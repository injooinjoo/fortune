import 'dart:math';
import '../../domain/models/health_fortune_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';

class HealthFortuneService {
  static final HealthFortuneService _instance =
      HealthFortuneService._internal();
  factory HealthFortuneService() => _instance;
  HealthFortuneService._internal();

  final Random _random = Random();
  FortuneApiService? _apiService;

  void setApiService(FortuneApiService apiService) {
    _apiService = apiService;
  }

  /// 건강운세 생성
  Future<HealthFortuneResult> generateHealthFortune(
    HealthFortuneInput input,
  ) async {
    try {
      Logger.info('Generating health fortune for user: ${input.userId}');

      // AI API 호출로 실제 운세 생성
      if (_apiService != null) {
        final fortune = await _apiService!.getFortune(
          userId: input.userId,
          fortuneType: 'health',
          params: {
            'currentCondition': input.currentCondition?.name,
            'concernedBodyParts':
                input.concernedBodyParts?.map((p) => p.name).toList() ?? [],
          },
        );

        return _convertFortuneToHealthResult(fortune, input);
      }

      // Fallback: 기존 하드코딩 로직 (API 서비스가 없을 때만)
      await Future.delayed(const Duration(seconds: 2));

      // 기본 점수 계산 (현재 컨디션 기반)
      final int baseScore = _calculateBaseScore(input.currentCondition);

      // 신체 부위별 건강 상태 생성
      final bodyPartHealthList = _generateBodyPartHealthList(
        input.concernedBodyParts ?? [],
        baseScore,
      );

      // 전체 점수 재조정
      final overallScore =
          _calculateOverallScore(baseScore, bodyPartHealthList);

      // 메인 메시지 생성
      final mainMessage =
          _generateMainMessage(overallScore, input.concernedBodyParts);

      // 건강 관리 추천사항 생성
      final recommendations =
          _generateRecommendations(overallScore, input.concernedBodyParts);

      // 피해야 할 것들
      final avoidanceList = _generateAvoidanceList(overallScore);

      // 시간대별 컨디션
      final timeline = _generateHealthTimeline(overallScore);

      // 내일 미리보기
      final tomorrowPreview = _generateTomorrowPreview();

      final result = HealthFortuneResult(
        id: _generateId(),
        userId: input.userId,
        createdAt: DateTime.now(),
        overallScore: overallScore,
        mainMessage: mainMessage,
        bodyPartHealthList: bodyPartHealthList,
        recommendations: recommendations,
        avoidanceList: avoidanceList,
        timeline: timeline,
        tomorrowPreview: tomorrowPreview,
        additionalInfo: {
          'inputCondition': input.currentCondition?.name,
          'concernedParts':
              input.concernedBodyParts?.map((p) => p.name).toList(),
        },
      );

      Logger.info('Health fortune generated successfully: ${result.id}');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate health fortune', e, stackTrace);
      rethrow;
    }
  }

  int _calculateBaseScore(ConditionState? condition) {
    if (condition == null) return 75; // 기본 점수

    switch (condition) {
      case ConditionState.excellent:
        return 90 + _random.nextInt(10);
      case ConditionState.good:
        return 80 + _random.nextInt(10);
      case ConditionState.normal:
        return 70 + _random.nextInt(10);
      case ConditionState.tired:
        return 50 + _random.nextInt(20);
      case ConditionState.sick:
        return 30 + _random.nextInt(20);
    }
  }

  List<BodyPartHealth> _generateBodyPartHealthList(
    List<BodyPart> concernedParts,
    int baseScore,
  ) {
    final List<BodyPartHealth> healthList = [];

    for (final part in BodyPart.values) {
      if (part == BodyPart.whole) continue;

      // 관심 부위는 점수를 낮게 설정
      int score;
      if (concernedParts.contains(part)) {
        score = (baseScore * 0.6).round() + _random.nextInt(20);
      } else {
        score = baseScore + _random.nextInt(20) - 10;
      }

      score = score.clamp(0, 100);

      final level = _getHealthLevel(score);
      final description = _generateBodyPartDescription(part, score);
      final tips = _generateBodyPartTips(part, level);

      healthList.add(BodyPartHealth(
        bodyPart: part,
        score: score,
        level: level,
        description: description,
        specificTips: tips,
      ));
    }

    return healthList;
  }

  HealthLevel _getHealthLevel(int score) {
    if (score >= 90) return HealthLevel.excellent;
    if (score >= 70) return HealthLevel.good;
    if (score >= 50) return HealthLevel.caution;
    return HealthLevel.warning;
  }

  int _calculateOverallScore(
      int baseScore, List<BodyPartHealth> bodyPartHealthList) {
    final avgScore =
        bodyPartHealthList.map((bph) => bph.score).reduce((a, b) => a + b) /
            bodyPartHealthList.length;

    // 기본 점수와 평균 점수의 가중 평균
    return ((baseScore * 0.6 + avgScore * 0.4).round()).clamp(0, 100);
  }

