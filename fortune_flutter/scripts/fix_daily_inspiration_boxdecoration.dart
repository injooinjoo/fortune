import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/daily_inspiration_page.dart');
  
  if (!await file.exists()) {
    print('Error: File not found');
    return;
  }
  
  print('Fixing BoxDecoration errors in daily_inspiration_page.dart...');
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Fix pattern: decoration: BoxDecoration(...), without closing )
    content = content.replaceAllMapped(
      RegExp(r'decoration:\s*BoxDecoration\([^)]*\),\s*child:'),
      (match) {
        final decorationMatch = match.group(0) ?? '';
        if (!decorationMatch.contains('),\n')) {
          // Check if it's missing the closing parenthesis
          final fixedMatch = decorationMatch.replaceFirst(
            RegExp(r'borderRadius:\s*AppDimensions\.borderRadius\w+,\s*child:'),
            'borderRadius: AppDimensions.borderRadiusSmall,\n                              ),\n                              child:'
          );
          if (fixedMatch != decorationMatch) {
            replacements++;
            return fixedMatch;
          }
        }
        return decorationMatch;
      }
    );
    
    // More specific fix for the exact pattern
    content = content.replaceAll(
      RegExp(r'borderRadius: AppDimensions\.borderRadiusSmall,\s*child:'),
      'borderRadius: AppDimensions.borderRadiusSmall,\n                              ),\n                              child:'
    );
    
    await file.writeAsString(content);
    print('✓ Fixed BoxDecoration issues');
    
  } catch (e) {
    print('Error: $e');
  }
}