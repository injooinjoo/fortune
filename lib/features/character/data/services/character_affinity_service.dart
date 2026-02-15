import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/character_affinity.dart';
import '../../../../core/services/user_scope_service.dart';
import '../../../../core/utils/logger.dart';

/// 캐릭터 호감도 서비스
/// - 로컬 저장 (Hive) + 서버 동기화 (Supabase)
/// - 일일 리셋, 스트릭 계산, 부재 패널티 처리
class CharacterAffinityService {
  static const String _boxName = 'character_affinity';
  static Box<String>? _box;

  // Supabase 클라이언트
  final SupabaseClient _supabase = Supabase.instance.client;

  // 싱글톤
  static final CharacterAffinityService _instance =
      CharacterAffinityService._internal();
  factory CharacterAffinityService() => _instance;
  CharacterAffinityService._internal();

  /// 초기화 (main.dart에서 호출)
  static Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      Logger.info('CharacterAffinityService initialized');
    } catch (e) {
      Logger.error('CharacterAffinityService initialization failed', e);
    }
  }

  /// 초기화 여부
  static bool get isInitialized => _box != null;

  // ========== 로컬 저장 (Hive) ==========

  /// 호감도 로드 (로컬)
  Future<CharacterAffinity?> loadAffinityLocal(String characterId) async {
    if (!isInitialized) {
      Logger.warning('CharacterAffinityService not initialized');
      return null;
    }

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final jsonString = _box!.get(_localKey(ownerScope, characterId));
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final affinity = CharacterAffinity.fromJson(json);

      Logger.info(
          'Loaded affinity for $characterId: ${affinity.lovePoints}pts (owner: $ownerScope)');
      return affinity;
    } catch (e) {
      Logger.error('Failed to load affinity locally', e);
      return null;
    }
  }

  /// 호감도 저장 (로컬)
  Future<bool> saveAffinityLocal(
      String characterId, CharacterAffinity affinity) async {
    if (!isInitialized) {
      Logger.warning('CharacterAffinityService not initialized');
      return false;
    }

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final jsonString = jsonEncode(affinity.toJson());
      await _box!.put(_localKey(ownerScope, characterId), jsonString);
      Logger.info(
          'Saved affinity for $characterId: ${affinity.lovePoints}pts (owner: $ownerScope)');
      return true;
    } catch (e) {
      Logger.error('Failed to save affinity locally', e);
      return false;
    }
  }

  /// 호감도 삭제 (로컬)
  Future<bool> deleteAffinityLocal(String characterId) async {
    if (!isInitialized) return false;

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      await _box!.delete(_localKey(ownerScope, characterId));
      Logger.info('Deleted affinity for $characterId (owner: $ownerScope)');
      return true;
    } catch (e) {
      Logger.error('Failed to delete affinity locally', e);
      return false;
    }
  }

  /// 호감도 삭제 (서버)
  Future<bool> deleteAffinityFromServer(String characterId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      await _supabase
          .from('user_character_affinity')
          .delete()
          .eq('user_id', userId)
          .eq('character_id', characterId);

      Logger.info('Deleted affinity from server for $characterId');
      return true;
    } catch (e) {
      Logger.error('Failed to delete affinity from server', e);
      return false;
    }
  }

  // ========== 서버 동기화 (Supabase) ==========

  /// 호감도 로드 (서버)
  Future<CharacterAffinity?> loadAffinityFromServer(String characterId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('No user logged in');
        return null;
      }

      final response = await _supabase
          .from('user_character_affinity')
          .select()
          .eq('user_id', userId)
          .eq('character_id', characterId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final affinity = CharacterAffinity.fromJson(response);
      Logger.info(
          'Loaded affinity from server for $characterId: ${affinity.lovePoints}pts');
      return affinity;
    } catch (e) {
      Logger.error('Failed to load affinity from server', e);
      return null;
    }
  }

  /// 호감도 저장 (서버)
  Future<bool> saveAffinityToServer(
      String characterId, CharacterAffinity affinity) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('No user logged in');
        return false;
      }

      final data = {
        'user_id': userId,
        ...affinity.toSupabaseRow(characterId),
      };

      await _supabase
          .from('user_character_affinity')
          .upsert(data, onConflict: 'user_id,character_id');

      Logger.info(
          'Saved affinity to server for $characterId: ${affinity.lovePoints}pts');
      return true;
    } catch (e) {
      Logger.error('Failed to save affinity to server', e);
      return false;
    }
  }

  // ========== 통합 로드/저장 ==========

  /// 호감도 로드 (로컬 우선, 서버 폴백)
  Future<CharacterAffinity> loadAffinity(String characterId) async {
    // 1. 로컬에서 먼저 로드
    var affinity = await loadAffinityLocal(characterId);

    // 2. 로컬에 없으면 서버에서 로드
    if (affinity == null) {
      affinity = await loadAffinityFromServer(characterId);

      // 서버에서 가져왔으면 로컬에 캐시
      if (affinity != null) {
        await saveAffinityLocal(characterId, affinity);
      }
    }

    // 3. 둘 다 없으면 기본값
    affinity ??= const CharacterAffinity();

    // 4. 일일 리셋 및 부재 패널티 적용
    affinity = _applyDailyResetAndPenalty(affinity);

    return affinity;
  }

  /// 호감도 저장 (로컬 + 서버 동기화)
  Future<bool> saveAffinity(
    String characterId,
    CharacterAffinity affinity, {
    bool syncToServer = true,
  }) async {
    // 1. 로컬에 즉시 저장
    final localSuccess = await saveAffinityLocal(characterId, affinity);

    // 2. 서버에 동기화 (비동기)
    if (syncToServer) {
      // 백그라운드에서 서버 동기화
      saveAffinityToServer(characterId, affinity).then((success) {
        if (!success) {
          Logger.warning(
              'Server sync failed for $characterId, will retry later');
        }
      });
    }

    return localSuccess;
  }

  /// 호감도 삭제 (로컬 + 선택적 서버)
  Future<bool> deleteAffinity(
    String characterId, {
    bool deleteFromServer = false,
  }) async {
    final localDeleted = await deleteAffinityLocal(characterId);

    if (deleteFromServer) {
      await deleteAffinityFromServer(characterId);
    }

    return localDeleted;
  }

  /// 서버에서 동기화 (서버 → 로컬)
  Future<CharacterAffinity?> syncFromServer(String characterId) async {
    final serverAffinity = await loadAffinityFromServer(characterId);
    if (serverAffinity != null) {
      await saveAffinityLocal(characterId, serverAffinity);
      return serverAffinity;
    }
    return null;
  }

  // ========== 호감도 업데이트 ==========

  /// 호감도 포인트 추가 (AI 응답 기반)
  Future<AffinityUpdateResult> addPoints(
    String characterId,
    int points, {
    String? reason,
    AffinityInteractionType interactionType = AffinityInteractionType.neutral,
  }) async {
    // 현재 호감도 로드
    var affinity = await loadAffinity(characterId);
    final previousPhase = affinity.phase;

    // 포인트 추가
    affinity = affinity.addPointsWithTracking(points,
        interactionType: interactionType);

    // 저장
    await saveAffinity(characterId, affinity);

    // 단계 전환 확인
    PhaseTransitionResult? transition;
    if (affinity.phase != previousPhase) {
      transition = PhaseTransitionResult(
        previousPhase: previousPhase,
        newPhase: affinity.phase,
      );

      // 단계 상승 시 phaseHistory에 기록 (이미 addPointsWithTracking에서 처리됨)
      Logger.info(
          'Phase transition: ${previousPhase.displayName} → ${affinity.phase.displayName}');
    }

    return AffinityUpdateResult(
      affinity: affinity,
      pointsAdded: points,
      reason: reason,
      transition: transition,
    );
  }

  /// 첫 대화 보너스 적용
  Future<CharacterAffinity> applyFirstChatBonus(String characterId) async {
    final affinity = await loadAffinity(characterId);
    final updated = affinity.applyFirstChatBonus();

    if (updated != affinity) {
      await saveAffinity(characterId, updated);
      Logger.info('Applied first chat bonus for $characterId');
    }

    return updated;
  }

  /// 스트릭 보너스 적용
  Future<CharacterAffinity> applyStreakBonus(String characterId) async {
    final affinity = await loadAffinity(characterId);
    final updated = affinity.applyStreakBonus();

    if (updated != affinity) {
      await saveAffinity(characterId, updated);
      Logger.info(
          'Applied streak bonus for $characterId: ${updated.currentStreak} days');
    }

    return updated;
  }

  // ========== 헬퍼 메서드 ==========

  /// 일일 리셋 및 부재 패널티 적용
  CharacterAffinity _applyDailyResetAndPenalty(CharacterAffinity affinity) {
    // 부재 패널티 적용
    return affinity.applyAbsencePenalty();
  }

  /// 모든 캐릭터 호감도 로드
  Future<Map<String, CharacterAffinity>> loadAllAffinities() async {
    if (!isInitialized) return {};

    final Map<String, CharacterAffinity> result = {};

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final prefix = '$ownerScope|';
      final scopedKeys =
          _box!.keys.cast<String>().where((key) => key.startsWith(prefix));

      for (final key in scopedKeys) {
        final characterId = key.substring(prefix.length);
        final affinity = await loadAffinityLocal(characterId);
        if (affinity != null) {
          result[characterId] = _applyDailyResetAndPenalty(affinity);
        }
      }
    } catch (e) {
      Logger.error('Failed to load all affinities', e);
    }

    return result;
  }

  /// 모든 호감도 삭제
  Future<bool> clearAllAffinities() async {
    if (!isInitialized) return false;

    try {
      final ownerScope = await UserScopeService.instance.getCurrentOwnerId();
      final prefix = '$ownerScope|';
      final scopedKeys = _box!.keys
          .cast<String>()
          .where((key) => key.startsWith(prefix))
          .toList();
      for (final key in scopedKeys) {
        await _box!.delete(key);
      }
      Logger.info('Cleared all local affinities for owner: $ownerScope');
      return true;
    } catch (e) {
      Logger.error('Failed to clear all affinities', e);
      return false;
    }
  }

  /// 단계 전환 조건 충족 여부 확인
  bool canTransitionToPhase(
      CharacterAffinity affinity, AffinityPhase targetPhase) {
    // 포인트 조건
    if (affinity.lovePoints < targetPhase.minPoints) return false;

    // 추가 조건 (메시지 수, 스트릭)
    return targetPhase.requirements.isMet(affinity);
  }

  String _localKey(String ownerScope, String characterId) {
    return '$ownerScope|$characterId';
  }
}

/// 호감도 업데이트 결과
class AffinityUpdateResult {
  final CharacterAffinity affinity;
  final int pointsAdded;
  final String? reason;
  final PhaseTransitionResult? transition;

  const AffinityUpdateResult({
    required this.affinity,
    required this.pointsAdded,
    this.reason,
    this.transition,
  });

  /// 단계가 변경되었는지
  bool get hasTransition => transition != null;

  /// 단계가 상승했는지
  bool get isUpgrade => transition?.isUpgrade ?? false;
}
