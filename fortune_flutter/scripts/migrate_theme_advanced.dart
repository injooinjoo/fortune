import 'dart:io';

// Advanced theme migration script for batch processing
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart migrate_theme_advanced.dart <file1> <file2> ...');
    exit(1);
  }

  final filePaths = args;
  var successCount = 0;
  var errorCount = 0;
  var modifiedCount = 0;

  for (final filePath in filePaths) {
    try {
      final wasModified = await migrateFile(filePath);
      if (wasModified) {
        modifiedCount++;
        print('✅ Modified: ${filePath.split('/').last}');
      } else {
        print('ℹ️  No changes: ${filePath.split('/').last}');
      }
      successCount++;
    } catch (e) {
      errorCount++;
      print('❌ Error migrating ${filePath.split('/').last}: $e');
    }
  }

  print('\n📊 Migration Summary:');
  print('   ✅ Processed: $successCount files');
  print('   📝 Modified: $modifiedCount files');
  print('   ❌ Errors: $errorCount files');
}

Future<bool> migrateFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found: $filePath');
  }

  var content = await file.readAsString();
  final originalContent = content;

  // Skip if already migrated
  if (content.contains('AppSpacing') || 
      content.contains('AppDimensions') || 
      content.contains('AppTypography')) {
    return false;
  }

  // Track if imports are needed
  var needsSpacing = false;
  var needsDimensions = false;
  var needsTypography = false;

  // Apply migrations and track what's needed
  final spacingResult = migrateSpacing(content);
  if (spacingResult != content) {
    content = spacingResult;
    needsSpacing = true;
  }

  final radiusResult = migrateBorderRadius(content);
  if (radiusResult != content) {
    content = radiusResult;
    needsDimensions = true;
  }

  final typographyResult = migrateTypography(content);
  if (typographyResult != content) {
    content = typographyResult;
    needsTypography = true;
  }

  final dimensionsResult = migrateDimensions(content);
  if (dimensionsResult != content) {
    content = dimensionsResult;
    needsDimensions = true;
  }

  // Fix deprecated APIs
  content = fixDeprecatedAPIs(content);

  // Add imports if needed
  if (needsSpacing || needsDimensions || needsTypography) {
    content = addRequiredImports(content, needsSpacing, needsDimensions, needsTypography);
  }

  // Only write if content changed
  if (content != originalContent) {
    await file.writeAsString(content);
    return true;
  }
  return false;
}

String addRequiredImports(String content, bool needsSpacing, bool needsDimensions, bool needsTypography) {
  final imports = <String>[];
  
  if (needsSpacing && !content.contains("import 'package:fortune/core/theme/app_spacing.dart';")) {
    imports.add("import 'package:fortune/core/theme/app_spacing.dart';");
  }
  
  if (needsDimensions && !content.contains("import 'package:fortune/core/theme/app_dimensions.dart';")) {
    imports.add("import 'package:fortune/core/theme/app_dimensions.dart';");
  }
  
  if (needsTypography && !content.contains("import 'package:fortune/core/theme/app_typography.dart';")) {
    imports.add("import 'package:fortune/core/theme/app_typography.dart';");
  }

  if (imports.isEmpty) return content;

  // Find the first import statement
  final importMatch = RegExp(r'''import\s+['"]''').firstMatch(content);
  if (importMatch != null) {
    final insertIndex = importMatch.start;
    final importString = imports.join('\n') + '\n';
    content = content.substring(0, insertIndex) + importString + content.substring(insertIndex);
  }

  return content;
}

