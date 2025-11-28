import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/fortune.dart' as fortune_entity;
import '../../../domain/entities/user_profile.dart';
import '../../../presentation/providers/fortune_provider.dart';
import '../../../presentation/providers/fortune_story_provider.dart';
import '../../../services/cache_service.dart';
import '../../../services/weather_service.dart';
import '../../../services/fortune_history_service.dart';
import '../../../services/user_statistics_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/emotional_loading_checklist.dart';
import '../../../widgets/profile_completion_dialog.dart';
import '../../../core/utils/profile_validation.dart';
import '../fortune_story_viewer.dart';
import '../fortune_swipe_page.dart';
import '../preview_screen.dart';
import '../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../core/theme/toss_design_system.dart';

import 'story_helpers.dart';

/// 새로운 스토리 중심 홈 화면
class StoryHomeScreen extends ConsumerStatefulWidget {
  const StoryHomeScreen({super.key});

  @override
  ConsumerState<StoryHomeScreen> createState() => _StoryHomeScreenState();
}

class _StoryHomeScreenState extends ConsumerState<StoryHomeScreen> with WidgetsBindingObserver {
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

  bool isLoadingFortune = true; // 초기값은 true이지만 initState에서 캐시 확인 후 조정
  bool _isLoadingProfile = false; // Prevent duplicate loading
  bool _hasViewedStoryToday = false; // 오늘 스토리를 이미 봤는지 확인
  bool _isReallyLoggedIn = false; // 실제 로그인 여부 (익명 아닌)
  bool _showPreviewScreen = false; // 프리뷰 화면 표시 여부
  bool _isInitializing = false; // 초기화 중복 방지
  bool _hasCachedData = false; // 캐시 데이터 존재 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfAlreadyViewed();
    _checkRealLoginStatus(); // 초기 로그인 상태 확인
    _loadWeatherInfo(); // 날씨는 항상 로드
    _quickCacheCheck(); // 캐시 빠른 확인으로 로딩 상태 결정
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
        if (mounted) {
          setState(() {
            _isReallyLoggedIn = false;
          });
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 [StoryHomeScreen] App resumed - reloading profile');
      // 앱이 다시 포그라운드로 돌아왔을 때 프로필 다시 로드
      if (_isReallyLoggedIn && mounted) {
        _loadUserProfile();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 화면 재진입 시 todaysFortune이 null이면 Provider에서 복원
    if (todaysFortune == null && !isLoadingFortune && !_isInitializing) {
      debugPrint('🔄 [StoryHomeScreen] Screen re-entered with null fortune - restoring from Provider');
      _restoreFortuneFromProvider();
    } else {
      debugPrint('✅ [StoryHomeScreen] Screen re-entered - fortune exists: ${todaysFortune != null}');
    }

    // 화면 재진입 시 userProfile이 null이면 다시 로드
    if (userProfile == null && !_isInitializing && _isReallyLoggedIn) {
      debugPrint('🔄 [StoryHomeScreen] Screen re-entered with null userProfile - reloading');
      _loadUserProfile();
    }
  }

  /// 화면 재진입 시 Provider에서 운세 데이터 복원
  Future<void> _restoreFortuneFromProvider() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ [Provider Restore] No user ID - skipping restore');
        return;
      }

      debugPrint('🔍 [Provider Restore] Checking Provider state for user: $userId');

      // Provider 상태 확인 (Single Source of Truth)
      final providerState = ref.read(dailyFortuneProvider);

