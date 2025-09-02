import 'dart:math';
import '../features/fortune/domain/models/blind_date_instagram_model.dart';

/// Instagram 분석 서비스
/// 실제 구현에서는 Instagram API 또는 웹 스크래핑을 사용해야 함
class BlindDateInstagramService {
  static final BlindDateInstagramService _instance = BlindDateInstagramService._internal();
  factory BlindDateInstagramService() => _instance;
  BlindDateInstagramService._internal();

  /// Instagram 프로필을 분석하여 결과 생성
  Future<BlindDateCoachingResult> analyzeAndGenerateCoaching(
    BlindDateInstagramInput input,
  ) async {
    // 실제로는 Instagram API를 호출하거나 웹 스크래핑을 수행
    // 여기서는 시뮬레이션을 위해 2초 지연
    await Future.delayed(const Duration(seconds: 2));

    // Mock 프로필 분석 결과 생성
    final profileAnalysis = _generateMockProfileAnalysis(input.partnerInstagramUrl);
    
    // Mock 코칭 결과 생성
    return _generateMockCoachingResult(input, profileAnalysis);
  }

  /// Mock Instagram 프로필 분석 생성
  InstagramProfileAnalysis _generateMockProfileAnalysis(String instagramUrl) {
    final random = Random();
    final fashionStyles = ['casual', 'formal', 'street', 'minimal', 'trendy'];
    final personalities = ['extrovert', 'introvert', 'ambivert'];
    final lifestyles = ['workaholic', 'balanced', 'social', 'homebody'];
    final ageRanges = ['20-25', '25-30', '30-35'];
    final postingFrequencies = ['daily', 'weekly', 'monthly', 'rare'];
    final contentTypes = ['selfie', 'food', 'travel', 'lifestyle', 'mixed'];
    
    final interests = [
      'travel', 'food', 'fitness', 'art', 'music', 
      'fashion', 'photography', 'reading', 'movies', 'coffee'
    ];
    
    // 랜덤하게 3-5개의 관심사 선택
    interests.shuffle();
    final selectedInterests = interests.take(3 + random.nextInt(3)).toList();
    
    // 랜덤하게 2-4개의 자주 가는 장소 생성
    final locations = [
      '강남 카페거리', '홍대 클럽', '성수동 맛집', '한강공원',
      '이태원', '북촌 한옥마을', '명동', '을지로', '연남동'
    ];
    locations.shuffle();
    final selectedLocations = locations.take(2 + random.nextInt(3)).toList();
    
    // 랜덤하게 3-5개의 해시태그 트렌드 생성
    final hashtags = [
      '#일상', '#맛집', '#여행', '#운동', '#카페',
      '#소통', '#주말', '#힐링', '#셀피', '#오오티디'
    ];
    hashtags.shuffle();
    final selectedHashtags = hashtags.take(3 + random.nextInt(3)).toList();
    
    return InstagramProfileAnalysis(
      profileImageUrl: 'https://picsum.photos/200',
      username: instagramUrl.split('/').last.replaceAll('/', ''),
      followerCount: 500 + random.nextInt(2000),
      followingCount: 300 + random.nextInt(1000),
      postCount: 50 + random.nextInt(200),
      fashionStyle: fashionStyles[random.nextInt(fashionStyles.length)],
      estimatedPersonality: personalities[random.nextInt(personalities.length)],
      detectedInterests: selectedInterests,
      lifestyle: lifestyles[random.nextInt(lifestyles.length)],
      ageRange: ageRanges[random.nextInt(ageRanges.length)],
      frequentLocations: selectedLocations,
      hashtagTrends: selectedHashtags,
      postingFrequency: postingFrequencies[random.nextInt(postingFrequencies.length)],
      contentType: contentTypes[random.nextInt(contentTypes.length)],
    );
  }