  String _generateMainMessage(int score, List<BodyPart>? concernedParts) {
    final messages = <String>[];

    if (score >= 90) {
      messages.addAll([
        '오늘은 컨디션이 매우 좋은 날이에요! 활발한 활동을 즐겨보세요.',
        '건강 상태가 최상이군요! 이런 날엔 평소 미뤄뒀던 운동을 시작해보세요.',
        '몸과 마음이 모두 건강한 완벽한 날입니다!',
      ]);
    } else if (score >= 70) {
      messages.addAll([
        '전반적으로 좋은 컨디션을 유지하고 있어요.',
        '건강한 하루를 보낼 수 있을 것 같아요.',
        '몸 상태가 안정적이니 적당한 활동을 즐겨보세요.',
      ]);
    } else if (score >= 50) {
      messages.addAll([
        '컨디션이 평소보다 조금 떨어져 있어요. 무리하지 마세요.',
        '오늘은 휴식을 취하며 몸을 챙기는 날로 만들어보세요.',
        '피로가 쌓여있는 것 같아요. 충분한 수면을 취하세요.',
      ]);
    } else {
      messages.addAll([
        '몸에 무리가 가고 있어요. 오늘은 꼭 휴식을 취하세요.',
        '건강에 적신호가 켜졌어요. 몸의 신호를 무시하지 마세요.',
        '컨디션 회복을 위해 충분한 휴식과 영양 공급이 필요해요.',
      ]);
    }

    if (concernedParts != null && concernedParts.isNotEmpty) {
      final partNames = concernedParts.map((p) => p.displayName).join(', ');
      messages.add('\n특히 $partNames 부위에 주의가 필요합니다.');
    }

    return messages[_random.nextInt(messages.length)];
  }

  String _generateBodyPartDescription(BodyPart part, int score) {
    final descriptions = <String, List<String>>{
      'excellent': [
        '${part.displayName} 상태가 매우 좋습니다.',
        '${part.displayName} 컨디션이 최상입니다.',
        '${part.displayName}이/가 건강하고 활기찹니다.',
      ],
      'good': [
        '${part.displayName} 상태가 양호합니다.',
        '${part.displayName}이/가 안정적입니다.',
        '${part.displayName} 컨디션이 좋은 편입니다.',
      ],
      'caution': [
        '${part.displayName}에 약간의 피로감이 있어요.',
        '${part.displayName} 상태에 주의가 필요합니다.',
        '${part.displayName}이/가 조금 무거운 느낌입니다.',
      ],
      'warning': [
        '${part.displayName}에 부담이 가고 있어요.',
        '${part.displayName} 상태가 좋지 않습니다.',
        '${part.displayName} 관리가 시급합니다.',
      ],
    };

    String category;
    if (score >= 90) {
      category = 'excellent';
    } else if (score >= 70) {
      category = 'good';
    } else if (score >= 50) {
      category = 'caution';
    } else {
      category = 'warning';
    }

    final options = descriptions[category]!;
    return options[_random.nextInt(options.length)];
  }

  List<String> _generateBodyPartTips(BodyPart part, HealthLevel level) {
    final tipMap = <BodyPart, Map<HealthLevel, List<String>>>{
      BodyPart.head: {
        HealthLevel.excellent: ['충분한 수면을 계속 유지하세요', '스트레스 관리를 잘 하고 있어요'],
        HealthLevel.good: ['규칙적인 수면 패턴을 지켜주세요', '가벼운 목 스트레칭을 해보세요'],
        HealthLevel.caution: ['충분한 휴식을 취하세요', '카페인 섭취를 줄여보세요'],
        HealthLevel.warning: ['두통이 계속되면 전문의 상담을 받으세요', '스트레스 요인을 파악해보세요'],
      },
      BodyPart.neck: {
        HealthLevel.excellent: ['목 건강을 잘 관리하고 있어요', '올바른 자세를 유지하세요'],
        HealthLevel.good: ['목 스트레칭을 꾸준히 해주세요', '베개 높이를 점검해보세요'],
        HealthLevel.caution: ['장시간 같은 자세 피하기', '목 마사지를 받아보세요'],
        HealthLevel.warning: ['목 통증이 심하면 병원 방문을 고려하세요', '목에 무리가 가는 활동 자제'],
      },
      // ... 다른 부위들도 비슷하게 추가
    };

    return tipMap[part]?[level] ?? ['해당 부위 건강 관리에 신경써주세요'];
  }

