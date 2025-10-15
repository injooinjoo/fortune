import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/toss_theme.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../services/social_auth_service.dart';
import '../../../core/utils/logger.dart';

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
  bool _bottomSheetLoading = false;

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
    
    // 키보드 강제 활성화를 위한 다중 접근
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 1차 시도: 기본 포커스 요청
        _focusNode.requestFocus();
        
        // 2차 시도: 약간의 지연 후 시스템 키보드 강제 활성화
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            SystemChannels.textInput.invokeMethod('TextInput.show');
          }
        });
        
        // 3차 시도: 더 긴 지연 후 재시도
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_focusNode);
            SystemChannels.textInput.invokeMethod('TextInput.show');
          }
        });
      }
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
                  '기존 계정으로 로그인하세요',
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
                  // Social Login Buttons (unified design)
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
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
        
        // Reopen the bottom sheet for retry
        _showSocialLoginBottomSheet(context);
      }
    }
  }

  Future<void> _handleSocialLoginInBottomSheet(String provider, StateSetter setBottomSheetState) async {
    // Debug: Show immediate feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$provider 로그인 시도 중...'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    
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
        // Close bottom sheet and navigate to home
        Navigator.pop(context);
        context.go('/home');
      } else {
        // For OAuth flows, close bottom sheet and let auth state listener handle navigation
        Navigator.pop(context);
      }
      
    } catch (error) {
      Logger.error('소셜 로그인 실패: $provider', error);
      
      if (mounted) {
        setBottomSheetState(() {
          _bottomSheetLoading = false;
        });
        
        // Show detailed error message for debugging
        final errorMessage = error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider 로그인 실패: $errorMessage'),
            backgroundColor: TossDesignSystem.errorRed,
            duration: const Duration(seconds: 5),
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
    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: () {
          // Debug: Immediate feedback
          debugPrint('Button tapped: $label');
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark100
              : TossDesignSystem.white,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark300
                : TossDesignSystem.gray300,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.white
                    : TossDesignSystem.gray900,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // 배경 터치 시 키보드 내리기
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Main content - TextField in center
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TextField for name input - 테두리 완전 제거, 배경 투명
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.white
                                : TossDesignSystem.gray900,
                          ),
                          textAlign: TextAlign.center,
                          autofocus: true,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          cursorColor: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.tossBlueDark
                              : TossDesignSystem.tossBlue,
                          showCursor: true,
                          enableInteractiveSelection: true,
                          onTap: () {
                            debugPrint('TextField 탭됨!');
                            _focusNode.requestFocus();
                            SystemChannels.textInput.invokeMethod('TextInput.show');
                          },
                          onSubmitted: (_) {
                            if (_isValid) {
                              widget.onNext();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '이름을 알려주세요',
                            hintStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? TossDesignSystem.grayDark400
                                  : TossDesignSystem.gray400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            fillColor: TossDesignSystem.white.withValues(alpha: 0.0),
                            filled: true,
                          ),
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
              
              // Next button - Show above keyboard when text is entered
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isValid ? (isKeyboardVisible ? keyboardHeight + 16 : 32) : -100,
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isValid ? 1.0 : 0.0,
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isValid ? widget.onNext : null,
                      style: TossTheme.primaryButtonStyle(_isValid),
                      child: Text(
                        '다음',
                        style: TossTheme.button.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark100
              : TossDesignSystem.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // "계정이 있어요" link at bottom - Only show when keyboard is NOT visible AND no text input
              if (!isKeyboardVisible && !_isValid)
                Positioned(
                  bottom: 32.0,
                  left: 0,
                  right: 0,
                  child: Center(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}