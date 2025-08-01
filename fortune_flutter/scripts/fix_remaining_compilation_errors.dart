import 'dart:io';

void main() async {
  print('🔧 Fixing remaining compilation errors...');
  
  // Pattern 1: Fix nullable copyWith
  await fixNullableCopyWith();
  
  // Pattern 2: Fix BorderRadius type errors
  await fixBorderRadiusErrors();
  
  // Pattern 3: Fix const expression errors
  await fixConstExpressionErrors();
  
  // Pattern 4: Fix remaining shade properties
  await fixRemainingShadeProperties();
  
  print('✅ All fixes completed!');
}

Future<void> fixNullableCopyWith() async {
  print('\n📝 Fixing nullable copyWith patterns...');
  
  final files = [
    'lib/features/fortune/presentation/pages/zodiac_fortune_page.dart',
    'lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix patterns like textTheme.bodySmall.copyWith -> textTheme.bodySmall?.copyWith
    content = content.replaceAllMapped(
      RegExp(r'(textTheme\.\w+)\.copyWith'),
      (match) => '${match.group(1)}?.copyWith'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed $filePath');
    }
  }
}

Future<void> fixBorderRadiusErrors() async {
  print('\n📝 Fixing BorderRadius type errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/lucky_food_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_items_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_place_fortune_page.dart',
    'lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart',
  ];
  
  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Fix patterns where borderRadius expects BorderRadiusGeometry
    // Replace direct double assignment with BorderRadius.circular
    content = content.replaceAllMapped(
      RegExp(r'borderRadius:\s*AppDimensions\.radius\w+'),
      (match) => 'borderRadius: BorderRadius.circular(${match.group(0)!.split(':')[1].trim()})'
    );
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Fixed $filePath');
    }
  }
}

Future<void> fixConstExpressionErrors() async {
  print('\n📝 Fixing const expression errors...');
  
  // Fix physiognomy_enhanced_page.dart
  var file = File('lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart');
  if (file.existsSync()) {
    var content = await file.readAsString();
    
    // Remove const from constructors that use Theme.of(context)
    content = content.replaceAllMapped(
      RegExp(r'const\s+SizedBox\(\s*height:\s*\d+\s*\),\s*const\s+Text\([^)]+Theme\.of\(context\)[^)]+\)'),
      (match) {
        var text = match.group(0)!;
        text = text.replaceFirst('const Text(', 'Text(');
        return text;
      }
    );
    
    await file.writeAsString(content);
    print('  ✓ Fixed physiognomy_enhanced_page.dart');
  }
  
  // Fix physiognomy_input_page.dart
  file = File('lib/features/fortune/presentation/pages/physiognomy_input_page.dart');
  if (file.existsSync()) {
    var content = await file.readAsString();
    
    // Remove const from widgets that reference context
    content = content.replaceAllMapped(
      RegExp(r'const\s+Center\([^)]*child:\s*const\s+Text\([^)]*\)\s*\)'),
      (match) {
        var text = match.group(0)!;
        if (text.contains('context')) {
          text = text.replaceAll('const Center', 'Center');
          text = text.replaceAll('const Text', 'Text');
        }
        return text;
      }
    );
    
    await file.writeAsString(content);
    print('  ✓ Fixed physiognomy_input_page.dart');
  }
}

Future<void> fixRemainingShadeProperties() async {
  print('\n📝 Fixing remaining shade properties...');
  
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  final shadeMap = {
    '.shade50': '.withValues(alpha: 0.08)',
    '.shade100': '.withValues(alpha: 0.9)',
    '.shade200': '.withValues(alpha: 0.3)',
    '.shade300': '.withValues(alpha: 0.5)',
    '.shade400': '.withValues(alpha: 0.6)',
    '.shade500': '.withValues(alpha: 0.7)',
    '.shade600': '.withValues(alpha: 0.72)',
    '.shade700': '.withValues(alpha: 0.74)',
    '.shade800': '.withValues(alpha: 0.87)',
    '.shade900': '.withValues(alpha: 0.92)',
  };
  
  for (final file in files) {
    var content = await file.readAsString();
    var modified = false;
    
    for (final entry in shadeMap.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        modified = true;
      }
    }
    
    if (modified) {
      await file.writeAsString(content);
      print('  ✓ Fixed shade properties in ${file.path}');
    }
  }
}