import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/models/ai_recommendation.dart';

/// 로컬 키워드 매칭 맵 (운세 타입 → 검색 키워드들)
/// 여기 있는 키워드는 LLM 없이 즉시 매칭됩니다.
const Map<String, List<String>> _fortuneKeywords = {
  // 시간 기반
  'daily': ['오늘', '일일', '하루', '오늘운세', '일진', '오늘의'],
  'daily-calendar': ['캘린더', '달력', '날짜별', '기간별', '특정날짜', '날짜선택', '언제', '며칠'],
  'new-year': ['새해', '신년', '정월', '설날', '설'],

  // 연애/관계
  'love': ['연애', '사랑', '애인', '썸', '고백', '짝사랑', '연애운'],
  'compatibility': ['궁합', '상성', '어울림', '맞는사람', '케미'],
  'blind-date': ['소개팅', '미팅', '첫만남', '선보기', '맞선'],
  'ex-lover': ['재회', '이별', '헤어짐', '전남친', '전여친', '전애인', '다시'],
  'avoid-people': ['경계', '조심할', '피해야', '나쁜사람', '위험한'],

  // 직업/재능
  'career': ['직업', '취업', '이직', '승진', '퇴사', '직장', '회사', '커리어'],
  'talent': ['적성', '재능', '진로', '잘하는것', '소질', '능력'],

  // 재물
  'wealth': ['재물', '금전', '돈', '재운', '수입', '부자', '재물운'],
  'lucky-items': ['행운', '럭키', '행운아이템', '행운의', '색깔', '숫자'],
  'lotto': ['로또', '복권', '당첨', '번호', '로또번호'],

  // 전통/신비
  'tarot': ['타로', '카드', '타로카드', '카드점'],
  'traditional-saju': ['사주', '팔자', '명리', '음양오행', '사주팔자', '오행', '명식'],
  'face-reading': ['관상', '얼굴', '인상', '이목구비', 'AI관상'],

  // 성격/개성
  'mbti': ['mbti', 'MBTI', '엠비티아이', '성격유형', '유형'],
  'personality-dna': ['성격', 'DNA', '성격분석', '나의성격'],
  'biorhythm': ['바이오리듬', '리듬', '컨디션', '생체리듬'],

  // 건강/스포츠
  'health': ['건강', '건강운', '몸상태', '건강체크'],
  'exercise': ['운동', '피트니스', '헬스', '오늘운동'],
  'match-insight': ['경기', '스포츠', '승부', '축구', '야구', '경기운'],

  // 인터랙티브
  'dream': ['꿈', '꿈해몽', '악몽', '길몽', '꿈풀이', '꿈해석'],
  'wish': ['소원', '빌기', '원하는것', '소망'],
  'fortune-cookie': ['포춘쿠키', '쿠키', '행운메시지', '오늘메시지'],
  'celebrity': ['연예인', '아이돌', '유명인', '스타', '연예인궁합'],

  // 가족/반려동물
  'family': ['가족', '부모', '자녀', '육아', '가족운'],
  'pet-compatibility': ['반려동물', '강아지', '고양이', '펫', '반려견', '반려묘'],
  'naming': ['작명', '이름', '아기이름', '이름짓기'],

  // 스타일/패션
  'ootd-evaluation': ['ootd', 'OOTD', '옷', '패션', '코디', '오늘옷'],

  // 기타
  'talisman': ['부적', '액막이', '행운부적'],
  'exam': ['시험', '수능', '합격', '시험운'],
  'moving': ['이사', '이사운', '이사날짜'],
};

/// 키워드 → 추천 이유 매핑
const Map<String, String> _fortuneReasons = {
  'daily': '오늘의 운세',
  'daily-calendar': '기간별 인사이트',
  'new-year': '새해 인사이트',
  'love': '연애 인사이트',
  'compatibility': '궁합 보기',
  'blind-date': '소개팅 가이드',
  'ex-lover': '재회 인사이트',
  'avoid-people': '경계 대상',
  'career': '커리어 가이드',
  'talent': '적성 분석',
  'wealth': '재물 가이드',
  'lucky-items': '행운 아이템',
  'lotto': '로또 가이드',
  'tarot': '타로 리딩',
  'traditional-saju': '사주 분석',
  'face-reading': 'AI 관상',
  'mbti': 'MBTI 분석',
  'personality-dna': '성격 분석',
  'biorhythm': '바이오리듬',
  'health': '건강 체크',
  'exercise': '운동 추천',
  'match-insight': '경기 가이드',
  'dream': '꿈 해몽',
  'wish': '소원 빌기',
  'fortune-cookie': '포춘쿠키',
  'celebrity': '연예인 궁합',
  'family': '가족 인사이트',
  'pet-compatibility': '펫 궁합',
  'naming': '작명',
  'ootd-evaluation': 'OOTD 평가',
  'talisman': '부적 생성',
  'exam': '시험 가이드',
  'moving': '이사 가이드',
};

/// AI 기반 운세 추천 서비스
class FortuneRecommendService {
  final Map<String, AIRecommendResponse> _cache = {};

  // 디바운싱
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  FortuneRecommendService();

