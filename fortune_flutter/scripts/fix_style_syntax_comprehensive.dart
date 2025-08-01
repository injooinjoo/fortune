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
    
    // Fix copyWith patterns where properties are outside the parentheses
    final copyWithSplitPattern = RegExp(
      r'(\.copyWith\([^)]*)\),(\s*(?:fontWeight|letterSpacing|color|fontSize|height|decoration|decorationColor):)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(copyWithSplitPattern, (match) {
      fileFixed++;
      return '${match.group(1)},${match.group(2)}';
    });
    
    // Fix TextStyle patterns where properties are outside the parentheses
    final textStyleSplitPattern = RegExp(
      r'(TextStyle\([^)]*)\)\),(\s*(?:fontWeight|letterSpacing|color|fontSize|height|decoration|decorationColor):)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textStyleSplitPattern, (match) {
      fileFixed++;
      return '${match.group(1)},${match.group(2)}';
    });
    
    // Fix missing closing parenthesis for Text widgets before closing bracket
    final textClosingPattern = RegExp(
      r'(Text\(\s*[^,]+,\s*style:[^)]+\))\s*,?\s*\]',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textClosingPattern, (match) {
      if (!match.group(0)!.contains('),')) {
        fileFixed++;
        return '${match.group(1)}),\n                      ]';
      }
      return match.group(0)!;
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