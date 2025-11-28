import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 소개팅 운세 페이지의 탭 선택기
class BlindDateTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const BlindDateTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabOptions = [
      {'index': 0, 'icon': Icons.edit, 'label': '기본 정보'},
      {'index': 1, 'icon': Icons.photo_camera, 'label': '사진 분석'},
      {'index': 2, 'icon': Icons.chat_bubble, 'label': '대화 분석'},
    ];

    return Row(
      children: tabOptions.map((tab) {
        final index = tab['index'] as int;
        final icon = tab['icon'] as IconData;
        final label = tab['label'] as String;
        final isSelected = selectedIndex == index;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              onTabChanged(index);
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(
                right: index < 2 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          TossDesignSystem.tossBlue,
                          TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? TossDesignSystem.cardBackgroundDark
                        : TossDesignSystem.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? TossDesignSystem.tossBlue
                      : (isDark
                          ? TossDesignSystem.borderDark
                          : TossDesignSystem.gray200),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? TossDesignSystem.white
                        : (isDark
                            ? TossDesignSystem.grayDark100
                            : TossDesignSystem.gray600),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TypographyUnified.labelMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? TossDesignSystem.white
                          : (isDark
                              ? TossDesignSystem.grayDark100
                              : TossDesignSystem.gray600),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
