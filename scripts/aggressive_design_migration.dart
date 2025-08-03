import 'dart:io';

class AggressiveDesignMigration {
  int filesProcessed = 0;
  int changesApplied = 0;
  
  // Extended color mappings
  static const Map<String, String> colorMappings = {
    // Comprehensive color mapping
    '0xFF2D1B69': 'FortuneColors.tarotDark',
    '0xFF1A0F3A': 'FortuneColors.tarotDarker',
    '0xFF0F0C29': 'FortuneColors.tarotDarkest',
    '0xFF4C1D95': 'FortuneColors.spiritualDark',
    '0xFF6B46C1': 'FortuneColors.spiritualPrimary',
    '0xFF5E35B1': 'FortuneColors.spiritualDark',
    '0xFF4527A0': 'FortuneColors.spiritualDarker',
    
    // Success/Green colors
    '0xFF4CAF50': 'AppColors.success',
    '0xFF388E3C': 'AppColors.success',
    '0xFF059669': 'AppColors.success',
    '0xFF16A34A': 'AppColors.success',
    '0xFF15803D': 'AppColors.success',
    '0xFF047857': 'AppColors.success',
    '0xFF10B981': 'AppColors.success',
    '0xFF00C853': 'AppColors.success',
    '0xFF66BB6A': 'AppColors.success',
    '0xFF81C784': 'AppColors.success.withOpacity(0.8)',
    '0xFF34D399': 'AppColors.success',
    
    // Error/Red colors
    '0xFFEF4444': 'AppColors.error',
    '0xFFDC2626': 'AppColors.error',
    '0xFFB91C1C': 'AppColors.error',
    '0xFFE11D48': 'AppColors.error',
    '0xFFFF5252': 'AppColors.error',
    '0xFFF44336': 'AppColors.error',
    '0xFFFF1744': 'AppColors.error',
    '0xFFE91E63': 'FortuneColors.love',
    '0xFFF06292': 'FortuneColors.love.withOpacity(0.8)',
    '0xFFEC4899': 'FortuneColors.love',
    '0xFFDB2777': 'FortuneColors.love',
    '0xFFBE185D': 'FortuneColors.love',
    '0xFFC2185B': 'FortuneColors.love',
    '0xFFFF6B6B': 'FortuneColors.love',
    '0xFFFF8787': 'FortuneColors.love.withOpacity(0.8)',
    '0xFFFF4081': 'FortuneColors.love',
    '0xFFF50057': 'FortuneColors.love',
    '0xFFFF6B9D': 'FortuneColors.love',
    '0xFFC44569': 'FortuneColors.love',
    
    // Warning/Orange colors
    '0xFFF59E0B': 'AppColors.warning',
    '0xFFD97706': 'AppColors.warning',
    '0xFFFF8F00': 'AppColors.warning',
    '0xFFFF6F00': 'AppColors.warning',
    '0xFFE65100': 'AppColors.warning',
    '0xFFEA580C': 'AppColors.warning',
    '0xFFFBBF24': 'AppColors.warning',
    '0xFFFFB300': 'FortuneColors.goldLight',
    '0xFFF57C00': 'AppColors.warning',
    '0xFFFACC15': 'FortuneColors.goldLight',
    '0xFFEAB308': 'AppColors.warning',
    '0xFFFFD700': 'FortuneColors.goldPrimary',
    '0xFFFFA500': 'FortuneColors.goldLight',
    '0xFFF7B731': 'FortuneColors.goldLight',
    '0xFFFFD54F': 'FortuneColors.goldLight',
    '0xFFFFCC00': 'FortuneColors.goldLight',
    '0xFFFFE66D': 'FortuneColors.goldLighter',
    
    // Blue colors
    '0xFF3B82F6': 'AppColors.primary',
    '0xFF2563EB': 'AppColors.primary',
    '0xFF1D4ED8': 'AppColors.primary',
    '0xFF1976D2': 'AppColors.primary',
    '0xFF1E88E5': 'AppColors.primary',
    '0xFF1565C0': 'AppColors.primary',
    '0xFF2196F3': 'AppColors.primary',
    '0xFF42A5F5': 'AppColors.primary.withOpacity(0.8)',
    '0xFF0288D1': 'AppColors.primary',
    '0xFF03A9F4': 'AppColors.primary',
    '0xFF00D2FF': 'AppColors.info',
    '0xFF3A7BD5': 'AppColors.primary',
    '0xFF4F46E5': 'FortuneColors.spiritualPrimary',
    '0xFF6366F1': 'FortuneColors.spiritualPrimary',
    '0xFF1E40AF': 'AppColors.primary',
    '0xFF0891B2': 'AppColors.info',
    '0xFF0E7490': 'AppColors.info',
    '0xFF06B6D4': 'AppColors.info',
    '0xFF0EA5E9': 'AppColors.info',
    '0xFF0284C7': 'AppColors.info',
    '0xFF60A5FA': 'AppColors.primary.withOpacity(0.7)',
    '0xFF667EEA': 'FortuneColors.spiritualPrimary',
    '0xFF764BA2': 'FortuneColors.spiritualDark',
    '0xFF7F7FD5': 'FortuneColors.spiritualPrimary',
    '0xFF86A8E7': 'FortuneColors.spiritualLight',
    '0xFF91EAE4': 'AppColors.info.withOpacity(0.5)',
    '0xFF4FACFE': 'AppColors.info',
    '0xFF00F2FE': 'AppColors.info',
    '0xFF5B8DEE': 'AppColors.primary',
    '0xFF3F51B5': 'AppColors.primary',
    '0xFF7986CB': 'AppColors.primary.withOpacity(0.7)',
    '0xFF303F9F': 'AppColors.primary',
    '0xFF5C6BC0': 'AppColors.primary.withOpacity(0.8)',
    '0xFF0F52BA': 'AppColors.primary',
    '0xFF4169E1': 'AppColors.primary',
    '0xFF004EA2': 'AppColors.primary',
    
    // Purple colors
    '0xFF9C27B0': 'FortuneColors.spiritualPrimary',
    '0xFF8B5CF6': 'FortuneColors.spiritualPrimary',
    '0xFF7B1FA2': 'FortuneColors.spiritualDark',
    '0xFF6A1B9A': 'FortuneColors.spiritualDark',
    '0xFF4A148C': 'FortuneColors.spiritualDarker',
    '0xFF9370DB': 'FortuneColors.spiritualLight',
    '0xFFA78BFA': 'FortuneColors.spiritualLight',
    '0xFF8E24AA': 'FortuneColors.spiritualPrimary',
    '0xFFBA68C8': 'FortuneColors.spiritualLight',
    '0xFF5F27CD': 'FortuneColors.spiritualDark',
    '0xFF6D28D9': 'FortuneColors.spiritualDark',
    '0xFF8B008B': 'FortuneColors.spiritualDark',
    '0xFF4B0082': 'FortuneColors.spiritualDarker',
    '0xFF9966CC': 'FortuneColors.spiritualLight',
    
    // Neutral/Gray colors
    '0xFF9E9E9E': 'AppColors.textTertiary',
    '0xFF757575': 'AppColors.textSecondary',
    '0xFF4B5563': 'AppColors.textSecondary',
    '0xFFE5E7EB': 'AppColors.divider',
    
    // Special colors
    '0xFF795548': 'FortuneColors.earthBrown',
    '0xFF5D4037': 'FortuneColors.earthBrownDark',
    '0xFF8B4513': 'FortuneColors.earthBrown',
    '0xFFD2691E': 'FortuneColors.earthBrownLight',
    '0xFFBE123C': 'AppColors.error',
    '0xFF00A85D': 'AppColors.success',
    '0xFF4ECDC4': 'AppColors.info',
    '0xFF20B2AA': 'AppColors.info',
    '0xFFFF69B4': 'FortuneColors.love',
    '0xFFFF4500': 'AppColors.warning',
    '0xFFFF8C00': 'AppColors.warning',
    '0xFF32CD32': 'AppColors.success',
    '0xFF8B0000': 'AppColors.error',
    '0xFF7FFFD4': 'AppColors.info.withOpacity(0.3)',
    '0xFF50C878': 'AppColors.success',
    '0xFFFFFAF0': 'AppColors.background',
    '0xFFE0115F': 'AppColors.error',
    '0xFF9ACD32': 'AppColors.success',
    '0xFFFFE4E1': 'FortuneColors.love.withOpacity(0.1)',
    '0xFFFFBF00': 'FortuneColors.goldLight',
    '0xFF40E0D0': 'AppColors.info',
    '0xFFE6E6FA': 'FortuneColors.spiritualLighter',
    '0xFFF5F5DC': 'AppColors.surfaceLight',
    '0xFFFF7F50': 'AppColors.warning',
    
    // Background colors
    '0xFFFFF9E6': 'AppColors.background',
    '0xFF1a0033': 'FortuneColors.tarotDarkest',
    '0xFF0d001a': 'FortuneColors.tarotDarkest',
    
    // Other colors
    '0xFFFF5722': 'AppColors.warning',
    '0xFFEF5350': 'AppColors.error',
    '0xFFE61E2B': 'AppColors.error',
    '0xFFFFAB91': 'AppColors.warning.withOpacity(0.5)',
  };
  
