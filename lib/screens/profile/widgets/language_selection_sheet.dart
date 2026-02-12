import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/extensions/l10n_extension.dart';

/// 언어 선택 바텀 시트
class LanguageSelectionSheet extends ConsumerWidget {
  const LanguageSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (_) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: DSSpacing.sm),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Row(
                children: [
                  Text(
                    context.l10n.languageSelection,
                    style: context.heading3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: context.colors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 언어 목록
            ...supportedLanguages.map((language) {
              final isSelected =
                  currentLocale.languageCode == language.locale.languageCode;

              return ListTile(
                leading: _buildLanguageIcon(language.locale.languageCode),
                title: Text(
                  language.nativeName,
                  style: context.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  language.englishName,
                  style: context.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: context.colors.accent,
                      )
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(language.locale);
                  Navigator.pop(context);
                },
              );
            }),

            const SizedBox(height: DSSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageIcon(String languageCode) {
    String flag;
    switch (languageCode) {
      case 'ko':
        flag = '🇰🇷';
        break;
      case 'en':
        flag = '🇺🇸';
        break;
      case 'ja':
        flag = '🇯🇵';
        break;
      default:
        flag = '🌐';
    }

    return Text(
      flag,
      style: const TextStyle(fontSize: 24),
    );
  }
}
