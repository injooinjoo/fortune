import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/theme/typography_theme.dart';
import '../../../core/services/supabase_connection_service.dart';
import '../../../services/social_auth_service.dart';
import '../../../services/storage_service.dart';
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
  final StorageService _storageService = StorageService();
  SocialAuthService? _socialAuthService;
  bool _isValid = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    final resolvedSocialAuthService = widget.socialAuthService;
    final supabaseClient = SupabaseConnectionService.tryGetClient();
    _socialAuthService = resolvedSocialAuthService ??
        (supabaseClient != null ? SocialAuthService(supabaseClient) : null);
    _isValid = _nameController.text.isNotEmpty;

    _nameController.addListener(() {
      setState(() {
        _isValid = _nameController.text.trim().isNotEmpty;
      });
      widget.onNameChanged(_nameController.text.trim());
    });

    unawaited(_hydrateSavedConsents());

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

  bool get _canProceed => _isValid && _termsAccepted && _privacyAccepted;
  bool get _canSkip =>
      widget.allowSkip &&
      widget.onSkip != null &&
      _termsAccepted &&
      _privacyAccepted;

  Future<void> _hydrateSavedConsents() async {
    final termsAccepted = await _storageService.hasAcceptedTerms();
    final privacyAccepted = await _storageService.hasAcceptedPrivacyPolicy();
    if (!mounted) return;

    setState(() {
      _termsAccepted = termsAccepted;
      _privacyAccepted = privacyAccepted;
    });
  }

  Future<void> _persistConsentsAndContinue() async {
    if (!_canProceed) return;
    await _storageService.setRequiredPoliciesAccepted();
    if (!mounted) return;
    widget.onNext();
  }

  Future<void> _persistConsentsAndSkip() async {
    if (!_canSkip || widget.onSkip == null) return;
    await _storageService.setRequiredPoliciesAccepted();
    if (!mounted) return;
    widget.onSkip!();
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
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    '무엇이라고\n불러드릴까요?',
                    style: typography.headingLarge.copyWith(
                      color: colors.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '이름을 먼저 알려주시면 대화가 더 자연스러워져요',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textTertiary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Name input field
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(context.radius.md),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? colors.textPrimary.withValues(alpha: 0.2)
                            : colors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      style: typography.headingSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      autofocus: true,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      cursorColor: colors.textPrimary,
                      onTap: () {
                        _focusNode.requestFocus();
                        SystemChannels.textInput.invokeMethod('TextInput.show');
                      },
                      onSubmitted: (_) => _persistConsentsAndContinue(),
                      decoration: InputDecoration(
                        hintText: '이름을 입력해주세요',
                        hintStyle: typography.headingSmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textTertiary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Consent checkboxes
                  _ConsentRow(
                    isChecked: _termsAccepted,
                    onChanged: (v) =>
                        setState(() => _termsAccepted = v ?? false),
                    label: '이용약관',
                    onTap: () => context.push('/terms-of-service'),
                    colors: colors,
                    typography: typography,
                  ),
                  const SizedBox(height: 12),
                  _ConsentRow(
                    isChecked: _privacyAccepted,
                    onChanged: (v) =>
                        setState(() => _privacyAccepted = v ?? false),
                    label: '개인정보처리방침',
                    onTap: () => context.push('/privacy-policy'),
                    colors: colors,
                    typography: typography,
                  ),
                ],
              ),
            ),

            // CTA button (animated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _canProceed
                  ? (isKeyboardVisible ? keyboardHeight + 16 : 32)
                  : -80,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _canProceed ? 1.0 : 0.0,
                child: DSButton.primary(
                  text: '다음',
                  onPressed:
                      _canProceed ? () => _persistConsentsAndContinue() : null,
                ),
              ),
            ),

            // Bottom links (visible when CTA is hidden)
            if (!isKeyboardVisible && !_canProceed)
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
                          onTap:
                              _canSkip ? () => _persistConsentsAndSkip() : null,
                          child: Text(
                            '건너뛰기',
                            style: typography.labelLarge.copyWith(
                              color: _canSkip
                                  ? colors.textSecondary
                                  : colors.textTertiary,
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
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final String label;
  final VoidCallback onTap;
  final DSColorScheme colors;
  final TypographyTheme typography;

  const _ConsentRow({
    required this.isChecked,
    required this.onChanged,
    required this.label,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isChecked ? colors.textPrimary : colors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isChecked ? colors.textPrimary : colors.border,
                width: 1.5,
              ),
            ),
            child: isChecked
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: colors.ctaForeground,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: typography.labelMedium.copyWith(
                      color: colors.accent,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.accent,
                    ),
                  ),
                  TextSpan(
                    text: ' 동의 (필수)',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
