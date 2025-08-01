import 'dart:io';

void main() async {
  print('🔧 Starting critical syntax fixes for remaining issues...');
  
  // Files with critical syntax errors that need immediate fixing
  final criticalFiles = [
    // Provider files with remaining issues
    'lib/presentation/providers/celebrity_provider.dart',
    'lib/presentation/providers/fortune_provider.dart',
    'lib/presentation/providers/navigation_visibility_provider.dart',
    
    // Settings screen with major syntax issues
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
      
      // Critical syntax fixes
      content = applyCriticalSyntaxFixes(content);
      
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

String applyCriticalSyntaxFixes(String content) {
  // 1. Fix broken provider constructor patterns
  content = content.replaceAll('CelebrityFilter();', 'CelebrityFilter();');
  
  // 2. Fix StateNotifierProvider missing type parameters
  content = content.replaceAll(
    'final navigationVisibilityProvider = StateNotifierProvider((ref) => NavigationVisibilityNotifier());',
    'final navigationVisibilityProvider = StateNotifierProvider<NavigationVisibilityNotifier, NavigationVisibilityState>((ref) => NavigationVisibilityNotifier());'
  );

  // 3. Fix broken copyWith method calls in celebrity provider
  content = content.replaceAll(
    'state = CelebrityFilter(\n      category: state.category,\n      gender: state.gender,\n      minAge: state.minAge,\n      maxAge: state.maxAge,\n      searchQuery: state.searchQuery,\n      zodiacSign: state.zodiacSign),\n        chineseZodiac: state.chineseZodiac);',
    'state = CelebrityFilter(\n      category: state.category,\n      gender: state.gender,\n      minAge: state.minAge,\n      maxAge: state.maxAge,\n      searchQuery: state.searchQuery,\n      zodiacSign: state.zodiacSign,\n      chineseZodiac: state.chineseZodiac,\n    );'
  );

  // 4. Fix missing parenthesis in CelebrityFilterNotifier constructor
  content = content.replaceAll(
    'CelebrityFilterNotifier() : super(CelebrityFilter();',
    'CelebrityFilterNotifier() : super(CelebrityFilter());'
  );

  // 5. Fix broken FortuneState copyWith method
  content = content.replaceAll(
    'FortuneState copyWith({\n    bool? isLoading,\n    Fortune? fortune,\n    String? error,\n  ),\n  }) {',
    'FortuneState copyWith({\n    bool? isLoading,\n    Fortune? fortune,\n    String? error,\n  }) {'
  );

  // 6. Fix broken copyWith call in fortune provider
  content = content.replaceAll(
    'fortune: fortune ?? this.fortune),\n        error: error',
    'fortune: fortune ?? this.fortune,\n      error: error,'
  );

  // 7. Fix broken logger calls with malformed parameters
  content = content.replaceAll(
    'hasError: state.error != null,\n      hasFortune: state.fortune != null)\n      fortuneId: state.fortune?.id)\n      errorMessage: state.error);\n  });',
    'hasError: state.error != null,\n      hasFortune: state.fortune != null,\n      fortuneId: state.fortune?.id,\n      errorMessage: state.error,\n    });'
  );

  // 8. Fix broken logger calls in multiple places
  content = content.replaceAll(
    'userId: user?.id,\n        email: user?.email\n        isAuthenticated: user != null)\n        userRole: user?.role)\n        emailVerified: user?.emailConfirmedAt != null);\n  });',
    'userId: user?.id,\n        email: user?.email,\n        isAuthenticated: user != null,\n        userRole: user?.role,\n        emailVerified: user?.emailConfirmedAt != null,\n      });'
  );

  // 9. Fix broken logger parameters in generateFortune calls
  content = content.replaceAll(
    'userId: user.id)\n        notifierType: runtimeType.toString(),',
    'userId: user.id,\n        notifierType: runtimeType.toString(),'
  );

  // 10. Fix all broken logger parameter formatting
  content = content.replaceAllMapped(
    RegExp(r'(\w+): ([^,)]+)\)\s*([^}]+)\}(?!\s*\);)'),
    (match) => '${match.group(1)}: ${match.group(2)},${match.group(3)}}'
  );

  // 11. Fix state update calls with broken syntax
  content = content.replaceAll(
    'state = state.copyWith(\n        isLoading: false),\n        fortune: fortune);',
    'state = state.copyWith(\n        isLoading: false,\n        fortune: fortune,\n      );'
  );

  content = content.replaceAll(
    'state = state.copyWith(\n        isLoading: false),\n        error: e.toString())',
    'state = state.copyWith(\n        isLoading: false,\n        error: e.toString(),\n      );'
  );

  // 12. Fix getDailyFortune call with broken parameters
  content = content.replaceAll(
    'final fortune = await _apiService.getDailyFortune(\n        userId: userId),\n        date: _selectedDate\n      );',
    'final fortune = await _apiService.getDailyFortune(\n        userId: userId,\n        date: _selectedDate,\n      );'
  );

  // 13. Fix all similar broken method calls
  content = content.replaceAllMapped(
    RegExp(r'(\w+): ([^,)]+)\),\s*([^)]+)\s*\);'),
    (match) => '${match.group(1)}: ${match.group(2)},\n        ${match.group(3)},\n      );'
  );

  // 14. Fix AsyncValue constructor with missing closing parenthesis
  content = content.replaceAll(
    'FortuneHistoryNotifier(this._apiService, this.ref)\n      : super(const AsyncValue.loading();',
    'FortuneHistoryNotifier(this._apiService, this.ref)\n      : super(const AsyncValue.loading());'
  );

  // 15. Fix celebrity suggestions provider with broken comment
  content = content.replaceAll(
    'final celebritySuggestionsProvider = Provider.family<List<Celebrity>, String>((ref, query) {',
    '// Celebrity suggestions provider (for autocomplete)\nfinal celebritySuggestionsProvider = Provider.family<List<Celebrity>, String>((ref, query) {'
  );

  // 16. Fix fortune service provider comment
  content = content.replaceAll(
    '// Fortune Service Provider (for base pages,',
    '// Fortune Service Provider (for base pages)'
  );

  // 17. Fix settings screen AppBar constructor
  content = content.replaceAll(
    'appBar: AppBar(\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        leading: IconButton(\n          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n        ),\n        title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge,\n        ),\n      ),\n      elevation: 0),\n        leading: IconButton(,',
    'appBar: AppBar(\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        leading: IconButton(\n          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n        ),\n        title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge,\n        ),\n      ),'
  );

  // 18. Fix settings screen body constructor
  content = content.replaceAll(
    'body: SingleChildScrollView(,\n      child: Column(,\n      crossAxisAlignment: CrossAxisAlignment.start,\n              ),',
    'body: SingleChildScrollView(\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,'
  );

  // 19. Fix malformed Container constructors
  content = content.replaceAllMapped(
    RegExp(r'margin: ([^)]+)\),\s*decoration: BoxDecoration\(,\s*color: ([^,]+),\s*\),\s*borderRadius: ([^)]+)\),'),
    (match) => 'margin: ${match.group(1)},\n              decoration: BoxDecoration(\n                color: ${match.group(2)},\n                borderRadius: ${match.group(3)},'
  );

  // 20. Fix withValues calls with malformed parameters
  content = content.replaceAll('withValues(alph,\n      a: ', 'withValues(alpha: ');
  content = content.replaceAll('withValues(alp,\n      ha: ', 'withValues(alpha: ');

  // 21. Fix method signature in _buildSettingItem
  content = content.replaceAll(
    'VoidCallback? onTap)\n    bool isFirst = false)\n    bool isLast = false}) {',
    'VoidCallback? onTap,\n    bool isFirst = false,\n    bool isLast = false,\n  }) {'
  );

  // 22. Fix EdgeInsets.symmetric call
  content = content.replaceAll(
    'EdgeInsets.symmetric(horizont,\n      al: ',
    'EdgeInsets.symmetric(horizontal: '
  );

  // 23. Fix Container width/height declarations
  content = content.replaceAll(
    'width: AppDimensions.buttonHeightSmall),\n              height: AppDimensions.buttonHeightSmall),',
    'width: AppDimensions.buttonHeightSmall,\n              height: AppDimensions.buttonHeightSmall,'
  );

  // 24. Fix Icon constructor call
  content = content.replaceAll(
    'Icon(\n                icon,\n        ),\n        color: _getIconColor(icon),',
    'Icon(\n                icon,\n                color: _getIconColor(icon),'
  );

  // 25. Fix Text style formatting
  content = content.replaceAll(
    'style: Theme.of(context).textTheme.titleMedium?.copyWith(,\n      color: AppColors.textPrimary,\n                          ),\n        fontWeight: FontWeight.w500)\n                        ))',
    'style: Theme.of(context).textTheme.titleMedium?.copyWith(\n                            color: AppColors.textPrimary,\n                            fontWeight: FontWeight.w500,\n                          ),\n                        )'
  );

  // 26. Fix OutlinedButton styleFrom
  content = content.replaceAll(
    'style: OutlinedButton.styleFrom(,\n      padding: AppSpacing.paddingVertical16),\n        side: BorderSide(colo,\n      r: theme.colorScheme.error),',
    'style: OutlinedButton.styleFrom(\n                    padding: AppSpacing.paddingVertical16,\n                    side: BorderSide(color: theme.colorScheme.error),'
  );

  // 27. Fix Text constructor with broken style
  content = content.replaceAll(
    'Text(\n                    \'로그아웃\'),\n        style: Theme.of(context).textTheme.titleSmall?.copyWith(,\n      color: theme.colorScheme.error,\n                          )))))))',
    'Text(\n                    \'로그아웃\',\n                    style: Theme.of(context).textTheme.titleSmall?.copyWith(\n                      color: theme.colorScheme.error,\n                    ),\n                  )'
  );

  // 28. Fix final closing parentheses in settings screen
  content = content.replaceAll(
    'Text(\n                \'Fortune v1.0.0\'),\n        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,\n      color: AppColors.textSecondary,\n                          ))))',
    'Text(\n                \'Fortune v1.0.0\',\n                style: Theme.of(context).textTheme.bodyMedium?.copyWith(\n                  color: AppColors.textSecondary,\n                ),\n              )'
  );

  return content;
}