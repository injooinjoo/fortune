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
    
    // Fix Text widgets with missing closing parenthesis after style
    final textMissingClosePattern = RegExp(
      r'(Text\(\s*[^,]+,\s*style:\s*[^)]+\?\.\w+\([^)]+\)),\s*(\],|\),|$)',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(textMissingClosePattern, (match) {
      if (!match.group(0)!.contains('),')) {
        fileFixed++;
        return '${match.group(1)}),\n${match.group(2)}';
      }
      return match.group(0)!;
    });
    
    // Fix Text widgets with copyWith ending but no widget closing
    final copyWithNoClosePattern = RegExp(
      r'(Text\(\s*[^,]+,\s*style:\s*[^)]+\.copyWith\([^)]+\))\s*,?\s*(\]|\})',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(copyWithNoClosePattern, (match) {
      if (!match.group(0)!.endsWith('),')) {
        fileFixed++;
        return '${match.group(1)}),\n${match.group(2)}';
      }
      return match.group(0)!;
    });
    
    // Fix properties mixed with commas and parentheses
    final mixedPropsPattern = RegExp(
      r'(color:\s*[^,)]+)\s+(FontWeight\.\w+),',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(mixedPropsPattern, (match) {
      fileFixed++;
      return '${match.group(1)}, fontWeight: ${match.group(2)},';
    });
    
    // Fix copyWith with properties outside parentheses
    final copyWithPropsOutsidePattern = RegExp(
      r'(\.copyWith\([^)]*)\)\s*,\s*((?:fontWeight|fontSize|color|height|letterSpacing|decoration):\s*[^,)]+),',
      multiLine: true,
    );
    while (copyWithPropsOutsidePattern.hasMatch(fixedContent)) {
      fixedContent = fixedContent.replaceFirstMapped(copyWithPropsOutsidePattern, (match) {
        fileFixed++;
        return '${match.group(1)}, ${match.group(2)}),';
      });
    }
    
    // Fix double closing parentheses after copyWith
    final doubleClosePattern = RegExp(
      r'(\.copyWith\([^)]+\)\)),\s*\),',
      multiLine: true,
    );
    fixedContent = fixedContent.replaceAllMapped(doubleClosePattern, (match) {
      fileFixed++;
      return '${match.group(1)},';
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