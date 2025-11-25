import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling celebrity data from Supabase database
class CelebrityService {
  static final CelebrityService _instance = CelebrityService._internal();
  factory CelebrityService() => _instance;
  CelebrityService._internal();
  
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get celebrities by category
  Future<List<Map<String, dynamic>>> getCelebritiesByCategory({
    required String category,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('''
            id,
            name,
            name_en,
            category,
            gender,
            birth_date,
            profile_image_url,
            description,
            keywords,
            popularity_score
          ''')
          .eq('is_active', true)
          .eq('category', category)
          .order('popularity_score', ascending: false)
          .order('name', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return empty list silently
      return [];
    }
  }

  /// Get random celebrities
  Future<List<Map<String, dynamic>>> getRandomCelebrities({
    String? category,
    int limit = 10,
  }) async {
    try {
      final query = _supabase
          .from('celebrities')
          .select('''
            id,
            name,
            name_en,
            category,
            gender,
            birth_date,
            profile_image_url,
            description,
            keywords,
            popularity_score
          ''')
          .eq('is_active', true);

      if (category != null) {
        query.eq('category', category);
      }

      final response = await query
          .order('popularity_score', ascending: false)
          .limit(limit * 3); // Get more to randomize from

      final celebrities = List<Map<String, dynamic>>.from(response);
      celebrities.shuffle();
      return celebrities.take(limit).toList();
    } catch (e) {
      // Return empty list silently
      return [];
    }
  }

  /// Get celebrities with same birthday (month and day)
  Future<List<Map<String, dynamic>>> getCelebritiesWithBirthday(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('celebrities')
          .select('''
            id,
            name,
            stage_name,
            celebrity_type,
            gender,
            birth_date,
            nationality,
            profession_data
          ''')
          .eq('birth_date', dateString)
          .order('name')
          .limit(10);

      final celebrities = List<Map<String, dynamic>>.from(response);

      if (celebrities.isNotEmpty) {
        return celebrities.map((celebrity) {
          return {
            'id': celebrity['id'],
            'name': celebrity['stage_name'] ?? celebrity['name'],
            'birth_date': celebrity['birth_date'],
            'description': _getCelebrityTypeDescription(celebrity['celebrity_type']),
            'keywords': [celebrity['celebrity_type']],
            'popularity_score': 85, // Default score
          };
        }).toList();
      }

      // If no celebrities found, return empty list instead of fallback
      return [];
    } catch (e) {
      // Return empty list if query fails
      return [];
    }
  }
  
  /// Get description for celebrity type
  static String _getCelebrityTypeDescription(String? celebrityType) {
    switch (celebrityType) {
      case 'pro_gamer':
        return '프로게이머';
      case 'streamer':
        return '스트리머';
      case 'politician':
        return '정치인';
      case 'business':
        return '기업인';
      case 'solo_singer':
        return '솔로 가수';
      case 'idol_member':
        return '아이돌 멤버';
      case 'actor':
        return '배우';
      case 'athlete':
        return '운동선수';
      default:
        return '유명인';
    }
  }

  /// Get celebrities born today
  Future<List<Map<String, dynamic>>> getTodaysCelebrities() async {
    return await getCelebritiesWithBirthday(DateTime.now());
  }

  /// Search celebrities by name or keywords
  Future<List<Map<String, dynamic>>> searchCelebrities({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('''
            id,
            name,
            name_en,
            category,
            gender,
            birth_date,
            profile_image_url,
            description,
            keywords,
            popularity_score
          ''')
          .eq('is_active', true)
          .or('name.ilike.%$query%,name_en.ilike.%$query%,description.ilike.%$query%')
          .order('popularity_score', ascending: false)
          .order('name', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return empty list silently
      return [];
    }
  }

  /// Get popular celebrities
  Future<List<Map<String, dynamic>>> getPopularCelebrities({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('''
            id,
            name,
            name_en,
            category,
            gender,
            birth_date,
            profile_image_url,
            description,
            keywords,
            popularity_score
          ''')
          .eq('is_active', true)
          .order('popularity_score', ascending: false)
          .order('name', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return empty list silently
      return [];
    }
  }
}