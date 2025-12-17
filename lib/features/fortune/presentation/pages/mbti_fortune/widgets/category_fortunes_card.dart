import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/utils/fortune_text_cleaner.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';

/// MBTI 카테고리별 운세 카드 (연애, 직장, 금전, 건강)
class MbtiCategoryFortunesCard extends StatefulWidget {
  final FortuneResult fortuneResult;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const MbtiCategoryFortunesCard({
    super.key,
    required this.fortuneResult,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  State<MbtiCategoryFortunesCard> createState() =>
      _MbtiCategoryFortunesCardState();
}

class _MbtiCategoryFortunesCardState extends State<MbtiCategoryFortunesCard> {
  int _currentTypingIndex = 0;

  static const List<_CategoryConfig> _categories = [
    _CategoryConfig(
      key: 'loveFortune',
      title: '연애 운세',
      icon: Icons.favorite_outline,
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
    _CategoryConfig(
      key: 'careerFortune',
      title: '직장 운세',
      icon: Icons.work_outline,
      gradient: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    ),
    _CategoryConfig(
      key: 'moneyFortune',
      title: '금전 운세',
      icon: Icons.attach_money,
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    _CategoryConfig(
      key: 'healthFortune',
      title: '건강 운세',
      icon: Icons.favorite_border,
      gradient: [Color(0xFFEF4444), Color(0xFFF87171)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.fortuneResult.data as Map<String, dynamic>? ?? {};

    // 실제 데이터가 있는 카테고리만 필터링
    final availableCategories = _categories
        .where((cat) {
          final content = data[cat.key] as String?;
          return content != null && content.isNotEmpty;
        })
        .toList();

    if (availableCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: availableCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final content = data[category.key] as String? ?? '';
        final cleanedContent = FortuneTextCleaner.clean(content);

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < availableCategories.length - 1 ? 12 : 0,
          ),
          child: _CategoryCard(
            config: category,
            content: cleanedContent,
            startTyping: widget.startTyping && _currentTypingIndex >= index,
            onTypingComplete: () {
              if (index < availableCategories.length - 1) {
                setState(() => _currentTypingIndex = index + 1);
              } else {
                widget.onTypingComplete?.call();
              }
            },
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryConfig {
  final String key;
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const _CategoryConfig({
    required this.key,
    required this.title,
    required this.icon,
    required this.gradient,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryConfig config;
  final String content;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const _CategoryCard({
    required this.config,
    required this.content,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: config.gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                config.title,
                style: DSTypography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GptStyleTypingText(
            text: content,
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
            startTyping: startTyping,
            showGhostText: true,
            onComplete: onTypingComplete,
          ),
        ],
      ),
    );
  }
}
