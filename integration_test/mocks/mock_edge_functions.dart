/// Mock Edge Functions for Integration Tests
/// Edge Function Mock - 실제 API 호출 없이 운세 기능 테스트
///
/// 사용법:
/// ```dart
/// final mockApi = MockEdgeFunctions();
/// mockApi.setNextResponse(MockApiResponse.success(mockDailyFortune));
/// final result = await mockApi.callFunction('fortune-daily', {...});
/// ```

import 'dart:async';
import 'dart:math';

/// Mock API 응답 상태
enum MockApiStatus {
  success,
  error,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  rateLimited,
}

/// Mock API 응답
class MockApiResponse<T> {
  final MockApiStatus status;
  final T? data;
  final String? errorCode;
  final String? errorMessage;
  final int statusCode;
  final Duration? responseTime;

  const MockApiResponse._({
    required this.status,
    this.data,
    this.errorCode,
    this.errorMessage,
    required this.statusCode,
    this.responseTime,
  });

  factory MockApiResponse.success(T data, {Duration? responseTime}) =>
      MockApiResponse._(
        status: MockApiStatus.success,
        data: data,
        statusCode: 200,
        responseTime: responseTime,
      );

  factory MockApiResponse.error(String code, String message, {int statusCode = 400}) =>
      MockApiResponse._(
        status: MockApiStatus.error,
        errorCode: code,
        errorMessage: message,
        statusCode: statusCode,
      );

  factory MockApiResponse.timeout() => const MockApiResponse._(
        status: MockApiStatus.timeout,
        errorCode: 'TIMEOUT',
        errorMessage: '요청 시간이 초과되었습니다.',
        statusCode: 408,
      );

  factory MockApiResponse.unauthorized() => const MockApiResponse._(
        status: MockApiStatus.unauthorized,
        errorCode: 'UNAUTHORIZED',
        errorMessage: '인증이 필요합니다.',
        statusCode: 401,
      );

  factory MockApiResponse.serverError() => const MockApiResponse._(
        status: MockApiStatus.serverError,
        errorCode: 'SERVER_ERROR',
        errorMessage: '서버 오류가 발생했습니다.',
        statusCode: 500,
      );

  factory MockApiResponse.rateLimited() => const MockApiResponse._(
        status: MockApiStatus.rateLimited,
        errorCode: 'RATE_LIMITED',
        errorMessage: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
        statusCode: 429,
      );

  bool get isSuccess => status == MockApiStatus.success;
  bool get isError => status != MockApiStatus.success;
}

/// Mock Edge Functions Service
class MockEdgeFunctions {
  // Singleton
  static final MockEdgeFunctions _instance = MockEdgeFunctions._internal();
  factory MockEdgeFunctions() => _instance;
  MockEdgeFunctions._internal();

  // 설정
  Duration _defaultDelay = const Duration(milliseconds: 300);
  bool _simulateNetworkDelay = true;
  MockApiResponse? _forcedNextResponse;
  final Map<String, MockApiResponse Function(Map<String, dynamic>)> _customHandlers = {};

  // 호출 기록
  final List<MockFunctionCall> _callHistory = [];

  // Random for generating mock data
  final _random = Random();

  // Getters
  List<MockFunctionCall> get callHistory => List.unmodifiable(_callHistory);

  // 설정 메서드

  /// 네트워크 딜레이 설정
  void setNetworkDelay(Duration delay) {
    _defaultDelay = delay;
  }

  /// 네트워크 딜레이 시뮬레이션 활성화/비활성화
  void setSimulateNetworkDelay(bool simulate) {
    _simulateNetworkDelay = simulate;
  }

  /// 다음 응답 강제 설정 (한 번만 적용)
  void setNextResponse(MockApiResponse response) {
    _forcedNextResponse = response;
  }

  /// 특정 함수에 대한 커스텀 핸들러 등록
  void registerHandler(String functionName, MockApiResponse Function(Map<String, dynamic>) handler) {
    _customHandlers[functionName] = handler;
  }

  /// 호출 기록 초기화
  void clearCallHistory() {
    _callHistory.clear();
  }

  /// 모든 설정 초기화
  void reset() {
    _defaultDelay = const Duration(milliseconds: 300);
    _simulateNetworkDelay = true;
    _forcedNextResponse = null;
    _customHandlers.clear();
    _callHistory.clear();
  }

  // Edge Function 호출

  /// Edge Function 호출 (Mock)
  Future<MockApiResponse<Map<String, dynamic>>> callFunction(
    String functionName,
    Map<String, dynamic> params,
  ) async {
    // 호출 기록
    final call = MockFunctionCall(
      functionName: functionName,
      params: params,
      timestamp: DateTime.now(),
    );
    _callHistory.add(call);

    // 네트워크 딜레이 시뮬레이션
    if (_simulateNetworkDelay) {
      await Future.delayed(_defaultDelay);
    }

    // 강제 응답이 설정된 경우
    if (_forcedNextResponse != null) {
      final response = _forcedNextResponse!;
      _forcedNextResponse = null;
      return response as MockApiResponse<Map<String, dynamic>>;
    }

    // 커스텀 핸들러가 있는 경우
    if (_customHandlers.containsKey(functionName)) {
      return _customHandlers[functionName]!(params) as MockApiResponse<Map<String, dynamic>>;
    }

    // 기본 Mock 응답 생성
    return _generateMockResponse(functionName, params);
  }

