import 'dart:io';

/// Final typography migration script - handles all remaining patterns
/// Run: dart scripts/migrate_typography_final.dart [files...]

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart migrate_typography_final.dart <file1> <file2> ...');
    exit(1);
  }

  var successCount = 0;
  var failureCount = 0;
  final failures = <String>[];

  for (final filePath in args) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not,
    found: $filePath');
      failureCount++;
      continue;
    }

    try {
      final migrated = await migrateFile(file);
      if (migrated) {
        print('✅ Migrated: $filePath');
        successCount++;
      } else {
        print('ℹ️  Skipped (already migrated): $filePath');
      }
    } catch (e) {
      print('❌ Failed: $filePath - $e');
      failureCount++;
      failures.add('$filePath: $e');
    }
  }

  print('\n📊 Migration,
    Summary:');
  print('   ✅ Success: $successCount files');
  print('   ❌ Failed: $failureCount files');
  if (failures.isNotEmpty) {
    print('\n🔥 Failed,
    files:');
    failures.forEach(print);
  }
}

Future<bool> migrateFile(File file) async {
  var content = await file.readAsString();
  final originalContent = content;

  // Skip if already migrated
  if (content.contains('app_typography.dart') && 
      content.contains('AppTypography')) {
    return false;
  }

  // Add imports if not present
  content = addImports(content);

  // Replace TextStyle patterns
  content = replaceTextStyles(content);

  // Replace color patterns
  content = replaceColors(content);

  // Replace spacing patterns
  content = replaceSpacing(content);

  // Replace dimension patterns
  content = replaceDimensions(content);

  // Replace button text patterns
  content = replaceButtonTextPatterns(content);

  // Handle special cases
  content = handleSpecialCases(content);

  // Only write if content changed
  if (content != originalContent) {
    await file.writeAsString(content);
    return true;
  }

  return false;
}

String addImports(String content) {
  final imports = <String>[];
  
  // Check what imports are needed
  if ((content.contains('TextStyle') || content.contains('fontSize:') || 
       content.contains('fontWeight:')) && 
      !content.contains('app_typography.dart')) {
    imports.add("import 'package:fortune/core/theme/app_typography.dart';");
  }
  
  if ((content.contains('Color(') || content.contains('Colors.')) && 
      !content.contains('app_colors.dart')) {
    imports.add("import 'package:fortune/core/theme/app_colors.dart';");
  }
  
  if ((content.contains('EdgeInsets') || content.contains('SizedBox')) && 
      !content.contains('app_spacing.dart')) {
    imports.add("import 'package:fortune/core/theme/app_spacing.dart';");
  }
  
  if ((content.contains('BorderRadius') || content.contains('height:') || 
       content.contains('width:')) && 
      !content.contains('app_dimensions.dart')) {
    imports.add("import 'package:fortune/core/theme/app_dimensions.dart';");
  }

  if (imports.isEmpty) return content;

  // Find the last import statement
  final importRegex = RegExp(r'^import\s+[^;]+;', multiLine: true);
  final matches = importRegex.allMatches(content).toList();
  
  if (matches.isNotEmpty) {
    final lastImport = matches.last;
    final insertPosition = lastImport.end;
    
    // Insert the new imports after the last import
    final before = content.substring(0, insertPosition);
    final after = content.substring(insertPosition);
    
    content = before + '\n' + imports.join('\n') + after;
  } else {
    // No imports found, add at the beginning after library/part statements
    final libraryMatch = RegExp(r'^(library|part\s+of)[^;]+;', multiLine: true).firstMatch(content);
    if (libraryMatch != null) {
      final insertPosition = libraryMatch.end;
      final before = content.substring(0, insertPosition);
      final after = content.substring(insertPosition);
      content = before + '\n\n' + imports.join('\n') + after;
    } else {
      // Add at the very beginning
      content = imports.join('\n') + '\n\n' + content;
    }
  }

  return content;
}

String replaceTextStyles(String content) {
  // Map common text styles to typography system
  final styleReplacements = {
    // Display styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*3[2-9]'): 'context.displaySmall',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*4[0-9]'): 'context.displayMedium',
    
    // Headline styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*2[4-8],?\s*fontWeight:\s*FontWeight\.bold'): 'context.headlineLarge',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*2[0-3],?\s*fontWeight:\s*FontWeight\.[w6-9]'): 'context.headlineMedium',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[8-9],?\s*fontWeight:\s*FontWeight\.[w6-9]'): 'context.headlineSmall',
    
    // Title styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[8-9]'): 'context.titleLarge',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[6-7]'): 'context.titleMedium',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[4-5]'): 'context.titleSmall',
    
    // Body styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[6-7],?\s*fontWeight:\s*FontWeight\.normal'): 'context.bodyLarge',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[4-5],?\s*fontWeight:\s*FontWeight\.normal'): 'context.bodyMedium',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[2-3]'): 'context.bodySmall',
    
    // Label styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[4-5],?\s*fontWeight:\s*FontWeight\.w500'): 'context.labelLarge',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[2-3],?\s*fontWeight:\s*FontWeight\.w500'): 'context.labelMedium',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[0-1],?\s*fontWeight:\s*FontWeight\.w500'): 'context.labelSmall',
    
    // Caption styles
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[2-3],?\s*color:'): 'context.captionLarge',
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[0-1]'): 'context.captionMedium',
  };

  // First,
    pass: Replace simple TextStyle patterns
  for (final entry in styleReplacements.entries) {
    content = content.replaceAllMapped(entry.key, (match) {
      return entry.value;
    });
  }

  // Second,
    pass: Handle TextStyle with copyWith
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\([^)]+\)\.copyWith\s*\([^)]+\)'),
    (match) {
      final style = match.group(0)!;
      // Try to identify the base style
      if (style.contains('fontSize: 20') || style.contains('fontSize: 24')) {
        return 'context.headlineMedium.copyWith${style.substring(style.indexOf('.copyWith') + 9)}';
      } else if (style.contains('fontSize: 16')) {
        return 'context.bodyLarge.copyWith${style.substring(style.indexOf('.copyWith') + 9)}';
      } else if (style.contains('fontSize: 14')) {
        return 'context.bodyMedium.copyWith${style.substring(style.indexOf('.copyWith') + 9)}';
      }
      return style; // Keep original if can't determine
    },
  );

  // Third,
    pass: Handle remaining TextStyle with specific patterns
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*fontWeight:\s*FontWeight\.bold\s*\)'),
    (match) => 'context.titleMedium',
  );

  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*fontWeight:\s*FontWeight\.w600\s*\)'),
    (match) => 'context.titleMedium',
  );

  // Button text styles
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*1[6-8],?\s*fontWeight:\s*FontWeight\.[w6-9][^)]*\)'),
    (match) {
      if (match.group(0)!.contains('Button') || match.group(0)!.contains('button')) {
        return 'AppTypography.button';
      }
      return 'context.titleMedium';
    },
  );

  return content;
}

