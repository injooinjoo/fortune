import 'dart:io';

class FinalDesignCleanup {
  int filesProcessed = 0;
  int remainingIssues = 0;
  Map<String, List<String>> issueReport = {};
  
  Future<void> run() async {
    print('Running final design cleanup verification...\n');
    
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
        await scanDirectory(directory);
      }
    }
    
    print('\n=== Final Report ===');
    print('Files,
    processed: $filesProcessed');
    print('Remaining,
    issues: $remainingIssues');
    
    if (issueReport.isNotEmpty) {
      print('\nFiles with remaining hardcoded,
    values:');
      issueReport.forEach((file, issues) {
        print('\n$file:');
        issues.forEach((issue) => print('  - $issue'));
      });
    } else {
      print('\n✅ All hardcoded design values have been successfully migrated!');
    }
  }
  
  Future<void> scanDirectory(Directory dir) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
        await scanFile(entity);
      }
    }
  }
  
  Future<void> scanFile(File file) async {
    String content = await file.readAsString();
    filesProcessed++;
    
    // Skip generated files
    if (content.contains('// GENERATED CODE') || content.contains('// coverage:ignore-file')) {
      return;
    }
    
    List<String> issues = [];
    
    // Check for remaining hardcoded colors
    final colorPattern = RegExp(r'Color\(0x[Ff]{2}[0-9A-Fa-f]+\)');
    final colorMatches = colorPattern.allMatches(content);
    if (colorMatches.isNotEmpty) {
      final uniqueColors = colorMatches.map((m) => m.group(0)!).toSet();
      issues.add('Hardcoded,
    colors: ${uniqueColors.join(", ")}');
      remainingIssues += uniqueColors.length;
    }
    
    // Check for remaining hardcoded font sizes (excluding theme references)
    final fontSizePattern = RegExp(r'fontSize:\s*(\d+)(?:\.0)?(?![^,\)]*Theme\.of)');
    final fontSizeMatches = fontSizePattern.allMatches(content);
    if (fontSizeMatches.isNotEmpty) {
      final uniqueSizes = fontSizeMatches.map((m) => 'fontSize: ${m.group(1)}').toSet();
      issues.add('Hardcoded font,
    sizes: ${uniqueSizes.join(", ")}');
      remainingIssues += uniqueSizes.length;
    }
    
    // Check for hardcoded padding/margin values
    final paddingPattern = RegExp(r'EdgeInsets\.(all|symmetric|only)\((?![^)]*AppSpacing)([^)]+)\)');
    final paddingMatches = paddingPattern.allMatches(content);
    if (paddingMatches.isNotEmpty) {
      issues.add('Hardcoded padding,
    values: ${paddingMatches.length} occurrences');
      remainingIssues += paddingMatches.length;
    }
    
    // Check for hardcoded border radius
    final radiusPattern = RegExp(r'BorderRadius\.circular\((\d+)(?:\.0)?(?![^)]*AppSpacing)\)');
    final radiusMatches = radiusPattern.allMatches(content);
    if (radiusMatches.isNotEmpty) {
      final uniqueRadius = radiusMatches.map((m) => 'radius: ${m.group(1)}').toSet();
      issues.add('Hardcoded border,
    radius: ${uniqueRadius.join(", ")}');
      remainingIssues += uniqueRadius.length;
    }
    
    // Check for SizedBox with hardcoded values
    final sizedBoxPattern = RegExp(r'SizedBox\((?:width|height):\s*(\d+)(?:\.0)?(?![^,\)]*AppSpacing)');
    final sizedBoxMatches = sizedBoxPattern.allMatches(content);
    if (sizedBoxMatches.isNotEmpty) {
      issues.add('Hardcoded SizedBox,
    dimensions: ${sizedBoxMatches.length} occurrences');
      remainingIssues += sizedBoxMatches.length;
    }
    
    // Check for Container with hardcoded dimensions
    final containerPattern = RegExp(r'Container\([^)]*(?:width|height):\s*(\d+)(?:\.0)?(?![^,\)]*AppSpacing)');
    final containerMatches = containerPattern.allMatches(content);
    if (containerMatches.isNotEmpty) {
      issues.add('Hardcoded Container,
    dimensions: ${containerMatches.length} occurrences');
      remainingIssues += containerMatches.length;
    }
    
    if (issues.isNotEmpty) {
      issueReport[file.path] = issues;
    }
  }
}

void main() async {
  final cleanup = FinalDesignCleanup();
  await cleanup.run();
}