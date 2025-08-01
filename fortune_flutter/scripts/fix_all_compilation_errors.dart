import 'dart:io';

void main() async {
  print('🔧 Fixing ALL compilation errors...');
  
  // Fix BorderRadius errors
  await fixBorderRadiusErrors();
  
  // Fix const expression errors
  await fixConstExpressionErrors();
  
  // Fix nullable copyWith
  await fixNullableCopyWith();
  
  // Fix BoxDecoration errors
  await fixBoxDecorationErrors();
  
  print('✅ All fixes completed!');
}

Future<void> fixBorderRadiusErrors() async {
  print('\n📝 Fixing BorderRadius type errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/physiognomy_result_page.dart',
    'lib/features/fortune/presentation/pages/couple_match_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix patterns where borderRadius expects BorderRadiusGeometry
    content = content.replaceAllMapped(
      RegExp(r'borderRadius:\s*AppDimensions\.radius(\w+),'),
      (match) => 'borderRadius: BorderRadius.circular(AppDimensions.radius${match.group(1)!}),'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed $filePath');
    }
  }
}

Future<void> fixConstExpressionErrors() async {
  print('\n📝 Fixing const expression errors...');
  
  // Fix ex_lover_fortune_enhanced_page.dart
  var file = File('lib/features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart');
  if (file.existsSync()) {
    var content = await file.readAsString();
    
    // Remove const from Text widgets that use Theme.of(context)
    content = content.replaceAllMapped(
      RegExp(r'const\s+Text\([^)]*Theme\.of\(context\)[^)]*\)'),
      (match) {
        var text = match.group(0)!;
        text = text.replaceFirst('const Text(', 'Text(');
        return text;
      }
    );
    
    await file.writeAsString(content);
    print('  ✓ Fixed ex_lover_fortune_enhanced_page.dart');
  }
  
  // Fix time_based_fortune_page.dart
  file = File('lib/features/fortune/presentation/pages/time_based_fortune_page.dart');
  if (file.existsSync()) {
    var content = await file.readAsString();
    
    // Remove const from decorations that use Theme.of(context)
    content = content.replaceAllMapped(
      RegExp(r'const\s+BoxDecoration\([^)]*Theme\.of\(context\)[^)]*\)'),
      (match) {
        var text = match.group(0)!;
        text = text.replaceFirst('const BoxDecoration(', 'BoxDecoration(');
        return text;
      }
    );
    
    // Remove const from widgets containing Theme.of(context)
    content = content.replaceAllMapped(
      RegExp(r'const\s+(Icon|Text|Container|Padding|Column|Row)\([^{]*Theme\.of\(context\)[^}]*\}?\s*\)'),
      (match) {
        var text = match.group(0)!;
        text = text.replaceFirst(RegExp(r'const\s+'), '');
        return text;
      }
    );
    
    await file.writeAsString(content);
    print('  ✓ Fixed time_based_fortune_page.dart');
  }
  
  // Fix lifestyle_fortune_page.dart
  file = File('lib/features/fortune/presentation/pages/lifestyle_fortune_page.dart');
  if (file.existsSync()) {
    var content = await file.readAsString();
    
    // Remove const from widgets that use Theme.of(context)
    content = content.replaceAllMapped(
      RegExp(r'const\s+(Icon|Text|Container|Padding|Column|Row|LinearProgressIndicator)\([^)]*Theme\.of\(context\)[^)]*\)'),
      (match) {
        var text = match.group(0)!;
        text = text.replaceFirst(RegExp(r'const\s+'), '');
        return text;
      }
    );
    
    await file.writeAsString(content);
    print('  ✓ Fixed lifestyle_fortune_page.dart');
  }
}

Future<void> fixNullableCopyWith() async {
  print('\n📝 Fixing nullable copyWith patterns...');
  
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in files) {
    var content = await file.readAsString();
    var modified = false;
    
    // Fix patterns like textTheme.bodySmall.copyWith -> textTheme.bodySmall?.copyWith
    var newContent = content.replaceAllMapped(
      RegExp(r'(textTheme\.\w+)\.copyWith'),
      (match) {
        // Check if it's already optional
        var prefix = match.group(1)!;
        var index = match.start;
        if (index > 0 && content[index - 1] == '?') {
          return match.group(0)!; // Already fixed
        }
        modified = true;
        return '$prefix?.copyWith';
      }
    );
    
    if (modified) {
      await file.writeAsString(newContent);
      print('  ✓ Fixed nullable copyWith in ${file.path}');
    }
  }
}

Future<void> fixBoxDecorationErrors() async {
  print('\n📝 Fixing BoxDecoration errors...');
  
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in files) {
    var content = await file.readAsString();
    var modified = false;
    
    // Fix BoxDecoration with double borderRadius
    var newContent = content.replaceAllMapped(
      RegExp(r'BoxDecoration\s*\([^)]*borderRadius:\s*AppDimensions\.radius(\w+)[^)]*\)'),
      (match) {
        var decorationContent = match.group(0)!;
        if (!decorationContent.contains('BorderRadius.circular')) {
          modified = true;
          return decorationContent.replaceAllMapped(
            RegExp(r'borderRadius:\s*AppDimensions\.radius(\w+)'),
            (radiusMatch) => 'borderRadius: BorderRadius.circular(AppDimensions.radius${radiusMatch.group(1)!})'
          );
        }
        return decorationContent;
      }
    );
    
    if (modified) {
      await file.writeAsString(newContent);
      print('  ✓ Fixed BoxDecoration in ${file.path}');
    }
  }
}