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
import '../../services/fortune_history_service.dart';
import '../../widgets/emotional_loading_checklist.dart';
import '../../widgets/profile_completion_dialog.dart';
import '../../core/utils/profile_validation.dart';
import 'fortune_story_viewer.dart';
import 'fortune_completion_page.dart';
import 'preview_screen.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../core/theme/toss_design_system.dart';

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
  Map<String, dynamic>? sajuAnalysisData; // 사주 분석 데이터 저장
  // Comprehensive fortune data from Edge Function  
  Map<String, dynamic>? metaData;
  Map<String, dynamic>? weatherSummaryData;
  Map<String, dynamic>? overallData;
  Map<String, dynamic>? categoriesData;
  Map<String, dynamic>? sajuInsightData;
  List<Map<String, dynamic>>? personalActionsData;
  Map<String, dynamic>? notificationData;
  Map<String, dynamic>? shareCardData;
  
  bool isLoadingFortune = true;
  bool _isLoadingProfile = false; // Prevent duplicate loading
  bool _hasViewedStoryToday = false; // 오늘 스토리를 이미 봤는지 확인
  bool _isReallyLoggedIn = false; // 실제 로그인 여부 (익명 아닌)
  bool _showPreviewScreen = false; // 프리뷰 화면 표시 여부
  bool _isInitializing = false; // 초기화 중복 방지
  
  // Pull-to-refresh를 위한 새로고침 함수 (하루 1회 제한)
  Future<void> _refreshFortuneData() async {
    try {
      // 마지막 새로고침 시간 확인 (하루 1회 제한)
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final lastRefreshDate = prefs.getString('last_refresh_date');

      if (lastRefreshDate == todayKey) {
        debugPrint('🔄 Pull-to-refresh 제한: 오늘 이미 새로고침 완료');
        return; // 오늘 이미 새로고침했으면 실행하지 않음
      }

      debugPrint('🔄 Pull-to-refresh initiated - clearing cache and loading fresh data');

      // 캐시 무효화
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await _cacheService.removeCachedFortune('daily', {'userId': userId});
        await _cacheService.removeCachedStorySegments('daily', {'userId': userId});
      }

      // Provider 상태 초기화
      ref.read(dailyFortuneProvider.notifier).reset();

      // 새로운 데이터 로드
      setState(() {
        isLoadingFortune = true;
        todaysFortune = null;
        storySegments = null;
        _hasViewedStoryToday = false; // 새로운 스토리 보기 위해 재설정
      });

      await _loadTodaysFortune();

      // 새로고침 날짜 저장
      await prefs.setString('last_refresh_date', todayKey);

      debugPrint('✅ Pull-to-refresh completed');
    } catch (e) {
      debugPrint('❌ Pull-to-refresh failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyViewed();
    _checkRealLoginStatus(); // 초기 로그인 상태 확인
    _initializeDataWithCacheCheck();

    // 인증 상태 변화 리스너 추가
    supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('🔐 [StoryHomeScreen] Auth state changed: ${data.event}');
      debugPrint('🔐 [StoryHomeScreen] Session exists: ${data.session != null}');
      debugPrint('🔐 [StoryHomeScreen] Current _showPreviewScreen: $_showPreviewScreen');
      debugPrint('🔐 [StoryHomeScreen] Is initializing: $_isInitializing');

      if ((data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.initialSession) && data.session != null) {
        debugPrint('🔐 [StoryHomeScreen] User signed in or session restored, updating login status');
        _checkRealLoginStatus();

        // PreviewScreen에서 로그인한 경우에만 자동으로 스토리 표시 (중복 초기화 방지)
        if (_showPreviewScreen && !_isInitializing) {
          debugPrint('🔐 [StoryHomeScreen] Hiding PreviewScreen and loading story');
          setState(() {
            _showPreviewScreen = false;
            isLoadingFortune = true;
            _isInitializing = true;
          });
          _initializeData().then((_) {
            if (mounted) {
              setState(() {
                _isInitializing = false;
              });
            }
          });
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        debugPrint('🔐 [StoryHomeScreen] User signed out');
        setState(() {
          _isReallyLoggedIn = false;
        });
      }
    });
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
  
  // 실제 로그인 여부 체크 (익명 인증이 아닌)
  void _checkRealLoginStatus() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // 익명 사용자가 아닌 경우 (이메일이나 OAuth 제공자가 있는 경우)
      final isAnonymous = user.isAnonymous;
      final hasEmail = user.email != null && user.email!.isNotEmpty;
      final hasProvider = user.appMetadata['providers']?.isNotEmpty == true;
      
      // 온보딩만 진행한 사용자 vs 실제 로그인한 사용자 구분
      final isRealLogin = !isAnonymous && (hasEmail || hasProvider);
      
      setState(() {
        _isReallyLoggedIn = isRealLogin;
      });
      
      debugPrint('🔐 Login status - isAnonymous: $isAnonymous, hasEmail: $hasEmail, hasProvider: $hasProvider, _isReallyLoggedIn: $_isReallyLoggedIn');
      debugPrint('🔐 User ID: ${user.id}, Email: ${user.email}');
      debugPrint('🔐 App metadata: ${user.appMetadata}');
      debugPrint('🔐 User metadata: ${user.userMetadata}');
    } else {
      setState(() {
        _isReallyLoggedIn = false;
      });
      debugPrint('🔐 No user session, not logged in');
    }
  }
  
  // 캐시 체크와 함께 데이터 초기화
  Future<void> _initializeDataWithCacheCheck() async {
    if (_isInitializing) {
      debugPrint('⚠️ Already initializing, skipping duplicate call');
      return;
    }

    try {
      setState(() {
        _isInitializing = true;
      });

      // 먼저 캐시가 있는지 확인
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final cachedFortuneData = await _cacheService.getCachedFortune('daily', {'userId': userId});
        final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});

        // 캐시된 데이터가 완전하면 로딩 상태를 false로 시작
        if (cachedFortuneData != null && cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
          debugPrint('🚀 Found complete cached data - starting without loading screen');

          final fortuneEntity = cachedFortuneData.toEntity();

          // 캐시 로딩 시에도 사용자 프로필 로드 필요
          await _loadUserProfile();

          setState(() {
            isLoadingFortune = false;
            todaysFortune = fortuneEntity;
            storySegments = cachedStorySegments;
            _isInitializing = false;
          });

          return; // 캐시 데이터로 완료, 추가 초기화 불필요
        }
      }

      // 캐시가 없는 경우에만 일반적인 초기화 진행
      await _initializeData();
    } catch (e) {
      debugPrint('❌ Error in cache check initialization: $e');
      // 에러가 발생하면 일반적인 초기화로 fallback
      await _initializeData();
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }
  
  Future<void> _initializeData() async {
    try {
      debugPrint('🚀 Starting data initialization');

      // 실제 로그인 여부 체크 (익명이 아닌)
      _checkRealLoginStatus();

      // 로그인된 사용자는 PreviewScreen을 절대 보면 안 됨
      if (_isReallyLoggedIn) {
        debugPrint('🔐 Logged in user detected - ensuring no PreviewScreen');
        setState(() {
          _showPreviewScreen = false;
        });

        // 로그인된 사용자가 이미 데이터를 가지고 있다면 로딩 상태를 즉시 해제
        if (userProfile != null && (todaysFortune != null || storySegments != null)) {
          debugPrint('⚡ Already have data for logged in user - skipping loading screen');
          setState(() {
            isLoadingFortune = false;
          });
          return; // 데이터가 이미 있으므로 추가 로딩 불필요
        }
      }
      
      // 사용자가 로그인하지 않은 경우 익명 인증
      if (supabase.auth.currentUser == null) {
        debugPrint('🔐 No user session, signing in anonymously...');
        try {
          await supabase.auth.signInAnonymously();
          debugPrint('✅ Anonymous session created: ${supabase.auth.currentUser?.id}');
        } catch (e) {
          debugPrint('⚠️ Anonymous sign-in failed: $e');
          // 익명 인증 실패해도 계속 진행 (Edge Function이 공개 API일 수도 있음)
        }
      } else {
        debugPrint('✅ User already authenticated: ${supabase.auth.currentUser?.id}');
      }
      
      // Load user profile first and wait for it to complete
      await _loadUserProfile();
      debugPrint('✅ User profile loaded, name: ${userProfile?.name}');
      
      // Then load weather and fortune (but fortune needs profile, so can't be parallel)
      await _loadWeatherInfo();
      debugPrint('✅ Weather loaded');
      
      await _loadTodaysFortune();
      debugPrint('✅ Fortune and story loaded');
      debugPrint('📈 Fortune: ${todaysFortune != null}');
      debugPrint('📈 Story segments: ${storySegments?.length ?? 0}');
      
      // 확실히 로딩 상태를 false로 설정
      if (mounted) {
        setState(() {
          isLoadingFortune = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _initializeData: $e');
      debugPrint('📝 Stack trace: $stackTrace');
      
      // 에러를 사용자에게 표시
      if (mounted) {
        setState(() {
          isLoadingFortune = false;
        });
        
        // 에러 다이얼로그 표시
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류 발생'),
            content: Text('운세를 불러오는 중 문제가 발생했습니다.\n\n$e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 다시 시도
                  _initializeData();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  /// 기존 사용자의 사주 계산 (백그라운드 실행)
  Future<void> _calculateSajuForExistingUser(String userId, String birthDate, String birthTime) async {
    try {
      debugPrint('🔮 기존 사용자 사주 계산 시작: $userId');
      
      final sajuResponse = await supabase.functions.invoke(
        'calculate-saju',
        body: {
          'birthDate': birthDate.split('T')[0],
          'birthTime': birthTime,
          'isLunar': false,
          'timezone': 'Asia/Seoul'
        },
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          debugPrint('⏱️ 기존 사용자 사주 계산 시간 초과');
          throw Exception('사주 계산 시간 초과 (45초)');
        },
      );
      
      debugPrint('✅ 기존 사용자 사주 계산 완료: ${sajuResponse.status}');
      if (sajuResponse.status == 200) {
        final sajuData = sajuResponse.data;
        if (sajuData['success'] == true) {
          debugPrint('✅ 기존 사용자 사주 데이터 저장 성공');
          // 사주 계산 플래그 업데이트
          await supabase.from('user_profiles').update({
            'saju_calculated': true,
            'updated_at': DateTime.now().toIso8601String()
          }).eq('id', userId);
          debugPrint('✅ 기존 사용자 사주 계산 플래그 업데이트 완료');
        } else {
          debugPrint('⚠️ 기존 사용자 사주 계산 응답 오류: ${sajuData['error']}');
        }
      }
    } catch (e) {
      debugPrint('⚠️ 기존 사용자 사주 계산 오류 (백그라운드): $e');
      // 백그라운드 작업이므로 UI에 오류 표시하지 않음
    }
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
          
          // Check if Saju calculation is needed
          final sajuCalculated = response['saju_calculated'] ?? false;
          final birthDate = response['birth_date'];
          final birthTime = response['birth_time'];
          
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
          
          // Auto-calculate Saju if not done yet and user has birth info
          if (!sajuCalculated && birthDate != null && birthTime != null) {
            debugPrint('🔮 사주 미계산 감지: 자동 계산 시작');
            _calculateSajuForExistingUser(userId, birthDate, birthTime);
          }
          
          // Check if profile has essential fields
          if (mounted) {
            _checkProfileCompletion(response);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoadingProfile = false;
    }
  }
  
  /// Check if profile has essential fields and show dialog if needed
  Future<void> _checkProfileCompletion(Map<String, dynamic> profile) async {
    // Only check for logged-in users, not guest mode
    if (!_isReallyLoggedIn) return;
    
    // Check if profile has essential fields
    if (!ProfileValidation.hasEssentialFields(profile)) {
      final missingFields = ProfileValidation.getMissingEssentialFields(profile);
      
      // Show profile completion dialog after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        await ProfileCompletionDialog.show(context, missingFields);
      }
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
      if (userId == null) {
        debugPrint('❌ No user ID found for fortune loading');
        return;
      }

      // 중복 호출 방지 - 이미 오늘의 운세가 로드되어 있으면 스킵
      if (todaysFortune != null && !isLoadingFortune) {
        debugPrint('✅ Today\'s fortune already loaded, skipping duplicate load');
        return;
      }

      debugPrint('🎯 Loading today\'s fortune for user: $userId');

      // 현재 날짜 키 생성 (CacheService와 동일한 로직)
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month}-${now.day}';

      debugPrint('📅 Current date key: $dateKey');

      // 1. 캐시된 운세와 스토리 모두 확인 (Provider 상태보다 우선)
      final cachedFortuneData = await _cacheService.getCachedFortune('daily', {'userId': userId});
      final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});

      debugPrint('📦 Cache check - fortune: ${cachedFortuneData != null}, story: ${cachedStorySegments != null && cachedStorySegments.isNotEmpty}');

      // 2. Provider 상태 우선 확인 (최신 데이터)
      final currentProviderState = ref.read(dailyFortuneProvider);
      final hasProviderFortune = currentProviderState.fortune != null && !currentProviderState.isLoading;

      debugPrint('📊 Provider state - hasFortune: $hasProviderFortune, isLoading: ${currentProviderState.isLoading}');
      
      // 3. Provider에 데이터가 있으면 Provider 우선 사용 (캐시보다 최신)
      if (hasProviderFortune) {
        final providerFortune = currentProviderState.fortune!;
        debugPrint('🚀 Using Provider data (latest) - score: ${providerFortune.overallScore}');

        // 중복 데이터 설정 방지 - 이미 같은 데이터가 있으면 스킵
        if (todaysFortune?.id == providerFortune.id &&
            todaysFortune?.overallScore == providerFortune.overallScore) {
          debugPrint('✅ Same Provider data already set, skipping duplicate');
          return;
        }

        setState(() {
          todaysFortune = providerFortune;
          isLoadingFortune = false;
        });

        // Provider 데이터가 있으면 스토리만 생성/확인
        if (cachedStorySegments != null && cachedStorySegments.isNotEmpty && storySegments == null) {
          debugPrint('✅ Using cached story segments');
          setState(() {
            storySegments = cachedStorySegments;
          });
        } else if (storySegments == null) {
          debugPrint('📝 Generating new story for Provider fortune');
          await _generateStory(providerFortune);
        }
        return;
      }
      
      // 4. Provider에 없으면 캐시 확인 (단, 유효한 데이터만)
      if (cachedFortuneData != null && cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
        final cachedFortune = cachedFortuneData.toEntity();

        // 디버그: 캐시 데이터 상세 정보 확인
        debugPrint('🔍 DEBUG - Cached data analysis:');
        debugPrint('  - Metadata: ${cachedFortuneData.metadata}');
        debugPrint('  - Mapped overallScore: ${cachedFortune.overallScore}');
        debugPrint('  - Metadata overallScore: ${cachedFortuneData.metadata?['overallScore']}');

        // 캐시된 운세에 유효한 점수가 있는지 확인
        if (cachedFortune.overallScore != null) {
          // 중복 데이터 설정 방지 - 이미 같은 캐시 데이터가 있으면 스킵
          if (todaysFortune?.id == cachedFortune.id &&
              todaysFortune?.overallScore == cachedFortune.overallScore &&
              storySegments != null) {
            debugPrint('✅ Same cached data already set, skipping duplicate');
            return;
          }

          debugPrint('✅ Using cached data as fallback - score: ${cachedFortune.overallScore}');

          setState(() {
            todaysFortune = cachedFortune;
            storySegments = cachedStorySegments;
            isLoadingFortune = false; // 로딩 화면 스킵
          });
          return; // 더 이상 처리할 필요 없음
        } else {
          debugPrint('⚠️ Cached fortune has invalid overallScore, will fetch fresh data');
        }
      }
      
      // 5. 캐시가 없거나 불완전한 경우에만 API 호출 및 로딩 상태 관리
      debugPrint('📡 Need to fetch fresh data from API');
      await _fetchFortuneFromAPI();
      
      // 스토리가 캐시되어 있으면 사용, 없으면 생성
      if (cachedStorySegments != null && cachedStorySegments.isNotEmpty && todaysFortune != null) {
        debugPrint('✅ Using cached story segments');
        setState(() {
          storySegments = cachedStorySegments;
          isLoadingFortune = false;
        });
      } else if (todaysFortune != null) {
        debugPrint('📝 Generating new story');
        await _generateStory(todaysFortune!);
        setState(() {
          isLoadingFortune = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading fortune: $e');
      // 에러를 다시 throw하여 상위에서 처리하도록 함
      rethrow;
    }
  }
  
  Future<void> _fetchFortuneFromAPI() async {
    try {
      debugPrint('📡 Loading fortune via Provider (handles caching automatically)...');
      final dailyFortuneNotifier = ref.read(dailyFortuneProvider.notifier);
      final today = DateTime.now();
      
      dailyFortuneNotifier.setDate(today);
      await dailyFortuneNotifier.loadFortune();
      
      final fortuneState = ref.read(dailyFortuneProvider);
      
      debugPrint('📡 Provider response - hasData: ${fortuneState.fortune != null}, isLoading: ${fortuneState.isLoading}, hasError: ${fortuneState.error != null}');
      
      if (fortuneState.fortune != null && !fortuneState.isLoading) {
        final fortune = fortuneState.fortune!;
        debugPrint('✅ Fortune loaded successfully - score: ${fortune.overallScore}, content length: ${fortune.content?.length ?? 0}');
        
        // 유효한 점수가 있는지 확인
        if (fortune.overallScore != null) {
          debugPrint('✅ Fortune has valid overallScore: ${fortune.overallScore}');
          
          // 캐시 삭제 로직 제거 - 같은 날의 캐시는 유지하여 재사용
          debugPrint('✅ New fortune loaded - keeping cache for future use');
          
          setState(() {
            todaysFortune = fortune;
          });
          
          // 일일 운세를 히스토리에 저장
          await _saveDailyFortuneToHistory(fortune);
          
          // Provider가 이미 캐싱을 처리하므로 여기서는 스토리만 생성
          await _generateStory(fortune);
        } else {
          debugPrint('⚠️ Fortune loaded but overallScore is null, retrying...');
          // 점수가 없는 운세는 무효하므로 다시 시도
          throw Exception('Fortune data incomplete - missing overallScore');
        }
      } else if (fortuneState.error != null) {
        debugPrint('❌ Fortune loading error: ${fortuneState.error}');
      }
    } catch (e) {
      debugPrint('❌ Error loading fortune via Provider: $e');
    }
  }
  
  /// 일일 운세를 히스토리에 저장
  Future<void> _saveDailyFortuneToHistory(fortune_entity.Fortune fortune) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ User not authenticated, skipping fortune history save');
        return;
      }

      final now = DateTime.now();
      final title = '${now.year}년 ${now.month}월 ${now.day}일 운세';
      
      // Fortune 엔티티에서 필요한 정보를 추출하여 요약 데이터 생성
      final summary = {
        'score': fortune.overallScore ?? 80,
        'content': fortune.content,
        'advice': fortune.advice ?? fortune.recommendations?.firstOrNull,
        'caution': fortune.caution ?? fortune.warnings?.firstOrNull,
        'summary': fortune.summary,
        'greeting': fortune.greeting,
        'luckyColor': fortune.luckyColor,
        'luckyNumber': fortune.luckyNumber,
        'luckyDirection': fortune.luckyDirection,
        'bestTime': fortune.bestTime,
      };

      // 상세 메타데이터
      final metadata = {
        'hexagonScores': fortune.hexagonScores,
        'scoreBreakdown': fortune.scoreBreakdown,
        'recommendations': fortune.recommendations,
        'warnings': fortune.warnings,
        'luckyItems': fortune.luckyItems,
        'detailedLuckyItems': fortune.detailedLuckyItems,
        'timeSpecificFortunes': fortune.timeSpecificFortunes,
        'birthYearFortunes': fortune.birthYearFortunes,
        'fiveElements': fortune.fiveElements,
        'specialTip': fortune.specialTip,
        'meta': fortune.meta,
        'weatherSummary': fortune.weatherSummary,
        'overall': fortune.overall,
        'categories': fortune.categories,
        'sajuInsight': fortune.sajuInsight,
        'personalActions': fortune.personalActions,
        'notification': fortune.notification,
        'shareCard': fortune.shareCard,
      };

      // 태그 생성
      final tags = <String>['일일', '${now.year}년${now.month}월'];
      final score = fortune.overallScore ?? 80;
      if (score >= 90) tags.add('최고운');
      else if (score >= 80) tags.add('대길');
      else if (score >= 70) tags.add('길');
      else if (score >= 60) tags.add('보통');
      else tags.add('주의');

      // FortuneHistoryService에 저장 (새로운 히스토리 테이블)
      final historyService = FortuneHistoryService();
      await historyService.saveFortuneResult(
        fortuneType: 'daily',
        title: title,
        summary: summary,
        fortuneData: fortune.toJson(), // 전체 운세 데이터
        metadata: metadata,
        tags: tags,
        score: fortune.overallScore,
      );

      debugPrint('✅ Daily fortune saved to history: $title');
    } catch (error) {
      debugPrint('❌ Error saving daily fortune to history: $error');
    }
  }
  
  Future<void> _generateStory(fortune_entity.Fortune fortune) async {
    try {
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
        // 사주 분석 데이터도 가져오기
        if (storyState.sajuAnalysis != null) {
          setState(() {
            sajuAnalysisData = storyState.sajuAnalysis;
          });
        }
        
        // 확장된 데이터 추출
        setState(() {
          metaData = storyState.meta;
          weatherSummaryData = storyState.weatherSummary;
          overallData = storyState.overall;
          categoriesData = storyState.categories;
          sajuInsightData = storyState.sajuInsight;
          personalActionsData = storyState.personalActions;
          notificationData = storyState.notification;
          shareCardData = storyState.shareCard;
        });
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
    } catch (e) {
      debugPrint('❌ Error generating story: $e');
      // 에러 발생시에도 기본 스토리 생성
      final userName = (userProfile?.name != null && userProfile!.name!.isNotEmpty) 
          ? userProfile!.name! 
          : '사용자';
      final fallbackSegments = _createDetailedStorySegments(userName, fortune);
      setState(() {
        storySegments = fallbackSegments;
      });
    }
  }
  
  // 상세한 10페이지 스토리 생성
  List<StorySegment> _createDetailedStorySegments(
    String userName,
    fortune_entity.Fortune fortune,
  ) {
    final now = DateTime.now();
    
    // 유효한 운세 데이터가 없으면 빈 세그먼트 반환하고 새로 로드 시도
    if (fortune.overallScore == null) {
      debugPrint('⚠️ Fortune overallScore is null, triggering fortune reload');
      // 비동기로 운세 다시 로드
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchFortuneFromAPI();
      });
      return [
        StorySegment(
          text: '운세를 불러오는 중...',
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
      ];
    }
    
    final score = fortune.overallScore!;
    List<StorySegment> segments = [];
    
    // 1. 인사 페이지
    segments.add(StorySegment(
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));
    
    // 2. 날짜와 날씨
    String weatherText = currentWeather != null 
        ? currentWeather!.emotionalDescription
        : '맑은 하늘';
    segments.add(StorySegment(
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));
    
    // 3. 오늘의 총평
    segments.add(StorySegment(
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
          text: _getFortuneText1(score),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
          text: _getFortuneText2(score),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      segments.add(StorySegment(
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
    
    // 네비게이션 바 표시 (FortuneCompletionPage에서도 설정하지만 안전장치)
    ref.read(navigationVisibilityProvider.notifier).show();
    
    // Use push instead of pushReplacement to avoid page-based route issues
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FortuneCompletionPage(
          fortune: todaysFortune,
          userName: userProfile?.name,
          userProfile: userProfile,
          sajuAnalysis: sajuAnalysisData,
          meta: metaData,
          weatherSummary: weatherSummaryData,
          overall: overallData,
          categories: categoriesData,
          sajuInsight: sajuInsightData,
          personalActions: personalActionsData,
          notification: notificationData,
          shareCard: shareCardData,
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
    debugPrint('🎨 Building StoryHomeScreen - isLoading: $isLoadingFortune, segments: ${storySegments?.length}, fortune: ${todaysFortune != null}, _isReallyLoggedIn: $_isReallyLoggedIn, _showPreviewScreen: $_showPreviewScreen');
    
    // 프리뷰 화면 표시 (로그인되지 않은 사용자만)
    if (_showPreviewScreen && !_isReallyLoggedIn) {
      return PreviewScreen(
        onLoginSuccess: () {
          // OAuth 로그인의 경우 auth state listener에서 처리됨
          // 여기서는 로딩 상태만 표시
          debugPrint('🔐 Login initiated from PreviewScreen');
          setState(() {
            isLoadingFortune = true;
          });
        },
        onContinueWithoutLogin: () {
          // 로그인 없이 보기
          setState(() {
            _showPreviewScreen = false;
          });
        },
      );
    }
    
    // 로딩 중 조건
    // - 로그인된 사용자: isLoadingFortune이 true일 때만 로딩 화면
    // - 미로그인 사용자: 운세 데이터가 없거나 로딩 중일 때 로딩 화면
    bool shouldShowLoading = _isReallyLoggedIn 
        ? isLoadingFortune 
        : (isLoadingFortune || storySegments == null || todaysFortune == null);
    
    debugPrint('📊 Render state check - isLoading: $isLoadingFortune, _isReallyLoggedIn: $_isReallyLoggedIn, shouldShowLoading: $shouldShowLoading');
    debugPrint('📊 Data state - fortune: ${todaysFortune != null}, segments: ${storySegments?.length ?? 0}, _hasViewedStoryToday: $_hasViewedStoryToday, _showPreviewScreen: $_showPreviewScreen');
    
    if (shouldShowLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark50
            : TossDesignSystem.white,
        body: EmotionalLoadingChecklist(
          isLoggedIn: _isReallyLoggedIn,
          isApiComplete: !isLoadingFortune && (todaysFortune != null || storySegments != null),
          onComplete: () {
            debugPrint('🔔 EmotionalLoadingChecklist onComplete called for logged in user');
            debugPrint('📈 Current state - isLoading: $isLoadingFortune, segments: ${storySegments?.length}, fortune: ${todaysFortune != null}');
            // 로그인된 사용자는 운세 데이터가 있으면 바로 스토리로, 없으면 기본 운세로
            // 현재 로딩이 끝났다는 것은 이미 운세 데이터 처리가 완료되었다는 의미
            // 로딩 완료 시 자동으로 화면이 업데이트되므로 별도 처리 불필요
          },
          onPreviewComplete: () {
            debugPrint('🔔 EmotionalLoadingChecklist onPreviewComplete called');
            debugPrint('🔔 Current login status: _isReallyLoggedIn = $_isReallyLoggedIn');
            
            // 로그인된 사용자는 절대 PreviewScreen을 보면 안 됨
            if (!_isReallyLoggedIn) {
              debugPrint('🔔 Guest user - showing PreviewScreen');
              setState(() {
                _showPreviewScreen = true;
              });
            } else {
              debugPrint('🔔 Logged in user - skipping PreviewScreen');
              // 로그인된 사용자는 바로 운세 로딩 완료로 처리
            }
          },
        ),
      );
    }
    
    // 오늘 이미 스토리를 봤다면 바로 완료 페이지 표시
    if (_hasViewedStoryToday) {
      // 네비게이션 바 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationVisibilityProvider.notifier).show();
      });

      return FortuneCompletionPage(
        fortune: todaysFortune,
        userName: userProfile?.name,
        userProfile: userProfile,
        sajuAnalysis: sajuAnalysisData,
        meta: metaData,
        weatherSummary: weatherSummaryData,
        overall: overallData,
        categories: categoriesData,
        sajuInsight: sajuInsightData,
        personalActions: personalActionsData,
        notification: notificationData,
        shareCard: shareCardData,
        onReplay: () {
          // 다시 스토리 보기
          setState(() {
            _hasViewedStoryToday = false;
          });
        },
      );
    }
    
    // 스토리 뷰어 또는 기본 화면
    if (storySegments != null && storySegments!.isNotEmpty) {
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
    } else {
      // 운세 데이터가 없는 경우 기본 완료 화면 표시
      // 네비게이션 바 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationVisibilityProvider.notifier).show();
      });
      
      return FortuneCompletionPage(
        fortune: todaysFortune,
        userName: userProfile?.name,
        userProfile: userProfile,
        sajuAnalysis: sajuAnalysisData,
        meta: metaData,
        weatherSummary: weatherSummaryData,
        overall: overallData,
        categories: categoriesData,
        sajuInsight: sajuInsightData,
        personalActions: personalActionsData,
        notification: notificationData,
        shareCard: shareCardData,
        onReplay: () {
          // 다시 시도
          _initializeData();
        },
      );
    }
  }
}