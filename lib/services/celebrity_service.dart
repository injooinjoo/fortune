import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_simple.dart';

/// Service for handling celebrity data from Supabase database (New Schema)
class CelebrityService {
  static final CelebrityService _instance = CelebrityService._internal();
  factory CelebrityService() => _instance;
  CelebrityService._internal();

  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all celebrities (active only, excludes groups)
  Future<List<Celebrity>> getAllCelebrities({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('is_active', true)
          .order('name')
          .limit(limit);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting all celebrities: $e');
      return [];
    }
  }

  /// Get celebrity by ID
  Future<Celebrity?> getCelebrityById(String id) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('id', id)
          .single();

      return Celebrity.fromJson(response);
    } catch (e) {
      debugPrint('Error getting celebrity by ID: $e');
      return null;
    }
  }

  /// Get celebrities by type (active only)
  Future<List<Celebrity>> getCelebritiesByType(
    CelebrityType type, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('is_active', true)
          .eq('celebrity_type', type.name)
          .order('name')
          .limit(limit);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting celebrities by type: $e');
      return [];
    }
  }

  /// Search celebrities (active only)
  Future<List<Celebrity>> searchCelebrities(
    String query, {
    CelebrityType? type,
    Gender? gender,
    String? nationality,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('celebrities')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%');

      if (type != null) {
        queryBuilder = queryBuilder.eq('celebrity_type', type.name);
      }

      if (gender != null) {
        queryBuilder = queryBuilder.eq('gender', gender.name);
      }

      if (nationality != null) {
        queryBuilder = queryBuilder.eq('nationality', nationality);
      }

      final response = await queryBuilder
          .order('name')
          .limit(limit);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching celebrities: $e');
      return [];
    }
  }

  /// Get random celebrities (active only, excludes groups)
  Future<List<Celebrity>> getRandomCelebrities({
    int count = 10,
    CelebrityType? type,
  }) async {
    try {
      var queryBuilder = _supabase.from('celebrities').select().eq('is_active', true);

      if (type != null) {
        queryBuilder = queryBuilder.eq('celebrity_type', type.name);
      }

      final response = await queryBuilder.limit(count);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting random celebrities: $e');
      return [];
    }
  }

  /// Get celebrities by birth year range
  Future<List<Celebrity>> getCelebritiesByBirthYearRange(
    int startYear,
    int endYear, {
    CelebrityType? type,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('celebrities')
          .select()
          .gte('birth_date', '$startYear-01-01')
          .lte('birth_date', '$endYear-12-31');

      if (type != null) {
        queryBuilder = queryBuilder.eq('celebrity_type', type.name);
      }

      final response = await queryBuilder
          .order('name')
          .limit(limit);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting celebrities by birth year range: $e');
      return [];
    }
  }

  /// Get celebrities with same birthday
  Future<List<Celebrity>> getCelebritiesWithSameBirthday(DateTime birthDate) async {
    try {
      final dateString = birthDate.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('birth_date', dateString)
          .order('name');

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting celebrities with same birthday: $e');
      return [];
    }
  }

  /// Get celebrities with external links
  Future<List<Celebrity>> getCelebritiesWithExternalLinks(String platform) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .not('external_ids', 'is', null)
          .limit(50);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting celebrities with external links: $e');
      return [];
    }
  }

  // Profession-specific methods

  /// Get pro gamers by game
  Future<List<Celebrity>> getProGamersByGame(String gameTitle) async {
    try {
      final response = await _supabase.rpc('get_pro_gamers_by_game', params: {
        'game_title': gameTitle,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting pro gamers by game: $e');
      return [];
    }
  }

  /// Get streamers by platform
  Future<List<Celebrity>> getStreamersByPlatform(String platform) async {
    try {
      final response = await _supabase.rpc('get_streamers_by_platform', params: {
        'platform': platform,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting streamers by platform: $e');
      return [];
    }
  }

  /// Get politicians by party
  Future<List<Celebrity>> getPoliticiansByParty(String party) async {
    try {
      final response = await _supabase.rpc('get_politicians_by_party', params: {
        'party_name': party,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting politicians by party: $e');
      return [];
    }
  }

  /// Get business leaders by industry
  Future<List<Celebrity>> getBusinessLeadersByIndustry(String industry) async {
    try {
      final response = await _supabase.rpc('get_business_leaders_by_industry', params: {
        'industry_name': industry,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting business leaders by industry: $e');
      return [];
    }
  }

  /// Get idol members by group
  Future<List<Celebrity>> getIdolMembersByGroup(String groupName) async {
    try {
      final response = await _supabase.rpc('get_idol_members_by_group', params: {
        'group_name': groupName,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting idol members by group: $e');
      return [];
    }
  }

  /// Get solo singers by genre
  Future<List<Celebrity>> getSoloSingersByGenre(String genre) async {
    try {
      final response = await _supabase.rpc('get_solo_singers_by_genre', params: {
        'genre': genre,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting solo singers by genre: $e');
      return [];
    }
  }

  /// Get actors by specialty
  Future<List<Celebrity>> getActorsBySpecialty(String specialty) async {
    try {
      final response = await _supabase.rpc('get_actors_by_specialty', params: {
        'specialty': specialty,
        'limit_count': 50,
      });

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting actors by specialty: $e');
      return [];
    }
  }

  /// Get athletes by sport
  Future<List<Celebrity>> getAthletesBySport(String sport) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('celebrity_type', 'athlete')
          .limit(50);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting athletes by sport: $e');
      return [];
    }
  }

  // Management methods

  /// Add celebrity
  Future<Celebrity?> addCelebrity(Celebrity celebrity) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .insert(celebrity.toJson())
          .select()
          .single();

      return Celebrity.fromJson(response);
    } catch (e) {
      debugPrint('Error adding celebrity: $e');
      return null;
    }
  }

  /// Update celebrity
  Future<Celebrity?> updateCelebrity(Celebrity celebrity) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .update(celebrity.toJson())
          .eq('id', celebrity.id)
          .select()
          .single();

      return Celebrity.fromJson(response);
    } catch (e) {
      debugPrint('Error updating celebrity: $e');
      return null;
    }
  }

  /// Update external ID
  Future<bool> updateCelebrityExternalId(
    String celebrityId,
    String platform,
    String url,
  ) async {
    try {
      await _supabase.rpc('update_celebrity_external_id', params: {
        'celebrity_id': celebrityId,
        'platform': platform,
        'url': url,
      });

      return true;
    } catch (e) {
      debugPrint('Error updating celebrity external ID: $e');
      return false;
    }
  }

  /// Update profession data
  Future<bool> updateCelebrityProfessionData(
    String celebrityId,
    String dataKey,
    String dataValue,
  ) async {
    try {
      await _supabase.rpc('update_celebrity_profession_data', params: {
        'celebrity_id': celebrityId,
        'data_key': dataKey,
        'data_value': dataValue,
      });

      return true;
    } catch (e) {
      debugPrint('Error updating celebrity profession data: $e');
      return false;
    }
  }

  /// Get celebrity statistics
  Future<List<Map<String, dynamic>>> getCelebrityStatistics() async {
    try {
      final response = await _supabase.rpc('get_celebrity_statistics');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting celebrity statistics: $e');
      return [];
    }
  }

  /// Get celebrity analytics
  Future<List<Map<String, dynamic>>> getCelebrityAnalytics() async {
    try {
      final response = await _supabase
          .from('celebrity_analytics')
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting celebrity analytics: $e');
      return [];
    }
  }

  // Legacy compatibility methods (for gradual migration)

  /// Get celebrities by old category (for compatibility)
  @Deprecated('Use getCelebritiesByType instead')
  Future<List<Map<String, dynamic>>> getCelebritiesByCategory({
    required String category,
    int limit = 10,
  }) async {
    // Map old categories to new types
    CelebrityType? type;
    switch (category.toLowerCase()) {
      case 'politician':
        type = CelebrityType.politician;
        break;
      case 'actor':
        type = CelebrityType.actor;
        break;
      case 'singer':
        // Default to solo_singer, could be improved with better logic
        type = CelebrityType.soloSinger;
        break;
      case 'athlete':
      case 'sports':
        type = CelebrityType.athlete;
        break;
      case 'business_leader':
        type = CelebrityType.business;
        break;
      case 'streamer':
        type = CelebrityType.streamer;
        break;
      case 'pro_gamer':
        type = CelebrityType.proGamer;
        break;
    }

    if (type != null) {
      final celebrities = await getCelebritiesByType(type, limit: limit);
      return celebrities.map((c) => c.toJson()).toList();
    }

    return [];
  }
}