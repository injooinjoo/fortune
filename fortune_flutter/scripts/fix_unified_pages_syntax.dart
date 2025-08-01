import 'dart:io';

void main() async {
  print('🔧 Fixing unified pages syntax issues...');
  
  // Fix face_reading_unified_page.dart
  await fixFaceReadingPage();
  
  // Then fix the other unified pages that have similar issues
  await fixOtherUnifiedPages();
  
  print('✅ All syntax fixes completed!');
}

Future<void> fixFaceReadingPage() async {
  print('\n📝 Fixing face_reading_unified_page.dart...');
  
  final file = File('lib/features/fortune/presentation/pages/face_reading_unified_page.dart');
  if (!file.existsSync()) return;
  
  var content = await file.readAsString();
  
  // The main issue is missing parentheses in various places
  // We need to be careful and fix specific patterns
  
  // Fix patterns where textAlign: TextAlign.center) is missing a comma
  content = content.replaceAll(
    'textAlign: TextAlign.center)',
    'textAlign: TextAlign.center),'
  );
  
  await file.writeAsString(content);
  print('  ✓ Fixed face_reading_unified_page.dart');
}

Future<void> fixOtherUnifiedPages() async {
  print('\n📝 Fixing other unified pages...');
  
  final files = [
    'lib/features/fortune/presentation/pages/health_sports_unified_page.dart',
    'lib/features/fortune/presentation/pages/pet_fortune_unified_page.dart',
    'lib/features/fortune/presentation/pages/personality_fortune_unified_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix common patterns
    content = _fixCommonPatterns(content);
    
    // Ensure widget lists are properly closed
    content = _fixWidgetListClosures(content);
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed $filePath');
    }
  }
}

String _fixCommonPatterns(String content) {
  // Fix missing commas after Text widgets with textAlign
  content = content.replaceAllMapped(
    RegExp(r'(textAlign:\s*TextAlign\.\w+)\)(\s*(?:SizedBox|Container|Text|Icon|Row|Column|\]|\}))'),
    (match) {
      final alignPart = match.group(1)!;
      final nextPart = match.group(2)!;
      
      // Check if it needs a comma
      if (nextPart.trim().startsWith(']') || nextPart.trim().startsWith('}')) {
        return '$alignPart),$nextPart';
      } else if (!nextPart.trim().isEmpty) {
        return '$alignPart),$nextPart';
      }
      return match.group(0)!;
    }
  );
  
  // Fix missing closing brackets for Row/Column children
  content = content.replaceAllMapped(
    RegExp(r'(children:\s*\[[^]]+style:\s*Theme\.of\(context\)\.textTheme\.\w+)\),(\s*\),)'),
    (match) {
      return '${match.group(1)!}),],${match.group(2)!}';
    }
  );
  
  // Fix double closing parentheses that should have a bracket
  content = content.replaceAll('))),', ')],),');
  
  return content;
}

String _fixWidgetListClosures(String content) {
  // This is more complex - we need to ensure children: [ ... ] are properly closed
  final lines = content.split('\n');
  final fixedLines = <String>[];
  
  var inChildrenList = false;
  var childrenBracketDepth = 0;
  var parenthesisDepth = 0;
  
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    
    // Track when we enter a children list
    if (line.contains('children: [')) {
      inChildrenList = true;
      childrenBracketDepth = 1;
      parenthesisDepth = 0;
    }
    
    if (inChildrenList) {
      // Count brackets and parentheses
      for (final char in line.split('')) {
        if (char == '[') childrenBracketDepth++;
        if (char == ']') childrenBracketDepth--;
        if (char == '(') parenthesisDepth++;
        if (char == ')') parenthesisDepth--;
      }
      
      // If we're back to depth 0, we've closed the children list
      if (childrenBracketDepth == 0) {
        inChildrenList = false;
        
        // Check if the line needs fixing
        if (line.trim().endsWith('),') && !line.contains('],')) {
          // This might be a case where ], is missing
          line = line.replaceFirst('),', '],),');
        }
      }
    }
    
    fixedLines.add(line);
  }
  
  return fixedLines.join('\n');
}