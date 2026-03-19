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
  final SocialAuthService? socialAuthService;

  const NameInputStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
    this.onSkip,
    this.allowSkip = false,
    this.socialAuthService,
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
    _socialAuthService =
        widget.socialAuthService ?? SocialAuthService(Supabase.instance.client);
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
    await SocialLoginBottomSheet.showForAuthentication(
      context,
      ref: ref,
      socialAuthService: _socialAuthService,
      onAuthenticated: () => context.go('/chat'),
    );
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(context.radius.xxl),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '무엇이라고 불러드릴까요?',
                          style: typography.headingMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '이름을 먼저 정리해두면 이후 대화와 추천 흐름이 더 자연스럽게 이어집니다.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: typography.headingMedium.copyWith(
                            fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w500,
                              color: colors.textTertiary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                  child: DSButton.primary(
                    text: '다음',
                    onPressed: _isValid ? widget.onNext : null,
                  ),
                ),
              ),
              if (!isKeyboardVisible && !_isValid)
                Positioned(
                  bottom: 32.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.allowSkip && widget.onSkip != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: widget.onSkip,
                            child: Text(
                              '건너뛰기',
                              style: typography.labelLarge.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showSocialLoginBottomSheet(context),
                          child: Text(
                            '계정이 있어요',
                            style: typography.labelLarge.copyWith(
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
