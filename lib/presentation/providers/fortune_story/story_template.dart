import 'package:flutter/material.dart';
import '../../../screens/home/fortune_story_viewer.dart';
import '../../../domain/entities/fortune.dart' as fortune_entity;
import '../../../domain/entities/user_profile.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/typography_unified.dart';

/// 기본 스토리 템플릿 생성 (GPT 실패 시)
class StoryTemplate {
  /// 기본 스토리 생성 (GPT 실패 시)
  static List<StorySegment> createDefaultStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) {
    Logger.info('🎭 Creating default story for $userName');
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];

    // 1. 인사
    segments.add(StorySegment(
      text: userName.isNotEmpty ? '$userName님' : '오늘의 주인공',
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontWeight: FontWeight.w300,
    ));

    // 3. 총평
    final summaryData = _getDynamicSummaryText(score);
    segments.add(StorySegment(
      text: summaryData['text'] ?? '특별한 하루입니다',
      fontSize: TypographyUnified.heading1.fontSize!,
      fontWeight: FontWeight.w300,
      emoji: summaryData['emoji'] ?? '✨',
    ));

    // 4-6. 실제 운세 내용 사용 (3페이지)
    List<String> fortuneTexts = _extractFortuneTexts(fortune, score, 3);
    for (String text in fortuneTexts) {
      segments.add(StorySegment(
        text: text,
        fontWeight: FontWeight.w300,
      ));
    }

    // 운세 요약
    if (fortune.summary != null && fortune.summary!.isNotEmpty) {
      List<String> summaryParts = fortune.summary!.split('. ');
      for (String part in summaryParts) {
        if (part.trim().isNotEmpty) {
          segments.add(StorySegment(
            text: part.trim() + (part.endsWith('.') ? '' : '.'),
            fontSize: TypographyUnified.heading1.fontSize!,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    }

    // 7. 주의사항
    segments.add(StorySegment(
      subtitle: '⚠️ 주의',
      text: _extractCautionText(fortune, score),
      fontSize: TypographyUnified.heading3.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 8. 행운 요소
    segments.add(StorySegment(
      subtitle: '🍀 행운',
      text: _extractLuckyItems(fortune).join('\n'),
      fontWeight: FontWeight.w300,
    ));

    // 9. 조언
    segments.add(StorySegment(
      subtitle: '💡 조언',
      text: _extractAdviceText(fortune, score),
      fontWeight: FontWeight.w300,
    ));

    // 10. 마무리
    segments.add(StorySegment(
      subtitle: '마무리',
      text: '좋은 하루 되세요',
      fontWeight: FontWeight.w300,
      emoji: '✨',
    ));

    return segments;
  }

  /// 확장된 기본 스토리 생성 (10페이지 분량)
  static List<StorySegment> createExtendedDefaultStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) {
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];

    // 1. 인사
    segments.add(StorySegment(
      text: userName.isNotEmpty ? '$userName님' : '오늘의 주인공',
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontWeight: FontWeight.w300,
    ));

    // 3. 총평
    String energyText = score >= 80
        ? '특별한 에너지가\n넘치는 날'
        : score >= 60
        ? '차분하고 안정적인\n하루'
        : '천천히 가도\n괜찮은 날';
    segments.add(StorySegment(
      text: energyText,
      fontSize: TypographyUnified.heading1.fontSize!,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));

    // 4-6. 운세 상세 (3페이지)
    List<String> fortuneTexts = _extractFortuneTexts(fortune, score, 3);
    for (String text in fortuneTexts) {
      segments.add(StorySegment(
        text: text,
        fontWeight: FontWeight.w300,
      ));
    }

    // 7. 주의사항
    segments.add(StorySegment(
      text: '잠깐,\n\n${_extractCautionText(fortune, score)}',
      fontSize: TypographyUnified.heading3.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 8. 행운의 요소들
    String luckyText = _extractLuckyItems(fortune).join('\n');
    segments.add(StorySegment(
      text: luckyText.isNotEmpty ? luckyText : '오늘의 색: 하늘색\n행운의 숫자: 7\n최고의 시간: 오후 2-4시',
      fontSize: TypographyUnified.heading1.fontSize!,
      fontWeight: FontWeight.w300,
    ));

    // 9. 조언
    segments.add(StorySegment(
      text: _extractAdviceText(fortune, score),
      fontWeight: FontWeight.w300,
    ));

    // 10. 마무리
    segments.add(StorySegment(
      text: '오늘도\n멋진 하루가\n되길 바라요\n\n✨',
      fontWeight: FontWeight.w300,
    ));

    return segments;
  }

  /// 스토리 세그먼트 확장 (10페이지 미만일 때)
  static List<StorySegment> expandStorySegments(
    List<dynamic> segmentsData,
    String userName,
    fortune_entity.Fortune fortune,
  ) {
    List<StorySegment> segments = segmentsData.map((segment) {
      String textValue = segment['text']?.toString() ?? '';
      double? fontSizeValue;
      if (segment['fontSize'] != null) {
        if (segment['fontSize'] is num) {
          fontSizeValue = (segment['fontSize'] as num).toDouble();
        } else if (segment['fontSize'] is String) {
          fontSizeValue = double.tryParse(segment['fontSize']);
        }
      }

      return StorySegment(
        text: textValue,
        fontSize: fontSizeValue,
        fontWeight: _parseFontWeight(segment['fontWeight']),
        alignment: _parseTextAlign(segment['alignment']),
      );
    }).toList();

    // 부족한 페이지 수만큼 추가
    while (segments.length < 10) {
      if (segments.length == 7) {
        segments.add(StorySegment(
          text: '연애운: ${fortune.scoreBreakdown?['love'] ?? 70}점\n직장운: ${fortune.scoreBreakdown?['career'] ?? 70}점',
          fontWeight: FontWeight.w300,
        ));
      } else if (segments.length == 8) {
        segments.add(StorySegment(
          text: '금전운: ${fortune.scoreBreakdown?['money'] ?? 70}점\n건강운: ${fortune.scoreBreakdown?['health'] ?? 70}점',
          fontWeight: FontWeight.w300,
        ));
      } else if (segments.length == 9) {
        String tipText = _extractTipText(fortune);
        segments.add(StorySegment(
          text: tipText,
          fontWeight: FontWeight.w300,
        ));
      } else {
        String additionalText = _extractAdditionalText(fortune, segments.length);
        segments.add(StorySegment(
          text: additionalText,
          fontWeight: FontWeight.w300,
        ));
      }
    }

    Logger.info('🎆 Default story created with ${segments.length} segments');
    return segments;
  }

  // Private helper methods

  static String _getWeekdayKorean(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  static String _getColorName(String hexColor) {
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
    return colorNames[hexColor.toUpperCase()] ?? '특별한 색';
  }

  /// 운세 내용 추출 (3페이지 분량)
  static List<String> _extractFortuneTexts(fortune_entity.Fortune fortune, int score, int targetCount) {
    List<String> fortuneTexts = [];
    final now = DateTime.now();

    // 1. content를 분할
    if (fortune.content.isNotEmpty) {
      final sentences = fortune.content.split('. ');
      final chunkSize = (sentences.length / targetCount).ceil();

      for (int i = 0; i < targetCount; i++) {
        final start = i * chunkSize;
        final end = (i + 1) * chunkSize;
        if (start < sentences.length) {
          final chunk = sentences
              .sublist(start, end > sentences.length ? sentences.length : end)
              .join('. ');
          fortuneTexts.add(chunk + (chunk.endsWith('.') ? '' : '.'));
        }
      }
    }

    // 2. description 활용
    if (fortune.description != null && fortune.description!.isNotEmpty && fortuneTexts.length < targetCount) {
      final descSentences = fortune.description!.split('. ');
      for (int i = fortuneTexts.length; i < targetCount && i < descSentences.length; i++) {
        fortuneTexts.add(descSentences[i].trim() + (descSentences[i].endsWith('.') ? '' : '.'));
      }
    }

    // 3. recommendations 활용
    if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty && fortuneTexts.length < targetCount) {
      for (int i = fortuneTexts.length; i < targetCount && i < fortune.recommendations!.length; i++) {
        fortuneTexts.add('오늘의 조언:\n${fortune.recommendations![i]}');
      }
    }

    // 4. 점수별 세부 운세 활용
    if (fortune.scoreBreakdown != null && fortuneTexts.length < targetCount) {
      final breakdown = fortune.scoreBreakdown!;
      List<String> breakdownTexts = [];

      if (breakdown['love'] != null) {
        breakdownTexts.add('연애운 ${breakdown['love']}점\n\n${_getFortuneTextByScore(breakdown['love'], '연애')}');
      }
      if (breakdown['career'] != null) {
        breakdownTexts.add('직장운 ${breakdown['career']}점\n\n${_getFortuneTextByScore(breakdown['career'], '직장')}');
      }
      if (breakdown['money'] != null) {
        breakdownTexts.add('금전운 ${breakdown['money']}점\n\n${_getFortuneTextByScore(breakdown['money'], '금전')}');
      }
      if (breakdown['health'] != null) {
        breakdownTexts.add('건강운 ${breakdown['health']}점\n\n${_getFortuneTextByScore(breakdown['health'], '건강')}');
      }

      for (int i = fortuneTexts.length; i < targetCount && i < breakdownTexts.length; i++) {
        fortuneTexts.add(breakdownTexts[i]);
      }
    }

    // 5. 부족한 경우 날짜 기반 동적 텍스트로 보완
    while (fortuneTexts.length < targetCount) {
      final dateSeed = now.year * 10000 + now.month * 100 + now.day;
      final indexSeed = dateSeed + fortuneTexts.length;
      final randomIndex = (indexSeed % 1000) / 1000.0;

      final options = _getDynamicFortuneOptions(score, fortuneTexts.length);
      fortuneTexts.add(options[(randomIndex * options.length).floor()]);
    }

    return fortuneTexts;
  }

  /// 주의사항 추출
  static String _extractCautionText(fortune_entity.Fortune fortune, int score) {
    final now = DateTime.now();
    String cautionText = '';

    // 1. metadata에서 찾기
    if (fortune.metadata?['caution'] != null) {
      cautionText = fortune.metadata!['caution'];
    }
    // 2. description에서 찾기
    else if (fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('주의') || sentence.contains('조심') ||
            sentence.contains('경계') || sentence.contains('피하') || sentence.contains('신중')) {
          cautionText = sentence.trim();
          break;
        }
      }
    }

    // 3. 비어있다면 날짜 기반 동적 생성
    if (cautionText.isEmpty) {
      final cautionSeed = now.year * 100 + now.month * 10 + now.day;
      final cautionIndex = cautionSeed % 8;
      final cautionOptions = _getCautionOptions(score);
      cautionText = cautionOptions[cautionIndex];
    }

    return cautionText;
  }

  /// 행운 아이템 추출
  static List<String> _extractLuckyItems(fortune_entity.Fortune fortune) {
    List<String> luckyTexts = [];

    if (fortune.luckyItems != null) {
      if (fortune.luckyItems!['color'] != null) {
        luckyTexts.add('오늘의 색: ${_getColorName(fortune.luckyItems!['color'])}');
      }
      if (fortune.luckyItems!['number'] != null) {
        luckyTexts.add('행운의 숫자: ${fortune.luckyItems!['number']}');
      }
      if (fortune.luckyItems!['time'] != null) {
        luckyTexts.add('최고의 시간: ${fortune.luckyItems!['time']}');
      }
    }

    if (luckyTexts.isEmpty) {
      luckyTexts = _getDynamicLuckyItems();
    }

    return luckyTexts;
  }

  /// 조언 추출
  static String _extractAdviceText(fortune_entity.Fortune fortune, int score) {
    String adviceText = score >= 80
        ? '무엇이든 도전하세요.\n큰 성과가 기대됩니다.'
        : '신중하게 행동하고\n무리하지 마세요.';

    // 1. metadata에서 조언 찾기
    if (fortune.metadata?['advice'] != null) {
      adviceText = fortune.metadata!['advice'];
    }
    // 2. recommendations에서 조언 찾기
    else if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) {
      String bestRecommendation = fortune.recommendations!.first;
      for (String rec in fortune.recommendations!) {
        if (rec.length > bestRecommendation.length) {
          bestRecommendation = rec;
        }
      }
      adviceText = bestRecommendation;
    }
    // 3. description에서 조언성 내용 찾기
    else if (fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('조언') || sentence.contains('추천') ||
            sentence.contains('하세요') || sentence.contains('바랍니다')) {
          adviceText = sentence.trim();
          break;
        }
      }
    }

    return adviceText;
  }

  /// 팁 텍스트 추출
  static String _extractTipText(fortune_entity.Fortune fortune) {
    if (fortune.metadata?['special_tip'] != null) {
      return '특별한 팁:\n${fortune.metadata!['special_tip']}';
    } else if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) {
      return '특별한 팁:\n${fortune.recommendations!.last}';
    } else if (fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences.reversed) {
        if (sentence.contains('팁') || sentence.contains('도움') || sentence.contains('좋을')) {
          return '특별한 팁:\n${sentence.trim()}';
        }
      }
    }
    return '특별한 팁:\n오늘은 자신을 믿고 앞으로 나아가세요';
  }

  /// 추가 텍스트 추출
  static String _extractAdditionalText(fortune_entity.Fortune fortune, int currentLength) {
    if (fortune.content.isNotEmpty) {
      final sentences = fortune.content.split('.');
      final randomIndex = (currentLength - 3) % sentences.length;
      return '${sentences[randomIndex].trim()}.';
    } else if (fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      final randomIndex = (currentLength - 3) % sentences.length;
      return '${sentences[randomIndex].trim()}.';
    }
    return '긍정적인 마음으로\n하루를 시작하세요';
  }

  /// 분야별 점수에 따른 운세 텍스트 생성
  static String _getFortuneTextByScore(int score, String category) {
    if (category == '연애') {
      if (score >= 80) return '새로운 만남이나 관계 발전의 기회가 있습니다';
      if (score >= 60) return '현재 관계에서 안정감을 느낄 수 있습니다';
      return '서두르지 말고 자신을 돌아보는 시간을 가지세요';
    } else if (category == '직장') {
      if (score >= 80) return '업무에서 좋은 성과를 거둘 수 있습니다';
      if (score >= 60) return '동료들과의 협력이 원활할 것입니다';
      return '신중하게 업무를 처리하고 무리하지 마세요';
    } else if (category == '금전') {
      if (score >= 80) return '투자나 부업에서 좋은 결과가 기대됩니다';
      if (score >= 60) return '계획적인 소비로 안정적인 하루를 보내세요';
      return '불필요한 지출은 피하고 절약하는 것이 좋습니다';
    } else if (category == '건강') {
      if (score >= 80) return '컨디션이 좋고 활기찬 하루가 될 것입니다';
      if (score >= 60) return '적당한 운동으로 건강을 유지하세요';
      return '충분한 휴식을 취하고 몸을 아끼세요';
    }
    return '긍정적인 마음가짐으로 하루를 시작하세요';
  }

  /// 동적 운세 옵션 (점수별, 인덱스별)
  static List<String> _getDynamicFortuneOptions(int score, int index) {
    // Implementation similar to _getShortFortuneText but returns List<String>
    // For brevity, returning simplified version
    if (index == 0) {
      if (score >= 80) {
        return [
          '새로운 기회가\n찾아올 것입니다',
          '특별한 행운이\n기다리고 있어요',
          '중요한 만남이\n예정되어 있습니다',
          '창의적인 아이디어가\n떠오를 시간'
        ];
      } else if (score >= 60) {
        return [
          '작은 것에서\n큰 의미를 발견하세요',
          '차근차근 준비하면\n좋은 결과가 있을 것',
          '평온함 속에서\n새로운 깨달음을',
          '꾸준함이 가장\n큰 힘이 됩니다'
        ];
      } else {
        return [
          '조금 힘든 하루지만\n성장의 과정입니다',
          '천천히 걸어가도\n괜찮아요',
          '휴식을 통해\n새로운 힘을 얻으세요',
          '자신에게 너그러운\n마음을 가져보세요'
        ];
      }
    }
    // Similar logic for index 1, 2, etc.
    return ['긍정적인 마음으로\n하루를 시작하세요'];
  }

  /// 동적 총평 텍스트 생성
  static Map<String, String?> _getDynamicSummaryText(int score) {
    final now = DateTime.now();
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final summarySeed = dateSeed + score + 50;
    final randomIndex = (summarySeed % 1000) / 1000.0;

    final highSummaries = [
      {'text': '특별한 에너지가\n넘치는 날', 'emoji': '✨'},
      {'text': '행운이 함께하는\n황금 같은 하루', 'emoji': '🌟'},
      {'text': '모든 것이 순조로운\n완벽한 타이밍', 'emoji': '🎯'},
      {'text': '창의력이 폭발하는\n영감의 날', 'emoji': '💡'},
    ];

    final midSummaries = [
      {'text': '차분하고 안정적인\n하루', 'emoji': '☁️'},
      {'text': '평온함 속에서\n찾는 소중함', 'emoji': '🍃'},
      {'text': '균형이 잡힌\n조화로운 시간', 'emoji': '⚖️'},
      {'text': '작은 행복들이\n모이는 날', 'emoji': '🌸'},
    ];

    final lowSummaries = [
      {'text': '천천히 가도\n괜찮은 날', 'emoji': '🌙'},
      {'text': '휴식이 필요한\n자신을 돌보는 시간', 'emoji': '🛌'},
      {'text': '충전의 시간으로\n삼는 하루', 'emoji': '🔋'},
      {'text': '조용히 내면을\n들여다보는 날', 'emoji': '🤲'},
    ];

    if (score >= 80) {
      return highSummaries[(randomIndex * highSummaries.length).floor()];
    } else if (score >= 60) {
      return midSummaries[(randomIndex * midSummaries.length).floor()];
    } else {
      return lowSummaries[(randomIndex * lowSummaries.length).floor()];
    }
  }

  /// 동적 행운 아이템 생성
  static List<String> _getDynamicLuckyItems() {
    final now = DateTime.now();
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final luckySeed = dateSeed + 200;
    final randomIndex = (luckySeed % 1000) / 1000.0;

    final colors = ['하늘색', '분홍색', '연두색', '보라색', '노란색', '주황색', '민트색', '라벤더색'];
    final numbers = [3, 7, 9, 11, 13, 17, 21, 23];
    final times = ['오전 8-10시', '오후 2-4시', '저녁 6-8시', '오전 10-12시', '오후 4-6시', '저녁 8-10시', '오전 6-8시', '오후 12-2시'];

    final colorIndex = (randomIndex * colors.length).floor();
    final numberIndex = ((randomIndex * 1000) % numbers.length).floor();
    final timeIndex = ((randomIndex * 10000) % times.length).floor();

    return [
      '색상: ${colors[colorIndex]}',
      '숫자: ${numbers[numberIndex]}',
      '시간: ${times[timeIndex]}'
    ];
  }

  /// 주의사항 옵션 (점수별)
  static List<String> _getCautionOptions(int score) {
    if (score >= 80) {
      return [
        '과도한 자신감은 경계하세요',
        '성급한 결정보다 신중한 판단이 필요합니다',
        '다른 사람의 의견도 경청해보세요',
        '완벽함을 추구하다 기회를 놓치지 마세요',
        '감정적 반응보다는 이성적 접근이 좋겠습니다',
        '과욕을 부리면 오히려 역효과가 날 수 있어요',
        '주변 상황을 꼼꼼히 살펴보고 행동하세요',
        '너무 많은 일을 동시에 처리하려 하지 마세요'
      ];
    } else {
      return [
        '충동적인 결정은 피하세요',
        '소극적인 태도보다는 적극적인 자세가 필요해요',
        '부정적인 생각에 매몰되지 마세요',
        '작은 일에도 꼼꼼한 주의가 필요합니다',
        '타인과의 갈등은 피하는 것이 현명해요',
        '체력 관리에 신경 쓰시기 바랍니다',
        '중요한 약속이나 일정을 놓치지 마세요',
        '무리한 계획보다는 현실적인 목표를 세우세요'
      ];
    }
  }

  static FontWeight? _parseFontWeight(dynamic weight) {
    if (weight == null) return null;
    if (weight is int) {
      switch (weight) {
        case 100: return FontWeight.w100;
        case 200: return FontWeight.w200;
        case 300: return FontWeight.w300;
        case 400: return FontWeight.w400;
        case 500: return FontWeight.w500;
        case 600: return FontWeight.w600;
        case 700: return FontWeight.w700;
        case 800: return FontWeight.w800;
        case 900: return FontWeight.w900;
        default: return FontWeight.w400;
      }
    }
    if (weight is String) {
      final numWeight = int.tryParse(weight);
      if (numWeight != null) return _parseFontWeight(numWeight);
      switch (weight) {
        case 'w100': return FontWeight.w100;
        case 'w200': return FontWeight.w200;
        case 'w300': return FontWeight.w300;
        case 'w400': return FontWeight.w400;
        case 'w500': return FontWeight.w500;
        case 'w600': return FontWeight.w600;
        case 'w700': return FontWeight.w700;
        case 'w800': return FontWeight.w800;
        case 'w900': return FontWeight.w900;
        default: return FontWeight.w400;
      }
    }
    return null;
  }

  static TextAlign? _parseTextAlign(dynamic align) {
    if (align == null) return null;
    if (align is String) {
      switch (align) {
        case 'left': return TextAlign.left;
        case 'right': return TextAlign.right;
        case 'center': return TextAlign.center;
        case 'justify': return TextAlign.justify;
        default: return TextAlign.center;
      }
    }
    return null;
  }
}
