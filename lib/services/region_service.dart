import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/logger.dart';
import '../core/config/environment.dart';
import '../core/services/resilient_service.dart';

class Region {
  final String displayName;
  final String? sido;
  final String? sigungu;
  final bool isFeatured;
  final int usageCount;

  Region({
    required this.displayName,
    this.sido,
    this.sigungu,
    this.isFeatured = false,
    this.usageCount = 0,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      displayName: json['display_name'] as String,
      sido: json['sido'] as String?,
      sigungu: json['sigungu'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
    );
  }

  @override
  String toString() => displayName;
}

/// 강화된 지역 검색 서비스
///
/// KAN-78: 지역 검색 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - 다단계 폴백 메커니즘 강화
/// - Thread-safe 캐시 시스템
/// - API 연결 실패 복구 전략 개선
class RegionService extends ResilientService {
  static final RegionService _instance = RegionService._internal();
  factory RegionService() => _instance;
  RegionService._internal();

  @override
  String get serviceName => 'RegionService';

  final _supabase = Supabase.instance.client;
  final _dio = Dio();

  // Thread-safe cache for region data
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache durations
  static const Duration _popularRegionsCacheDuration = Duration(hours: 6);
  static const Duration _searchCacheDuration = Duration(minutes: 30);

  /// 강화된 인기 지역 목록 가져오기 (ResilientService 패턴 적용)
  Future<List<Region>> getPopularRegions() async {
    const cacheKey = 'popular_regions';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache first
        if (_isCacheValid(cacheKey, _popularRegionsCacheDuration)) {
          return _cache[cacheKey] as List<Region>;
        }

        final response = await _supabase
            .from('popular_regions')
            .select()
            .neq('display_name', '기타 지역')
            .order('is_featured', ascending: false)
            .order('order_priority', ascending: true);

        final regions = (response as List)
            .map((json) => Region.fromJson(json))
            .toList();

        // Update cache
        _updateCache(cacheKey, regions);

        Logger.info('인기 지역 ${regions.length}개 조회 완료');
        return regions;
      },
      () async {
        // Fallback: use local fallback data
        return _getFallbackRegions();
      },
      '인기 지역 목록 조회',
      'Supabase 연결 실패, 기본 지역 목록 제공'
    );
  }

  /// 강화된 전체 지역 검색 (ResilientService 패턴 적용)
  Future<List<Region>> searchRegions(String query) async {
    if (query.trim().length < 2) {
      return [];
    }

    final cacheKey = 'search_$query';

    return await safeExecuteWithRetry(
      [
        // 1차 시도: 캐시된 검색 결과
        () async {
          if (_isCacheValid(cacheKey, _searchCacheDuration)) {
            return _cache[cacheKey] as List<Region>;
          }
          throw Exception('캐시 없음');
        },
        // 2차 시도: 인기 지역에서 검색
        () async {
          final results = await _searchPopularRegions(query);
          if (results.isNotEmpty) {
            _updateCache(cacheKey, results);
            return results;
          }
          throw Exception('인기 지역 검색 결과 없음');
        },
        // 3차 시도: Kakao API 검색
        () async {
          final results = await _searchPublicApi(query);
          if (results.isNotEmpty) {
            _updateCache(cacheKey, results);
            return results;
          }
          throw Exception('Kakao API 검색 결과 없음');
        },
      ],
      _searchLocalFallback(query),
      '지역 검색: $query',
      '모든 검색 실패, 로컬 데이터 검색 수행'
    );
  }

  /// 인기 지역에서 검색 (ResilientService 패턴 적용)
  Future<List<Region>> _searchPopularRegions(String query) async {
    return await safeExecuteWithFallbackFunction(
      () async {
        final response = await _supabase
            .from('popular_regions')
            .select()
            .or('display_name.ilike.%$query%,sido.ilike.%$query%,sigungu.ilike.%$query%')
            .order('is_featured', ascending: false)
            .order('usage_count', ascending: false)
            .limit(20);

        return (response as List)
            .map((json) => Region.fromJson(json))
            .toList();
      },
      () async => <Region>[],
      '인기 지역 검색: $query',
      'Supabase 검색 실패, 빈 결과 반환'
    );
  }

  // Kakao API로 주소 검색
  Future<List<Region>> _searchPublicApi(String query) async {
    try {
      final apiKey = Environment.kakaoRestApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_KAKAO_REST_API_KEY_HERE') {
        Logger.warning('Kakao API 키가 설정되지 않음, 폴백 데이터 사용');
        return [
          Region(displayName: '$query (API 키 없음)', sido: '설정필요', sigungu: query),
        ];
      }

      Logger.info('Kakao API 주소 검색: $query');
      
      // Kakao 주소 검색 API 호출
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/address.json',
        queryParameters: {
          'query': query,
          'page': 1,
          'size': 15,
        },
        options: Options(
          headers: {
            'Authorization': 'KakaoAK $apiKey',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['documents'] != null) {
        final documents = response.data['documents'] as List;
        
        if (documents.isEmpty) {
          // 주소 검색 실패 시 키워드 검색 시도
          return await _searchKakaoKeyword(query);
        }

        final regions = documents.map((doc) {
          final address = doc['address'];
          if (address != null) {
            return Region(
              displayName: address['address_name'] ?? query,
              sido: address['region_1depth_name'],
              sigungu: address['region_2depth_name'],
            );
          }
          
          // road_address 사용
          final roadAddress = doc['road_address'];
          if (roadAddress != null) {
            return Region(
              displayName: roadAddress['address_name'] ?? query,
              sido: roadAddress['region_1depth_name'],
              sigungu: roadAddress['region_2depth_name'],
            );
          }
          
          return Region(displayName: query, sido: '기타', sigungu: null);
        }).toList();

        Logger.info('Kakao API 검색 완료: ${regions.length}개');
        return regions;
      } else {
        Logger.warning('Kakao API 응답 오류 (키워드 검색 시도): ${response.statusCode}');
        return await _searchKakaoKeyword(query);
      }
    } catch (e) {
      Logger.warning('Kakao API 검색 실패 (키워드 검색 시도): $e');
      // 네트워크 오류 시 키워드 검색 시도
      return await _searchKakaoKeyword(query);
    }
  }

  // Kakao 키워드 검색 (주소 검색 실패 시 대체)
  Future<List<Region>> _searchKakaoKeyword(String query) async {
    try {
      final apiKey = Environment.kakaoRestApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_KAKAO_REST_API_KEY_HERE') {
        return [];
      }

      Logger.info('Kakao API 키워드 검색: $query');
      
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {
          'query': query,
          'page': 1,
          'size': 10,
          'category_group_code': 'AD5', // 지역명 카테고리
        },
        options: Options(
          headers: {
            'Authorization': 'KakaoAK $apiKey',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['documents'] != null) {
        final documents = response.data['documents'] as List;
        
        final regions = documents.map((doc) {
          return Region(
            displayName: doc['address_name'] ?? doc['place_name'] ?? query,
            sido: doc['address_name']?.toString().split(' ').first,
            sigungu: doc['address_name']?.toString().split(' ').skip(1).first,
          );
        }).toList();

        Logger.info('Kakao 키워드 검색 완료: ${regions.length}개');
        return regions;
      } else {
        return [];
      }
    } catch (e) {
      Logger.warning('Kakao 키워드 검색 실패 (빈 결과 반환): $e');
      return [];
    }
  }

  /// 강화된 지역 사용 횟수 증가 (ResilientService 패턴 적용)
  Future<void> incrementUsageCount(String displayName) async {
    await safeExecute(
      () async {
        await _supabase
            .from('popular_regions')
            .update({'usage_count': 'usage_count + 1'})
            .eq('display_name', displayName);

        Logger.info('지역 사용 횟수 증가: $displayName');
      },
      '지역 사용 횟수 증가: $displayName',
      '분석 데이터 수집 실패 (무시됨, 기능은 정상 작동)'
    );
  }

  // 폴백 데이터 (네트워크 실패 시)
  List<Region> _getFallbackRegions() {
    return [
      Region(displayName: '서울시 강남구', sido: '서울특별시', sigungu: '강남구', isFeatured: true),
      Region(displayName: '서울시 서초구', sido: '서울특별시', sigungu: '서초구', isFeatured: true),
      Region(displayName: '서울시 송파구', sido: '서울특별시', sigungu: '송파구', isFeatured: true),
      Region(displayName: '서울시 강서구', sido: '서울특별시', sigungu: '강서구', isFeatured: true),
      Region(displayName: '서울시 마포구', sido: '서울특별시', sigungu: '마포구', isFeatured: true),
      Region(displayName: '경기도 성남시', sido: '경기도', sigungu: '성남시', isFeatured: true),
      Region(displayName: '경기도 수원시', sido: '경기도', sigungu: '수원시', isFeatured: true),
      Region(displayName: '경기도 안양시', sido: '경기도', sigungu: '안양시', isFeatured: true),
      Region(displayName: '인천시 연수구', sido: '인천광역시', sigungu: '연수구', isFeatured: true),
      Region(displayName: '부산시 해운대구', sido: '부산광역시', sigungu: '해운대구', isFeatured: true),
      Region(displayName: '기타 지역', sido: null, sigungu: null),
    ];
  }

  // 로컬 폴백 검색 (API 모두 실패 시)
  List<Region> _searchLocalFallback(String query) {
    Logger.info('로컬 폴백 검색: $query');
    
    final regions = <Region>[];
    final queryLower = query.toLowerCase();
    
    // 서울 구 검색
    final seoulDistricts = [
      '강남구', '서초구', '송파구', '강동구', '마포구', '용산구', '종로구', '중구',
      '영등포구', '구로구', '금천구', '관악구', '동작구', '서대문구', '은평구',
      '성북구', '강북구', '도봉구', '노원구', '중랑구', '동대문구', '광진구',
      '성동구', '양천구'
    ];
    
    for (final district in seoulDistricts) {
      if (district.contains(queryLower) || queryLower.contains('서울') || 
          queryLower.contains('강남') && district == '강남구') {
        regions.add(Region(
          displayName: '서울시 $district',
          sido: '서울특별시',
          sigungu: district,
        ));
      }
    }
    
    // 경기도 시 검색
    final gyeonggiCities = [
      '수원시', '성남시', '안양시', '부천시', '광명시', '고양시', '과천시', '구리시',
      '남양주시', '오산시', '시흥시', '군포시', '의왕시', '하남시', '용인시', '파주시',
      '이천시', '안성시', '김포시', '화성시', '광주시', '양주시', '포천시', '여주시'
    ];
    
    for (final city in gyeonggiCities) {
      if (city.contains(queryLower) || queryLower.contains('경기') || 
          (queryLower.contains('수원') && city == '수원시') ||
          (queryLower.contains('성남') && city == '성남시')) {
        regions.add(Region(
          displayName: '경기도 $city',
          sido: '경기도',
          sigungu: city,
        ));
      }
    }
    
    // 부산 구 검색
    if (queryLower.contains('부산') || queryLower.contains('해운대')) {
      final busanDistricts = ['해운대구', '부산진구', '남구', '동래구', '서구', '사상구'];
      for (final district in busanDistricts) {
        regions.add(Region(
          displayName: '부산시 $district',
          sido: '부산광역시',
          sigungu: district,
        ));
      }
    }
    
    // 대구 검색
    if (queryLower.contains('대구')) {
      regions.add(Region(displayName: '대구시 수성구', sido: '대구광역시', sigungu: '수성구'));
      regions.add(Region(displayName: '대구시 달서구', sido: '대구광역시', sigungu: '달서구'));
    }
    
    // 인천 검색
    if (queryLower.contains('인천')) {
      regions.add(Region(displayName: '인천시 연수구', sido: '인천광역시', sigungu: '연수구'));
      regions.add(Region(displayName: '인천시 남동구', sido: '인천광역시', sigungu: '남동구'));
    }
    
    Logger.info('로컬 폴백 검색 결과: ${regions.length}개');
    return regions.take(10).toList(); // 최대 10개 결과
  }

  /// 강화된 캐시 검증 (Thread-safe)
  bool _isCacheValid(String key, Duration maxAge) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < maxAge;
  }

  /// 강화된 캐시 업데이트 (Thread-safe)
  void _updateCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 캐시 초기화 (메모리 정리)
  Future<void> clearCache() async {
    await safeExecute(
      () async {
        _cache.clear();
        _cacheTimestamps.clear();
        Logger.info('Region service cache cleared');
      },
      '지역 서비스 캐시 초기화',
      '캐시 초기화 실패'
    );
  }
}