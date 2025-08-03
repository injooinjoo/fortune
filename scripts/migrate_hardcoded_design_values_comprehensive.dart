import 'dart:io';
import 'dart:convert';

class ComprehensiveDesignMigration {
  static const Map<String, String> colorMappings = {
    // Purple/Spiritual colors - all variations
    '0xFF9333EA': 'FortuneColors.spiritualPrimary',
    '0xFF7C3AED': 'FortuneColors.spiritualPrimary', 
    '0xFF6B21A8': 'FortuneColors.spiritualDark',
    '0xFF9333ea': 'FortuneColors.spiritualPrimary',
    '0xFF7c3aed': 'FortuneColors.spiritualPrimary',
    '0xFF6b21a8': 'FortuneColors.spiritualDark',
    '0xFFE9D5FF': 'FortuneColors.spiritualLight',
    '0xFFe9d5ff': 'FortuneColors.spiritualLight',
    '0xFFF3E8FF': 'FortuneColors.spiritualLighter',
    '0xFFf3e8ff': 'FortuneColors.spiritualLighter',
    
    // Error colors
    '0xFFEF4444': 'AppColors.error',
    '0xFFDC2626': 'AppColors.error',
    '0xFFB91C1C': 'AppColors.error',
    '0xFFef4444': 'AppColors.error',
    '0xFFdc2626': 'AppColors.error',
    '0xFFb91c1c': 'AppColors.error',
    '0xFFFEE2E2': 'AppColors.error.withOpacity(0.1)',
    '0xFFfee2e2': 'AppColors.error.withOpacity(0.1)',
    
    // Warning colors
    '0xFFF59E0B': 'AppColors.warning',
    '0xFFD97706': 'AppColors.warning',
    '0xFFf59e0b': 'AppColors.warning',
    '0xFFd97706': 'AppColors.warning',
    '0xFFFEF3C7': 'AppColors.warning.withOpacity(0.1)',
    '0xFFfef3c7': 'AppColors.warning.withOpacity(0.1)',
    
    // Success colors
    '0xFF10B981': 'AppColors.success',
    '0xFF059669': 'AppColors.success',
    '0xFF10b981': 'AppColors.success',
    '0xFFD1FAE5': 'AppColors.success.withOpacity(0.1)',
    '0xFFd1fae5': 'AppColors.success.withOpacity(0.1)',
    
    // Background colors
    '0xFFF9FAFB': 'AppColors.background',
    '0xFFF3F4F6': 'AppColors.surfaceLight',
    '0xFFf9fafb': 'AppColors.background',
    '0xFFf3f4f6': 'AppColors.surfaceLight',
    '0xFFE5E7EB': 'AppColors.divider',
    '0xFFe5e7eb': 'AppColors.divider',
    
    // Text colors
    '0xFF111827': 'AppColors.textPrimary',
    '0xFF1F2937': 'AppColors.textPrimary',
    '0xFF374151': 'AppColors.textSecondary',
    '0xFF4B5563': 'AppColors.textSecondary',
    '0xFF6B7280': 'AppColors.textTertiary',
    '0xFF9CA3AF': 'AppColors.textTertiary',
    '0xFFD1D5DB': 'AppColors.textTertiary.withOpacity(0.5)',
    
    // White/Black
    '0xFFFFFFFF': 'Colors.white',
    '0xFFffffff': 'Colors.white',
    '0xFF000000': 'Colors.black',
    
    // Transparent
    '0x00000000': 'Colors.transparent',
    
    // Primary colors
    '0xFF3B82F6': 'AppColors.primary',
    '0xFF2563EB': 'AppColors.primary',
    '0xFF1D4ED8': 'AppColors.primary',
    '0xFF3b82f6': 'AppColors.primary',
    '0xFF2563eb': 'AppColors.primary',
    '0xFF1d4ed8': 'AppColors.primary',
    '0xFFDBEAFE': 'AppColors.primary.withOpacity(0.1)',
    '0xFFdbeafe': 'AppColors.primary.withOpacity(0.1)',
    
    // Gold/Special colors
    '0xFFFFD700': 'FortuneColors.goldPrimary',
    '0xFFffd700': 'FortuneColors.goldPrimary',
    '0xFFFBBF24': 'FortuneColors.goldLight',
    '0xFFfbbf24': 'FortuneColors.goldLight',
    '0xFFA16207': 'FortuneColors.goldDark',
    '0xFFa16207': 'FortuneColors.goldDark',
  };
  
