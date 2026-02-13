import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_simple.dart';

/// 그룹명 한국어 발음 매핑 (영어 → 한국어)
const Map<String, List<String>> _groupNameRomanization = {
  // 4세대 걸그룹
  'IVE': ['아이브'],
  'NewJeans': ['뉴진스'],
  'LE SSERAFIM': ['르세라핌', '르 세라핌'],
  'aespa': ['에스파'],
  'NMIXX': ['엔믹스'],
  'ILLIT': ['아일릿'],
  'KISS OF LIFE': ['키스오브라이프', '키오라'],
  'BABYMONSTER': ['베이비몬스터'],
  'tripleS': ['트리플에스'],
  'FIFTY FIFTY': ['피프티피프티'],

  // 4세대 보이그룹
  'Stray Kids': ['스트레이키즈', '스키즈'],
  'ENHYPEN': ['엔하이픈'],
  'TXT': ['투바투', '투모로우바이투게더', 'TOMORROW X TOGETHER'],
  'ATEEZ': ['에이티즈'],
  'THE BOYZ': ['더보이즈'],
  'TREASURE': ['트레저'],
  'RIIZE': ['라이즈'],
  'ZEROBASEONE': ['제로베이스원', 'ZB1'],
  'BOYNEXTDOOR': ['보이넥스트도어'],
  'TWS': ['투어스'],

  // 3세대 걸그룹
  'BLACKPINK': ['블랙핑크', '블핑'],
  'TWICE': ['트와이스'],
  'Red Velvet': ['레드벨벳', '레벨'],
  'MAMAMOO': ['마마무'],
  'GFRIEND': ['여자친구'],
  '(G)I-DLE': ['아이들', '여자아이들'],
  'ITZY': ['있지'],
  'LOONA': ['이달의소녀', '이달소'],
  'EVERGLOW': ['에버글로우'],
  'OH MY GIRL': ['오마이걸'],
  'fromis_9': ['프로미스나인'],
  'Weeekly': ['위클리'],

  // 3세대 보이그룹
  'BTS': ['방탄소년단', '방탄'],
  'EXO': ['엑소'],
  'SEVENTEEN': ['세븐틴', '세봉이'],
  'NCT': ['엔시티'],
  'NCT 127': ['엔시티 127', '일이칠'],
  'NCT DREAM': ['엔시티 드림'],
  'WayV': ['웨이비'],
  'GOT7': ['갓세븐'],
  'MONSTA X': ['몬스타엑스'],
  'NU\'EST': ['뉴이스트'],
  'BTOB': ['비투비'],
  'WINNER': ['위너'],
  'iKON': ['아이콘'],
  'ASTRO': ['아스트로'],

  // 2세대 및 레전드
  'BIGBANG': ['빅뱅'],
  '2NE1': ['투애니원'],
  'Girls\' Generation': ['소녀시대', '소시'],
  'SNSD': ['소녀시대', '소시'],
  'Wonder Girls': ['원더걸스'],
  'KARA': ['카라'],
  '2PM': ['투피엠'],
  'SHINee': ['샤이니'],
  'f(x)': ['에프엑스'],
  'SISTAR': ['씨스타'],
  'INFINITE': ['인피니트'],
  'BEAST': ['비스트'],
  'B1A4': ['비원에이포'],
  'Block B': ['블락비'],
  'AOA': ['에이오에이'],
  'EXID': ['이엑스아이디'],
  'VIXX': ['빅스'],

  // 솔로 아티스트 관련
  'IU': ['아이유'],
  'PSY': ['싸이'],
  'G-DRAGON': ['지드래곤', '지디'],
  'DEAN': ['딘'],
  'Crush': ['크러쉬'],
  'Zico': ['지코'],
  'Heize': ['헤이즈'],

  // E스포츠 팀
  'T1': ['티원', 'SKT'],
  'Gen.G': ['젠지'],
  'DRX': ['디알엑스'],
  'Dplus KIA': ['디플러스 기아', '담원'],
  'Hanwha Life Esports': ['한화생명', 'HLE'],
  'KT Rolster': ['케이티', 'KT'],
  'Nongshim RedForce': ['농심', 'NS'],
  'Kwangdong Freecs': ['광동', 'KDF'],
  'OK BRION': ['브리온'],
  'FearX': ['피어엑스'],
};

