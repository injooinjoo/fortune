import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/social_auth_provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../core/utils/logger.dart';

enum SocialProvider {
  google,
  apple,
  facebook,
  kakao,
  naver,
}

class SocialLoginStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const SocialLoginStep({
    Key? key,
    required this.onNext,
    this.onSkip,
  }) : super(key: key);

  @override
  ConsumerState<SocialLoginStep> createState() => _SocialLoginStepState();
}

class _SocialLoginStepState extends ConsumerState<SocialLoginStep> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSocialLogin(SocialProvider provider) async {
    print('🔵 [SocialLoginStep] _handleSocialLogin called with provider: $provider');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔵 [SocialLoginStep] Getting socialAuthNotifier...');
      final socialAuthNotifier = ref.read(socialAuthProvider.notifier);
      print('🔵 [SocialLoginStep] socialAuthNotifier obtained');
      
      // Call the appropriate sign-in method based on provider
      switch (provider) {
        case SocialProvider.google:
          print('🔵 [SocialLoginStep] Calling signInWithGoogle()...');
          await socialAuthNotifier.signInWithGoogle();
          print('🔵 [SocialLoginStep] signInWithGoogle() completed');
          break;
        case SocialProvider.apple:
          print('🔵 [SocialLoginStep] Calling signInWithApple()...');
          await socialAuthNotifier.signInWithApple();
          print('🔵 [SocialLoginStep] signInWithApple() completed');
          break;
        case SocialProvider.facebook:
          await socialAuthNotifier.signInWithFacebook();
          break;
        case SocialProvider.kakao:
          await socialAuthNotifier.signInWithKakao();
          break;
        case SocialProvider.naver:
          await socialAuthNotifier.signInWithNaver();
          break;
      }
      
      // Wait a moment for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 로그인 성공 후 사용자 정보 확인
      final authService = ref.read(authServiceProvider);
      final hasProfile = await authService.hasUserProfile();
      
      if (hasProfile) {
        // 프로필이 이미 있으면 홈으로 이동
        if (context.mounted) {
          context.go('/home');
        }
      } else {
        // 프로필이 없으면 다음 온보딩 단계로
        widget.onNext();
      }
    } catch (e) {
      Logger.error('소셜 로그인 실패', e);
      setState(() {
        _errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: textColor ?? Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          '거의 다 왔습니다!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '계정을 연결하면 모든 기기에서\n운세를 확인할 수 있습니다',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        _buildSocialButton(
          label: '구글로 계속하기',
          icon: Image.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
          ),
          onPressed: () => _handleSocialLogin(SocialProvider.google),
        ),

        _buildSocialButton(
          label: 'Apple로 계속하기',
          icon: Icon(Icons.apple, size: 24, color: Colors.white),
          onPressed: () => _handleSocialLogin(SocialProvider.apple),
          backgroundColor: Colors.black,
          textColor: Colors.white,
        ),

        _buildSocialButton(
          label: 'Facebook으로 계속하기',
          icon: Icon(Icons.facebook, size: 24, color: Colors.white),
          onPressed: () => _handleSocialLogin(SocialProvider.facebook),
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        ),

        _buildSocialButton(
          label: '카카오로 계속하기',
          icon: Image.network(
            'https://developers.kakao.com/static/images/pc/product/icon/kakaoTalk.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) => 
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'K',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFEE500),
                      ),
                    ),
                  ),
                ),
          ),
          onPressed: () => _handleSocialLogin(SocialProvider.kakao),
          backgroundColor: const Color(0xFFFEE500),
          textColor: Colors.black87,
        ),

        _buildSocialButton(
          label: '네이버로 계속하기',
          icon: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'N',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF03C75A),
                ),
              ),
            ),
          ),
          onPressed: () => _handleSocialLogin(SocialProvider.naver),
          backgroundColor: const Color(0xFF03C75A),
          textColor: Colors.white,
        ),

        const SizedBox(height: 24),

        if (widget.onSkip != null)
          TextButton(
            onPressed: _isLoading ? null : widget.onSkip,
            child: Text(
              '나중에 하기',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),

        if (_isLoading) ...[
          const SizedBox(height: 24),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }
}