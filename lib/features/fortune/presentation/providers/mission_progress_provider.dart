import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// 미션 상태
enum MissionStatus {
  notStarted,
  inProgress,
  completed,
  expired,
}

/// 개별 미션 진행 상태
class MissionProgress {
  final String missionId;
  final String missionType;
  final String title;
  final String description;
  final String emoji;
  final int goalValue;
  final int currentValue;
  final MissionStatus status;
  final int progressPercentage;
  final int streakCount;
  final bool rewardClaimed;

  const MissionProgress({
    required this.missionId,
    required this.missionType,
    required this.title,
    required this.description,
    required this.emoji,
    required this.goalValue,
    required this.currentValue,
    required this.status,
    required this.progressPercentage,
    required this.streakCount,
    required this.rewardClaimed,
  });

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      missionId: json['mission_id'] as String,
      missionType: json['mission_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String? ?? '😊',
      goalValue: json['goal_value'] as int,
      currentValue: json['current_value'] as int? ?? 0,
      status: _parseStatus(json['status'] as String?),
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      streakCount: json['streak_count'] as int? ?? 0,
      rewardClaimed: json['reward_claimed'] as bool? ?? false,
    );
  }

  static MissionStatus _parseStatus(String? status) {
    switch (status) {
      case 'in_progress':
        return MissionStatus.inProgress;
      case 'completed':
        return MissionStatus.completed;
      case 'expired':
        return MissionStatus.expired;
      default:
        return MissionStatus.notStarted;
    }
  }

  bool get isCompleted => status == MissionStatus.completed;
  bool get isActive => status == MissionStatus.inProgress;
  bool get canClaim => isCompleted && !rewardClaimed;
}

/// 미션 진행 상태 전체
class MissionProgressState {
  final bool isLoading;
  final List<MissionProgress> missions;
  final String? errorMessage;

  const MissionProgressState({
    this.isLoading = false,
    this.missions = const [],
    this.errorMessage,
  });

  MissionProgressState copyWith({
    bool? isLoading,
    List<MissionProgress>? missions,
    String? errorMessage,
  }) {
    return MissionProgressState(
      isLoading: isLoading ?? this.isLoading,
      missions: missions ?? this.missions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 진행 중인 미션 수
  int get activeMissionCount => missions.where((m) => m.isActive).length;

  /// 완료된 미션 수
  int get completedMissionCount => missions.where((m) => m.isCompleted).length;

  /// 전체 미션 완료율
  double get overallCompletionRate {
    if (missions.isEmpty) return 0.0;
    return completedMissionCount / missions.length * 100;
  }
}

/// 미션 진행 Provider
final missionProgressProvider =
    StateNotifierProvider<MissionProgressNotifier, MissionProgressState>((ref) {
  return MissionProgressNotifier();
});

/// 미션 진행 상태 관리 클래스
class MissionProgressNotifier extends StateNotifier<MissionProgressState> {
  MissionProgressNotifier() : super(const MissionProgressState()) {
    _loadMissions();
  }

  final _supabase = Supabase.instance.client;

  /// 미션 목록 로드
  Future<void> _loadMissions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _supabase.rpc('get_user_mission_status',
          params: {'p_user_id': userId});

      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final missions = (response as List)
          .map((data) =>
              MissionProgress.fromJson(data as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        missions: missions,
      );

      developer.log('✅ MissionProgress: ${missions.length}개 미션 로드 완료');
    } catch (e) {
      developer.log('❌ MissionProgress 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 미션 시작
  Future<void> startMission(String missionId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      developer.log('🎯 MissionProgress: 미션 시작 - $missionId');

      await _supabase.from('face_reading_mission_progress').insert({
        'user_id': userId,
        'mission_id': missionId,
        'status': 'in_progress',
        'current_value': 0,
        'streak_count': 0,
      });

      await _loadMissions();
      developer.log('✅ MissionProgress: 미션 시작 완료');
    } catch (e) {
      developer.log('❌ MissionProgress 미션 시작 실패: $e');
      rethrow;
    }
  }

  /// 미션 진행도 업데이트 (관상 분석 후 자동 호출)
  Future<void> updateProgress({
    required int conditionScore,
    required double smilePercentage,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      developer.log('📈 MissionProgress: 진행도 업데이트');

      await _supabase.rpc('update_face_reading_mission_progress', params: {
        'p_user_id': userId,
        'p_condition_score': conditionScore,
        'p_smile_percentage': smilePercentage,
      });

      await _loadMissions();
      developer.log('✅ MissionProgress: 진행도 업데이트 완료');
    } catch (e) {
      developer.log('⚠️ MissionProgress 업데이트 실패: $e');
      // 업데이트 실패는 메인 플로우에 영향 주지 않음
    }
  }

  /// 보상 수령
  Future<void> claimReward(String missionId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      developer.log('🎁 MissionProgress: 보상 수령 - $missionId');

      await _supabase
          .from('face_reading_mission_progress')
          .update({'reward_claimed': true})
          .eq('user_id', userId)
          .eq('mission_id', missionId);

      await _loadMissions();
      developer.log('✅ MissionProgress: 보상 수령 완료');
    } catch (e) {
      developer.log('❌ MissionProgress 보상 수령 실패: $e');
      rethrow;
    }
  }

  /// 새로고침
  Future<void> refresh() => _loadMissions();
}

/// 진행 중인 미션 Provider
final activeMissionsProvider = Provider<List<MissionProgress>>((ref) {
  final state = ref.watch(missionProgressProvider);
  return state.missions.where((m) => m.isActive).toList();
});

/// 완료된 미션 Provider
final completedMissionsProvider = Provider<List<MissionProgress>>((ref) {
  final state = ref.watch(missionProgressProvider);
  return state.missions.where((m) => m.isCompleted).toList();
});

/// 보상 수령 가능한 미션 Provider
final claimableMissionsProvider = Provider<List<MissionProgress>>((ref) {
  final state = ref.watch(missionProgressProvider);
  return state.missions.where((m) => m.canClaim).toList();
});

/// 미소 챌린지 진행률 Provider
final smileChallengeProgressProvider = Provider<MissionProgress?>((ref) {
  final state = ref.watch(missionProgressProvider);
  try {
    return state.missions.firstWhere((m) => m.missionType == 'smile_challenge');
  } catch (_) {
    return null;
  }
});

/// 연속 기록 현황 Provider
final streakDaysProvider = Provider<int>((ref) {
  final state = ref.watch(missionProgressProvider);
  try {
    final weeklyStreak =
        state.missions.firstWhere((m) => m.missionType == 'weekly_streak');
    return weeklyStreak.streakCount;
  } catch (_) {
    return 0;
  }
});
