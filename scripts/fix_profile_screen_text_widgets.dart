import 'dart:io';

void main() async {
  final file = File('lib/screens/profile/profile_screen.dart');
  final lines = await file.readAsLines();
  var fixCount = 0;
  var newLines = <String>[];
  
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    newLines.add(line);
    
    // Check if this is a Text widget
    if (line.trim().startsWith('Text(')) {
      var bracketCount = 0;
      var isInStyleBlock = false;
      var textStartIndex = i;
      
      // Scan through lines to find the matching closing parenthesis
      for (var j = i; j < lines.length && j < i + 20; j++) {
        var scanLine = lines[j];
        
        // Count parentheses
        for (var char in scanLine.split('')) {
          if (char == '(') bracketCount++;
          else if (char == ')') bracketCount--;
        }
        
        // Check if we're in a style block
        if (scanLine.contains('style:')) isInStyleBlock = true;
        
        // If we've closed all parentheses
        if (bracketCount == 0) {
          // Check if the next line has issues
          if (j + 1 < lines.length) {
            var nextLine = lines[j + 1].trim();
            
            // If the next line is a closing bracket/parenthesis and current line doesn't end with ),
            if ((nextLine.startsWith('],') || nextLine.startsWith('),') || nextLine.startsWith('}')) 
                && !scanLine.trim().endsWith('),')) {
              // Fix: Add closing parenthesis
              newLines[newLines.length - 1] = scanLine.trimRight() + '),';
              fixCount++;
              print('Fixed Text widget at line ${j + 1}');
            }
          }
          break;
        }
      }
    }
  }
  
  if (fixCount > 0) {
    await file.writeAsString(newLines.join('\n'));
    print('\nFixed $fixCount Text widget issues in profile_screen.dart');
  } else {
    print('No Text widget issues found in profile_screen.dart');
  }
}