import 'dart:io';

void main() async {
  print('Fixing backslash import errors...');
  
  final dartFiles = await findDartFiles(Directory('lib'));
  var totalFixed = 0;
  
  for (final file in dartFiles) {
    final fixed = await fixBackslashImports(file);
    if (fixed > 0) {
      totalFixed += fixed;
      print('✓ Fixed ${file.path} ($fixed replacements)');
    }
  }
  
  print('\n✅ Fixed $totalFixed backslash import errors in total!');
}

Future<List<File>> findDartFiles(Directory dir) async {
  final files = <File>[];
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  
  return files;
}

Future<int> fixBackslashImports(File file) async {
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Fix patterns like: import 'path';\nimport 'path';
    final backslashPattern = RegExp(r"import\s+'[^']+';\\nimport\s+'[^']+';");
    content = content.replaceAllMapped(backslashPattern, (match) {
      replacements++;
      final fixed = match.group(0)?.replaceAll(r'\n', '\n') ?? '';
      return fixed;
    });
    
    // Fix patterns with package imports too
    final packagePattern = RegExp(r"import\s+'package:[^']+';\\nimport\s+'[^']+';");
    content = content.replaceAllMapped(packagePattern, (match) {
      replacements++;
      final fixed = match.group(0)?.replaceAll(r'\n', '\n') ?? '';
      return fixed;
    });
    
    // Fix any remaining backslash-n patterns in import lines
    final lines = content.split('\n');
    final fixedLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Check if line contains import and has literal \n
      if (line.contains('import ') && line.contains(r'\n')) {
        // Split by literal \n and create separate lines
        final parts = line.split(r'\n');
        for (final part in parts) {
          if (part.trim().isNotEmpty) {
            fixedLines.add(part);
            replacements++;
          }
        }
      } else {
        fixedLines.add(line);
      }
    }
    
    if (replacements > 0) {
      await file.writeAsString(fixedLines.join('\n'));
    }
    
    return replacements;
  } catch (e) {
    print('Error processing ${file.path}: $e');
    return 0;
  }
}