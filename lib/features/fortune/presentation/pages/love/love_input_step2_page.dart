import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../shared/components/floating_bottom_button.dart';
import '../../../../../core/theme/typography_unified.dart';

enum DatingStyle { active, passive, emotional, logical, independent, dependent, serious, casual }

class LoveInputStep2Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final ValueNotifier<bool>? canProceedNotifier;

  const LoveInputStep2Page({
    super.key,
    required this.onNext,
    this.canProceedNotifier,
  });

  @override
  State<LoveInputStep2Page> createState() => _LoveInputStep2PageState();
}

class _LoveInputStep2PageState extends State<LoveInputStep2Page> {
  final Set<DatingStyle> _selectedStyles = {};
  final Map<String, double> _valueImportance = {
    '외모': 3.0,
    '성격': 3.0,
    '경제력': 3.0,
    '가치관': 3.0,
    '유머감각': 3.0,
  };

  bool get _canProceed => _selectedStyles.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _updateCanProceed();
  }

  void _updateCanProceed() {
    widget.canProceedNotifier?.value = _canProceed;
  }

  String _getDatingStyleText(DatingStyle style) {
    switch (style) {
      case DatingStyle.active:
        return '적극적';
      case DatingStyle.passive:
        return '소극적';
      case DatingStyle.emotional:
        return '감성적';
      case DatingStyle.logical:
        return '이성적';
      case DatingStyle.independent:
        return '독립적';
      case DatingStyle.dependent:
        return '의존적';
      case DatingStyle.serious:
        return '진지한';
      case DatingStyle.casual:
        return '가벼운';
    }
  }

  String _getDatingStyleEmoji(DatingStyle style) {
    switch (style) {
      case DatingStyle.active:
        return '🔥';
      case DatingStyle.passive:
        return '🌸';
      case DatingStyle.emotional:
        return '💖';
      case DatingStyle.logical:
        return '🧠';
      case DatingStyle.independent:
        return '🦅';
      case DatingStyle.dependent:
        return '🤝';
      case DatingStyle.serious:
        return '💍';
      case DatingStyle.casual:
        return '😊';
    }
  }

  void _handleNext() {
    if (!_canProceed) return;
    
    widget.onNext({
      'datingStyles': _selectedStyles.map((s) => s.toString().split('.').last).toList(),
      'valueImportance': _valueImportance,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '연애 스타일을\n알려주세요',
            style: TossTheme.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ).animate().slideX(begin: -0.3, duration: 600.ms).fadeIn(),

          const SizedBox(height: 8),

          Text(
            '여러 개 선택 가능해요',
            style: TossTheme.body1.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ).animate(delay: 200.ms).slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 32),
          
          // Dating Styles Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: DatingStyle.values.map((style) {
              return _buildStyleChip(style, isDark);
            }).toList(),
          ).animate(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 40),
          
          // Value Importance Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '중요한 가치',
                      style: TossTheme.heading4.copyWith(
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '1~5점',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '각 항목이 연애할 때 얼마나 중요한지 점수를 매겨주세요',
                  style: TossTheme.body2.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 20),
                ..._valueImportance.entries.map((entry) {
                  return _buildValueSlider(entry.key, entry.value, isDark);
                }),
              ],
            ),
          ).animate(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),

          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  // Floating Button Widget
  Widget buildFloatingButton() {
    return FloatingBottomButton(
      text: '다음 단계로',
      onPressed: _canProceed ? _handleNext : null,
      style: _canProceed ? TossButtonStyle.primary : TossButtonStyle.secondary,
      hideWhenDisabled: true,
    );
  }

  Widget _buildStyleChip(DatingStyle style, bool isDark) {
    final isSelected = _selectedStyles.contains(style);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStyles.remove(style);
          } else {
            _selectedStyles.add(style);
          }
        });
        _updateCanProceed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossTheme.primaryBlue
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossTheme.primaryBlue
                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getDatingStyleEmoji(style),
              style: TypographyUnified.heading4,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _getDatingStyleText(style),
                style: TossTheme.body1.copyWith(
                  color: isSelected
                      ? TossDesignSystem.white
                      : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueSlider(String label, double value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TossTheme.body1.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(value).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}점',
                  style: TossTheme.body2.copyWith(
                    color: _getScoreColor(value),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getScoreColor(value),
              inactiveTrackColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
              thumbColor: _getScoreColor(value),
              overlayColor: _getScoreColor(value).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (newValue) {
                setState(() {
                  _valueImportance[label] = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score <= 2) {
      return TossTheme.textGray500;
    } else if (score <= 3) {
      return TossTheme.warning;
    } else if (score <= 4) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
    }
  }
}