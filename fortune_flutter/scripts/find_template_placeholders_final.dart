import 'dart:io';

void main() async {
  print('Searching for template placeholders...\n');
  
  final fortuneDir = Directory('lib/features/fortune/presentation/pages');
  final widgetsDir = Directory('lib/presentation/widgets');
  final otherDirs = [
    Directory('lib/screens'),
    Directory('lib/shared'),
    Directory('lib/features/fortune/presentation/widgets'),
  ];
  
  int totalIssues = 0;
  
  // Search function
  Future<void> searchDir(Directory dir) async {
    if (!await dir.exists()) return;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        
        // Check for template placeholders
        if (content.contains('\${') || content.contains('\$copyWithProps')) {
          final lines = content.split('\n');
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].contains('\${') || lines[i].contains('\$copyWithProps')) {
              print('${entity.path}:${i + 1}: ${lines[i].trim()}');
              totalIssues++;
            }
          }
        }
      }
    }
  }
  
  // Search all directories
  await searchDir(fortuneDir);
  await searchDir(widgetsDir);
  for (final dir in otherDirs) {
    await searchDir(dir);
  }
  
  print('\nTotal template placeholder issues found: $totalIssues');
}