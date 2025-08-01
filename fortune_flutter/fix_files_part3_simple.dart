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
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.trim())
      .where((path) => path.startsWith('lib/') && path.endsWith('.dart'))
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
  // Fix 1: Fix trailing malformed syntax patterns from previous attempts
  content = content.replaceAll(RegExp(r'\)\$1\)'), '))');
  content = content.replaceAll(RegExp(r'\$1\)'), ')');
  content = content.replaceAll(RegExp(r'\$1,'), ',');
  content = content.replaceAll(RegExp(r'\$1'), '');
  
  // Fix 2: Fix appBar property syntax issues
  content = content.replaceAllMapped(
    RegExp(r'AppBar\(\s*([^}]+?)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'AppBar(\n        ${match.group(1)?.trim()},\n      ),\n      ${match.group(2)}:',
  );
  
  // Fix 3: Fix backgroundColor and elevation syntax
  content = content.replaceAllMapped(
    RegExp(r'backgroundColor:\s*([^,\n)]+)\)\s*elevation:'),
    (match) => 'backgroundColor: ${match.group(1)?.trim()},\n        elevation:',
  );
  
  // Fix 4: Fix leading IconButton syntax
  content = content.replaceAllMapped(
    RegExp(r'leading:\s*IconButton\(\s*([^}]+?)\)\s*onPressed:'),
    (match) => 'leading: IconButton(\n          ${match.group(1)?.trim()},\n          onPressed:',
  );
  
  // Fix 5: Fix title Text widget syntax
  content = content.replaceAllMapped(
    RegExp(r'title:\s*Text\(\s*([^}]+?)\)\s*style:'),
    (match) => 'title: Text(\n          ${match.group(1)?.trim()},\n          style:',
  );
  
  // Fix 6: Fix margin and padding syntax
  content = content.replaceAllMapped(
    RegExp(r'(margin|padding):\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(1)}: ${match.group(2)?.trim()}),\n        ${match.group(3)}:',
  );
  
  // Fix 7: Fix decoration BoxDecoration syntax
  content = content.replaceAllMapped(
    RegExp(r'decoration:\s*BoxDecoration\(\s*([^}]+?)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'decoration: BoxDecoration(\n          ${match.group(1)?.trim()},\n        ),\n        ${match.group(2)}:',
  );
  
  // Fix 8: Fix color withValues syntax
  content = content.replaceAllMapped(
    RegExp(r'color:\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'color: ${match.group(1)?.trim()}),\n        ${match.group(2)}:',
  );
  
  // Fix 9: Fix borderRadius syntax
  content = content.replaceAllMapped(
    RegExp(r'borderRadius:\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'borderRadius: ${match.group(1)?.trim()}),\n        ${match.group(2)}:',
  );
  
  // Fix 10: Fix boxShadow list syntax
  content = content.replaceAllMapped(
    RegExp(r'boxShadow:\s*\[\s*BoxShadow\(\s*([^}]+?)\)\s*\]\s*\)\s*([a-zA-Z_]\w*):'),
    (match) => 'boxShadow: [\n                  BoxShadow(\n                    ${match.group(1)?.trim()},\n                  ),\n                ],\n              ),\n              ${match.group(2)}:',
  );
  
  // Fix 11: Fix child Column syntax
  content = content.replaceAllMapped(
    RegExp(r'child:\s*Column\(\s*([^}]+?)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'child: Column(\n                ${match.group(1)?.trim()},\n              ),\n              ${match.group(2)}:',
  );
  
  // Fix 12: Fix Container padding syntax
  content = content.replaceAllMapped(
    RegExp(r'Container\(\s*padding:\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'Container(\n                    padding: ${match.group(1)?.trim()}),\n                    ${match.group(2)}:',
  );
  
  // Fix 13: Fix crossAxisAlignment syntax
  content = content.replaceAllMapped(
    RegExp(r'crossAxisAlignment:\s*([^,\n)]+)\)\s*children:'),
    (match) => 'crossAxisAlignment: ${match.group(1)?.trim()},\n                children:',
  );
  
  // Fix 14: Fix Row children syntax
  content = content.replaceAllMapped(
    RegExp(r'children:\s*\[\s*Text\(\s*([^}]+?)\)\s*style:'),
    (match) => 'children: [\n                        Text(\n                          ${match.group(1)?.trim()},\n                          style:',
  );
  
  // Fix 15: Fix Switch widget syntax
  content = content.replaceAllMapped(
    RegExp(r'trailing:\s*Switch\(\s*([^}]+?)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'trailing: Switch(\n                      ${match.group(1)?.trim()},\n                    ),\n                    ${match.group(2)}:',
  );
  
  // Fix 16: Fix onChanged callback syntax
  content = content.replaceAllMapped(
    RegExp(r'onChanged:\s*\([^}]+?\}\s*([a-zA-Z_]\w*):'),
    (match) => 'onChanged: (value) {\n                        ${match.group(0)?.split('}')[0].split('{')[1]?.trim()}\n                      },\n                      ${match.group(1)}:',
  );
  
  // Fix 17: Fix method parameter trailing syntax
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\?\s*([a-zA-Z_]\w*),\s*bool\s+([a-zA-Z_]\w*)\s*=\s*false\)\s*bool\s+([a-zA-Z_]\w*)\s*=\s*false\)'),
    (match) => '${match.group(1)}? ${match.group(2)},\n    bool ${match.group(3)} = false,\n    bool ${match.group(4)} = false,\n  )',
  );
  
  // Fix 18: Fix onTap callback syntax
  content = content.replaceAllMapped(
    RegExp(r'onTap:\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'onTap: ${match.group(1)?.trim()}),\n      ${match.group(2)}:',
  );
  
  // Fix 19: Fix border bottom syntax
  content = content.replaceAllMapped(
    RegExp(r'bottom:\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'bottom: ${match.group(1)?.trim()}),\n                ${match.group(2)}:',
  );
  
  // Fix 20: Fix width and height syntax
  content = content.replaceAllMapped(
    RegExp(r'(width|height):\s*([^,\n)]+)\)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(1)}: ${match.group(2)?.trim()}),\n              ${match.group(3)}:',
  );
  
  // Fix 21: Fix Icon widget syntax
  content = content.replaceAllMapped(
    RegExp(r'child:\s*Icon\(\s*([^}]+?)\)\s*([a-zA-Z_]\w*):'),
    (match) => 'child: Icon(\n                ${match.group(1)?.trim()},\n              ),\n              ${match.group(2)}:',
  );
  
  // Fix 22: Fix duplicated closing parentheses
  content = content.replaceAll(RegExp(r'\)\s*\)\s*([,;])'), ')${r'$1'}');
  content = content.replaceAll(RegExp(r',\s*,'), ',');
  
  // Fix 23: Fix theme copyWith syntax
  content = content.replaceAllMapped(
    RegExp(r'style:\s*([^}]+?)\.copyWith\(\s*([^}]+?)\)\s*([,\)])'),
    (match) => 'style: ${match.group(1)?.trim()}.copyWith(\n                            ${match.group(2)?.trim()},\n                          )${match.group(3)}',
  );
  
  // Fix 24: Fix function parameter definitions
  content = content.replaceAllMapped(
    RegExp(r'VoidCallback\?\s*onTap\)\s*bool\s+([a-zA-Z_]\w*)\s*=\s*false\)\s*bool\s+([a-zA-Z_]\w*)\s*=\s*false\)'),
    (match) => 'VoidCallback? onTap,\n    bool ${match.group(1)} = false,\n    bool ${match.group(2)} = false,\n  )',
  );
  
  // Fix 25: General trailing parentheses cleanup
  content = content.replaceAllMapped(
    RegExp(r'\)\s*([a-zA-Z_]\w*):'),
    (match) => '),\n        ${match.group(1)}:',
  );
  
  return content;
}