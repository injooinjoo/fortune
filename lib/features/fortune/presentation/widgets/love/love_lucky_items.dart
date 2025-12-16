import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';

class LoveLuckyItems extends StatelessWidget {
  final Map<String, String> luckyItems;
  
  const LoveLuckyItems({
    super.key,
    required this.luckyItems,
  });

  Color _getItemColor(String category) {
    switch (category) {
      case '향수':
        return const Color(0xFF8B5CF6);
      case '색상':
        return const Color(0xFFEC4899);
      case '액세서리':
        return const Color(0xFF10B981);
      case '꽃':
        return const Color(0xFFF59E0B);
      default:
        return DSColors.accent;
    }
  }

  String _getItemEmoji(String category) {
    switch (category) {
      case '향수':
        return '🌸';
      case '색상':
        return '🎨';
      case '액세서리':
        return '💎';
      case '꽃':
        return '🌺';
      default:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DSColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEC4899),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🎁 이번 달 행운 아이템',
                  style: DSTypography.labelLarge.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4),
          
          Text(
            '이 아이템들이 연애 운을 높여줄 거예요!',
            style: DSTypography.bodyMedium.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 아이템 그리드
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: luckyItems.entries.map((entry) {
              final index = luckyItems.keys.toList().indexOf(entry.key);
              return _buildLuckyItemCard(
                entry.key,
                entry.value,
                index,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // 사용법 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DSColors.accent.withValues(alpha: 0.05),
                  DSColors.accent.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: DSColors.accent,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 데이트나 중요한 만남 전에 이 아이템들을 활용해보세요!',
                    style: DSTypography.bodyMedium.copyWith(
                      color: DSColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
        ],
      ),
    ).animate(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildLuckyItemCard(String category, String item, int index) {
    final color = _getItemColor(category);
    final emoji = _getItemEmoji(category);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DSColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: DSTypography.buttonMedium,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  category,
                  style: DSTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            item,
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate(delay: (200 * index).ms)
     .slideY(begin: 0.3, duration: 600.ms)
     .fadeIn()
     .then()
     .shimmer(
       duration: 2000.ms,
       color: color.withValues(alpha: 0.3),
     );
  }
}