String replaceColors(String content) {
  // Common color replacements
  final colorReplacements = {
    'Colors.black': 'AppColors.textPrimary',
    'Colors.black87': 'AppColors.textPrimary', 
    'Colors.black54': 'AppColors.textSecondary',
    'Colors.black45': 'AppColors.textTertiary',
    'Colors.black38': 'AppColors.textDisabled',
    'Colors.black26': 'AppColors.textDisabled',
    'Colors.black12': 'AppColors.divider',
    'Colors.white': 'AppColors.textPrimaryDark',
    'Colors.white70': 'AppColors.textSecondaryDark',
    'Colors.white60': 'AppColors.textSecondaryDark',
    'Colors.white54': 'AppColors.textTertiaryDark',
    'Colors.white38': 'AppColors.textDisabledDark',
    'Colors.grey': 'AppColors.textSecondary',
    'Colors.grey[600]': 'AppColors.textSecondary',
    'Colors.grey[500]': 'AppColors.textTertiary',
    'Colors.grey[400]': 'AppColors.textDisabled',
    'Colors.grey[300]': 'AppColors.divider',
    'Colors.red': 'AppColors.error',
    'Colors.redAccent': 'AppColors.error',
    'Colors.green': 'AppColors.success',
    'Colors.greenAccent': 'AppColors.success',
    'Colors.blue': 'AppColors.primary',
    'Colors.blueAccent': 'AppColors.primary',
    'Colors.orange': 'AppColors.warning',
    'Colors.orangeAccent': 'AppColors.warning',
  };

  for (final entry in colorReplacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  // Replace hex colors
  content = content.replaceAllMapped(
    RegExp(r'Color\s*\(\s*0xFF([0-9A-Fa-f]{6})\s*\)'),
    (match) {
      final hex = match.group(1)!.toUpperCase();
      
      // Map common hex colors
      final hexMap = {
        '000000': 'AppColors.textPrimary',
        '1F2937': 'AppColors.textPrimary',
        '374151': 'AppColors.textSecondary',
        '6B7280': 'AppColors.textTertiary',
        '9CA3AF': 'AppColors.textDisabled',
        'D1D5DB': 'AppColors.divider',
        'E5E7EB': 'AppColors.divider',
        'F3F4F6': 'AppColors.background',
        'F9FAFB': 'AppColors.surface',
        'FFFFFF': 'AppColors.surface',
        'EF4444': 'AppColors.error',
        'DC2626': 'AppColors.error',
        '10B981': 'AppColors.success',
        '059669': 'AppColors.success',
        '3B82F6': 'AppColors.primary',
        '2563EB': 'AppColors.primary',
        'F59E0B': 'AppColors.warning',
        'D97706': 'AppColors.warning',
      };

      return hexMap[hex] ?? match.group(0)!;
    },
  );

  return content;
}

String replaceSpacing(String content) {
  // EdgeInsets replacements
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.all\s*\(\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      
      if (value == 0) return 'EdgeInsets.zero';
      if (value <= 4) return 'AppSpacing.xxs.all';
      if (value <= 8) return 'AppSpacing.xSmallall';
      if (value <= 12) return 'AppSpacing.smallall';
      if (value <= 16) return 'AppSpacing.md.all';
      if (value <= 20) return 'AppSpacing.largeall';
      if (value <= 24) return 'AppSpacing.xl.all';
      if (value <= 32) return 'AppSpacing.paddingAll24';
      if (value <= 40) return 'AppSpacing.xxxl.all';
      return 'AppSpacing.custom(${value.toInt()}).all';
    },
  );

  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.symmetric\s*\(\s*horizontal:\s*(\d+(?:\.\d+)?),?\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final h = double.parse(match.group(1)!);
      final v = double.parse(match.group(2)!);
      
      final hSpacing = getSpacingName(h);
      final vSpacing = getSpacingName(v);
      
      if (hSpacing == vSpacing) {
        return 'AppSpacing.$hSpacing.symmetric';
      } else {
        return 'AppSpacing.$hSpacing.horizontal + AppSpacing.$vSpacing.vertical';
      }
    },
  );

  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.only\s*\(\s*([^)]+)\s*\)'),
    (match) {
      final params = match.group(1)!;
      var result = 'EdgeInsets.only(';
      
      // Parse each parameter
      final topMatch = RegExp(r'top:\s*(\d+(?:\.\d+)?)').firstMatch(params);
      final bottomMatch = RegExp(r'bottom:\s*(\d+(?:\.\d+)?)').firstMatch(params);
      final leftMatch = RegExp(r'left:\s*(\d+(?:\.\d+)?)').firstMatch(params);
      final rightMatch = RegExp(r'right:\s*(\d+(?:\.\d+)?)').firstMatch(params);
      
      final parts = <String>[];
      if (topMatch != null) parts.add('top: AppSpacing.${getSpacingName(double.parse(topMatch.group(1)!))}.value');
      if (bottomMatch != null) parts.add('bottom: AppSpacing.${getSpacingName(double.parse(bottomMatch.group(1)!))}.value');
      if (leftMatch != null) parts.add('left: AppSpacing.${getSpacingName(double.parse(leftMatch.group(1)!))}.value');
      if (rightMatch != null) parts.add('right: AppSpacing.${getSpacingName(double.parse(rightMatch.group(1)!))}.value');
      
      return 'EdgeInsets.only(${parts.join(', ')})';
    },
  );

  // SizedBox replacements
  content = content.replaceAllMapped(
    RegExp(r'SizedBox\s*\(\s*height:\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      final spacing = getSpacingName(value);
      return 'AppSpacing.$spacing.verticalBox';
    },
  );

  content = content.replaceAllMapped(
    RegExp(r'SizedBox\s*\(\s*width:\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      final spacing = getSpacingName(value);
      return 'AppSpacing.$spacing.horizontalBox';
    },
  );

  return content;
}

