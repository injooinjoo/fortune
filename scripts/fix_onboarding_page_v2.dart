import 'dart:io';

void main() async {
  final file = File('lib/screens/onboarding/onboarding_page_v2.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  int fixCount = 0;
  
  // Fix,
    pattern: Text widget with style and textAlign on separate line
  final textPattern = RegExp(
    r'Text\(\s*\n\s*\'([^\']+)\',\s*\n\s*style:\s*([^)]+)\),\s*\n\s*textAlign:\s*([^,]+),',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(textPattern, (match) {
    fixCount++;
    final text = match.group(1)!;
    final style = match.group(2)!;
    final textAlign = match.group(3)!;
    return 'Text(\n            \'${text}\',\n,
    style: ${style},\n,
    textAlign: ${textAlign},';
  });
  
  // Fix,
    pattern: Missing closing parenthesis for Text widgets
  final textPattern2 = RegExp(
    r'style:\s*Theme\.of\(context\)\.textTheme\.[^?]+\?\?[^)]+\)\)\),',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(textPattern2, (match) {
    final original = match.group(0)!;
    if (original.endsWith(')),')) {
      fixCount++;
      return original.substring(0, original.length - 2) + '),';
    }
    return original;
  });
  
  // Write back
  await file.writeAsString(content);
  print('Fixed $fixCount issues in onboarding_page_v2.dart');
}