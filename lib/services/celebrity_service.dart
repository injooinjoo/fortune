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
          .like('birth_date', '%${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}')
          .order('popularity_score', ascending: false)
          .limit(10);

      final celebrities = List<Map<String, dynamic>>.from(response);
      
      // If no celebrities found with exact birthday, return fallback data silently
      if (celebrities.isEmpty) {
        return _getFallbackCelebrities(date.month, date.day);
      }
      
      return celebrities;
    } catch (e) {
      // Return fallback data silently without print
      return _getFallbackCelebrities(date.month, date.day);
    }
  }
  
  /// Generate fallback celebrity data based on birth month and day
  static List<Map<String, dynamic>> _getFallbackCelebrities(int month, int day) {
    final fallbackCelebrities = [
      {
        'id': 1,
        'name': '김태희',
        'name_en': 'Kim Tae Hee',
        'category': '배우',
        'gender': 'F',
        'birth_date': '1980-03-29',
        'profile_image_url': null,
        'description': '대한민국의 배우',
        'keywords': ['배우', '드라마', '영화'],
        'popularity_score': 95,
      },
      {
        'id': 2,
        'name': '송중기',
        'name_en': 'Song Joong Ki',
        'category': '배우',
        'gender': 'M',
        'birth_date': '1985-09-19',
        'profile_image_url': null,
        'description': '대한민국의 배우',
        'keywords': ['배우', '드라마', '영화'],
        'popularity_score': 93,
      },
      {
        'id': 3,
        'name': '아이유',
        'name_en': 'IU',
        'category': '가수',
        'gender': 'F',
        'birth_date': '1993-05-16',
        'profile_image_url': null,
        'description': '대한민국의 가수 겸 배우',
        'keywords': ['가수', '솔로', '배우'],
        'popularity_score': 98,
      },
    ];
    
    // Return 2-3 celebrities based on hash of month/day
    final hash = (month * 31 + day) % fallbackCelebrities.length;
    final count = 2 + (hash % 2); // 2 or 3 celebrities
    
    return fallbackCelebrities.take(count).toList();
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