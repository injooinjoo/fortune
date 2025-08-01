import 'dart:io';

void main() async {
  print('Fixing const before AppSpacing and AppDimensions usage...\n');
  
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
        
        // Pattern to find const before AppSpacing usage
        final pattern1 = RegExp(r'const\s+(AppSpacing\.padding\w+)');
        final pattern2 = RegExp(r'const\s+(AppSpacing\.spacing\w+)');
        final pattern3 = RegExp(r'const\s+(AppDimensions\.\w+)');
        
        if (pattern1.hasMatch(content) || pattern2.hasMatch(content) || pattern3.hasMatch(content)) {
          print('Fixing ${entity.path}');
          
          var newContent = content;
          
          // Remove const before AppSpacing.padding*
          newContent = newContent.replaceAllMapped(pattern1, (match) {
            totalFixed++;
            return match.group(1)!;
          });
          
          // Remove const before AppSpacing.spacing*
          newContent = newContent.replaceAllMapped(pattern2, (match) {
            totalFixed++;
            return match.group(1)!;
          });
          
          // Remove const before AppDimensions.*
          newContent = newContent.replaceAllMapped(pattern3, (match) {
            totalFixed++;
            return match.group(1)!;
          });
          
          await entity.writeAsString(newContent);
        }
      }
    }
  }
  
  print('\nTotal fixes: $totalFixed');
}