  /// Mock 코칭 결과 생성
  BlindDateCoachingResult _generateMockCoachingResult(
    BlindDateInstagramInput input,
    InstagramProfileAnalysis profileAnalysis,
  ) {
    final random = Random();
    
    // 궁합 점수 계산 (60-95 사이)
    final compatibilityScore = 60 + random.nextInt(36);
    
    // 궁합 레벨 결정
    String compatibilityLevel;
    if (compatibilityScore >= 85) {
      compatibilityLevel = 'excellent';
    } else if (compatibilityScore >= 70) {
      compatibilityLevel = 'good';
    } else if (compatibilityScore >= 55) {
      compatibilityLevel = 'moderate';
    } else {
      compatibilityLevel = 'challenging';
    }
    
    // 공통 관심사 찾기
    final commonInterests = input.myInterests
        .where((interest) => profileAnalysis.detectedInterests.contains(interest))
        .toList();
    if (commonInterests.isEmpty && profileAnalysis.detectedInterests.isNotEmpty) {
      commonInterests.add(profileAnalysis.detectedInterests.first);
    }
    
    // 보완적 특성 생성
    final complementaryTraits = _generateComplementaryTraits(profileAnalysis);
    
    // 첫인상 전략 생성
    final firstImpression = _generateFirstImpressionStrategy(
      input,
      profileAnalysis,
    );
    
    // 대화 가이드 생성
    final conversationGuide = _generateConversationGuide(
      input,
      profileAnalysis,
      commonInterests,
    );
    
    // 스타일링 추천 생성
    final styling = _generateStylingRecommendation(
      input,
      profileAnalysis,
    );
    
    // 데이트 플랜 제안 생성
    final datePlan = _generateDatePlanSuggestion(
      input,
      profileAnalysis,
    );
    
    // DO & DON'T 리스트 생성
    final doList = _generateDoList(profileAnalysis);
    final dontList = _generateDontList(profileAnalysis);
    
    // 동기부여 메시지와 행운의 아이템
    final motivationalMessage = _generateMotivationalMessage(compatibilityScore);
    final luckyCharm = _generateLuckyCharm();
    
    return BlindDateCoachingResult(
      compatibilityScore: compatibilityScore,
      compatibilityLevel: compatibilityLevel,
      commonInterests: commonInterests,
      complementaryTraits: complementaryTraits,
      firstImpression: firstImpression,
      conversationGuide: conversationGuide,
      styling: styling,
      datePlan: datePlan,
      doList: doList,
      dontList: dontList,
      motivationalMessage: motivationalMessage,
      luckyCharm: luckyCharm,
    );
  }

  List<String> _generateComplementaryTraits(InstagramProfileAnalysis profile) {
    final traits = <String>[];
    
    if (profile.estimatedPersonality == 'extrovert') {
      traits.add('당신의 차분함이 상대의 에너지와 균형을 이룹니다');
    } else if (profile.estimatedPersonality == 'introvert') {
      traits.add('당신의 활발함이 상대에게 새로운 경험을 선사합니다');
    } else {
      traits.add('서로의 유연한 성격이 조화를 이룹니다');
    }
    
    if (profile.lifestyle == 'workaholic') {
      traits.add('일과 삶의 균형에 대한 새로운 시각을 제공할 수 있습니다');
    } else if (profile.lifestyle == 'social') {
      traits.add('다양한 사람들과의 네트워킹 기회가 늘어날 것입니다');
    }
    
    traits.add('서로 다른 관심사가 관계를 더욱 풍성하게 만들어줍니다');
    
    return traits;
  }

  FirstImpressionStrategy _generateFirstImpressionStrategy(
    BlindDateInstagramInput input,
    InstagramProfileAnalysis profile,
  ) {
    String approachStyle;
    String openingLine;
    List<String> bodyLanguageTips;
    String energyLevel;
    String smileIntensity;
    
    // 성격에 따른 접근 스타일 결정
    if (profile.estimatedPersonality == 'extrovert') {
      approachStyle = 'warm';
      openingLine = '오늘 날씨 정말 좋네요! 여기까지 오시는데 힘들지 않으셨어요?';
      energyLevel = 'energetic';
      smileIntensity = 'bright';
    } else if (profile.estimatedPersonality == 'introvert') {
      approachStyle = 'professional';
      openingLine = '안녕하세요, 만나서 반갑습니다. 좋은 곳이네요.';
      energyLevel = 'calm';
      smileIntensity = 'subtle';
    } else {
      approachStyle = 'playful';
      openingLine = '드디어 만났네요! 사진으로 뵙던 것보다 더 좋으신데요?';
      energyLevel = 'moderate';
      smileIntensity = 'natural';
    }
    
    // 바디랭귀지 팁
    bodyLanguageTips = [
      '눈을 마주치며 진정성 있게 대화하기',
      '열린 자세로 편안한 분위기 만들기',
      '적절한 거리 유지하며 존중 표현하기',
      '고개를 끄덕이며 경청하는 모습 보이기',
    ];
    
    return FirstImpressionStrategy(
      approachStyle: approachStyle,
      openingLine: openingLine,
      bodyLanguageTips: bodyLanguageTips,
      energyLevel: energyLevel,
      smileIntensity: smileIntensity,
    );
  }

