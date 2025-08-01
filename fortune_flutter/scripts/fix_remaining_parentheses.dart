import 'dart:io';

void main() async {
  print('Fixing remaining extra parentheses issues...\n');
  
  final directories = [
    Directory('lib/features/fortune/presentation/pages'),
    Directory('lib/features/fortune/presentation/widgets'),
    Directory('lib/presentation/widgets'),
    Directory('lib/screens'),
    Directory('lib/shared'),
  ];
  
  int totalFixed = 0;
  
  for (final dir in directories) {
    if (!await dir.exists()) continue;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        
        // Pattern to find double closing parentheses after style declarations
        final pattern = RegExp(
          r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+(?:\?.copyWith\([^)]*\))?,)\s*\),\s*\),',
          multiLine: true,
        );
        
        if (pattern.hasMatch(content)) {
          print('Found issues in ${entity.path}');
          
          // Replace the pattern
          final newContent = content.replaceAllMapped(pattern, (match) {
            totalFixed++;
            // Keep the style part and only one closing parenthesis
            return '${match.group(1)}\n                  ),';
          });
          
          await entity.writeAsString(newContent);
        }
      }
    }
  }
  
  print('\nTotal fixes: $totalFixed');
}