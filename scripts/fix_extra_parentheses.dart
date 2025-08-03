import 'dart:io';

void main() async {
  print('Fixing extra closing parentheses after style declarations...\n');
  
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
        
        // Pattern to find style declarations with extra closing parentheses
        final pattern = RegExp(
          r'style: Theme\.of\(context\)\.textTheme\.\w+(\?.copyWith\([^)]*\))?,\s*\),\s*\),',
          multiLine: true,
        );
        
        if (pattern.hasMatch(content)) {
          print('Found issues in ${entity.path}');
          
          // Replace the pattern
          final newContent = content.replaceAllMapped(pattern, (match) {
            totalFixed++;
            // Remove one of the extra closing parentheses
            final matched = match.group(0)!;
            // Find the last ),), and replace it with just ),
            return matched.substring(0, matched.lastIndexOf('),')) + '),';
          });
          
          await entity.writeAsString(newContent);
        }
      }
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed');
}