  ConversationGuide _generateConversationGuide(
    BlindDateInstagramInput input,
    InstagramProfileAnalysis profile,
    List<String> commonInterests,
  ) {
    final iceBreakers = <String>[];
    final recommendedTopics = <String>[];
    final avoidTopics = <String>[];
    String conversationStyle;
    final interestingQuestions = <String>[];
    String humorLevel;
    
    // 아이스브레이킹 질문들
    if (profile.detectedInterests.contains('travel')) {
      iceBreakers.add('최근에 가장 인상 깊었던 여행지는 어디였어요?');
    }
    if (profile.detectedInterests.contains('food')) {
      iceBreakers.add('이 근처에 맛집 아시는 곳 있으신가요?');
    }
    iceBreakers.addAll([
      '주말에는 주로 뭐 하면서 시간 보내세요?',
      '요즘 가장 빠져있는 것이 있다면?',
      '스트레스 받을 때 어떻게 푸시는 편이에요?',
    ]);
    
    // 추천 대화 주제
    recommendedTopics.addAll(commonInterests.map((e) => '$e에 대한 이야기'));
    recommendedTopics.addAll([
      '좋아하는 음악이나 영화',
      '최근 관심사나 취미',
      '일상 루틴과 라이프스타일',
    ]);
    
    // 피해야 할 주제
    avoidTopics.addAll([
      '과거 연애 이야기',
      '정치적 견해',
      '연봉이나 재산',
      '가족의 사적인 문제',
    ]);
    
    // 대화 스타일
    if (profile.estimatedPersonality == 'extrovert') {
      conversationStyle = 'listener';
      humorLevel = 'moderate';
    } else if (profile.estimatedPersonality == 'introvert') {
      conversationStyle = 'storyteller';
      humorLevel = 'minimal';
    } else {
      conversationStyle = 'balanced';
      humorLevel = 'frequent';
    }
    
    // 흥미로운 질문들
    interestingQuestions.addAll([
      '만약 한 달 동안 휴가를 간다면 어디로 가고 싶으세요?',
      '인생에서 가장 도전적이었던 순간은?',
      '10년 후 자신의 모습을 상상해보신 적 있으세요?',
    ]);
    
    return ConversationGuide(
      iceBreakers: iceBreakers.take(5).toList(),
      recommendedTopics: recommendedTopics,
      avoidTopics: avoidTopics,
      conversationStyle: conversationStyle,
      interestingQuestions: interestingQuestions,
      humorLevel: humorLevel,
    );
  }

  StylingRecommendation _generateStylingRecommendation(
    BlindDateInstagramInput input,
    InstagramProfileAnalysis profile,
  ) {
    String recommendedStyle;
    List<String> colorSuggestions;
    String dressCode;
    List<String> avoidItems;
    String accessoryTips;
    String groomingAdvice;
    
    // 상대방 스타일에 맞춰 추천
    if (profile.fashionStyle == 'formal') {
      recommendedStyle = '깔끔한 비즈니스 캐주얼 스타일';
      colorSuggestions = ['네이비', '화이트', '베이지'];
      dressCode = 'business casual';
      avoidItems = ['너무 캐주얼한 운동복', '샌들'];
    } else if (profile.fashionStyle == 'casual') {
      recommendedStyle = '편안하면서도 단정한 캐주얼룩';
      colorSuggestions = ['데님', '화이트', '파스텔톤'];
      dressCode = 'smart casual';
      avoidItems = ['너무 격식있는 정장', '화려한 액세서리'];
    } else if (profile.fashionStyle == 'trendy') {
      recommendedStyle = '트렌디하면서도 과하지 않은 스타일';
      colorSuggestions = ['블랙', '화이트', '포인트 컬러'];
      dressCode = 'casual';
      avoidItems = ['올드한 스타일', '너무 평범한 옷'];
    } else {
      recommendedStyle = '깔끔하고 무난한 스타일';
      colorSuggestions = ['모노톤', '네이비', '베이지'];
      dressCode = 'smart casual';
      avoidItems = ['너무 화려한 패턴', '과한 로고'];
    }
    
    // 만남 시간대에 따른 조정
    if (input.meetingTime == 'evening' || input.meetingTime == 'night') {
      recommendedStyle += ' (저녁이므로 조금 더 포멀하게)';
    }
    
    accessoryTips = '시계나 간단한 액세서리로 포인트 주기';
    groomingAdvice = '깔끔한 헤어스타일과 은은한 향수';
    
    return StylingRecommendation(
      recommendedStyle: recommendedStyle,
      colorSuggestions: colorSuggestions,
      dressCode: dressCode,
      avoidItems: avoidItems,
      accessoryTips: accessoryTips,
      groomingAdvice: groomingAdvice,
    );
  }

