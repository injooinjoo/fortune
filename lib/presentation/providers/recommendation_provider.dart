import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import 'providers.dart';

// 추천 운세 모델
class RecommendedFortune {
  final String id;
  final String title;
  final String description;
  final String route;
  final String reason; // 추천 이유
  final double relevanceScore; // 관련성 점수
  
  const RecommendedFortune({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.reason,
    required this.relevanceScore});
}

// 추천 운세 프로바이더
final recommendedFortunesProvider = FutureProvider<List<RecommendedFortune>>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  final supabase = ref.watch(supabaseProvider);
  
  // 사용자 프로필 가져오기
  UserProfile? userProfile;
  final userId = supabase.auth.currentUser?.id;
  if (userId != null) {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response != null) {
      userProfile = UserProfile(
        id: response['id'],
      email: response['email'] ?? supabase.auth.currentUser?.email ?? '',
        name: response['name'] ?? '',
      birthdate: response['birth_date'] != null 
            ? DateTime.tryParse(response['birth_date'])
            : null,
        birthTime: response['birth_time'],
      isLunar: response['is_lunar'],
        gender: response['gender'],
      mbti: response['mbti'],
      bloodType: response['blood_type'],
      zodiacSign: response['zodiac_sign'],
      zodiacAnimal: response['chinese_zodiac'],
      onboardingCompleted: response['onboarding_completed'],
        isPremium: response['is_premium'],
      premiumExpiry: response['premium_expiry'] != null
            ? DateTime.tryParse(response['premium_expiry'])
            : null,
        tokenBalance: response['token_balance'],
        preferences: response['preferences'],
        createdAt: response['created_at'] != null 
            ? DateTime.parse(response['created_at'])
            : DateTime.now(),
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : DateTime.now());
    }
  }
  
  // 최근 방문한 운세 가져오기
  final recentFortunes = await storageService.getRecentFortunes();
  
  // 추천 알고리즘
  final recommendations = <RecommendedFortune>[];
  
  // 1. 사용자 프로필 기반 추천
  if (userProfile != null) {
    // MBTI 기반 추천
    if (userProfile.mbti != null && userProfile.mbti!.isNotEmpty) {
      recommendations.add(RecommendedFortune(
        id: 'mbti',
        title: 'MBTI 주간 운세',
        description: '${userProfile.mbti} 유형에 맞는 조언',
        route: '/fortune/mbti',
        reason: '${userProfile.mbti} 성격 유형 맞춤',
        relevanceScore: 0.95));
    }
    
    // 띠 기반 추천
    if (userProfile.zodiacAnimal != null && userProfile.zodiacAnimal!.isNotEmpty) {
      recommendations.add(RecommendedFortune(
        id: 'zodiac-animal',
        title: '띠 운세',
        description: '${userProfile.zodiacAnimal}띠의 이달 운세',
        route: '/fortune/zodiac-animal',
        reason: '${userProfile.zodiacAnimal}띠 맞춤',
        relevanceScore: 0.9));
    }
    
    // 별자리 기반 추천
    if (userProfile.zodiacSign != null && userProfile.zodiacSign!.isNotEmpty) {
      recommendations.add(RecommendedFortune(
        id: 'zodiac',
        title: '별자리 월간 운세',
        description: '${userProfile.zodiacSign}자리의 흐름',
        route: '/fortune/zodiac',
        reason: '${userProfile.zodiacSign}자리 맞춤',
        relevanceScore: 0.85));
    }
  }
  
  // 2. 최근 방문 기록 기반 추천
  final visitedCategories = <String>{};
  for (final fortune in recentFortunes) {
    final path = fortune['path'] as String;
    if (path.contains('love') || path.contains('marriage') || path.contains('compatibility')) {
      visitedCategories.add('love');
    } else if (path.contains('career') || path.contains('business')) {
      visitedCategories.add('career');
    } else if (path.contains('wealth') || path.contains('money')) {
      visitedCategories.add('wealth');
    }
  }
  
  // 연애 관련 방문이 많으면 연애운 추천
  if (visitedCategories.contains('love') && !recommendations.any((r) => r.id == 'chemistry')) {
    recommendations.add(RecommendedFortune(
      id: 'chemistry',
      title: '케미 운세',
      description: '상대방과의 특별한 연결',
      route: '/fortune/chemistry',
        reason: '연애 운세에 관심',
        relevanceScore: 0.8));
  }
  
  // 직업 관련 방문이 많으면 직업운 추천
  if (visitedCategories.contains('career') && !recommendations.any((r) => r.id == 'lucky-job')) {
    recommendations.add(RecommendedFortune(
      id: 'lucky-job',
      title: '천직 운세',
      description: '나에게 맞는 직업 찾기',
      route: '/fortune/lucky-job',
        reason: '직업 운세에 관심',
        relevanceScore: 0.75));
  }
  
  // 3. 시즌/트렌드 기반 추천
  final now = DateTime.now();
  
  // 새해 시즌 (12월 ~ 1월)
  if (now.month == 12 || now.month == 1) {
    recommendations.add(RecommendedFortune(
      id: 'new-year',
      title: '신년 운세',
      description: '새해의 전체적인 흐름',
      route: '/fortune/yearly',
        reason: '새해 특별 운세',
        relevanceScore: 0.7));
  }
  
  // 4. 인기 운세 추가 (추천이 부족한 경우)
  if (recommendations.length < 3) {
    final popularFortunes = [
      RecommendedFortune(
        id: 'saju',
        title: '사주팔자',
        description: '정통 사주 풀이',
        route: '/fortune/saju',
        reason: '인기 운세',
        relevanceScore: 0.6),
      RecommendedFortune(
        id: 'love',
        title: '연애운',
        description: '사랑과 인연의 흐름',
        route: '/fortune/love',
        reason: '인기 운세',
        relevanceScore: 0.6),
      RecommendedFortune(
        id: 'wealth',
        title: '금전운',
        description: '재물과 투자의 운',
        route: '/fortune/wealth',
        reason: '인기 운세',
        relevanceScore: 0.6)];
    
    for (final fortune in popularFortunes) {
      if (!recommendations.any((r) => r.id == fortune.id) && recommendations.length < 5) {
        recommendations.add(fortune);
      }
    }
  }
  
  // 관련성 점수로 정렬하고 상위 3개 반환
  recommendations.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  return recommendations.take(3).toList();
});