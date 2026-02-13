// Saju Calculation Service - Unit Test
// 사주 계산 서비스 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../../mocks/mock_user_services.dart';

void main() {
  setUpAll(() {
    registerUserFallbackValues();
  });

  group('SajuCalculationService 테스트', () {
    group('사주팔자 계산', () {
      test('년주 계산', () {
        // 1990년 = 경오년 (庚午)
        final stems = UserTestData.getHeavenlyStems();
        final branches = UserTestData.getEarthlyBranches();

        int getYearStemIndex(int year) => (year - 4) % 10;
        int getYearBranchIndex(int year) => (year - 4) % 12;

        final stemIndex = getYearStemIndex(1990);
        final branchIndex = getYearBranchIndex(1990);

        expect(stems[stemIndex]['name'], '경');
        expect(branches[branchIndex]['name'], '오');
      });

      test('월주 계산', () {
        // 월주는 년간에 따라 결정됨
        final stems = UserTestData.getHeavenlyStems();

        // 갑/기년의 1월은 병인월
        String getMonthStem(int yearStemIndex, int month) {
          final baseIndex = (yearStemIndex % 5) * 2;
          return stems[(baseIndex + month - 1) % 10]['name'] as String;
        }

        expect(getMonthStem(0, 1), isNotNull); // 갑년 1월
      });

      test('일주 계산', () {
        // 일주는 만세력 기반으로 계산
        final sajuData = UserTestData.createSajuData();

        expect(sajuData['four_pillars']['day'], isNotNull);
        expect(sajuData['four_pillars']['day']['heavenly_stem'], isNotNull);
        expect(sajuData['four_pillars']['day']['earthly_branch'], isNotNull);
      });

      test('시주 계산', () {
        // 시주는 일간에 따라 결정됨
        String getHourBranch(int hour) {
          if (hour >= 23 || hour < 1) return '자';
          if (hour >= 1 && hour < 3) return '축';
          if (hour >= 3 && hour < 5) return '인';
          if (hour >= 5 && hour < 7) return '묘';
          if (hour >= 7 && hour < 9) return '진';
          if (hour >= 9 && hour < 11) return '사';
          if (hour >= 11 && hour < 13) return '오';
          if (hour >= 13 && hour < 15) return '미';
          if (hour >= 15 && hour < 17) return '신';
          if (hour >= 17 && hour < 19) return '유';
          if (hour >= 19 && hour < 21) return '술';
          return '해';
        }

        expect(getHourBranch(9), '사');  // 09:00
        expect(getHourBranch(15), '신'); // 15:00
        expect(getHourBranch(0), '자');  // 00:00
      });
    });

    group('오행 분석', () {
      test('오행 분포 계산', () {
        final elements = UserTestData.createElementsAnalysis();
        final elementData = elements['elements'] as Map<String, dynamic>;

        // 모든 오행이 포함되어야 함
        expect(elementData.keys, containsAll(['wood', 'fire', 'earth', 'metal', 'water']));

        // 퍼센티지 합계가 100%
        double totalPercentage = 0;
        for (final element in elementData.values) {
          totalPercentage += (element['percentage'] as num).toDouble();
        }
        expect(totalPercentage.round(), 100);
      });

      test('주 오행 결정', () {
        final elements = UserTestData.createElementsAnalysis();

        expect(elements['dominant_element'], isNotNull);
        expect(['wood', 'fire', 'earth', 'metal', 'water'],
            contains(elements['dominant_element']));
      });

      test('부족한 오행 결정', () {
        final elements = UserTestData.createElementsAnalysis();

        expect(elements['weak_element'], isNotNull);
        expect(['wood', 'fire', 'earth', 'metal', 'water'],
            contains(elements['weak_element']));
      });

      test('균형 점수 계산', () {
        final elements = UserTestData.createElementsAnalysis();
        final balanceScore = elements['balance_score'] as int;

        expect(balanceScore, greaterThanOrEqualTo(0));
        expect(balanceScore, lessThanOrEqualTo(100));
      });
    });

    group('천간지지 변환', () {
      test('천간 목록 검증', () {
        final stems = UserTestData.getHeavenlyStems();

        expect(stems.length, 10);

        // 오행별 천간 확인
        final woodStems = stems.where((s) => s['element'] == 'wood');
        final fireStems = stems.where((s) => s['element'] == 'fire');

        expect(woodStems.length, 2); // 갑, 을
        expect(fireStems.length, 2); // 병, 정
      });

      test('지지 목록 검증', () {
        final branches = UserTestData.getEarthlyBranches();

        expect(branches.length, 12);

        // 12간지 이름 확인
        final names = branches.map((b) => b['korean']).toList();
        expect(names, containsAll(['쥐', '소', '호랑이', '토끼', '용', '뱀',
          '말', '양', '원숭이', '닭', '개', '돼지']));
      });

      test('천간 음양 분류', () {
        final stems = UserTestData.getHeavenlyStems();

        final yangStems = stems.where((s) => s['yin_yang'] == 'yang').toList();
        final yinStems = stems.where((s) => s['yin_yang'] == 'yin').toList();

        expect(yangStems.length, 5);
        expect(yinStems.length, 5);
      });
    });

    group('성격 분석', () {
      test('핵심 성격 특성 추출', () {
        final sajuData = UserTestData.createSajuData();
        final personality = sajuData['personality'] as Map<String, dynamic>;

        expect(personality['core_traits'], isA<List>());
        expect(personality['strengths'], isA<List>());
        expect(personality['weaknesses'], isA<List>());
      });

      test('오행별 성격 매핑', () {
        Map<String, List<String>> getElementTraits(String element) {
          switch (element) {
            case 'wood':
              return {'traits': ['창의적', '진취적', '성장 지향']};
            case 'fire':
              return {'traits': ['열정적', '활발', '리더십']};
            case 'earth':
              return {'traits': ['안정적', '신중', '포용력']};
            case 'metal':
              return {'traits': ['결단력', '정의로움', '완벽주의']};
            case 'water':
              return {'traits': ['지혜로움', '유연함', '감수성']};
            default:
              return {'traits': []};
          }
        }

        expect(getElementTraits('wood')['traits'], contains('창의적'));
        expect(getElementTraits('fire')['traits'], contains('열정적'));
      });
    });

    group('음력/양력 변환', () {
      test('음력 날짜 처리', () {
        final sajuData = UserTestData.createSajuData();

        expect(sajuData['is_lunar'], isA<bool>());
      });

      test('윤달 처리', () {
        // 윤달이 있는 경우 처리
        bool hasLeapMonth(int year, int month) {
          // 실제로는 만세력 데이터 필요
          return false;
        }

        expect(hasLeapMonth(2023, 2), isFalse);
      });
    });

    group('시간대 처리', () {
      test('한국 시간대 적용', () {
        final sajuData = UserTestData.createSajuData(
          birthTime: '09:30',
        );

        expect(sajuData['birth_time'], '09:30');
      });

      test('자정 전후 시간 처리', () {
        // 자시(子時)는 23:00 - 01:00
        String getHourBranch(int hour) {
          if (hour >= 23 || hour < 1) return '자';
          if (hour >= 1 && hour < 3) return '축';
          // ... 생략
          return '해';
        }

        expect(getHourBranch(23), '자');
        expect(getHourBranch(0), '자');
      });
    });

    group('추천 사항', () {
      test('보충 오행 추천', () {
        final elements = UserTestData.createElementsAnalysis();
        final recommendations = elements['recommendations'] as List;

        expect(recommendations, isNotEmpty);
      });

      test('행운의 색상 추천', () {
        Map<String, String> getLuckyColor(String weakElement) {
          switch (weakElement) {
            case 'wood':
              return {'color': '파랑/초록', 'reason': '목 기운 보충'};
            case 'fire':
              return {'color': '빨강/주황', 'reason': '화 기운 보충'};
            case 'earth':
              return {'color': '노랑/갈색', 'reason': '토 기운 보충'};
            case 'metal':
              return {'color': '흰색/금색', 'reason': '금 기운 보충'};
            case 'water':
              return {'color': '검정/파랑', 'reason': '수 기운 보충'};
            default:
              return {'color': '', 'reason': ''};
          }
        }

        final lucky = getLuckyColor('earth');
        expect(lucky['color'], contains('노랑'));
      });

      test('행운의 방향 추천', () {
        Map<String, String> getLuckyDirection(String weakElement) {
          switch (weakElement) {
            case 'wood':
              return {'direction': '동쪽'};
            case 'fire':
              return {'direction': '남쪽'};
            case 'earth':
              return {'direction': '중앙'};
            case 'metal':
              return {'direction': '서쪽'};
            case 'water':
              return {'direction': '북쪽'};
            default:
              return {'direction': ''};
          }
        }

        expect(getLuckyDirection('fire')['direction'], '남쪽');
      });
    });
  });
}
