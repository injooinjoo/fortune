import 'dart:io';

void main() async {
  final file = File('lib/screens/settings/social_accounts_screen.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  
  // Count brackets and parentheses to find imbalances
  int openBrackets = 0;
  int closeBrackets = 0;
  int openParens = 0;
  int closeParens = 0;
  int openBraces = 0;
  int closeBraces = 0;
  
  for (int i = 0; i < content.length; i++) {
    switch (content[i]) {
      case '[':
        openBrackets++;
        break;
      case ']':
        closeBrackets++;
        break;
      case '(':
        openParens++;
        break;
      case ')':
        closeParens++;
        break;
      case '{':
        openBraces++;
        break;
      case '}':
        closeBraces++;
        break;
    }
  }
  
  print('Bracket analysis:');
  print('Open brackets [ : $openBrackets');
  print('Close brackets ] : $closeBrackets');
  print('Difference: ${openBrackets - closeBrackets}');
  print('');
  print('Open parentheses ( : $openParens');
  print('Close parentheses ) : $closeParens');
  print('Difference: ${openParens - closeParens}');
  print('');
  print('Open braces { : $openBraces');
  print('Close braces } : $closeBraces');
  print('Difference: ${openBraces - closeBraces}');
  
  // If brackets are unbalanced, we need to add closing bracket
  if (openBrackets > closeBrackets) {
    print('\nNeed to add ${openBrackets - closeBrackets} closing bracket(s)');
    
    // Find likely place to add closing bracket - after line 206
    final pattern = RegExp(r'SizedBox\(height: AppSpacing\.spacing8\),\s*\n\s*\],', multiLine: true);
    if (pattern.hasMatch(content)) {
      print('Found the pattern at the end of children list');
    } else {
      // Try simpler pattern
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('SizedBox(height: AppSpacing.spacing8),')) {
          if (i + 1 < lines.length && lines[i + 1].trim() == '],') {
            // Need to add another closing bracket
            lines[i + 1] = '                ],';
            lines.insert(i + 2, '              ],');
            content = lines.join('\n');
            print('Added missing closing bracket after line ${i + 1}');
            break;
          }
        }
      }
    }
  }
  
  // Write back
  await file.writeAsString(content);
  print('\nFile updated');
}