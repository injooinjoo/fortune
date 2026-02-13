import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/token_provider.dart';
import 'section_header.dart';
import 'settings_list_tile.dart';

/// 프로필 페이지의 토큰 섹션 (다른 섹션과 동일한 레이아웃)
class PremiumMembershipCard extends ConsumerWidget {
  const PremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);
    final remainingTokens = tokenState.currentTokens;
    const maxTokens = 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        const SectionHeader(title: '토큰'),
        // 컨테이너 (다른 섹션과 동일한 스타일)
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SettingsListTile(
            icon: Icons.toll_outlined,
            title: '보유 토큰',
            trailing: Text(
              '$remainingTokens / $maxTokens개',
              style: context.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => context.push('/token-purchase'),
            isLast: true,
          ),
        ),
      ],
    );
  }
}
