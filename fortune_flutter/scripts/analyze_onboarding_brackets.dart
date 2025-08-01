import 'dart:io';

void main() async {
  final file = File('lib/screens/onboarding/onboarding_page.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  
  // Find the build method
  final buildStart = content.indexOf('Widget build(BuildContext context)');
  if (buildStart == -1) {
    print('build method not found');
    return;
  }
  
  // Find the end of build method (next method or end of class)
  final buildEnd = content.indexOf('\n  Widget ', buildStart + 1);
  final classEnd = content.indexOf('\n}', buildStart);
  final methodEnd = buildEnd != -1 && buildEnd < classEnd ? buildEnd : classEnd;
  
  final buildContent = content.substring(buildStart, methodEnd);
  
  // Count brackets
  int openBrackets = 0;
  int closeBrackets = 0;
  int openParens = 0;
  int closeParens = 0;
  int openBraces = 0;
  int closeBraces = 0;
  
  int currentLine = content.substring(0, buildStart).split('\n').length;
  
  for (int i = 0; i < buildContent.length; i++) {
    if (buildContent[i] == '\n') currentLine++;
    
    switch (buildContent[i]) {
      case '[':
        openBrackets++;
        print('Line $currentLine: [ (total open: $openBrackets)');
        break;
      case ']':
        closeBrackets++;
        print('Line $currentLine: ] (total close: $closeBrackets)');
        if (closeBrackets > openBrackets) {
          print('ERROR: Extra closing bracket at line $currentLine');
        }
        break;
    }
  }
  
  print('\nSummary:');
  print('Open brackets [ : $openBrackets');
  print('Close brackets ] : $closeBrackets');
  print('Difference: ${openBrackets - closeBrackets}');
}