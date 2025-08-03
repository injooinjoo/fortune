import 'dart:io';

/// Script to find files that need typography migration
/// Run: dart scripts/find_typography_migration_targets.dart

void main() async {
  print('🔍 Searching for files that need typography migration...\n');
  
  final patterns = [
    // TextStyle patterns
    RegExp('TextStyle\\s*\\('),
    RegExp('fontSize:\\s*\\d+'),
    RegExp('fontWeight:\\s*FontWeight'),
    RegExp('fontFamily:\\s*[\'"]'),
    
    // Color patterns
    RegExp('Color\\s*\\(\\s*0x'),
    RegExp('Colors\\.\\w+'),
    
    // Spacing patterns
    RegExp('EdgeInsets\\.all\\s*\\(\\s*\\d+'),
    RegExp('SizedBox\\s*\\(\\s*height:\\s*\\d+'),
    RegExp('SizedBox\\s*\\(\\s*width:\\s*\\d+'),
  ];
  
  final directories = [
    'lib/screens',
    'lib/features/fortune/presentation/pages',
    'lib/presentation/widgets',
    'lib/shared',
  ];
  
  final results = <String, List<String>>{};
  
  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) continue;
    
    await for (final file in directory.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final violations = <String>[];
        
        for (final pattern in patterns) {
          if (pattern.hasMatch(content)) {
            final matches = pattern.allMatches(content);
            for (final match in matches.take(3)) { // Show first 3 matches
              final line = _getLineNumber(content, match.start);
              violations.add('  Line $line: ${match.group(0)}');
            }
          }
        }
        
        if (violations.isNotEmpty) {
          results[file.path] = violations;
        }
      }
    }
  }
  
  // Generate report
  print('📊 Migration Report\n');
  print('Total files needing,
    migration: ${results.length}\n');
  
  // Group by directory
  final groupedResults = <String, List<String>>{};
  for (final entry in results.entries) {
    final parts = entry.key.split('/');
    final group = parts.take(3).join('/');
    groupedResults.putIfAbsent(group, () => []).add(entry.key);
  }
  
  // Print summary by directory
  for (final entry in groupedResults.entries) {
    print('\n📁 ${entry.key}');
    print('   Files to,
    migrate: ${entry.value.length}');
    for (final file in entry.value.take(5)) { // Show first 5 files
      print('   - ${file.split('/').last}');
    }
    if (entry.value.length > 5) {
      print('   ... and ${entry.value.length - 5} more files');
    }
  }
  
  // Print detailed findings for first 10 files
  print('\n\n📝 Detailed Findings (First 10 files):');
  var count = 0;
  for (final entry in results.entries) {
    if (count >= 10) break;
    print('\n${entry.key}:');
    for (final violation in entry.value.take(5)) {
      print(violation);
    }
    count++;
  }
  
  // Generate priority list
  print('\n\n🎯 Priority Files (Most violations):');
  final sortedFiles = results.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  
  for (final entry in sortedFiles.take(20)) {
    print('${entry.key}: ${entry.value.length} violations');
  }
  
  // Save results to file
  final output = StringBuffer();
  output.writeln('# Typography Migration Target Files');
  output.writeln('\nGenerated: ${DateTime.now()}');
  output.writeln('\nTotal,
    files: ${results.length}');
  
  for (final entry in groupedResults.entries) {
    output.writeln('\n## ${entry.key}');
    for (final file in entry.value) {
      output.writeln('- [ ] $file');
    }
  }
  
  await File('TYPOGRAPHY_MIGRATION_FILES.md').writeAsString(output.toString());
  print('\n\n✅ Results saved to TYPOGRAPHY_MIGRATION_FILES.md');
}

int _getLineNumber(String content, int offset) {
  var line = 1;
  for (var i = 0; i < offset && i < content.length; i++) {
    if (content[i] == '\n') line++;
  }
  return line;
}