import 'dart:io';

void main() async {
  final file = File('lib/features/fortune/presentation/pages/mbti_fortune_page.dart');
  
  if (!await file.exists()) {
    print('Error: File not found');
    return;
  }
  
  print('Fixing mbti_fortune_page.dart bracket errors...');
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Fix pattern: decoration: BoxDecoration(...), without closing )
    content = content.replaceAllMapped(
      RegExp(r'decoration:\s*BoxDecoration\([^)]*\),\s*child:'),
      (match) {
        final decorationMatch = match.group(0) ?? '';
        if (!decorationMatch.contains('),')) {
          replacements++;
          return decorationMatch.replaceFirst('borderRadius: AppDimensions.borderRadiusMedium,', 'borderRadius: AppDimensions.borderRadiusMedium,\n              ),');
        }
        return decorationMatch;
      }
    );
    
    // Fix all BoxDecoration missing closing parentheses
    final lines = content.split('\n');
    final newLines = <String>[];
    bool inBoxDecoration = false;
    int decorationOpenCount = 0;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Track BoxDecoration blocks
      if (line.contains('BoxDecoration(')) {
        inBoxDecoration = true;
        decorationOpenCount = 1;
      }
      
      if (inBoxDecoration) {
        // Count parentheses
        decorationOpenCount += line.split('(').length - 1;
        decorationOpenCount -= line.split(')').length - 1;
        
        // If we're at the end of BoxDecoration and next line has child:
        if (decorationOpenCount == 0 && i + 1 < lines.length && lines[i + 1].contains('child:')) {
          // Check if the line doesn't end with ),
          if (!line.trim().endsWith('),')) {
            newLines.add(line + ',');
            newLines.add('              ),');
            replacements++;
            inBoxDecoration = false;
            continue;
          }
        }
        
        if (decorationOpenCount <= 0) {
          inBoxDecoration = false;
        }
      }
      
      newLines.add(line);
    }
    
    if (replacements > 0) {
      await file.writeAsString(newLines.join('\n'));
      print('✓ Fixed $replacements bracket issues');
    } else {
      print('No fixes needed');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}