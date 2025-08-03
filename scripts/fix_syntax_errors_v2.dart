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
    
    // Fix double,
    commas: ),,
    final doubleCommaPattern = RegExp(r'\),,', multiLine: true);
    fixedContent = fixedContent.replaceAllMapped(doubleCommaPattern, (match) {
      fileFixed++;
      return '),';
    });
    
    // Fix comma-parenthesis-comma: ,),
    final commaParenCommaPattern = RegExp(r',\),', multiLine: true);
    fixedContent = fixedContent.replaceAllMapped(commaParenCommaPattern, (match) {
      fileFixed++;
      return '),';
    });
    
    // Fix style ending with double comma
    final styleDoubleCommaPattern = RegExp(
      r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+\?\.copyWith\([^)]+\)),,(\s*\))',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(styleDoubleCommaPattern, (match) {
      fileFixed++;
      return '${match.group(1)},${match.group(2)}';
    });
    
    // Fix style ending with ),), where it should just be ),
    final styleExtraParenPattern = RegExp(
      r'(style:\s*Theme\.of\(context\)\.textTheme\.\w+\?\.copyWith\([^)]+\))\),\)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(styleExtraParenPattern, (match) {
      fileFixed++;
      return '${match.group(1)})';
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