  /// 기본 Mock 응답 생성
  MockApiResponse<Map<String, dynamic>> _generateMockResponse(
    String functionName,
    Map<String, dynamic> params,
  ) {
    // 함수명에 따른 Mock 데이터 생성
    switch (functionName) {
      case 'fortune-daily':
      case 'fortune-today':
        return MockApiResponse.success(_mockDailyFortune(params));

      case 'fortune-tarot':
      case 'tarot-reading':
        return MockApiResponse.success(_mockTarotReading(params));

      case 'fortune-compatibility':
      case 'compatibility':
        return MockApiResponse.success(_mockCompatibility(params));

      case 'fortune-mbti':
        return MockApiResponse.success(_mockMbtiFortune(params));

      case 'fortune-dream':
      case 'dream-interpretation':
        return MockApiResponse.success(_mockDreamInterpretation(params));

      case 'fortune-saju':
      case 'saju-analysis':
        return MockApiResponse.success(_mockSajuAnalysis(params));

      case 'fortune-love':
        return MockApiResponse.success(_mockLoveFortune(params));

      case 'fortune-money':
      case 'fortune-wealth':
        return MockApiResponse.success(_mockWealthFortune(params));

      case 'fortune-health':
        return MockApiResponse.success(_mockHealthFortune(params));

      case 'fortune-talisman':
      case 'generate-talisman':
        return MockApiResponse.success(_mockTalisman(params));

      case 'fortune-face-reading':
        return MockApiResponse.success(_mockFaceReading(params));

      case 'fortune-biorhythm':
        return MockApiResponse.success(_mockBiorhythm(params));

      default:
        return MockApiResponse.success(_mockGenericFortune(functionName, params));
    }
  }

  // Mock 데이터 생성 메서드들

