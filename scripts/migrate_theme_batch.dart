import 'dart:io';

// Theme migration script for batch processing
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart migrate_theme_batch.dart <file1> <file2> ...');
    exit(1);
  }

  final filePaths = args;
  var successCount = 0;
  var errorCount = 0;

  for (final filePath in filePaths) {
    try {
      await migrateFile(filePath);
      successCount++;
      print('✅ Migrated: ${filePath.split('/').last}');
    } catch (e) {
      errorCount++;
      print('❌ Error migrating ${filePath.split('/').last}: $e');
    }
  }

  print('\n📊 Migration,
    Summary:');
  print('   ✅ Success: $successCount files');
  print('   ❌ Errors: $errorCount files');
}

Future<void> migrateFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not,
    found: $filePath');
  }

  var content = await file.readAsString();
  final originalContent = content;

  // Skip if already migrated
  if (content.contains('AppSpacing') || 
      content.contains('AppDimensions') || 
      content.contains('AppTypography')) {
    print('ℹ️  Already,
    migrated: ${filePath.split('/').last}');
    return;
  }

  // Add imports if needed
  if (!content.contains("import 'package:fortune/core/theme/app_spacing.dart';") &&
      (content.contains('EdgeInsets') || content.contains('SizedBox'))) {
    final importIndex = content.indexOf('import ');
    if (importIndex != -1) {
      content = content.substring(0, importIndex) +
          "import 'package:fortune/core/theme/app_spacing.dart';\n" +
          content.substring(importIndex);
    }
  }

  if (!content.contains("import 'package:fortune/core/theme/app_dimensions.dart';") &&
      (content.contains('BorderRadius') || content.contains('height:') || content.contains('width:'))) {
    final importIndex = content.indexOf('import ');
    if (importIndex != -1) {
      content = content.substring(0, importIndex) +
          "import 'package:fortune/core/theme/app_dimensions.dart';\n" +
          content.substring(importIndex);
    }
  }

  if (!content.contains("import 'package:fortune/core/theme/app_typography.dart';") &&
      content.contains('TextStyle')) {
    final importIndex = content.indexOf('import ');
    if (importIndex != -1) {
      content = content.substring(0, importIndex) +
          "import 'package:fortune/core/theme/app_typography.dart';\n" +
          content.substring(importIndex);
    }
  }

  // Apply migrations
  content = migrateSpacing(content);
  content = migrateBorderRadius(content);
  content = migrateTypography(content);
  content = migrateDimensions(content);
  content = migrateColors(content);
  content = fixConstIssues(content);
  content = fixDeprecatedAPIs(content);

  // Only write if content changed
  if (content != originalContent) {
    await file.writeAsString(content);
  }
}

