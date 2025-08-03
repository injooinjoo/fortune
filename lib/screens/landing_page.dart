import 'dart:io';
import 'dart:math' as math;
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

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  bool _isCheckingAuth = true;
  bool _isAuthProcessing = false;
  final _authService = AuthService();
  late final SocialAuthService _socialAuthService;
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(Supabase.instance.client);
    _checkAuthState();
    _checkUrlParameters();
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      debugPrint('changed: ${data.event}');
      if (data.session != null && mounted) {
        debugPrint('User logged in, checking profile...');
        
        // Try to sync profile from Supabase first
        await _syncProfileFromSupabase();
        
        // Check if user needs onboarding
        final needsOnboarding = await ProfileValidation.needsOnboarding();
        if (needsOnboarding && mounted) {
          debugPrint('Profile incomplete, redirecting to onboarding...');
          context.go('/onboarding/flow');
        } else if (mounted) {
          debugPrint('Profile complete, redirecting to home...');
          context.go('/home');
        }
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
          'updated_at': null,
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
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      // Try to sync profile from Supabase first
      if (session != null) {
        await _syncProfileFromSupabase();
      }
      
      // Check if user (authenticated or guest) needs onboarding
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
      if (mounted) {
        setState(() => _isCheckingAuth = false);
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
            backgroundColor: Colors.red,
          ),
        );
        
        // Clean error parameter from URL after showing message
        if (kIsWeb) {
          final cleanUrl = uri.path;
          cleanUrlInBrowser(cleanUrl);
        }
      });
    }
  }

  Future<void> _handleAppleLogin() async {
    if (_isAuthProcessing) return;
    
    setState(() => _isAuthProcessing = true);
    
    try {
      // Apple OAuth 로그인
      await _authService.signInWithApple();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple 로그인을 처리하고 있습니다...'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    if (_isAuthProcessing) return;
    
    setState(() => _isAuthProcessing = true);
    
    try {
      // Naver OAuth 로그인
      await _authService.signInWithNaver();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네이버 로그인을 처리하고 있습니다...'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('네이버 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
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
          const SnackBar(
            content: Text('Instagram 로그인은 준비 중입니다.'),
            backgroundColor: Colors.orange,
          ),
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
          const SnackBar(
            content: Text('TikTok 로그인은 준비 중입니다.'),
            backgroundColor: Colors.orange,
          ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
      topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
      children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
      color: Colors.grey[300],
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
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '소셜 계정으로 간편하게 시작해보세요',
                        style: TextStyle(
      fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      
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
                            type: 'google',
                          ),
                          const SizedBox(height: 12),
                          
                          // Apple Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleAppleLogin();
                            },
                            type: 'apple',
                          ),
                          const SizedBox(height: 12),
                          
                          // Kakao Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Kakao');
                            },
                            type: 'kakao',
                          ),
                          const SizedBox(height: 12),
                          
                          // Naver Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleNaverLogin();
                            },
                            type: 'naver',
                          ),
                          const SizedBox(height: 12),
                          
                          // Instagram Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleInstagramLogin();
                            },
                            type: 'instagram',
                          ),
                          const SizedBox(height: 12),
                          
                          // TikTok Login
                          _buildModernSocialButton(
                            onPressed: _isAuthProcessing ? null : () {
                              Navigator.pop(context);
                              _handleTikTokLogin();
                            },
                            type: 'tiktok',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      Divider(height: 1),
                      
                      const SizedBox(height: 20),
                      
                      // Terms text
                      Text(
                        '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                        style: TextStyle(
      fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isAuthProcessing) return;
    
    setState(() => _isAuthProcessing = true);
    
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
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
        
        // Google Sign-In SDK 사용
        try {
          final response = await _socialAuthService.signInWithGoogle();
          
          // 로딩 스낭바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
          
          // The auth state listener will handle navigation after successful login
          // OAuth 리다이렉트 방식은 항상 null을 반환하므로
          // 취소 메시지를 표시하지 않음
        } catch (e) {
          // 로딩 스낵바 닫기
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
          
          // Show error message
          if (mounted && e.toString().contains('Invalid API key')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('인증 서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          rethrow;
        }
      } else if (provider == 'Kakao') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카카오 로그인은 현재 준비 중입니다.'),
            ),
          );
        }
      } else if (provider == 'Instagram') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인스타그램 로그인은 현재 준비 중입니다.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthProcessing = false);
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/main_logo.svg',
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2.seconds),
              const SizedBox(height: 16),
              Text(
                '로그인 상태를 확인하고 있습니다...',
                style: TextStyle(
      fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
      children: [
          // 몽환적인 배경 효과
          // 떠다니는 원형 보케 효과
          ...List.generate(15, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 80 + 40;
            final opacity = random.nextDouble() * 0.1 + 0.05;
            final duration = random.nextInt(10) + 15;
            
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
      width: size,
                height: size,
                decoration: BoxDecoration(
      shape: BoxShape.circle,
                  gradient: RadialGradient(
      colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.withOpacity(opacity)
                          : Colors.blue.withOpacity(opacity),
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.withOpacity(opacity * 0.5)
                          : Colors.blue.withOpacity(opacity * 0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(
                  begin: -30,
                  end: 30,
                  duration: Duration(seconds: duration),
                  curve: Curves.easeInOut,
                )
                .moveY(
                  begin: -20,
                  end: 20,
                  duration: Duration(seconds: duration + 2),
                  curve: Curves.easeInOut,
                )
                .fadeIn(duration: 2000.ms),
            );
          }),
          
          // 빛나는 작은 입자들
          ...List.generate(20, (index) {
            final random = math.Random(index + 100);
            final duration = random.nextInt(5) + 10;
            
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
      width: 3,
                height: 3,
                decoration: BoxDecoration(
      shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1000.ms)
                .then(delay: Duration(seconds: random.nextInt(3)))
                .fadeOut(duration: 1000.ms)
                .then(delay: Duration(seconds: random.nextInt(2)))
                .moveY(
                  begin: 0,
                  end: -50,
                  duration: Duration(seconds: duration),
                  curve: Curves.linear,
                ),
            );
          }),
          
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
                              ? Colors.grey[700]! 
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Theme.of(context).brightness == Brightness.dark 
                            ? Icons.light_mode_outlined 
                            : Icons.dark_mode_outlined,
                        size: 24,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[300] 
                            : Colors.grey[600],
                      ),
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
                        SvgPicture.asset(
                          'assets/images/main_logo.svg',
                          width: 100,
                          height: 100,
                          colorFilter: ColorFilter.mode(
                            Colors.black87,
                            BlendMode.srcIn,
                          ),
                        ).animate()
                          .fadeIn(duration: 800.ms)
                          .scale(
                            begin: Offset(0.8, 0.8),
                            end: Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                        
                        const SizedBox(height: 40),
                        
                        // App Name
                        Text(
                          'Fortune',
                          style: TextStyle(
      fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -1,
                          ),
                        ).animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms),
                        
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text(
                          '매일 새로운 운세를 만나보세요',
                          style: TextStyle(
      fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ).animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms),
                        
                        const SizedBox(height: 80),

                        // Start Button with Hero Animation
                        Hero(
                          tag: 'start-button-hero',
                          child: Material(
      color: Colors.transparent,
                            child: SizedBox(
      width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
      onPressed: _startOnboarding,
                                style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  '시작하기',
                                  style: TextStyle(
      fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .scale(
                            begin: Offset(0.9, 0.9),
                            end: Offset(1.0, 1.0),
                            duration: 400.ms,
                          ),
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
    required int delay,
  }) {
    Widget icon;
    String text;
    Color? backgroundColor;
    Color? foregroundColor;
    
    switch (type) {
      case 'apple':
        icon = Icon(Icons.apple, size: 24, color: Colors.white);
        text = 'Apple로 계속하기';
        backgroundColor = Colors.black;
        foregroundColor = Colors.white;
        break;
      case 'google':
        icon = Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) => 
              Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
        );
        text = 'Google로 계속하기';
        backgroundColor = Colors.white;
        foregroundColor = Colors.black87;
        break;
      case 'kakao':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
      color: Color(0xFFFEE500),
            shape: BoxShape.circle,
          ),
          child: Center(
      child: Text(
              'K',
              style: TextStyle(
      fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
        text = '카카오로 계속하기';
        backgroundColor = Color(0xFFFEE500);
        foregroundColor = Colors.black87;
        break;
      case 'naver':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
      color: Color(0xFF03C75A),
            shape: BoxShape.circle,
          ),
          child: Center(
      child: Text(
              'N',
              style: TextStyle(
      fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
        text = '네이버로 계속하기';
        backgroundColor = Color(0xFF03C75A);
        foregroundColor = Colors.white;
        break;
      default:
        icon = Container();
        text = '';
        backgroundColor = Colors.grey;
        foregroundColor = Colors.white;
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
                    color: Colors.grey[300]!,
                    width: 1,
                  )
                : BorderSide.none,
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
    required String type,
  }) {
    Widget icon;
    String text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // All buttons have white background in both light and dark modes
    final backgroundColor = Colors.white;
    final foregroundColor = Colors.black87;
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[300];
    
    switch (type) {
      case 'apple':
        icon = SvgPicture.asset(
          'assets/images/social/apple.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        );
        text = 'TikTok으로 계속하기';
        break;
      default:
        icon = Container();
        text = '';
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
      color: borderColor ?? Colors.transparent,
              width: 1,
            ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTikTokStyleButton({
    required VoidCallback? onPressed,
    required String type,
  }) {
    Widget icon;
    String text;
    
    switch (type) {
      case 'apple':
        icon = Icon(Icons.apple, size: 24, color: Colors.black);
        text = 'Continue with Apple';
        break;
      case 'google':
        icon = Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) => 
              Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
        );
        text = 'Continue with Google';
        break;
      case 'kakao':
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
      color: Color(0xFFFEE500),
            shape: BoxShape.circle,
          ),
          child: Center(
      child: Text(
              'K',
              style: TextStyle(
      fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
            shape: BoxShape.circle,
          ),
          child: Center(
      child: Text(
              'N',
              style: TextStyle(
      fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                Color(0xFF666666),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt,
            size: 16,
            color: Colors.white,
          ),
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
              ? Colors.white 
              : Colors.black,
          foregroundColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black 
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(27),
            side: BorderSide(
      color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[300]! 
                  : Colors.grey[800]!,
              width: 1,
            ),
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
                      ? Colors.black 
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 24), // Balance the icon on left
          ],
        ),
      ),
    );
  }
}