import 'dart:io';

void main() async {
  final file = File('lib/screens/profile/profile_screen.dart');
  final content = await file.readAsString();
  var fixedContent = content;
  var fixCount = 0;
  
  // Fix pattern where fontWeight is outside copyWith
  final fontWeightPattern = RegExp(
    r'(\.copyWith\([^)]*)\),\s*(fontWeight:\s*FontWeight\.\w+),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(fontWeightPattern, (match) {
    fixCount++;
    return '${match.group(1)}, ${match.group(2)}),';
  });
  
  // Fix pattern where properties are mixed with closing parentheses  
  final mixedPropsPattern = RegExp(
    r'(color:\s*[^,]+)\s+(FontWeight\.\w+),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(mixedPropsPattern, (match) {
    fixCount++;
    return '${match.group(1)}, fontWeight: ${match.group(2)},';
  });
  
  // Fix Text widgets with extra closing parentheses in style
  final textStyleExtraClosePattern = RegExp(
    r'(style:\s*[^)]+\?\.\w+\([^)]+\)\)),\s*\),\s*\),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(textStyleExtraClosePattern, (match) {
    fixCount++;
    return '${match.group(1)},';
  });
  
  // Fix copyWith patterns with double closing parentheses
  final copyWithDoubleClosePattern = RegExp(
    r'(\.copyWith\([^)]+\)\)),\s*\),',
    multiLine: true,
  );
  fixedContent = fixedContent.replaceAllMapped(copyWithDoubleClosePattern, (match) {
    fixCount++;
    return '${match.group(1)},';
  });
  
  if (fixCount > 0) {
    await file.writeAsString(fixedContent);
    print('Fixed $fixCount syntax issues in profile_screen.dart');
  } else {
    print('No syntax issues found in profile_screen.dart');
  }
}