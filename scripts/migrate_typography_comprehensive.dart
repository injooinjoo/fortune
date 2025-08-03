import 'dart:io';

/// Comprehensive typography migration script - handles all edge cases
/// Run: dart scripts/migrate_typography_comprehensive.dart [files...]

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart migrate_typography_comprehensive.dart <file1> <file2> ...');
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

  // Skip if already fully migrated
  if (content.contains('app_typography.dart') && 
      !content.contains('TextStyle(') &&
      !content.contains('fontSize:') &&
      !content.contains('fontWeight:')) {
    return false;
  }

  // Add imports if not present
  content = addImports(content);

  // Phase,
    1: Replace simple patterns first
  content = replaceSimpleTextStyles(content);
  
  // Phase,
    2: Replace complex TextStyle patterns
  content = replaceComplexTextStyles(content);
  
  // Phase,
    3: Replace remaining TextStyle patterns
  content = replaceRemainingTextStyles(content);

  // Replace color patterns
  content = replaceColors(content);

  // Replace spacing patterns
  content = replaceSpacing(content);

  // Replace dimension patterns
  content = replaceDimensions(content);

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
       content.contains('fontWeight:') || content.contains('context.')) && 
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

String replaceSimpleTextStyles(String content) {
  // Simple TextStyle with only fontSize
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final size = double.parse(match.group(1)!);
      return getTextStyleForSize(size);
    },
  );

  // Simple TextStyle with only fontWeight
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*fontWeight:\s*FontWeight\.(\w+)\s*\)'),
    (match) {
      final weight = match.group(1)!;
      if (weight == 'bold' || weight == 'w700' || weight == 'w800' || weight == 'w900') {
        return 'context.titleMedium';
      } else if (weight == 'w600') {
        return 'context.titleSmall';
      } else if (weight == 'w500') {
        return 'context.labelLarge';
      }
      return 'context.bodyMedium';
    },
  );

  return content;
}

String replaceComplexTextStyles(String content) {
  // TextStyle with fontSize and fontWeight
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*(?:color:[^,]+,\s*)?fontSize:\s*(\d+(?:\.\d+)?),?\s*fontWeight:\s*FontWeight\.(\w+)[^)]*\)'),
    (match) {
      final size = double.parse(match.group(1)!);
      final weight = match.group(2)!;
      return getTextStyleForSizeAndWeight(size, weight);
    },
  );

  // TextStyle with fontWeight and fontSize (reversed order)
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\(\s*(?:color:[^,]+,\s*)?fontWeight:\s*FontWeight\.(\w+),?\s*fontSize:\s*(\d+(?:\.\d+)?)[^)]*\)'),
    (match) {
      final weight = match.group(1)!;
      final size = double.parse(match.group(2)!);
      return getTextStyleForSizeAndWeight(size, weight);
    },
  );

  return content;
}

String replaceRemainingTextStyles(String content) {
  // TextStyle with multiple properties including color
  content = content.replaceAllMapped(
    RegExp(r'TextStyle\s*\([^)]+\)'),
    (match) {
      final style = match.group(0)!;
      
      // Extract properties
      final fontSizeMatch = RegExp(r'fontSize:\s*(\d+(?:\.\d+)?)').firstMatch(style);
      final fontWeightMatch = RegExp(r'fontWeight:\s*FontWeight\.(\w+)').firstMatch(style);
      final colorMatch = RegExp(r'color:\s*([^,)]+)').firstMatch(style);
      
      // Determine base style
      String baseStyle;
      if (fontSizeMatch != null && fontWeightMatch != null) {
        final size = double.parse(fontSizeMatch.group(1)!);
        final weight = fontWeightMatch.group(2)!;
        baseStyle = getTextStyleForSizeAndWeight(size, weight);
      } else if (fontSizeMatch != null) {
        final size = double.parse(fontSizeMatch.group(1)!);
        baseStyle = getTextStyleForSize(size);
      } else if (fontWeightMatch != null) {
        final weight = fontWeightMatch.group(1)!;
        baseStyle = getTextStyleForWeight(weight);
      } else {
        return style; // Can't determine, keep original
      }
      
      // Add copyWith if there are additional properties
      if (colorMatch != null || style.contains('height:') || style.contains('letterSpacing:')) {
        final copyWithProps = <String>[];
        if (colorMatch != null) {
          copyWithProps.add('color: ${colorMatch.group(1)}');
        }
        final heightMatch = RegExp(r'height:\s*([^,)]+)').firstMatch(style);
        if (heightMatch != null) {
          copyWithProps.add('height: ${heightMatch.group(1)}');
        }
        final letterSpacingMatch = RegExp(r'letterSpacing:\s*([^,)]+)').firstMatch(style);
        if (letterSpacingMatch != null) {
          copyWithProps.add('letterSpacing: ${letterSpacingMatch.group(1)}');
        }
        
        if (copyWithProps.isNotEmpty) {
          return '$baseStyle.copyWith(${copyWithProps.join(', ')})';
        }
      }
      
      return baseStyle;
    },
  );

  return content;
}

