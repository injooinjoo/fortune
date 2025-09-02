/// 소개팅 인스타그램 분석 모델
class BlindDateInstagramInput {
  // Step 1: 인스타그램 정보
  final String partnerInstagramUrl;
  final String? myInstagramUrl;
  final DateTime meetingDate;
  final String meetingTime; // morning, lunch, evening, night
  final String meetingType; // cafe, meal, activity
  
  // Step 2: 추가 정보
  final List<String> myInterests;
  final String mainCuriosity; // personality, conversation, compatibility, firstImpression
  final String? specialRequest;
  
  BlindDateInstagramInput({
    required this.partnerInstagramUrl,
    this.myInstagramUrl,
    required this.meetingDate,
    required this.meetingTime,
    required this.meetingType,
    required this.myInterests,
    required this.mainCuriosity,
    this.specialRequest,
  });
}

/// 인스타그램 프로필 분석 결과
class InstagramProfileAnalysis {
  final String profileImageUrl;
  final String username;
  final int followerCount;
  final int followingCount;
  final int postCount;
  
  // AI 분석 결과
  final String fashionStyle; // casual, formal, street, minimal, trendy
  final String estimatedPersonality; // extrovert, introvert, ambivert
  final List<String> detectedInterests; // travel, food, fitness, art, music, etc.
  final String lifestyle; // workaholic, balanced, social, homebody
  final String ageRange; // 20-25, 25-30, 30-35, etc.
  
  // 게시물 분석
  final List<String> frequentLocations;
  final List<String> hashtagTrends;
  final String postingFrequency; // daily, weekly, monthly, rare
  final String contentType; // selfie, food, travel, lifestyle, mixed
  
  InstagramProfileAnalysis({
    required this.profileImageUrl,
    required this.username,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.fashionStyle,
    required this.estimatedPersonality,
    required this.detectedInterests,
    required this.lifestyle,
    required this.ageRange,
    required this.frequentLocations,
    required this.hashtagTrends,
    required this.postingFrequency,
    required this.contentType,
  });
}

/// 소개팅 코칭 결과
class BlindDateCoachingResult {
  // 매칭 분석
  final int compatibilityScore; // 0-100
  final String compatibilityLevel; // excellent, good, moderate, challenging
  final List<String> commonInterests;
  final List<String> complementaryTraits;
  
  // 첫인상 전략
  final FirstImpressionStrategy firstImpression;
  
  // 대화 가이드
  final ConversationGuide conversationGuide;
  
  // 스타일링 추천
  final StylingRecommendation styling;
  
  // 데이트 플랜
  final DatePlanSuggestion datePlan;
  
  // 주의사항
  final List<String> doList;
  final List<String> dontList;
  
  // 특별 메시지
  final String motivationalMessage;
  final String luckyCharm;
  
  BlindDateCoachingResult({
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.commonInterests,
    required this.complementaryTraits,
    required this.firstImpression,
    required this.conversationGuide,
    required this.styling,
    required this.datePlan,
    required this.doList,
    required this.dontList,
    required this.motivationalMessage,
    required this.luckyCharm,
  });
}

/// 첫인상 전략
class FirstImpressionStrategy {
  final String approachStyle; // warm, professional, playful, mysterious
  final String openingLine;
  final List<String> bodyLanguageTips;
  final String energyLevel; // calm, moderate, energetic
  final String smileIntensity; // subtle, natural, bright
  
  FirstImpressionStrategy({
    required this.approachStyle,
    required this.openingLine,
    required this.bodyLanguageTips,
    required this.energyLevel,
    required this.smileIntensity,
  });
}

/// 대화 가이드
class ConversationGuide {
  final List<String> iceBreakers; // 5개의 아이스브레이킹 질문
  final List<String> recommendedTopics; // 추천 대화 주제
  final List<String> avoidTopics; // 피해야 할 주제
  final String conversationStyle; // listener, balanced, storyteller
  final List<String> interestingQuestions; // 흥미로운 질문들
  final String humorLevel; // minimal, moderate, frequent
  
