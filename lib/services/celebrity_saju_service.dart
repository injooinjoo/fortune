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

  /// 랜덤 유명인사 추천
  Future<List<CelebritySaju>> getRandomCelebrities([int limit = 5]) async {
    try {
      final response = await _supabase
          .rpc('get_random_celebrities', params: {'limit_count': limit});

      return (response as List)
          .map((data) => CelebritySaju.fromJson(data))
          .toList();
    } catch (e) {
      // RPC 함수가 없는 경우 대안 (is_active=true만 조회, 그룹 제외)
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('is_active', true)
          .limit(limit * 3);

      final allCelebrities = (response as List)
          .map((data) => CelebritySaju.fromJson(data))
          .toList();

      allCelebrities.shuffle();
      return allCelebrities.take(limit).toList();
    }
  }
}