import 'dart:io';

void main() async {
  print('Fixing final template placeholder errors...');
  
  final fixes = [
    // investment_fortune_result_page.dart - Missing closing bracket
    FileEdit(
      'lib/features/fortune/presentation/pages/investment_fortune_result_page.dart',
      [
        Edit(
          'style: const TextStyle(\n,
    color: Colors.white,\n,
    fontWeight: FontWeight.bold,\n                  ),',
          'style: const TextStyle(\n,
    color: Colors.white,\n,
    fontWeight: FontWeight.bold,\n                  ),',
        ),
      ],
    ),
    
    // tarot_summary_page.dart - Fix labelMedium
    FileEdit(
      'lib/features/fortune/presentation/pages/tarot_summary_page.dart',
      [
        Edit(
          "style: Theme.of(context).textTheme.bodyMedium,",
          "style: Theme.of(context).textTheme.labelMedium?.copyWith(\n,
    fontWeight: FontWeight.bold,\n                  ),",
        ),
      ],
    ),
    
    // enhanced_tarot_card_detail.dart - Multiple fixes
    FileEdit(
      'lib/features/fortune/presentation/widgets/enhanced_tarot_card_detail.dart',
      [
        // Line 346 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,",
        ),
        // Line 411 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,",
        ),
        // Line 580 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,",
        ),
        // Line 617 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,",
        ),
        // Line 636 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,",
        ),
        // Line 697 - Fix template placeholder
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,",
        ),
      ],
    ),
    
    // tarot_card_reveal_widget.dart - Fix template placeholder
    FileEdit(
      'lib/features/fortune/presentation/widgets/tarot_card_reveal_widget.dart',
      [
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,",
        ),
      ],
    ),
    
    // blood_type_personality_chart.dart - Fix template placeholder
    FileEdit(
      'lib/features/fortune/presentation/widgets/blood_type_personality_chart.dart',
      [
        Edit(
          "fontSize: Theme.of(context).textTheme.\${getTextThemeForSize(size)}!.fontSize,",
          "fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,",
        ),
      ],
    ),
  ];
  
  for (final fileEdit in fixes) {
    await processFile(fileEdit);
  }
  
  print('\nFixed all template placeholder errors!');
}

class FileEdit {
  final String path;
  final List<Edit> edits;
  
  FileEdit(this.path, this.edits);
}

class Edit {
  final String oldText;
  final String newText;
  
  Edit(this.oldText, this.newText);
}

Future<void> processFile(FileEdit fileEdit) async {
  final file = File(fileEdit.path);
  
  if (!await file.exists()) {
    print('Warning: File not,
    found: ${fileEdit.path}');
    return;
  }
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    for (final edit in fileEdit.edits) {
      if (content.contains(edit.oldText)) {
        content = content.replaceAll(edit.oldText, edit.newText);
        replacements++;
      }
    }
    
    if (replacements > 0) {
      await file.writeAsString(content);
      print('✓ Fixed ${fileEdit.path} ($replacements replacements)');
    }
  } catch (e) {
    print('Error processing ${fileEdit.path}: $e');
  }
}