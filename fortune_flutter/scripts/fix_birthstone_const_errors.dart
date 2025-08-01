import 'dart:io';

void main() async {
  print('Fixing birthstone_fortune_page.dart const errors...');
  
  final file = File('lib/features/fortune/presentation/pages/birthstone_fortune_page.dart');
  
  if (!await file.exists()) {
    print('File not found!');
    return;
  }
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Find lines with const BoxDecoration and AppDimensions.borderRadius method calls
    content = content.replaceAllMapped(
      RegExp(r'(\s*)const BoxDecoration\(\s*borderRadius: AppDimensions\.borderRadius\(([^)]+)\)'),
      (match) {
        replacements++;
        final indent = match.group(1) ?? '';
        final param = match.group(2) ?? '';
        return '${indent}BoxDecoration(\n${indent}  borderRadius: AppDimensions.borderRadius($param)';
      }
    );
    
    // Fix lines with const BorderRadius.circular(AppSpacing.spacing...)
    content = content.replaceAllMapped(
      RegExp(r'const BorderRadius\.circular\(AppSpacing\.spacing(\d+)\s*\*\s*[\d.]+\)'),
      (match) {
        replacements++;
        return 'BorderRadius.circular(AppSpacing.spacing${match.group(1)} * ${match.group(0)?.split('*').last?.trim() ?? "1"}';
      }
    );
    
    // More general fix for const BorderRadius.circular with calculations
    content = content.replaceAllMapped(
      RegExp(r'const (BorderRadius\.circular\([^)]*\))'),
      (match) {
        final borderRadius = match.group(1) ?? '';
        // Check if it contains method calls or calculations
        if (borderRadius.contains('AppSpacing') || borderRadius.contains('*') || borderRadius.contains('+') || borderRadius.contains('-')) {
          replacements++;
          return borderRadius;
        }
        return match.group(0) ?? '';
      }
    );
    
    // Fix the unnecessary non-null assertion
    content = content.replaceAll(
      'Theme.of(context).textTheme.bodyMedium!.fontSize!',
      'Theme.of(context).textTheme.bodyMedium?.fontSize'
    );
    replacements++;
    
    if (replacements > 0) {
      await file.writeAsString(content);
      print('✓ Fixed birthstone_fortune_page.dart ($replacements replacements)');
    } else {
      print('No changes needed.');
    }
  } catch (e) {
    print('Error processing file: $e');
  }
}