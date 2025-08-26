import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity.dart';
import '../core/utils/logger.dart';

class CelebritySupabaseService {
  static final CelebritySupabaseService _instance = CelebritySupabaseService._internal();
  factory CelebritySupabaseService() => _instance;
  CelebritySupabaseService._internal();

  final _supabase = Supabase.instance.client;
  static const String _tableName = 'celebrities';

  /// 모든 활성 유명인 가져오기
  Future<List<Celebrity>> fetchAllCelebrities() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .order('name');

      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to fetch all celebrities', e);
      throw Exception('유명인 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 카테고리별 유명인 가져오기
  Future<List<Celebrity>> fetchCelebritiesByCategory(CelebrityCategory category) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .eq('category', category.name)
          .order('popularity_score', ascending: false)
          .order('name');

      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to fetch celebrities by category: ${category.name}', e);
      throw Exception('카테고리별 유명인 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 유명인 검색
  Future<List<Celebrity>> searchCelebrities({
    String? query,
    CelebrityFilter? filter,
    int? limit,
  }) async {
    try {
      var queryBuilder = _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true);

      // 검색어가 있는 경우
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'name.ilike.%$query%,'
          'name_en.ilike.%$query%,'
          'description.ilike.%$query%,'
          'keywords.cs.{$query}'
        );
      }

      // 필터 적용
      if (filter != null) {
        if (filter.category != null) {
          queryBuilder = queryBuilder.eq('category', filter.category!.name);
        }
        if (filter.gender != null) {
          queryBuilder = queryBuilder.eq('gender', filter.gender!.name);
        }
      }

      var orderedBuilder = queryBuilder
          .order('popularity_score', ascending: false)
          .order('name');

      if (limit != null) {
        orderedBuilder = orderedBuilder.limit(limit);
      }

      final response = await orderedBuilder;
      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to search celebrities', e);
      throw Exception('유명인 검색에 실패했습니다: $e');
    }
  }

  /// ID로 유명인 가져오기
  Future<Celebrity?> getCelebrityById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return _mapToCelebrity(response);
    } catch (e) {
      Logger.error('Failed to get celebrity by id: $id', e);
      throw Exception('유명인 정보를 불러오는데 실패했습니다: $e');
    }
  }

  /// 인기 유명인 가져오기
  Future<List<Celebrity>> getPopularCelebrities({
    CelebrityCategory? category,
    int limit = 10,
  }) async {
    try {
      var queryBuilder = _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true);

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }

      final response = await queryBuilder
          .order('popularity_score', ascending: false)
          .order('name')
          .limit(limit);

      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to get popular celebrities', e);
      throw Exception('인기 유명인 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 랜덤 유명인 가져오기
  Future<List<Celebrity>> getRandomCelebrities({
    CelebrityCategory? category,
    int limit = 10,
  }) async {
    try {
      // PostgreSQL의 RANDOM() 함수 사용
      var queryBuilder = _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true);

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }

      final response = await queryBuilder
          .order('popularity_score', ascending: false) // 인기도로 먼저 정렬
          .limit(limit * 3); // 더 많이 가져온 후 클라이언트에서 셔플

      final celebrities = _mapToCelebrities(response);
      celebrities.shuffle(); // 클라이언트에서 셔플
      return celebrities.take(limit).toList();
    } catch (e) {
      Logger.error('Failed to get random celebrities', e);
      throw Exception('랜덤 유명인 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 생일이 같은 유명인 가져오기
  Future<List<Celebrity>> getCelebritiesWithBirthday(DateTime date) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .eq('extract(month from birth_date)', date.month)
          .eq('extract(day from birth_date)', date.day)
          .order('popularity_score', ascending: false);

      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to get celebrities with birthday: ${date.toString()}', e);
      throw Exception('생일이 같은 유명인을 찾는데 실패했습니다: $e');
    }
  }

  /// 자동완성용 제안 가져오기
  Future<List<Celebrity>> getSuggestions(String query, {int limit = 10}) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .or(
            'name.ilike.%$query%,'
            'name_en.ilike.%$query%'
          )
          .order('popularity_score', ascending: false)
          .order('name')
          .limit(limit);

      return _mapToCelebrities(response);
    } catch (e) {
      Logger.error('Failed to get celebrity suggestions for query: $query', e);
      throw Exception('자동완성 제안을 가져오는데 실패했습니다: $e');
    }
  }

  /// 유명인 통계 가져오기
  Future<Map<String, dynamic>> getCelebrityStatistics() async {
    try {
      // 전체 수
      final totalResponse = await _supabase
          .from(_tableName)
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact);

      // 카테고리별 수
      final categoryResponse = await _supabase
          .from(_tableName)
          .select('category')
          .eq('is_active', true);

      // 성별 통계
      final genderResponse = await _supabase
          .from(_tableName)
          .select('gender')
          .eq('is_active', true);

      final stats = <String, dynamic>{};
      stats['total'] = totalResponse.count ?? 0;

      // 카테고리별 통계
      final byCategory = <String, int>{};
      for (final row in categoryResponse) {
        final category = row['category'] as String;
        byCategory[category] = (byCategory[category] ?? 0) + 1;
      }
      stats['byCategory'] = byCategory;

      // 성별 통계
      final byGender = <String, int>{};
      for (final row in genderResponse) {
        final gender = row['gender'] as String;
        byGender[gender] = (byGender[gender] ?? 0) + 1;
      }
      stats['byGender'] = byGender;

      return stats;
    } catch (e) {
      Logger.error('Failed to get celebrity statistics', e);
      throw Exception('유명인 통계를 가져오는데 실패했습니다: $e');
    }
  }

  /// 새 유명인 추가 (관리자용)
  Future<Celebrity> addCelebrity(Celebrity celebrity) async {
    try {
      final data = _celebrityToJson(celebrity);
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return _mapToCelebrity(response);
    } catch (e) {
      Logger.error('Failed to add celebrity', e);
      throw Exception('유명인 추가에 실패했습니다: $e');
    }
  }

  /// 유명인 정보 수정 (관리자용)
  Future<Celebrity> updateCelebrity(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();

      return _mapToCelebrity(response);
    } catch (e) {
      Logger.error('Failed to update celebrity: $id', e);
      throw Exception('유명인 정보 수정에 실패했습니다: $e');
    }
  }

  /// 유명인 비활성화 (관리자용)
  Future<void> deactivateCelebrity(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      Logger.error('Failed to deactivate celebrity: $id', e);
      throw Exception('유명인 비활성화에 실패했습니다: $e');
    }
  }

  /// Response를 Celebrity 리스트로 매핑
  List<Celebrity> _mapToCelebrities(List<Map<String, dynamic>> response) {
    return response.map((json) => _mapToCelebrity(json)).toList();
  }

  /// JSON을 Celebrity 객체로 매핑
  Celebrity _mapToCelebrity(Map<String, dynamic> json) {
    return Celebrity(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String? ?? '',
      category: _parseCelebrityCategory(json['category'] as String),
      gender: _parseGender(json['gender'] as String),
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthTime: json['birth_time'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>(),
      nationality: json['nationality'] as String? ?? '한국',
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  /// Celebrity를 JSON으로 변환
  Map<String, dynamic> _celebrityToJson(Celebrity celebrity) {
    return {
      if (celebrity.id.isNotEmpty) 'id': celebrity.id,
      'name': celebrity.name,
      'name_en': celebrity.nameEn,
      'category': celebrity.category.name,
      'gender': celebrity.gender.name,
      'birth_date': celebrity.birthDate.toIso8601String().split('T')[0],
      if (celebrity.birthTime != null) 'birth_time': celebrity.birthTime,
      if (celebrity.profileImageUrl != null) 'profile_image_url': celebrity.profileImageUrl,
      if (celebrity.description != null) 'description': celebrity.description,
      if (celebrity.keywords != null) 'keywords': celebrity.keywords,
      'nationality': celebrity.nationality,
      if (celebrity.additionalInfo != null) 'additional_info': celebrity.additionalInfo,
    };
  }

  /// 문자열을 CelebrityCategory로 파싱
  CelebrityCategory _parseCelebrityCategory(String category) {
    switch (category) {
      case 'politician':
        return CelebrityCategory.politician;
      case 'actor':
        return CelebrityCategory.actor;
      case 'singer':
        return CelebrityCategory.singer;
      case 'sports':
      case 'athlete':
        return CelebrityCategory.sports;
      case 'pro_gamer':
        return CelebrityCategory.proGamer;
      case 'streamer':
        return CelebrityCategory.streamer;
      case 'youtuber':
        return CelebrityCategory.youtuber;
      case 'business_leader':
        return CelebrityCategory.businessLeader;
      case 'entertainer':
        return CelebrityCategory.actor; // fallback
      default:
        return CelebrityCategory.actor; // default fallback
    }
  }

  /// 문자열을 Gender로 파싱
  Gender _parseGender(String gender) {
    switch (gender) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other; // default fallback
    }
  }
}