  // Advanced replacements for different contexts
  static const Map<String, Map<String, String>> contextualReplacements = {
    'elevation': {
      '0': '0',
      '1': '1',
      '2': '2', 
      '4': '4',
      '8': '8',
      '16': '16',
    },
    'borderRadius': {
      '4': 'AppSpacing.spacing1',
      '8': 'AppSpacing.spacing2',
      '12': 'AppSpacing.spacing3',
      '16': 'AppSpacing.spacing4',
      '20': 'AppSpacing.spacing5',
      '24': 'AppSpacing.spacing6',
      '28': 'AppSpacing.spacing7',
      '32': 'AppSpacing.spacing8',
    },
    'padding': {
      '4': 'AppSpacing.spacing1',
      '8': 'AppSpacing.spacing2',
      '12': 'AppSpacing.spacing3',
      '16': 'AppSpacing.spacing4',
      '20': 'AppSpacing.spacing5',
      '24': 'AppSpacing.spacing6',
      '28': 'AppSpacing.spacing7',
      '32': 'AppSpacing.spacing8',
      '36': 'AppSpacing.spacing9',
      '40': 'AppSpacing.spacing10',
      '48': 'AppSpacing.spacing12',
      '56': 'AppSpacing.spacing14',
      '60': 'AppSpacing.spacing15',
      '64': 'AppSpacing.spacing16',
    },
  };
  
  // Letter spacing and line height constants
  static const Map<String, String> letterSpacingMap = {
    '-0.5': '-0.5',
    '-0.25': '-0.25', 
    '0': '0',
    '0.25': '0.25',
    '0.5': '0.5',
    '1': '1.0',
    '1.5': '1.5',
  };
  
  static const Map<String, String> lineHeightMap = {
    '1': '1.0',
    '1.2': '1.2',
    '1.4': '1.4',
    '1.5': '1.5',
    '1.6': '1.6',
    '1.8': '1.8',
    '2': '2.0',
  };
  
  final List<String> targetDirectories = [
    'lib/features/fortune/presentation/widgets',
    'lib/features/fortune/presentation/pages',
    'lib/presentation/widgets',
    'lib/presentation/screens',
    'lib/screens',
    'lib/shared/components',
    'lib/shared/widgets',
    'lib/shared/glassmorphism',
  ];
  
  Map<String, int> statistics = {
    'filesProcessed': 0,
    'colorsReplaced': 0,
    'fontSizesReplaced': 0,
    'fontWeightsReplaced': 0,
    'elevationsReplaced': 0,
    'borderRadiusReplaced': 0,
    'paddingReplaced': 0,
    'letterSpacingReplaced': 0,
    'heightReplaced': 0,
  };
  
  Set<String> processedFiles = {};
  
