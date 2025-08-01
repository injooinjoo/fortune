import 'dart:io';

void main() async {
  final file = File('lib/screens/profile/profile_edit_page.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  int fixCount = 0;
  
  // Fix pattern 1: copyWith with fontWeight outside parentheses
  final copyWithPattern = RegExp(
    r'\.copyWith\(\s*fontWeight:\s*(FontWeight\.\w+)\s*\)\s*,',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(copyWithPattern, (match) {
    fixCount++;
    final fontWeight = match.group(1)!;
    return '.copyWith(\n          fontWeight: ${fontWeight},\n        ),';
  });
  
  // Fix pattern 2: copyWith with properties outside
  final copyWithPropsPattern = RegExp(
    r'\.copyWith\(([^)]*)\)\s*,\s*((?:fontWeight|fontSize|color|height|letterSpacing):\s*[^,)]+),',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(copyWithPropsPattern, (match) {
    fixCount++;
    final insideProps = match.group(1)!.trim();
    final outsideProps = match.group(2)!.trim();
    if (insideProps.isEmpty) {
      return '.copyWith(\n          ${outsideProps},\n        ),';
    } else {
      return '.copyWith(\n          ${insideProps},\n          ${outsideProps},\n        ),';
    }
  });
  
  // Fix pattern 3: Missing closing parenthesis for copyWith
  final missingParenPattern = RegExp(
    r'\.copyWith\(\s*([^)]+)\s*\)\s*,\s*\)\s*,\s*\)\s*,',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(missingParenPattern, (match) {
    fixCount++;
    final props = match.group(1)!;
    return '.copyWith(\n          ${props},\n        ),\n      ),';
  });
  
  // Fix pattern 4: Style with properties outside TextStyle parentheses
  final stylePattern = RegExp(
    r'style:\s*TextStyle\s*\(\s*([^)]+)\s*\)\s*,\s*((?:fontWeight|fontSize|color):\s*[^,)]+),',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(stylePattern, (match) {
    fixCount++;
    final insideProps = match.group(1)!.trim();
    final outsideProps = match.group(2)!.trim();
    return 'style: TextStyle(\n          ${insideProps},\n          ${outsideProps},\n        ),';
  });
  
  // Fix pattern 5: withValues followed by comma and closing parenthesis
  final withValuesPattern = RegExp(
    r'\.withValues\(alpha:\s*[\d.]+\)\s*\)\s*,\s*\)',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(withValuesPattern, (match) {
    fixCount++;
    return match.group(0)!.replaceAll('),)', ')');
  });
  
  // Write back
  await file.writeAsString(content);
  print('Fixed $fixCount bracket matching issues in profile_edit_page.dart');
}