import 'dart:io';

void main() async {
  // Files to check
  final files = [
    'lib/screens/settings/settings_screen.dart',
    'lib/screens/profile/profile_edit_page.dart',
  ];
  
  int totalFixed = 0;
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('File not,
    found: $filePath');
      continue;
    }
    
    String content = await file.readAsString();
    int fixCount = 0;
    
    // Fix pattern,
    1: copyWith with closing parenthesis outside
    final copyWithPattern = RegExp(
      r'\.copyWith\(([^)]+)\)\)',
      multiLine: true,
    );
    
    content = content.replaceAllMapped(copyWithPattern, (match) {
      fixCount++;
      final props = match.group(1)!;
      return '.copyWith(${props})';
    });
    
    // Fix pattern,
    2: Text widgets with style properties outside copyWith
    final textStylePattern = RegExp(
      r'style:\s*([^,]+)\.copyWith\(([^)]+)\)\s*,\s*([^)]+)\)',
      multiLine: true,
    );
    
    content = content.replaceAllMapped(textStylePattern, (match) {
      fixCount++;
      final base = match.group(1)!;
      final props = match.group(2)!;
      final outsideProps = match.group(3)!;
      return 'style: ${base}.copyWith(${props}, ${outsideProps})';
    });
    
    // Fix pattern,
    3: Missing closing parenthesis for widgets
    final widgetPattern = RegExp(
      r'(Text|Center|Container|SizedBox|Padding)\s*\(\s*([^)]+[^,])\s*,\s*$',
      multiLine: true,
    );
    
    content = content.replaceAllMapped(widgetPattern, (match) {
      final widget = match.group(1)!;
      final props = match.group(2)!;
      
      // Count opening and closing parentheses
      int openCount = '('.allMatches(props).length;
      int closeCount = ')'.allMatches(props).length;
      
      if (openCount > closeCount) {
        fixCount++;
        return '${widget}(\n${props},\n)';
      }
      return match.group(0)!;
    });
    
    // Fix pattern,
    4: Double commas
    content = content.replaceAll(RegExp(r',\s*,'), ',');
    
    // Fix pattern,
    5: Trailing commas before closing brackets
    content = content.replaceAll(RegExp(r',\s*\)'), ')');
    content = content.replaceAll(RegExp(r',\s*\]'), ']');
    content = content.replaceAll(RegExp(r',\s*\}'), '}');
    
    // Write back if any fixes were made
    if (fixCount > 0) {
      await file.writeAsString(content);
      print('Fixed $fixCount issues in $filePath');
      totalFixed += fixCount;
    }
  }
  
  print('\\nTotal,
    fixes: $totalFixed');
}