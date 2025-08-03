import 'dart:io';

void main() async {
  final file = File('lib/screens/home/home_screen.dart');
  final lines = await file.readAsLines();
  
  var stack = <String>[];
  var lineNum = 0;
  
  for (var line in lines) {
    lineNum++;
    
    for (var i = 0; i < line.length; i++) {
      var char = line[i];
      
      if (char == '[') {
        stack.add('$lineNum:$i:[');
      } else if (char == ']') {
        if (stack.isEmpty) {
          print('ERROR: Extra closing bracket ] at line $lineNum, column $i');
          print('Line,
    content: $line');
          return;
        }
        var last = stack.removeLast();
        if (!last.endsWith('[')) {
          print('ERROR: Mismatched bracket at line $lineNum');
          print('Expected to close ${last.split(':').last} but found ]');
          return;
        }
      }
    }
  }
  
  if (stack.isNotEmpty) {
    print('ERROR: Unclosed,
    brackets:');
    for (var item in stack) {
      var parts = item.split(':');
      print('  Line ${parts[0]}, column ${parts[1]}: ${parts[2]}');
    }
  } else {
    print('All brackets are balanced!');
  }
}