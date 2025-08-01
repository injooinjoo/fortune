import 'dart:io';

void main() async {
  print('🔧 Fixing syntax errors in unified pages...');
  
  final files = [
    'lib/features/fortune/presentation/pages/health_sports_unified_page.dart',
    'lib/features/fortune/presentation/pages/pet_fortune_unified_page.dart',
    'lib/features/fortune/presentation/pages/personality_fortune_unified_page.dart',
    'lib/features/fortune/presentation/pages/face_reading_unified_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix missing closing parentheses and brackets
    content = _fixBracketMatching(content);
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed syntax in $filePath');
    }
  }
  
  print('✅ Syntax fixes completed!');
}

String _fixBracketMatching(String content) {
  // Fix common patterns where brackets got messed up
  
  // Fix pattern where )] should be ),
  content = content.replaceAll(')],', '),');
  
  // Fix missing closing parentheses for Text widgets
  content = content.replaceAllMapped(
    RegExp(r'Text\([^)]+textAlign: TextAlign\.center\)([^,])'),
    (match) => 'Text(${match.group(0)!.substring(5, match.group(0)!.length - 1)})${match.group(1)}'
  );
  
  // Fix const Theme.of(context) that should not have const
  content = content.replaceAll(
    'const Text(\n                    \'Premium\',\n                    style: Theme.of(context).textTheme.bodySmall,\n                  ),',
    'Text(\n                    \'Premium\',\n                    style: Theme.of(context).textTheme.bodySmall,\n                  ),'
  );
  
  // Check bracket balance and attempt fixes
  final lines = content.split('\n');
  var openParens = 0;
  var openBrackets = 0;
  var openBraces = 0;
  
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    for (final char in line.split('')) {
      switch (char) {
        case '(':
          openParens++;
          break;
        case ')':
          openParens--;
          break;
        case '[':
          openBrackets++;
          break;
        case ']':
          openBrackets--;
          break;
        case '{':
          openBraces++;
          break;
        case '}':
          openBraces--;
          break;
      }
    }
    
    // Fix specific known issues
    if (line.contains('textAlign: TextAlign.center)],')) {
      lines[i] = line.replaceAll('textAlign: TextAlign.center)],', 'textAlign: TextAlign.center),');
    }
    
    if (line.contains('))],') && openParens < 0) {
      lines[i] = line.replaceAll('))],', ')),');
    }
  }
  
  return lines.join('\n');
}