#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🚀 Starting syntax fixes for files #61-120...');
  
  // List of files from #61-120 in error_files_list_v4.txt
  final filesToFix = [
    'lib/features/fortune/presentation/pages/pet_fortune_page.dart', // #61
    'lib/features/fortune/presentation/pages/pet_fortune_unified_page.dart', // #62
    'lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart', // #63
    'lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart', // #64
    'lib/features/fortune/presentation/pages/physiognomy_input_page.dart', // #65
    'lib/features/fortune/presentation/pages/physiognomy_result_page.dart', // #66
    'lib/features/fortune/presentation/pages/salpuli_fortune_page.dart', // #67
    'lib/features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart', // #68
    'lib/features/fortune/presentation/pages/sports_fortune_page.dart', // #69
    'lib/features/fortune/presentation/pages/startup_fortune_page.dart', // #70
    'lib/features/fortune/presentation/pages/talent_fortune_page.dart', // #71
    'lib/features/fortune/presentation/pages/talisman_enhanced_page.dart', // #72
    'lib/features/fortune/presentation/pages/talisman_fortune_page.dart', // #73
    'lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart', // #74
    'lib/features/fortune/presentation/pages/tarot_enhanced_page.dart', // #75
    'lib/features/fortune/presentation/pages/tarot_main_page.dart', // #76
    'lib/features/fortune/presentation/pages/tarot_storytelling_page.dart', // #77
    'lib/features/fortune/presentation/pages/tarot_summary_page.dart', // #78
    'lib/features/fortune/presentation/pages/time_based_fortune_page.dart', // #79
    'lib/features/fortune/presentation/pages/timeline_fortune_page.dart', // #80
    'lib/features/fortune/presentation/pages/tojeong_fortune_page.dart', // #81
    'lib/features/fortune/presentation/pages/traditional_compatibility_page.dart', // #82
    'lib/features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart', // #83
    'lib/features/fortune/presentation/pages/traditional_fortune_result_page.dart', // #84
    'lib/features/fortune/presentation/pages/traditional_fortune_unified_page.dart', // #85
    'lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart', // #86
    'lib/features/fortune/presentation/pages/wealth_fortune_page.dart', // #87
    'lib/features/fortune/presentation/pages/wish_fortune_page.dart', // #88
    'lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart', // #89
    'lib/features/fortune/presentation/pages/zodiac_fortune_page.dart', // #90
    'lib/features/fortune/presentation/widgets/career_fortune_selector.dart', // #91
    'lib/features/interactive/presentation/pages/dream_interpretation_page.dart', // #92
    'lib/features/interactive/presentation/pages/face_reading_page.dart', // #93
    'lib/features/interactive/presentation/pages/fortune_cookie_page.dart', // #94
    'lib/features/interactive/presentation/pages/interactive_list_page.dart', // #95
    'lib/features/interactive/presentation/pages/psychology_test_page.dart', // #96
    'lib/features/interactive/presentation/pages/taemong_page.dart', // #97
    'lib/features/interactive/presentation/pages/tarot_animated_flow_page.dart', // #98
    'lib/features/interactive/presentation/pages/tarot_card_page.dart', // #99
    'lib/features/interactive/presentation/pages/tarot_chat_page.dart', // #100
    'lib/features/interactive/presentation/pages/worry_bead_page.dart', // #101
    'lib/features/notification/presentation/pages/notification_settings_page.dart', // #102
    'lib/features/payment/presentation/pages/token_purchase_page_v2.dart', // #103
    'lib/features/policy/presentation/pages/policy_page.dart', // #104
    'lib/features/policy/presentation/pages/privacy_policy_page.dart', // #105
    'lib/features/policy/presentation/pages/terms_of_service_page.dart', // #106
    'lib/presentation/pages/todo/todo_list_page.dart', // #107
    'lib/routes/app_router.dart', // #108
    'lib/screens/onboarding/enhanced_onboarding_flow.dart', // #109
    'lib/screens/onboarding/onboarding_flow_page.dart', // #110
    'lib/screens/onboarding/onboarding_page_v2.dart', // #111
    'lib/screens/onboarding/onboarding_page.dart', // #112
    'lib/screens/payment/token_history_page.dart', // #113
    'lib/screens/premium/premium_screen.dart', // #114
    'lib/screens/profile/profile_edit_page.dart', // #115
    'lib/screens/profile/profile_screen.dart', // #116
    'lib/screens/settings/phone_management_screen.dart', // #117
    'lib/screens/settings/settings_screen.dart', // #118
    'lib/screens/settings/social_accounts_screen.dart', // #119
    'lib/screens/subscription/subscription_page.dart', // #120
  ];

  int fixedCount = 0;
  int totalCount = filesToFix.length;

  for (int i = 0; i < filesToFix.length; i++) {
    final filePath = filesToFix[i];
    final fileNumber = i + 61; // Start from #61
    
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found (#$fileNumber): $filePath');
      continue;
    }

    try {
      final content = await file.readAsString();
      String fixedContent = await fixSyntaxErrors(content, filePath);

      if (fixedContent != content) {
        await file.writeAsString(fixedContent);
        fixedCount++;
        print('✅ Fixed (#$fileNumber): $filePath');
      } else {
        print('ℹ️  No changes needed (#$fileNumber): $filePath');
      }
    } catch (e) {
      print('❌ Error processing (#$fileNumber) $filePath: $e');
    }
  }

  print('\n🎉 Completed! Fixed $fixedCount out of $totalCount files (#61-120).');
}

