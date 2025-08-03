import 'dart:io';

void main() {
  final directory = Directory('lib');
  
  // More comprehensive replacements
  final replacements = {
    // Template placeholder patterns
    r'Theme.of(context).textTheme.$textTheme!.copyWith($copyWithProps)': 'Theme.of(context).textTheme.bodyMedium',
    r'Theme.of(context).textTheme.$textTheme': 'Theme.of(context).textTheme.bodyMedium',
    r'.$textTheme!.copyWith($copyWithProps)': '.bodyMedium',
    r'.$textTheme': '.bodyMedium',
    
    // Fix const errors
    r'const Theme.of(context)': 'Theme.of(context)',
    r'const AppColors.': 'AppColors.',
    r'const FortuneColors.': 'FortuneColors.',
    
    // Fix withOpacity to withValues (if any remaining)
    r'.withOpacity(': '.withValues(alpha: ',
  };

  processDirectory(directory, replacements);
  
  // Additional pass for specific fixes
  final specificReplacements = {
    // Fix any remaining $textTheme patterns
    r'$textTheme!': 'bodyMedium',
    r'$textTheme': 'bodyMedium',
    r'$copyWithProps': '',
  };
  
  processDirectory(directory, specificReplacements);
  
  print('Template placeholder fix completed!');
}

void processDirectory(Directory dir, Map<String, String> replacements) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      processFile(entity, replacements);
    }
  }
}

void processFile(File file, Map<String, String> replacements) {
  try {
    var content = file.readAsStringSync();
    var modified = false;

    replacements.forEach((pattern, replacement) {
      if (content.contains(pattern)) {
        content = content.replaceAll(pattern, replacement);
        modified = true;
        print('  Replaced "$pattern" in ${file.path}');
      }
    });

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed: ${file.path}');
    }
  } catch (e) {
    print('Error processing ${file.path}: $e');
  }
}