String migrateSpacing(String content) {
  // EdgeInsets migrations
  content = content.replaceAll('EdgeInsets.all(4)', 'AppSpacing.paddingAll4');
  content = content.replaceAll('EdgeInsets.all(8)', 'AppSpacing.paddingAll8');
  content = content.replaceAll('EdgeInsets.all(12)', 'AppSpacing.paddingAll12');
  content = content.replaceAll('EdgeInsets.all(16)', 'AppSpacing.paddingAll16');
  content = content.replaceAll('EdgeInsets.all(20)', 'AppSpacing.paddingAll20');
  content = content.replaceAll('EdgeInsets.all(24)', 'AppSpacing.paddingAll24');

  // EdgeInsets.all with decimals
  content = content.replaceAll('EdgeInsets.all(4.0)', 'AppSpacing.paddingAll4');
  content = content.replaceAll('EdgeInsets.all(8.0)', 'AppSpacing.paddingAll8');
  content = content.replaceAll('EdgeInsets.all(12.0)', 'AppSpacing.paddingAll12');
  content = content.replaceAll('EdgeInsets.all(16.0)', 'AppSpacing.paddingAll16');
  content = content.replaceAll('EdgeInsets.all(20.0)', 'AppSpacing.paddingAll20');
  content = content.replaceAll('EdgeInsets.all(24.0)', 'AppSpacing.paddingAll24');

  // EdgeInsets.symmetric
  content = content.replaceAll('EdgeInsets.symmetric(horizontal: 16)', 'AppSpacing.paddingHorizontal16');
  content = content.replaceAll('EdgeInsets.symmetric(horizontal: 16.0)', 'AppSpacing.paddingHorizontal16');
  content = content.replaceAll('EdgeInsets.symmetric(horizontal: 24)', 'AppSpacing.paddingHorizontal24');
  content = content.replaceAll('EdgeInsets.symmetric(horizontal: 24.0)', 'AppSpacing.paddingHorizontal24');
  content = content.replaceAll('EdgeInsets.symmetric(vertical: 8)', 'AppSpacing.paddingVertical8');
  content = content.replaceAll('EdgeInsets.symmetric(vertical: 8.0)', 'AppSpacing.paddingVertical8');
  content = content.replaceAll('EdgeInsets.symmetric(vertical: 16)', 'AppSpacing.paddingVertical16');
  content = content.replaceAll('EdgeInsets.symmetric(vertical: 16.0)', 'AppSpacing.paddingVertical16');

  // SizedBox heights
  content = content.replaceAll('SizedBox(height: 4)', 'SizedBox(height: AppSpacing.spacing1)');
  content = content.replaceAll('SizedBox(height: 8)', 'SizedBox(height: AppSpacing.spacing2)');
  content = content.replaceAll('SizedBox(height: 12)', 'SizedBox(height: AppSpacing.spacing3)');
  content = content.replaceAll('SizedBox(height: 16)', 'SizedBox(height: AppSpacing.spacing4)');
  content = content.replaceAll('SizedBox(height: 20)', 'SizedBox(height: AppSpacing.spacing5)');
  content = content.replaceAll('SizedBox(height: 24)', 'SizedBox(height: AppSpacing.spacing6)');
  content = content.replaceAll('SizedBox(height: 32)', 'SizedBox(height: AppSpacing.spacing8)');
  content = content.replaceAll('SizedBox(height: 40)', 'SizedBox(height: AppSpacing.spacing10)');
  content = content.replaceAll('SizedBox(height: 48)', 'SizedBox(height: AppSpacing.spacing12)');

  // With decimals
  content = content.replaceAll('SizedBox(height: 4.0)', 'SizedBox(height: AppSpacing.spacing1)');
  content = content.replaceAll('SizedBox(height: 8.0)', 'SizedBox(height: AppSpacing.spacing2)');
  content = content.replaceAll('SizedBox(height: 12.0)', 'SizedBox(height: AppSpacing.spacing3)');
  content = content.replaceAll('SizedBox(height: 16.0)', 'SizedBox(height: AppSpacing.spacing4)');
  content = content.replaceAll('SizedBox(height: 20.0)', 'SizedBox(height: AppSpacing.spacing5)');
  content = content.replaceAll('SizedBox(height: 24.0)', 'SizedBox(height: AppSpacing.spacing6)');
  content = content.replaceAll('SizedBox(height: 32.0)', 'SizedBox(height: AppSpacing.spacing8)');
  content = content.replaceAll('SizedBox(height: 40.0)', 'SizedBox(height: AppSpacing.spacing10)');
  content = content.replaceAll('SizedBox(height: 48.0)', 'SizedBox(height: AppSpacing.spacing12)');

  // SizedBox widths
  content = content.replaceAll('SizedBox(width: 4)', 'SizedBox(width: AppSpacing.spacing1)');
  content = content.replaceAll('SizedBox(width: 8)', 'SizedBox(width: AppSpacing.spacing2)');
  content = content.replaceAll('SizedBox(width: 12)', 'SizedBox(width: AppSpacing.spacing3)');
  content = content.replaceAll('SizedBox(width: 16)', 'SizedBox(width: AppSpacing.spacing4)');
  content = content.replaceAll('SizedBox(width: 20)', 'SizedBox(width: AppSpacing.spacing5)');
  content = content.replaceAll('SizedBox(width: 24)', 'SizedBox(width: AppSpacing.spacing6)');

  return content;
}

