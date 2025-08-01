#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🚀 Starting syntax fixes for files #201-307...');
  
  // List of all remaining files to fix (from #201-307)
  final filesToFix = [
    // Already fixed: cache_entry.g.dart, fortune_model.dart, user_profile.dart
    // Already fixed: todo_list_page.dart, todo_creation_dialog.dart, todo_filter_chip.dart
    
    // Continue with remaining files
    'lib/presentation/pages/todo/widgets/todo_list_item.dart',
    'lib/presentation/pages/todo/widgets/todo_stats_card.dart',
    'lib/presentation/providers/ad_provider.dart',
    'lib/presentation/providers/auth_provider.dart',
    'lib/presentation/providers/celebrity_provider.dart',
    'lib/presentation/providers/font_size_provider.dart',
    'lib/presentation/providers/fortune_provider.dart',
    'lib/presentation/providers/fortune_recommendation_provider.dart',
    'lib/presentation/providers/navigation_visibility_provider.dart',
    'lib/presentation/providers/providers.dart',
    'lib/presentation/providers/recommendation_provider.dart',
    'lib/presentation/providers/social_auth_provider.dart',
    'lib/presentation/providers/soul_animation_provider.dart',
    'lib/presentation/providers/tarot_deck_provider.dart',
    'lib/presentation/providers/today_fortune_provider.dart',
    'lib/presentation/providers/todo_provider.dart',
    'lib/presentation/providers/token_provider.dart',
    'lib/presentation/providers/user_profile_notifier.dart',
    'lib/presentation/providers/user_statistics_provider.dart',
    'lib/presentation/screens/ad_loading_screen.dart',
    'lib/presentation/widgets/ad_widgets.dart',
    'lib/presentation/widgets/ads/adsense_widget_web.dart',
    'lib/presentation/widgets/ads/banner_ad_widget.dart',
    'lib/presentation/widgets/ads/cross_platform_ad_widget.dart',
    'lib/presentation/widgets/animated_tarot_card_widget.dart',
    'lib/presentation/widgets/birth_year_fortune_list.dart',
    'lib/presentation/widgets/common/custom_button.dart',
    'lib/presentation/widgets/common/custom_card.dart',
    'lib/presentation/widgets/common/empty_state_widget.dart',
    'lib/presentation/widgets/common/error_widget.dart',
    'lib/presentation/widgets/daily_fortune_summary_card.dart',
    'lib/presentation/widgets/enhanced_shareable_fortune_card.dart',
    'lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart',
    'lib/presentation/widgets/five_elements_widget.dart',
    'lib/presentation/widgets/fortune_card.dart',
    'lib/presentation/widgets/fortune_explanation_bottom_sheet.dart',
    'lib/presentation/widgets/fortune_history_chart.dart',
    'lib/presentation/widgets/fortune_history_summary_widget.dart',
    'lib/presentation/widgets/fortune_loading_widget.dart',
    'lib/presentation/widgets/hexagon_chart.dart',
    'lib/presentation/widgets/profile_completion_banner.dart',
    'lib/presentation/widgets/profile_edit_dialogs/birth_date_edit_dialog.dart',
    'lib/presentation/widgets/profile_edit_dialogs/birth_time_edit_dialog.dart',
    'lib/presentation/widgets/profile_edit_dialogs/blood_type_edit_dialog.dart',
    'lib/presentation/widgets/profile_edit_dialogs/mbti_edit_dialog.dart',
    'lib/presentation/widgets/profile_edit_dialogs/profile_field_edit_dialog.dart',
    'lib/presentation/widgets/profile_image_picker.dart',
    'lib/presentation/widgets/saju_chart_widget.dart',
    'lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart',
    'lib/presentation/widgets/saju_loading_widget.dart',
    'lib/presentation/widgets/simple_fortune_info_sheet.dart',
    'lib/presentation/widgets/social_accounts_section.dart',
    'lib/presentation/widgets/social_share_bottom_sheet.dart',
    'lib/presentation/widgets/time_based_fortune_bottom_sheet.dart',
    'lib/presentation/widgets/time_specific_fortune_card.dart',
    'lib/presentation/widgets/user_info_card.dart',
    'lib/presentation/widgets/user_info_visualization.dart',
    'lib/routes/app_router.dart',
    'lib/screens/auth/callback_page.dart',
    'lib/screens/home/home_screen.dart',
    'lib/screens/landing_page.dart',
    'lib/screens/onboarding/enhanced_onboarding_flow.dart',
    'lib/screens/onboarding/onboarding_flow_page.dart',
    'lib/screens/onboarding/onboarding_page_v2.dart',
    'lib/screens/onboarding/onboarding_page.dart',
    'lib/screens/onboarding/steps/birth_info_step.dart',
    'lib/screens/onboarding/steps/gender_step.dart',
    'lib/screens/onboarding/steps/location_step.dart',
    'lib/screens/onboarding/steps/name_step.dart',
    'lib/screens/onboarding/steps/phone_step.dart',
    'lib/screens/onboarding/widgets/bottom_sheet_time_picker.dart',
    'lib/screens/onboarding/widgets/onboarding_progress_bar.dart',
    'lib/screens/onboarding/widgets/onboarding_step_one.dart',
    'lib/screens/onboarding/widgets/onboarding_step_three.dart',
    'lib/screens/onboarding/widgets/onboarding_step_two.dart',
    'lib/screens/payment/token_history_page.dart',
    'lib/screens/premium/premium_screen.dart',
    'lib/screens/profile/profile_edit_page.dart',
    'lib/screens/profile/profile_screen.dart',
    'lib/screens/settings/phone_management_screen.dart',
    'lib/screens/settings/settings_screen.dart',
    'lib/screens/settings/social_accounts_screen.dart',
    'lib/screens/splash_screen.dart',
    'lib/screens/subscription/subscription_page.dart',
    'lib/services/ad_service.dart',
    'lib/services/auth_service.dart',
    'lib/services/cache_service.dart',
    'lib/services/celebrity_service.dart',
    'lib/services/in_app_purchase_service.dart',
    'lib/services/notification/fcm_service.dart',
    'lib/services/widget_data_manager.dart',
    'lib/services/zodiac_compatibility_service.dart',
    'lib/shared/components/ad_loading_screen.dart',
    'lib/shared/components/app_header.dart',
    'lib/shared/components/base_card.dart',
    'lib/shared/components/custom_calendar_date_picker.dart',
    'lib/shared/components/loading_states.dart',
    'lib/shared/components/soul_earn_animation.dart',
    'lib/shared/components/token_balance_widget.dart',
    'lib/shared/components/token_insufficient_modal.dart',
    'lib/shared/glassmorphism/glass_effects.dart',
  ];

  int fixedCount = 0;
  int totalCount = filesToFix.length;

  for (final filePath in filesToFix) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath');
      continue;
    }

    try {
      final content = await file.readAsString();
      String fixedContent = await fixSyntaxErrors(content, filePath);

      if (fixedContent != content) {
        await file.writeAsString(fixedContent);
        fixedCount++;
        print('✅ Fixed: $filePath');
      } else {
        print('ℹ️  No changes needed: $filePath');
      }
    } catch (e) {
      print('❌ Error processing $filePath: $e');
    }
  }

  print('\n🎉 Completed! Fixed $fixedCount out of $totalCount files.');
}

