import 'dart:io';
import 'dart:convert';

class DesignValueMigration {
  static const Map<String, String> colorMappings = {
    // Purple/Spiritual colors
    '0xFF9333EA': 'FortuneColors.spiritualPrimary',
    '0xFF7C3AED': 'FortuneColors.spiritualPrimary',
    '0xFF6B21A8': 'FortuneColors.spiritualPrimary',
    '0xFF9333ea': 'FortuneColors.spiritualPrimary',
    '0xFF7c3aed': 'FortuneColors.spiritualPrimary',
    '0xFF6b21a8': 'FortuneColors.spiritualPrimary',
    
    // Error colors
    '0xFFEF4444': 'AppColors.error',
    '0xFFDC2626': 'AppColors.error',
    '0xFFB91C1C': 'AppColors.error',
    '0xFFef4444': 'AppColors.error',
    '0xFFdc2626': 'AppColors.error',
    '0xFFb91c1c': 'AppColors.error',
    
    // Warning colors
    '0xFFF59E0B': 'AppColors.warning',
    '0xFFD97706': 'AppColors.warning',
    '0xFFf59e0b': 'AppColors.warning',
    '0xFFd97706': 'AppColors.warning',
    
    // Success colors
    '0xFF10B981': 'AppColors.success',
    '0xFF059669': 'AppColors.success',
    '0xFF10b981': 'AppColors.success',
    '0xFF059669': 'AppColors.success',
    
    // Background colors
    '0xFFF9FAFB': 'AppColors.background',
    '0xFFF3F4F6': 'AppColors.surfaceLight',
    '0xFFf9fafb': 'AppColors.background',
    '0xFFf3f4f6': 'AppColors.surfaceLight',
    
    // Dark colors
    '0xFF111827': 'AppColors.textPrimary',
    '0xFF1F2937': 'AppColors.textPrimary',
    '0xFF374151': 'AppColors.textSecondary',
    '0xFF4B5563': 'AppColors.textSecondary',
    '0xFF6B7280': 'AppColors.textTertiary',
    '0xFF9CA3AF': 'AppColors.textTertiary',
    
    // White/Light colors
    '0xFFFFFFFF': 'Colors.white',
    '0xFFffffff': 'Colors.white',
    '0xFF000000': 'Colors.black',
    
    // Fortune specific colors
    '0xFF4B5563': 'FortuneColors.neutralMedium',
    '0xFF6B7280': 'FortuneColors.neutralLight',
    '0xFF9CA3AF': 'FortuneColors.neutralLighter',
    '0xFFD1D5DB': 'FortuneColors.neutralLightest',
    '0xFFE5E7EB': 'FortuneColors.neutralBackground',
    '0xFFF3F4F6': 'FortuneColors.neutralSurface',
    
    // Primary colors
    '0xFF3B82F6': 'AppColors.primary',
    '0xFF2563EB': 'AppColors.primary',
    '0xFF1D4ED8': 'AppColors.primary',
    '0xFF3b82f6': 'AppColors.primary',
    '0xFF2563eb': 'AppColors.primary',
    '0xFF1d4ed8': 'AppColors.primary',
  };
  
  static const Map<String, String> fontSizeMappings = {
    '8': 'Theme.of(context).textTheme.bodySmall!.fontSize',
    '10': 'Theme.of(context).textTheme.bodySmall!.fontSize',
    '11': 'Theme.of(context).textTheme.bodySmall!.fontSize',
    '12': 'Theme.of(context).textTheme.bodyMedium!.fontSize',
    '13': 'Theme.of(context).textTheme.bodyMedium!.fontSize',
    '14': 'Theme.of(context).textTheme.bodyLarge!.fontSize',
    '15': 'Theme.of(context).textTheme.bodyLarge!.fontSize',
    '16': 'Theme.of(context).textTheme.titleMedium!.fontSize',
    '17': 'Theme.of(context).textTheme.titleMedium!.fontSize',
    '18': 'Theme.of(context).textTheme.titleLarge!.fontSize',
    '20': 'Theme.of(context).textTheme.titleLarge!.fontSize',
    '22': 'Theme.of(context).textTheme.headlineSmall!.fontSize',
    '24': 'Theme.of(context).textTheme.headlineMedium!.fontSize',
    '26': 'Theme.of(context).textTheme.headlineMedium!.fontSize',
    '28': 'Theme.of(context).textTheme.headlineMedium!.fontSize',
    '30': 'Theme.of(context).textTheme.headlineLarge!.fontSize',
    '32': 'Theme.of(context).textTheme.headlineLarge!.fontSize',
    '36': 'Theme.of(context).textTheme.displaySmall!.fontSize',
    '40': 'Theme.of(context).textTheme.displayMedium!.fontSize',
    '48': 'Theme.of(context).textTheme.displayLarge!.fontSize',
  };
  
  static const Map<String, String> textStyleMappings = {
    // Map common font size patterns to text styles
    'fontSize: 12': 'style: Theme.of(context).textTheme.bodyMedium',
    'fontSize: 14': 'style: Theme.of(context).textTheme.bodyLarge',
    'fontSize: 16': 'style: Theme.of(context).textTheme.titleMedium',
    'fontSize: 18': 'style: Theme.of(context).textTheme.titleLarge',
    'fontSize: 20': 'style: Theme.of(context).textTheme.titleLarge',
    'fontSize: 24': 'style: Theme.of(context).textTheme.headlineMedium',
    'fontSize: 28': 'style: Theme.of(context).textTheme.headlineMedium',
    'fontSize: 32': 'style: Theme.of(context).textTheme.headlineLarge',
  };
  
