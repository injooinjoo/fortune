#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing Flutter syntax errors for 97 files in error_files_part3.txt...');
  
  // Read the file list
  final errorListFile = File('error_files_part3.txt');
  if (!errorListFile.existsSync()) {
    print('❌ Error: error_files_part3.txt not found');
    exit(1);
  }
  
  final lines = await errorListFile.readAsLines();
  final filePaths = lines
      .where((line) => line.trim().isNotEmpty && line.contains('→'))
      .map((line) => line.split('→')[1].trim())
      .where((path) => path.isNotEmpty)
      .toList();
  
  print('📂 Found ${filePaths.length} files to fix');
  
  int successCount = 0;
  int errorCount = 0;
  
  for (int i = 0; i < filePaths.length; i++) {
    final filePath = filePaths[i];
    print('🔄 [${i + 1}/${filePaths.length}] Fixing: $filePath');
    
    final file = File(filePath);
    if (!file.existsSync()) {
      print('   ❌ File not found: $filePath');
      errorCount++;
      continue;
    }
    
    try {
      String content = await file.readAsString();
      String originalContent = content;
      
      // Apply comprehensive syntax fixes
      content = applySyntaxFixes(content);
      
      // Only write if content changed
      if (content != originalContent) {
        await file.writeAsString(content);
        print('   ✅ Fixed syntax errors');
      } else {
        print('   ℹ️  No changes needed');
      }
      
      successCount++;
    } catch (e) {
      print('   ❌ Error: $e');
      errorCount++;
    }
  }
  
  print('\n📊 Summary:');
  print('✅ Successfully processed: $successCount files');
  print('❌ Errors encountered: $errorCount files');
  print('📈 Success rate: ${((successCount / filePaths.length) * 100).toStringAsFixed(1)}%');
}