  DatePlanSuggestion _generateDatePlanSuggestion(
    BlindDateInstagramInput input,
    InstagramProfileAnalysis profile,
  ) {
    String idealTiming;
    List<String> locationSuggestions;
    String atmosphereType;
    List<String> activityIdeas;
    String mealRecommendation;
    int suggestedDuration;
    
    // 이미 정해진 시간대 활용
    idealTiming = '약속된 ${_getTimeString(input.meetingTime)}';
    
    // 만남 타입에 따른 장소 추천
    if (input.meetingType == 'cafe') {
      locationSuggestions = [
        '분위기 좋은 독립 카페',
        '조용한 브런치 카페',
        '루프탑 카페',
      ];
      atmosphereType = 'casual';
      mealRecommendation = '가벼운 디저트와 음료';
      suggestedDuration = 90;
    } else if (input.meetingType == 'meal') {
      locationSuggestions = [
        '분위기 있는 레스토랑',
        '맛집으로 유명한 곳',
        '프라이빗한 다이닝',
      ];
      atmosphereType = 'romantic';
      mealRecommendation = '코스 요리 또는 인기 메뉴';
      suggestedDuration = 120;
    } else {
      locationSuggestions = [
        '미술관이나 전시회',
        '볼링이나 보드게임 카페',
        '산책하기 좋은 공원',
      ];
      atmosphereType = 'lively';
      mealRecommendation = '활동 후 가벼운 식사';
      suggestedDuration = 150;
    }
    
    // 프로필 기반 활동 아이디어
    activityIdeas = [];
    if (profile.detectedInterests.contains('art')) {
      activityIdeas.add('근처 갤러리 방문');
    }
    if (profile.detectedInterests.contains('coffee')) {
      activityIdeas.add('커피 투어');
    }
    activityIdeas.addAll([
      '가벼운 산책',
      '다음 만남 약속 정하기',
    ]);
    
    return DatePlanSuggestion(
      idealTiming: idealTiming,
      locationSuggestions: locationSuggestions,
      atmosphereType: atmosphereType,
      activityIdeas: activityIdeas,
      mealRecommendation: mealRecommendation,
      suggestedDuration: suggestedDuration,
    );
  }

  List<String> _generateDoList(InstagramProfileAnalysis profile) {
    final doList = [
      '시간 약속 정확히 지키기',
      '긍정적인 에너지로 대화하기',
      '상대방 이야기에 진심으로 경청하기',
      '자연스러운 스킨십은 상황 봐가며',
    ];
    
    if (profile.estimatedPersonality == 'introvert') {
      doList.add('조용하고 편안한 분위기 만들기');
    } else if (profile.estimatedPersonality == 'extrovert') {
      doList.add('활발하고 즐거운 분위기 만들기');
    }
    
    return doList;
  }

  List<String> _generateDontList(InstagramProfileAnalysis profile) {
    return [
      '과도한 자기 자랑 하지 않기',
      '부정적인 이야기 꺼내지 않기',
      '핸드폰 자주 보지 않기',
      '과거 연애 이야기 하지 않기',
      '너무 많은 질문 공세 하지 않기',
    ];
  }

  String _generateMotivationalMessage(int score) {
    if (score >= 85) {
      return '두 분의 궁합이 정말 좋습니다! 자신감을 가지고 자연스럽게 만남을 즐기세요. 좋은 인연이 될 가능성이 높아요!';
    } else if (score >= 70) {
      return '좋은 궁합입니다! 서로를 알아가는 시간을 충분히 가지면서 관계를 발전시켜보세요.';
    } else {
      return '첫 만남은 누구에게나 설레는 일입니다. 너무 부담 갖지 마시고 편안한 마음으로 임하세요!';
    }
  }

  String _generateLuckyCharm() {
    final charms = [
      '💝 분홍색 소품을 하나 착용하세요',
      '🌟 작은 향수를 뿌리고 가세요',
      '🍀 주머니에 네잎클로버를 넣어두세요',
      '✨ 거울을 보며 미소 연습을 하고 가세요',
      '💎 반짝이는 액세서리를 착용하세요',
    ];
    return charms[Random().nextInt(charms.length)];
  }

  String _getTimeString(String time) {
    switch (time) {
      case 'morning':
        return '아침 시간';
      case 'lunch':
        return '점심 시간';
      case 'evening':
        return '저녁 시간';
      case 'night':
        return '밤 시간';
      default:
        return time;
    }
  }
}