import 'dart:io';

class DesignValueFixer {
  int filesProcessed = 0;
  int changesApplied = 0;
  
  Future<void> run() async {
    print('Starting design value fixes...\n');
    
    // Fix files with broken syntax from previous migration
    await fixBrokenFiles();
    
    // Apply remaining migrations
    await applyRemainingMigrations();
    
    print('\n✅ Migration complete!');
    print('Files processed: $filesProcessed');
    print('Changes applied: $changesApplied');
  }
  
  Future<void> fixBrokenFiles() async {
    print('Fixing files with broken syntax...');
    
    // List of files that need fixing based on the error outputs
    final brokenFiles = [
      'lib/screens/settings/settings_screen.dart',
      'lib/presentation/widgets/birth_year_fortune_list.dart',
      'lib/features/fortune/presentation/pages/investment_fortune_page.dart',
      'lib/features/fortune/presentation/pages/sports_fortune_page.dart',
      'lib/features/fortune/presentation/pages/traditional_fortune_unified_page.dart',
      'lib/features/fortune/presentation/pages/crypto_fortune_page.dart',
      'lib/features/fortune/presentation/pages/family_fortune_unified_page.dart',
      'lib/features/fortune/presentation/pages/pet_fortune_unified_page.dart',
      'lib/features/fortune/presentation/pages/personality_fortune_unified_page.dart',
      'lib/features/fortune/presentation/pages/love_fortune_page.dart',
      'lib/features/fortune/presentation/pages/wealth_fortune_page.dart',
    ];
    
    for (final filePath in brokenFiles) {
      final file = File(filePath);
      if (await file.exists()) {
        await fixFile(file);
      }
    }
  }
  
  Future<void> fixFile(File file) async {
    String content = await file.readAsString();
    String originalContent = content;
    
    // Fix broken TextStyle patterns
    // Remove getTextThemeForSize method calls
    content = content.replaceAll(
      RegExp(r'Theme\.of\(context\)\.textTheme\.\$\{getTextThemeForSize\(size\)\}!\.fontSize'),
      'Theme.of(context).textTheme.bodyMedium!.fontSize'
    );
    
    // Fix broken const TextStyle patterns
    content = content.replaceAll(
      RegExp(r'const Theme\.of\(context\)\.textTheme\.\$textTheme(!\.copyWith\(\$copyWithProps\))?'),
      'Theme.of(context).textTheme.bodyMedium'
    );
    
    // Fix Theme.of(context).textTheme.$textTheme patterns
    content = content.replaceAll(
      RegExp(r'Theme\.of\(context\)\.textTheme\.\$textTheme(!\.copyWith\(\$copyWithProps\))?'),
      'Theme.of(context).textTheme.bodyMedium'
    );
    
    // Fix duplicate imports
    final importPattern = RegExp(r'^import .+;$', multiLine: true);
    final imports = importPattern.allMatches(content).map((m) => m.group(0)!).toList();
    final uniqueImports = imports.toSet().toList();
    
    if (imports.length != uniqueImports.length) {
      // Remove all imports and add unique ones
      content = content.replaceAll(importPattern, '');
      content = uniqueImports.join('\n') + '\n' + content.trim();
    }
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed: ${file.path}');
      filesProcessed++;
      changesApplied++;
    }
  }
  
  Future<void> applyRemainingMigrations() async {
    print('\nApplying remaining migrations...');
    
    final directories = [
      'lib/features/fortune/presentation/widgets',
      'lib/features/fortune/presentation/pages',
      'lib/presentation/widgets',
      'lib/presentation/screens',
      'lib/screens',
      'lib/shared/components',
    ];
    
    for (final dir in directories) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        await processDirectory(directory);
      }
    }
  }
  
  Future<void> processDirectory(Directory dir) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
        await migrateFile(entity);
      }
    }
  }
  
  Future<void> migrateFile(File file) async {
    String content = await file.readAsString();
    String originalContent = content;
    
    // Skip generated files
    if (content.contains('// GENERATED CODE') || content.contains('// coverage:ignore-file')) {
      return;
    }
    
    // Simple color replacements
    final colorReplacements = {
      'Color(0xFF9333EA)': 'FortuneColors.spiritualPrimary',
      'Color(0xFF7C3AED)': 'FortuneColors.spiritualPrimary',
      'Color(0xFFEF4444)': 'AppColors.error',
      'Color(0xFFF59E0B)': 'AppColors.warning',
      'Color(0xFF10B981)': 'AppColors.success',
      'Color(0xFFF9FAFB)': 'AppColors.background',
      'Color(0xFF111827)': 'AppColors.textPrimary',
      'Color(0xFF6B7280)': 'AppColors.textTertiary',
      'Color(0xFFFFFFFF)': 'Colors.white',
      'Color(0xFF000000)': 'Colors.black',
    };
    
    colorReplacements.forEach((from, to) {
      if (content.contains(from)) {
        content = content.replaceAll(from, to);
        changesApplied++;
      }
    });
    
    // Simple fontSize replacements in TextStyle
    final fontSizePattern = RegExp(r'fontSize:\s*(\d+)(?:\.0)?(?![^,\)]*Theme\.of)');
    content = content.replaceAllMapped(fontSizePattern, (match) {
      final size = int.parse(match.group(1)!);
      changesApplied++;
      
      if (size <= 12) return 'fontSize: Theme.of(context).textTheme.bodySmall!.fontSize';
      if (size <= 14) return 'fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize';
      if (size <= 16) return 'fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize';
      if (size <= 18) return 'fontSize: Theme.of(context).textTheme.titleMedium!.fontSize';
      if (size <= 20) return 'fontSize: Theme.of(context).textTheme.titleLarge!.fontSize';
      if (size <= 24) return 'fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize';
      if (size <= 28) return 'fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize';
      return 'fontSize: Theme.of(context).textTheme.headlineLarge!.fontSize';
    });
    
    // Add imports if needed
    if (content != originalContent) {
      if (content.contains('AppColors.') && !content.contains('app_colors.dart')) {
        final importPattern = RegExp(r'^import .+;$', multiLine: true);
        final matches = importPattern.allMatches(content).toList();
        if (matches.isNotEmpty) {
          final lastImport = matches.last;
          content = content.substring(0, lastImport.end) +
              '\nimport \'package:fortune/core/theme/app_colors.dart\';' +
              content.substring(lastImport.end);
        }
      }
      
      if (content.contains('FortuneColors.') && !content.contains('fortune_colors.dart')) {
        final importPattern = RegExp(r'^import .+;$', multiLine: true);
        final matches = importPattern.allMatches(content).toList();
        if (matches.isNotEmpty) {
          final lastImport = matches.last;
          content = content.substring(0, lastImport.end) +
              '\nimport \'package:fortune/core/theme/fortune_colors.dart\';' +
              content.substring(lastImport.end);
        }
      }
      
      await file.writeAsString(content);
      print('  ✓ Migrated: ${file.path}');
      filesProcessed++;
    }
  }
}

void main() async {
  final fixer = DesignValueFixer();
  await fixer.run();
}