String migrateBorderRadius(String content) {
  // BorderRadius migrations
  content = content.replaceAll('BorderRadius.circular(4)', 'AppDimensions.borderRadius(AppDimensions.radiusXxSmall)');
  content = content.replaceAll('BorderRadius.circular(6)', 'BorderRadius.circular(AppDimensions.radiusXSmall)');
  content = content.replaceAll('BorderRadius.circular(8)', 'AppDimensions.borderRadiusSmall');
  content = content.replaceAll('BorderRadius.circular(12)', 'AppDimensions.borderRadiusMedium');
  content = content.replaceAll('BorderRadius.circular(16)', 'AppDimensions.borderRadiusLarge');
  content = content.replaceAll('BorderRadius.circular(20)', 'BorderRadius.circular(AppDimensions.radiusXLarge)');
  content = content.replaceAll('BorderRadius.circular(24)', 'BorderRadius.circular(AppDimensions.radiusXxLarge)');

  // With decimals
  content = content.replaceAll('BorderRadius.circular(4.0)', 'AppDimensions.borderRadius(AppDimensions.radiusXxSmall)');
  content = content.replaceAll('BorderRadius.circular(6.0)', 'BorderRadius.circular(AppDimensions.radiusXSmall)');
  content = content.replaceAll('BorderRadius.circular(8.0)', 'AppDimensions.borderRadiusSmall');
  content = content.replaceAll('BorderRadius.circular(12.0)', 'AppDimensions.borderRadiusMedium');
  content = content.replaceAll('BorderRadius.circular(16.0)', 'AppDimensions.borderRadiusLarge');
  content = content.replaceAll('BorderRadius.circular(20.0)', 'BorderRadius.circular(AppDimensions.radiusXLarge)');
  content = content.replaceAll('BorderRadius.circular(24.0)', 'BorderRadius.circular(AppDimensions.radiusXxLarge)');

  return content;
}

String migrateTypography(String content) {
  // Common TextStyle patterns - need more sophisticated regex
  final patterns = [
    // fontSize: 48
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*48[^)]*\)'),
    // fontSize: 36
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*36[^)]*\)'),
    // fontSize: 28
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*28[^)]*\)'),
    // fontSize: 24
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*24[^)]*\)'),
    // fontSize: 20
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*20[^)]*\)'),
    // fontSize: 18
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*18[^)]*\)'),
    // fontSize: 16
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*16[^)]*\)'),
    // fontSize: 14
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*14[^)]*\)'),
    // fontSize: 12
    RegExp(r'TextStyle\s*\(\s*fontSize:\s*12[^)]*\)'),
  ];

  // Map of fontSize to context style
  final replacements = {
    '48': 'context.displayLarge',
    '36': 'context.displayMedium',
    '28': 'context.displaySmall',
    '24': 'context.headlineLarge',
    '20': 'context.headlineMedium',
    '18': 'context.headlineSmall',
    '16': 'context.bodyLarge',
    '14': 'context.bodySmall',
    '12': 'context.captionMedium',
  };

  // For simple cases, do direct replacements
  for (final entry in replacements.entries) {
    content = content.replaceAll(
      'TextStyle(fontSize: ${entry.key})',
      entry.value,
    );
    content = content.replaceAll(
      'TextStyle(fontSize: ${entry.key}.0)',
      entry.value,
    );
  }

  return content;
}

String migrateDimensions(String content) {
  // Button heights
  content = content.replaceAll('height: 56', 'height: AppDimensions.buttonHeightLarge');
  content = content.replaceAll('height: 48', 'height: AppDimensions.buttonHeightMedium');
  content = content.replaceAll('height: 40', 'height: AppDimensions.buttonHeightSmall');
  content = content.replaceAll('height: 32', 'height: AppDimensions.buttonHeightXSmall');

  // Icon sizes
  content = content.replaceAll('size: 16', 'size: AppDimensions.iconSizeXSmall');
  content = content.replaceAll('size: 20', 'size: AppDimensions.iconSizeSmall');
  content = content.replaceAll('size: 24', 'size: AppDimensions.iconSizeMedium');
  content = content.replaceAll('size: 28', 'size: AppDimensions.iconSizeLarge');
  content = content.replaceAll('size: 32', 'size: AppDimensions.iconSizeXLarge');

  return content;
}

String migrateColors(String content) {
  // Update withOpacity to withValues
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\(([0-9.]+)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})',
  );

  return content;
}

String fixConstIssues(String content) {
  // Remove const where theme values are used
  final themePatterns = [
    'AppSpacing',
    'AppDimensions',
    'AppTypography',
    'context.',
    'Theme.of(context)',
  ];

  for (final pattern in themePatterns) {
    // Remove const from widgets containing these patterns
    content = content.replaceAllMapped(
      RegExp('const\\s+([A-Z][a-zA-Z]*?)\\s*\\([^)]*?$pattern[^)]*?\\)', multiLine: true),
      (match) => '${match.group(1)}(${match.group(0).substring(match.group(0).indexOf('(') + 1)}',
    );
  }

  return content;
}

String fixDeprecatedAPIs(String content) {
  // Already handled in migrateColors
  return content;
}