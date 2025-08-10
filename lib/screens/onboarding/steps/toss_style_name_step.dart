import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/toss_theme.dart';
import '../../../services/social_auth_service.dart';
import '../../../core/utils/logger.dart';
import '../../landing_page.dart';

class TossStyleNameStep extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  
  const TossStyleNameStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
  });

  @override
  State<TossStyleNameStep> createState() => _TossStyleNameStepState();
}

class _TossStyleNameStepState extends State<TossStyleNameStep> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  late final SocialAuthService _socialAuthService;
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _socialAuthService = SocialAuthService(Supabase.instance.client);
    _isValid = _nameController.text.isNotEmpty;
    
    _nameController.addListener(() {
      setState(() {
        _isValid = _nameController.text.trim().isNotEmpty;
      });
      widget.onNameChanged(_nameController.text.trim());
    });
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSocialLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Title
                    Text(
                      '기존 계정으로 로그인하세요',
                      style: TossTheme.heading2.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Loading indicator
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      )
                    else ...[                    
                      // Social Login Buttons (unified design)
                      _buildSocialLoginButton(
                      context: context,
                      label: 'Google로 계속하기',
                      logoPath: 'assets/images/social/google.svg',
                      onTap: () => _handleSocialLogin('google'),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: 'Apple로 계속하기',
                      logoPath: 'assets/images/social/apple.svg',
                      onTap: () => _handleSocialLogin('apple'),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: '카카오로 계속하기',
                      logoPath: 'assets/images/social/kakao.svg',
                      onTap: () => _handleSocialLogin('kakao'),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: '네이버로 계속하기',
                      logoPath: 'assets/images/social/naver.svg',
                      onTap: () => _handleSocialLogin('naver'),
                    ),
                    ],  // Close the else block for loading
                    
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
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    // Close the bottom sheet first
    Navigator.pop(context);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      AuthResponse? response;
      
      switch (provider) {
        case 'google':
          response = await _socialAuthService.signInWithGoogle();
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
        // Login successful, navigate to home
        context.go('/home');
      }
      // For OAuth flows, the auth state listener will handle navigation
      
    } catch (error) {
      Logger.error('소셜 로그인 실패: $provider', error);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Reopen the bottom sheet for retry
        _showSocialLoginBottomSheet(context);
      }
    }
  }
  
  Widget _buildSocialLoginButton({
    required BuildContext context,
    required String label,
    required String logoPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
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
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer to center the input field
            const Spacer(),
            
            // Center content - Input field only
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _nameController,
                focusNode: _focusNode,
                style: TossTheme.inputStyle,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '이름을 알려주세요',
                  hintStyle: TossTheme.inputStyle.copyWith(
                    color: TossTheme.textGray400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 800),
              ),
            ),
            
            const Spacer(),
            
            // Bottom button area - Only show when text is entered
            AnimatedOpacity(
              opacity: _isValid ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isValid ? 58 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                margin: EdgeInsets.only(
                  bottom: _isValid ? 24.0 : 0,
                ),
                child: _isValid
                    ? SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: widget.onNext,
                          style: TossTheme.primaryButtonStyle(true),
                          child: Text(
                            '다음',
                            style: TossTheme.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            
            // "계정이 있어요" link at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: GestureDetector(
                onTap: () => _showSocialLoginBottomSheet(context),
                child: Text(
                  '계정이 있어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossTheme.textGray600,
                    decoration: TextDecoration.underline,
                    decorationColor: TossTheme.textGray600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}