import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/fortune.dart' as fortune_entity;
import '../../../core/design_system/design_system.dart';
import '../fortune_story_viewer.dart';

class StoryHelpers {
  /// 문장 분리 헬퍼
  static List<String> splitIntoSentences(String text) {
    // 마침표, 느낌표, 물음표로 문장 분리
    final regex = RegExp(r'[.!?]+');
    return text.split(regex)
        .where((s) => s.trim().isNotEmpty)
        .map((s) => '${s.trim()}.')
        .toList();
  }

  /// 점수별 에너지 설명
  static String getEnergyDescription(int score) {
    if (score >= 90) {
      return '특별한 에너지가\n넘치는 날';
    } else if (score >= 80) {
      return '긍정적인 기운이\n감싸는 날';
    } else if (score >= 70) {
      return '차분하고\n안정적인 하루';
    } else if (score >= 60) {
      return '평온한 기운 속\n작은 행복';
    } else {
      return '천천히 가도\n괜찮은 날';
    }
  }

  /// 운세 텍스트 1 (첫번째 페이지)
  static String getFortuneText1(int score) {
    if (score >= 80) {
      return '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다.\n\n용기를 내어\n도전해보세요.';
    } else if (score >= 60) {
      return '평범해 보이는\n오늘 하루지만\n\n작은 것에서\n큰 의미를\n발견하게 될 거예요.';
    } else {
      return '조금 힘든 하루가\n될 수 있지만\n\n이 또한\n성장의 과정입니다.';
    }
  }

  /// 운세 텍스트 2 (두번째 페이지)
  static String getFortuneText2(int score) {
    if (score >= 80) {
      return '주변 사람들과의\n관계에서\n좋은 소식이\n들려올 것입니다.\n\n마음을 열고\n소통해보세요.';
    } else if (score >= 60) {
      return '일상 속에서\n예상치 못한\n즐거움을\n발견하게 됩니다.\n\n긍정적인 마음을\n유지하세요.';
    } else {
      return '혼자만의 시간이\n필요한 날입니다.\n\n자신을 돌보는\n시간을 가져보세요.';
    }
  }

  /// 운세 텍스트 3 (세번째 페이지)
  static String getFortuneText3(int score) {
    if (score >= 80) {
      return '오늘 내린 결정이\n미래에 큰\n영향을 미칠 것입니다.\n\n자신감을 가지고\n앞으로 나아가세요.';
    } else if (score >= 60) {
      return '차근차근\n계획을 세우고\n실행한다면\n\n원하는 결과를\n얻을 수 있습니다.';
    } else {
      return '잠시 멈춰서\n생각해볼 시간입니다.\n\n급하게 서두르지\n마세요.';
    }
  }

  /// 점수별 조언
  static String getAdviceByScore(int score) {
    if (score >= 90) {
      return '무엇이든 도전하세요.\n큰 성과가 기대됩니다.';
    } else if (score >= 80) {
      return '긍정적인 에너지를\n활용하여\n적극적으로 행동하세요.';
    } else if (score >= 70) {
      return '안정적인 하루입니다.\n차분하게 계획을\n실행하세요.';
    } else if (score >= 60) {
      return '평범한 하루지만\n작은 행복을\n찾아보세요.';
    } else if (score >= 50) {
      return '신중하게 행동하고\n무리하지 마세요.';
    } else {
      return '오늘은 휴식이\n필요한 날입니다.\n자신을 돌보세요.';
    }
  }

  /// 점수별 주의사항
  static String getCautionByScore(int score) {
    if (score >= 90) {
      return '과도한 자신감은\n경계하세요.';
    } else if (score >= 80) {
      return '지나친 낙관은 피하고\n현실적으로 판단하세요.';
    } else if (score >= 70) {
      return '작은 실수가\n큰 문제가 될 수 있으니\n주의하세요.';
    } else if (score >= 60) {
      return '감정 기복에\n휘둘리지 마세요.';
    } else if (score >= 50) {
      return '충동적인 결정은 피하고\n신중히 생각하세요.';
    } else {
      return '무리한 도전보다는\n안정을 추구하세요.';
    }
  }

