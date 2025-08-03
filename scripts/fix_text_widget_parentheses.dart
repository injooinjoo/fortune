import 'dart:io';

void main() async {
  var totalFixed = 0;
  var filesFixed = 0;
  
  // Find all Dart files
  final files = await findDartFiles(Directory('lib'));
  files.addAll(await findDartFiles(Directory('test')));
  
  for (final file in files) {
    final content = await file.readAsString();
    var fixedContent = content;
    var fileFixed = 0;
    
    // Pattern to find Text widgets with missing closing parenthesis after style
    // This pattern looks for Text( followed by content and style property without closing );
    final pattern = RegExp(
      r'(\s*)(Text\(\s*[^,]+,\s*style:\s*[^,]+(?:\.copyWith\([^)]*\))?),(\s*[^\)])',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(pattern, (match) {
      fileFixed++;
      return '${match.group(1)}${match.group(2)},),${match.group(3)}';
    });
    
    // Another pattern for Text widgets with only one argument
    final singleArgPattern = RegExp(
      r'(\s*)(Text\(\s*[^,\)]+)(\s*\n\s*[^\),])',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(singleArgPattern, (match) {
      // Check if this is really missing a closing parenthesis
      final lineContent = match.group(2)!;
      final openCount = lineContent.split('(').length - 1;
      final closeCount = lineContent.split(')').length - 1;
      
      if (openCount > closeCount) {
        fileFixed++;
        return '${match.group(1)}${match.group(2)},),${match.group(3)}';
      }
      return match.group(0)!;
    });
    
    // Pattern specifically for Text widgets with Theme.of(context).textTheme
    final themePattern = RegExp(
      r'(\s*Text\(\s*[^,]+,\s*style:\s*Theme\.of\(context\)\.textTheme\.\w+(?:\?.copyWith\([^)]*\))?),(\s*[^\)]\s*[^\)])',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(themePattern, (match) {
      fileFixed++;
      return '${match.group(1)},),${match.group(2)}';
    });
    
    if (fileFixed > 0) {
      await file.writeAsString(fixedContent);
      print('Fixed $fileFixed issues in ${file.path}');
      totalFixed += fileFixed;
      filesFixed++;
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed across $filesFixed files');
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