import 'dart:io';

void main() async {
  print('🔧 Fixing remaining compilation errors...');
  
  // Fix syntax errors in unified pages
  await fixUnifiedPageErrors();
  
  // Fix const AppColors errors
  await fixConstAppColorsErrors();
  
  // Fix const Theme.of(context) errors
  await fixConstThemeOfContextErrors();
  
  // Fix BorderRadius errors
  await fixBorderRadiusErrors();
  
  print('✅ All fixes completed!');
}

Future<void> fixUnifiedPageErrors() async {
  print('\n📝 Fixing unified page syntax errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/health_sports_unified_page.dart',
    'lib/features/fortune/presentation/pages/pet_fortune_unified_page.dart',
    'lib/features/fortune/presentation/pages/personality_fortune_unified_page.dart',
    'lib/features/fortune/presentation/pages/face_reading_unified_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix trailing commas in arrays
    content = content.replaceAllMapped(
      RegExp(r',\s*\)\s*,\s*\]'),
      (match) => ')]'
    );
    
    // Fix context.captionMedium to Theme.of(context).textTheme.bodySmall
    content = content.replaceAll(
      'context.captionMedium',
      'Theme.of(context).textTheme.bodySmall'
    );
    
    // Fix missing semicolons
    content = content.replaceAllMapped(
      RegExp(r'\)\s*,\s*\)\s*;'),
      (match) => ');'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed $filePath');
    }
  }
}

Future<void> fixConstAppColorsErrors() async {
  print('\n📝 Fixing const AppColors errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/lucky_hiking_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_job_fortune_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Remove const from AppColors
    content = content.replaceAllMapped(
      RegExp(r'const\s+AppColors\.(\w+)'),
      (match) => 'AppColors.${match.group(1)}'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed const AppColors in $filePath');
    }
  }
}

Future<void> fixConstThemeOfContextErrors() async {
  print('\n📝 Fixing const Theme.of(context) errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/five_blessings_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_job_fortune_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Remove const from widgets that use Theme.of(context);
    content = content.replaceAllMapped(
      RegExp(r'const\s+(Text|Icon|Container|Column|Row|Padding|Center)\s*\([^{]*Theme\.of\(context\)[^}]*\}?\s*\)'),
      (match) {
        var text = match.group(0)!;
        return text.replaceFirst(RegExp(r'const\s+'), '');
      }
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed const Theme.of(context) in $filePath');
    }
  }
}

Future<void> fixBorderRadiusErrors() async {
  print('\n📝 Fixing BorderRadius type errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix borderRadius expecting BorderRadiusGeometry
    content = content.replaceAllMapped(
      RegExp(r'borderRadius:\s*AppDimensions\.radius(\w+),'),
      (match) => 'borderRadius: BorderRadius.circular(AppDimensions.radius${match.group(1)!}),'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed BorderRadius in $filePath');
    }
  }
}