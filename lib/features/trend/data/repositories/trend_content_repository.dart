import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/models.dart';

/// 트렌드 콘텐츠 Repository
class TrendContentRepository {
  final SupabaseClient _supabase;

  TrendContentRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 트렌드 콘텐츠 목록 조회
  Future<TrendContentListResponse> getContents({
    TrendContentType? type,
    TrendCategory? category,
    int limit = 20,
    int offset = 0,
    String orderBy = 'participant_count',
    bool ascending = false,
  }) async {
    try {
      var query = _supabase
          .from('trend_contents')
          .select()
          .eq('is_active', true);

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (category != null) {
        query = query.eq('category', category.name);
      }

      final response = await query
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit - 1);

      final contents = (response as List)
          .map((json) => TrendContent.fromJson(_snakeToCamel(json)))
          .toList();

      // Total count - use the list length as approximation
      // For proper pagination, we check if there are more items
      final hasMore = contents.length >= limit;
      final totalCount = offset + contents.length + (hasMore ? 1 : 0);

      return TrendContentListResponse(
        contents: contents,
        totalCount: totalCount,
        hasMore: offset + contents.length < totalCount,
      );
    } catch (e) {
      debugPrint('❌ [TrendContentRepository] getContents error: $e');
      // 테이블이 없는 경우 빈 목록 반환 (DB 마이그레이션 전까지 임시 처리)
      return const TrendContentListResponse(
        contents: [],
        totalCount: 0,
        hasMore: false,
      );
    }
  }

  /// 단일 콘텐츠 조회
  Future<TrendContent?> getContentById(String id) async {
    try {
      final response = await _supabase
          .from('trend_contents')
          .select()
          .eq('id', id)
          .single();

      return TrendContent.fromJson(_snakeToCamel(response));
    } catch (e) {
      debugPrint('❌ [TrendContentRepository] getContentById error: $e');
      return null;
    }
  }

  /// 조회수 증가
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _supabase.rpc('increment_view_count', params: {
        'content_id': contentId,
      });
    } catch (e) {
      // RPC 함수가 없으면 직접 업데이트
      try {
        final current = await _supabase
            .from('trend_contents')
            .select('view_count')
            .eq('id', contentId)
            .single();

        await _supabase.from('trend_contents').update({
          'view_count': (current['view_count'] as int) + 1,
        }).eq('id', contentId);
      } catch (e2) {
        debugPrint('❌ [TrendContentRepository] incrementViewCount error: $e2');
      }
    }
  }

  /// 인기 콘텐츠 조회
  Future<List<TrendContent>> getPopularContents({
    TrendContentType? type,
    int limit = 10,
  }) async {
    try {
      var query = _supabase
          .from('trend_contents')
          .select()
          .eq('is_active', true);

      if (type != null) {
        query = query.eq('type', type.name);
      }

      final response = await query
          .order('participant_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TrendContent.fromJson(_snakeToCamel(json)))
          .toList();
    } catch (e) {
      debugPrint('❌ [TrendContentRepository] getPopularContents error: $e');
      return [];
    }
  }

  /// Snake case to camelCase 변환
  Map<String, dynamic> _snakeToCamel(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    for (final entry in json.entries) {
      final camelKey = entry.key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      result[camelKey] = entry.value;
    }
    return result;
  }
}
