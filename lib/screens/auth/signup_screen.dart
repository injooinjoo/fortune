import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../services/storage_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final Future<void> Function()? onBrowseAsGuest;
  final bool showBrowseAction;
  final String title;
  final String description;
  final String? eyebrow;

  const SignupScreen({
    super.key,
    this.onAuthenticated,
    this.onBrowseAsGuest,
    this.showBrowseAction = true,
    this.title = '대화를 바로 시작해볼까요?',
    this.description = '로그인하면 흐름을 저장하고, 개인화된 인사이트를 더 자연스럽게 이어갈 수 있어요.',
    this.eyebrow,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final StorageService _storageService = StorageService();

  Future<void> _startAsGuest() async {
    await _storageService.setGuestMode(true);
    if (widget.onBrowseAsGuest != null) {
      await widget.onBrowseAsGuest!.call();
      return;
    }
    if (mounted) context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.radius.xxl),
                        color: colors.surface,
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.radius.xxl),
                        child: Image.asset(
                          'assets/images/zpzg_logo_light.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.xl),
                    SocialAuthEntryPanel(
                      eyebrow: widget.eyebrow,
                      title: widget.title,
                      description: widget.description,
                      showBrowseAction: widget.showBrowseAction,
                      onBrowseAsGuest: _startAsGuest,
                      onAuthenticated:
                          widget.onAuthenticated ?? () => context.go('/chat'),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
