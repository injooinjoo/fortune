import 'dart:io';

void main() async {
  print('Fixing all bracket errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/mbti_fortune_page.dart',
    'lib/features/fortune/presentation/pages/traditional_fortune_result_page.dart',
    'lib/features/fortune/presentation/pages/daily_inspiration_page.dart',
    'lib/presentation/widgets/enhanced_shareable_fortune_card.dart',
    'lib/features/fortune/presentation/widgets/fortune_display.dart',
  ];
  
  for (final filePath in files) {
    await fixFile(filePath);
  }
  
  print('\n✅ Fixed all bracket errors!');
}

Future<void> fixFile(String filePath) async {
  final file = File(filePath);
  
  if (!await file.exists()) {
    print('Warning: File not found: $filePath');
    return;
  }
  
  print('\nFixing $filePath...');
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Common pattern 1: Extra ), after style declarations
    content = content.replaceAllMapped(
      RegExp(r'style: Theme\.of\(context\)\.textTheme\.\w+\?,?\s*\),\s*\),'),
      (match) {
        replacements++;
        final styleMatch = match.group(0) ?? '';
        // Remove the extra ),
        return styleMatch.replaceFirst(RegExp(r'\),\s*\),$'), '),');
      }
    );
    
    // Common pattern 2: Extra ), after copyWith
    content = content.replaceAllMapped(
      RegExp(r'\.copyWith\([^)]*\)\?,?\s*\),\s*\),'),
      (match) {
        replacements++;
        final copyWithMatch = match.group(0) ?? '';
        // Remove the extra ),
        return copyWithMatch.replaceFirst(RegExp(r'\),\s*\),$'), '),');
      }
    );
    
    // Common pattern 3: height property after style
    content = content.replaceAllMapped(
      RegExp(r'(style: Theme\.of\(context\)\.textTheme\.\w+\?,?)\s*height: ([\d.]+),\s*\),\s*\),'),
      (match) {
        replacements++;
        final style = match.group(1) ?? '';
        final height = match.group(2) ?? '';
        return '$style?.copyWith(height: $height),),';
      }
    );
    
    // Common pattern 4: BoxDecoration/LinearGradient extra closing
    content = content.replaceAllMapped(
      RegExp(r'(LinearGradient\([^)]*colors: \[[^\]]*\],?\s*)\),\s*\),'),
      (match) {
        replacements++;
        final gradient = match.group(1) ?? '';
        return '$gradient),';
      }
    );
    
    // Common pattern 5: BorderRadius extra closing
    content = content.replaceAllMapped(
      RegExp(r'(borderRadius: [^,]+,)\s*\),'),
      (match) {
        replacements++;
        final radius = match.group(1) ?? '';
        return radius;
      }
    );
    
    // Common pattern 6: Empty closing ),
    content = content.replaceAllMapped(
      RegExp(r'^\s*\),\s*$', multiLine: true),
      (match) {
        // Check if this is a legitimate closing
        final beforeMatch = content.substring(0, match.start).trim();
        if (beforeMatch.endsWith(',') || beforeMatch.endsWith('{') || beforeMatch.endsWith('[')) {
          return match.group(0) ?? '';
        }
        // Otherwise it might be extra
        replacements++;
        return '';
      }
    );
    
    // Common pattern 7: Fix mismatched brackets in lists
    content = content.replaceAllMapped(
      RegExp(r'children: \[\s*([^]]*?)(?:\],\s*\],|\)\s*\],)'),
      (match) {
        replacements++;
        final children = match.group(1) ?? '';
        return 'children: [\n$children],';
      }
    );
    
    if (replacements > 0) {
      await file.writeAsString(content);
      print('✓ Fixed $filePath ($replacements fixes)');
    } else {
      print('No fixes needed for $filePath');
    }
    
  } catch (e) {
    print('Error fixing $filePath: $e');
  }
}