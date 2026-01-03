import 'package:flutter/material.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 직장 스타일 카드
class WorkStyleCard extends StatelessWidget {
  final WorkStyle workStyle;

  const WorkStyleCard({super.key, required this.workStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A90E2).withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💼', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '직장 스타일',
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
                colors: [Color(0xFF4A90E2), Color(0xFF67B8F5)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              workStyle.title,
              style: context.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 상세 정보
          _buildDetailItem(context, '👔 상사일 때', workStyle.asBoss),
          const SizedBox(height: 12),
          _buildDetailItem(context, '🍻 회식에서', workStyle.atCompanyDinner),
          const SizedBox(height: 12),
          _buildDetailItem(context, '📝 업무 습관', workStyle.workHabit),
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
              color: const Color(0xFF4A90E2),
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
