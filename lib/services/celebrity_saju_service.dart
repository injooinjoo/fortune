import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_saju.dart';

class CelebritySajuService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 유명인사 사주 검색 (이름으로)
  Future<List<CelebritySaju>> searchCelebrities(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .ilike('name', '%$query%')
          .order('name')
          .limit(20);

      return (response as List)
          .map((data) => CelebritySaju.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('유명인사 검색 중 오류가 발생했습니다: $e');
    }
  }

  /// 카테고리별 인기 유명인사 조회
  Future<List<CelebritySaju>> getPopularCelebrities([String? category]) async {
    try {
      var query = _supabase
          .from('celebrities')
          .select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('name')
          .limit(50);

      return (response as List)
          .map((data) => CelebritySaju.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('인기 유명인사 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 유명인사 사주 정보 조회
  Future<CelebritySaju?> getCelebritySaju(String name) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('name', name)
          .single();

      return CelebritySaju.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리 목록 조회
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('category')
          .order('category');

      final categories = (response as List)
          .map((data) => data['category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      throw Exception('카테고리 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 오행별 유명인사 조회 (같은 오행 성향)
  Future<List<CelebritySaju>> getCelebritiesByElement(String dominantElement) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .order('${dominantElement.toLowerCase()}_count', ascending: false)
          .limit(20);

      return (response as List)
          .map((data) => CelebritySaju.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('오행별 유명인사 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 랜덤 유명인사 추천 (개인 멤버만)
  Future<List<CelebritySaju>> getRandomCelebrities([int limit = 5]) async {
    try {
      // 개인 멤버만 가져오기 (is_group_member = true)
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('is_group_member', true)  // 개인 멤버만
          .eq('is_active', true)
          .limit(limit * 5);

      debugPrint('🎭 [CELEBRITY] 개인 멤버 쿼리 응답: ${(response as List).length}개');

      if ((response as List).isEmpty) {
        // is_group_member 컬럼이 없거나 데이터가 없는 경우 fallback
        debugPrint('🎭 [CELEBRITY] 개인 멤버 없음, 전체 쿼리 시도');
        final fallbackResponse = await _supabase
            .from('celebrities')
            .select()
            .limit(limit * 3);

        final allCelebrities = (fallbackResponse as List)
            .map((data) {
              debugPrint('🎭 [CELEBRITY] 데이터: name=${data['name']}, is_group_member=${data['is_group_member']}, birth_date=${data['birth_date']}');
              return CelebritySaju.fromJson(data);
            })
            .toList();

        allCelebrities.shuffle();
        return allCelebrities.take(limit).toList();
      }

      final celebrities = (response as List)
          .map((data) {
            debugPrint('🎭 [CELEBRITY] 개인 멤버: name=${data['name']}, group=${data['group_name']}, birth_date=${data['birth_date']}');
            return CelebritySaju.fromJson(data);
          })
          .toList();

      celebrities.shuffle();
      return celebrities.take(limit).toList();
    } catch (e) {
      debugPrint('🎭 [CELEBRITY] 쿼리 실패: $e');
      return [];
    }
  }
}