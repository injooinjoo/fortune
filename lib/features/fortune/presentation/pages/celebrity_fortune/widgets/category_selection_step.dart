import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../data/models/celebrity_simple.dart';

class CategorySelectionStep extends StatelessWidget {
  final CelebrityType? selectedCategory;
  final ValueChanged<CelebrityType?> onCategorySelected;

  const CategorySelectionStep({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  // C04: 스트리머/프로게이머를 하단에 배치한 카테고리 순서
  static const List<CelebrityType> _orderedCategories = [
    CelebrityType.actor,
    CelebrityType.soloSinger,
    CelebrityType.idolMember,
    CelebrityType.athlete,
    CelebrityType.politician,
    CelebrityType.business,
    CelebrityType.streamer,    // 하단 배치
    CelebrityType.proGamer,    // 하단 배치
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 분야의 유명인과\n궁합을 보고 싶으신가요?',
            style: DSTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '관심 있는 분야를 선택해주세요',
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // All categories option
          CategoryCard(
            category: null,
            title: '전체',
            description: '모든 분야의 유명인',
            icon: Icons.star,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(height: 12),

          // Individual categories (C04: 스트리머/프로게이머 하단 배치)
          ..._orderedCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CategoryCard(
                category: category,
                title: category.displayName,
                description: _getCategoryDescription(category),
                icon: _getCategoryIcon(category),
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(category),
              ),
            );
          }),
          const SizedBox(height: 100), // 버튼 높이만큼 여백
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }

  String _getCategoryDescription(CelebrityType category) {
    switch (category) {
      case CelebrityType.actor:
        return '배우, 탤런트, 영화배우';
      case CelebrityType.soloSinger:
        return '솔로 가수, 뮤지션';
      case CelebrityType.idolMember:
        return '아이돌 멤버, 그룹 가수';
      case CelebrityType.politician:
        return '정치인, 공인, 사회인사';
      case CelebrityType.athlete:
        return '운동선수, 스포츠 스타';
      case CelebrityType.streamer:
        return '스트리머, 인플루언서';
      case CelebrityType.proGamer:
        return '프로게이머, 이스포츠 선수';
      case CelebrityType.business:
        return '기업인, 경영자';
    }
  }

  IconData _getCategoryIcon(CelebrityType category) {
    switch (category) {
      case CelebrityType.actor:
        return Icons.movie;
      case CelebrityType.soloSinger:
        return Icons.music_note;
      case CelebrityType.idolMember:
        return Icons.groups;
      case CelebrityType.politician:
        return Icons.account_balance;
      case CelebrityType.athlete:
        return Icons.sports;
      case CelebrityType.streamer:
        return Icons.tv;
      case CelebrityType.proGamer:
        return Icons.sports_esports;
      case CelebrityType.business:
        return Icons.business;
    }
  }
}

class CategoryCard extends StatelessWidget {
  final CelebrityType? category;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.08) : colors.surface,
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : colors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DSTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.accent : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.accent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
