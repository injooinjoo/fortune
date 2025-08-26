import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/talisman_wish.dart';
import '../../../../core/theme/toss_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 이루고 싶은 것은?',
          style: TossTheme.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          '구체적인 소원을 알려주시면\n더욱 효과적인 부적을 만들어드려요',
          style: TossTheme.subtitle1.copyWith(
            color: TossTheme.textGray600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        
        // Category Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: TalismanCategory.values.length,
          itemBuilder: (context, index) {
            final category = TalismanCategory.values[index];
            final isSelected = _selectedCategory == category;
            
            return _CategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () {
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
}

class _CategoryCard extends StatelessWidget {
  final TalismanCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? TossTheme.primaryBlue.withOpacity(0.2)
                    : TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.displayName,
              style: TossTheme.body3.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? TossTheme.primaryBlue : TossTheme.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}