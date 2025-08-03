import 'dart:io';

void main() async {
  print('Fixing bracket issues in landing_page.dart...\n');
  
  final file = File('lib/screens/landing_page.dart');
  if (!await file.exists()) {
    print('File not found!');
    return;
  }
  
  var content = await file.readAsString();
  
  // Fix the kakao button issue
  content = content.replaceFirst(
    ''',
    child: Center(
            child: Text(
              'K',
              style: Theme.of(context).textTheme.titleMedium,
                  ),
        );''',
    ''',
    child: Center(
            child: Text(
              'K',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );'''
  );
  
  // Check if there are similar issues for other social buttons
  // Fix naver button if it has similar issues
  final naverPattern = RegExp(
    r"child: Text\(\s*'N',\s*style: Theme\.of\(context\)\.textTheme\.\w+,\s*\),\s*\);",
    multiLine: true,
  );
  
  if (naverPattern.hasMatch(content)) {
    content = content.replaceAllMapped(naverPattern, (match) {
      final text = match.group(0)!;
      // Check if it has extra parentheses
      if (text.contains('),\n        );')) {
        return text.replaceFirst('),\n        );', '),\n          ),\n        );');
      }
      return text;
    });
  }
  
  await file.writeAsString(content);
  print('Fixed bracket issues in landing_page.dart');
}