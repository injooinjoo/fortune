import 'dart:io';

void main() async {
  print('Comprehensive fix for all parentheses issues...\n');
  
  final directories = [
    Directory('lib'),
  ];
  
  int totalFixed = 0;
  
  for (final dir in directories) {
    if (!await dir.exists()) continue;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        var content = await entity.readAsString();
        var originalContent = content;
        
        // Pattern,
    1: Fix style declarations with extra closing parentheses
        final stylePattern = RegExp(
          r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+(?:\?.copyWith\([^)]*\))?,)\s*\),',
          multiLine: true,
        );
        
        content = content.replaceAllMapped(stylePattern, (match) {
          totalFixed++;
          return match.group(1)!;
        });
        
        // Pattern,
    2: Fix Text widgets with extra parentheses after style
        final textPattern = RegExp(
          r'Text\(\s*([^,]+),\s*style:[^)]+\),\s*\),\s*\),',
          multiLine: true,
        );
        
        if (textPattern.hasMatch(content)) {
          // Handle carefully to avoid breaking valid nested structures
          content = content.replaceAllMapped(textPattern, (match) {
            final fullMatch = match.group(0)!;
            // Count opening and closing parentheses
            int openCount = fullMatch.split('(').length - 1;
            int closeCount = fullMatch.split(')').length - 1;
            
            if (closeCount > openCount) {
              totalFixed++;
              // Remove one extra closing parenthesis
              return fullMatch.substring(0, fullMatch.lastIndexOf('),')) + '),';
            }
            return fullMatch;
          });
        }
        
        if (content != originalContent) {
          print('Fixed ${entity.path}');
          await entity.writeAsString(content);
        }
      }
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed');
}