  List<HealthRecommendation> _generateRecommendations(
      int score, List<BodyPart>? concernedParts) {
    final recommendations = <HealthRecommendation>[];

    // 점수 기반 추천
    if (score >= 80) {
      recommendations.addAll([
        const HealthRecommendation(
          type: HealthRecommendationType.exercise,
          title: '유산소 운동',
          description: '30분간 가벼운 조깅이나 걷기를 추천해요',
          priority: 1,
        ),
        const HealthRecommendation(
          type: HealthRecommendationType.food,
          title: '신선한 과일',
          description: '비타민이 풍부한 제철 과일을 드세요',
          priority: 2,
        ),
      ]);
    } else if (score >= 60) {
      recommendations.addAll([
        const HealthRecommendation(
          type: HealthRecommendationType.rest,
          title: '충분한 휴식',
          description: '7-8시간의 양질의 수면을 취하세요',
          priority: 1,
        ),
        const HealthRecommendation(
          type: HealthRecommendationType.food,
          title: '균형 잡힌 식사',
          description: '규칙적인 식사와 충분한 수분 섭취',
          priority: 2,
        ),
      ]);
    } else {
      recommendations.addAll([
        const HealthRecommendation(
          type: HealthRecommendationType.rest,
          title: '완전한 휴식',
          description: '오늘은 충분한 휴식을 취하는 것이 최우선이에요',
          priority: 1,
        ),
        const HealthRecommendation(
          type: HealthRecommendationType.medical,
          title: '건강 체크',
          description: '컨디션이 지속적으로 나쁘면 병원 방문을 고려하세요',
          priority: 1,
        ),
      ]);
    }

    return recommendations;
  }

  List<String> _generateAvoidanceList(int score) {
    if (score >= 80) {
      return ['과도한 음주', '너무 늦은 시간 취침'];
    } else if (score >= 60) {
      return ['무리한 운동', '스트레스 받는 일', '기름진 음식'];
    } else {
      return ['격렬한 운동', '음주', '흡연', '스트레스 상황', '과식'];
    }
  }

  HealthTimeline _generateHealthTimeline(int baseScore) {
    final morning = HealthTimeSlot(
      timeLabel: '오전 (06-12시)',
      conditionScore: (baseScore + _random.nextInt(20) - 10).clamp(0, 100),
      description: '하루를 시작하는 활력이 있어요',
      recommendations: ['가벼운 스트레칭', '건강한 아침식사'],
    );

    final afternoon = HealthTimeSlot(
      timeLabel: '오후 (12-18시)',
      conditionScore: (baseScore + _random.nextInt(15) - 7).clamp(0, 100),
      description: '전반적으로 안정적인 컨디션이에요',
      recommendations: ['균형잡힌 점심', '짧은 산책'],
    );

    final evening = HealthTimeSlot(
      timeLabel: '저녁 (18-24시)',
      conditionScore: (baseScore + _random.nextInt(25) - 12).clamp(0, 100),
      description: '하루 피로가 쌓이는 시간이에요',
      recommendations: ['가벼운 저녁식사', '충분한 휴식'],
    );

    final bestTime = [morning, afternoon, evening]
        .reduce((a, b) => a.conditionScore > b.conditionScore ? a : b);

    return HealthTimeline(
      morning: morning,
      afternoon: afternoon,
      evening: evening,
      bestTimeActivity: '${bestTime.timeLabel}에 중요한 활동을 하는 것이 좋겠어요',
    );
  }