      if (providerState.fortune != null && providerState.fortune!.overallScore != null) {
        debugPrint('✅ [Provider Restore] Found fortune in Provider - score: ${providerState.fortune!.overallScore}');

        setState(() {
          todaysFortune = providerState.fortune;
          isLoadingFortune = false;
          _hasViewedStoryToday = true; // Provider에 있으면 이미 본 것으로 간주
        });

        // 스토리 복원
        final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
        if (cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
          setState(() {
            storySegments = cachedStorySegments;
          });
          debugPrint('✅ [Provider Restore] Restored ${cachedStorySegments.length} story segments');
        }
      } else {
        debugPrint('⚠️ [Provider Restore] No fortune in Provider - will load fresh data');
      }
    } catch (e) {
      debugPrint('❌ [Provider Restore] Error: $e');
    }
  }

  // Provider 빠른 확인 (동기적으로 실행되어 첫 build 전에 완료)
  Future<void> _quickCacheCheck() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Provider 상태 우선 확인
        final providerState = ref.read(dailyFortuneProvider);

        if (providerState.fortune != null && providerState.fortune!.overallScore != null) {
          debugPrint('⚡ Quick check: Found fortune in Provider, skipping loading screen');

          if (mounted) {
            setState(() {
              isLoadingFortune = false;
              _hasCachedData = true;
              todaysFortune = providerState.fortune;
              _hasViewedStoryToday = true;
            });
          }

          // 스토리 복원
          final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
          if (cachedStorySegments != null && cachedStorySegments.isNotEmpty && mounted) {
            setState(() {
              storySegments = cachedStorySegments;
            });
          }
        } else {
          debugPrint('⚡ Quick check: No data in Provider, will show loading screen');
        }
      }
    } catch (e) {
      debugPrint('❌ Quick check failed: $e');
    }
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

  // Provider를 통한 데이터 초기화 (캐시는 Provider가 자동 처리)
  Future<void> _initializeDataWithCacheCheck() async {
    if (_isInitializing) {
      debugPrint('⚠️ Already initializing, skipping duplicate call');
      return;
    }

    // 연속 접속일 업데이트 (앱 시작 시 한 번만)
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        final statisticsService = UserStatisticsService(supabase, StorageService());
        await statisticsService.updateConsecutiveDays(userId);
        debugPrint('✅ [StoryHomeScreen] Updated consecutive days for user: $userId');
      } catch (e) {
        debugPrint('⚠️ [StoryHomeScreen] Failed to update consecutive days: $e');
      }
    }

    // Quick cache check에서 이미 로드했으면 스킵
    if (_hasCachedData && todaysFortune != null && storySegments != null) {
      debugPrint('✅ Data already loaded by quick cache check, loading user profile only');
      await _loadUserProfile();
      return;
    }

    // Provider 상태 확인 (Single Source of Truth)
    final providerState = ref.read(dailyFortuneProvider);
    if (providerState.fortune != null && providerState.fortune!.overallScore != null) {
      debugPrint('✅ Provider already has fortune - using it directly');

      setState(() {
        todaysFortune = providerState.fortune;
        isLoadingFortune = false;
      });

      // 스토리 복원
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
        if (cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
          setState(() {
            storySegments = cachedStorySegments;
          });
        }
      }

      return;
    }

    // Provider에 없으면 일반 초기화 진행
    try {
      setState(() {
        _isInitializing = true;
      });

      await _initializeData();
    } catch (e) {
      debugPrint('❌ Error in initialization: $e');
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
        // 로컬 스토리지에서 먼저 이름 확인 (사용자가 직접 입력한 이름)
        final localProfile = await StorageService().getUserProfile();
        final localName = localProfile?['name'] as String?;
        debugPrint('📦 Local profile name: $localName');

        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          // 로컬 스토리지 이름을 우선 사용 (사용자가 직접 입력한 이름)
          final dbName = response['name'] as String?;
          final String finalName = (localName?.isNotEmpty == true) ? localName! : (dbName ?? '');
          debugPrint('✅ User profile loaded: dbName=$dbName, localName=$localName, finalName=$finalName');

          // Check if Saju calculation is needed
          final sajuCalculated = response['saju_calculated'] ?? false;
          final birthDate = response['birth_date'];
          final birthTime = response['birth_time'];

          setState(() {
            userProfile = UserProfile(
              id: response['id'],
              email: response['email'] ?? supabase.auth.currentUser?.email ?? '',
              name: finalName,
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
      debugPrint('🌤️ Loading weather info...');
      final weather = await WeatherService.getCurrentWeather();
      setState(() {
        currentWeather = weather;
      });
      debugPrint('✅ Weather loaded: ${weather.condition}, ${weather.temperature}°C');
    } catch (e) {
      debugPrint('❌ Failed to load weather: $e');
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

      // 현재 날짜 키 생성
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month}-${now.day}';
      debugPrint('📅 Current date key: $dateKey');

      // 1. Provider 상태 우선 확인 (Single Source of Truth)
      final providerState = ref.read(dailyFortuneProvider);

      if (providerState.fortune != null && providerState.fortune!.overallScore != null) {
        debugPrint('✅ Using Provider state (already loaded) - score: ${providerState.fortune!.overallScore}');

        // Provider에 운세가 있으면 바로 사용
        setState(() {
          todaysFortune = providerState.fortune;
          isLoadingFortune = false;
        });

        // 스토리 확인
        final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
        if (cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
          setState(() {
            storySegments = cachedStorySegments;
          });
        } else {
          await _generateStory(providerState.fortune!);
        }

        return;
      }

      // 2. Provider에 없으면 로드 (Provider가 캐시를 자동으로 체크함)
      debugPrint('📡 Loading fortune via Provider (checks cache automatically)');
      final dailyFortuneNotifier = ref.read(dailyFortuneProvider.notifier);
      dailyFortuneNotifier.setDate(now);
      await dailyFortuneNotifier.loadFortune();

      final fortuneState = ref.read(dailyFortuneProvider);

      debugPrint('🔍 Provider state after load - hasFortune: ${fortuneState.fortune != null}, hasScore: ${fortuneState.fortune?.overallScore != null}, score: ${fortuneState.fortune?.overallScore}');

      // 3. Provider에서 로드했지만 overallScore가 null인 경우 (잘못된 캐시)
      if (fortuneState.fortune != null && fortuneState.fortune!.overallScore == null) {
        debugPrint('⚠️ Cached fortune has null overallScore - invalidating cache and reloading');

        // 캐시 무효화
        await _cacheService.removeCachedFortune('daily', {'userId': userId});

        // Provider 리셋
        dailyFortuneNotifier.reset();

        // 새로 로드
        dailyFortuneNotifier.setDate(now);
        await dailyFortuneNotifier.loadFortune();

        final newFortuneState = ref.read(dailyFortuneProvider);

        if (newFortuneState.fortune != null && newFortuneState.fortune!.overallScore != null) {
          debugPrint('✅ Fortune reloaded with valid score - score: ${newFortuneState.fortune!.overallScore}');

          setState(() {
            todaysFortune = newFortuneState.fortune;
            isLoadingFortune = false;
          });

          await _saveDailyFortuneToHistory(newFortuneState.fortune!);

          final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
          if (cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
            setState(() {
              storySegments = cachedStorySegments;
            });
          } else {
            await _generateStory(newFortuneState.fortune!);
          }
        } else {
          debugPrint('❌ Still no valid fortune after reload');
        }

        return;
      }

      if (fortuneState.fortune != null && fortuneState.fortune!.overallScore != null) {
        debugPrint('✅ Fortune loaded via Provider - score: ${fortuneState.fortune!.overallScore}');

        setState(() {
          todaysFortune = fortuneState.fortune;
          isLoadingFortune = false;
        });

        // 일일 운세를 히스토리에 저장
        await _saveDailyFortuneToHistory(fortuneState.fortune!);

        // 스토리 생성
        final cachedStorySegments = await _cacheService.getCachedStorySegments('daily', {'userId': userId});
        if (cachedStorySegments != null && cachedStorySegments.isNotEmpty) {
          setState(() {
            storySegments = cachedStorySegments;
          });
        } else {
          await _generateStory(fortuneState.fortune!);
        }
      } else if (fortuneState.error != null) {
        debugPrint('❌ Fortune loading error: ${fortuneState.error}');
        throw Exception(fortuneState.error);
      }
    } catch (e) {
      debugPrint('❌ Error loading fortune: $e');
      rethrow;
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
      if (score >= 90) {
        tags.add('최고운');
      } else if (score >= 80) {
        tags.add('대길');
      } else if (score >= 70) {
        tags.add('길');
      } else if (score >= 60) {
        tags.add('보통');
      } else {
        tags.add('주의');
      }

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
      // ✅ 최초 mounted 체크
      if (!mounted) return;

      // Ensure we have the user profile loaded
      if (userProfile == null || userProfile!.name.isEmpty) {
        await _loadUserProfile();
      }

      // ✅ 비동기 작업 후 mounted 체크
      if (!mounted) return;

      // Use the actual name from userProfile, fallback to '사용자' only if really empty
      final userName = (userProfile?.name != null && userProfile!.name.isNotEmpty)
          ? userProfile!.name
          : '사용자';

      debugPrint('🎯 Generating story with userName: "$userName" (profile name: "${userProfile?.name}")');

      // GPT로 스토리 생성 (사주 정보 포함)
      final storyNotifier = ref.read(fortuneStoryProvider.notifier);
      await storyNotifier.generateFortuneStory(
        userName: userName,
        fortune: fortune,
        userProfile: userProfile,
      );

      // ✅ 비동기 작업 후 mounted 체크
      if (!mounted) return;

      final storyState = ref.read(fortuneStoryProvider);
      List<StorySegment>? generatedSegments;

      if (storyState.segments != null) {
        generatedSegments = storyState.segments;
        // 사주 분석 데이터도 가져오기
        if (storyState.sajuAnalysis != null && mounted) { // ✅ mounted 체크
          setState(() {
            sajuAnalysisData = storyState.sajuAnalysis;
          });
        }

        // 확장된 데이터 추출
        if (mounted) { // ✅ mounted 체크
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
        }
      } else {
        // GPT 실패시 기본 스토리 생성
        generatedSegments = StoryHelpers.createDetailedStorySegments(userName, fortune);
      }

      if (generatedSegments != null && mounted) { // ✅ mounted 체크
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
      if (!mounted) return; // ✅ dispose 체크 추가

      final userName = (userProfile?.name != null && userProfile!.name.isNotEmpty)
          ? userProfile!.name
          : '사용자';
      final fallbackSegments = StoryHelpers.createDetailedStorySegments(userName, fortune);

      if (mounted) { // ✅ setState 전 mounted 체크
        setState(() {
          storySegments = fallbackSegments;
        });
      }
    }
  }

  // 완료 페이지 표시
  void _showCompletionPage() {
    // 스토리를 봤다고 기록
    _markAsViewed();

    // 네비게이션 바 표시
    ref.read(navigationVisibilityProvider.notifier).show();

    // Navigator push로 완료 페이지 열기
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FortuneSwipePage(
          fortune: todaysFortune,
          userName: userProfile?.name,
          userProfile: userProfile,
          overall: overallData,
          categories: categoriesData,
          sajuInsight: sajuInsightData,
          currentWeather: currentWeather,
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

    // 기본: Tinder 페이지 표시
    // 예외: 새로운 스토리가 있고 아직 보지 않은 경우에만 스토리 뷰어
    if (storySegments != null && storySegments!.isNotEmpty && !_hasViewedStoryToday) {
      debugPrint('🎬 New story available - showing FortuneStoryViewer');
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

    // 기본 화면: Tinder 완료 페이지
    debugPrint('🎯 Showing default FortuneSwipePage');
    debugPrint('🔍 [StoryHomeScreen] userProfile: ${userProfile?.name}, fortune: ${todaysFortune != null}');

    // 네비게이션 바 즉시 표시 (build 후에)
    // FortuneStoryViewer가 hide()를 호출했을 수 있으므로 명시적으로 show() 필요
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navNotifier = ref.read(navigationVisibilityProvider.notifier);
      if (!ref.read(navigationVisibilityProvider).isVisible) {
        debugPrint('⚠️ Navigation bar was hidden, showing it now');
        navNotifier.show();
      }
    });

    return FortuneSwipePage(
      fortune: todaysFortune,
      userName: userProfile?.name,
      userProfile: userProfile,
      overall: overallData,
      categories: categoriesData,
      sajuInsight: sajuInsightData,
      currentWeather: currentWeather,
    );
  }
}
