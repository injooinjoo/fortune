import 'dart:io';

void main() async {
  var totalFixed = 0;
  var filesFixed = 0;
  
  // Files with bracket issues from the error output
  final problematicFiles = [
    'lib/main.dart',
    'lib/screens/landing_page.dart',
    'lib/screens/auth/signup_screen.dart',
    'lib/screens/home/home_screen.dart',
    'lib/screens/profile/profile_screen.dart',
    'lib/screens/settings/settings_screen.dart',
    'lib/screens/settings/social_accounts_screen.dart',
    'lib/screens/settings/phone_management_screen.dart',
    'lib/screens/onboarding/onboarding_page_v2.dart',
    'lib/screens/onboarding/onboarding_flow_page.dart',
    'lib/screens/onboarding/enhanced_onboarding_flow.dart',
    'lib/screens/premium/premium_screen.dart',
    'lib/features/fortune/presentation/pages/time_based_fortune_page.dart',
  ];
  
  for (final filePath in problematicFiles) {
    final file = File(filePath);
    if (!await file.exists()) continue;
    
    final content = await file.readAsString();
    var fixedContent = content;
    var fileFixed = 0;
    
    // Fix pattern where style line ends with ,),), instead of ),
    // This was caused by the previous script adding extra closing parentheses
    final stylePattern = RegExp(
      r'(style:\s*[^,]+(?:\.copyWith\([^)]*\))?),\),\)',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(stylePattern, (match) {
      fileFixed++;
      return '${match.group(1)}),';
    });
    
    // Fix pattern where fontWeight is on a separate line after style ends
    final fontWeightPattern = RegExp(
      r'(style:\s*[^,]+(?:\.copyWith\([^)]*\))?),\),\s*fontWeight:',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(fontWeightPattern, (match) {
      fileFixed++;
      // Extract the part before ,), and add fontWeight inside copyWith
      final stylePart = match.group(1)!;
      if (stylePart.contains('copyWith')) {
        // Remove the last ) from copyWith and add fontWeight
        return stylePart.replaceFirst(RegExp(r'\)$'), ', fontWeight:');
      } else {
        // Add copyWith with fontWeight
        return '$stylePart?.copyWith(fontWeight:';
      }
    });
    
    // Fix height property appearing after style ends
    final heightPattern = RegExp(
      r'(style:\s*[^,]+(?:\.copyWith\([^)]*\))?),\),\s*height:\s*([^,)]+)\)',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(heightPattern, (match) {
      fileFixed++;
      final stylePart = match.group(1)!;
      final heightValue = match.group(2)!;
      if (stylePart.contains('copyWith')) {
        // Add height inside existing copyWith
        return stylePart.replaceFirst(RegExp(r'\)$'), ', height: $heightValue)');
      } else {
        // Add copyWith with height
        return '$stylePart?.copyWith(height: $heightValue)';
      }
    });
    
    // Fix cases where Text widget has style ending with ,), and there's content after
    final textWidgetPattern = RegExp(
      r'(Text\(\s*[^,]+,\s*style:\s*[^,]+(?:\.copyWith\([^)]*\))?),\),(\s*[^)])',
      multiLine: true,
    );
    
    fixedContent = fixedContent.replaceAllMapped(textWidgetPattern, (match) {
      fileFixed++;
      return '${match.group(1)}),),${match.group(2)}';
    });
    
    if (fileFixed > 0) {
      await file.writeAsString(fixedContent);
      print('Fixed $fileFixed issues in ${file.path}');
      totalFixed += fileFixed;
      filesFixed++;
    }
  }
  
  print('\nTotal,
    fixes: $totalFixed across $filesFixed files');
}