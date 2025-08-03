import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/tarot_main_page.dart');
  final lines = await file.readAsLines();
  var fixCount = 0;
  
  // Process lines to fix Text widgets
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    
    // Check if this is a Text widget with style ending with )
    if (line.contains('style:') && line.contains('textTheme') && line.endsWith('),')) {
      // Check if the next line starts with widget indicators (SizedBox, Container, Text, etc.)
      if (i + 1 < lines.length) {
        var nextLine = lines[i + 1].trim();
        if (nextLine.startsWith('SizedBox(') || 
            nextLine.startsWith('Container(') || 
            nextLine.startsWith('Text(') ||
            nextLine.startsWith('],') ||
            nextLine.startsWith('},') ||
            nextLine.startsWith('),')) {
          // This line probably needs an extra closing parenthesis
          lines[i] = line.substring(0, line.length - 1) + '),';
          fixCount++;
          print('Fixed line ${i + 1}: Text widget closing parenthesis');
        }
      }
    }
    
    // Check for specific pattern where style ends without proper closing
    if (line.contains('style:') && line.contains('.textTheme.') && line.endsWith('),') && !line.contains('),')) {
      // Count parentheses in the line
      var openCount = line.split('(').length - 1;
      var closeCount = line.split(')').length - 1;
      
      if (openCount > closeCount) {
        lines[i] = line.substring(0, line.length - 1) + '),';
        fixCount++;
        print('Fixed line ${i + 1}: Parenthesis mismatch');
      }
    }
  }
  
  if (fixCount > 0) {
    await file.writeAsString(lines.join('\n'));
    print('\nFixed $fixCount issues in tarot_main_page.dart');
  } else {
    print('No issues found in tarot_main_page.dart');
  }
}