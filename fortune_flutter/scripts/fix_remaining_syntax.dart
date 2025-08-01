import 'dart:io';

void main() async {
  var totalFixed = 0;
  var filesFixed = 0;
  
  // Get all Dart files
  final dartFiles = await _getDartFiles('lib');
  
  for (final filePath in dartFiles) {
    final file = File(filePath);
    final content = await file.readAsString();
    var fixedContent = content;
    var fileFixed = 0;
    
    // Fix Text widgets with style ending with double parenthesis
    final textStylePattern = RegExp(
      r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+(?:\?\.\w+)?)\)\)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textStylePattern, (match) {
      fileFixed++;
      return '${match.group(1)})';
    });
    
    // Fix TextStyle ending with double parenthesis
    final textStyleEndPattern = RegExp(
      r'(style:\s*TextStyle\([^)]+\))\)\)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textStyleEndPattern, (match) {
      fileFixed++;
      return '${match.group(1)})';
    });
    
    // Fix copyWith patterns ending with double parenthesis
    final copyWithPattern = RegExp(
      r'(\.copyWith\([^)]+\))\)\)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(copyWithPattern, (match) {
      fileFixed++;
      return '${match.group(1)})';
    });
    
    // Fix Text widget with TextStyle properties split across lines
    final splitStylePattern = RegExp(
      r'(fontSize:\s*[^,\)]+)\)\),(\s*(?:color|fontWeight|height|letterSpacing):)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(splitStylePattern, (match) {
      fileFixed++;
      return '${match.group(1)},${match.group(2)}';
    });
    
    if (fileFixed > 0) {
      await file.writeAsString(fixedContent);
      print('Fixed $fileFixed issues in $filePath');
      totalFixed += fileFixed;
      filesFixed++;
    }
  }
  
  print('\nTotal fixes: $totalFixed across $filesFixed files');
}

Future<List<String>> _getDartFiles(String directory) async {
  final files = <String>[];
  final dir = Directory(directory);
  
  if (!await dir.exists()) return files;
  
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity.path);
    }
  }
  
  return files;
}