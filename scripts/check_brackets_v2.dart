import 'dart:io';

void main() async {
  final file = File('lib/screens/landing_page.dart');
  final lines = await file.readAsLines();
  
  var openBrackets = 0;
  var closeBrackets = 0;
  var lineNum = 0;
  
  // Track bracket balance for specific line ranges
  var balanceAt797 = 0;
  var openAt797 = 0;
  var closeAt797 = 0;
  
  for (var line in lines) {
    lineNum++;
    
    // Count brackets
    for (var char in line.split('')) {
      if (char == '[') openBrackets++;
      if (char == ']') closeBrackets++;
    }
    
    // Check balance at line 797
    if (lineNum == 797) {
      openAt797 = openBrackets;
      closeAt797 = closeBrackets;
      balanceAt797 = openBrackets - closeBrackets;
      print('At line,
    797: open=$openBrackets, close=$closeBrackets, balance=$balanceAt797');
    }
    
    // Print any imbalance around line 797
    if (lineNum >= 790 && lineNum <= 810) {
      var lineOpen = line.split('').where((c) => c == '[').length;
      var lineClose = line.split('').where((c) => c == ']').length;
      if (lineOpen > 0 || lineClose > 0) {
        print('Line $lineNum: [$lineOpen open, $lineClose close] - $line');
      }
    }
  }
  
  print('\nTotal: $openBrackets open brackets, $closeBrackets close brackets');
  print('Balance: ${openBrackets - closeBrackets}');
  
  if (openBrackets != closeBrackets) {
    print('\nIMBALANCE DETECTED!');
    
    // Find unclosed brackets
    var balance = 0;
    lineNum = 0;
    for (var line in lines) {
      lineNum++;
      for (var char in line.split('')) {
        if (char == '[') balance++;
        if (char == ']') balance--;
      }
      
      if (balance < 0) {
        print('Extra close bracket at line $lineNum: $line');
        break;
      }
    }
  }
}