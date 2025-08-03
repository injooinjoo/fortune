import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/tarot_main_page.dart');
  final content = await file.readAsString();
  var fixedContent = content;
  var fixCount = 0;
  
  // Fix Text widgets with missing closing parenthesis
  final textMissingClosePattern = RegExp(
    r'(Text\(\s*[^,]+,\s*style:\s*[^)]+\?\.\w+(?:\([^)]*\))?)\s*,\s*(\w+\(|SizedBox\(|\])',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(textMissingClosePattern, (match) {
    if (!match.group(0)!.contains('),')) {
      fixCount++;
      return '${match.group(1)}),\n                        ${match.group(2)}';
    }
    return match.group(0)!;
  });
  
  // Fix copyWith patterns where properties are outside
  final copyWithPropsOutsidePattern = RegExp(
    r'(\.copyWith\([^)]*)\)\s*,\s*((?:fontWeight|fontSize|color|height|letterSpacing):\s*[^,)]+),',
    multiLine: true,
  );
  while (copyWithPropsOutsidePattern.hasMatch(fixedContent)) {
    fixedContent = fixedContent.replaceFirstMapped(copyWithPropsOutsidePattern, (match) {
      fixCount++;
      return '${match.group(1)}, ${match.group(2)}),';
    });
  }
  
  // Fix properties mixed with closing parentheses
  final mixedPropsPattern = RegExp(
    r'(color:\s*[^,)]+)\s*\)\s*,\s*(fontWeight:\s*FontWeight\.\w+),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(mixedPropsPattern, (match) {
    fixCount++;
    return '${match.group(1)}, ${match.group(2)}),';
  });
  
  // Fix TextStyle with properties outside
  final textStylePropsPattern = RegExp(
    r'(TextStyle\([^)]*)\)\s*,\s*((?:fontWeight|fontSize|color):\s*[^,)]+),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(textStylePropsPattern, (match) {
    fixCount++;
    return '${match.group(1)}, ${match.group(2)}),';
  });
  
  if (fixCount > 0) {
    await file.writeAsString(fixedContent);
    print('Fixed $fixCount syntax issues in tarot_main_page.dart');
  } else {
    print('No syntax issues found in tarot_main_page.dart');
  }
}