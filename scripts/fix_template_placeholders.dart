import 'dart:io';

void main() {
  final directory = Directory('lib');
  
  // Map of file patterns to replacements
  final replacements = {
    // Common template patterns
    r"Theme.of(context).textTheme.\$textTheme!.copyWith(\$copyWithProps)": "Theme.of(context).textTheme.bodyMedium",
    r"const Theme.of(context).textTheme.\$textTheme!.copyWith(\$copyWithProps)": "Theme.of(context).textTheme.bodyMedium",
    r"style: const Theme.of": "style: Theme.of",
    r"const AppColors\.": "AppColors.",
    r"const FortuneColors\.": "FortuneColors.",
  };

  processDirectory(directory, replacements);
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