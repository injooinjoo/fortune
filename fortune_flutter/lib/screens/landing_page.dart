import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
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
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _checkUrlParameters();
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      debugPrint('Landing page auth state changed: ${data.event}');
      if (data.session != null && mounted) {
        debugPrint('User logged in, checking profile...');
        
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

  Future<void> _checkAuthState() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
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
      debugPrint('Auth check error: $e');
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
      debugPrint('Apple login error: $e');
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
      debugPrint('Naver login error: $e');
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
    // Show social login bottom sheet
    _showSocialLoginBottomSheet();
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
                margin: EdgeInsets.only(top: 12),
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
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                          
                          // Apple Login (iOS only)
                          if (!kIsWeb && Platform.isIOS) ...[  
                            _buildModernSocialButton(
                              onPressed: _isAuthProcessing ? null : () {
                                Navigator.pop(context);
                                _handleAppleLogin();
                              },
                              type: 'apple',
                            ),
                            const SizedBox(height: 12),
                          ],
                          
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
        // 브라우저 확장 프로그램 간섭 제거
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys().where((key) => 
          key.contains('fortune-auth-token-code-verifier') || 
          (key.contains('code-verifier') && !key.startsWith('sb-'))
        ).toList();
        
        for (final key in keys) {
          await prefs.remove(key);
        }
        
        // Google OAuth 로그인
        await _authService.signInWithGoogle();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google 로그인을 처리하고 있습니다...'),
            ),
          );
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
      debugPrint('Social login error: $e');
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

                        // Start Button
                        SizedBox(
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
                
                // Bottom section
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '서비스를 이용하시려면 위의 방법 중 하나를 선택해주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(delay: 1100.ms, duration: 600.ms),
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
            side: type == 'google' ? BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ) : BorderSide.none,
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