import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/supabase_connection_service.dart';
import '../../../../presentation/providers/providers.dart';

/// Chat-first minimal account/legal sheet.
class ProfileBottomSheet extends ConsumerStatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  ConsumerState<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends ConsumerState<ProfileBottomSheet> {
  Future<void> _handleLogout() async {
    await ref.read(sessionCleanupServiceProvider).signOutAndClearSession();

    if (!mounted) return;
    context.go('/chat');
  }

  void _openRoute(String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = SupabaseConnectionService.tryGetCurrentUser();
    final profile = ref.watch(userProfileNotifierProvider).valueOrNull;
    final displayName = profile?.name ?? user?.email ?? '게스트';
    final statusLabel = user == null ? '로그인되지 않음' : '로그인됨';

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    DSSpacing.lg,
                    DSSpacing.sm,
                    DSSpacing.lg,
                    DSSpacing.xl,
                  ),
                  children: [
                    Text(
                      '계정 및 법적 안내',
                      style: context.heading3.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(DSRadius.lg),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.surfaceSecondary,
                            child: Icon(
                              Icons.person_outline,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: DSSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: context.bodyLarge.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: DSSpacing.xxs),
                                Text(
                                  statusLabel,
                                  style: context.labelSmall.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.lg),
                    _ProfileSheetActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보처리방침',
                      onTap: () => _openRoute('/privacy-policy'),
                    ),
                    _ProfileSheetActionTile(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () => _openRoute('/terms-of-service'),
                    ),
                    if (user != null)
                      _ProfileSheetActionTile(
                        icon: Icons.person_remove_outlined,
                        title: '회원 탈퇴',
                        isDestructive: true,
                        onTap: () => _openRoute('/account-deletion'),
                      ),
                    if (user != null)
                      _ProfileSheetActionTile(
                        icon: Icons.logout,
                        title: '로그아웃',
                        isDestructive: true,
                        onTap: _handleLogout,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileSheetActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileSheetActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isDestructive ? colors.error : colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(DSRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: foreground),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: context.bodyMedium.copyWith(color: foreground),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
