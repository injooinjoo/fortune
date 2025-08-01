import 'dart:io';

void main() async {
  print('🔧 Starting critical syntax fixes for remaining issues...');
  
  // Files with critical syntax errors that need immediate fixing
  final criticalFiles = [
    // Provider files with remaining issues
    'lib/presentation/providers/celebrity_provider.dart',
    'lib/presentation/providers/fortune_provider.dart',
    'lib/presentation/providers/navigation_visibility_provider.dart',
    
    // Settings screen with major syntax issues
    'lib/screens/settings/settings_screen.dart',
    
    // Core constants files (discovered during build_runner)
    'lib/core/constants/tarot_metadata.dart',
    'lib/core/constants/tarot_card_orientation.dart', 
    'lib/core/constants/tarot_minor_arcana.dart',
    'lib/core/constants/fortune_metadata.dart',
    
    // Network and API files
    'lib/core/network/auth_api_client.dart',
    'lib/core/utils/format_utils.dart',
    
    // Service files
    'lib/services/analytics_tracker.dart',
    'lib/services/remote_config_service.dart',
  ];

  int totalProcessed = 0;
  int totalFixed = 0;

  for (final filePath in criticalFiles) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('⚠️  File not found: $filePath');
        continue;
      }

      String content = await file.readAsString();
      final originalContent = content;
      
      // Critical syntax fixes
      content = applyCriticalSyntaxFixes(content);
      
      if (content != originalContent) {
        await file.writeAsString(content);
        print('✅ Fixed: $filePath');
        totalFixed++;
      } else {
        print('ℹ️  No changes: $filePath');
      }
      
      totalProcessed++;
    } catch (e) {
      print('❌ Error processing $filePath: $e');
    }
  }

  print('\n📊 Summary:');
  print('   Files processed: $totalProcessed');
  print('   Files fixed: $totalFixed');
  print('   Success rate: ${totalProcessed > 0 ? ((totalFixed / totalProcessed) * 100).toStringAsFixed(1) : 0}%');
}

