import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
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
    this.title = '먼저 둘러보고,\n필요할 때 이어가세요',
    this.description = '로그인하면 저장과 개인화가 바로 이어지고,\n지금은 둘러보기로 가볍게 시작할 수 있어요.',
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
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DSSpacing.xl),
            PaperRuntimePill(
              label: widget.eyebrow ?? 'FIRST RUN / SOFT GATE',
            ),
            SizedBox(height: spacing.lg),
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
                  Text(
                    widget.title,
                    style: typography.displayLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    widget.description,
                    style: typography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.58,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SocialAuthEntryPanel(
                title: '계정을 연결하면',
                description: '',
                showHeader: true,
                showBrowseAction: widget.showBrowseAction,
                onBrowseAsGuest: _startAsGuest,
                onAuthenticated:
                    widget.onAuthenticated ?? () => context.go('/chat'),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
          ],
        ),
      ),
    );
  }
}
