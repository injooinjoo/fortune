import 'dart:io';

void main() async {
  print('🔧 Fixing critical remaining syntax issues...');
  
  final criticalFiles = [
    'lib/presentation/providers/fortune_provider.dart',
    'lib/screens/settings/settings_screen.dart',
  ];

  int totalProcessed = 0;
  int totalFixed = 0;

  for (final filePath in criticalFiles) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('⚠️  File not found: $filePath');
        continue;
      }

      String content = await file.readAsString();
      final originalContent = content;
      
      content = applyPreciseSyntaxFixes(content);
      
      if (content != originalContent) {
        await file.writeAsString(content);
        print('✅ Fixed: $filePath');
        totalFixed++;
      } else {
        print('ℹ️  No changes: $filePath');
      }
      
      totalProcessed++;
    } catch (e) {
      print('❌ Error processing $filePath: $e');
    }
  }

  print('\n📊 Summary:');
  print('   Files processed: $totalProcessed');
  print('   Files fixed: $totalFixed');
  print('   Success rate: ${totalProcessed > 0 ? ((totalFixed / totalProcessed) * 100).toStringAsFixed(1) : 0}%');
}

String applyPreciseSyntaxFixes(String content) {
  // Fix broken method calls with missing closing parentheses
  content = content.replaceAll(
    'return await _apiService.getLoveFortune(userId: userId,\n  }',
    'return await _apiService.getLoveFortune(userId: userId);\n  }'
  );

  content = content.replaceAll(
    'return await _apiService.getTomorrowFortune(userId: userId,\n  }',
    'return await _apiService.getTomorrowFortune(userId: userId);\n  }'
  );

  content = content.replaceAll(
    'return await _apiService.getWeeklyFortune(userId: userId,\n  }',
    'return await _apiService.getWeeklyFortune(userId: userId);\n  }'
  );

  content = content.replaceAll(
    'return await _apiService.getMonthlyFortune(userId: userId,\n  }',
    'return await _apiService.getMonthlyFortune(userId: userId);\n  }'
  );

  content = content.replaceAll(
    'return await _apiService.getYearlyFortune(userId: userId,\n  }',
    'return await _apiService.getYearlyFortune(userId: userId);\n  }'
  );

  // Fix logger calls missing commas and parentheses
  content = content.replaceAll(
    "'previousType': _mbtiType\n      'newType': mbtiType)\n      'categoriesCount': categories.length)\n      'categories': categories);",
    "'previousType': _mbtiType,\n      'newType': mbtiType,\n      'categoriesCount': categories.length,\n      'categories': categories,"
  );

  // Fix broken logger calls in CompatibilityFortuneNotifier
  content = content.replaceAll(
    "'person1': _person1Data != null)\n        'person2': _person2Data != null);",
    "'person1': _person1Data != null,\n        'person2': _person2Data != null,"
  );

  // Fix settings screen broken constructors that are still malformed
  
  // Fix duplicate Text style declarations
  content = content.replaceAll(
    'Text(\n                          \'계정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n        style: theme.textTheme.titleLarge?.copyWith(,\n      fontWeight: FontWeight.w700, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,\n                          ))])',
    'Text(\n                          \'계정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),'
  );

  // Fix similar patterns for other section headers
  content = content.replaceAll(
    'Text(\n                          \'앱 설정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n        style: theme.textTheme.titleLarge?.copyWith(,\n      fontWeight: FontWeight.w700, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,\n                          ))])',
    'Text(\n                          \'앱 설정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),'
  );

  content = content.replaceAll(
    'Text(\n                          \'결제\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n        style: theme.textTheme.titleLarge?.copyWith(,\n      fontWeight: FontWeight.w700, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,\n                          ))])',
    'Text(\n                          \'결제\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),'
  );

  content = content.replaceAll(
    'Text(\n                          \'지원\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n        style: theme.textTheme.titleLarge?.copyWith(,\n      fontWeight: FontWeight.w700, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,\n                          ))])',
    'Text(\n                          \'지원\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),\n                      ],\n                    ),\n                  ),'
  );

  // Fix broken _buildSettingItem calls
  content = content.replaceAll(
    '_buildSettingItem(\n                    icon: Icons.person_outline),\n        title: \'프로필 편집\',\n                    onTap: () => context.push(\'/profile/edit\'),\n                    isFirst: true),',
    '_buildSettingItem(\n                    icon: Icons.person_outline,\n                    title: \'프로필 편집\',\n                    onTap: () => context.push(\'/profile/edit\'),\n                    isFirst: true,\n                  ),'
  );

  // Fix similar patterns for other _buildSettingItem calls
  content = content.replaceAll(
    'title: \'소셜 계정 연동\'),\n        subtitle: \'여러 로그인 방법을 하나로 관리\'),\n        onTap: () => context.push(\'/settings/social-accounts\')',
    'title: \'소셜 계정 연동\',\n                    subtitle: \'여러 로그인 방법을 하나로 관리\',\n                    onTap: () => context.push(\'/settings/social-accounts\'),'
  );

  content = content.replaceAll(
    'title: \'전화번호 관리\'),\n        subtitle: \'전화번호 변경 및 인증\'),\n        onTap: () => context.push(\'/settings/phone\')',
    'title: \'전화번호 관리\',\n                    subtitle: \'전화번호 변경 및 인증\',\n                    onTap: () => context.push(\'/settings/phone\'),'
  );

  content = content.replaceAll(
    'title: \'알림 설정\'),\n        subtitle: \'푸시, 문자, 운세 알림 관리\'),\n        onTap: () => context.push(\'/settings/notifications\')',
    'title: \'알림 설정\',\n                    subtitle: \'푸시, 문자, 운세 알림 관리\',\n                    onTap: () => context.push(\'/settings/notifications\'),'
  );

  content = content.replaceAll(
    'title: \'운세 기록\'),\n        subtitle: \'지난 운세 보기\'),\n        onTap: () => context.push(\'/fortune/history\'),\n                    isLast: true)])',
    'title: \'운세 기록\',\n                    subtitle: \'지난 운세 보기\',\n                    onTap: () => context.push(\'/fortune/history\'),\n                    isLast: true,\n                  ),\n                ],\n              ),\n            ),'
  );

  // Fix Container constructor issues in settings screen
  content = content.replaceAll(
    'padding: AppSpacing.paddingAll20),\n        decoration: BoxDecoration(,\n      color: AppColors.success.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(,\n      topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n      child: Row(',
    'padding: AppSpacing.paddingAll20,\n                    decoration: BoxDecoration(\n                      color: AppColors.success.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(\n                        topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n                      ),\n                    ),\n                    child: Row('
  );

  content = content.replaceAll(
    'padding: AppSpacing.paddingAll20),\n        decoration: BoxDecoration(,\n      color: AppColors.warning.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(,\n      topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n      child: Row(',
    'padding: AppSpacing.paddingAll20,\n                    decoration: BoxDecoration(\n                      color: AppColors.warning.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(\n                        topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n                      ),\n                    ),\n                    child: Row('
  );

  content = content.replaceAll(
    'padding: AppSpacing.paddingAll20),\n        decoration: BoxDecoration(,\n      color: Colors.purple.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(,\n      topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n      child: Row(',
    'padding: AppSpacing.paddingAll20,\n                    decoration: BoxDecoration(\n                      color: Colors.purple.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(\n                        topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n                      ),\n                    ),\n                    child: Row('
  );

  // Fix _buildSettingItem calls for other sections
  content = content.replaceAll(
    'title: \'다크 모드\'),\n        trailing: Switch(\n                      value: isDarkMode,',
    'title: \'다크 모드\',\n                    trailing: Switch(\n                      value: isDarkMode,'
  );

  content = content.replaceAll(
    'title: \'언어\'),\n        subtitle: \'한국어\'),',
    'title: \'언어\',\n                    subtitle: \'한국어\','
  );

  content = content.replaceAll(
    'title: \'토큰 구매\'),\n        subtitle: \'토큰 충전하기\'),\n        onTap: () => context.go(\'/payment/tokens\'),',
    'title: \'토큰 구매\',\n                    subtitle: \'토큰 충전하기\',\n                    onTap: () => context.go(\'/payment/tokens\'),'
  );

  content = content.replaceAll(
    'title: \'도움말\'),\n        onTap: () => context.push(\'/help\'),',
    'title: \'도움말\',\n                    onTap: () => context.push(\'/help\'),'
  );

  content = content.replaceAll(
    'title: \'개인정보 처리방침\'),\n        onTap: () => context.push(\'/policy/privacy\')',
    'title: \'개인정보 처리방침\',\n                    onTap: () => context.push(\'/policy/privacy\'),'
  );

  content = content.replaceAll(
    'title: \'이용약관\'),\n        onTap: () => context.push(\'/policy/terms\'),\n                    isLast: true)])',
    'title: \'이용약관\',\n                    onTap: () => context.push(\'/policy/terms\'),\n                    isLast: true,\n                  ),\n                ],\n              ),\n            ),'
  );

  // Fix Container constructor issues  
  content = content.replaceAll(
    'width: AppDimensions.buttonHeightSmall,\n              height: AppDimensions.buttonHeightSmall,',
    'width: AppDimensions.buttonHeightSmall,\n              height: AppDimensions.buttonHeightSmall,'
  );

  // Fix Row children with trailing icons
  content = content.replaceAll(
    'trailing ?? (onTap != null ? const Icon(\n              Icons.arrow_forward_ios),\n        size: AppDimensions.iconSizeXSmall),\n        color: AppColors.textSecondary) : const SizedBox.shrink()))',
    'trailing ??\n            (onTap != null\n                ? const Icon(\n                    Icons.arrow_forward_ios,\n                    size: AppDimensions.iconSizeXSmall,\n                    color: AppColors.textSecondary,\n                  )\n                : const SizedBox.shrink()),\n          ],\n        ),\n      ),\n    );'
  );

  return content;
}