String applyCriticalSyntaxFixes(String content) {
  // 1. Fix broken provider constructor patterns
  content = content.replaceAllMapped(
    RegExp(r'CelebrityFilter\(\);'), 
    (match) => 'CelebrityFilter();'
  );
  
  // 2. Fix broken StateNotifierProvider declarations  
  content = content.replaceAllMapped(
    RegExp(r'StateNotifierProvider\(\(ref\)\s*=>\s*(\w+)\(\)\);'),
    (match) => 'StateNotifierProvider<${match.group(1)}, ${match.group(1) == 'NavigationVisibilityNotifier' ? 'NavigationVisibilityState' : 'dynamic'}>((ref) => ${match.group(1)}());'
  );

  // 3. Fix malformed method signatures and missing commas
  content = content.replaceAllMapped(
    RegExp(r'(\w+)\?\s*(\w+),\s*\}\s*\)\s*{'),
    (match) => '${match.group(1)}? ${match.group(2)},\n  }) {'
  );

  // 4. Fix broken copyWith method calls with extra parameters
  content = content.replaceAllMapped(
    RegExp(r'copyWith\(([^)]+)\),\s*([^)]+)\);'),
    (match) => 'copyWith(${match.group(1)});'
  );

  // 5. Fix malformed AppBar constructor in settings screen
  content = content.replaceAllMapped(
    RegExp(r'appBar:\s*AppBar\(\s*backgroundColor:\s*Colors\.transparent,\s*elevation:\s*0,\s*leading:\s*IconButton\(\s*icon:\s*Icon\([^)]+\),\s*onPressed:\s*[^,]+,\s*\),\s*title:\s*Text\(\s*[^,]+,\s*style:\s*[^,]+,\s*\),\s*\),\s*elevation:\s*0\),\s*leading:\s*IconButton\(,'),
    (match) => 'appBar: AppBar(\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        leading: IconButton(\n          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),\n          onPressed: () => context.pop(),\n        ),\n        title: Text(\n          \'설정\',\n          style: Theme.of(context).textTheme.titleLarge,\n        ),\n      ),'
  );

  // 6. Fix broken widget constructor chains
  content = content.replaceAllMapped(
    RegExp(r'body:\s*SingleChildScrollView\(,\s*child:\s*Column\(,\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*\),\s*children:\s*\['),
    (match) => 'body: SingleChildScrollView(\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: ['
  );

  // 7. Fix broken Container constructor chains  
  content = content.replaceAllMapped(
    RegExp(r'Container\(\s*margin:\s*([^)]+)\),\s*decoration:\s*BoxDecoration\(,\s*color:\s*([^,]+),\s*\),\s*borderRadius:\s*([^)]+)\),'),
    (match) => 'Container(\n              margin: ${match.group(1)},\n              decoration: BoxDecoration(\n                color: ${match.group(2)},\n                borderRadius: ${match.group(3)},\n              ),'
  );

  // 8. Fix broken withValues calls with malformed parameters
  content = content.replaceAllMapped(
    RegExp(r'withValues\(alph,\s*a:\s*([^)]+)\)'),
    (match) => 'withValues(alpha: ${match.group(1)})'
  );
  
  content = content.replaceAllMapped(
    RegExp(r'withValues\(alp,\s*ha:\s*([^)]+)\)'),
    (match) => 'withValues(alpha: ${match.group(1)})'
  );

  // 9. Fix broken Text widget constructors
  content = content.replaceAllMapped(
    RegExp(r'Text\(\s*\'([^\']+)\'\s*\),\s*style:\s*([^)]+)\.copyWith\(,\s*([^)]+)\s*\)\)\]?\}?'),
    (match) => 'Text(\n                          \'${match.group(1)}\',\n                          style: ${match.group(2)}.copyWith(${match.group(3)}),\n                        )'
  );

  // 10. Fix broken Row/Column constructor patterns
  content = content.replaceAllMapped(
    RegExp(r'child:\s*Row\(\s*children:\s*\[\s*Text\(\s*\'([^\']+)\'\s*\),\s*style:\s*([^)]+)\.copyWith\(,\s*([^)]+)\s*\)\)\]\)\)'),
    (match) => 'child: Row(\n                      children: [\n                        Text(\n                          \'${match.group(1)}\',\n                          style: ${match.group(2)}.copyWith(${match.group(3)}),\n                        ),\n                      ],\n                    ),\n                  )'
  );

  // 11. Fix malformed method parameter lists
  content = content.replaceAllMapped(
    RegExp(r'VoidCallback\?\s*onTap\)\s*bool\s*isFirst\s*=\s*false\)\s*bool\s*isLast\s*=\s*false\)'),
    (match) => 'VoidCallback? onTap,\n    bool isFirst = false,\n    bool isLast = false,'
  );

  // 12. Fix broken EdgeInsets and padding calls
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.symmetric\(horizont,\s*al:\s*([^,]+),\s*vertical:\s*([^)]+)\)'),
    (match) => 'EdgeInsets.symmetric(horizontal: ${match.group(1)}, vertical: ${match.group(2)})'
  );

  // 13. Fix broken BorderSide constructor calls
  content = content.replaceAllMapped(
    RegExp(r'const\s*BorderSide\(,\s*color:\s*([^,]+),\s*\),\s*width:\s*([^)]+)\)'),
    (match) => 'const BorderSide(color: ${match.group(1)}, width: ${match.group(2)})'
  );

  // 14. Fix broken Container width/height declarations
  content = content.replaceAllMapped(
    RegExp(r'width:\s*([^)]+)\),\s*height:\s*([^)]+)\),\s*decoration:'),
    (match) => 'width: ${match.group(1)},\n              height: ${match.group(2)},\n              decoration:'
  );

  // 15. Fix broken Icon constructor calls
  content = content.replaceAllMapped(
    RegExp(r'Icon\(\s*([^,]+),\s*\),\s*color:\s*([^,]+),\s*size:\s*([^)]+)\)'),
    (match) => 'Icon(\n                ${match.group(1)},\n                color: ${match.group(2)},\n                size: ${match.group(3)},\n              )'
  );

  // 16. Fix logger method calls with malformed parameters
  content = content.replaceAllMapped(
    RegExp(r'(\w+):\s*([^)]+)\)\s*([^}]+)\}\s*\)\s*;'),
    (match) => '${match.group(1)}: ${match.group(2)},${match.group(3)}},\n    );'
  );

  // 17. Fix broken OutlinedButton.styleFrom calls
  content = content.replaceAllMapped(
    RegExp(r'OutlinedButton\.styleFrom\(,\s*padding:\s*([^)]+)\),\s*side:\s*BorderSide\(colo,\s*r:\s*([^)]+)\),'),
    (match) => 'OutlinedButton.styleFrom(\n                    padding: ${match.group(1)},\n                    side: BorderSide(color: ${match.group(2)}),'
  );

  // 18. Fix broken RoundedRectangleBorder calls
  content = content.replaceAllMapped(
    RegExp(r'RoundedRectangleBorder\(,\s*borderRadius:\s*([^)]+)\)'),
    (match) => 'RoundedRectangleBorder(\n                      borderRadius: ${match.group(1)},\n                    )'
  );

  // 19. Fix malformed Text style chains
  content = content.replaceAllMapped(
    RegExp(r'Text\(\s*\'([^\']+)\'\),\s*style:\s*([^)]+)\.copyWith\(,\s*color:\s*([^,]+),\s*\)\)\)\)\)\)\)'),
    (match) => 'Text(\n                    \'${match.group(1)}\',\n                    style: ${match.group(2)}.copyWith(\n                      color: ${match.group(3)},\n                    ),\n                  )'
  );

  // 20. Fix broken copyWith method calls in providers
  content = content.replaceAllMapped(
    RegExp(r'state\s*=\s*state\.copyWith\(\s*isLoading:\s*([^,]+)\),\s*fortune:\s*([^)]+)\);'),
    (match) => 'state = state.copyWith(\n        isLoading: ${match.group(1)},\n        fortune: ${match.group(2)},\n      );'
  );

  // 21. Fix malformed log method parameters
  content = content.replaceAllMapped(
    RegExp(r'(\w+):\s*([^)]+)\)\s*([^}]+)\}\s*\)\s*;'),
    (match) => '${match.group(1)}: ${match.group(2)},${match.group(3)}},\n    );'
  );

  // 22. Fix broken async method declarations
  content = content.replaceAllMapped(
    RegExp(r'AsyncValue<List<Fortune>>\(\(\s*ref\s*\)\s*{\s*final\s*apiService'),
    (match) => 'AsyncValue<List<Fortune>>>((ref) {\n  final apiService'
  );

  // 23. Fix provider constructor with missing type parameters
  content = content.replaceAllMapped(
    RegExp(r'StateNotifierProvider<([^,]+),\s*AsyncValue<List<Fortune>>>\(\s*\(\s*ref\s*\)\s*{\s*final\s*apiService\s*=\s*ref\.watch\(([^)]+)\);\s*return\s*([^(]+)\(apiService,\s*ref\);\s*}\);'),
    (match) => 'StateNotifierProvider<${match.group(1)}, AsyncValue<List<Fortune>>>(\n        (ref) {\n  final apiService = ref.watch(${match.group(2)});\n  return ${match.group(3)}(apiService, ref);\n});'
  );

  return content;
}