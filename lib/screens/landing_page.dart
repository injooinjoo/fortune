import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service.dart';
import '../services/storage_service.dart';
import '../core/utils/url_cleaner_stub.dart'
    if (dart.library.html) '../core/utils/url_cleaner_web.dart';
import '../presentation/providers/theme_provider.dart';
import '../core/utils/profile_validation.dart';
import '../core/theme/toss_design_system.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> with WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  bool _isAuthProcessing = false;
  final _authService = AuthService();
  late final SocialAuthService _socialAuthService;
  final _storageService = StorageService();
  Timer? _authTimeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 상태 초기화 명확히 하기
    _isAuthProcessing = false;
    print('🔵 initState: _isAuthProcessing initialized to false');
    print('🔵 initState: _isCheckingAuth is $_isCheckingAuth');
    
    _socialAuthService = SocialAuthService(Supabase.instance.client);
    
    // Ensure auth check happens after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 PostFrameCallback: Starting auth check');
      _checkAuthState();
      _checkUrlParameters();
    });
    
    // Add timeout fallback to prevent infinite loading
    Timer(const Duration(seconds: 5), () {
      if (_isCheckingAuth && mounted) {
        print('⚠️ Auth check timeout - forcing _isCheckingAuth to false');
        setState(() => _isCheckingAuth = false);
      }
    });
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      debugPrint('🔔 Auth state changed: ${data.event}');
      
      // OAuth 로그인 성공 후 처리 (SignedIn 이벤트)
      if (data.event == AuthChangeEvent.signedIn && data.session != null && mounted) {
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 페이지로 돌아왔을 때 OAuth 상태 체크
    if (_isAuthProcessing) {
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
    debugPrint('🔄 _resetAuthProcessing called - _isAuthProcessing: $_isAuthProcessing');
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

  Future<void> _syncProfileFromSupabase() async {
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
          profileWithSocialAuth['primary_provider'] = user.appMetadata['provider'] ?? 'google';
          profileWithSocialAuth['linked_providers'] = [user.appMetadata['provider'] ?? 'google'];
          
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
            debugPrint('Social auth columns not found, creating profile without them...');
            try {
              await Supabase.instance.client
                  .from('user_profiles')
                  .insert(profileData);
              debugPrint('Profile created successfully without social auth columns');
              
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
    print('🔍 _checkAuthState: Starting auth check, _isCheckingAuth is $_isCheckingAuth');
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      // If no session, stay on landing page
      if (session == null) {
        debugPrint('No session found, staying on landing page');
        print('🔍 _checkAuthState: Setting _isCheckingAuth to false');
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
            print('✅ _checkAuthState: _isCheckingAuth set to false');
          });
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
    } finally {
      print('🔍 _checkAuthState: Finally block - setting _isCheckingAuth to false');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
          print('✅ _checkAuthState: Finally - _isCheckingAuth set to false');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
    print('🍎 _handleAppleLogin() called');
    print('🍎 _isAuthProcessing at start: $_isAuthProcessing');
    
    if (_isAuthProcessing) {
      print('🍎 Already processing, returning early');
      return;
    }
    
    print('🍎 Setting _isAuthProcessing to true');
    setState(() => _isAuthProcessing = true);
    _startAuthTimeout(); // 타임아웃 시작
    
    try {
      print('🍎 Calling _socialAuthService.signInWithApple()');
      // Apple OAuth 로그인 - SocialAuthService 사용
      final result = await _socialAuthService.signInWithApple();
      
      print('🍎 signInWithApple() result: $result');
      
      if (result != null) {
        // Native Apple Sign-In 성공
        print('🍎 Native Apple Sign-In successful');
        
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
        print('🍎 OAuth flow initiated');
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
      print('🍎 Apple login error: $e');
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.errorRedDark
                : TossDesignSystem.errorRed));
      }
    } finally {
      print('🍎 Setting _isAuthProcessing to false');
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    if (_isAuthProcessing) return;
    
    setState(() => _isAuthProcessing = true);
    _startAuthTimeout(); // 타임아웃 시작
    
    try {
      // Naver OAuth 로그인 - SocialAuthService 사용
      final result = await _socialAuthService.signInWithNaver();
      
      if (result != null) {
        // Naver Sign-In 성공
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('네이버 로그인 성공!'),
              backgroundColor: TossDesignSystem.successGreen,
            )
          );
        }
      } else {
        // OAuth 방식인 경우
        // _startAuthTimeout(); // 이미 시작됨
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('네이버 로그인을 처리하고 있습니다...')
            )
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네이버 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.errorRedDark
                : TossDesignSystem.errorRed
          )
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Instagram 로그인은 준비 중입니다.'),
            backgroundColor: TossDesignSystem.warningOrange
          )
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TikTok 로그인은 준비 중입니다.'),
            backgroundColor: TossDesignSystem.warningOrange
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  void _startOnboarding() async {
    // Navigate directly to onboarding flow
    context.go('/onboarding');
  }

  void _showSocialLoginBottomSheet() async {
    // Modal 표시 전에 항상 인증 상태 초기화
    if (_isAuthProcessing) {
      setState(() => _isAuthProcessing = false);
      _authTimeoutTimer?.cancel();
    }
    
    // Modal이 닫힐 때 처리하는 로직 추가
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark50
                : TossDesignSystem.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.grayDark300
                      : TossDesignSystem.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
      controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
      children: [
                      // Title
                      Text(
                        '시작하기',
                        style: TextStyle(
      fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark900
                              : TossDesignSystem.gray900,
                          letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      Text(
                        '소셜 계정으로 간편하게 시작해보세요',
                        style: TextStyle(
      fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark700
                              : TossDesignSystem.gray700)),
                      
                      const SizedBox(height: 40),
                      
                      // Social Login Buttons
                      Column(
                        children: [
                          // Google Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Google');
                            },
                            type: 'google'),
                          const SizedBox(height: 12),
                          
                          // Apple Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () async {
                              print('🍎 Apple login button clicked');
                              print('🍎 _isAuthProcessing: $_isAuthProcessing');
                              
                              // 모달을 먼저 닫기
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              // 잠시 기다렸다가 로그인 처리 (UI가 완전히 업데이트되도록)
                              await Future.delayed(Duration(milliseconds: 100));
                              _handleAppleLogin();
                            },
                            type: 'apple'),
                          const SizedBox(height: 12),
                          
                          // Kakao Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Kakao');
                            },
                            type: 'kakao'),
                          const SizedBox(height: 12),
                          
                          // Naver Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleNaverLogin();
                            },
                            type: 'naver'),
                          const SizedBox(height: 12),
                          
                          // Instagram Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleInstagramLogin();
                            },
                            type: 'instagram'),
                          const SizedBox(height: 12),
                          
                          // TikTok Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleTikTokLogin();
                            },
                            type: 'tiktok')]),
                      
                      const SizedBox(height: 30),
                      
                      Divider(
                        height: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark300
                            : TossDesignSystem.gray300,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Terms text
                      Text(
                        '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark600
                              : TossDesignSystem.gray700,
                          height: 1.5),
                        textAlign: TextAlign.center),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
    
    // Modal이 닫힌 후 처리
    // result가 null이면 사용자가 직접 modal을 닫은 것
    // _isAuthProcessing이 true이면 OAuth 진행 중이었던 것
    if (result == null && _isAuthProcessing) {
      // OAuth 진행 중에 modal이 닫혔다면 상태 초기화
      _resetAuthProcessing();
    }
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
                      valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.white)),
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
        final keys = prefs.getKeys().where((key) => 
          key.contains('fortune-auth-token-code-verifier') || 
          (key.contains('code-verifier') && !key.startsWith('sb-'))
        ).toList();
        
        for (final key in keys) {
          await prefs.remove(key);
        }
        
        // Google Sign-In OAuth 사용
        try {
          final response = await _socialAuthService.signInWithGoogle();
          
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
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
                      valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.white)),
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
          final response = await _socialAuthService.signInWithKakao();
          
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
            debugPrint('🟡 Kakao OAuth flow initiated, waiting for callback...');
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('인스타그램 로그인은 현재 준비 중입니다.'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.warningOrange
                  : TossDesignSystem.warningOrange));
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
    print('🎨 Building LandingPage: _isCheckingAuth=$_isCheckingAuth, _isAuthProcessing=$_isAuthProcessing');
    
    // Build 시마다 OAuth 상태 체크
    if (_isAuthProcessing) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        // 세션이 없는데 아직 processing 중이면 즉시 리셋
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('🔄 Build detected no session while auth processing - resetting');
          _resetAuthProcessing();
        });
      }
    }
    
    if (_isCheckingAuth) {
      print('🅿️ Showing loading screen because _isCheckingAuth is true');
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
              ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2.seconds),
              const SizedBox(height: 16),
              Text(
                '로그인 상태를 확인하고 있습니다...',
                style: TextStyle(
                  fontSize: 16,
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
                        Color(0xFF1a1a2e),  // 진한 남색
                        Color(0xFF16213e),  // 어두운 파란색
                        Color(0xFF0f1624),  // 거의 검정
                        Color(0xFF1a1a2e),  // 진한 남색
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF5E6FF),  // 연한 보라
                        Color(0xFFFFE6F0),  // 연한 핑크
                        Color(0xFFFFEFE6),  // 연한 살구색
                        Color(0xFFFFF9E6),  // 연한 노란색
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
                      Color(0xFFE8B4FF).withValues(alpha: 0.5),  // 보라색
                      Color(0xFFE8B4FF).withValues(alpha: 0.3),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(begin: 0, end: 50, duration: 15.seconds, curve: Curves.easeInOut)
                .moveY(begin: 0, end: 30, duration: 20.seconds, curve: Curves.easeInOut),
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
                      Color(0xFFFFB4B4).withValues(alpha: 0.5),  // 분홍색
                      Color(0xFFFFB4B4).withValues(alpha: 0.3),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(begin: 0, end: -40, duration: 18.seconds, curve: Curves.easeInOut)
                .moveY(begin: 0, end: -40, duration: 22.seconds, curve: Curves.easeInOut),
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
                      Color(0xFFFFE4B4).withValues(alpha: 0.4),  // 노란색
                      Color(0xFFFFE4B4).withValues(alpha: 0.2),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(begin: 0, end: 60, duration: 25.seconds, curve: Curves.easeInOut)
                .moveY(begin: 0, end: -30, duration: 20.seconds, curve: Curves.easeInOut),
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
                      Color(0xFF6B46C1).withValues(alpha: 0.15),  // 보라색
                      Color(0xFF6B46C1).withValues(alpha: 0.08),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(begin: 0, end: 50, duration: 15.seconds, curve: Curves.easeInOut)
                .moveY(begin: 0, end: 30, duration: 20.seconds, curve: Curves.easeInOut),
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
                      Color(0xFF2563EB).withValues(alpha: 0.15),  // 파란색
                      Color(0xFF2563EB).withValues(alpha: 0.08),
                      TossDesignSystem.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(begin: 0, end: -40, duration: 18.seconds, curve: Curves.easeInOut)
                .moveY(begin: 0, end: -40, duration: 22.seconds, curve: Curves.easeInOut),
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
                      
                      final themeNotifier = ref.read(themeModeProvider.notifier);
                      final isDark = themeNotifier.isDarkMode(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isDark ? '다크 모드로 전환되었습니다' : '라이트 모드로 전환되었습니다'),
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                        ).animate()
                          .fadeIn(duration: 800.ms)
                          .scale(
                            begin: Offset(0.8, 0.8),
                            end: Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 40),
                        
                        // App Name
                        Text(
                          'Fortune',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -1),
                        ).animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms),
                        
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text(
                          '매일 새로운 운세를 만나보세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.grayDark400
                                : TossDesignSystem.gray600),
                        ).animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms),
                        
                        const SizedBox(height: 80),

                        // Start Button with Hero Animation
                        Hero(
                          tag: 'start-button-hero',
                          child: Material(
                            color: TossDesignSystem.white.withValues(alpha: 0.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _startOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                                      ? TossDesignSystem.white
                                      : TossDesignSystem.black,
                                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                                      ? TossDesignSystem.black
                                      : TossDesignSystem.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  '시작하기',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ).animate()
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

  Widget _buildSocialLoginButton({
    required VoidCallback? onPressed,
    required String type,
    required int delay}) {
    Widget icon;
    String text;
    Color? backgroundColor;
    Color? foregroundColor;
    
    switch (type) {
      case 'apple':
        icon = Icon(Icons.apple, size: 24, color: TossDesignSystem.white);
        text = 'Apple로 계속하기';
        backgroundColor = TossDesignSystem.black;
        foregroundColor = TossDesignSystem.white;
        break;
      case 'google':
        // Use icon instead of network image to prevent loading issues on real devices
        icon = Icon(Icons.g_mobiledata, size: 24, color: TossDesignSystem.tossBlue);
        text = 'Google로 계속하기';
        backgroundColor = TossDesignSystem.white;
        foregroundColor = TossDesignSystem.black;
        break;
      case 'kakao':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xFFFEE500),
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              'K',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.black),
            ),
          ),
        );
        text = '카카오로 계속하기';
        backgroundColor = Color(0xFFFEE500);
        foregroundColor = TossDesignSystem.black;
        break;
      case 'naver':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xFF03C75A),
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.white),
            ),
          ),
        );
        text = '네이버로 계속하기';
        backgroundColor = Color(0xFF03C75A);
        foregroundColor = TossDesignSystem.white;
        break;
      default:
        icon = Container();
        text = '';
        backgroundColor = TossDesignSystem.gray300;
        foregroundColor = TossDesignSystem.white;
    }
    
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: type == 'google'
                ? BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark300
                        : TossDesignSystem.gray300,
                    width: 1)
                : BorderSide.none),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildModernSocialButton({
    required VoidCallback? onPressed,
    required String type}) {
    Widget icon;
    String text;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 라이트모드와 다크모드에서 모두 읽기 쉽도록 배경과 텍스트 색상 개선
    final backgroundColor = isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white;
    final foregroundColor = isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;
    final borderColor = isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300;
    
    switch (type) {
      case 'apple':
        icon = SvgPicture.asset(
          'assets/images/social/apple.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        );
        text = 'Apple로 계속하기';
        break;
      case 'google':
        icon = SvgPicture.asset(
          'assets/images/social/google.svg',
          width: 24,
          height: 24,
        );
        text = 'Google로 계속하기';
        break;
      case 'kakao':
        icon = SvgPicture.asset(
          'assets/images/social/kakao.svg',
          width: 24,
          height: 24,
        );
        text = '카카오로 계속하기';
        break;
      case 'naver':
        icon = SvgPicture.asset(
          'assets/images/social/naver.svg',
          width: 24,
          height: 24,
        );
        text = '네이버로 계속하기';
        break;
      case 'instagram':
        icon = SvgPicture.asset(
          'assets/images/social/instagram.svg',
          width: 24,
          height: 24,
        );
        text = 'Instagram으로 계속하기';
        break;
      case 'tiktok':
        icon = SvgPicture.asset(
          'assets/images/social/tiktok.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        );
        text = 'TikTok으로 계속하기';
        break;
      default:
        icon = Container();
        text = '';
    }
    
    // 디버깅: 버튼 상태 로그
    if (type == 'apple') {
      print('🔴 Building Apple button - onPressed: ${onPressed != null ? 'enabled' : 'disabled'}');
    }
    
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: borderColor ?? TossDesignSystem.white.withValues(alpha: 0.0),
              width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTikTokStyleButton({
    required VoidCallback? onPressed,
    required String type}) {
    Widget icon;
    String text;
    
    switch (type) {
      case 'apple':
        icon = Icon(Icons.apple, size: 24, color: TossDesignSystem.black);
        text = 'Continue with Apple';
        break;
      case 'google':
        icon = Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) => 
              Icon(Icons.g_mobiledata, size: 24, color: TossDesignSystem.tossBlue),
        );
        text = 'Continue with Google';
        break;
      case 'kakao':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xFFFEE500),
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              'K',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.black),
            ),
          ),
        );
        text = 'Continue with Kakao';
        break;
      case 'naver':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xFF03C75A),
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.white),
            ),
          ),
        );
        text = 'Continue with Naver';
        break;
      case 'instagram':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF000000),
                Color(0xFF333333),
                Color(0xFF666666)]),
            shape: BoxShape.circle),
          child: Icon(
            Icons.camera_alt,
            size: 16,
            color: TossDesignSystem.white),
        );
        text = 'Continue with Instagram';
        break;
      default:
        icon = Container();
        text = '';
    }
    
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.white
              : TossDesignSystem.black,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.black
              : TossDesignSystem.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.gray300
                  : TossDesignSystem.gray800,
              width: 1),
          ),
        ),
        child: Row(
          children: [
            icon,
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.black
                      : TossDesignSystem.white),
                textAlign: TextAlign.center),
            ),
            SizedBox(width: 24), // Balance the icon on left
          ],
        ),
      ),
    );
  }
}