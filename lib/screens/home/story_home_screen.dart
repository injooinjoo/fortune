import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../presentation/providers/fortune_provider.dart';
import '../../presentation/providers/fortune_story_provider.dart';
import '../../services/cache_service.dart';
import '../../models/fortune_model.dart';
import '../../services/weather_service.dart';
import '../../widgets/emotional_loading_checklist.dart';
import 'fortune_story_viewer.dart';
import 'fortune_completion_page.dart';

/// 새로운 스토리 중심 홈 화면
class StoryHomeScreen extends ConsumerStatefulWidget {
  const StoryHomeScreen({super.key});

  @override
  ConsumerState<StoryHomeScreen> createState() => _StoryHomeScreenState();
}

class _StoryHomeScreenState extends ConsumerState<StoryHomeScreen> {
  final supabase = Supabase.instance.client;
  final _cacheService = CacheService();
  
  UserProfile? userProfile;
  fortune_entity.Fortune? todaysFortune;
  WeatherInfo? currentWeather;
  List<StorySegment>? storySegments;
  bool isLoadingFortune = true;
  bool _isLoadingProfile = false; // Prevent duplicate loading
  bool _hasViewedStoryToday = false; // 오늘 스토리를 이미 봤는지 확인
  
  @override
  void initState() {
    super.initState();
    _checkIfAlreadyViewed();
    _initializeData();
  }
  
  // 오늘 이미 스토리를 봤는지 확인
  Future<void> _checkIfAlreadyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final lastViewedDate = prefs.getString('last_fortune_viewed_date');
      