  String _generateTomorrowPreview() {
    final previews = [
      '내일은 오늘보다 더 좋은 컨디션이 예상돼요!',
      '내일도 비슷한 건강 상태를 유지할 것 같아요.',
      '내일은 조금 더 주의가 필요할 수 있어요.',
      '내일부터는 컨디션 회복이 시작될 거예요.',
    ];
    return previews[_random.nextInt(previews.length)];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  /// Fortune 객체를 HealthFortuneResult로 변환
  HealthFortuneResult _convertFortuneToHealthResult(
    Fortune fortune,
    HealthFortuneInput input,
  ) {
    // API 응답에서 신체 부위별 정보 파싱
    final bodyPartHealthList = _parseBodyPartHealthFromFortune(fortune);

    return HealthFortuneResult(
      id: fortune.id,
      userId: input.userId,
      createdAt: DateTime.now(),
      overallScore: fortune.overallScore ?? 75,
      mainMessage: fortune.description ?? fortune.content,
      bodyPartHealthList: bodyPartHealthList,
      recommendations: _parseRecommendations(fortune),
      avoidanceList: _parseAvoidanceList(fortune),
      timeline: _parseTimeline(fortune),
      tomorrowPreview: _parseTomorrowPreview(fortune),
      additionalInfo: fortune.additionalInfo ?? {},
    );
  }

  List<BodyPartHealth> _parseBodyPartHealthFromFortune(Fortune fortune) {
    // API 응답의 additionalInfo에서 신체 부위 정보 파싱
    if (fortune.additionalInfo != null &&
        fortune.additionalInfo!['bodyParts'] != null) {
      final bodyPartsData = fortune.additionalInfo!['bodyParts'] as List;
      return bodyPartsData.map((data) {
        final partName = data['bodyPart'] as String;
        final bodyPart = BodyPart.values.firstWhere(
          (p) => p.name == partName,
          orElse: () => BodyPart.whole,
        );

        return BodyPartHealth(
          bodyPart: bodyPart,
          score: data['score'] as int? ?? 75,
          level: _parseHealthLevel(data['level'] as String?),
          description: data['description'] as String? ?? '',
          specificTips: (data['tips'] as List?)?.cast<String>() ?? [],
        );
      }).toList();
    }

    // 기본값: 전체 신체 상태만 반환
    return [
      BodyPartHealth(
        bodyPart: BodyPart.whole,
        score: fortune.overallScore ?? 75,
        level: _getHealthLevel(fortune.overallScore ?? 75),
        description: fortune.description ?? '',
        specificTips: fortune.recommendations ?? [],
      ),
    ];
  }

  HealthLevel _parseHealthLevel(String? levelStr) {
    switch (levelStr) {
      case 'excellent':
        return HealthLevel.excellent;
      case 'good':
        return HealthLevel.good;
      case 'caution':
        return HealthLevel.caution;
      case 'warning':
        return HealthLevel.warning;
      default:
        return HealthLevel.good;
    }
  }

  List<HealthRecommendation> _parseRecommendations(Fortune fortune) {
    if (fortune.recommendations != null &&
        fortune.recommendations!.isNotEmpty) {
      return fortune.recommendations!.asMap().entries.map((entry) {
        return HealthRecommendation(
          type: HealthRecommendationType.lifestyle,
          title: '건강 관리 ${entry.key + 1}',
          description: entry.value,
          priority: entry.key + 1,
        );
      }).toList();
    }
    return [];
  }

  List<String> _parseAvoidanceList(Fortune fortune) {
    if (fortune.additionalInfo != null &&
        fortune.additionalInfo!['avoidanceList'] != null) {
      return (fortune.additionalInfo!['avoidanceList'] as List).cast<String>();
    }
    return [];
  }

  HealthTimeline _parseTimeline(Fortune fortune) {
    // additionalInfo에서 시간대별 정보 파싱
    if (fortune.additionalInfo != null &&
        fortune.additionalInfo!['timeline'] != null) {
      final timelineData =
          fortune.additionalInfo!['timeline'] as Map<String, dynamic>;

      return HealthTimeline(
        morning: _parseTimeSlot(
            timelineData['morning'] as Map<String, dynamic>?, '오전'),
        afternoon: _parseTimeSlot(
            timelineData['afternoon'] as Map<String, dynamic>?, '오후'),
        evening: _parseTimeSlot(
            timelineData['evening'] as Map<String, dynamic>?, '저녁'),
        bestTimeActivity: timelineData['bestTimeActivity'] as String?,
      );
    }

    // 기본값: 전체적으로 좋은 컨디션
    final defaultScore = fortune.overallScore ?? 75;
    return HealthTimeline(
      morning: HealthTimeSlot(
        timeLabel: '오전',
        conditionScore: defaultScore,
        description: '전반적으로 양호한 컨디션입니다',
        recommendations: ['가벼운 운동', '아침 식사'],
      ),
      afternoon: HealthTimeSlot(
        timeLabel: '오후',
        conditionScore: defaultScore,
        description: '전반적으로 양호한 컨디션입니다',
        recommendations: ['업무', '산책'],
      ),
      evening: HealthTimeSlot(
        timeLabel: '저녁',
        conditionScore: defaultScore,
        description: '전반적으로 양호한 컨디션입니다',
        recommendations: ['휴식', '스트레칭'],
      ),
    );
  }

  HealthTimeSlot _parseTimeSlot(Map<String, dynamic>? data, String label) {
    if (data == null) {
      return HealthTimeSlot(
        timeLabel: label,
        conditionScore: 75,
        description: '양호한 컨디션',
        recommendations: [],
      );
    }

    return HealthTimeSlot(
      timeLabel: label,
      conditionScore: data['score'] as int? ?? 75,
      description: data['description'] as String? ?? '',
      recommendations: (data['activities'] as List?)?.cast<String>() ?? [],
    );
  }

  String _parseTomorrowPreview(Fortune fortune) {
    if (fortune.additionalInfo != null &&
        fortune.additionalInfo!['tomorrowPreview'] != null) {
      return fortune.additionalInfo!['tomorrowPreview'] as String;
    }
    return '내일의 건강 상태를 예측하고 있어요.';
  }
}
