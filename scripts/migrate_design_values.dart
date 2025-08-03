import 'dart:io';

/// Master migration script to replace hardcoded design values with theme constants
/// 
/// This script,
    will:
/// 1. Find all hardcoded padding, spacing, icon sizes, border radius, and durations
/// 2. Replace them with appropriate theme constants
/// 3. Add necessary imports
/// 4. Preserve existing functionality
void main() async {
  print('🚀 Starting Fortune Flutter Design Values Migration...\n');
  
  final migrator = DesignValuesMigrator();
  await migrator.run();
}

class DesignValuesMigrator {
  // Target directories
  static const targetDirs = [
    'lib/features/fortune/presentation/pages',
    'lib/features/fortune/presentation/widgets',
    'lib/presentation/widgets',
    'lib/presentation/screens',
    'lib/screens',
    'lib/shared/components',
  ];

  // Keep track of files modified
  final List<String> modifiedFiles = [];
  final List<String> skippedFiles = [];
  
  Future<void> run() async {
    for (final dir in targetDirs) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        await processDirectory(directory);
      }
    }
    
    // Report results
    print('\n✅ Migration completed!');
    print('📝 Modified ${modifiedFiles.length} files');
    if (skippedFiles.isNotEmpty) {
      print('⏭️  Skipped ${skippedFiles.length} files (no changes needed)');
    }
    
    if (modifiedFiles.isNotEmpty) {
      print('\n📋 Modified,
    files:');
      for (final file in modifiedFiles) {
        print('   ✓ $file');
      }
    }
  }
  
  Future<void> processDirectory(Directory dir) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        await processFile(entity);
      }
    }
  }
  
  Future<void> processFile(File file) async {
    try {
      String content = await file.readAsString();
      final originalContent = content;
      
      // Track if we need to add imports
      bool needsSpacingImport = false;
      bool needsDimensionsImport = false;
      bool needsAnimationsImport = false;
      
      // 1. Replace EdgeInsets patterns
      final edgeInsetsPatterns = [
        (pattern: r'EdgeInsets\.all\(4(?:\.0)?\)', replacement: 'AppSpacing.paddingAll4', needsImport: true),
        (pattern: r'EdgeInsets\.all\(8(?:\.0)?\)', replacement: 'AppSpacing.paddingAll8', needsImport: true),
        (pattern: r'EdgeInsets\.all\(12(?:\.0)?\)', replacement: 'AppSpacing.paddingAll12', needsImport: true),
        (pattern: r'EdgeInsets\.all\(16(?:\.0)?\)', replacement: 'AppSpacing.paddingAll16', needsImport: true),
        (pattern: r'EdgeInsets\.all\(20(?:\.0)?\)', replacement: 'AppSpacing.paddingAll20', needsImport: true),
        (pattern: r'EdgeInsets\.all\(24(?:\.0)?\)', replacement: 'AppSpacing.paddingAll24', needsImport: true),
        (pattern: r'EdgeInsets\.symmetric\(horizontal:\s*16(?:\.0)?\)', replacement: 'AppSpacing.paddingHorizontal16', needsImport: true),
        (pattern: r'EdgeInsets\.symmetric\(horizontal:\s*24(?:\.0)?\)', replacement: 'AppSpacing.paddingHorizontal24', needsImport: true),
        (pattern: r'EdgeInsets\.symmetric\(vertical:\s*8(?:\.0)?\)', replacement: 'AppSpacing.paddingVertical8', needsImport: true),
        (pattern: r'EdgeInsets\.symmetric\(vertical:\s*16(?:\.0)?\)', replacement: 'AppSpacing.paddingVertical16', needsImport: true),
      ];
      
      for (final pattern in edgeInsetsPatterns) {
        if (content.contains(RegExp(pattern.pattern))) {
          content = content.replaceAll(RegExp(pattern.pattern), pattern.replacement);
          if (pattern.needsImport) needsSpacingImport = true;
        }
      }
      
      // 2. Replace SizedBox spacing patterns
      final sizedBoxPatterns = [
        (pattern: r'SizedBox\(height:\s*4(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing1)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*8(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing2)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*12(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing3)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*16(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing4)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*20(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing5)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*24(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing6)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*32(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing8)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*40(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing10)', needsImport: true),
        (pattern: r'SizedBox\(height:\s*48(?:\.0)?\)', replacement: 'SizedBox(height: AppSpacing.spacing12)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*4(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing1)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*8(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing2)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*12(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing3)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*16(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing4)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*20(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing5)', needsImport: true),
        (pattern: r'SizedBox\(width:\s*24(?:\.0)?\)', replacement: 'SizedBox(width: AppSpacing.spacing6)', needsImport: true),
      ];
      
      for (final pattern in sizedBoxPatterns) {
        if (content.contains(RegExp(pattern.pattern))) {
          content = content.replaceAll(RegExp(pattern.pattern), pattern.replacement);
          if (pattern.needsImport) needsSpacingImport = true;
        }
      }
      
      // 3. Replace Icon size patterns
      final iconSizePatterns = [
        (pattern: r'size:\s*16(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeXSmall', needsImport: true),
        (pattern: r'size:\s*20(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeSmall', needsImport: true),
        (pattern: r'size:\s*24(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeMedium', needsImport: true),
        (pattern: r'size:\s*28(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeLarge', needsImport: true),
        (pattern: r'size:\s*32(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeXLarge', needsImport: true),
        (pattern: r'size:\s*40(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeXxLarge', needsImport: true),
        (pattern: r'size:\s*48(?:\.0)?(?=\s*[,)])', replacement: 'size: AppDimensions.iconSizeXxxLarge', needsImport: true),
      ];
      
      // Only apply icon size patterns if we're likely in an Icon widget context
      for (final pattern in iconSizePatterns) {
        // Look for Icon widget context
        final iconContextPattern = RegExp(r'Icon\s*\([^)]*' + pattern.pattern);
        if (iconContextPattern.hasMatch(content)) {
          content = content.replaceAllMapped(iconContextPattern, (match) {
            needsDimensionsImport = true;
            return match.group(0)!.replaceAll(RegExp(pattern.pattern), pattern.replacement);
          });
        }
      }
      
      // 4. Replace BorderRadius patterns
      final borderRadiusPatterns = [
        (pattern: r'BorderRadius\.circular\(4(?:\.0)?\)', replacement: 'AppDimensions.borderRadiusSmall', needsImport: true),
        (pattern: r'BorderRadius\.circular\(8(?:\.0)?\)', replacement: 'AppDimensions.borderRadiusSmall', needsImport: true),
        (pattern: r'BorderRadius\.circular\(12(?:\.0)?\)', replacement: 'AppDimensions.borderRadiusMedium', needsImport: true),
        (pattern: r'BorderRadius\.circular\(16(?:\.0)?\)', replacement: 'AppDimensions.borderRadiusLarge', needsImport: true),
        (pattern: r'BorderRadius\.circular\(20(?:\.0)?\)', replacement: 'AppDimensions.borderRadius(AppDimensions.radiusXLarge)', needsImport: true),
        (pattern: r'BorderRadius\.circular\(24(?:\.0)?\)', replacement: 'AppDimensions.borderRadius(AppDimensions.radiusXxLarge)', needsImport: true),
      ];
      
      for (final pattern in borderRadiusPatterns) {
        if (content.contains(RegExp(pattern.pattern))) {
          content = content.replaceAll(RegExp(pattern.pattern), pattern.replacement);
          if (pattern.needsImport) needsDimensionsImport = true;
        }
      }
      
      // 5. Replace Duration patterns
      final durationPatterns = [
        (pattern: r'Duration\(milliseconds:\s*100\)', replacement: 'AppAnimations.durationMicro', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*200\)', replacement: 'AppAnimations.durationShort', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*300\)', replacement: 'AppAnimations.durationMedium', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*500\)', replacement: 'AppAnimations.durationLong', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*800\)', replacement: 'AppAnimations.durationXLong', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*1000\)', replacement: 'AppAnimations.durationLong * 2', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*1200\)', replacement: 'AppAnimations.durationShimmer', needsImport: true),
        (pattern: r'Duration\(milliseconds:\s*1500\)', replacement: 'AppAnimations.durationSkeleton', needsImport: true),
      ];
      
      for (final pattern in durationPatterns) {
        if (content.contains(RegExp(pattern.pattern))) {
          content = content.replaceAll(RegExp(pattern.pattern), pattern.replacement);
          if (pattern.needsImport) needsAnimationsImport = true;
        }
      }
      
      // 6. Add necessary imports if content was modified
      if (content != originalContent) {
        final imports = <String>[];
        
        // Check existing imports
        final hasSpacingImport = content.contains("import 'package:fortune/core/theme/app_spacing.dart'") ||
                                content.contains('import "package:fortune/core/theme/app_spacing.dart"');
        final hasDimensionsImport = content.contains("import 'package:fortune/core/theme/app_dimensions.dart'") ||
                                   content.contains('import "package:fortune/core/theme/app_dimensions.dart"');
        final hasAnimationsImport = content.contains("import 'package:fortune/core/theme/app_animations.dart'") ||
                                   content.contains('import "package:fortune/core/theme/app_animations.dart"');
        
        if (needsSpacingImport && !hasSpacingImport) {
          imports.add("import 'package:fortune/core/theme/app_spacing.dart';");
        }
        if (needsDimensionsImport && !hasDimensionsImport) {
          imports.add("import 'package:fortune/core/theme/app_dimensions.dart';");
        }
        if (needsAnimationsImport && !hasAnimationsImport) {
          imports.add("import 'package:fortune/core/theme/app_animations.dart';");
        }
        
        if (imports.isNotEmpty) {
          // Find the right place to insert imports (after existing imports)
          final lines = content.split('\n');
          int lastImportLine = -1;
          
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].trim().startsWith('import ')) {
              lastImportLine = i;
            }
          }
          
          if (lastImportLine >= 0) {
            // Insert after the last import
            lines.insert(lastImportLine + 1, imports.join('\n'));
          } else {
            // Find library or part statement
            int insertLine = 0;
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].trim().startsWith('library ') || 
                  lines[i].trim().startsWith('part of ')) {
                insertLine = i + 1;
                break;
              }
            }
            
            // Insert imports
            if (insertLine > 0) {
              lines.insert(insertLine, '');
              lines.insert(insertLine + 1, imports.join('\n'));
              lines.insert(insertLine + 2, '');
            } else {
              lines.insert(0, imports.join('\n'));
              lines.insert(1, '');
            }
          }
          
          content = lines.join('\n');
        }
        
        // Write the modified content back
        await file.writeAsString(content);
        modifiedFiles.add(file.path);
        print('✓ Modified: ${file.path}');
      } else {
        skippedFiles.add(file.path);
      }
    } catch (e) {
      print('❌ Error processing ${file.path}: $e');
    }
  }
}

// Pattern matching helper class
class MigrationPattern {
  final String pattern;
  final String replacement;
  final bool needsImport;
  
  const MigrationPattern({
    required this.pattern,
    required this.replacement,
    required this.needsImport,
  });
}