Future<String> fixSyntaxErrors(String content, String filePath) async {
  String result = content;

  // Common syntax error patterns and fixes
  final fixes = [
    // Missing closing parentheses in function calls
    RegExp(r'(\w+)\(([^)]*),\s*$', multiLine: true),
    // Missing closing parentheses after commas
    RegExp(r',\s*$', multiLine: true),
    // Missing closing brackets
    RegExp(r'\[([^\]]*),\s*$', multiLine: true),
    // Missing semicolons after statements
    RegExp(r'(\w+)(\s*,\s*$)', multiLine: true),
    // Mismatched parentheses
    RegExp(r'\.(\w+)\(([^)]*,)\s*$', multiLine: true),
  ];

  // Fix 1: Missing closing parentheses in annotations
  result = result.replaceAllMapped(
    RegExp(r'@(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '@${match.group(1)}(${match.group(2)})',
  );

  // Fix 2: Missing closing parentheses in function calls
  result = result.replaceAllMapped(
    RegExp(r'\.(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '.${match.group(1)}(${match.group(2)})',
  );

  // Fix 3: Fix method chains with trailing commas
  result = result.replaceAllMapped(
    RegExp(r'\.(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '.${match.group(1)}(${match.group(2)})',
  );

  // Fix 4: Missing closing parentheses in simple calls
  result = result.replaceAllMapped(
    RegExp(r'(\w+)\(([^)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}(${match.group(2)})',
  );

  // Fix 5: Replace trailing commas followed by whitespace/newlines with closing parentheses
  result = result.replaceAll(RegExp(r',(\s*\n\s*)\)'), r')$1)');
  result = result.replaceAll(RegExp(r',(\s*\n\s*);'), r'$1;');

  // Fix 6: Method chaining syntax errors
  result = result.replaceAllMapped(
    RegExp(r'\.map\(([^)]*),\s*$', multiLine: true),
    (match) => '.map(${match.group(1)})',
  );

  result = result.replaceAllMapped(
    RegExp(r'\.where\(([^)]*),\s*$', multiLine: true),
    (match) => '.where(${match.group(1)})',
  );

  result = result.replaceAllMapped(
    RegExp(r'\.take\(([^)]*),\s*$', multiLine: true),
    (match) => '.take(${match.group(1)})',
  );

  // Fix 7: Conditional operator syntax errors
  result = result.replaceAllMapped(
    RegExp(r'(\?[^:]*):([^,)]*),\s*$', multiLine: true),
    (match) => '${match.group(1)}:${match.group(2)}',
  );

  // Fix 8: Missing closing brackets and braces
  result = result.replaceAll(RegExp(r'\]\s*,\s*$', multiLine: true), ']');
  result = result.replaceAll(RegExp(r'\}\s*,\s*$', multiLine: true), '}');

  // Fix 9: Trailing commas in widget constructors
  result = result.replaceAllMapped(
    RegExp(r'(\w+)\(([^)]*),(\s*)\)', multiLine: true),
    (match) => '${match.group(1)}(${match.group(2)}${match.group(3)})',
  );

  // Fix 10: withValues/copyWith syntax
  result = result.replaceAllMapped(
    RegExp(r'\.withValues\(([^)]*),\s*$', multiLine: true),
    (match) => '.withValues(${match.group(1)})',
  );

  result = result.replaceAllMapped(
    RegExp(r'\.copyWith\(([^)]*),\s*$', multiLine: true),
    (match) => '.copyWith(${match.group(1)})',
  );

  return result;
}