  /// 로컬 키워드 매칭 (LLM 호출 없이 즉시 반환)
  /// 단어별로 쪼개서 매칭하므로 대부분의 쿼리가 여기서 처리됨
  AIRecommendResponse? _tryLocalMatch(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    // 공백, 물음표, 마침표 등으로 분리하여 단어 추출
    final queryWords = normalizedQuery
        .replaceAll(RegExp(r'[?!.,~]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2) // 2글자 이상만
        .toList();

    final matchScores = <String, double>{}; // fortuneType → 최고 점수

    for (final entry in _fortuneKeywords.entries) {
      final fortuneType = entry.key;
      final keywords = entry.value;

      for (final keyword in keywords) {
        final lowerKeyword = keyword.toLowerCase();

        // 1️⃣ 전체 쿼리에 키워드가 포함 (가장 높은 점수)
        if (normalizedQuery.contains(lowerKeyword)) {
          final score = normalizedQuery == lowerKeyword ? 0.98 : 0.90;
          matchScores[fortuneType] = (matchScores[fortuneType] ?? 0) < score
              ? score
              : matchScores[fortuneType]!;
          continue;
        }

        // 2️⃣ 쿼리의 각 단어가 키워드를 포함하거나 키워드가 단어를 포함
        for (final word in queryWords) {
          if (word.contains(lowerKeyword) || lowerKeyword.contains(word)) {
            // "소개팅인데" contains "소개팅" → 0.85
            // "내일" → "내일"이 키워드에 없더라도 비슷한 패턴 매칭
            final score = word == lowerKeyword ? 0.88 : 0.80;
            matchScores[fortuneType] = (matchScores[fortuneType] ?? 0) < score
                ? score
                : matchScores[fortuneType]!;
          }
        }
      }
    }

    if (matchScores.isEmpty) return null;

    // 점수순 정렬 후 상위 3개
    final sortedMatches = matchScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMatches = sortedMatches.take(3).toList();

    final recommendations = topMatches
        .map((m) => AIRecommendation(
              fortuneType: m.key,
              confidence: m.value,
              reason: _fortuneReasons[m.key] ?? '',
            ))
        .toList();

    debugPrint(
      '⚡ [FortuneRecommendService] 로컬 매칭: "$query" → ${recommendations.map((r) => "${r.fortuneType}(${(r.confidence * 100).toInt()}%)").join(", ")}',
    );

    return AIRecommendResponse(
      success: true,
      recommendations: recommendations,
      meta: const AIRecommendMeta(
        provider: 'local',
        model: 'keyword-matcher-v2',
        latencyMs: 0,
      ),
    );
  }

  /// 추천 호출 (로컬 → AI 폴백)
  Future<AIRecommendResponse> getRecommendations(String query) async {
    // 캐시 확인
    if (_cache.containsKey(query)) {
      debugPrint('🎯 [FortuneRecommendService] 캐시 히트: $query');
      return _cache[query]!;
    }

    // 1️⃣ 로컬 키워드 매칭 시도 (무료, 즉시)
    final localResult = _tryLocalMatch(query);
    if (localResult != null) {
      _cache[query] = localResult;
      return localResult;
    }

    // 2️⃣ 로컬 매칭 실패 → 빈 응답 반환 (AI 호출 비활성화)
    // TODO: AI 호출 다시 활성화하려면 아래 주석 해제
    debugPrint('ℹ️ [FortuneRecommendService] 로컬 매칭 실패, AI 호출 비활성화됨: $query');
    return const AIRecommendResponse(
      success: false,
      recommendations: [],
      error: null,
    );

    /*
    // ========== AI 호출 (비활성화됨) ==========
    try {
      debugPrint('🤖 [FortuneRecommendService] AI 추천 요청: $query');

      // Supabase 인증 토큰 가져오기
      final session = Supabase.instance.client.auth.currentSession;
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (session?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${session!.accessToken}';
      }

      final response = await _dio.post(
        EdgeFunctionsEndpoints.fortuneRecommend,
        data: {'query': query, 'limit': 3},
        options: Options(headers: headers),
      );

      final result = AIRecommendResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // 캐시 저장 (성공 시에만)
      if (result.success && result.recommendations.isNotEmpty) {
        _cache[query] = result;
        debugPrint(
          '✅ [FortuneRecommendService] 추천 성공: ${result.recommendations.length}개, '
          '지연: ${result.meta?.latencyMs}ms',
        );
      }

      return result;
    } on DioException catch (e) {
      debugPrint('❌ [FortuneRecommendService] Dio 에러: ${e.message}');
      return AIRecommendResponse(
        success: false,
        recommendations: [],
        error: e.message,
      );
    } catch (e) {
      debugPrint('❌ [FortuneRecommendService] 에러: $e');
      return AIRecommendResponse(
        success: false,
        recommendations: [],
        error: e.toString(),
      );
    }
    */
  }

  /// 디바운싱 래퍼 (타이핑 중 실시간 추천용)
  void getRecommendationsDebounced(
    String query, {
    required void Function(AIRecommendResponse) onSuccess,
    void Function()? onError,
    void Function()? onStart,
  }) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      return;
    }

    _debounceTimer = Timer(_debounceDelay, () async {
      onStart?.call();

      try {
        final response = await getRecommendations(query);
        if (response.success && response.recommendations.isNotEmpty) {
          onSuccess(response);
        } else {
          onError?.call();
        }
      } catch (e) {
        debugPrint('❌ [FortuneRecommendService] 디바운스 에러: $e');
        onError?.call();
      }
    });
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ [FortuneRecommendService] 캐시 초기화');
  }

  /// 디바운스 타이머 취소
  void cancelDebounce() {
    _debounceTimer?.cancel();
  }

  /// 리소스 정리
  void dispose() {
    cancelDebounce();
    clearCache();
  }
}