String replaceDimensions(String content) {
  // BorderRadius replacements
  content = content.replaceAllMapped(
    RegExp(r'BorderRadius\.circular\s*\(\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      
      if (value == 0) return 'BorderRadius.zero';
      if (value <= 4) return 'BorderRadius.circular(AppDimensions.radiusXSmall)';
      if (value <= 8) return 'AppDimensions.radiusSm';
      if (value <= 12) return 'AppDimensions.radiusMd';
      if (value <= 16) return 'AppDimensions.radiusLg';
      if (value <= 20) return 'AppDimensions.radiusXl';
      if (value <= 24) return 'AppDimensions.radius2xl';
      if (value <= 32) return 'BorderRadius.circular(AppDimensions.radiusXxLarge)';
      return 'BorderRadius.circular($value)'; // Keep custom values
    },
  );

  // Icon size replacements
  content = content.replaceAllMapped(
    RegExp(r'Icon\s*\([^,]+,\s*size:\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final fullMatch = match.group(0)!;
      final size = double.parse(match.group(1)!);
      
      String newSize;
      if (size <= 16) newSize = 'AppDimensions.iconSizeXs';
      else if (size <= 20) newSize = 'AppDimensions.iconSizeSm';
      else if (size <= 24) newSize = 'AppDimensions.iconSizeMd';
      else if (size <= 28) newSize = 'AppDimensions.iconSizeLg';
      else if (size <= 32) newSize = 'AppDimensions.iconSizeXl';
      else return fullMatch; // Keep custom sizes
      
      return fullMatch.replaceFirst('size: $size', 'size: $newSize');
    },
  );

  return content;
}

