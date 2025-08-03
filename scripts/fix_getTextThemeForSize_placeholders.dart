import 'dart:io';

void main() async {
  print('Fixing getTextThemeForSize template placeholders...\n');
  
  final directories = [
    Directory('lib/features/fortune/presentation/pages'),
    Directory('lib/presentation/widgets'),
    Directory('lib/screens'),
    Directory('lib/shared'),
    Directory('lib/features/fortune/presentation/widgets'),
  ];
  
  int totalFixed = 0;
  
  for (final dir in directories) {
    if (!await dir.exists()) continue;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        
        if (content.contains('getTextThemeForSize')) {
          print('Fixing ${entity.path}...');
          
          // Replace the problematic pattern
          final newContent = content.replaceAllMapped(
            RegExp(r'Theme\.of\(context\)\.textTheme\.\$\{getTextThemeForSize\(size\)\}'),
            (match) {
              totalFixed++;
              return 'Theme.of(context).textTheme.bodyMedium';
            }
          );
          
          await entity.writeAsString(newContent);
        }
      }
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed');
}