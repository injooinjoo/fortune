import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../services/social_auth_service.dart';
import '../services/storage_service.dart';
import '../core/utils/url_cleaner_stub.dart'
    if (dart.library.html) '../core/utils/url_cleaner_web.dart';
import '../presentation/providers/theme_provider.dart';
import '../core/utils/profile_validation.dart';
import '../core/theme/toss_design_system.dart';
import '../presentation/widgets/social_login_bottom_sheet.dart';
import '../core/theme/typography_unified.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  bool _isAuthProcessing = false;
  SocialAuthService? _socialAuthService; // nullable로 변경
  final _storageService = StorageService();
  Timer? _authTimeoutTimer;
  bool _isSupabaseAvailable = false; // Supabase 사용 가능 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 상태 초기화 명확히 하기
    _isAuthProcessing = false;
    _isCheckingAuth = false; // Initialize as false instead of true
    debugPrint('🔵 initState: _isAuthProcessing initialized to false');
    debugPrint('🔵 initState: _isCheckingAuth initialized to false');

    // Supabase 안전하게 초기화
    try {
      final client = Supabase.instance.client;
      _socialAuthService = SocialAuthService(client);
      _isSupabaseAvailable = true;
      debugPrint('✅ [LandingPage] Supabase client initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [LandingPage] Supabase client not available, using offline mode: $e');
      _isSupabaseAvailable = false;
      _socialAuthService = null;
    }

    // Check auth in background without blocking UI
    Future.microtask(() async {
      if (!_isSupabaseAvailable) {
        debugPrint('⚠️ [LandingPage] Skipping auth check - Supabase not available');
        return;
      }

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Only show loading if there's a session to check
        if (mounted) {
          setState(() {
            _isCheckingAuth = true;
          });
        }
        await _checkAuthState();
      }
      _checkUrlParameters();
    });

    // Add timeout fallback to prevent infinite loading
    Timer(const Duration(seconds: 5), () {
      if (_isCheckingAuth && mounted) {
        debugPrint('⚠️ Auth check timeout - forcing _isCheckingAuth to false');
        setState(() => _isCheckingAuth = false);
      }
    });

    // Listen for auth state changes (only if Supabase is available)
    if (_isSupabaseAvailable) {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      debugPrint('🔔 Auth state changed: ${data.event}');

      // OAuth 로그인 성공 후 처리 (SignedIn 이벤트)
      if (data.event == AuthChangeEvent.signedIn &&
          data.session != null &&
          mounted) {
        debugPrint('🟢 User signed in via OAuth, processing...');

        // OAuth 처리 중 상태 해제
        if (_isAuthProcessing) {
          setState(() => _isAuthProcessing = false);
          _authTimeoutTimer?.cancel();
        }

        // 프로필 동기화 (이미 프로필 저장 로직이 포함됨)
        await _syncProfileFromSupabase();

        // 로그인 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 성공!'),
              backgroundColor: TossDesignSystem.successGreen,
            ),
          );
        }

        // 온보딩 필요 여부 확인 후 라우팅
        final needsOnboarding = await ProfileValidation.needsOnboarding();
        if (needsOnboarding && mounted) {
          debugPrint('Profile incomplete, redirecting to onboarding...');
          context.go('/onboarding');
        } else if (mounted) {
          debugPrint('Profile complete, redirecting to home...');
          context.go('/home');
        }
      }
    });
    } // Supabase available check 종료
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 페이지로 돌아왔을 때 OAuth 상태 체크
    if (_isAuthProcessing && _isSupabaseAvailable) {
      // 세션이 없으면 OAuth가 취소된 것으로 판단
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('🔄 Page resumed with no session - resetting auth state');
        _resetAuthProcessing();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때
      if (_isAuthProcessing) {
        // OAuth 프로세스 중이었다면, 짧은 지연 후 상태 체크
        Future.delayed(const Duration(seconds: 1), () {
          if (!_isSupabaseAvailable) return;

          // 세션이 없으면 OAuth가 취소된 것으로 판단
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null && _isAuthProcessing && mounted) {
            debugPrint('OAuth cancelled - returning to login screen');
            _resetAuthProcessing();
          }
        });
      }
    }
  }

  void _resetAuthProcessing() {
    debugPrint(
        '🔄 _resetAuthProcessing called - _isAuthProcessing: $_isAuthProcessing');
    if (mounted) {
      setState(() {
        _isAuthProcessing = false;
      });
      _authTimeoutTimer?.cancel();
      debugPrint('🔄 Auth processing reset complete');

      // 사용자에게 취소되었음을 알림
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 취소되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startAuthTimeout() {
    _authTimeoutTimer?.cancel();
    _authTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isAuthProcessing && mounted) {
        debugPrint('OAuth timeout - resetting auth state');
        _resetAuthProcessing();
      }
    });
  }

  Future<void> _updateKakaoProfileName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 사용자 메타데이터에서 카카오 ID 확인
      final userMetadata = user.userMetadata;
      final kakaoId = userMetadata?['kakao_id'];

      debugPrint('🟡 [Kakao Profile Update] Current metadata name: ${userMetadata?['name']}');
      debugPrint('🟡 [Kakao Profile Update] Current metadata nickname: ${userMetadata?['nickname']}');
      debugPrint('🟡 [Kakao Profile Update] Kakao ID: $kakaoId');

      if (kakaoId == null) {
        debugPrint('🟡 [Kakao Profile Update] Not a Kakao user, skipping');
        return;
      }

      // 카카오 SDK에서 직접 사용자 정보 가져오기
      try {
        final kakaoUser = await kakao.UserApi.instance.me();
        final kakaoNickname = kakaoUser.kakaoAccount?.profile?.nickname ??
                             (kakaoUser.kakaoAccount?.name ?? '사용자');

        debugPrint('🟡 [Kakao Profile Update] Retrieved nickname from Kakao SDK: $kakaoNickname');

        if (kakaoNickname != '사용자') {
          // Supabase 프로필 업데이트
          await Supabase.instance.client
              .from('user_profiles')
              .update({'name': kakaoNickname})
              .eq('id', user.id);

          debugPrint('🟡 [Kakao Profile Update] Updated Supabase profile name to: $kakaoNickname');

          // 로컬 스토리지도 업데이트
          final localProfile = await _storageService.getUserProfile();
          if (localProfile != null) {
            localProfile['name'] = kakaoNickname;
            await _storageService.saveUserProfile(localProfile);
            debugPrint('🟡 [Kakao Profile Update] Updated local profile name');
          }
        } else {
          debugPrint('🟡 [Kakao Profile Update] Kakao nickname is still default, not updating');
        }
      } catch (kakaoError) {
        debugPrint('🟡 [Kakao Profile Update] Error fetching from Kakao SDK: $kakaoError');
        debugPrint('🟡 [Kakao Profile Update] Falling back to metadata');
      }
    } catch (e) {
      debugPrint('🟡 [Kakao Profile Update] Error updating profile: $e');
    }
  }

  Future<void> _syncProfileFromSupabase() async {
    if (!_isSupabaseAvailable) {
      debugPrint('⚠️ [LandingPage] Skipping profile sync - Supabase not available');
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      debugPrint('user: ${user.id}');

      // Try to get profile from Supabase
      var response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        debugPrint('Profile found in Supabase, saving to local storage');

        // Ensure onboarding_completed is set if all required fields are present
        if (response['name'] != null &&
            response['birth_date'] != null &&
            response['gender'] != null) {
          response['onboarding_completed'] = true;
        }

        // Save to local storage
        await _storageService.saveUserProfile(response);
      } else {
        debugPrint('No profile found in Supabase');

        // Create profile automatically for OAuth users
        debugPrint('Creating new profile for OAuth user...');
        debugPrint('metadata: ${user.userMetadata}');
        debugPrint('metadata: ${user.appMetadata}');

        // Start with basic profile data that's always supported
        final profileData = {
          'id': user.id,
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': null
        };

        // Add additional info from user metadata if available
        if (user.userMetadata != null) {
          if (user.userMetadata?['full_name'] != null) {
            profileData['name'] = user.userMetadata?['full_name'];
          } else if (user.userMetadata?['name'] != null) {
            profileData['name'] = user.userMetadata?['name'];
          } else {
            profileData['name'] = '사용자';
          }

          if (user.userMetadata?['avatar_url'] != null) {
            profileData['profile_image_url'] = user.userMetadata?['avatar_url'];
          } else if (user.userMetadata?['picture'] != null) {
            profileData['profile_image_url'] = user.userMetadata?['picture'];
          }
        } else {
          profileData['name'] = '사용자';
        }

        try {
          // First try with social auth columns
          final profileWithSocialAuth = Map<String, dynamic>.from(profileData);
          profileWithSocialAuth['primary_provider'] =
              user.appMetadata['provider'] ?? 'google';
          profileWithSocialAuth['linked_providers'] = [
            user.appMetadata['provider'] ?? 'google'
          ];

          await Supabase.instance.client
              .from('user_profiles')
              .insert(profileWithSocialAuth);
          debugPrint('Profile created successfully with social auth columns');

          // Save to local storage
          await _storageService.saveUserProfile(profileWithSocialAuth);
        } catch (insertError) {
          debugPrint('Error saving profile: $insertError');

          // If social auth columns don't exist, try without them
          if (insertError.toString().contains('linked_providers') ||
              insertError.toString().contains('primary_provider')) {
            debugPrint(
                'Social auth columns not found, creating profile without them...');
            try {
              await Supabase.instance.client
                  .from('user_profiles')
                  .insert(profileData);
              debugPrint(
                  'Profile created successfully without social auth columns');

              // Save to local storage
              await _storageService.saveUserProfile(profileData);
            } catch (fallbackError) {
              debugPrint('Error saving profile: $fallbackError');
              // Continue even if profile creation fails
            }
          } else {
            debugPrint('Profile creation failed with unexpected error');
            // Continue even if profile creation fails
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> _checkAuthState() async {
    if (!_isSupabaseAvailable) {
      debugPrint('⚠️ [LandingPage] Skipping auth state check - Supabase not available');
      return;
    }

    debugPrint(
        '🔍 _checkAuthState: Starting auth check, _isCheckingAuth is $_isCheckingAuth');
    try {
      final session = Supabase.instance.client.auth.currentSession;

      // If no session, stay on landing page
      if (session == null) {
        debugPrint('No session found, staying on landing page');
        debugPrint('🔍 _checkAuthState: Setting _isCheckingAuth to false');
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
            debugPrint('✅ _checkAuthState: _isCheckingAuth set to false');
          });
          // Force visual update in release mode
          WidgetsBinding.instance.ensureVisualUpdate();
          debugPrint('🔍 _checkAuthState: ensureVisualUpdate() called');
        }
        return;
      }

      // Try to sync profile from Supabase first
      await _syncProfileFromSupabase();

      // Check if user needs onboarding (only for authenticated users)
      final needsOnboarding = await ProfileValidation.needsOnboarding();

      if (needsOnboarding) {
        // Don't auto-redirect to onboarding from landing page
        // Let user click "시작하기" button
        debugPrint('User needs onboarding, staying on landing page');
      } else {
        // Profile is complete, check for returnUrl or go to home
        final uri = Uri.base;
        final returnUrl = uri.queryParameters['returnUrl'];

        if (returnUrl != null && mounted) {
          // Clean URL before navigation
          if (kIsWeb) {
            cleanUrlInBrowser(Uri.decodeComponent(returnUrl));
          }
          context.go(Uri.decodeComponent(returnUrl));
        } else if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  void _checkUrlParameters() {
    final uri = Uri.base;
    final error = uri.queryParameters['error'];

    if (error != null) {
      String message = '';
      switch (error) {
        case 'session_expired':
          message = '세션이 만료되었습니다. 다시 로그인해 주세요.';
          break;
        case 'auth_failure':
          message = '로그인 처리 중 문제가 발생했습니다. 다시 시도해 주세요.';
          break;
        case 'timeout':
          message = '로그인 처리 시간이 초과되었습니다. 다시 시도해 주세요.';
          break;
        case 'no_session':
          message = '세션을 찾을 수 없습니다. 다시 로그인해 주세요.';
          break;
        case 'pkce_failure':
          message = 'PKCE 인증에 실패했습니다. 다시 로그인해 주세요.';
          break;
        default:
          message = '로그인 중 문제가 발생했습니다.';
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: TossDesignSystem.errorRed));

        // Clean error parameter from URL after showing message
        if (kIsWeb) {
          final cleanUrl = uri.path;
          cleanUrlInBrowser(cleanUrl);
        }
      });
    }
  }

  Future<void> _handleAppleLogin() async {
    debugPrint('🍎 _handleAppleLogin() called');
    debugPrint('🍎 _isAuthProcessing at start: $_isAuthProcessing');

    if (_isAuthProcessing) {
      debugPrint('🍎 Already processing, returning early');
      return;
    }

    debugPrint('🍎 Setting _isAuthProcessing to true');
    setState(() => _isAuthProcessing = true);
    _startAuthTimeout(); // 타임아웃 시작

    try {
      debugPrint('🍎 Calling _socialAuthService.signInWithApple()');
      // Apple OAuth 로그인 - SocialAuthService 사용
      if (_socialAuthService == null) {
        throw Exception('Social auth service not available');
      }
      final result = await _socialAuthService!.signInWithApple();

      debugPrint('🍎 signInWithApple() result: $result');

      if (result != null) {
        // Native Apple Sign-In 성공
        debugPrint('🍎 Native Apple Sign-In successful');

        // 프로필은 social_auth_service에서 이미 저장됨

        // 프로필 검증 후 라우팅
        final needsOnboarding = await ProfileValidation.needsOnboarding();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Apple 로그인 성공!'),
              backgroundColor: TossDesignSystem.successGreen,
            ),
          );

          // 화면 전환
          if (needsOnboarding) {
            context.go('/onboarding');
          } else {
            context.go('/home');
          }
        }
      } else {
        // OAuth flow - 브라우저로 리다이렉트됨
        debugPrint('🍎 OAuth flow initiated');
        // _startAuthTimeout(); // 이미 시작됨
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple 로그인을 처리하고 있습니다...'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🍎 Apple login error: $e');
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.errorRedDark
                : TossDesignSystem.errorRed));
      }
    } finally {
      debugPrint('🍎 Setting _isAuthProcessing to false');
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    debugPrint('🟢 [NAVER] _handleNaverLogin() called');
    debugPrint('🟢 [NAVER] _isAuthProcessing at entry: $_isAuthProcessing');

    if (_isAuthProcessing) {
      debugPrint('🟢 [NAVER] Already processing, returning early');
      return;
    }

    debugPrint('🟢 [NAVER] Setting _isAuthProcessing = true');
    setState(() => _isAuthProcessing = true);
    _startAuthTimeout(); // 타임아웃 시작

    try {
      // Naver OAuth 로그인 - SocialAuthService 사용
      debugPrint('🟢 [NAVER] Checking _socialAuthService: $_socialAuthService');
      if (_socialAuthService == null) {
        debugPrint('🟢 [NAVER] ERROR: Social auth service is NULL!');
        throw Exception('Social auth service not available');
      }

      debugPrint('🟢 [NAVER] Calling signInWithNaver()...');

      // Test: call without await first to see if it returns a Future
      final futureResult = _socialAuthService!.signInWithNaver();
      debugPrint('🟢 [NAVER] Got Future: ${futureResult.runtimeType}');

      final result = await futureResult;
      debugPrint('🟢 [NAVER] signInWithNaver() returned: $result');

      if (result != null) {
        // Naver Sign-In 성공
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('네이버 로그인 성공!'),
            backgroundColor: TossDesignSystem.successGreen,
          ));
        }
      } else {
        // OAuth 방식인 경우
        // _startAuthTimeout(); // 이미 시작됨
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('네이버 로그인을 처리하고 있습니다...')));
        }
      }
    } catch (e) {
      debugPrint('🟢 [NAVER] Exception caught: $e');
      debugPrint('🟢 [NAVER] Exception type: ${e.runtimeType}');
      debugPrint('Error saving profile: $e');
      if (mounted) {
        // Check for duplicate email error
        String errorMessage = '네이버 로그인 중 문제가 발생했습니다. 다시 시도해주세요.';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e.toString().contains('already been registered')) {
          errorMessage = '이미 다른 소셜 계정(Google, Kakao, Apple)으로 가입된 이메일입니다.\n다른 로그인 방법을 시도해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 4),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.errorRedDark
                : TossDesignSystem.errorRed));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  Future<void> _handleInstagramLogin() async {
    if (_isAuthProcessing) return;

    setState(() => _isAuthProcessing = true);

    try {
      // Instagram login coming soon
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Instagram 로그인은 준비 중입니다.'),
            backgroundColor: TossDesignSystem.warningOrange));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  Future<void> _handleTikTokLogin() async {
    if (_isAuthProcessing) return;

    setState(() => _isAuthProcessing = true);

    try {
      // TikTok login coming soon
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('TikTok 로그인은 준비 중입니다.'),
            backgroundColor: TossDesignSystem.warningOrange));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  void _startOnboarding() async {
    // Show social login bottom sheet first
    _showSocialLoginBottomSheet();
  }

  void _showSocialLoginBottomSheet() async {
    // Modal 표시 전에 항상 인증 상태 초기화
    if (_isAuthProcessing) {
      setState(() => _isAuthProcessing = false);
      _authTimeoutTimer?.cancel();
    }

    // 공통 BottomSheet 위젯 사용
    await SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () async {
        debugPrint('🔴 Google login button clicked');

        // 모달을 먼저 닫기
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // 잠시 기다렸다가 로그인 처리
        await Future.delayed(Duration(milliseconds: 100));
        _handleSocialLogin('Google');
      },
      onAppleLogin: () async {
        debugPrint('🍎 Apple login button clicked');
        debugPrint('🍎 _isAuthProcessing: $_isAuthProcessing');

        // 모달을 먼저 닫기
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // 잠시 기다렸다가 로그인 처리 (UI가 완전히 업데이트되도록)
        await Future.delayed(Duration(milliseconds: 100));
        _handleAppleLogin();
      },
      onKakaoLogin: () async {
        debugPrint('🟡 Kakao login button clicked');

        // 모달을 먼저 닫기
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // 잠시 기다렸다가 로그인 처리
        await Future.delayed(Duration(milliseconds: 100));
        _handleSocialLogin('Kakao');
      },
      onNaverLogin: () {
        debugPrint('🟢 Naver login button clicked');
        debugPrint('🟢 _isAuthProcessing before pop: $_isAuthProcessing');

        // 모달을 먼저 닫기
        Navigator.pop(context);

        // 즉시 로그인 처리 (100ms 대기 제거)
        debugPrint('🟢 About to call _handleNaverLogin()');
        _handleNaverLogin();
      },
      onInstagramLogin: () {
        Navigator.pop(context);
        _handleInstagramLogin();
      },
      onTikTokLogin: () {
        Navigator.pop(context);
        _handleTikTokLogin();
      },
      isProcessing: _isAuthProcessing,
    );

    // Modal이 닫힌 후 처리
    // 각 버튼의 콜백이 async로 처리되므로 여기서는 특별한 처리 불필요
    // _resetAuthProcessing()을 호출하면 버튼 클릭 직후 상태가 초기화되어 로그인이 진행되지 않음
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isAuthProcessing) return;

    setState(() => _isAuthProcessing = true);
    _startAuthTimeout(); // 모든 소셜 로그인에 타임아웃 적용

    try {
      if (provider == 'Google') {
        // 즉시 로딩 피드백 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            TossDesignSystem.white)),
                  ),
                  SizedBox(width: 16),
                  Text('Google 로그인 진행 중...'),
                ],
              ),
              duration: Duration(seconds: 10), // Auth timeout과 동일
            ),
          );
        }

        // 브라우저 확장 프로그램 간섭 제거
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs
            .getKeys()
            .where((key) =>
                key.contains('fortune-auth-token-code-verifier') ||
                (key.contains('code-verifier') && !key.startsWith('sb-')))
            .toList();

        for (final key in keys) {
          await prefs.remove(key);
        }

        // Google Sign-In OAuth 사용
        try {
          if (_socialAuthService == null) {
            throw Exception('Social auth service not available');
          }

          await _socialAuthService!.signInWithGoogle();

          // 로딩 스낵바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }

          // OAuth 리다이렉트 방식은 항상 null을 반환
          // 실제 인증은 브라우저에서 진행되고 콜백으로 처리됨
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google 로그인을 처리하고 있습니다...'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          // 로딩 스낵바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }

          debugPrint('Google 로그인 에러: $e');

          // Show error message
          if (mounted) {
            String errorMessage = '로그인 중 문제가 발생했습니다. 다시 시도해주세요.';

            if (e.toString().contains('Invalid API key')) {
              errorMessage = '인증 서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.';
            } else if (e.toString().contains('sign in failed to start')) {
              errorMessage = 'Google 로그인을 시작할 수 없습니다. 다시 시도해주세요.';
            }

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(errorMessage),
                backgroundColor: TossDesignSystem.errorRed));
          }
          rethrow;
        }
      } else if (provider == 'Kakao') {
        // 카카오 로그인 진행 중 피드백 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            TossDesignSystem.white)),
                  ),
                  SizedBox(width: 16),
                  Text('카카오 로그인 진행 중...'),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
        }

        try {
          debugPrint('🟡 Starting Kakao login...');
          if (_socialAuthService == null) {
            throw Exception('Social auth service not available');
          }

          final response = await _socialAuthService!.signInWithKakao();

          // 로딩 스낵바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }

          debugPrint('🟡 Kakao login response: $response');

          // 카카오 네이티브 로그인은 AuthResponse를 반환할 수 있음
          if (response != null && response.user != null) {
            debugPrint('🟡 Kakao login successful, user: ${response.user?.id}');

            // 성공 메시지 표시
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('카카오 로그인이 완료되었습니다.'),
                  backgroundColor: TossDesignSystem.successGreen,
                ),
              );
            }

            // 명시적으로 프로필 동기화 및 페이지 이동 처리
            await _syncProfileFromSupabase();

            // 카카오 사용자 정보를 다시 가져와서 프로필 업데이트
            await _updateKakaoProfileName();

            // 프로필 상태 확인 후 페이지 이동
            final needsOnboarding = await ProfileValidation.needsOnboarding();
            if (needsOnboarding && mounted) {
              debugPrint('🟡 Profile incomplete, redirecting to onboarding...');
              context.go('/onboarding');
            } else if (mounted) {
              debugPrint('🟡 Profile complete, redirecting to home...');
              context.go('/home');
            }
          } else {
            // OAuth 방식인 경우 (response == null)
            debugPrint(
                '🟡 Kakao OAuth flow initiated, waiting for callback...');
            // _startAuthTimeout(); 이미 _handleSocialLogin에서 시작됨
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('카카오 로그인을 처리하고 있습니다...'),
                  backgroundColor: TossDesignSystem.warningOrange,
                ),
              );
            }
          }
        } catch (kakaoError) {
          debugPrint('🟡 Kakao login error: $kakaoError');

          // 로딩 스낵바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('카카오 로그인 중 문제가 발생했습니다: ${kakaoError.toString()}'),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.errorRed
                    : TossDesignSystem.errorRed,
              ),
            );
          }
        }
      } else if (provider == 'Instagram') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('인스타그램 로그인은 현재 준비 중입니다.'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.warningOrange
                  : TossDesignSystem.warningOrange));
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.errorRedDark
                : TossDesignSystem.errorRed));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🎨 Building LandingPage: _isCheckingAuth=$_isCheckingAuth, _isAuthProcessing=$_isAuthProcessing');

    // Build 시 OAuth 상태 체크는 제거 (didChangeDependencies와 didChangeAppLifecycleState에서 처리)
    // build()에서 setState를 트리거하는 로직은 무한 리빌드를 유발할 수 있음

    if (_isCheckingAuth) {
      debugPrint('🅿️ Showing loading screen because _isCheckingAuth is true');
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/flower_transparent_white.png'
                    : 'assets/images/flower_transparent.png',
                width: 64,
                height: 64,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2.seconds),
              SizedBox(height: 16),
              Text(
                '로그인 상태를 확인하고 있습니다...',
                style: TypographyUnified.buttonMedium.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark400
                        : TossDesignSystem.gray600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // GPT-5 스타일 그라데이션 배경
          Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a1a2e), // 진한 남색
                        Color(0xFF16213e), // 어두운 파란색
                        Color(0xFF0f1624), // 거의 검정
                        Color(0xFF1a1a2e), // 진한 남색
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF5E6FF), // 연한 보라
                        Color(0xFFFFE6F0), // 연한 핑크
                        Color(0xFFFFEFE6), // 연한 살구색
                        Color(0xFFFFF9E6), // 연한 노란색
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    ),
            ),
          ),

          // 부드러운 색상 블러 효과 (GPT-5 스타일)
          if (Theme.of(context).brightness == Brightness.light) ...[
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFE8B4FF).withValues(alpha: 0.5), // 보라색
                      Color(0xFFE8B4FF).withValues(alpha: 0.3),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .moveX(
                      begin: 0,
                      end: 50,
                      duration: 15.seconds,
                      curve: Curves.easeInOut)
                  .moveY(
                      begin: 0,
                      end: 30,
                      duration: 20.seconds,
                      curve: Curves.easeInOut),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFB4B4).withValues(alpha: 0.5), // 분홍색
                      Color(0xFFFFB4B4).withValues(alpha: 0.3),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .moveX(
                      begin: 0,
                      end: -40,
                      duration: 18.seconds,
                      curve: Curves.easeInOut)
                  .moveY(
                      begin: 0,
                      end: -40,
                      duration: 22.seconds,
                      curve: Curves.easeInOut),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: -200,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFE4B4).withValues(alpha: 0.4), // 노란색
                      Color(0xFFFFE4B4).withValues(alpha: 0.2),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .moveX(
                      begin: 0,
                      end: 60,
                      duration: 25.seconds,
                      curve: Curves.easeInOut)
                  .moveY(
                      begin: 0,
                      end: -30,
                      duration: 20.seconds,
                      curve: Curves.easeInOut),
            ),
          ] else ...[
            // 다크 모드용 은은한 색상 효과
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF6B46C1).withValues(alpha: 0.15), // 보라색
                      Color(0xFF6B46C1).withValues(alpha: 0.08),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .moveX(
                      begin: 0,
                      end: 50,
                      duration: 15.seconds,
                      curve: Curves.easeInOut)
                  .moveY(
                      begin: 0,
                      end: 30,
                      duration: 20.seconds,
                      curve: Curves.easeInOut),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF2563EB).withValues(alpha: 0.15), // 파란색
                      Color(0xFF2563EB).withValues(alpha: 0.08),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .moveX(
                      begin: 0,
                      end: -40,
                      duration: 18.seconds,
                      curve: Curves.easeInOut)
                  .moveY(
                      begin: 0,
                      end: -40,
                      duration: 22.seconds,
                      curve: Curves.easeInOut),
            ),
          ],

          SafeArea(
            child: Column(
              children: [
                // Header with dark mode toggle
                Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();

                      final themeNotifier =
                          ref.read(themeModeProvider.notifier);
                      final isDark = themeNotifier.isDarkMode(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              isDark ? '다크 모드로 전환되었습니다' : '라이트 모드로 전환되었습니다'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? TossDesignSystem.grayDark300
                                    : TossDesignSystem.gray300,
                            width: 1),
                      ),
                      child: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 24,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark300
                              : TossDesignSystem.gray600),
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        Image.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/images/flower_transparent_white.png'
                              : 'assets/images/flower_transparent.png',
                          width: 100,
                          height: 100,
                        ).animate().fadeIn(duration: 800.ms).scale(
                            begin: Offset(0.8, 0.8),
                            end: Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutBack),

                        SizedBox(height: 40),

                        // App Name
                        Text(
                          'Fortune',
                          style: TypographyUnified.heading1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1),
                        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          '매일 새로운 운세를 만나보세요',
                          style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? TossDesignSystem.grayDark400
                                  : TossDesignSystem.gray600),
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                        const SizedBox(height: 80),

                        // Start Button with Hero Animation
                        Hero(
                          tag: 'start-button-hero',
                          child: Material(
                            color:
                                TossDesignSystem.white.withValues(alpha: 0.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _startOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? TossDesignSystem.white
                                          : TossDesignSystem.black,
                                  foregroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? TossDesignSystem.black
                                          : TossDesignSystem.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  '시작하기',
                                  style: TypographyUnified.heading4.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 600.ms)
                            .scale(
                                begin: Offset(0.9, 0.9),
                                end: Offset(1.0, 1.0),
                                duration: 400.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
