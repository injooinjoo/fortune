#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing remaining syntax issues from part 3 fixes...');
  
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
  
  print('📂 Processing ${filePaths.length} files for remaining syntax fixes');
  
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
      
      // Apply remaining syntax fixes
      content = fixRemainingSyntaxIssues(content);
      
      // Only write if content changed
      if (content != originalContent) {
        await file.writeAsString(content);
        print('   ✅ Fixed remaining syntax errors');
      } else {
        print('   ℹ️  No additional changes needed');
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

String fixRemainingSyntaxIssues(String content) {
  // Fix 1: Remove leftover $1 artifacts
  content = content.replaceAll(RegExp(r'\$1'), '');
  
  // Fix 2: Fix missing commas in constructors
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\(\s*([^)]+)\s*\)\s*\}'),
    (match) => '${match.group(1)}(\n    ${match.group(2)?.trim()},\n  )}',
  );
  
  // Fix 3: Fix copyWith method syntax
  content = content.replaceAllMapped(
    RegExp(r'copyWith\(\s*\{\s*([^}]+)\s*\}\s*\)\s*\{\s*return'),
    (match) => 'copyWith({\n    ${match.group(1)?.trim()},\n  }) {\n    return',
  );
  
  // Fix 4: Fix NavigationVisibilityState constructor
  content = content.replaceAllMapped(
    RegExp(r'NavigationVisibilityState\(\s*\{\s*([^}]+)\s*\)\s*\}\s*\);'),
    (match) => 'NavigationVisibilityState({\n    ${match.group(1)?.trim()}\n  });',
  );
  
  // Fix 5: Fix super constructor calls
  content = content.replaceAllMapped(
    RegExp(r'super\(const\s+(\w+)\(\s*\);'),
    (match) => 'super(const ${match.group(1)}());',
  );
  
  // Fix 6: Fix missing commas after parameters
  content = content.replaceAllMapped(
    RegExp(r'([a-zA-Z_]\w*):\s*([^,\n]+)\s*([a-zA-Z_]\w*):'),
    (match) => '${match.group(1)}: ${match.group(2)?.trim()},\n      ${match.group(3)}:',
  );
  
  // Fix 7: Fix method parameter lists
  content = content.replaceAllMapped(
    RegExp(r'(\w+\?)\s*([a-zA-Z_]\w*)\s*\)\s*\{\s*return'),
    (match) => '${match.group(1)} ${match.group(2)}\n  }) {\n    return',
  );
  
  // Fix 8: Fix constructor parameter formatting
  content = content.replaceAllMapped(
    RegExp(r'this\.(\w+)\s*=\s*([^,\n]+),?\s*this\.(\w+)\s*=\s*([^,\n}]+)\s*\)'),
    (match) => 'this.${match.group(1)} = ${match.group(2)?.trim()},\n    this.${match.group(3)} = ${match.group(4)?.trim()},\n  )',
  );
  
  // Fix 9: Fix StateNotifier constructor calls
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\(\)\s*:\s*super\(([^)]+)\);'),
    (match) => '${match.group(1)}() : super(${match.group(2)?.trim()});',
  );
  
  // Fix 10: Fix provider definitions
  content = content.replaceAllMapped(
    RegExp(r'final\s+(\w+)\s*=\s*StateNotifierProvider[^(]*\(\s*\(ref\)\s*=>\s*([^)]+)\s*\)\s*\$1'),
    (match) => 'final ${match.group(1)} = StateNotifierProvider((ref) => ${match.group(2)?.trim()});',
  );
  
  // Fix 11: Fix method calls with missing commas
  content = content.replaceAllMapped(
    RegExp(r'\.(\w+)\(\s*([^)]+)\s*\)\s*([a-zA-Z_]\w*):'),
    (match) => '.${match.group(1)}(\n        ${match.group(2)?.trim()}\n      ),\n      ${match.group(3)}:',
  );
  
  // Fix 12: Fix tuple access syntax
  content = content.replaceAllMapped(
    RegExp(r'pair\.\s*,\s*pair\.\$2'),
    (match) => 'pair.\$1, pair.\$2',
  );
  
  // Fix 13: Fix filter constructor calls
  content = content.replaceAllMapped(
    RegExp(r'CelebrityFilter\(\s*([^)]+)\s*\)\s*([a-zA-Z_]\w*):'),
    (match) => 'CelebrityFilter(\n      ${match.group(1)?.trim()},\n    ),\n        ${match.group(2)}:',
  );
  
  // Fix 14: Fix missing commas in parameter lists
  content = content.replaceAllMapped(
    RegExp(r'(\w+):\s*([^,\n]+)\s*([a-zA-Z_]\w+):\s*([^,\n]+),'),
    (match) => '${match.group(1)}: ${match.group(2)?.trim()},\n      ${match.group(3)}: ${match.group(4)?.trim()},',
  );
  
  // Fix 15: Fix trailing syntax issues
  content = content.replaceAllMapped(
    RegExp(r'\)\s*\)\s*([,;])'),
    (match) => ')${match.group(1)}',
  );
  content = content.replaceAll(RegExp(r',\s*,'), ',');
  content = content.replaceAll(RegExp(r':\s*,'), ':');
  
  return content;
}