/// 한국어 → 영어 역매핑 생성
Map<String, String> _createReverseRomanization() {
  final Map<String, String> reverse = {};
  _groupNameRomanization.forEach((english, koreanList) {
    for (final korean in koreanList) {
      reverse[korean.toLowerCase()] = english;
    }
    // 영어 자체도 소문자로 매핑
    reverse[english.toLowerCase()] = english;
  });
  return reverse;
}

final Map<String, String> _koreanToEnglish = _createReverseRomanization();

/// Service for handling celebrity data from Supabase database (New Schema)
class CelebrityService {
  static final CelebrityService _instance = CelebrityService._internal();
  factory CelebrityService() => _instance;
  CelebrityService._internal();

  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all celebrities
  Future<List<Celebrity>> getAllCelebrities({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
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

  /// Get celebrities by type
  Future<List<Celebrity>> getCelebritiesByType(
    CelebrityType type, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select()
          .eq('celebrity_type', type.name)
          .order('name')
          .limit(limit);

      return response.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting celebrities by type: $e');
      return [];
    }
  }

  /// Search celebrities
  /// 이름, 그룹명, 한국어 발음으로 검색 가능
  Future<List<Celebrity>> searchCelebrities(
    String query, {
    CelebrityType? type,
    Gender? gender,
    String? nationality,
    int limit = 50,
  }) async {
    try {
      final normalizedQuery = query.trim().toLowerCase();

      // 한국어 발음으로 검색 시 영어 그룹명으로 변환
      final englishGroupName = _koreanToEnglish[normalizedQuery];

      // 검색할 그룹명 목록 생성
      final groupNamesToSearch = <String>{query};
      if (englishGroupName != null) {
        groupNamesToSearch.add(englishGroupName);
      }

      // 영어로 검색 시 한국어 발음도 추가
      for (final entry in _groupNameRomanization.entries) {
        if (entry.key.toLowerCase().contains(normalizedQuery)) {
          groupNamesToSearch.add(entry.key);
        }
      }

      // 복합 검색: name OR group_name OR aliases
      // Supabase에서는 or 필터 사용
      final searchPatterns = groupNamesToSearch.map((g) => '%$g%').toList();

      // 기본 필터 조건 구성
      final List<String> orConditions = [];
      for (final pattern in searchPatterns) {
        orConditions.add('name.ilike.$pattern');
        orConditions.add('stage_name.ilike.$pattern');
        orConditions.add('legal_name.ilike.$pattern');
      }

      var queryBuilder = _supabase
          .from('celebrities')
          .select()
          .or(orConditions.join(','));

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

      final List<Celebrity> results = response.map((json) => Celebrity.fromJson(json)).toList();

      // 그룹명으로 추가 검색 (profession_data에서)
      if (results.length < limit) {
        final groupResults = await _searchByGroupName(
          groupNamesToSearch.toList(),
          type: type,
          gender: gender,
          limit: limit - results.length,
        );

        // 중복 제거하며 병합
        final existingIds = results.map((c) => c.id).toSet();
        for (final celebrity in groupResults) {
          if (!existingIds.contains(celebrity.id)) {
            results.add(celebrity);
            existingIds.add(celebrity.id);
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching celebrities: $e');
      return [];
    }
  }

  /// 그룹명으로 검색 (profession_data->group_name)
  Future<List<Celebrity>> _searchByGroupName(
    List<String> groupNames, {
    CelebrityType? type,
    Gender? gender,
    int limit = 50,
  }) async {
    try {
      final List<Celebrity> allResults = [];

      for (final groupName in groupNames) {
        // RPC 함수 대신 직접 필터링 사용
        var queryBuilder = _supabase
            .from('celebrities')
            .select()
            .ilike('profession_data->>group_name', '%$groupName%');

        if (type != null) {
          queryBuilder = queryBuilder.eq('celebrity_type', type.name);
        }

        if (gender != null) {
          queryBuilder = queryBuilder.eq('gender', gender.name);
        }

        final response = await queryBuilder.limit(limit);

        for (final json in response) {
          allResults.add(Celebrity.fromJson(json));
        }

        if (allResults.length >= limit) break;
      }

      return allResults.take(limit).toList();
    } catch (e) {
      debugPrint('Error searching by group name: $e');
      return [];
    }
  }

  /// Get random celebrities
  Future<List<Celebrity>> getRandomCelebrities({
    int count = 10,
    CelebrityType? type,
  }) async {
    try {
      var queryBuilder = _supabase.from('celebrities').select();

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