import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../services/social_auth_service.dart';
import '../../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../../core/providers/user_settings_provider.dart';

class NameInputStep extends ConsumerStatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool allowSkip;

  const NameInputStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
    this.onSkip,
    this.allowSkip = false,
  });

  @override
  ConsumerState<NameInputStep> createState() => _NameInputStepState();
}

class _NameInputStepState extends ConsumerState<NameInputStep> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  late final SocialAuthService _socialAuthService;
  bool _isValid = false;

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

    // 키보드 활성화 - 단일 접근으로 최적화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _showSocialLoginBottomSheet(BuildContext context) async {
    await SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () => _handleSocialLogin(
        provider: 'google',
        loginAction: () =>
            _socialAuthService.signInWithGoogle(context: context),
      ),
      onAppleLogin: () => _handleSocialLogin(
        provider: 'apple',
        loginAction: _socialAuthService.signInWithApple,
      ),
      onKakaoLogin: () async {},
      onNaverLogin: () async {},
      ref: ref,
    );
  }

  Future<void> _handleSocialLogin({
    required String provider,
    required Future<AuthResponse?> Function() loginAction,
  }) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인 시도 중...'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final response = await loginAction();

      if (!mounted) return;
      if (response != null && response.user != null) {
        context.go('/chat');
      }
    } catch (error) {
      if (!mounted) return;
      final errorMessage = error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$provider 로그인 실패: $errorMessage'),
          backgroundColor: context.colors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    final typography = ref.watch(typographyThemeProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
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
                    // 자기발견 컨셉 강조 메시지
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Text(
                        '나를 더 깊이 알아가는 여정',
                        style: typography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // TextField for name input - 테두리 완전 제거, 배경 투명
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        style: typography.headingMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        autofocus: true,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        cursorColor: colors.accent,
                        showCursor: true,
                        enableInteractiveSelection: true,
                        onTap: () {
                          debugPrint('TextField 탭됨!');
                          _focusNode.requestFocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.show');
                        },
                        onSubmitted: (_) {
                          if (_isValid) {
                            widget.onNext();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '이름을 알려주세요',
                          hintStyle: typography.headingMedium.copyWith(
                            fontWeight: FontWeight.w400,
                            color: colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.transparent,
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
                bottom: _isValid
                    ? (isKeyboardVisible ? keyboardHeight + 16 : 32)
                    : -100,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isValid ? colors.ctaBackground : colors.border,
                        foregroundColor: colors.ctaForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DSRadius.lg),
                        ),
                        elevation: 0,
                        textStyle: typography.headingSmall
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: Text(
                        '다음',
                        style: typography.headingSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.ctaForeground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom links - Only show when keyboard is NOT visible AND no text input
              if (!isKeyboardVisible && !_isValid)
                Positioned(
                  bottom: 32.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip button for social login users
                      if (widget.allowSkip && widget.onSkip != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: widget.onSkip,
                            child: Text(
                              '건너뛰기',
                              style: typography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      // "계정이 있어요" link
                      Center(
                        child: GestureDetector(
                          onTap: () => _showSocialLoginBottomSheet(context),
                          child: Text(
                            '계정이 있어요',
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