String replaceButtonTextPatterns(String content) {
  // Replace button text patterns with simpler approach
  // Match button with Text child and TextStyle
  final buttonPattern = RegExp(
    r'(ElevatedButton|TextButton|OutlinedButton)\s*\([^)]*child:\s*Text\s*\([^)]+style:\s*TextStyle[^)]+\)',
    multiLine: true,
    dotAll: true,
  );
  
  content = content.replaceAllMapped(buttonPattern, (match) {
    final fullMatch = match.group(0)!;
    
    // Replace TextStyle with AppTypography.button
    if (fullMatch.contains('TextStyle')) {
      return fullMatch.replaceFirst(
        RegExp(r'style:\s*TextStyle[^)]+\)'),
        'style: AppTypography.button)',
      );
    }
    
    return fullMatch;
  });

  return content;
}

String handleSpecialCases(String content) {
  // Handle Theme.of(context).textTheme patterns
  content = content.replaceAllMapped(
    RegExp(r'Theme\.of\(context\)\.textTheme\.(\w+)'),
    (match) {
      final style = match.group(1)!;
      
      final mappings = {
        'displayLarge': 'context.displayLarge',
        'displayMedium': 'context.displayMedium',
        'displaySmall': 'context.displaySmall',
        'headlineLarge': 'context.headlineLarge',
        'headlineMedium': 'context.headlineMedium',
        'headlineSmall': 'context.headlineSmall',
        'titleLarge': 'context.titleLarge',
        'titleMedium': 'context.titleMedium',
        'titleSmall': 'context.titleSmall',
        'bodyLarge': 'context.bodyLarge',
        'bodyMedium': 'context.bodyMedium',
        'bodySmall': 'context.bodySmall',
        'labelLarge': 'context.labelLarge',
        'labelMedium': 'context.labelMedium',
        'labelSmall': 'context.labelSmall',
        // Legacy mappings
        'headline1': 'context.displayLarge',
        'headline2': 'context.displayMedium',
        'headline3': 'context.displaySmall',
        'headline4': 'context.headlineLarge',
        'headline5': 'context.headlineMedium',
        'headline6': 'context.headlineSmall',
        'subtitle1': 'context.titleMedium',
        'subtitle2': 'context.titleSmall',
        'bodyText1': 'context.bodyLarge',
        'bodyText2': 'context.bodyMedium',
        'caption': 'context.captionMedium',
        'button': 'AppTypography.button',
        'overline': 'AppTypography.overline',
      };
      
      return mappings[style] ?? match.group(0)!;
    },
  );

  // Handle const TextStyle patterns
  content = content.replaceAllMapped(
    RegExp(r'const\s+TextStyle\s*\([^)]+\)'),
    (match) {
      // Remove const and try to match the pattern
      final withoutConst = match.group(0)!.substring(6); // Remove 'const '
      
      // Try to find a suitable replacement
      if (withoutConst.contains('fontSize: 20')) {
        return 'context.headlineMedium';
      } else if (withoutConst.contains('fontSize: 16')) {
        return 'context.bodyLarge';
      } else if (withoutConst.contains('fontSize: 14')) {
        return 'context.bodyMedium';
      } else if (withoutConst.contains('fontSize: 12')) {
        return 'context.bodySmall';
      }
      
      return match.group(0)!; // Keep original if can't determine
    },
  );

  return content;
}

String getSpacingName(double value) {
  if (value <= 2) return 'xxxs';
  if (value <= 4) return 'xxs';
  if (value <= 8) return 'xs';
  if (value <= 12) return 'sm';
  if (value <= 16) return 'md';
  if (value <= 20) return 'lg';
  if (value <= 24) return 'xl';
  if (value <= 32) return 'xxl';
  if (value <= 40) return 'xxxl';
  return 'custom(${value.toInt()})';
}