  ConversationGuide({
    required this.iceBreakers,
    required this.recommendedTopics,
    required this.avoidTopics,
    required this.conversationStyle,
    required this.interestingQuestions,
    required this.humorLevel,
  });
}

/// 스타일링 추천
class StylingRecommendation {
  final String recommendedStyle; // 추천 스타일 설명
  final List<String> colorSuggestions; // 추천 색상
  final String dressCode; // casual, smart casual, business casual, formal
  final List<String> avoidItems; // 피해야 할 아이템
  final String accessoryTips; // 액세서리 팁
  final String groomingAdvice; // 그루밍 조언
  
  StylingRecommendation({
    required this.recommendedStyle,
    required this.colorSuggestions,
    required this.dressCode,
    required this.avoidItems,
    required this.accessoryTips,
    required this.groomingAdvice,
  });
}

/// 데이트 플랜 제안
class DatePlanSuggestion {
  final String idealTiming; // 최적의 시간대
  final List<String> locationSuggestions; // 추천 장소
  final String atmosphereType; // quiet, lively, romantic, casual
  final List<String> activityIdeas; // 활동 아이디어
  final String mealRecommendation; // 식사 추천
  final int suggestedDuration; // 권장 시간 (분)
  
  DatePlanSuggestion({
    required this.idealTiming,
    required this.locationSuggestions,
    required this.atmosphereType,
    required this.activityIdeas,
    required this.mealRecommendation,
    required this.suggestedDuration,
  });
}

/// 관심사 카드
class InterestCard {
  final String id;
  final String title;
  final String emoji;
  final String description;
  
  const InterestCard({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

/// 미리 정의된 관심사
const List<InterestCard> interestCards = [
  InterestCard(
    id: 'travel',
    title: '여행',
    emoji: '✈️',
    description: '새로운 곳을 탐험하는 것을 좋아해요',
  ),
  InterestCard(
    id: 'food',
    title: '맛집',
    emoji: '🍽️',
    description: '맛있는 음식을 찾아다녀요',
  ),
  InterestCard(
    id: 'fitness',
    title: '운동',
    emoji: '💪',
    description: '건강한 라이프스타일을 추구해요',
  ),
  InterestCard(
    id: 'art',
    title: '예술',
    emoji: '🎨',
    description: '전시회, 공연 등 문화생활을 즐겨요',
  ),
  InterestCard(
    id: 'music',
    title: '음악',
    emoji: '🎵',
    description: '음악 감상이나 공연을 좋아해요',
  ),
  InterestCard(
    id: 'reading',
    title: '독서',
    emoji: '📚',
    description: '책 읽는 것을 좋아해요',
  ),
  InterestCard(
    id: 'movie',
    title: '영화',
    emoji: '🎬',
    description: '영화나 드라마 보는 것을 즐겨요',
  ),
  InterestCard(
    id: 'game',
    title: '게임',
    emoji: '🎮',
    description: '게임을 즐겨해요',
  ),
  InterestCard(
    id: 'pet',
    title: '반려동물',
    emoji: '🐾',
    description: '동물을 사랑해요',
  ),
  InterestCard(
    id: 'fashion',
    title: '패션',
    emoji: '👗',
    description: '패션과 스타일에 관심이 많아요',
  ),
];

/// 궁금한 점 카드
class CuriosityCard {
  final String id;
  final String title;
  final String icon;
  final String description;
  
  const CuriosityCard({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}

const List<CuriosityCard> curiosityCards = [
  CuriosityCard(
    id: 'personality',
    title: '성격 분석',
    icon: '🧠',
    description: '상대방은 어떤 성격일까?',
  ),
  CuriosityCard(
    id: 'conversation',
    title: '대화 전략',
    icon: '💬',
    description: '무슨 얘기를 하면 좋을까?',
  ),
  CuriosityCard(
    id: 'compatibility',
    title: '궁합 분석',
    icon: '💕',
    description: '우리 잘 맞을까?',
  ),
  CuriosityCard(
    id: 'firstImpression',
    title: '첫인상 전략',
    icon: '✨',
    description: '좋은 첫인상을 남기려면?',
  ),
];