  Map<String, dynamic> _mockDailyFortune(Map<String, dynamic> params) {
    final score = 60 + _random.nextInt(40);
    return {
      'id': 'mock-daily-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'daily',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'score': score,
      'summary': '오늘은 ${score >= 80 ? '매우 좋은' : score >= 60 ? '무난한' : '조심해야 할'} 하루입니다.',
      'overall': '전반적으로 ${score >= 80 ? '긍정적인 에너지가 넘치는' : '평온한'} 하루가 예상됩니다.',
      'love': '연애운: ${_random.nextInt(100)}점 - 소통이 중요한 시기입니다.',
      'money': '금전운: ${_random.nextInt(100)}점 - 지출을 관리하세요.',
      'health': '건강운: ${_random.nextInt(100)}점 - 충분한 휴식이 필요합니다.',
      'work': '직장운: ${_random.nextInt(100)}점 - 협업이 좋은 결과를 가져옵니다.',
      'lucky_color': ['빨강', '파랑', '노랑', '초록', '보라'][_random.nextInt(5)],
      'lucky_number': _random.nextInt(9) + 1,
      'lucky_direction': ['동', '서', '남', '북'][_random.nextInt(4)],
      'advice': '오늘 하루도 긍정적인 마음으로 시작하세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockTarotReading(Map<String, dynamic> params) {
    final cards = ['The Fool', 'The Magician', 'The High Priestess', 'The Empress', 'The Emperor'];
    return {
      'id': 'mock-tarot-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'tarot',
      'question': params['question'] ?? '오늘의 운세',
      'spread': params['spread'] ?? 'single',
      'cards': [
        {
          'name': cards[_random.nextInt(cards.length)],
          'position': 'present',
          'is_reversed': _random.nextBool(),
          'meaning': '현재 상황을 나타냅니다.',
        },
      ],
      'interpretation': '카드가 전하는 메시지: 변화를 두려워하지 마세요.',
      'advice': '직관을 믿고 행동하세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockCompatibility(Map<String, dynamic> params) {
    final score = 50 + _random.nextInt(50);
    return {
      'id': 'mock-compat-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'compatibility',
      'person1': params['person1'] ?? {},
      'person2': params['person2'] ?? {},
      'overall_score': score,
      'love_score': 40 + _random.nextInt(60),
      'friendship_score': 40 + _random.nextInt(60),
      'work_score': 40 + _random.nextInt(60),
      'summary': '두 분의 궁합은 ${score}%입니다.',
      'strengths': ['서로를 이해하는 능력', '의사소통'],
      'challenges': ['가끔의 의견 충돌'],
      'advice': '서로의 차이를 존중하세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockMbtiFortune(Map<String, dynamic> params) {
    final mbti = params['mbti'] ?? 'INTJ';
    return {
      'id': 'mock-mbti-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'mbti',
      'mbti': mbti,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'daily_fortune': '$mbti 유형을 위한 오늘의 조언입니다.',
      'energy_level': 60 + _random.nextInt(40),
      'social_compatibility': ['ENFP', 'ENTP', 'INFJ'],
      'lucky_activity': '창의적인 작업',
      'avoid_activity': '갈등 상황',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockDreamInterpretation(Map<String, dynamic> params) {
    return {
      'id': 'mock-dream-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'dream',
      'dream_content': params['content'] ?? '',
      'symbols': ['물', '하늘', '새'],
      'interpretation': '이 꿈은 새로운 시작을 암시합니다.',
      'psychological_meaning': '무의식의 욕구가 반영되어 있습니다.',
      'fortune_implication': '긍정적인 변화가 예상됩니다.',
      'lucky_number': _random.nextInt(45) + 1,
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockSajuAnalysis(Map<String, dynamic> params) {
    return {
      'id': 'mock-saju-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'saju',
      'birth_date': params['birth_date'] ?? '',
      'birth_time': params['birth_time'] ?? '',
      'pillars': {
        'year': {'heavenly': '갑', 'earthly': '자'},
        'month': {'heavenly': '을', 'earthly': '축'},
        'day': {'heavenly': '병', 'earthly': '인'},
        'hour': {'heavenly': '정', 'earthly': '묘'},
      },
      'five_elements': {'wood': 2, 'fire': 3, 'earth': 1, 'metal': 2, 'water': 2},
      'overall_analysis': '균형 잡힌 사주입니다.',
      'career_advice': '창의적인 분야에서 두각을 나타낼 수 있습니다.',
      'love_advice': '올해 좋은 인연을 만날 가능성이 있습니다.',
      'health_advice': '화의 기운이 강하니 심장 건강에 유의하세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockLoveFortune(Map<String, dynamic> params) {
    return {
      'id': 'mock-love-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'love',
      'score': 60 + _random.nextInt(40),
      'summary': '연애 운이 상승하는 시기입니다.',
      'ideal_partner': '차분하고 이해심 많은 사람',
      'meeting_place': ['카페', '도서관', '운동 시설'][_random.nextInt(3)],
      'timing': '이번 달 후반',
      'advice': '자신감을 가지고 다가가세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockWealthFortune(Map<String, dynamic> params) {
    return {
      'id': 'mock-wealth-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'wealth',
      'score': 50 + _random.nextInt(50),
      'summary': '재물운이 안정적인 시기입니다.',
      'investment_advice': '안정적인 투자를 권장합니다.',
      'spending_advice': '불필요한 지출을 줄이세요.',
      'lucky_direction': '동쪽',
      'lucky_color': '노랑',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockHealthFortune(Map<String, dynamic> params) {
    return {
      'id': 'mock-health-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'health',
      'score': 60 + _random.nextInt(40),
      'summary': '건강 상태가 양호합니다.',
      'focus_areas': ['소화기', '호흡기'],
      'exercise_recommendation': '가벼운 유산소 운동',
      'diet_advice': '채소 섭취를 늘리세요.',
      'rest_advice': '7-8시간 수면을 유지하세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockTalisman(Map<String, dynamic> params) {
    return {
      'id': 'mock-talisman-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'talisman',
      'wish': params['wish'] ?? '',
      'image_url': 'https://placeholder.com/talisman.png',
      'design_elements': ['용', '구름', '태극'],
      'meaning': '소원 성취를 기원하는 부적입니다.',
      'usage_guide': '매일 아침 부적을 바라보며 소원을 빌어보세요.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockFaceReading(Map<String, dynamic> params) {
    return {
      'id': 'mock-face-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'face_reading',
      'overall_fortune': '좋은 관상입니다.',
      'forehead': '지혜로운 이마입니다.',
      'eyes': '부드러운 인상의 눈입니다.',
      'nose': '재물복이 있는 코입니다.',
      'mouth': '복이 많은 입술입니다.',
      'face_shape': '원만한 대인관계를 나타냅니다.',
      'career_tendency': '리더십이 있습니다.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockBiorhythm(Map<String, dynamic> params) {
    return {
      'id': 'mock-biorhythm-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'biorhythm',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'physical': _random.nextInt(200) - 100,
      'emotional': _random.nextInt(200) - 100,
      'intellectual': _random.nextInt(200) - 100,
      'intuition': _random.nextInt(200) - 100,
      'advice': '오늘은 지적 활동에 좋은 날입니다.',
      'is_test_data': true,
    };
  }

  Map<String, dynamic> _mockGenericFortune(String functionName, Map<String, dynamic> params) {
    return {
      'id': 'mock-generic-${DateTime.now().millisecondsSinceEpoch}',
      'type': functionName,
      'score': 50 + _random.nextInt(50),
      'summary': '테스트 운세입니다.',
      'advice': '좋은 하루 되세요.',
      'is_test_data': true,
    };
  }
}

/// Mock 함수 호출 기록
class MockFunctionCall {
  final String functionName;
  final Map<String, dynamic> params;
  final DateTime timestamp;

  MockFunctionCall({
    required this.functionName,
    required this.params,
    required this.timestamp,
  });
}
