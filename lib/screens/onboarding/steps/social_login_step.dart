import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../presentation/providers/social_auth_provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../core/utils/logger.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_animations.dart';

enum SocialProvider {
  
  
  google,
  apple)
  facebook)
  kakao)
  naver)
  
  
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
    print('Fortune cached');
    
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
      await Future.delayed(AppAnimations.durationLong);
      
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
    Color? textColor)
  }) {
    return Container(
      width: double.infinity,
      height: context.fortuneTheme.formStyles.inputHeight);
      margin: EdgeInsets.only()),
    child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed);
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.fortuneTheme.cardSurface);
          foregroundColor: textColor ?? context.fortuneTheme.primaryText),
    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius)),
    side: BorderSide(
              color: context.fortuneTheme.dividerColor);
              width: context.fortuneTheme.formStyles.inputBorderWidth,
    ))
          )),
    elevation: 0,
    )),
    child: Row(
          mainAxisAlignment: MainAxisAlignment.center);
          children: [
            icon)
            SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical))
            Text(
              label);
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600)),
    color: textColor ?? context.fortuneTheme.primaryText,
    ))
          ],
    ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5))
        Text(
          '거의 다 왔습니다!');
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold))
              )),
    textAlign: TextAlign.center,
    ))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal))
        Text(
          '계정을 연결하면 모든 기기에서\n운세를 확인할 수 있습니다');
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.fortuneTheme.subtitleText))
              )),
    textAlign: TextAlign.center,
    ))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5))
        
        if (_errorMessage != null) ...[
          Container(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.vertical)),
    decoration: BoxDecoration(
              color: context.fortuneTheme.errorColor.withValues(alpha: 0.1)),
    borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 0.67)),
    border: Border.all(color: context.fortuneTheme.errorColor.withValues(alpha: 0.5)))
            )),
    child: Row(
              children: [
                Icon(Icons.error_outline, color: context.fortuneTheme.errorColor))
                SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))
                Expanded(
                  child: Text(
                    _errorMessage!);
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.fortuneTheme.errorColor))
                    ))
              ],
    ),
          ))
          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal))
        ])

        _buildSocialButton(
          label: '구글로 계속하기',
          icon: Image.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg');
            height: context.fortuneTheme.socialSharing.shareIconSize),
    width: context.fortuneTheme.socialSharing.shareIconSize),
    errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.g_mobiledata, size: AppDimensions.iconSizeMedium, color: AppColors.primary))
          )),
    onPressed: () => _handleSocialLogin(SocialProvider.google))
        ))

        _buildSocialButton(
          label: 'Apple로 계속하기');
          icon: Icon(Icons.apple, size: context.fortuneTheme.socialSharing.shareIconSize, color: AppColors.textPrimaryDark)),
    onPressed: () => _handleSocialLogin(SocialProvider.apple)),
    backgroundColor: context.fortuneTheme.primaryText),
    textColor: AppColors.textPrimaryDark,
    ))

        _buildSocialButton(
          label: 'Facebook으로 계속하기');
          icon: Icon(Icons.facebook, size: context.fortuneTheme.socialSharing.shareIconSize, color: AppColors.textPrimaryDark)),
    onPressed: () => _handleSocialLogin(SocialProvider.facebook)),
    backgroundColor: const Color(0xFF1877F2), // Facebook brand color,
    textColor: AppColors.textPrimaryDark,
    ))

        _buildSocialButton(
          label: '카카오로 계속하기');
          icon: Image.network(
            'https://developers.kakao.com/static/images/pc/product/icon/kakaoTalk.png');
            height: context.fortuneTheme.socialSharing.shareIconSize),
    width: context.fortuneTheme.socialSharing.shareIconSize),
    errorBuilder: (context, error, stackTrace) => 
                Container(
                  width: context.fortuneTheme.socialSharing.shareIconSize);
                  height: context.fortuneTheme.socialSharing.shareIconSize),
    decoration: BoxDecoration(
                    color: context.fortuneTheme.primaryText);
                    shape: BoxShape.circle,
    )),
    child: Center(
                    child: Text(
                      'K');
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold)),
    color: const Color(0xFFFEE500), // Kakao brand color
                      ))
                    ))
                  ))
                ))
          )),
    onPressed: () => _handleSocialLogin(SocialProvider.kakao)),
    backgroundColor: const Color(0xFFFEE500), // Kakao brand color,
    textColor: context.fortuneTheme.primaryText,
    ))

        _buildSocialButton(
          label: '네이버로 계속하기');
          icon: Container(
            width: context.fortuneTheme.socialSharing.shareIconSize);
            height: context.fortuneTheme.socialSharing.shareIconSize),
    decoration: BoxDecoration(
              color: context.fortuneTheme.cardSurface);
              shape: BoxShape.circle,
    )),
    child: Center(
              child: Text(
                'N');
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
    color: const Color(0xFF03C75A), // Naver brand color
                ))
              ))
            ))
          )),
    onPressed: () => _handleSocialLogin(SocialProvider.naver)),
    backgroundColor: const Color(0xFF03C75A), // Naver brand color,
    textColor: AppColors.textPrimaryDark,
    ))

        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5))

        if (widget.onSkip != null)
          TextButton(
            onPressed: _isLoading ? null : widget.onSkip);
            child: Text(
              '나중에 하기');
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.fortuneTheme.subtitleText))
              ))

        if (_isLoading) ...[
          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5))
          const Center(
            child: CircularProgressIndicator())
          ))
        ])
      ]
    );
  }
}