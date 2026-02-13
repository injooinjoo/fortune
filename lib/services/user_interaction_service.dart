import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 사용자 콘텐츠 인터랙션 서비스
/// - 좋아요(저장) 토글
/// - 공유 기록
/// - 저장된 콘텐츠 조회
class UserInteractionService {
  static final UserInteractionService _instance = UserInteractionService._internal();
  factory UserInteractionService() => _instance;
  UserInteractionService._internal();

  final _supabase = Supabase.instance.client;
  static const _tableName = 'user_content_interactions';

  /// 현재 사용자 ID
  String? get _userId => _supabase.auth.currentUser?.id;

  /// 저장(좋아요) 토글
  /// 반환: true = 저장됨, false = 취소됨
  ///
  /// [contentKey]를 기준으로 조회/저장합니다.
  /// content_id는 UUID가 필요한 경우에만 사용됩니다.
  Future<bool> toggleSave({
    required String contentKey,
    required String contentType,
    String? contentId, // UUID 형식인 경우에만 전달
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) {
      debugPrint('[UserInteractionService] User not logged in');
      return false;
    }

    try {
      // 기존 저장 여부 확인 (content_key로 조회)
      final existing = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', _userId!)
          .eq('content_key', contentKey)
          .eq('interaction_type', 'save')
          .maybeSingle();

      if (existing != null) {
        // 이미 저장됨 → 삭제 (취소)
        await _supabase
            .from(_tableName)
            .delete()
            .eq('id', existing['id']);
        debugPrint('[UserInteractionService] Save removed: $contentKey');
        return false;
      } else {
        // 저장 안 됨 → 삽입
        final insertData = <String, dynamic>{
          'user_id': _userId,
          'content_type': contentType,
          'content_key': contentKey,
          'interaction_type': 'save',
          'source': 'result_card',
          'metadata': metadata ?? {},
        };

        // UUID 형식 content_id가 있으면 추가
        if (contentId != null && _isValidUuid(contentId)) {
          insertData['content_id'] = contentId;
        }

        await _supabase.from(_tableName).insert(insertData);
        debugPrint('[UserInteractionService] Saved: $contentKey');
        return true;
      }
    } catch (e) {
      debugPrint('[UserInteractionService] toggleSave error: $e');
      rethrow;
    }
  }

  /// 공유 기록
  Future<void> recordShare({
    required String contentKey,
    required String contentType,
    required String platform,
    String? contentId, // UUID 형식인 경우에만 전달
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) {
      debugPrint('[UserInteractionService] User not logged in');
      return;
    }

    try {
      final insertData = <String, dynamic>{
        'user_id': _userId,
        'content_type': contentType,
        'content_key': contentKey,
        'interaction_type': 'share',
        'platform': platform,
        'source': 'result_card',
        'metadata': metadata ?? {},
      };

      // UUID 형식 content_id가 있으면 추가
      if (contentId != null && _isValidUuid(contentId)) {
        insertData['content_id'] = contentId;
      }

      await _supabase.from(_tableName).insert(insertData);

      debugPrint('[UserInteractionService] Share recorded: $contentKey on $platform');
    } catch (e) {
      debugPrint('[UserInteractionService] recordShare error: $e');
      // 공유 기록 실패는 무시 (공유 자체는 진행)
    }
  }

  /// 저장 여부 확인
  Future<bool> isSaved({required String contentKey}) async {
    if (_userId == null) return false;

    try {
      final result = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', _userId!)
          .eq('content_key', contentKey)
          .eq('interaction_type', 'save')
          .maybeSingle();

      return result != null;
    } catch (e) {
      debugPrint('[UserInteractionService] isSaved error: $e');
      return false;
    }
  }

  /// 저장된 콘텐츠 키 목록 조회
  Future<List<String>> getSavedContentKeys({String? contentType}) async {
    if (_userId == null) return [];

    try {
      var query = _supabase
          .from(_tableName)
          .select('content_key')
          .eq('user_id', _userId!)
          .eq('interaction_type', 'save');

      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }

      final result = await query.order('created_at', ascending: false);

      return (result as List)
          .map((row) => row['content_key'] as String)
          .toList();
    } catch (e) {
      debugPrint('[UserInteractionService] getSavedContentKeys error: $e');
      return [];
    }
  }

  /// 저장된 콘텐츠 상세 목록 조회
  Future<List<Map<String, dynamic>>> getSavedContents({
    String? contentType,
    int limit = 50,
    int offset = 0,
  }) async {
    if (_userId == null) return [];

    try {
      var query = _supabase
          .from(_tableName)
          .select('content_key, content_type, metadata, created_at')
          .eq('user_id', _userId!)
          .eq('interaction_type', 'save');

      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }

      final result = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      debugPrint('[UserInteractionService] getSavedContents error: $e');
      return [];
    }
  }

  /// 여러 콘텐츠의 저장 상태 일괄 조회
  Future<Set<String>> getSavedStatusBatch(List<String> contentKeys) async {
    if (_userId == null || contentKeys.isEmpty) return {};

    try {
      final result = await _supabase
          .from(_tableName)
          .select('content_key')
          .eq('user_id', _userId!)
          .eq('interaction_type', 'save')
          .inFilter('content_key', contentKeys);

      return (result as List)
          .map((row) => row['content_key'] as String)
          .toSet();
    } catch (e) {
      debugPrint('[UserInteractionService] getSavedStatusBatch error: $e');
      return {};
    }
  }

  /// UUID 형식 검증
  bool _isValidUuid(String str) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str);
  }
}
