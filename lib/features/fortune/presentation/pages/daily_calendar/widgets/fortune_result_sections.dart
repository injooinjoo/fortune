import 'package:flutter/material.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../../core/widgets/gpt_style_typing_text.dart';

/// 운세 섹션 카드 빌더
class FortuneSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;
  final bool isWarning;

  const FortuneSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // 문단 구분을 위해 '. '으로 문장 분리
    final sentences = content.split('. ').where((s) => s.trim().isNotEmpty).toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning
                  ? DSColors.error
                  : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.heading3.copyWith(
                  color: isWarning
                    ? DSColors.error
                    : (colors.textPrimary),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 문장별로 구분하여 표시
          ...sentences.asMap().entries.map((entry) {
            final index = entry.key;
            final sentence = entry.value.trim();
            final isLastSentence = index == sentences.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLastSentence ? 0 : 16),
              child: Text(
                sentence + (sentence.endsWith('.') ? '' : '.'),
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.8,
                  letterSpacing: -0.3,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 카테고리별 운세 섹션
class CategoriesSection extends StatelessWidget {
  final Map<String, dynamic> categories;
  final bool isDark;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.isDark,
  });

  static const List<Map<String, dynamic>> categoryData = [
    {'key': 'love', 'title': '애정 운세', 'icon': Icons.favorite_outline, 'color': Colors.pink},
    {'key': 'work', 'title': '직장 운세', 'icon': Icons.work_outline, 'color': Colors.blue},
    {'key': 'money', 'title': '금전 운세', 'icon': Icons.attach_money, 'color': Colors.green},
    {'key': 'study', 'title': '학업 운세', 'icon': Icons.school_outlined, 'color': Colors.orange},
    {'key': 'health', 'title': '건강 운세', 'icon': Icons.favorite_border, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '카테고리별 운세',
            style: context.heading3.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        ...categoryData.map((cat) {
          final categoryInfo = categories[cat['key']];
          if (categoryInfo == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['title'] as String,
                        style: context.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categoryInfo['score']}점',
                          style: context.labelSmall.copyWith(
                            color: cat['color'] as Color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (categoryInfo['title'] != null)
                    Text(
                      FortuneTextCleaner.clean(categoryInfo['title'] as String),
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (categoryInfo['advice'] != null)
                    Text(
                      FortuneTextCleaner.cleanAndTruncate(categoryInfo['advice'] as String),
                      style: context.bodySmall.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        // 전체 운세
        if (categories['total'] != null) ...[
          const SizedBox(height: 4),
          _buildTotalFortuneCard(context),
        ],
      ],
    );
  }

  Widget _buildTotalFortuneCard(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        style: AppCardStyle.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '전체 운세',
                  style: context.heading3.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${categories['total']['score']}점',
                    style: context.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (categories['total']['advice'] is Map) ...[
              // advice가 Map 구조인 경우 (idiom + description)
              Text(
                FortuneTextCleaner.clean((categories['total']['advice'] as Map)['idiom'] as String? ?? ''),
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                FortuneTextCleaner.cleanAndTruncate((categories['total']['advice'] as Map)['description'] as String? ?? ''),
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ] else ...[
              // advice가 String인 경우 (하위 호환)
              Text(
                FortuneTextCleaner.cleanAndTruncate(categories['total']['advice'] as String? ?? ''),
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AI 팁 리스트 위젯
class AITipsList extends StatelessWidget {
  final List tips;
  final bool isDark;

  const AITipsList({
    super.key,
    required this.tips,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '신의 조언',
                style: context.heading3.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.labelSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      FortuneTextCleaner.cleanAndTruncate(tip, maxLength: 80),
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// GPT 스타일 타이핑 효과가 적용된 위젯들
// ============================================================================

/// 타이핑 효과가 적용된 운세 섹션 카드
class TypingFortuneSectionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;
  final bool isWarning;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const TypingFortuneSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
    this.isWarning = false,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<TypingFortuneSectionCard> createState() => _TypingFortuneSectionCardState();
}

class _TypingFortuneSectionCardState extends State<TypingFortuneSectionCard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // 문단 구분을 위해 '. '으로 문장 분리
    final sentences = widget.content.split('. ').where((s) => s.trim().isNotEmpty).toList();
    final paragraphs = sentences.map((s) {
      final trimmed = s.trim();
      return trimmed + (trimmed.endsWith('.') ? '' : '.');
    }).toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isWarning
                  ? DSColors.error
                  : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: context.heading3.copyWith(
                  color: widget.isWarning
                    ? DSColors.error
                    : colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GptStyleTypingParagraphs(
            paragraphs: paragraphs,
            paragraphSpacing: 16.0,
            showGhostText: false,
            showCursor: true,
            startTyping: widget.startTyping,
            onComplete: widget.onTypingComplete,
            style: context.bodyMedium.copyWith(
              color: colors.textPrimary,
              height: 1.8,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 타이핑 효과가 적용된 총운 섹션 (상단 표시용)
class TypingTotalFortuneSection extends StatefulWidget {
  final Map<String, dynamic> total;
  final bool isDark;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const TypingTotalFortuneSection({
    super.key,
    required this.total,
    required this.isDark,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<TypingTotalFortuneSection> createState() => _TypingTotalFortuneSectionState();
}

class _TypingTotalFortuneSectionState extends State<TypingTotalFortuneSection> {
  bool _idiomComplete = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final advice = widget.total['advice'];
    final isMapAdvice = advice is Map;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        style: AppCardStyle.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMapAdvice) ...[
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice['idiom'] as String? ?? ''),
                startTyping: widget.startTyping,
                showGhostText: false,
                showCursor: !_idiomComplete,
                onComplete: () {
                  setState(() {
                    _idiomComplete = true;
                  });
                },
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice['description'] as String? ?? ''),
                startTyping: widget.startTyping && _idiomComplete,
                showGhostText: false,
                showCursor: true,
                onComplete: widget.onTypingComplete,
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ] else ...[
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice as String? ?? ''),
                startTyping: widget.startTyping,
                showGhostText: false,
                showCursor: true,
                onComplete: widget.onTypingComplete,
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 타이핑 효과가 적용된 카테고리 섹션
class TypingCategoriesSection extends StatefulWidget {
  final Map<String, dynamic> categories;
  final bool isDark;
  final bool startTyping;
  final bool showTotal;  // 총운 표시 여부
  final VoidCallback? onTypingComplete;

  const TypingCategoriesSection({
    super.key,
    required this.categories,
    required this.isDark,
    this.startTyping = true,
    this.showTotal = true,
    this.onTypingComplete,
  });

  @override
  State<TypingCategoriesSection> createState() => _TypingCategoriesSectionState();
}

class _TypingCategoriesSectionState extends State<TypingCategoriesSection> {
  int _currentCategoryIndex = 0;
  bool _categoriesComplete = false;

  static const List<Map<String, dynamic>> categoryData = [
    {'key': 'love', 'title': '애정 운세', 'icon': Icons.favorite_outline, 'color': Colors.pink},
    {'key': 'work', 'title': '직장 운세', 'icon': Icons.work_outline, 'color': Colors.blue},
    {'key': 'money', 'title': '금전 운세', 'icon': Icons.attach_money, 'color': Colors.green},
    {'key': 'study', 'title': '학업 운세', 'icon': Icons.school_outlined, 'color': Colors.orange},
    {'key': 'health', 'title': '건강 운세', 'icon': Icons.favorite_border, 'color': Colors.red},
  ];

  List<Map<String, dynamic>> get _validCategories {
    return categoryData.where((cat) => widget.categories[cat['key']] != null).toList();
  }

  void _onCategoryComplete(int index) {
    if (index < _validCategories.length - 1) {
      setState(() {
        _currentCategoryIndex = index + 1;
      });
    } else {
      // 모든 카테고리 완료
      if (widget.showTotal && widget.categories['total'] != null) {
        setState(() {
          _categoriesComplete = true;
        });
      } else {
        widget.onTypingComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '카테고리별 운세',
            style: context.heading3.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        ..._validCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          final categoryInfo = widget.categories[cat['key']];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TypingCategoryCard(
              cat: cat,
              categoryInfo: categoryInfo,
              isDark: widget.isDark,
              startTyping: widget.startTyping && index <= _currentCategoryIndex,
              onTypingComplete: () => _onCategoryComplete(index),
            ),
          );
        }),

        // 전체 운세 (showTotal이 true일 때만)
        if (widget.showTotal && widget.categories['total'] != null) ...[
          const SizedBox(height: 4),
          _TypingTotalFortuneCard(
            total: widget.categories['total'],
            isDark: widget.isDark,
            startTyping: widget.startTyping && _categoriesComplete,
            onTypingComplete: widget.onTypingComplete,
          ),
        ],
      ],
    );
  }
}

class _TypingCategoryCard extends StatefulWidget {
  final Map<String, dynamic> cat;
  final Map<String, dynamic> categoryInfo;
  final bool isDark;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const _TypingCategoryCard({
    required this.cat,
    required this.categoryInfo,
    required this.isDark,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<_TypingCategoryCard> createState() => _TypingCategoryCardState();
}

class _TypingCategoryCardState extends State<_TypingCategoryCard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final advice = widget.categoryInfo['advice'] as String?;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.cat['icon'] as IconData,
                color: widget.cat['color'] as Color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.cat['title'] as String,
                style: context.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (widget.cat['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.categoryInfo['score']}점',
                  style: context.labelSmall.copyWith(
                    color: widget.cat['color'] as Color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (advice != null)
            GptStyleTypingText(
              text: FortuneTextCleaner.clean(advice),
              startTyping: widget.startTyping,
              showGhostText: false,
              showCursor: true,
              onComplete: widget.onTypingComplete,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingTotalFortuneCard extends StatefulWidget {
  final Map<String, dynamic> total;
  final bool isDark;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const _TypingTotalFortuneCard({
    required this.total,
    required this.isDark,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<_TypingTotalFortuneCard> createState() => _TypingTotalFortuneCardState();
}

class _TypingTotalFortuneCardState extends State<_TypingTotalFortuneCard> {
  bool _idiomComplete = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final advice = widget.total['advice'];
    final isMapAdvice = advice is Map;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        style: AppCardStyle.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '전체 운세',
                  style: context.heading3.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.total['score']}점',
                    style: context.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMapAdvice) ...[
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice['idiom'] as String? ?? ''),
                startTyping: widget.startTyping,
                showGhostText: false,
                showCursor: !_idiomComplete,
                onComplete: () {
                  setState(() {
                    _idiomComplete = true;
                  });
                },
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice['description'] as String? ?? ''),
                startTyping: widget.startTyping && _idiomComplete,
                showGhostText: false,
                showCursor: true,
                onComplete: widget.onTypingComplete,
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ] else ...[
              GptStyleTypingText(
                text: FortuneTextCleaner.clean(advice as String? ?? ''),
                startTyping: widget.startTyping,
                showGhostText: false,
                showCursor: true,
                onComplete: widget.onTypingComplete,
                style: context.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 타이핑 효과가 적용된 AI 팁 리스트
class TypingAITipsList extends StatefulWidget {
  final List tips;
  final bool isDark;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const TypingAITipsList({
    super.key,
    required this.tips,
    required this.isDark,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<TypingAITipsList> createState() => _TypingAITipsListState();
}

class _TypingAITipsListState extends State<TypingAITipsList> {
  int _currentTipIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '신의 조언',
                style: context.heading3.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value as String;
            final isLastTip = index == widget.tips.length - 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.labelSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GptStyleTypingText(
                      text: FortuneTextCleaner.clean(tip),
                      startTyping: widget.startTyping && index <= _currentTipIndex,
                      showGhostText: false,
                      showCursor: index == _currentTipIndex,
                      onComplete: () {
                        if (!isLastTip) {
                          setState(() {
                            _currentTipIndex = index + 1;
                          });
                        } else {
                          widget.onTypingComplete?.call();
                        }
                      },
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
