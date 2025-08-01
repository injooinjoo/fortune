import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/daily_inspiration_page.dart');
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
    
    if (i == 357) {  // Line 358 in 1-based indexing
      print('Line 358 bracket state:');
      print('  Brackets: $openBrackets');
      print('  Parens: $openParens');
      print('  Braces: $openBraces');
    }
  }
  
  print('\nFinal counts:');
  print('Open brackets: $openBrackets');
  print('Open parentheses: $openParens');
  print('Open braces: $openBraces');
  
  // Show lines around 358
  print('\nLines around 358:');
  for (int i = 353; i < 363 && i < lines.length; i++) {
    print('${i + 1}: ${lines[i]}');
  }
}