String getTextStyleForSize(double size) {
  if (size >= 32) return 'context.displaySmall';
  if (size >= 28) return 'context.headlineLarge';
  if (size >= 24) return 'context.headlineMedium';
  if (size >= 20) return 'context.headlineSmall';
  if (size >= 18) return 'context.titleLarge';
  if (size >= 16) return 'context.titleMedium';
  if (size >= 14) return 'context.bodyLarge';
  if (size >= 12) return 'context.bodyMedium';
  return 'context.bodySmall';
}

String getTextStyleForWeight(String weight) {
  if (weight == 'bold' || weight == 'w700' || weight == 'w800' || weight == 'w900') {
    return 'context.titleMedium';
  } else if (weight == 'w600') {
    return 'context.titleSmall';
  } else if (weight == 'w500') {
    return 'context.labelLarge';
  }
  return 'context.bodyMedium';
}

String getTextStyleForSizeAndWeight(double size, String weight) {
  final isBold = weight == 'bold' || weight == 'w700' || weight == 'w800' || weight == 'w900';
  final isSemiBold = weight == 'w600';
  final isMedium = weight == 'w500';
  
  if (size >= 32) {
    return 'context.displaySmall';
  } else if (size >= 28) {
    return 'context.headlineLarge';
  } else if (size >= 24) {
    return isBold ? 'context.headlineLarge' : 'context.headlineMedium';
  } else if (size >= 20) {
    return isBold || isSemiBold ? 'context.headlineMedium' : 'context.headlineSmall';
  } else if (size >= 18) {
    return isBold || isSemiBold ? 'context.titleLarge' : 'context.titleMedium';
  } else if (size >= 16) {
    if (isBold || isSemiBold) return 'context.titleMedium';
    if (isMedium) return 'context.labelLarge';
    return 'context.bodyLarge';
  } else if (size >= 14) {
    if (isBold || isSemiBold) return 'context.titleSmall';
    if (isMedium) return 'context.labelMedium';
    return 'context.bodyMedium';
  } else if (size >= 12) {
    if (isBold || isSemiBold || isMedium) return 'context.labelSmall';
    return 'context.bodySmall';
  } else {
    return 'context.captionMedium';
  }
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
    'Colors.transparent': 'Colors.transparent', // Keep transparent
  };

  for (final entry in colorReplacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  // Replace hex colors
  content = content.replaceAllMapped(
    RegExp(r'Color\s*\(\s*0x([A-Fa-f0-9]{8})\s*\)'),
    (match) {
      final hex = match.group(1)!.toUpperCase();
      
      // Map common hex colors (including alpha channel)
      final hexMap = {
        'FF000000': 'AppColors.textPrimary',
        'FF1F2937': 'AppColors.textPrimary',
        'FF374151': 'AppColors.textSecondary',
        'FF6B7280': 'AppColors.textTertiary',
        'FF9CA3AF': 'AppColors.textDisabled',
        'FFD1D5DB': 'AppColors.divider',
        'FFE5E7EB': 'AppColors.divider',
        'FFF3F4F6': 'AppColors.background',
        'FFF9FAFB': 'AppColors.surface',
        'FFFFFFFF': 'AppColors.surface',
        'FFEF4444': 'AppColors.error',
        'FFDC2626': 'AppColors.error',
        'FF10B981': 'AppColors.success',
        'FF059669': 'AppColors.success',
        'FF3B82F6': 'AppColors.primary',
        'FF2563EB': 'AppColors.primary',
        'FFF59E0B': 'AppColors.warning',
        'FFD97706': 'AppColors.warning',
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
    RegExp(r'Icon\s*\([^,]+,\s*size:\s*(\d+(?:\.\d+)?)\s*[,)]'),
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
      // Remove const and process as regular TextStyle
      final withoutConst = match.group(0)!.substring(6);
      
      // Extract properties
      final fontSizeMatch = RegExp(r'fontSize:\s*(\d+(?:\.\d+)?)').firstMatch(withoutConst);
      final fontWeightMatch = RegExp(r'fontWeight:\s*FontWeight\.(\w+)').firstMatch(withoutConst);
      
      if (fontSizeMatch != null && fontWeightMatch != null) {
        final size = double.parse(fontSizeMatch.group(1)!);
        final weight = fontWeightMatch.group(2)!;
        return getTextStyleForSizeAndWeight(size, weight);
      } else if (fontSizeMatch != null) {
        final size = double.parse(fontSizeMatch.group(1)!);
        return getTextStyleForSize(size);
      } else if (fontWeightMatch != null) {
        final weight = fontWeightMatch.group(1)!;
        return getTextStyleForWeight(weight);
      }
      
      return match.group(0)!; // Keep original if can't determine
    },
  );

  // Handle button text patterns
  content = content.replaceAllMapped(
    RegExp(r'(ElevatedButton|TextButton|OutlinedButton)[^{]+style:\s*TextStyle[^)]+\)'),
    (match) {
      final fullMatch = match.group(0)!;
      return fullMatch.replaceFirst(
        RegExp(r'style:\s*TextStyle[^)]+\)'),
        'style: AppTypography.button)',
      );
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