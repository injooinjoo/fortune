import 'package:flutter/foundation.dart';
import 'package:lunar/lunar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_saju.dart';
import '../features/fortune/domain/models/saju/stem_branch_relations.dart';

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

  /// 랜덤 유명인사 추천 (전체 연예인에서 랜덤 선택)
  Future<List<CelebritySaju>> getRandomCelebrities([int limit = 5]) async {
    try {
      // 전체 연예인 중 birth_date가 있는 데이터만 랜덤 선택
      final response = await _supabase
          .from('celebrities')
          .select()
          .not('birth_date', 'is', null)
          .limit(limit * 5);

      debugPrint('🎭 [CELEBRITY] 전체 쿼리 응답: ${(response as List).length}개');

      if ((response as List).isEmpty) {
        return [];
      }

      final celebrities = (response as List)
          .map((data) {
            debugPrint('🎭 [CELEBRITY] 연예인: name=${data['name']}, type=${data['celebrity_type']}, birth_date=${data['birth_date']}');
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

  /// 오늘 일주와 연예인 일주 간의 궁합도 계산
  ///
  /// 계산 로직:
  /// 1. 오늘의 일주(日柱) = 오늘 날짜의 천간+지지
  /// 2. 연예인의 일주 = 생년월일의 천간+지지
  /// 3. 천간 관계 분석 (합: +20, 충: -15)
  /// 4. 지지 관계 분석 (육합: +25, 충: -20, 해/파: -10)
  /// 5. 기본 점수 60점에서 가감
  static int calculateDailyCompatibility(DateTime today, String celebrityBirthDate) {
    try {
      if (celebrityBirthDate.isEmpty) {
        return 50 + (today.day % 30);
      }

      final todayLunar = Lunar.fromDate(today);
      final birthDate = DateTime.parse(celebrityBirthDate);
      final birthLunar = Lunar.fromDate(birthDate);

      // 오늘의 일주 (천간+지지) - 한자
      final todayGan = todayLunar.getDayGan();
      final todayZhi = todayLunar.getDayZhi();

      // 연예인의 일주 - 한자
      final celebGan = birthLunar.getDayGan();
      final celebZhi = birthLunar.getDayZhi();

      // 한자 → 한글 변환
      final todayGanKr = _hanjaToKoreanStem(todayGan);
      final todayZhiKr = _hanjaToKoreanBranch(todayZhi);
      final celebGanKr = _hanjaToKoreanStem(celebGan);
      final celebZhiKr = _hanjaToKoreanBranch(celebZhi);

      int score = 60; // 기본 점수

      // 1. 천간 관계 분석
      final stemRelation = StemBranchRelations.analyzeStemRelation(todayGanKr, celebGanKr);
      if (stemRelation != null) {
        if (stemRelation.type == RelationType.combination) {
          score += 20; // 천간합
        } else if (stemRelation.type == RelationType.clash) {
          score -= 15; // 천간충
        }
      }

      // 2. 지지 관계 분석
      final branchRelations = StemBranchRelations.analyzeBranchRelation(todayZhiKr, celebZhiKr);
      for (final relation in branchRelations) {
        switch (relation.type) {
          case RelationType.combination:
            score += 25; // 지지육합
            break;
          case RelationType.clash:
            score -= 20; // 지지충
            break;
          case RelationType.harm:
          case RelationType.breakRelation:
            score -= 10; // 해/파
            break;
          case RelationType.punishment:
            score -= 5; // 형
            break;
        }
      }

      // 3. 같은 일간(日干)이면 보너스
      if (todayGanKr == celebGanKr) {
        score += 10;
      }

      debugPrint('🎭 [COMPATIBILITY] 오늘=$todayGanKr$todayZhiKr, 연예인=$celebGanKr$celebZhiKr → $score점');

      // 점수 범위 제한 (35% ~ 95%)
      return score.clamp(35, 95);
    } catch (e) {
      debugPrint('🎭 [COMPATIBILITY] 계산 실패: $e');
      return 50 + (celebrityBirthDate.hashCode.abs() % 30);
    }
  }

  /// 한자 천간 → 한글 변환
  static String _hanjaToKoreanStem(String hanja) {
    const map = {
      '甲': '갑', '乙': '을', '丙': '병', '丁': '정', '戊': '무',
      '己': '기', '庚': '경', '辛': '신', '壬': '임', '癸': '계',
    };
    return map[hanja] ?? hanja;
  }

  /// 한자 지지 → 한글 변환
  static String _hanjaToKoreanBranch(String hanja) {
    const map = {
      '子': '자', '丑': '축', '寅': '인', '卯': '묘', '辰': '진', '巳': '사',
      '午': '오', '未': '미', '申': '신', '酉': '유', '戌': '술', '亥': '해',
    };
    return map[hanja] ?? hanja;
  }

  /// F04: 사용자 사주와 유명인 사주의 유사도 계산
  ///
  /// 계산 로직:
  /// 1. 오행 분포 유사도 (최대 50점)
  /// 2. 일주(日柱) 유사도 (최대 30점)
  /// 3. 주요 오행 일치 (최대 20점)
  static int calculateSajuSimilarity({
    required Map<String, int> userElements,
    required String userDayPillar,
    required CelebritySaju celebrity,
  }) {
    int score = 0;

    // 1. 오행 분포 유사도 (최대 50점)
    final userTotal = userElements.values.fold(0, (a, b) => a + b);
    if (userTotal > 0) {
      final celebElements = {
        '목': celebrity.woodCount,
        '화': celebrity.fireCount,
        '토': celebrity.earthCount,
        '금': celebrity.metalCount,
        '수': celebrity.waterCount,
      };
      final celebTotal = celebElements.values.fold(0, (a, b) => a + b);

      if (celebTotal > 0) {
        double similarity = 0;
        for (final element in ['목', '화', '토', '금', '수']) {
          final userRatio = (userElements[element] ?? 0) / userTotal;
          final celebRatio = celebElements[element]! / celebTotal;
          // 비율 차이가 작을수록 유사 (1 - 차이)
          similarity += 1 - (userRatio - celebRatio).abs();
        }
        // similarity ranges 0-5, normalize to 0-50
        score += (similarity * 10).round();
      }
    }

    // 2. 일주(日柱) 유사도 (최대 30점)
    if (userDayPillar.length >= 2 && celebrity.dayPillar.isNotEmpty) {
      final userGan = userDayPillar[0];
      final userZhi = userDayPillar[1];

      // 연예인 일주 파싱 (한글 또는 한자 형태)
      String celebGan = '';
      String celebZhi = '';
      if (celebrity.dayPillar.length >= 2) {
        celebGan = celebrity.dayPillar[0];
        celebZhi = celebrity.dayPillar[1];
      }

      // 천간 일치 여부 (+15점)
      if (userGan == celebGan) {
        score += 15;
      } else {
        // 천간합 관계 (+10점)
        final stemRelation = StemBranchRelations.analyzeStemRelation(userGan, celebGan);
        if (stemRelation?.type == RelationType.combination) {
          score += 10;
        }
      }

      // 지지 일치 여부 (+15점)
      if (userZhi == celebZhi) {
        score += 15;
      } else {
        // 지지육합 관계 (+10점)
        final branchRelations = StemBranchRelations.analyzeBranchRelation(userZhi, celebZhi);
        for (final relation in branchRelations) {
          if (relation.type == RelationType.combination) {
            score += 10;
            break;
          }
        }
      }
    }

    // 3. 주요 오행 일치 (최대 20점)
    final userDominant = _getDominantElement(userElements);
    if (userDominant == celebrity.dominantElement) {
      score += 20;
    }

    debugPrint('🎭 [SIMILARITY] ${celebrity.name}: 오행=$score, 일주분석, 주오행=${celebrity.dominantElement} → 최종 $score점');

    return score.clamp(0, 100);
  }

  /// 주요 오행 찾기
  static String _getDominantElement(Map<String, int> elements) {
    if (elements.isEmpty) return '';
    String dominant = '';
    int maxCount = -1;
    for (final entry in elements.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominant = entry.key;
      }
    }
    return dominant;
  }

  /// F04: 유사 사주 유명인 찾기 (1~3명, 유사도 50점 이상만)
  Future<List<Map<String, dynamic>>> findSimilarCelebrities({
    required Map<String, int> userElements,
    required String userDayPillar,
    int minSimilarity = 50,
    int maxResults = 3,
  }) async {
    try {
      // 충분한 후보를 가져옴
      final response = await _supabase
          .from('celebrities')
          .select()
          .not('birth_date', 'is', null)
          .not('day_pillar', 'is', null)
          .limit(100);

      if ((response as List).isEmpty) {
        return [];
      }

      final celebrities = response
          .map((data) => CelebritySaju.fromJson(data))
          .toList();

      // 유사도 계산
      final results = <Map<String, dynamic>>[];
      for (final celeb in celebrities) {
        final similarity = calculateSajuSimilarity(
          userElements: userElements,
          userDayPillar: userDayPillar,
          celebrity: celeb,
        );

        if (similarity >= minSimilarity) {
          results.add({
            'celebrity': celeb,
            'similarity': similarity,
          });
        }
      }

      // 유사도 높은 순 정렬
      results.sort((a, b) => (b['similarity'] as int).compareTo(a['similarity'] as int));

      debugPrint('🎭 [SIMILARITY] 유사도 $minSimilarity점 이상: ${results.length}명, 반환: ${results.take(maxResults).length}명');

      // 최대 maxResults명 반환 (1~3명)
      return results.take(maxResults).toList();
    } catch (e) {
      debugPrint('🎭 [SIMILARITY] 검색 실패: $e');
      return [];
    }
  }
}