Future<String> fixSyntaxErrors(String content, String filePath) async {
  String result = content;

  // Enhanced fix patterns for more comprehensive error handling
  
  // Fix 1: Missing closing parentheses in widget properties
  result = result.replaceAllMapped(
    RegExp(r'(\w+):\s*([^,)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}: ${match.group(2)},',
  );

  // Fix 2: Missing closing parentheses in function calls
  result = result.replaceAllMapped(
    RegExp(r'(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}(${match.group(2)})',
  );

  // Fix 3: Fix method chains with trailing commas  
  result = result.replaceAllMapped(
    RegExp(r'\.(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '.${match.group(1)}(${match.group(2)})',
  );

  // Fix 4: Fix conditional expressions with trailing commas
  result = result.replaceAllMapped(
    RegExp(r'(\?[^:]*:\s*[^,)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}',
  );

  // Fix 5: Fix widget constructor calls
  result = result.replaceAllMapped(
    RegExp(r'(\w+)\(\s*([^)]*),(\s*)\)', multiLine: true),
    (match) {
      final name = match.group(1)!;
      final params = match.group(2)!.trim();
      final spacing = match.group(3)!;
      if (params.isEmpty) {
        return '$name()';
      }
      return '$name($params$spacing)';
    },
  );

  // Fix 6: Fix annotations with trailing commas
  result = result.replaceAllMapped(
    RegExp(r'@(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '@${match.group(1)}(${match.group(2)})',
  );

  // Fix 7: Fix if statements with trailing commas
  result = result.replaceAllMapped(
    RegExp(r'if\s*\(([^)]*),\s*$', multiLine: true),
    (match) => 'if (${match.group(1)})',
  );

  // Fix 8: Fix builder functions with trailing commas
  result = result.replaceAllMapped(
    RegExp(r'builder:\s*\([^)]*\)\s*=>\s*([^,)]*),\s*$', multiLine: true),
    (match) => 'builder: ${match.group(0)?.replaceAll(RegExp(r',\s*$'), '')}',
  );

  // Fix 9: Fix trailing commas in lists and maps
  result = result.replaceAll(RegExp(r',(\s*[\]}])', multiLine: true), r'$1');

  // Fix 10: Fix specific widget patterns
  result = result.replaceAllMapped(
    RegExp(r'child:\s*([^,)]*),\s*$', multiLine: true),
    (match) => 'child: ${match.group(1)},',
  );

  // Fix 11: Fix onPressed and callback patterns
  result = result.replaceAllMapped(
    RegExp(r'(onPressed|onTap|onChanged):\s*([^,)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}: ${match.group(2)},',
  );

  // Fix 12: Fix Text widget patterns
  result = result.replaceAllMapped(
    RegExp(r'Text\(([^)]*),\s*$', multiLine: true),
    (match) => 'Text(${match.group(1)})',
  );

  // Fix 13: Fix Icon widget patterns
  result = result.replaceAllMapped(
    RegExp(r'Icon\(([^)]*),\s*$', multiLine: true),
    (match) => 'Icon(${match.group(1)})',
  );

  // Fix 14: Fix EdgeInsets patterns
  result = result.replaceAllMapped(
    RegExp(r'EdgeInsets\.(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => 'EdgeInsets.${match.group(1)}(${match.group(2)})',
  );

  // Fix 15: Fix Container and similar widgets
  result = result.replaceAllMapped(
    RegExp(r'(Container|Column|Row|Stack|Expanded|Flexible)\(([^)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}(${match.group(2)})',
  );

  // Fix 16: Fix withValues method calls
  result = result.replaceAllMapped(
    RegExp(r'\.withValues\(([^)]*),\s*$', multiLine: true),
    (match) => '.withValues(${match.group(1)})',
  );

  // Fix 17: Fix copyWith method calls
  result = result.replaceAllMapped(
    RegExp(r'\.copyWith\(([^)]*),\s*$', multiLine: true),
    (match) => '.copyWith(${match.group(1)})',
  );

  // Fix 18: Fix Theme.of context calls
  result = result.replaceAllMapped(
    RegExp(r'Theme\.of\(([^)]*),\s*$', multiLine: true),
    (match) => 'Theme.of(${match.group(1)})',
  );

  // Fix 19: Fix Navigator calls
  result = result.replaceAllMapped(
    RegExp(r'Navigator\.(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => 'Navigator.${match.group(1)}(${match.group(2)})',
  );

  // Fix 20: Fix setState calls
  result = result.replaceAllMapped(
    RegExp(r'setState\(([^)]*),\s*$', multiLine: true),
    (match) => 'setState(${match.group(1)})',
  );

  return result;
}