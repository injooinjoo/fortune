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
    
    // Fix pattern where copyWith ends early and properties follow
    final copyWithSplitAllPattern = RegExp(
      r'(\.copyWith\([^)]*)\)\),?\s*(\w+:)',
      multiLine: true,
    );
    while (copyWithSplitAllPattern.hasMatch(fixedContent)) {
      fixedContent = fixedContent.replaceFirstMapped(copyWithSplitAllPattern, (match) {
        fileFixed++;
        return '${match.group(1)}, ${match.group(2)}';
      });
    }
    
    // Fix TextStyle pattern where closing parenthesis is doubled
    final textStyleDoubleClosePattern = RegExp(
      r'(style:\s*[^)]+\))\),(\s*\w+:)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textStyleDoubleClosePattern, (match) {
      fileFixed++;
      return '${match.group(1)},${match.group(2)}';
    });
    
    // Fix Text widgets with incorrect style closing
    final textStyleExtraClosePattern = RegExp(
      r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+\?\.\w+)\),\s*\)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textStyleExtraClosePattern, (match) {
      fileFixed++;
      return '${match.group(1)})';
    });
    
    // Fix nested copyWith calls
    final nestedCopyWithPattern = RegExp(
      r'(copyWith\([^)]+)\)\)\),',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(nestedCopyWithPattern, (match) {
      fileFixed++;
      return '${match.group(1)})),';
    });
    
    if (fileFixed > 0) {
      await file.writeAsString(fixedContent);
      print('Fixed $fileFixed issues in $filePath');
      totalFixed += fileFixed;
      filesFixed++;
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed across $filesFixed files');
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