String applySyntaxFixes(String content) {
  // Fix 1: Missing closing parentheses in widget properties and method calls
  content = content.replaceAllMapped(
    RegExp(r'(\w+):\s*([^,\n\)]+),?\s*\n\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(1)}: ${match.group(2)},\n        ${match.group(3)}:',
  );
  
  // Fix 2: Fix AppBar properties syntax
  content = content.replaceAllMapped(
    RegExp(r'AppBar\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'AppBar(\n        ${match.group(1)},\n      ),\n      ${match.group(2)}:',
  );
  
  // Fix 3: Fix trailing commas and parentheses issues
  content = content.replaceAllMapped(
    RegExp(r'\)\s*\)\s*([,;])'),
    (match) => ')${match.group(1)}',
  );
  content = content.replaceAllMapped(
    RegExp(r'\)\s*([a-zA-Z_]\w*):'),
    (match) => '),\n        ${match.group(1)}:',
  );
  
  // Fix 4: Fix Container and widget constructor syntax
  content = content.replaceAllMapped(
    RegExp(r'Container\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'Container(\n        ${match.group(1)},\n      ),\n      ${match.group(2)}:',
  );
  
  // Fix 5: Fix BoxDecoration syntax issues
  content = content.replaceAllMapped(
    RegExp(r'BoxDecoration\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'BoxDecoration(\n          ${match.group(1)},\n        ),\n        ${match.group(2)}:',
  );
  
  // Fix 6: Fix method calls and trailing syntax
  content = content.replaceAllMapped(
    RegExp(r'\.\w+\([^)]*\)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(0)!.replaceAllMapped(RegExp(r'\)\s*([a-zA-Z_]\w*):'), (m) => '),\n        ${m.group(1)}:')}',
  );
  
  // Fix 7: Fix widget parameter alignment
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\(\s*([^)]+)\)\s*child:'),
    (match) => '${match.group(1)}(\n        ${match.group(2)},\n      ),\n      child:',
  );
  
  // Fix 8: Fix IconButton and similar widget syntax
  content = content.replaceAllMapped(
    RegExp(r'IconButton\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'IconButton(\n          ${match.group(1)},\n        ),\n        ${match.group(2)}:',
  );
  
  // Fix 9: Fix Switch and similar widgets
  content = content.replaceAllMapped(
    RegExp(r'Switch\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'Switch(\n            ${match.group(1)},\n          ),\n          ${match.group(2)}:',
  );
  
  // Fix 10: Fix Text widget syntax issues
  content = content.replaceAllMapped(
    RegExp(r'Text\(\s*([^)]+)\)\s*style:'),
    (match) => 'Text(\n          ${match.group(1)},\n          style:',
  );
  
  // Fix 11: Fix theme and style method calls
  content = content.replaceAllMapped(
    RegExp(r'\.copyWith\(\s*([^)]+)\)\s*([,\)])'),
    (match) => '.copyWith(\n            ${match.group(1)}\n          )${match.group(2)}',
  );
  
  // Fix 12: Fix EdgeInsets and padding syntax
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.(\w+)\([^)]*\)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(0)!.replaceAllMapped(RegExp(r'\)\s*([a-zA-Z_]\w*):'), (m) => '),\n        ${m.group(1)}:')}',
  );
  
  // Fix 13: Fix showDialog and showModalBottomSheet syntax
  content = content.replaceAllMapped(
    RegExp(r'show(Dialog|ModalBottomSheet)\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'show${match.group(1)}(\n        ${match.group(2)},\n      ),\n      ${match.group(3)}:',
  );
  
  // Fix 14: Fix BorderRadius and similar constructors
  content = content.replaceAllMapped(
    RegExp(r'BorderRadius\.(\w+)\([^)]*\)\s*([,\)])'),
    (match) => '${match.group(0)!.replaceAllMapped(RegExp(r'\)\s*([,\)])'), (m) => ')${m.group(1)}')}',
  );
  
  // Fix 15: Fix trailing characters and malformed syntax
  content = content.replaceAll(RegExp(r'\)\$1\)'), '))');
  content = content.replaceAll(RegExp(r'\$1\)'), ')');
  content = content.replaceAll(RegExp(r'\$1,'), ',');
  content = content.replaceAll(RegExp(r'\$1'), '');
  
  // Fix 16: Fix margin and padding property syntax
  content = content.replaceAllMapped(
    RegExp(r'(margin|padding):\s*([^,\n]+)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(1)}: ${match.group(2)},\n        ${match.group(3)}:',
  );
  
  // Fix 17: Fix method chaining syntax issues
  content = content.replaceAllMapped(
    RegExp(r'\.withValues\([^)]*\)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(0)!.replaceAllMapped(RegExp(r'\)\s*([a-zA-Z_]\w*):'), (m) => '),\n        ${m.group(1)}:')}',
  );
  
  // Fix 18: Fix onPressed and callback syntax
  content = content.replaceAllMapped(
    RegExp(r'onPressed:\s*([^,\n]+)\s*([a-zA-Z_]\w*):'),
    (match) => 'onPressed: ${match.group(1)},\n        ${match.group(2)}:',
  );
  
  // Fix 19: Fix conditional expressions and widget rendering
  content = content.replaceAllMapped(
    RegExp(r'if\s*\([^)]+\)\s*([^,\n]+)\s*([a-zA-Z_]\w*):'),
    (match) => 'if (${match.group(1)!.replaceFirst('if (', '').replaceFirst(')', '')}) ${match.group(1)},\n        ${match.group(2)}:',
  );
  
  // Fix 20: Fix ListView and similar scroll widgets
  content = content.replaceAllMapped(
    RegExp(r'ListView\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'ListView(\n          ${match.group(1)},\n        ),\n        ${match.group(2)}:',
  );
  
  // Fix 21: Fix AlertDialog and dialog widgets
  content = content.replaceAllMapped(
    RegExp(r'AlertDialog\(\s*([^)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'AlertDialog(\n        ${match.group(1)},\n      ),\n      ${match.group(2)}:',
  );
  
  // Fix 22: Fix trailing comma issues in lists and widgets
  content = content.replaceAll(RegExp(r',\s*,'), ',');
  content = content.replaceAll(RegExp(r':\s*,'), ':');
  
  // Fix 23: Fix specific Flutter 3.24 withValues() syntax
  content = content.replaceAllMapped(
    RegExp(r'\.withValues\(alpha:\s*([^)]+)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})',
  );
  
  // Fix 24: Fix function parameter syntax
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\?\s*([a-zA-Z_]\w*),'),
    (match) => '${match.group(1)}? ${match.group(2)},',
  );
  
  // Fix 25: Fix specific widget constructor issues
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\(\s*([^)]+)\s*\)\s*\)\s*([,;])'),
    (match) => '${match.group(1)}(\n        ${match.group(2)}\n      )${match.group(3)}',
  );
  
  return content;
}