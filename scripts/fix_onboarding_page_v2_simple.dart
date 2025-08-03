import 'dart:io';

void main() async {
  final file = File('lib/screens/onboarding/onboarding_page_v2.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  int fixCount = 0;
  
  // Fix pattern,
    1: style with closing parenthesis on wrong line
  final lines = content.split('\n');
  for (int i = 0; i < lines.length - 1; i++) {
    // Check if line ends with .displaySmall) and next line has textAlign
    if (lines[i].trim().endsWith('.displaySmall),') && 
        i + 1 < lines.length && 
        lines[i + 1].trim().startsWith('textAlign:')) {
      lines[i] = lines[i].replaceAll('),', ',');
      fixCount++;
    }
    
    // Check for style with ?? const TextStyle()))),
    if (lines[i].contains('?? const TextStyle())),')) {
      lines[i] = lines[i].replaceAll('?? const TextStyle())),', '?? const TextStyle(),');
      fixCount++;
    }
  }
  
  content = lines.join('\n');
  
  // Write back
  await file.writeAsString(content);
  print('Fixed $fixCount issues in onboarding_page_v2.dart');
}