  // Files to process
  final List<String> targetDirectories = [
    'lib/features/fortune/presentation/widgets',
    'lib/features/fortune/presentation/pages',
    'lib/presentation/widgets',
    'lib/presentation/screens',
    'lib/screens',
    'lib/shared/components',
    'lib/shared/widgets',
  ];
  
  int filesProcessed = 0;
  int colorsReplaced = 0;
  int fontSizesReplaced = 0;
  int fontWeightsReplaced = 0;
  
  Future<void> run() async {
    print('Starting design value migration...');
    
    for (final dir in targetDirectories) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        await processDirectory(directory);
      }
    }
    
    print('\\nMigration complete!');
    print('Files processed: \$filesProcessed');
    print('Colors replaced: \$colorsReplaced');
    print('Font sizes replaced: \$fontSizesReplaced');
    print('Font weights replaced: \$fontWeightsReplaced');
  }
  
  Future<void> processDirectory(Directory dir) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        await processFile(entity);
      }
    }
  }
  
  Future<void> processFile(File file) async {
    String content = await file.readAsString();
    String originalContent = content;
    
    // Replace hardcoded colors
    colorMappings.forEach((hex, replacement) {
      final pattern = RegExp('Color\\(\$hex\\)');
      if (pattern.hasMatch(content)) {
        content = content.replaceAll(pattern, replacement);
        colorsReplaced += content.split(replacement).length - originalContent.split(replacement).length;
      }
    });
    
    // Replace fontSize in TextStyle
    final fontSizePattern = RegExp(r'fontSize:\s*(\d+)(?:\.0)?(?![^,\)]*\?)');
    content = content.replaceAllMapped(fontSizePattern, (match) {
      final size = match.group(1)!;
      if (fontSizeMappings.containsKey(size)) {
        fontSizesReplaced++;
        return 'fontSize: \${fontSizeMappings[size]!}';
      }
      return match.group(0)!;
    });
    
    // Replace simple TextStyle with just fontSize
    textStyleMappings.forEach((pattern, replacement) {
      final regex = RegExp('TextStyle\\s*\\(\\s*\$pattern\\s*(?:,\\s*)?\\)');
      if (regex.hasMatch(content)) {
        content = content.replaceAll(regex, replacement);
      }
    });
    
    // Replace FontWeight patterns
    final fontWeightPattern = RegExp(r'FontWeight\.(bold|w\d+)');
    content = content.replaceAllMapped(fontWeightPattern, (match) {
      fontWeightsReplaced++;
      return match.group(0)!; // Keep for now, will handle in copyWith
    });
    
    // Handle TextStyle with fontSize and fontWeight
    final textStylePattern = RegExp(
      r'TextStyle\s*\(\s*fontSize:\s*(\d+)(?:\.0)?\s*,\s*fontWeight:\s*(FontWeight\.\w+)\s*(?:,\s*color:\s*([^,\)]+))?\s*\)',
      multiLine: true
    );
    
    content = content.replaceAllMapped(textStylePattern, (match) {
      final size = match.group(1)!;
      final weight = match.group(2)!;
      final color = match.group(3);
      
      String textTheme = '';
      if (size == '12' || size == '13') textTheme = 'bodyMedium';
      else if (size == '14' || size == '15') textTheme = 'bodyLarge';
      else if (size == '16' || size == '17') textTheme = 'titleMedium';
      else if (size == '18' || size == '20') textTheme = 'titleLarge';
      else if (size == '24' || size == '28') textTheme = 'headlineMedium';
      else if (size == '32') textTheme = 'headlineLarge';
      else textTheme = 'bodyMedium';
      
      String result = 'Theme.of(context).textTheme.\$textTheme!.copyWith(fontWeight: \$weight';
      if (color != null) {
        result += ', color: \$color';
      }
      result += ')';
      
      return result;
    });
    
    // Add necessary imports if content was modified and they're not already present
    if (content != originalContent) {
      filesProcessed++;
      
      // Add imports if needed
      if (!content.contains('import \'package:flutter/material.dart\'')) {
        content = 'import \'package:flutter/material.dart\';\n' + content;
      }
      
      if (content.contains('AppColors.') && !content.contains('app_colors.dart')) {
        // Find the last import statement
        final importPattern = RegExp(r'^import .+;$', multiLine: true);
        final matches = importPattern.allMatches(content).toList();
        if (matches.isNotEmpty) {
          final lastImport = matches.last;
          content = content.substring(0, lastImport.end) +
              '\\nimport \'package:fortune/core/theme/app_colors.dart\';' +
              content.substring(lastImport.end);
        }
      }
      
      if (content.contains('FortuneColors.') && !content.contains('fortune_colors.dart')) {
        // Find the last import statement
        final importPattern = RegExp(r'^import .+;$', multiLine: true);
        final matches = importPattern.allMatches(content).toList();
        if (matches.isNotEmpty) {
          final lastImport = matches.last;
          content = content.substring(0, lastImport.end) +
              '\\nimport \'package:fortune/core/theme/fortune_colors.dart\';' +
              content.substring(lastImport.end);
        }
      }
      
      // Write the modified content back
      await file.writeAsString(content);
      print('Processed: \${file.path}');
    }
  }
}

void main() async {
  final migration = DesignValueMigration();
  await migration.run();
}