  Future<void> run() async {
    print('Starting aggressive design value migration...\n');
    
    final directories = [
      'lib/features/fortune/presentation/widgets',
      'lib/features/fortune/presentation/pages',
      'lib/presentation/widgets',
      'lib/presentation/screens',
      'lib/screens',
      'lib/shared/components',
      'lib/shared/widgets',
    ];
    
    for (final dir in directories) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        print('Processing,
    directory: $dir');
        await processDirectory(directory);
      }
    }
    
    print('\n✅ Migration complete!');
    print('Files,
    processed: $filesProcessed');
    print('Changes,
    applied: $changesApplied');
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
    
    // Skip generated files
    if (content.contains('// GENERATED CODE') || content.contains('// coverage:ignore-file')) {
      return;
    }
    
    // Replace all colors
    colorMappings.forEach((hex, replacement) {
      final pattern = RegExp('Color\\($hex\\)');
      if (pattern.hasMatch(content)) {
        content = content.replaceAll(pattern, replacement);
        changesApplied++;
      }
    });
    
    // Replace EdgeInsets patterns
    content = replaceEdgeInsets(content);
    
    // Replace BorderRadius patterns
    content = replaceBorderRadius(content);
    
    // Replace Container/SizedBox dimensions
    content = replaceDimensions(content);
    
    // Add imports if content was modified
    if (content != originalContent) {
      filesProcessed++;
      content = addNecessaryImports(content);
      await file.writeAsString(content);
      print('  ✓ Processed: ${file.path}');
    }
  }
  
  String replaceEdgeInsets(String content) {
    // EdgeInsets.all(X);
    final allPattern = RegExp(r'EdgeInsets\.all\((\d+)(?:\.0)?\)');
    content = content.replaceAllMapped(allPattern, (match) {
      final value = int.parse(match.group(1)!);
      changesApplied++;
      return getEdgeInsetsAll(value);
    });
    
    // EdgeInsets.symmetric patterns
    final symmetricPattern = RegExp(r'EdgeInsets\.symmetric\(([^)]+)\)');
    content = content.replaceAllMapped(symmetricPattern, (match) {
      String params = match.group(1)!;
      changesApplied++;
      
      // Extract horizontal and vertical values
      final horizontalMatch = RegExp(r'horizontal:\s*(\d+)(?:\.0)?').firstMatch(params);
      final verticalMatch = RegExp(r'vertical:\s*(\d+)(?:\.0)?').firstMatch(params);
      
      if (horizontalMatch != null && verticalMatch != null) {
        final h = int.parse(horizontalMatch.group(1)!);
        final v = int.parse(verticalMatch.group(1)!);
        params = params.replaceAll(horizontalMatch.group(0)!, 'horizontal: ${getSpacingValue(h)}');
        params = params.replaceAll(verticalMatch.group(0)!, 'vertical: ${getSpacingValue(v)}');
      } else if (horizontalMatch != null) {
        final h = int.parse(horizontalMatch.group(1)!);
        params = params.replaceAll(horizontalMatch.group(0)!, 'horizontal: ${getSpacingValue(h)}');
      } else if (verticalMatch != null) {
        final v = int.parse(verticalMatch.group(1)!);
        params = params.replaceAll(verticalMatch.group(0)!, 'vertical: ${getSpacingValue(v)}');
      }
      
      return 'EdgeInsets.symmetric($params)';
    });
    
    // EdgeInsets.only patterns
    final onlyPattern = RegExp(r'EdgeInsets\.only\(([^)]+)\)');
    content = content.replaceAllMapped(onlyPattern, (match) {
      String params = match.group(1)!;
      changesApplied++;
      
      ['left', 'right', 'top', 'bottom'].forEach((side) {
        final sidePattern = RegExp('$side:\\s*(\\d+)(?:\\.0)?');
        final sideMatch = sidePattern.firstMatch(params);
        if (sideMatch != null) {
          final value = int.parse(sideMatch.group(1)!);
          params = params.replaceAll(sideMatch.group(0)!, '$side: ${getSpacingValue(value)}');
        }
      });
      
      return 'EdgeInsets.only($params)';
    });
    
    return content;
  }
  
  String replaceBorderRadius(String content) {
    // BorderRadius.circular(X);
    final circularPattern = RegExp(r'BorderRadius\.circular\((\d+)(?:\.0)?\)');
    content = content.replaceAllMapped(circularPattern, (match) {
      final value = int.parse(match.group(1)!);
      changesApplied++;
      return 'BorderRadius.circular(${getSpacingValue(value)})';
    });
    
    // borderRadius: X
    final radiusPattern = RegExp(r'borderRadius:\s*(\d+)(?:\.0)?(?![0-9])');
    content = content.replaceAllMapped(radiusPattern, (match) {
      final value = int.parse(match.group(1)!);
      changesApplied++;
      return 'borderRadius: ${getSpacingValue(value)}';
    });
    
    return content;
  }
  
  String replaceDimensions(String content) {
    // Container width/height
    final containerPattern = RegExp(r'(Container\([^)]*)(width|height):\s*(\d+)(?:\.0)?');
    content = content.replaceAllMapped(containerPattern, (match) {
      final prefix = match.group(1)!;
      final dimension = match.group(2)!;
      final value = int.parse(match.group(3)!);
      changesApplied++;
      
      // For common sizes, use predefined dimensions
      if (value == 48) return '${prefix}$dimension: AppDimensions.buttonHeightMedium';
      if (value == 56) return '${prefix}$dimension: AppDimensions.buttonHeightLarge';
      if (value == 40) return '${prefix}$dimension: AppDimensions.buttonHeightSmall';
      
      // Otherwise use spacing values multiplied
      return '${prefix}$dimension: ${getSpacingValue(value)}';
    });
    
    // SizedBox width/height
    final sizedBoxPattern = RegExp(r'SizedBox\((?:width|height):\s*(\d+)(?:\.0)?');
    content = content.replaceAllMapped(sizedBoxPattern, (match) {
      final value = int.parse(match.group(1)!);
      changesApplied++;
      final dimension = match.group(0)!.contains('width') ? 'width' : 'height';
      return 'SizedBox($dimension: ${getSpacingValue(value)}';
    });
    
    return content;
  }
  
  String getEdgeInsetsAll(int value) {
    switch (value) {
      case,
    4: return 'AppSpacing.paddingAll4';
      case,
    8: return 'AppSpacing.paddingAll8';
      case,
    12: return 'AppSpacing.paddingAll12';
      case,
    16: return 'AppSpacing.paddingAll16';
      case,
    20: return 'AppSpacing.paddingAll20';
      case,
    24: return 'AppSpacing.paddingAll24';
      default: return 'EdgeInsets.all(${getSpacingValue(value)})';
    }
  }
  
  String getSpacingValue(int value) {
    switch (value) {
      case,
    0: return 'AppSpacing.spacing0';
      case,
    2: return 'AppSpacing.spacing0 * 0.5';
      case,
    4: return 'AppSpacing.spacing1';
      case,
    6: return 'AppSpacing.spacing1 * 1.5';
      case,
    8: return 'AppSpacing.spacing2';
      case,
    10: return 'AppSpacing.spacing2 * 1.25';
      case,
    12: return 'AppSpacing.spacing3';
      case,
    14: return 'AppSpacing.spacing3 * 1.17';
      case,
    16: return 'AppSpacing.spacing4';
      case,
    18: return 'AppSpacing.spacing4 * 1.125';
      case,
    20: return 'AppSpacing.spacing5';
      case,
    24: return 'AppSpacing.spacing6';
      case,
    25: return 'AppSpacing.spacing6 * 1.04';
      case,
    28: return 'AppSpacing.spacing7';
      case,
    30: return 'AppSpacing.spacing7 * 1.07';
      case,
    32: return 'AppSpacing.spacing8';
      case,
    36: return 'AppSpacing.spacing9';
      case,
    40: return 'AppSpacing.spacing10';
      case,
    48: return 'AppSpacing.spacing12';
      case,
    50: return 'AppSpacing.spacing12 * 1.04';
      case,
    56: return 'AppSpacing.spacing14';
      case,
    60: return 'AppSpacing.spacing15';
      case,
    64: return 'AppSpacing.spacing16';
      case,
    80: return 'AppSpacing.spacing20';
      case,
    96: return 'AppSpacing.spacing24';
      case,
    100: return 'AppSpacing.spacing24 * 1.04';
      case,
    120: return 'AppSpacing.spacing24 * 1.25';
      case,
    150: return 'AppSpacing.spacing24 * 1.56';
      case,
    200: return 'AppSpacing.spacing24 * 2.08';
      case,
    250: return 'AppSpacing.spacing24 * 2.6';
      case,
    300: return 'AppSpacing.spacing24 * 3.125';
      default: 
        if (value % 4 == 0) {
          return 'AppSpacing.spacing1 * ${value / 4}';
        }
        return value.toString();
    }
  }
  
  String addNecessaryImports(String content) {
    List<String> requiredImports = [];
    
    if (content.contains('AppColors.')) {
      requiredImports.add("import 'package:fortune/core/theme/app_colors.dart';");
    }
    
    if (content.contains('FortuneColors.')) {
      // Check if it's using the old path or new path
      if (!content.contains('fortune_colors.dart')) {
        requiredImports.add("import 'package:fortune/core/theme/fortune_colors.dart';");
      }
    }
    
    if (content.contains('AppSpacing.')) {
      requiredImports.add("import 'package:fortune/core/theme/app_spacing.dart';");
    }
    
    if (content.contains('AppDimensions.')) {
      requiredImports.add("import 'package:fortune/core/theme/app_dimensions.dart';");
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
          .join('\n');
      
      if (importsToAdd.isNotEmpty) {
        content = content.substring(0, lastImport.end) +
            '\n' + importsToAdd +
            content.substring(lastImport.end);
      }
    } else {
      // No imports found, add at the beginning
      content = requiredImports.join('\n') + '\n\n' + content;
    }
    
    return content;
  }
}

void main() async {
  final migration = AggressiveDesignMigration();
  await migration.run();
}