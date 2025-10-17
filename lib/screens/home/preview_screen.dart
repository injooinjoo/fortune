import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/toss_theme.dart';
import '../../core/theme/toss_design_system.dart';
import '../../services/social_auth_service.dart';
import '../../core/utils/logger.dart';

class PreviewScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onContinueWithoutLogin;
  
  const PreviewScreen({
    super.key,
    this.onLoginSuccess,
    this.onContinueWithoutLogin,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with TickerProviderStateMixin {
  late final SocialAuthService _socialAuthService;
  bool _bottomSheetLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(Supabase.instance.client);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showSocialLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      builder: (context) => Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark100
              : TossDesignSystem.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return _buildBottomSheetContent(setBottomSheetState);
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(StateSetter setBottomSheetState) {
    return Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Title
                Text(
                  '나만의 운세를 확인하세요',
                  style: TossTheme.heading2.copyWith(
                    fontSize: 20,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Loading indicator
                if (_bottomSheetLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  // Social Login Buttons
                  _buildSocialLoginButton(
                    context: context,
                    label: 'Google로 계속하기',
                    logoPath: 'assets/images/social/google.svg',
                    onTap: () => _handleSocialLoginInBottomSheet('google', setBottomSheetState),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSocialLoginButton(
                    context: context,
                    label: 'Apple로 계속하기',
                    logoPath: 'assets/images/social/apple.svg',
                    onTap: () => _handleSocialLoginInBottomSheet('apple', setBottomSheetState),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSocialLoginButton(
                    context: context,
                    label: '카카오로 계속하기',
                    logoPath: 'assets/images/social/kakao.svg',
                    onTap: () => _handleSocialLoginInBottomSheet('kakao', setBottomSheetState),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSocialLoginButton(
                    context: context,
                    label: '네이버로 계속하기',
                    logoPath: 'assets/images/social/naver.svg',
                    onTap: () => _handleSocialLoginInBottomSheet('naver', setBottomSheetState),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Terms text
                Text(
                  '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: TossTheme.textGray600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSocialLoginInBottomSheet(String provider, StateSetter setBottomSheetState) async {
    setBottomSheetState(() {
      _bottomSheetLoading = true;
    });
    
    try {
      AuthResponse? response;
      
      switch (provider) {
        case 'google':
          response = await _socialAuthService.signInWithGoogle(context: context);
          break;
        case 'apple':
          response = await _socialAuthService.signInWithApple();
          break;
        case 'kakao':
          response = await _socialAuthService.signInWithKakao();
          break;
        case 'naver':
          response = await _socialAuthService.signInWithNaver();
          break;
      }
      
      // OAuth flows return null (handled by deep linking)
      // Direct auth flows return AuthResponse
      if (response != null && response.user != null && mounted) {
        // Close bottom sheet and call success callback
        Navigator.pop(context);
        widget.onLoginSuccess?.call();
      } else {
        // For OAuth flows, close bottom sheet and let auth state listener handle navigation
        Navigator.pop(context);
        widget.onLoginSuccess?.call();
      }
      
    } catch (error) {
      Logger.error('소셜 로그인 실패: $provider', error);
      
      if (mounted) {
        setBottomSheetState(() {
          _bottomSheetLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }
  
  Widget _buildSocialLoginButton({
    required BuildContext context,
    required String label,
    required String logoPath,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.white,
          border: Border.all(
            color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              logoPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? TossDesignSystem.white : TossDesignSystem.grayDark900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Main content
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        '오늘의 이야기가\n완성되었어요!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        '로그인하고 나만의 맞춤 운세를\n확인해보세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Preview button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => _showSocialLoginBottomSheet(context),
                          style: TossTheme.primaryButtonStyle(true),
                          child: Text(
                            '내 미래 미리보기',
                            style: TossTheme.button.copyWith(
                              color: TossDesignSystem.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Continue without login
                      GestureDetector(
                        onTap: widget.onContinueWithoutLogin,
                        child: Text(
                          '로그인 없이 보기',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                            decoration: TextDecoration.underline,
                            decorationColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}