  /// 색상 이름 변환
  static String getColorName(dynamic color) {
    if (color is String) {
      if (color.startsWith('#')) {
        Map<String, String> colorNames = {
          '#FF6B6B': '붉은색',
          '#4ECDC4': '청록색',
          '#45B7D1': '하늘색',
          '#FFA07A': '살구색',
          '#98D8C8': '민트색',
          '#F7DC6F': '노란색',
          '#BB8FCE': '보라색',
          '#85C1E2': '연한 파란색',
          '#F8B739': '주황색',
          '#52D681': '초록색',
        };
        return colorNames[color.toUpperCase()] ?? color;
      } else {
        // 이미 한글 색상명인 경우
        return color;
      }
    }
    return '특별한 색';
  }

  /// 상세한 10페이지 스토리 생성
  static List<StorySegment> createDetailedStorySegments(
    String userName,
    fortune_entity.Fortune fortune,
  ) {
    // 유효한 운세 데이터가 없으면 빈 세그먼트 반환
    if (fortune.overallScore == null) {
      debugPrint('⚠️ Fortune overallScore is null in createDetailedStorySegments');
      return [
        StorySegment(
          text: '운세를 불러오는 중...',
          fontSize: DSTypography.headingSmall.fontSize!,
          fontWeight: FontWeight.w300,
        ),
      ];
    }

    final score = fortune.overallScore!;
    List<StorySegment> segments = [];

    // 1. 인사 페이지
    segments.add(StorySegment(
      text: userName.isNotEmpty ? '$userName님' : '오늘의 주인공',
      fontSize: DSTypography.displaySmall.fontSize!,
      fontWeight: FontWeight.w200,
    ));

    // 2. 오늘의 총평 (날씨 페이지 제거)
    segments.add(StorySegment(
      text: getEnergyDescription(score),
      fontSize: DSTypography.headingSmall.fontSize!,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));

    // 3-5. 운세 상세 (3페이지에 걸쳐)
    if (fortune.content.isNotEmpty) {
      final sentences = splitIntoSentences(fortune.content);
      final chunkSize = (sentences.length / 3).ceil();

      for (int i = 0; i < 3; i++) {
        final start = i * chunkSize;
        final end = math.min((i + 1) * chunkSize, sentences.length);
        if (start < sentences.length) {
          final chunk = sentences.sublist(start, end).join(' ');
          String subtitle = i == 0 ? '운세 이야기' : i == 1 ? '오전 운세' : '오후 운세';
          segments.add(StorySegment(
            subtitle: subtitle,
            text: chunk,
            fontSize: DSTypography.headingSmall.fontSize!,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    } else {
      // 기본 운세 텍스트
      segments.add(StorySegment(
        text: getFortuneText1(score),
        fontSize: DSTypography.headingSmall.fontSize!,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
        text: getFortuneText2(score),
        fontSize: DSTypography.headingSmall.fontSize!,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
        text: getFortuneText3(score),
        fontSize: DSTypography.headingSmall.fontSize!,
        fontWeight: FontWeight.w300,
      ));
    }

    // 6. 오늘의 주의사항
    String cautionText = fortune.metadata?['caution'] ?? getCautionByScore(score);
    segments.add(StorySegment(
      subtitle: '⚠️ 주의',
      text: cautionText,
      fontSize: DSTypography.headingSmall.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 7. 행운의 요소들
    String luckyText = '';
    if (fortune.luckyItems != null) {
      if (fortune.luckyItems!['color'] != null) {
        luckyText += '오늘의 색: ${getColorName(fortune.luckyItems!['color'])}\n';
      }
      if (fortune.luckyItems!['number'] != null) {
        luckyText += '행운의 숫자: ${fortune.luckyItems!['number']}\n';
      }
      if (fortune.luckyItems!['time'] != null) {
        luckyText += '최고의 시간: ${fortune.luckyItems!['time']}';
      }
    }
    if (luckyText.isEmpty) {
      luckyText = '오늘의 색: 하늘색\n행운의 숫자: 7\n최고의 시간: 오후 2-4시';
    }
    segments.add(StorySegment(
      subtitle: '🍀 행운',
      text: luckyText,
      fontSize: DSTypography.headingSmall.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 8. 오늘의 조언
    String adviceText = fortune.metadata?['advice'] ?? getAdviceByScore(score);
    segments.add(StorySegment(
      subtitle: '💡 조언',
      text: adviceText,
      fontSize: DSTypography.headingSmall.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 9. 마무리 메시지
    segments.add(StorySegment(
      subtitle: '마무리',
      text: '좋은 하루 되세요',
      fontSize: DSTypography.displaySmall.fontSize!,
      fontWeight: FontWeight.w300,
      emoji: '✨',
    ));

    return segments;
  }
}
