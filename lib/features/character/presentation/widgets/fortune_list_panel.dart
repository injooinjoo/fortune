import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chat/domain/models/recommendation_chip.dart';
import '../providers/character_provider.dart';

/// 운세 목록 패널 (왼쪽 스와이프)
/// 기존 defaultChips의 모든 칩을 리스트 형태로 표시
class FortuneListPanel extends ConsumerWidget {
  final void Function(RecommendationChip chip) onFortuneSelected;

  const FortuneListPanel({
    super.key,
    required this.onFortuneSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),
            const Divider(height: 1),
            // 운세 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: defaultChips.length,
                itemBuilder: (context, index) {
                  final chip = defaultChips[index];
                  return _FortuneListItem(
                    chip: chip,
                    onTap: () {
                      // 선택된 칩을 Provider에 저장
                      ref.read(pendingFortuneChipProvider.notifier).state = chip;
                      onFortuneSelected(chip);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            "How's your day?",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// 운세 목록 아이템
class _FortuneListItem extends StatelessWidget {
  final RecommendationChip chip;
  final VoidCallback onTap;

  const _FortuneListItem({
    required this.chip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: chip.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                chip.icon,
                size: 24,
                color: chip.color,
              ),
            ),
            const SizedBox(width: 12),
            // 라벨 + 부제목
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chip.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (chip.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      chip.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // 화살표
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