  Future<void> run() async {
    print('Starting comprehensive design value migration...');
    print('Target,
    directories: ${targetDirectories.join(", ")}\n');
    
    for (final dir in targetDirectories) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        print('Processing,
    directory: $dir');
        await processDirectory(directory);
      } else {
        print('Directory not,
    found: $dir');
      }
    }
    
    print('\n=== Migration Summary ===');
    statistics.forEach((key, value) {
      print('$key: $value');
    });
    print('\nProcessed,
    files:');
    processedFiles.forEach((file) => print('  - $file'));
  }
  
  Future<void> processDirectory(Directory dir) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
        await processFile(entity);
      }
    }
  }
  
  Future<void> processFile(File file) async {
    String content = await file.readAsString();
    String originalContent = content;
    bool modified = false;
    
    // Skip generated files
    if (content.contains('// GENERATED CODE') || content.contains('// coverage:ignore-file')) {
      return;
    }
    
    // 1. Replace Color(0xFF...) patterns
    colorMappings.forEach((hex, replacement) {
      final pattern = RegExp('Color\\(\$hex\\)');
      final matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, replacement);
        statistics['colorsReplaced'] = statistics['colorsReplaced']! + matches;
        modified = true;
      }
    });
    
    // 2. Replace fontSize in TextStyle comprehensively
    content = replaceFontSizes(content);
    
    // 3. Replace FontWeight with proper copyWith
    content = replaceFontWeights(content);
    
    // 4. Replace elevation values
    content = replaceElevations(content);
    
    // 5. Replace borderRadius values
    content = replaceBorderRadius(content);
    
    // 6. Replace padding/margin values
    content = replacePaddingMargin(content);
    
    // 7. Replace letterSpacing
    content = replaceLetterSpacing(content);
    
    // 8. Replace height (line height)
    content = replaceLineHeight(content);
    
    // Add imports if modified
    if (content != originalContent) {
      statistics['filesProcessed'] = statistics['filesProcessed']! + 1;
      processedFiles.add(file.path);
      
      content = addNecessaryImports(content);
      
      await file.writeAsString(content);
      print('  ✓ Processed: ${file.path}');
    }
  }
  
  String replaceFontSizes(String content) {
    // Complex TextStyle replacement
    final complexPattern = RegExp(
      r'TextStyle\s*\([^)]*fontSize:\s*(\d+)(?:\.0)?[^)]*\)',
      multiLine: true,
      dotAll: true,
    );
    
    content = content.replaceAllMapped(complexPattern, (match) {
      final fullMatch = match.group(0)!;
      final fontSize = match.group(1)!;
      
      // Extract other properties
      final hasColor = fullMatch.contains('color:');
      final hasFontWeight = fullMatch.contains('fontWeight:');
      final hasLetterSpacing = fullMatch.contains('letterSpacing:');
      final hasHeight = fullMatch.contains('height:');
      
      String textTheme = getTextThemeForSize(fontSize);
      
      if (!hasColor && !hasFontWeight && !hasLetterSpacing && !hasHeight) {
        // Simple case - just fontSize
        statistics['fontSizesReplaced'] = statistics['fontSizesReplaced']! + 1;
        return 'Theme.of(context).textTheme.\$textTheme';
      } else {
        // Complex case - need copyWith
        statistics['fontSizesReplaced'] = statistics['fontSizesReplaced']! + 1;
        
        // Extract properties
        Map<String, String> props = extractTextStyleProperties(fullMatch);
        
        String copyWithProps = props.entries
            .where((e) => e.key != 'fontSize')
            .map((e) => '\${e.key}: \${e.value}')
            .join(', ');
        
        return 'Theme.of(context).textTheme.\$textTheme!.copyWith(\$copyWithProps)';
      }
    });
    
    // Simple,
    fontSize: X replacement
    final simpleFontSizePattern = RegExp(r'fontSize:\s*(\d+)(?:\.0)?(?![^,\)]*\?)');
    content = content.replaceAllMapped(simpleFontSizePattern, (match) {
      final size = match.group(1)!;
      if (!match.group(0)!.contains('Theme.of(context)')) {
        statistics['fontSizesReplaced'] = statistics['fontSizesReplaced']! + 1;
        return 'fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize';
      }
      return match.group(0)!;
    });
    
    return content;
  }
  
  String replaceFontWeights(String content) {
    // Replace standalone FontWeight usage
    final standalonePattern = RegExp(r'fontWeight:\s*(FontWeight\.\w+)');
    final matches = standalonePattern.allMatches(content).length;
    if (matches > 0) {
      statistics['fontWeightsReplaced'] = statistics['fontWeightsReplaced']! + matches;
    }
    // Note: We keep FontWeight as is since it's used in copyWith
    return content;
  }
  
  String replaceElevations(String content) {
    contextualReplacements['elevation']!.forEach((value, replacement) {
      final pattern = RegExp('elevation:\\s*\$value(?:\\.0)?(?![0-9])');
      final matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'elevation: \$replacement');
        statistics['elevationsReplaced'] = statistics['elevationsReplaced']! + matches;
      }
    });
    return content;
  }
  
  String replaceBorderRadius(String content) {
    // BorderRadius.circular(X);
    contextualReplacements['borderRadius']!.forEach((value, replacement) {
      final pattern = RegExp('BorderRadius\\.circular\\(\$value(?:\\.0)?\\)');
      final matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'BorderRadius.circular(\$replacement)');
        statistics['borderRadiusReplaced'] = statistics['borderRadiusReplaced']! + matches;
      }
    });
    
    // borderRadius: X
    contextualReplacements['borderRadius']!.forEach((value, replacement) {
      final pattern = RegExp('borderRadius:\\s*\$value(?:\\.0)?(?![0-9])');
      final matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'borderRadius: \$replacement');
        statistics['borderRadiusReplaced'] = statistics['borderRadiusReplaced']! + matches;
      }
    });
    
    return content;
  }
  
  String replacePaddingMargin(String content) {
    // EdgeInsets patterns
    contextualReplacements['padding']!.forEach((value, replacement) {
      // EdgeInsets.all(X);
      var pattern = RegExp('EdgeInsets\\.all\\(\$value(?:\\.0)?\\)');
      var matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'EdgeInsets.all(\$replacement)');
        statistics['paddingReplaced'] = statistics['paddingReplaced']! + matches;
      }
      
      // EdgeInsets.symmetric(horizontal: X, vertical: Y);
      pattern = RegExp('horizontal:\\s*\$value(?:\\.0)?');
      matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'horizontal: \$replacement');
        statistics['paddingReplaced'] = statistics['paddingReplaced']! + matches;
      }
      
      pattern = RegExp('vertical:\\s*\$value(?:\\.0)?');
      matches = pattern.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(pattern, 'vertical: \$replacement');
        statistics['paddingReplaced'] = statistics['paddingReplaced']! + matches;
      }
      
      // EdgeInsets.only patterns
      ['left', 'right', 'top', 'bottom'].forEach((side) {
        pattern = RegExp('\$side:\\s*\$value(?:\\.0)?');
        matches = pattern.allMatches(content).length;
        if (matches > 0) {
          content = content.replaceAll(pattern, '\$side: \$replacement');
          statistics['paddingReplaced'] = statistics['paddingReplaced']! + matches;
        }
      });
    });
    
    return content;
  }
  
  String replaceLetterSpacing(String content) {
    // For now, keep letter spacing values as they are since they're typically small decimal values
    // that don't have direct AppSpacing equivalents
    return content;
  }
  
  String replaceLineHeight(String content) {
    // For now, keep line height values as they are since they're ratios
    // that don't have direct AppSpacing equivalents
    return content;
  }
  
  String getTextThemeForSize(String size) {
    final sizeInt = int.tryParse(size) ?? 14;
    if (sizeInt <= 11) return 'bodySmall';
    if (sizeInt <= 13) return 'bodyMedium';
    if (sizeInt <= 15) return 'bodyLarge';
    if (sizeInt <= 17) return 'titleMedium';
    if (sizeInt <= 20) return 'titleLarge';
    if (sizeInt <= 22) return 'headlineSmall';
    if (sizeInt <= 28) return 'headlineMedium';
    if (sizeInt <= 32) return 'headlineLarge';
    if (sizeInt <= 40) return 'displaySmall';
    if (sizeInt <= 48) return 'displayMedium';
    return 'displayLarge';
  }
  
  Map<String, String> extractTextStyleProperties(String textStyle) {
    Map<String, String> props = {};
    
    // Extract each property
    final colorMatch = RegExp(r'color:\s*([^,\)]+)').firstMatch(textStyle);
    if (colorMatch != null) props['color'] = colorMatch.group(1)!;
    
    final fontWeightMatch = RegExp(r'fontWeight:\s*([^,\)]+)').firstMatch(textStyle);
    if (fontWeightMatch != null) props['fontWeight'] = fontWeightMatch.group(1)!;
    
    final letterSpacingMatch = RegExp(r'letterSpacing:\s*([^,\)]+)').firstMatch(textStyle);
    if (letterSpacingMatch != null) props['letterSpacing'] = letterSpacingMatch.group(1)!;
    
    final heightMatch = RegExp(r'height:\s*([^,\)]+)').firstMatch(textStyle);
    if (heightMatch != null) props['height'] = heightMatch.group(1)!;
    
    final fontSizeMatch = RegExp(r'fontSize:\s*([^,\)]+)').firstMatch(textStyle);
    if (fontSizeMatch != null) props['fontSize'] = fontSizeMatch.group(1)!;
    
    return props;
  }
  
  String addNecessaryImports(String content) {
    List<String> requiredImports = [];
    
    if (content.contains('AppColors.')) {
      requiredImports.add("import 'package:fortune/core/theme/app_colors.dart';");
    }
    
    if (content.contains('FortuneColors.')) {
      requiredImports.add("import 'package:fortune/core/theme/fortune_colors.dart';");
    }
    
    if (content.contains('AppSpacing.')) {
      requiredImports.add("import 'package:fortune/core/theme/app_spacing.dart';");
    }
    
    if (content.contains('Theme.of(context)') && !content.contains("import 'package:flutter/material.dart'")) {
      requiredImports.add("import 'package:flutter/material.dart';");
    }
    
    if (requiredImports.isEmpty) return content;
    
    // Find where to insert imports
    final importPattern = RegExp(r'^import .+;$', multiLine: true);
    final matches = importPattern.allMatches(content).toList();
    
    if (matches.isNotEmpty) {
      final lastImport = matches.last;
      final existingImports = content.substring(0, lastImport.end);
      
      // Add only imports that don't exist
      final importsToAdd = requiredImports
          .where((imp) => !existingImports.contains(imp.replaceAll("import '", "").replaceAll("';", "")))
          .join('\\n');
      
      if (importsToAdd.isNotEmpty) {
        content = content.substring(0, lastImport.end) +
            '\\n' + importsToAdd +
            content.substring(lastImport.end);
      }
    } else {
      // No imports found, add at the beginning
      content = requiredImports.join('\\n') + '\\n\\n' + content;
    }
    
    return content;
  }
}

void main() async {
  final migration = ComprehensiveDesignMigration();
  await migration.run();
}