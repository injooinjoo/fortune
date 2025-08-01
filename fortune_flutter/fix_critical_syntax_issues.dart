#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing critical syntax issues identified by analyzer...');
  
  // List of critical files with specific syntax errors
  final criticalFiles = [
    'lib/presentation/providers/navigation_visibility_provider.dart',
    'lib/presentation/providers/fortune_recommendation_provider.dart', 
    'lib/presentation/providers/fortune_provider.dart',
    'lib/presentation/providers/celebrity_provider.dart',
    'lib/screens/settings/settings_screen.dart',
  ];
  
  int successCount = 0;
  int errorCount = 0;
  
  for (int i = 0; i < criticalFiles.length; i++) {
    final filePath = criticalFiles[i];
    print('🔄 [${i + 1}/${criticalFiles.length}] Fixing: $filePath');
    
    final file = File(filePath);
    if (!file.existsSync()) {
      print('   ❌ File not found: $filePath');
      errorCount++;
      continue;
    }
    
    try {
      String content = await file.readAsString();
      String originalContent = content;
      
      // Apply critical syntax fixes
      content = fixCriticalSyntaxIssues(content, filePath);
      
      // Only write if content changed
      if (content != originalContent) {
        await file.writeAsString(content);
        print('   ✅ Fixed critical syntax errors');
      } else {
        print('   ℹ️  No critical changes needed');
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
}

String fixCriticalSyntaxIssues(String content, String filePath) {
  // Fix 1: Constructor parameter formatting issues
  content = content.replaceAllMapped(
    RegExp(r'const\s+(\w+)\(\{\s*([^}]+)\s*\)\s*\}\);'),
    (match) => 'const ${match.group(1)}({\n    ${match.group(2)?.trim()}\n  });',
  );
  
  // Fix 2: copyWith method parameter closing
  content = content.replaceAllMapped(
    RegExp(r'copyWith\(\{\s*([^}]+)\s*\},?\s*\)\s*\}\)'),
    (match) => 'copyWith({\n    ${match.group(1)?.trim()},\n  }) {',
  );
  
  // Fix 3: Fix missing closing parentheses in constructor calls
  content = content.replaceAllMapped(
    RegExp(r'super\(const\s+(\w+)\(\);'),
    (match) => 'super(const ${match.group(1)}());',
  );
  
  // Fix 4: Fix tuple access syntax
  content = content.replaceAll('pair., pair.\$2', 'pair.\$1, pair.\$2');
  
  // Fix 5: Fix provider definition syntax
  content = content.replaceAllMapped(
    RegExp(r'final\s+(\w+)\s*=\s*StateNotifierProvider[^(]*\(\s*\(ref\)\s*=>\s*([^)]+)\s*\)\s*'),
    (match) => 'final ${match.group(1)} = StateNotifierProvider((ref) => ${match.group(2)?.trim()});',
  );
  
  // Fix 6: Fix constructor parameter lists with trailing commas
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\(\s*\{\s*([^}]+)\s*,\s*\)\s*\}\)'),
    (match) => '${match.group(1)}({\n    ${match.group(2)?.trim()}\n  })',
  );
  
  // Fix 7: Fix method return statements
  content = content.replaceAllMapped(
    RegExp(r'return\s+(\w+)\(\s*([^)]+)\s*\)\s*,?\s*([^}]*)\s*\)\s*\}'),
    (match) => 'return ${match.group(1)}(\n      ${match.group(2)?.trim()}${match.group(3)?.isNotEmpty == true ? ',\n      ${match.group(3)?.trim()}' : ''}\n    );\n  }',
  );
  
  // Fix 8: Fix specific critical patterns based on the file
  if (filePath.contains('navigation_visibility_provider')) {
    // Fix NavigationVisibilityState copyWith method
    content = content.replaceAll(
      'copyWith({\n    bool? isVisible,\n    bool? isAnimating,\n  ),\n  }) {',
      'copyWith({\n    bool? isVisible,\n    bool? isAnimating,\n  }) {',
    );
    
    // Fix return statement in copyWith
    content = content.replaceAll(
      'return NavigationVisibilityState(\n    isVisible: isVisible ?? this.isVisible,\n      isAnimating: isAnimating ?? this.isAnimating,\n  )}',
      'return NavigationVisibilityState(\n      isVisible: isVisible ?? this.isVisible,\n      isAnimating: isAnimating ?? this.isAnimating,\n    );\n  }',
    );
    
    // Fix CelebrityFilterNotifier constructor
    content = content.replaceAll('CelebrityFilterNotifier() : super(CelebrityFilter();', 'CelebrityFilterNotifier() : super(CelebrityFilter());');
  }
  
  if (filePath.contains('celebrity_provider')) {
    // Fix search method parameters
    content = content.replaceAll(
      'void search(\n    {\n    String? query,\n    CelebrityFilter? filter,\n  }}) {',
      'void search({\n    String? query,\n    CelebrityFilter? filter,\n  }) {',
    );
    
    // Fix service calls
    content = content.replaceAll(
      'state = _service.searchCelebrities(\n      query: query),\n        filter: filter);',
      'state = _service.searchCelebrities(\n      query: query,\n      filter: filter,\n    );',
    );
  }
  
  if (filePath.contains('settings_screen.dart')) {
    // Fix broken widget constructor chains - this file has severe formatting issues
    content = fixSettingsScreenSyntax(content);
  }
  
  // Fix 9: Remove broken parameter syntax
  content = content.replaceAll(RegExp(r',\s*\)\s*\}'), '\n  }');
  content = content.replaceAll(RegExp(r'\)\s*\}'), ');\n  }');
  
  return content;
}

String fixSettingsScreenSyntax(String content) {
  // This file has very complex broken syntax - let's read the original and fix the key issues
  
  // Fix AppBar constructor
  content = content.replaceAllMapped(
    RegExp(r'appBar:\s*AppBar\([^)]*backgroundColor:\s*Colors\.transparent[^)]*\)\s*[^,]*,'),
    (match) => '''appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '설정',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),''',
  );
  
  // Fix body structure
  content = content.replaceAllMapped(
    RegExp(r'body:\s*SingleChildScrollView[^{]*\{[^}]*child:\s*Column[^{]*\{[^}]*children:\s*\['),
    (match) => '''body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [''',
  );
  
  return content;
}