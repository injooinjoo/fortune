import 'dart:io';

void main() async {
  print('🔧 Fixing FINAL compilation errors...');
  
  // Fix AppColors const errors
  await fixAppColorsConstErrors();
  
  // Fix Theme.of(context) in const widgets
  await fixThemeOfContextErrors();
  
  // Fix remaining text theme issues
  await fixTextThemeErrors();
  
  print('✅ All fixes completed!');
}

Future<void> fixAppColorsConstErrors() async {
  print('\n📝 Fixing AppColors const errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart',
    'lib/features/fortune/presentation/pages/lucky_running_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_cycling_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_swim_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_investment_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_crypto_fortune_page.dart',
    'lib/features/fortune/presentation/pages/network_report_fortune_page.dart',
    'lib/features/fortune/presentation/pages/birth_season_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_exam_fortune_page.dart',
    'lib/features/fortune/presentation/pages/time_specific_fortune_card.dart',
    'lib/presentation/widgets/time_specific_fortune_card.dart',
    'lib/features/fortune/presentation/pages/children_fortune_page.dart',
    'lib/features/fortune/presentation/pages/couple_match_page.dart',
    'lib/features/fortune/presentation/pages/personality_fortune_optimized_page.dart',
    'lib/screens/home/home_screen.dart',
    'lib/screens/home/home_screen_updated.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix const AppColors.xxx patterns
    content = content.replaceAllMapped(
      RegExp(r'const\s+AppColors\.(\w+)'),
      (match) => 'AppColors.${match.group(1)}'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed AppColors const in $filePath');
    }
  }
}

Future<void> fixThemeOfContextErrors() async {
  print('\n📝 Fixing Theme.of(context) in const widgets...');
  
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in files) {
    var content = await file.readAsString();
    var modified = false;
    
    // Fix const Text with Theme.of(context)
    var newContent = content.replaceAllMapped(
      RegExp(r'const\s+(Text|Icon|Container|Column|Row|Padding|Center|Card|DecoratedBox|AnimatedContainer)\s*\([^{]*Theme\.of\(context\)[^}]*\}?\s*\)'),
      (match) {
        modified = true;
        var text = match.group(0)!;
        // Remove const from the widget
        return text.replaceFirst(RegExp(r'const\s+'), '');
      }
    );
    
    // Fix const constructors with Theme.of(context)
    newContent = newContent.replaceAllMapped(
      RegExp(r'const\s+\w+\s*\([^)]*Theme\.of\(context\)[^)]*\)'),
      (match) {
        modified = true;
        var text = match.group(0)!;
        return text.replaceFirst('const ', '');
      }
    );
    
    if (modified) {
      await file.writeAsString(newContent);
      print('  ✓ Fixed Theme.of(context) const in ${file.path}');
    }
  }
}

Future<void> fixTextThemeErrors() async {
  print('\n📝 Fixing text theme errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/personality_fortune_optimized_page.dart',
    'lib/presentation/widgets/time_specific_fortune_card.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix textTheme.xxx to textTheme.xxx?
    content = content.replaceAllMapped(
      RegExp(r'(theme\.textTheme\.\w+)(\.copyWith)'),
      (match) => '${match.group(1)}?${match.group(2)}'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed text theme in $filePath');
    }
  }
}