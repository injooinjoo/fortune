import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:lunar/lunar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_saju.dart';
import '../domain/entities/fortune.dart';
import '../features/fortune/domain/models/saju/stem_branch_relations.dart';

/// 유명인의 오늘 운세 데이터 (로컬 계산용)
class CelebrityDailyFortune {
  /// 종합 점수 (35-95)
  final int overallScore;

  /// 카테고리별 점수 {love, money, health, work, study}
  final Map<String, int> categoryScores;

  /// 행운 요소 {color, number, direction, time}
  final Map<String, String> luckyItems;

  const CelebrityDailyFortune({
    required this.overallScore,
    required this.categoryScores,
    required this.luckyItems,
  });
}

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
  /// 날짜 기반 시드를 사용하여 매일 다른 결과 제공
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

      // 날짜 기반 시드로 매일 다른 순서 (같은 날은 같은 순서)
      final today = DateTime.now();
      final seed = today.year * 10000 + today.month * 100 + today.day;
      celebrities.shuffle(Random(seed));

      debugPrint('🎭 [CELEBRITY] 날짜 시드: $seed, 결과: ${celebrities.take(limit).map((c) => c.name).join(', ')}');

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
  ///
  /// birth_date를 기반으로 사주를 동적 계산하여 유사도 비교
  Future<List<Map<String, dynamic>>> findSimilarCelebrities({
    required Map<String, int> userElements,
    required String userDayPillar,
    int minSimilarity = 50,
    int maxResults = 3,
  }) async {
    try {
      // birth_date가 있는 연예인만 가져옴 (충분한 후보)
      final response = await _supabase
          .from('celebrities')
          .select()
          .not('birth_date', 'is', null)
          .limit(100);

      if ((response as List).isEmpty) {
        return [];
      }

      // 유사도 계산
      final results = <Map<String, dynamic>>[];
      for (final data in response) {
        final celeb = CelebritySaju.fromJson(data);

        // birth_date 기반으로 사주 동적 계산
        final calculatedSaju = _calculateCelebritySaju(celeb.birthDate, celeb.birthTime);
        if (calculatedSaju == null) continue;

        final similarity = _calculateDynamicSimilarity(
          userElements: userElements,
          userDayPillar: userDayPillar,
          celebDayPillar: calculatedSaju['dayPillar'] as String,
          celebElements: calculatedSaju['elements'] as Map<String, int>,
        );

        if (similarity >= minSimilarity) {
          results.add({
            'celebrity': celeb,
            'similarity': similarity,
            'calculatedDayPillar': calculatedSaju['dayPillar'],
          });
        }
      }

      // 유사도 높은 순 정렬
      results.sort((a, b) => (b['similarity'] as int).compareTo(a['similarity'] as int));

      // 상위 후보들 중에서 날짜 기반으로 선택 (매일 다른 조합)
      final topCandidates = results.take(maxResults * 3).toList(); // 상위 9명
      if (topCandidates.length > maxResults) {
        final today = DateTime.now();
        final seed = today.year * 10000 + today.month * 100 + today.day;
        topCandidates.shuffle(Random(seed));
      }

      final finalResults = topCandidates.take(maxResults).toList();
      debugPrint('🎭 [SIMILARITY] 유사도 $minSimilarity점 이상: ${results.length}명, 반환: ${finalResults.map((r) => (r['celebrity'] as CelebritySaju).name).join(', ')}');

      // 최대 maxResults명 반환 (1~3명)
      return finalResults;
    } catch (e) {
      debugPrint('🎭 [SIMILARITY] 검색 실패: $e');
      return [];
    }
  }

  /// birth_date 기반으로 유명인 사주 계산
  Map<String, dynamic>? _calculateCelebritySaju(String birthDateStr, String birthTimeStr) {
    try {
      if (birthDateStr.isEmpty) return null;

      final birthDate = DateTime.parse(birthDateStr);
      final birthLunar = Lunar.fromDate(birthDate);

      // 일주 계산 (한글 변환)
      final dayGan = _hanjaToKoreanStem(birthLunar.getDayGan());
      final dayZhi = _hanjaToKoreanBranch(birthLunar.getDayZhi());
      final dayPillar = '$dayGan$dayZhi';

      // 년주, 월주 계산
      final yearGan = _hanjaToKoreanStem(birthLunar.getYearGan());
      final yearZhi = _hanjaToKoreanBranch(birthLunar.getYearZhi());
      final monthGan = _hanjaToKoreanStem(birthLunar.getMonthGan());
      final monthZhi = _hanjaToKoreanBranch(birthLunar.getMonthZhi());

      // 오행 계산 (천간/지지에서 추출)
      final elements = _calculateElements([
        yearGan, yearZhi, monthGan, monthZhi, dayGan, dayZhi
      ]);

      return {
        'dayPillar': dayPillar,
        'elements': elements,
      };
    } catch (e) {
      debugPrint('🎭 [SAJU] 사주 계산 실패: $e');
      return null;
    }
  }

  /// 천간/지지에서 오행 카운트 계산
  Map<String, int> _calculateElements(List<String> stems) {
    final elements = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};

    // 천간 → 오행
    const stemElements = {
      '갑': '목', '을': '목',
      '병': '화', '정': '화',
      '무': '토', '기': '토',
      '경': '금', '신': '금',
      '임': '수', '계': '수',
    };

    // 지지 → 오행
    const branchElements = {
      '인': '목', '묘': '목',
      '사': '화', '오': '화',
      '진': '토', '술': '토', '축': '토', '미': '토',
      '신': '금', '유': '금',
      '해': '수', '자': '수',
    };

    for (final stem in stems) {
      final element = stemElements[stem] ?? branchElements[stem];
      if (element != null) {
        elements[element] = (elements[element] ?? 0) + 1;
      }
    }

    return elements;
  }

  /// 동적 계산된 사주로 유사도 계산
  int _calculateDynamicSimilarity({
    required Map<String, int> userElements,
    required String userDayPillar,
    required String celebDayPillar,
    required Map<String, int> celebElements,
  }) {
    int score = 0;

    // 1. 오행 분포 유사도 (최대 50점)
    final userTotal = userElements.values.fold(0, (a, b) => a + b);
    final celebTotal = celebElements.values.fold(0, (a, b) => a + b);

    if (userTotal > 0 && celebTotal > 0) {
      double similarity = 0;
      for (final element in ['목', '화', '토', '금', '수']) {
        final userRatio = (userElements[element] ?? 0) / userTotal;
        final celebRatio = (celebElements[element] ?? 0) / celebTotal;
        similarity += 1 - (userRatio - celebRatio).abs();
      }
      score += (similarity * 10).round();
    }

    // 2. 일주(日柱) 유사도 (최대 30점)
    if (userDayPillar.length >= 2 && celebDayPillar.length >= 2) {
      final userGan = userDayPillar[0];
      final userZhi = userDayPillar[1];
      final celebGan = celebDayPillar[0];
      final celebZhi = celebDayPillar[1];

      // 천간 일치 (+15점) 또는 합 (+10점)
      if (userGan == celebGan) {
        score += 15;
      } else {
        final stemRelation = StemBranchRelations.analyzeStemRelation(userGan, celebGan);
        if (stemRelation?.type == RelationType.combination) {
          score += 10;
        }
      }

      // 지지 일치 (+15점) 또는 합 (+10점)
      if (userZhi == celebZhi) {
        score += 15;
      } else {
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
    final celebDominant = _getDominantElement(celebElements);
    if (userDominant.isNotEmpty && userDominant == celebDominant) {
      score += 20;
    }

    return score.clamp(0, 100);
  }

  // ============================================================
  // 오늘 운세 비슷한 유명인 기능 (매일 다른 결과)
  // ============================================================

  /// 유명인의 오늘 운세 계산 (로컬, API 비용 0)
  ///
  /// 오늘 날짜의 천간지지와 유명인 사주의 관계를 분석하여
  /// 종합 점수, 카테고리별 점수, 행운 요소를 계산
  static CelebrityDailyFortune calculateCelebrityDailyFortune(
    DateTime today,
    CelebritySaju celebrity,
  ) {
    // 1. 기본 일진 점수 (기존 로직 활용)
    final baseScore = calculateDailyCompatibility(today, celebrity.birthDate);

    // 2. 오늘의 일주 정보
    final todayLunar = Lunar.fromDate(today);
    final todayDayGan = _hanjaToKoreanStem(todayLunar.getDayGan());
    final todayDayZhi = _hanjaToKoreanBranch(todayLunar.getDayZhi());
    final todayElement = _getElementFromStem(todayDayGan);

    // 3. 카테고리별 점수 계산
    final categoryScores = _calculateCategoryScores(
      baseScore: baseScore,
      todayElement: todayElement,
      celebrity: celebrity,
    );

    // 4. 행운 요소 계산
    final luckyItems = _calculateLuckyItems(
      todayDayGan: todayDayGan,
      todayDayZhi: todayDayZhi,
      celebrity: celebrity,
    );

    return CelebrityDailyFortune(
      overallScore: baseScore,
      categoryScores: categoryScores,
      luckyItems: luckyItems,
    );
  }

  /// 천간 → 오행 변환
  static String _getElementFromStem(String stem) {
    const stemToElement = {
      '갑': '목', '을': '목',
      '병': '화', '정': '화',
      '무': '토', '기': '토',
      '경': '금', '신': '금',
      '임': '수', '계': '수',
    };
    return stemToElement[stem] ?? '토';
  }

  /// 카테고리별 점수 계산 (오행 기반)
  static Map<String, int> _calculateCategoryScores({
    required int baseScore,
    required String todayElement,
    required CelebritySaju celebrity,
  }) {
    // 카테고리 ↔ 오행 매핑
    // 연애운 ↔ 화(火), 재물운 ↔ 금(金), 건강운 ↔ 수(水)
    // 사업운 ↔ 목(木), 학업운 ↔ 토(土)
    final celebElements = {
      '목': celebrity.woodCount,
      '화': celebrity.fireCount,
      '토': celebrity.earthCount,
      '금': celebrity.metalCount,
      '수': celebrity.waterCount,
    };

    final total = celebElements.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return {
        'love': baseScore,
        'money': baseScore,
        'health': baseScore,
        'work': baseScore,
        'study': baseScore,
      };
    }

    // 오행 상생/상극 관계로 점수 조정
    int adjustScore(String categoryElement) {
      final elementCount = celebElements[categoryElement] ?? 0;
      final ratio = elementCount / total;

      // 오행 비율에 따른 보정 (-10 ~ +10)
      int adjustment = ((ratio - 0.2) * 50).round().clamp(-10, 10);

      // 오늘 오행과의 관계 추가 보정
      if (_isGenerating(todayElement, categoryElement)) {
        adjustment += 5; // 상생
      } else if (_isOvercoming(todayElement, categoryElement)) {
        adjustment -= 5; // 상극
      }

      return (baseScore + adjustment).clamp(35, 95);
    }

    return {
      'love': adjustScore('화'),
      'money': adjustScore('금'),
      'health': adjustScore('수'),
      'work': adjustScore('목'),
      'study': adjustScore('토'),
    };
  }

  /// 상생 관계 확인 (목→화→토→금→수→목)
  static bool _isGenerating(String from, String to) {
    const generating = {
      '목': '화', '화': '토', '토': '금', '금': '수', '수': '목',
    };
    return generating[from] == to;
  }

  /// 상극 관계 확인 (목→토→수→화→금→목)
  static bool _isOvercoming(String from, String to) {
    const overcoming = {
      '목': '토', '토': '수', '수': '화', '화': '금', '금': '목',
    };
    return overcoming[from] == to;
  }

  /// 행운 요소 계산
  static Map<String, String> _calculateLuckyItems({
    required String todayDayGan,
    required String todayDayZhi,
    required CelebritySaju celebrity,
  }) {
    // 1. 행운의 색상 (오늘 일간 오행 기반)
    final todayElement = _getElementFromStem(todayDayGan);
    final luckyColor = _getColorFromElement(todayElement);

    // 2. 행운의 숫자 (일주 조합)
    final luckyNumber = _calculateLuckyNumber(todayDayZhi, celebrity);

    // 3. 행운의 방향 (지지 방위)
    final luckyDirection = _getDirectionFromBranch(todayDayZhi);

    // 4. 행운의 시간대 (일간 음양)
    final luckyTime = _getLuckyTime(todayDayGan);

    return {
      'color': luckyColor,
      'number': luckyNumber,
      'direction': luckyDirection,
      'time': luckyTime,
    };
  }

  /// 오행 → 색상 변환
  static String _getColorFromElement(String element) {
    const elementColors = {
      '목': '청색',
      '화': '적색',
      '토': '황색',
      '금': '백색',
      '수': '흑색',
    };
    return elementColors[element] ?? '황색';
  }

  /// 행운의 숫자 계산
  static String _calculateLuckyNumber(String todayZhi, CelebritySaju celebrity) {
    // 지지 → 숫자 매핑
    const zhiNumbers = {
      '자': 1, '축': 2, '인': 3, '묘': 4, '진': 5, '사': 6,
      '오': 7, '미': 8, '신': 9, '유': 10, '술': 11, '해': 12,
    };

    final todayNum = zhiNumbers[todayZhi] ?? 1;
    final celebNum = celebrity.birthDate.isNotEmpty
        ? DateTime.parse(celebrity.birthDate).day % 10
        : 5;

    // 두 숫자 조합
    final lucky1 = (todayNum + celebNum) % 10;
    final lucky2 = (todayNum * 2 + 1) % 10;

    return '$lucky1, $lucky2';
  }

  /// 지지 → 방향 변환
  static String _getDirectionFromBranch(String branch) {
    const branchDirections = {
      '자': '북', '축': '북동', '인': '동북', '묘': '동',
      '진': '동남', '사': '남동', '오': '남', '미': '남서',
      '신': '서남', '유': '서', '술': '서북', '해': '북서',
    };
    return branchDirections[branch] ?? '동';
  }

  /// 일간 음양 → 시간대
  static String _getLuckyTime(String dayGan) {
    // 양간(갑, 병, 무, 경, 임) → 오전
    // 음간(을, 정, 기, 신, 계) → 오후
    const yangGan = {'갑', '병', '무', '경', '임'};
    return yangGan.contains(dayGan) ? '오전' : '오후';
  }

  /// 사용자 오늘 운세와 유명인 오늘 운세의 유사도 계산 (100점 만점)
  ///
  /// - 일진 점수 유사: 최대 40점
  /// - 카테고리 유사: 최대 35점
  /// - 행운 요소 유사: 최대 25점
  static int calculateDailyFortuneSimilarity({
    required Fortune userFortune,
    required CelebrityDailyFortune celebFortune,
  }) {
    int similarity = 0;

    // 1. 일진 점수 유사도 (40점)
    // 점수 차이가 작을수록 유사
    final userScore = userFortune.overallScore ?? 50; // 기본값 50
    final celebScore = celebFortune.overallScore;
    final scoreDiff = (userScore - celebScore).abs();
    similarity += max(0, 40 - (scoreDiff * 0.8).round());

    // 2. 카테고리 유사도 (35점)
    // 사용자 hexagonScores와 유명인 categoryScores 비교
    final userCategories = userFortune.hexagonScores ?? {};
    final celebCategories = celebFortune.categoryScores;

    if (userCategories.isNotEmpty && celebCategories.isNotEmpty) {
      int categoryScore = 0;
      int comparisons = 0;

      // 매핑: 사용자 카테고리 → 유명인 카테고리
      final categoryMap = {
        '연애운': 'love',
        '재물운': 'money',
        '건강운': 'health',
        '사업운': 'work',
        '학업운': 'study',
      };

      for (final entry in categoryMap.entries) {
        final userCatScore = userCategories[entry.key];
        final celebCatScore = celebCategories[entry.value];

        if (userCatScore != null && celebCatScore != null) {
          final diff = (userCatScore - celebCatScore).abs();
          // 차이가 10 이하면 7점, 20 이하면 4점, 그 외 0점
          if (diff <= 10) {
            categoryScore += 7;
          } else if (diff <= 20) {
            categoryScore += 4;
          }
          comparisons++;
        }
      }

      // 비교한 카테고리 수에 따라 정규화
      if (comparisons > 0) {
        similarity += (categoryScore * 5 ~/ comparisons).clamp(0, 35);
      }
    }

    // 3. 행운 요소 유사도 (25점)
    // Fortune의 getter 사용: luckyColor, luckyNumber, luckyDirection, bestTime
    final celebLucky = celebFortune.luckyItems;

    // 색상 일치: +8점
    if (_isColorMatch(userFortune.luckyColor, celebLucky['color'])) {
      similarity += 8;
    }

    // 숫자 일치: +7점 (부분 일치 포함)
    final userNumber = userFortune.luckyNumber?.toString();
    if (_isNumberMatch(userNumber, celebLucky['number'])) {
      similarity += 7;
    }

    // 방향 일치: +5점
    if (_isDirectionMatch(userFortune.luckyDirection, celebLucky['direction'])) {
      similarity += 5;
    }

    // 시간대 일치: +5점
    final userTime = userFortune.bestTime;
    final celebTime = celebLucky['time'] as String?;
    if (userTime != null && celebTime != null &&
        (userTime.contains(celebTime) || celebTime.contains(userTime))) {
      similarity += 5;
    }

    return similarity.clamp(0, 100);
  }

  /// 색상 유사 여부 (오행 기반)
  static bool _isColorMatch(String? userColor, String? celebColor) {
    if (userColor == null || celebColor == null) return false;

    // 같은 색상이거나 같은 오행 계열
    if (userColor.contains(celebColor) || celebColor.contains(userColor)) {
      return true;
    }

    // 오행 색상 그룹
    const colorGroups = {
      '목': ['청', '녹', '파랑', '초록', '청색'],
      '화': ['적', '빨강', '주황', '적색', '붉'],
      '토': ['황', '노랑', '갈색', '황색', '베이지'],
      '금': ['백', '흰', '은', '백색', '화이트'],
      '수': ['흑', '검', '남색', '흑색', '블랙'],
    };

    for (final group in colorGroups.values) {
      final userMatch = group.any((c) => userColor.contains(c));
      final celebMatch = group.any((c) => celebColor.contains(c));
      if (userMatch && celebMatch) return true;
    }

    return false;
  }

  /// 숫자 유사 여부
  static bool _isNumberMatch(String? userNum, String? celebNum) {
    if (userNum == null || celebNum == null) return false;

    // 숫자 추출
    final userNumbers = RegExp(r'\d+').allMatches(userNum).map((m) => m.group(0)).toSet();
    final celebNumbers = RegExp(r'\d+').allMatches(celebNum).map((m) => m.group(0)).toSet();

    // 하나라도 일치하면 true
    return userNumbers.intersection(celebNumbers).isNotEmpty;
  }

  /// 방향 유사 여부
  static bool _isDirectionMatch(String? userDir, String? celebDir) {
    if (userDir == null || celebDir == null) return false;

    // 동일 방향
    if (userDir.contains(celebDir) || celebDir.contains(userDir)) {
      return true;
    }

    // 인접 방향도 부분 일치로 처리
    const adjacentDirs = {
      '동': ['동북', '동남', '북동', '남동'],
      '서': ['서북', '서남', '북서', '남서'],
      '남': ['동남', '서남', '남동', '남서'],
      '북': ['동북', '서북', '북동', '북서'],
    };

    for (final entry in adjacentDirs.entries) {
      if (userDir.contains(entry.key) && entry.value.any((d) => celebDir.contains(d))) {
        return true;
      }
      if (celebDir.contains(entry.key) && entry.value.any((d) => userDir.contains(d))) {
        return true;
      }
    }

    return false;
  }

  /// 오늘 운세가 비슷한 유명인 찾기
  ///
  /// 사용자의 오늘 운세를 기반으로 유사한 운세를 가진 유명인 1~3명 반환
  /// - 유사도 50점 이상만 표시
  /// - 매일 다른 결과 (오늘 일진 기반)
  Future<List<Map<String, dynamic>>> findDailySimilarCelebrities({
    required Fortune userFortune,
    int minSimilarity = 50,
    int maxResults = 3,
  }) async {
    try {
      final today = DateTime.now();

      // 1. birth_date가 있는 유명인 조회
      final response = await _supabase
          .from('celebrities')
          .select()
          .not('birth_date', 'is', null)
          .limit(150); // 충분한 후보

      if ((response as List).isEmpty) {
        return [];
      }

      // 2. 각 유명인의 오늘 운세 계산 및 유사도 측정
      final results = <Map<String, dynamic>>[];

      for (final data in response) {
        final celebrity = CelebritySaju.fromJson(data);

        // 유명인 오늘 운세 계산 (로컬)
        final celebFortune = calculateCelebrityDailyFortune(today, celebrity);

        // 유사도 계산
        final similarity = calculateDailyFortuneSimilarity(
          userFortune: userFortune,
          celebFortune: celebFortune,
        );

        if (similarity >= minSimilarity) {
          results.add({
            'celebrity': celebrity,
            'similarity': similarity,
            'dailyFortune': celebFortune,
          });
        }
      }

      // 3. 유사도 높은 순 정렬
      results.sort((a, b) => (b['similarity'] as int).compareTo(a['similarity'] as int));

      // 4. 상위 후보 중에서 날짜 기반으로 다양하게 선택 (매일 다른 조합)
      final topCandidates = results.take(maxResults * 3).toList();
      if (topCandidates.length > maxResults) {
        final seed = today.year * 10000 + today.month * 100 + today.day;
        topCandidates.shuffle(Random(seed));
      }

      final finalResults = topCandidates.take(maxResults).toList();

      debugPrint('🎭 [DAILY_SIMILAR] 유사도 $minSimilarity점 이상: ${results.length}명, '
          '반환: ${finalResults.map((r) => '${(r['celebrity'] as CelebritySaju).name}(${r['similarity']}점)').join(', ')}');

      return finalResults;
    } catch (e) {
      debugPrint('🎭 [DAILY_SIMILAR] 검색 실패: $e');
      return [];
    }
  }
}