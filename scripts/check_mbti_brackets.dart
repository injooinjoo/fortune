import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/mbti_fortune_page.dart');
  final lines = await file.readAsLines();
  
  int openBrackets = 0;
  int openParens = 0;
  int openBraces = 0;
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    // Count brackets
    openBrackets += line.split('[').length - 1;
    openBrackets -= line.split(']').length - 1;
    
    // Count parentheses
    openParens += line.split('(').length - 1;
    openParens -= line.split(')').length - 1;
    
    // Count braces
    openBraces += line.split('{').length - 1;
    openBraces -= line.split('}').length - 1;
    
    if (openBrackets < 0) {
      print('Line ${i + 1}: Too many closing brackets ] - $line');
    }
    if (openParens < 0) {
      print('Line ${i + 1}: Too many closing parentheses ) - $line');
    }
    if (openBraces < 0) {
      print('Line ${i + 1}: Too many closing braces } - $line');
    }
  }
  
  print('\nFinal,
    counts:');
  print('Open,
    brackets: $openBrackets');
  print('Open,
    parentheses: $openParens');
  print('Open,
    braces: $openBraces');
  
  // Show lines around 701
  print('\nLines around,
    701:');
  for (int i = 695; i < 705 && i < lines.length; i++) {
    print('${i + 1}: ${lines[i]}');
  }
}