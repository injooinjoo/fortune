import 'dart:io';

void main() async {
  print('Fixing bracket matching errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/mbti_fortune_page.dart',
    'lib/features/fortune/presentation/pages/traditional_fortune_result_page.dart',
    'lib/features/fortune/presentation/pages/daily_inspiration_page.dart',
    'lib/presentation/widgets/enhanced_shareable_fortune_card.dart',
    'lib/features/fortune/presentation/widgets/fortune_display.dart',
  ];
  
  for (final filePath in files) {
    await analyzeAndFixFile(filePath);
  }
  
  print('\n✅ Bracket analysis complete!');
}

Future<void> analyzeAndFixFile(String filePath) async {
  final file = File(filePath);
  
  if (!await file.exists()) {
    print('Warning: File not,
    found: $filePath');
    return;
  }
  
  print('\nAnalyzing $filePath...');
  
  try {
    final lines = await file.readAsLines();
    final issues = <String>[];
    
    // Track bracket counts
    int brackets = 0;
    int parens = 0;
    int braces = 0;
    
    // Track lines where issues might be
    final problemLines = <int>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;
      
      // Count brackets
      brackets += line.split('[').length - 1;
      brackets -= line.split(']').length - 1;
      
      // Count parentheses
      parens += line.split('(').length - 1;
      parens -= line.split(')').length - 1;
      
      // Count braces
      braces += line.split('{').length - 1;
      braces -= line.split('}').length - 1;
      
      // Check for common patterns that cause issues
      if (line.contains('),') && line.contains('style:') && line.contains('Theme.of(context)')) {
        // Common,
    pattern: extra closing parenthesis after style
        if (countChar(line, ')') > countChar(line, '(')) {
          issues.add('Line $lineNum: Possible extra ) in style declaration');
          problemLines.add(lineNum);
        }
      }
      
      // Check for misplaced commas and parentheses
      if (line.trim().endsWith('),') && !line.contains('(')) {
        issues.add('Line $lineNum: Closing ), without opening (');
        problemLines.add(lineNum);
      }
      
      // Check for double closing
      if (line.contains(')),') || line.contains(']],') || line.contains('}},')) {
        issues.add('Line $lineNum: Possible double closing brackets');
        problemLines.add(lineNum);
      }
    }
    
    print('Final counts - Brackets: $brackets, Parens: $parens, Braces: $braces');
    
    if (issues.isNotEmpty) {
      print('Issues,
    found:');
      for (final issue in issues) {
        print('  $issue');
      }
      
      // Show context around problem lines
      for (final lineNum in problemLines.take(5)) {
        print('\n  Context around line $lineNum:');
        for (int i = lineNum - 3; i <= lineNum + 2 && i > 0 && i <= lines.length; i++) {
          final prefix = i == lineNum ? '>>> ' : '    ';
          print('  $prefix$i: ${lines[i - 1]}');
        }
      }
    } else if (brackets != 0 || parens != 0 || braces != 0) {
      print('No specific issues found, but counts are unbalanced.');
      print('This might indicate missing brackets at the end of the file.');
    } else {
      print('No bracket issues found.');
    }
    
  } catch (e) {
    print('Error analyzing $filePath: $e');
  }
}

int countChar(String str, String char) {
  return str.split(char).length - 1;
}