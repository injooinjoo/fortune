import 'dart:io';

void main() async {
  print('🔧 Final pass: fixing remaining critical syntax issues...');
  
  final criticalFiles = [
    'lib/presentation/providers/celebrity_provider.dart',
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
      
      content = applyFinalSyntaxFixes(content);
      
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

String applyFinalSyntaxFixes(String content) {
  // Fix celebrity provider CelebrityFilter constructor calls with extra commas
  content = content.replaceAll(
    'zodiacSign: state.zodiacSign,,\n        chineseZodiac: state.chineseZodiac);',
    'zodiacSign: state.zodiacSign,\n      chineseZodiac: state.chineseZodiac,\n    );'
  );

  // Fix fortune provider - broken logger parameters
  content = content.replaceAll(
    "'luckyItemsCount': fortune.luckyItems?.length ?? 0)\n        'recommendationsCount': fortune.recommendations?.length ?? 0)\n        'generationTime': '\${fortuneStopwatch.elapsedMilliseconds}ms');",
    "'luckyItemsCount': fortune.luckyItems?.length ?? 0,\n        'recommendationsCount': fortune.recommendations?.length ?? 0,\n        'generationTime': '\${fortuneStopwatch.elapsedMilliseconds}ms',"
  );

  // Fix broken state updates
  content = content.replaceAll(
    'isLoading: false,,\n        fortune: fortune);',
    'isLoading: false,\n        fortune: fortune,\n      );'
  );

  content = content.replaceAll(
    "'totalLoadTime': '\${stopwatch.elapsedMilliseconds}ms')\n        'fortuneId': fortune.id);",
    "'totalLoadTime': '\${stopwatch.elapsedMilliseconds}ms',\n        'fortuneId': fortune.id,"
  );

  content = content.replaceAll(
    'error: e.toString(,\n         ,\n      );',
    'error: e.toString(),\n      );'
  );

  // Fix logger method calls
  content = content.replaceAll(
    "'method': 'getDailyFortune')\n        'userId': userId)\n        'date': _selectedDate?.toIso8601String(),",
    "'method': 'getDailyFortune',\n        'userId': userId,\n        'date': _selectedDate?.toIso8601String(),"
  );

  content = content.replaceAll(
    'userId: userId,,\n        date: _selectedDate\n      );',
    'userId: userId,\n        date: _selectedDate,\n      );'
  );

  // Fix ValidationException calls with extra commas
  content = content.replaceAll(
    'ValidationException(message: \'생년월일 정보가 필요합니다\',;',
    'ValidationException(message: \'생년월일 정보가 필요합니다\');'
  );
  
  content = content.replaceAll(
    'ValidationException(message: \'두 사람의 정보가 모두 필요합니다\',;',
    'ValidationException(message: \'두 사람의 정보가 모두 필요합니다\');'
  );
  
  content = content.replaceAll(
    'ValidationException(message: \'재무 정보가 필요합니다\',;',
    'ValidationException(message: \'재무 정보가 필요합니다\');'
  );
  
  content = content.replaceAll(
    'ValidationException(message: \'MBTI 타입과 카테고리를 선택해주세요\',;',
    'ValidationException(message: \'MBTI 타입과 카테고리를 선택해주세요\');'
  );

  // Fix getSajuFortune call
  content = content.replaceAll(
    'userId: userId,,\n        birthDate: birthDate\n      );',
    'userId: userId,\n        birthDate: birthDate,\n      );'
  );

  // Fix broken logger calls
  content = content.replaceAll(
    "'fortuneId': fortune.id)\n        'overallScore': fortune.overallScore)\n        'generationTime': '\${stopwatch.elapsedMilliseconds}ms');",
    "'fortuneId': fortune.id,\n        'overallScore': fortune.overallScore,\n        'generationTime': '\${stopwatch.elapsedMilliseconds}ms',"
  );

  // Fix CompatibilityFortuneNotifier logger calls
  content = content.replaceAll(
    "'person1': _person1Data!['name'])\n        'person2': _person2Data!['name']);",
    "'person1': _person1Data!['name'],\n        'person2': _person2Data!['name'],"
  );

  content = content.replaceAll(
    'person1: _person1Data!,,\n        person2: _person2Data!\n      );',
    'person1: _person1Data!,\n        person2: _person2Data!,\n      );'
  );

  content = content.replaceAll(
    "'fortuneId': fortune.id)\n        'overallScore': fortune.overallScore)\n        'apiCallTime': '\${stopwatch.elapsedMilliseconds}ms');",
    "'fortuneId': fortune.id,\n        'overallScore': fortune.overallScore,\n        'apiCallTime': '\${stopwatch.elapsedMilliseconds}ms',"
  );

  // Fix method calls with extra commas
  content = content.replaceAll(
    'userId: userId,;',
    'userId: userId,'
  );

  content = content.replaceAll(
    'userId: userId,,\n        financialData: _financialData!\n    );',
    'userId: userId,\n      financialData: _financialData!,\n    );'
  );

  content = content.replaceAll(
    'userId: userId,,\n        mbtiType: _mbtiType!,\n        categories: _categories\n    ,\n      );',
    'userId: userId,\n      mbtiType: _mbtiType!,\n      categories: _categories,\n    );'
  );

  // Fix FortuneHistoryNotifier logger calls
  content = content.replaceAll(
    "'limit': limit)\n      'offset': offset)\n      'timestamp': DateTime.now().toIso8601String(),",
    "'limit': limit,\n      'offset': offset,\n      'timestamp': DateTime.now().toIso8601String(),"
  );

  content = content.replaceAll(
    'userId: user.id,,\n        limit: limit,\n        offset: offset\n      ,\n      );',
    'userId: user.id,\n        limit: limit,\n        offset: offset,\n      );'
  );

  content = content.replaceAll(
    "'itemCount': history.length)\n        'loadTime': '\${stopwatch.elapsedMilliseconds}ms');",
    "'itemCount': history.length,\n        'loadTime': '\${stopwatch.elapsedMilliseconds}ms',"
  );

  // Fix Fortune Generation Provider logger calls
  content = content.replaceAll(
    "'userId': user.id)\n      'fortuneType': params.fortuneType)\n      'paramCount': params.userInfo.length);",
    "'userId': user.id,\n      'fortuneType': params.fortuneType,\n      'paramCount': params.userInfo.length,"
  );

  content = content.replaceAll(
    'userId: user.id,,\n        fortuneType: params.fortuneType,\n        params: params.userInfo\n    ,\n      );',
    'userId: user.id,\n      fortuneType: params.fortuneType,\n      params: params.userInfo,\n    );'
  );

  content = content.replaceAll(
    "'fortuneType': params.fortuneType)\n      'overallScore': fortune.overallScore)\n      'generationTime': '\${stopwatch.elapsedMilliseconds}ms');",
    "'fortuneType': params.fortuneType,\n      'overallScore': fortune.overallScore,\n      'generationTime': '\${stopwatch.elapsedMilliseconds}ms',"
  );

  // Fix settings screen issues
  content = content.replaceAll(
    'backgroundColor: AppColors.getCardBackground(context,,',
    'backgroundColor: AppColors.getCardBackground(context),'
  );

  // Remove duplicate AppBar properties
  content = content.replaceAll(
    'appBar: AppBar(\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        leading: IconButton(\n          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n        ),\n        title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge,\n        ),\n      ),\n      icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n      title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge),',
    'appBar: AppBar(\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        leading: IconButton(\n          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n        ),\n        title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge,\n        ),\n      ),'
  );

  // Fix Container constructor issues
  content = content.replaceAll(
    'Container(\nmargin: AppSpacing.paddingHorizontal16,',
    'Container(\n              margin: AppSpacing.paddingHorizontal16,'
  );

  // Fix missing closing brackets and parentheses
  content = content.replaceAll(
    'const Offset(0, 2)))\n              child: Column(,\n      crossAxisAlignment: CrossAxisAlignment.start,\n              ),',
    'const Offset(0, 2)),\n                ],\n              ),\n              child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,'
  );

  // Fix broken Text and Container constructors
  content = content.replaceAll(
    'padding: AppSpacing.paddingAll20),\n        decoration: BoxDecoration(,\n      color: AppColors.primary.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(,\n      topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n      child: Row(',
    'padding: AppSpacing.paddingAll20,\n                    decoration: BoxDecoration(\n                      color: AppColors.primary.withValues(alpha: 0.1),\n                      borderRadius: const BorderRadius.only(\n                        topLeft: Radius.circular(16),\n                        topRight: Radius.circular(16),\n                      ),\n                    ),\n                    child: Row('
  );

  // Fix Text constructor in headers
  content = content.replaceAll(
    'Text(\n                          \'계정\',\n        ),',
    'Text(\n                          \'계정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),'
  );

  // Fix similar patterns for other section headers
  content = content.replaceAll(
    'Text(\n                          \'앱 설정\',\n        ),',
    'Text(\n                          \'앱 설정\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),'
  );

  content = content.replaceAll(
    'Text(\n                          \'결제\',\n        ),',
    'Text(\n                          \'결제\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),'
  );

  content = content.replaceAll(
    'Text(\n                          \'지원\',\n        ),',
    'Text(\n                          \'지원\',\n                          style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.w700,\n                          ),\n                        ),'
  );

  // Fix _buildSettingItem calls with broken syntax
  content = content.replaceAll(
    'title: \'프로필 편집\'),\n        onTap: () => context.push(\'/profile/edit\'),',
    'title: \'프로필 편집\',\n                    onTap: () => context.push(\'/profile/edit\'),'
  );

  // Fix Switch constructor
  content = content.replaceAll(
    'trailing: Switch(,\n      value: isDarkMode,\n                    ),',
    'trailing: Switch(\n                      value: isDarkMode,'
  );

  content = content.replaceAll(
    'activeColor: AppColors.primary,,',
    'activeColor: AppColors.primary,\n                    ),'
  );

  // Fix onTap callbacks with missing commas
  content = content.replaceAll(
    'onTap: () {\n                      // TODO: Implement language selection\n                    }\n                    isLast: true,])',
    'onTap: () {\n                      // TODO: Implement language selection\n                    },\n                    isLast: true,\n                  ),\n                ],\n              ),\n            ),'
  );

  // Fix OutlinedButton style issues
  content = content.replaceAll(
    'style: OutlinedButton.styleFrom(,\n      padding: AppSpacing.paddingVertical16,,\n        side: BorderSide(colo,\n      r: theme.colorScheme.error),\n                    shape: RoundedRectangleBorder(,\n      borderRadius: AppDimensions.borderRadiusSmall)',
    'style: OutlinedButton.styleFrom(\n                    padding: AppSpacing.paddingVertical16,\n                    side: BorderSide(color: theme.colorScheme.error),\n                    shape: RoundedRectangleBorder(\n                      borderRadius: AppDimensions.borderRadiusSmall,\n                    ),\n                  ),'
  );

  // Fix Container width/height syntax
  content = content.replaceAll(
    'width: AppDimensions.buttonHeightSmall,\n              height: AppDimensions.buttonHeightSmall,\n        decoration: BoxDecoration(,\n      color: _getIconBackgroundColor(icon),\n                borderRadius: AppDimensions.borderRadiusSmall),',
    'width: AppDimensions.buttonHeightSmall,\n              height: AppDimensions.buttonHeightSmall,\n              decoration: BoxDecoration(\n                color: _getIconBackgroundColor(icon),\n                borderRadius: AppDimensions.borderRadiusSmall,\n              ),'
  );

  // Fix Icon constructor
  content = content.replaceAll(
    'child: Icon(\n                icon,\n                color: _getIconColor(icon),\n                size: 22)',
    'child: Icon(\n                icon,\n                color: _getIconColor(icon),\n                size: 22,\n              ),'
  );

  // Fix BorderRadius constructor
  content = content.replaceAll(
    'borderRadius: isLast ? const BorderRadius.only(,\n      bottomLeft: Radius.circular(16,,\n        bottomRight: Radius.circular(16)) : null,',
    'borderRadius: isLast\n          ? const BorderRadius.only(\n              bottomLeft: Radius.circular(16),\n              bottomRight: Radius.circular(16),\n            )\n          : null,'
  );

  // Fix Container padding syntax
  content = content.replaceAll(
    'child: Container(,\n      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing4),\n        decoration: BoxDecoration(,\n      border: Border(,\n      bottom: isLast ? BorderSide.none : const BorderSide(,\n      color: AppColors.divider,\n        ),\n        width: 1),',
    'child: Container(\n        padding: EdgeInsets.symmetric(\n          horizontal: AppSpacing.spacing5,\n          vertical: AppSpacing.spacing4,\n        ),\n        decoration: BoxDecoration(\n          border: Border(\n            bottom: isLast\n                ? BorderSide.none\n                : const BorderSide(\n                    color: AppColors.divider,\n                    width: 1,\n                  ),\n          ),\n        ),'
  );

  // Fix Column constructor
  content = content.replaceAll(
    'child: Column(,\n      crossAxisAlignment: CrossAxisAlignment.start,\n              ),',
    'child: Column(\n                crossAxisAlignment: CrossAxisAlignment.start,'
  );

  // Fix withValues calls with extra commas
  content = content.replaceAll(
    'withValues(alpha: 0.2,;',
    'withValues(alpha: 0.2);'
  );

  content = content.replaceAll(
    'withValues(alpha: 0.9,;',
    'withValues(alpha: 0.9);'
  );

  return content;
}