      if (lastViewedDate == todayKey) {
        setState(() {
          _hasViewedStoryToday = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking viewed status: $e');
    }
  }
  
  // 스토리 본 것을 기록
  Future<void> _markAsViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      await prefs.setString('last_fortune_viewed_date', todayKey);
      setState(() {
        _hasViewedStoryToday = true;
      });
    } catch (e) {
      debugPrint('Error marking as viewed: $e');
    }
  }
  
  Future<void> _initializeData() async {
    // Load user profile first and wait for it to complete
    await _loadUserProfile();
    debugPrint('User profile loaded, name: ${userProfile?.name}');
    // Then load weather and fortune (but fortune needs profile, so can't be parallel)
    await _loadWeatherInfo();
    await _loadTodaysFortune();
  }
  
  Future<void> _loadUserProfile() async {
    // Prevent duplicate loading
    if (_isLoadingProfile) {
      debugPrint('⏳ Profile already loading, skipping duplicate request');
      return;
    }
    
    _isLoadingProfile = true;
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (response != null) {
          debugPrint('✅ User profile loaded: name=${response['name']}');
          setState(() {
            userProfile = UserProfile(
              id: response['id'],
              email: response['email'] ?? supabase.auth.currentUser?.email ?? '',
              name: response['name'] ?? '',
              birthdate: response['birth_date'] != null 
                  ? DateTime.tryParse(response['birth_date']) 
                  : null,
              birthTime: response['birth_time'],
              isLunar: response['is_lunar'] ?? false,  // Handle is_lunar safely
              gender: response['gender'],
              mbti: response['mbti'],
              bloodType: response['blood_type'],
              zodiacSign: response['zodiac_sign'],
              zodiacAnimal: response['chinese_zodiac'],
              onboardingCompleted: response['onboarding_completed'] ?? false,
              isPremium: response['is_premium'] ?? false,
              premiumExpiry: response['premium_expiry'] != null
                  ? DateTime.tryParse(response['premium_expiry'])
                  : null,
              tokenBalance: response['token_balance'] ?? 0,
              preferences: response['preferences'],
              createdAt: response['created_at'] != null 
                  ? DateTime.parse(response['created_at'])
                  : DateTime.now(),
              updatedAt: response['updated_at'] != null
                  ? DateTime.parse(response['updated_at']) 
                  : DateTime.now()
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoadingProfile = false;
    }
  }
  
  Future<void> _loadWeatherInfo() async {
    try {
      final weather = await WeatherService.getCurrentWeather();
      setState(() {
        currentWeather = weather;
      });
    } catch (e) {
      debugPrint('Failed to load weather: $e');
    }
  }
  
  Future<void> _loadTodaysFortune() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // 1. 캐시에서 운세와 스토리 확인
      final cachedFortuneData = await _cacheService.getCachedFortune('daily', {'userId': userId});
      final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
      
      // 캐시된 운세와 스토리가 모두 있으면 API 호출 없이 사용
      if (cachedFortuneData != null && cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
        debugPrint('✅ Using fully cached data - no API calls needed');
        setState(() {
          todaysFortune = cachedFortuneData.toEntity();
          storySegments = cachedStorySegments;
          isLoadingFortune = false;
        });
        return; // API 호출 없이 종료
      }
      
      // 캐시된 운세만 있고 스토리가 없으면
      if (cachedFortuneData != null) {
        debugPrint('⚠️ Fortune cached but no story - generating story only');
        final fortuneEntity = cachedFortuneData.toEntity();
        setState(() {
          todaysFortune = fortuneEntity;
        });
        
        // 스토리만 생성 (API 호출 없음)
        await _generateStory(fortuneEntity);
        setState(() {
          isLoadingFortune = false;
        });
        return;
      }
      
      // 캐시가 전혀 없을 때만 API 호출
      debugPrint('❌ No cache found - fetching from API');
      await _fetchFortuneFromAPI();
      
      setState(() {
        isLoadingFortune = false;
      });
    } catch (e) {
      debugPrint('Error loading fortune: $e');
      setState(() {
        isLoadingFortune = false;
      });
    }
  }
  
  Future<void> _fetchFortuneFromAPI() async {
    try {
      final dailyFortuneNotifier = ref.read(dailyFortuneProvider.notifier);
      final today = DateTime.now();
      
      dailyFortuneNotifier.setDate(today);
      await dailyFortuneNotifier.loadFortune();
      
      final fortuneState = ref.read(dailyFortuneProvider);
      
      if (fortuneState.fortune != null && !fortuneState.isLoading) {
        final fortune = fortuneState.fortune!;
        setState(() {
          todaysFortune = fortune;
        });
        
        // 캐시에 저장
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await _cacheService.cacheFortune(
            'daily',
            {'userId': userId},
            FortuneModel.fromEntity(fortune)
          );
        }
        
        await _generateStory(fortune);
      }
    } catch (e) {
      debugPrint('Error fetching fortune from API: $e');
    }
  }
  
  Future<void> _generateStory(fortune_entity.Fortune fortune) async {
    // Ensure we have the user profile loaded
    if (userProfile == null || userProfile!.name == null || userProfile!.name!.isEmpty) {
      await _loadUserProfile();
    }
    
    // Use the actual name from userProfile, fallback to '사용자' only if really empty
    final userName = (userProfile?.name != null && userProfile!.name!.isNotEmpty) 
        ? userProfile!.name! 
        : '사용자';
    
    debugPrint('🎯 Generating story with userName: "$userName" (profile name: "${userProfile?.name}")');
    
    // GPT로 스토리 생성 (사주 정보 포함)
    final storyNotifier = ref.read(fortuneStoryProvider.notifier);
    await storyNotifier.generateFortuneStory(
      userName: userName,
      fortune: fortune,
      userProfile: userProfile,
    );
    
    final storyState = ref.read(fortuneStoryProvider);
    List<StorySegment>? generatedSegments;
    
    if (storyState.segments != null) {
      generatedSegments = storyState.segments;
    } else {
      // GPT 실패시 기본 스토리 생성
      generatedSegments = _createDetailedStorySegments(userName, fortune);
    }
    
    if (generatedSegments != null) {
      setState(() {
        storySegments = generatedSegments;
      });
      
      // 생성된 스토리를 캐시에 저장
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await _cacheService.cacheStorySegments(
          'daily',
          {'userId': userId},
          generatedSegments,
        );
        debugPrint('Story segments cached successfully');
      }
    }
  }
  
  // 상세한 10페이지 스토리 생성
  List<StorySegment> _createDetailedStorySegments(
    String userName,
    fortune_entity.Fortune fortune,
  ) {
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];
    
    // 1. 인사 페이지
    segments.add(StorySegment(
      subtitle: '인사',
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));
    
    // 2. 날짜와 날씨
    String weatherText = currentWeather != null 
        ? currentWeather!.emotionalDescription
        : '맑은 하늘';
    segments.add(StorySegment(
      subtitle: '오늘은',
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));
    
    // 3. 오늘의 총평
    segments.add(StorySegment(
      subtitle: '오늘의 총평',
      text: _getEnergyDescription(score),
      fontSize: 26,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));
    
    // 4-6. 운세 상세 (3페이지에 걸쳐)
    if (fortune.content != null && fortune.content!.isNotEmpty) {
      final sentences = _splitIntoSentences(fortune.content!);
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
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    } else {
      // 기본 운세 텍스트
      segments.add(StorySegment(
        subtitle: '운세 이야기',
        text: _getFortuneText1(score),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
        subtitle: '오전 운세',
        text: _getFortuneText2(score),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
        subtitle: '오후 운세',
        text: _getFortuneText3(score),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }
    
    // 7. 오늘의 주의사항
    String cautionText = fortune.metadata?['caution'] ?? _getCautionByScore(score);
    segments.add(StorySegment(
      subtitle: '⚠️ 주의',
      text: cautionText,
      fontSize: 22,
      fontWeight: FontWeight.w300,
    ));
    
    // 8. 행운의 요소들
    String luckyText = '';
    if (fortune.luckyItems != null) {
      if (fortune.luckyItems!['color'] != null) {
        luckyText += '오늘의 색: ${_getColorName(fortune.luckyItems!['color'])}\n';
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
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));
    
    // 9. 오늘의 조언
    String adviceText = fortune.metadata?['advice'] ?? _getAdviceByScore(score);
    segments.add(StorySegment(
      subtitle: '💡 조언',
      text: adviceText,
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));
    
    // 10. 마무리 메시지
    segments.add(StorySegment(
      subtitle: '마무리',
      text: '좋은 하루 되세요',
      fontSize: 28,
      fontWeight: FontWeight.w300,
      emoji: '✨',
    ));
    
    return segments;
  }
  
  // 문장 분리 헬퍼
  List<String> _splitIntoSentences(String text) {
    // 마침표, 느낌표, 물음표로 문장 분리
    final regex = RegExp(r'[.!?]+');
    return text.split(regex)
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim() + '.')
        .toList();
  }
  
  // 점수별 에너지 설명
  String _getEnergyDescription(int score) {
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
  
  // 운세 텍스트 (3개 페이지)
  String _getFortuneText1(int score) {
    if (score >= 80) {
      return '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다.\n\n용기를 내어\n도전해보세요.';
    } else if (score >= 60) {
      return '평범해 보이는\n오늘 하루지만\n\n작은 것에서\n큰 의미를\n발견하게 될 거예요.';
    } else {
      return '조금 힘든 하루가\n될 수 있지만\n\n이 또한\n성장의 과정입니다.';
    }
  }
  
  String _getFortuneText2(int score) {
    if (score >= 80) {
      return '주변 사람들과의\n관계에서\n좋은 소식이\n들려올 것입니다.\n\n마음을 열고\n소통해보세요.';
    } else if (score >= 60) {
      return '일상 속에서\n예상치 못한\n즐거움을\n발견하게 됩니다.\n\n긍정적인 마음을\n유지하세요.';
    } else {
      return '혼자만의 시간이\n필요한 날입니다.\n\n자신을 돌보는\n시간을 가져보세요.';
    }
  }
  
  String _getFortuneText3(int score) {
    if (score >= 80) {
      return '오늘 내린 결정이\n미래에 큰\n영향을 미칠 것입니다.\n\n자신감을 가지고\n앞으로 나아가세요.';
    } else if (score >= 60) {
      return '차근차근\n계획을 세우고\n실행한다면\n\n원하는 결과를\n얻을 수 있습니다.';
    } else {
      return '잠시 멈춰서\n생각해볼 시간입니다.\n\n급하게 서두르지\n마세요.';
    }
  }
  
  // 점수별 조언과 주의사항
  String _getAdviceByScore(int score) {
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
  
  String _getCautionByScore(int score) {
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
  
  String _getWeekdayKorean(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }
  
  String _getColorName(dynamic color) {
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
  
  // 완료 페이지 표시
  void _showCompletionPage() {
    // 스토리를 봤다고 기록
    _markAsViewed();
    
    // Use push instead of pushReplacement to avoid page-based route issues
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FortuneCompletionPage(
          fortune: todaysFortune,
          userName: userProfile?.name,
          onReplay: () {
            // 다시 스토리 보기 - pop back to story screen
            Navigator.of(context).pop();
            // Reset the story viewer state
            setState(() {
              _hasViewedStoryToday = false;
            });
          },
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (isLoadingFortune || storySegments == null || todaysFortune == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: EmotionalLoadingChecklist(
          onComplete: () {
            // 로딩 완료 시 자동으로 스토리 뷰어로 전환됨
          },
        ),
      );
    }
    
    // 오늘 이미 스토리를 봤다면 바로 완료 페이지 표시
    if (_hasViewedStoryToday) {
      return FortuneCompletionPage(
        fortune: todaysFortune,
        userName: userProfile?.name,
        onReplay: () {
          // 다시 스토리 보기
          setState(() {
            _hasViewedStoryToday = false;
          });
        },
      );
    }
    
    // 스토리 뷰어
    return FortuneStoryViewer(
      segments: storySegments!,
      userName: userProfile?.name,
      onComplete: () {
        // 완료 화면으로 이동
        _showCompletionPage();
      },
      onSkip: () {
        // 건너뛰기 시에도 완료 화면으로
        _showCompletionPage();
      },
    );
  }
}