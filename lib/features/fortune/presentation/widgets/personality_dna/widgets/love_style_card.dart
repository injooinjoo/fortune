import 'package:flutter/material.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 연애 스타일 카드
class LoveStyleCard extends StatelessWidget {
  final LoveStyle loveStyle;

  const LoveStyleCard({super.key, required this.loveStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '연애 스타일',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 타이틀
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              loveStyle.title,
              style: context.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 설명
          Text(
            loveStyle.description,
            style: context.bodyLarge,
          ),
          const SizedBox(height: 16),
          // 상세 정보
          _buildDetailItem(context, '💑 데이트할 때', loveStyle.whenDating),
          const SizedBox(height: 12),
          _buildDetailItem(context, '💔 이별 후', loveStyle.afterBreakup),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: const Color(0xFFFF6B9D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}
