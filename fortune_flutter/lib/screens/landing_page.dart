import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/icons/fortune_compass_icon.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isDarkMode = false;
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
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('Landing page auth state changed: ${data.event}');
      if (data.session != null && mounted) {
        debugPrint('User logged in, redirecting to home...');
        context.go('/home');
      }
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session?.user != null) {
        // 로그인된 사용자 - 프로필 확인
        final profile = await _storageService.getUserProfile();
        
        if (profile != null && profile['onboarding_completed'] == true) {
          // returnUrl 확인
          final uri = Uri.base;
          final returnUrl = uri.queryParameters['returnUrl'];
          if (returnUrl != null) {
            context.go(Uri.decodeComponent(returnUrl));
          } else {
            context.go('/home');
          }
          return;
        }
      } else {
        // 게스트 사용자 확인
        final guestProfile = await _storageService.getUserProfile();
        
        if (guestProfile != null && guestProfile['onboarding_completed'] == true) {
          final uri = Uri.base;
          final returnUrl = uri.queryParameters['returnUrl'];
          if (returnUrl != null) {
            context.go(Uri.decodeComponent(returnUrl));
          } else {
            context.go('/home');
          }
          return;
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
      });
    }
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [Colors.grey[900]!, Colors.purple[900]!, Colors.grey[900]!]
                  : [Colors.purple[50]!, Colors.white, Colors.pink[50]!],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FortuneCompassIcon(
                  size: 64,
                  color: _isDarkMode ? Colors.purple[400] : Colors.purple[600],
                ).animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2.seconds),
                const SizedBox(height: 16),
                Text(
                  '로그인 상태를 확인하고 있습니다...',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [Colors.grey[900]!, Colors.purple[900]!, Colors.grey[900]!]
                : [Colors.purple[50]!, Colors.white, Colors.pink[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FortuneCompassIcon(
                          size: 32,
                          color: _isDarkMode ? Colors.purple[400] : Colors.purple[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '운세',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _isDarkMode = !_isDarkMode);
                      },
                      icon: Icon(
                        _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                        color: _isDarkMode ? Colors.yellow[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 메인 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // 히어로 섹션
                      FortuneCompassIcon(
                        size: 96,
                        color: _isDarkMode ? Colors.purple[400] : Colors.purple[600],
                      ).animate()
                        .fadeIn(duration: 600.ms)
                        .scale(delay: 300.ms),
                      
                      const SizedBox(height: 32),
                      
                      // 게스트로 시작하기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go('/onboarding/profile'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: BorderSide(
                              color: _isDarkMode ? Colors.purple[400]! : Colors.purple[600]!,
                            ),
                          ),
                          child: Text(
                            '게스트로 시작하기',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDarkMode ? Colors.purple[400] : Colors.purple[600],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[400])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[400])),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 소셜 로그인 버튼들
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAuthProcessing 
                              ? null 
                              : () => _handleSocialLogin('Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
                            foregroundColor: _isDarkMode ? Colors.grey[200] : Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                              ),
                            ),
                          ),
                          child: Text(
                            _isAuthProcessing ? '로그인 중...' : 'Google로 시작하기',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAuthProcessing 
                              ? null 
                              : () => _handleSocialLogin('Kakao'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[400],
                            foregroundColor: Colors.grey[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            '카카오로 시작하기',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // 기능 카드들
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              icon: Icons.star,
                              iconColor: Colors.purple,
                              title: '개인화된 운세',
                              description: '당신만의 특별한 운세를 받아보세요',
                              onTap: () => context.go('/fortune'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFeatureCard(
                              icon: Icons.auto_awesome,
                              iconColor: Colors.blue,
                              title: '심리테스트',
                              description: '5가지 질문으로 알아보는 나의 성격',
                              onTap: () => context.go('/interactive/psychology-test'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        icon: Icons.nightlight_round,
                        iconColor: Colors.pink,
                        title: '유명인 운세',
                        description: '당신과 닮은 유명인의 운세 확인',
                        onTap: () => context.go('/fortune/celebrity'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 푸터
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Text(
                  '© 2024 Fortune. 모든 권리 보유.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isDarkMode 
                    ? iconColor.withOpacity(0.2) 
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 24,
                color: _isDarkMode 
                    ? iconColor.withOpacity(0.8) 
                    : iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .scale(delay: 200.ms, duration: 600.ms),
    );
  }
}