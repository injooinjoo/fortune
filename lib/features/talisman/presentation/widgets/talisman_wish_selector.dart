import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/fortune_theme.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/utils/haptic_utils.dart';

/// 전통 부적 스타일 색상 팔레트
class _TalismanColors {
  static const Color gold = Color(0xFFD4AF37);       // 금색 강조
  static const Color goldLight = Color(0xFFF5E6C8); // 연한 금색
  static const Color redSeal = Color(0xFFC41E3A);   // 인주/도장 색
  static const Color inkBlack = Color(0xFF1A1A1A);  // 먹색
  static const Color paper = Color(0xFFF5F0E1);     // 한지 미색
  static const Color paperDark = Color(0xFF2A2520); // 다크모드 한지색
}

/// 카테고리별 한자 매핑
const Map<TalismanCategory, String> _categoryHanja = {
  TalismanCategory.relationship: '人緣',
  TalismanCategory.wealth: '財物',
  TalismanCategory.career: '事業',
  TalismanCategory.love: '緣愛',
  TalismanCategory.study: '學業',
  TalismanCategory.health: '健康',
  TalismanCategory.goal: '成就',
};

class TalismanWishSelector extends StatefulWidget {
  final Function(TalismanCategory) onCategorySelected;
  final TalismanCategory? selectedCategory;

  const TalismanWishSelector({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<TalismanWishSelector> createState() => _TalismanWishSelectorState();
}

class _TalismanWishSelectorState extends State<TalismanWishSelector> {
  TalismanCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ 전통 스타일 헤더
        _buildTraditionalHeader(isDark),

        const SizedBox(height: 24),

        // Category Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: TalismanCategory.values.length,
          itemBuilder: (context, index) {
            final category = TalismanCategory.values[index];
            final isSelected = _selectedCategory == category;

            return _TraditionalCategoryCard(
              category: category,
              hanja: _categoryHanja[category] ?? '',
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                HapticUtils.lightImpact();
                setState(() {
                  _selectedCategory = category;
                });
                widget.onCategorySelected(category);
              },
            ).animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0);
          },
        ),
      ],
    );
  }

  /// 전통 스타일 헤더
  Widget _buildTraditionalHeader(bool isDark) {
    return Column(
      children: [
        // 장식 + 제목
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: _TalismanColors.gold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '소원 부적',
              style: TossTheme.heading1.copyWith(
                color: isDark ? _TalismanColors.goldLight : _TalismanColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.auto_awesome,
              color: _TalismanColors.gold,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 부제목
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: (isDark ? _TalismanColors.goldLight : _TalismanColors.gold).withValues(alpha: 0.3),
                width: 1,
              ),
              bottom: BorderSide(
                color: (isDark ? _TalismanColors.goldLight : _TalismanColors.gold).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Text(
            '마음을 담아 빌어보세요',
            style: TossTheme.subtitle1.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              fontStyle: FontStyle.italic,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: -0.1, end: 0);
  }
}

/// ✅ 전통 스타일 카테고리 카드 (한자 + 한글 + 이모지)
class _TraditionalCategoryCard extends StatelessWidget {
  final TalismanCategory category;
  final String hanja;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TraditionalCategoryCard({
    required this.category,
    required this.hanja,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? (isDark ? _TalismanColors.gold.withValues(alpha: 0.2) : _TalismanColors.goldLight)
        : (isDark ? _TalismanColors.paperDark : _TalismanColors.paper);

    final borderColor = isSelected
        ? _TalismanColors.gold
        : (isDark ? _TalismanColors.inkBlack.withValues(alpha: 0.3) : _TalismanColors.inkBlack.withValues(alpha: 0.2));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _TalismanColors.inkBlack.withValues(alpha: isDark ? 0.3 : 0.08),
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 수묵화 이미지
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/talismans/${category.name}.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패 시 기존 한자 표시
                    return Center(
                      child: Text(
                        hanja,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _TalismanColors.gold : (isDark ? Colors.white : _TalismanColors.inkBlack),
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 한글 카테고리명 + 이모지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    category.displayName,
                    style: TossTheme.body3.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? _TalismanColors.goldLight : _TalismanColors.gold)
                          : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            // 선택 표시 (인주 스타일)
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _TalismanColors.redSeal,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '選',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}