String migrateSpacing(String content) {
  // Remove const from EdgeInsets patterns that will use theme values
  content = content.replaceAllMapped(
    RegExp(r'const\s+(EdgeInsets\.(all|symmetric)\([^)]+\))'),
    (match) => match.group(1)!,
  );

  // EdgeInsets.all migrations
  final edgeInsetsAllPatterns = {
    'EdgeInsets.all(4)': 'AppSpacing.paddingAll4',
    'EdgeInsets.all(4.0)': 'AppSpacing.paddingAll4',
    'EdgeInsets.all(8)': 'AppSpacing.paddingAll8',
    'EdgeInsets.all(8.0)': 'AppSpacing.paddingAll8',
    'EdgeInsets.all(12)': 'AppSpacing.paddingAll12',
    'EdgeInsets.all(12.0)': 'AppSpacing.paddingAll12',
    'EdgeInsets.all(16)': 'AppSpacing.paddingAll16',
    'EdgeInsets.all(16.0)': 'AppSpacing.paddingAll16',
    'EdgeInsets.all(20)': 'AppSpacing.paddingAll20',
    'EdgeInsets.all(20.0)': 'AppSpacing.paddingAll20',
    'EdgeInsets.all(24)': 'AppSpacing.paddingAll24',
    'EdgeInsets.all(24.0)': 'AppSpacing.paddingAll24',
  };

  for (final entry in edgeInsetsAllPatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  // EdgeInsets.symmetric migrations
  final symmetricPatterns = {
    'EdgeInsets.symmetric(horizontal: 16)': 'AppSpacing.paddingHorizontal16',
    'EdgeInsets.symmetric(horizontal: 16.0)': 'AppSpacing.paddingHorizontal16',
    'EdgeInsets.symmetric(horizontal: 24)': 'AppSpacing.paddingHorizontal24',
    'EdgeInsets.symmetric(horizontal: 24.0)': 'AppSpacing.paddingHorizontal24',
    'EdgeInsets.symmetric(vertical: 8)': 'AppSpacing.paddingVertical8',
    'EdgeInsets.symmetric(vertical: 8.0)': 'AppSpacing.paddingVertical8',
    'EdgeInsets.symmetric(vertical: 16)': 'AppSpacing.paddingVertical16',
    'EdgeInsets.symmetric(vertical: 16.0)': 'AppSpacing.paddingVertical16',
  };

  for (final entry in symmetricPatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  // Custom EdgeInsets.symmetric patterns
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.symmetric\(horizontal:\s*(\d+)(\.0)?,\s*vertical:\s*(\d+)(\.0)?\)'),
    (match) {
      final horizontal = match.group(1)!;
      final vertical = match.group(3)!;
      
      // Map common patterns
      if (horizontal == '32' && vertical == '16') {
        return 'EdgeInsets.symmetric(horizontal: AppSpacing.spacing8, vertical: AppSpacing.spacing4)';
      } else if (horizontal == '24' && vertical == '12') {
        return 'EdgeInsets.symmetric(horizontal: AppSpacing.spacing6, vertical: AppSpacing.spacing3)';
      } else if (horizontal == '20' && vertical == '10') {
        return 'EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing2)';
      }
      
      // For other values, use spacing constants
      return 'EdgeInsets.symmetric(horizontal: AppSpacing.spacing${int.parse(horizontal) ~/ 4}, vertical: AppSpacing.spacing${int.parse(vertical) ~/ 4})';
    },
  );

  // SizedBox migrations
  final sizedBoxPatterns = {
    'SizedBox(height: 4)': 'SizedBox(height: AppSpacing.spacing1)',
    'SizedBox(height: 4.0)': 'SizedBox(height: AppSpacing.spacing1)',
    'SizedBox(height: 8)': 'SizedBox(height: AppSpacing.spacing2)',
    'SizedBox(height: 8.0)': 'SizedBox(height: AppSpacing.spacing2)',
    'SizedBox(height: 12)': 'SizedBox(height: AppSpacing.spacing3)',
    'SizedBox(height: 12.0)': 'SizedBox(height: AppSpacing.spacing3)',
    'SizedBox(height: 16)': 'SizedBox(height: AppSpacing.spacing4)',
    'SizedBox(height: 16.0)': 'SizedBox(height: AppSpacing.spacing4)',
    'SizedBox(height: 20)': 'SizedBox(height: AppSpacing.spacing5)',
    'SizedBox(height: 20.0)': 'SizedBox(height: AppSpacing.spacing5)',
    'SizedBox(height: 24)': 'SizedBox(height: AppSpacing.spacing6)',
    'SizedBox(height: 24.0)': 'SizedBox(height: AppSpacing.spacing6)',
    'SizedBox(height: 32)': 'SizedBox(height: AppSpacing.spacing8)',
    'SizedBox(height: 32.0)': 'SizedBox(height: AppSpacing.spacing8)',
    'SizedBox(height: 40)': 'SizedBox(height: AppSpacing.spacing10)',
    'SizedBox(height: 40.0)': 'SizedBox(height: AppSpacing.spacing10)',
    'SizedBox(height: 48)': 'SizedBox(height: AppSpacing.spacing12)',
    'SizedBox(height: 48.0)': 'SizedBox(height: AppSpacing.spacing12)',
    'SizedBox(width: 4)': 'SizedBox(width: AppSpacing.spacing1)',
    'SizedBox(width: 4.0)': 'SizedBox(width: AppSpacing.spacing1)',
    'SizedBox(width: 8)': 'SizedBox(width: AppSpacing.spacing2)',
    'SizedBox(width: 8.0)': 'SizedBox(width: AppSpacing.spacing2)',
    'SizedBox(width: 12)': 'SizedBox(width: AppSpacing.spacing3)',
    'SizedBox(width: 12.0)': 'SizedBox(width: AppSpacing.spacing3)',
    'SizedBox(width: 16)': 'SizedBox(width: AppSpacing.spacing4)',
    'SizedBox(width: 16.0)': 'SizedBox(width: AppSpacing.spacing4)',
    'SizedBox(width: 20)': 'SizedBox(width: AppSpacing.spacing5)',
    'SizedBox(width: 20.0)': 'SizedBox(width: AppSpacing.spacing5)',
    'SizedBox(width: 24)': 'SizedBox(width: AppSpacing.spacing6)',
    'SizedBox(width: 24.0)': 'SizedBox(width: AppSpacing.spacing6)',
  };

  // Remove const from SizedBox patterns
  content = content.replaceAllMapped(
    RegExp(r'const\s+(SizedBox\((?:height|width):\s*\d+(?:\.\d+)?\))'),
    (match) => match.group(1)!,
  );

  for (final entry in sizedBoxPatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  return content;
}

String migrateBorderRadius(String content) {
  // Remove const from BorderRadius patterns
  content = content.replaceAllMapped(
    RegExp(r'const\s+(BorderRadius\.circular\([^)]+\))'),
    (match) => match.group(1)!,
  );

  // BorderRadius migrations
  final borderRadiusPatterns = {
    'BorderRadius.circular(4)': 'AppDimensions.borderRadius(AppDimensions.radiusXxSmall)',
    'BorderRadius.circular(4.0)': 'AppDimensions.borderRadius(AppDimensions.radiusXxSmall)',
    'BorderRadius.circular(6)': 'BorderRadius.circular(AppDimensions.radiusXSmall)',
    'BorderRadius.circular(6.0)': 'BorderRadius.circular(AppDimensions.radiusXSmall)',
    'BorderRadius.circular(8)': 'AppDimensions.borderRadiusSmall',
    'BorderRadius.circular(8.0)': 'AppDimensions.borderRadiusSmall',
    'BorderRadius.circular(12)': 'AppDimensions.borderRadiusMedium',
    'BorderRadius.circular(12.0)': 'AppDimensions.borderRadiusMedium',
    'BorderRadius.circular(16)': 'AppDimensions.borderRadiusLarge',
    'BorderRadius.circular(16.0)': 'AppDimensions.borderRadiusLarge',
    'BorderRadius.circular(20)': 'BorderRadius.circular(AppDimensions.radiusXLarge)',
    'BorderRadius.circular(20.0)': 'BorderRadius.circular(AppDimensions.radiusXLarge)',
    'BorderRadius.circular(24)': 'BorderRadius.circular(AppDimensions.radiusXxLarge)',
    'BorderRadius.circular(24.0)': 'BorderRadius.circular(AppDimensions.radiusXxLarge)',
  };

  for (final entry in borderRadiusPatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  return content;
}

String migrateTypography(String content) {
  // Add context extension where TextStyle is used
  if (content.contains('TextStyle') && !content.contains('context.')) {
    // This is a more complex migration that requires context awareness
    // For now, we'll skip direct TextStyle migrations to avoid breaking code
  }

  return content;
}

String migrateDimensions(String content) {
  // Height migrations for common patterns
  final heightPatterns = {
    'height: 56': 'height: AppDimensions.buttonHeightLarge',
    'height: 56.0': 'height: AppDimensions.buttonHeightLarge',
    'height: 48': 'height: AppDimensions.buttonHeightMedium',
    'height: 48.0': 'height: AppDimensions.buttonHeightMedium',
    'height: 40': 'height: AppDimensions.buttonHeightSmall',
    'height: 40.0': 'height: AppDimensions.buttonHeightSmall',
    'height: 32': 'height: AppDimensions.buttonHeightXSmall',
    'height: 32.0': 'height: AppDimensions.buttonHeightXSmall',
  };

  // Icon size migrations
  final iconSizePatterns = {
    'size: 16': 'size: AppDimensions.iconSizeXSmall',
    'size: 16.0': 'size: AppDimensions.iconSizeXSmall',
    'size: 20': 'size: AppDimensions.iconSizeSmall',
    'size: 20.0': 'size: AppDimensions.iconSizeSmall',
    'size: 24': 'size: AppDimensions.iconSizeMedium',
    'size: 24.0': 'size: AppDimensions.iconSizeMedium',
    'size: 28': 'size: AppDimensions.iconSizeLarge',
    'size: 28.0': 'size: AppDimensions.iconSizeLarge',
    'size: 32': 'size: AppDimensions.iconSizeXLarge',
    'size: 32.0': 'size: AppDimensions.iconSizeXLarge',
  };

  for (final entry in heightPatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  for (final entry in iconSizePatterns.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  return content;
}

String fixDeprecatedAPIs(String content) {
  // Update withOpacity to withValues
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\(([0-9.]+)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})',
  );

  return content;
}