import 'dart:math' as math;
import 'moving_fortune_data.dart';

/// 이사운 데이터 생성 로직
class MovingFortuneGenerator {
  /// 이사운 데이터 생성
  static MovingFortuneData generateFortuneData({
    required DateTime birthDate,
    required String purpose,
  }) {
    final random = math.Random();
    final now = DateTime.now();

    // 종합 점수 계산 (생년월일과 목적에 따라)
    int baseScore = 70;
    if (purpose == '결혼해서') baseScore += 10;
    if (purpose == '투자 목적') baseScore += 5;
    baseScore += random.nextInt(20);

    // 방향별 운세 점수
    final directions = {
      '동': 65 + random.nextInt(30),
      '서': 65 + random.nextInt(30),
      '남': 65 + random.nextInt(30),
      '북': 65 + random.nextInt(30),
      '동남': 65 + random.nextInt(30),
      '동북': 65 + random.nextInt(30),
      '서남': 65 + random.nextInt(30),
      '서북': 65 + random.nextInt(30),
    };

    // 최고 방향 찾기
    String bestDirection = directions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // 월별 운세 데이터 (3개월)
    final monthlyScores = List.generate(90, (day) {
      double baseValue = 50 + math.sin(day * 0.1) * 30;
      return baseValue + random.nextInt(20);
    });

    // 길한 날짜들
    final luckyDates = <DateTime>[];
    for (int i = 0; i < 5; i++) {
      luckyDates.add(now.add(Duration(days: 5 + i * 7 + random.nextInt(5))));
    }

    // 예산 브레이크다운
    final budget = {
      '이사업체': 150 + random.nextInt(100),
      '포장재료': 30 + random.nextInt(20),
      '청소비용': 50 + random.nextInt(30),
      '기타비용': 20 + random.nextInt(20),
    };

    return MovingFortuneData(
      overallScore: baseScore.clamp(0, 100),
      bestDirection: bestDirection,
      directionScores: directions,
      monthlyScores: monthlyScores,
      luckyDates: luckyDates,
      budgetBreakdown: budget,
      checklistItems: _generateChecklist(),
      houseTypeScores: _generateHouseTypeScores(purpose, random),
    );
  }

  static List<ChecklistItem> _generateChecklist() {
    return [
      ChecklistItem('D-30', '이사업체 견적 받기', false),
      ChecklistItem('D-30', '새 집 계약 확인', false),
      ChecklistItem('D-21', '불필요한 물건 정리', false),
      ChecklistItem('D-14', '주소 이전 신고', false),
      ChecklistItem('D-14', '공과금 정산 예약', false),
      ChecklistItem('D-7', '포장 시작', false),
      ChecklistItem('D-3', '냉장고 정리', false),
      ChecklistItem('D-1', '귀중품 별도 보관', false),
    ];
  }

  static Map<String, int> _generateHouseTypeScores(String purpose, math.Random random) {
    final scores = <String, int>{};

    // 목적에 따라 점수 조정
    switch (purpose) {
      case '직장 때문에':
        scores['오피스텔'] = 85 + random.nextInt(10);
        scores['원룸/투룸'] = 80 + random.nextInt(10);
        scores['아파트'] = 70 + random.nextInt(10);
        scores['단독주택'] = 60 + random.nextInt(10);
        break;
      case '결혼해서':
        scores['아파트'] = 90 + random.nextInt(10);
        scores['빌라'] = 75 + random.nextInt(10);
        scores['단독주택'] = 70 + random.nextInt(10);
        scores['오피스텔'] = 60 + random.nextInt(10);
        break;
      case '교육 환경':
        scores['아파트'] = 95 + random.nextInt(5);
        scores['단독주택'] = 80 + random.nextInt(10);
        scores['빌라'] = 75 + random.nextInt(10);
        scores['오피스텔'] = 50 + random.nextInt(10);
        break;
      default:
        scores['아파트'] = 75 + random.nextInt(20);
        scores['빌라'] = 75 + random.nextInt(20);
        scores['오피스텔'] = 75 + random.nextInt(20);
        scores['단독주택'] = 75 + random.nextInt(20);
    }

    return scores;
  }
}
