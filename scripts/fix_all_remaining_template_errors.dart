import 'dart:io';

void main() async {
  print('Fixing ALL remaining template placeholder errors...');
  
  final files = [
    'lib/features/fortune/presentation/pages/blind_date_fortune_page.dart',
    'lib/features/fortune/presentation/pages/celebrity_match_page.dart',
    'lib/features/fortune/presentation/pages/chemistry_page.dart',
    'lib/features/fortune/presentation/pages/compatibility_page.dart',
    'lib/features/fortune/presentation/pages/couple_match_page.dart',
    'lib/features/fortune/presentation/pages/daily_inspiration_page.dart',
    'lib/features/fortune/presentation/pages/dream_fortune_chat_page.dart',
    'lib/features/fortune/presentation/pages/dream_fortune_page.dart',
    'lib/features/fortune/presentation/pages/dream_steps/dream_symbols_step.dart',
    'lib/features/fortune/presentation/pages/ex_lover_fortune_page.dart',
    'lib/features/fortune/presentation/pages/face_reading_fortune_page.dart',
    'lib/features/fortune/presentation/pages/influencer_fortune_page.dart',
    'lib/features/fortune/presentation/pages/investment_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lifestyle_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lottery_fortune_page.dart',
    'lib/features/fortune/presentation/pages/love_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_baseball_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart',
    'lib/features/fortune/presentation/pages/lucky_crypto_fortune_page.dart',
    'lib/features/fortune/presentation/pages/mbti_fortune_page.dart',
    'lib/features/fortune/presentation/pages/moving_date_fortune_page.dart',
    'lib/features/fortune/presentation/pages/moving_fortune_page.dart',
    'lib/features/fortune/presentation/pages/network_report_page.dart',
    'lib/features/fortune/presentation/pages/palmistry_fortune_page.dart',
    'lib/features/fortune/presentation/pages/past_life_fortune_page.dart',
    'lib/features/fortune/presentation/pages/pet_compatibility_page.dart',
    'lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart',
    'lib/features/fortune/presentation/pages/politician_fortune_page.dart',
    'lib/features/fortune/presentation/pages/saju_page.dart',
    'lib/features/fortune/presentation/pages/salpuli_fortune_page.dart',
    'lib/features/fortune/presentation/pages/talisman_enhanced_page.dart',
    'lib/features/fortune/presentation/pages/talisman_result_page.dart',
    'lib/features/fortune/presentation/pages/tarot_enhanced_page.dart',
    'lib/features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart',
    'lib/features/fortune/presentation/pages/traditional_fortune_page.dart',
    'lib/features/fortune/presentation/pages/traditional_fortune_result_page.dart',
    'lib/features/fortune/presentation/pages/wish_fortune_page.dart',
    'lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart',
    'lib/features/fortune/presentation/widgets/dream_input_widget.dart',
    'lib/features/fortune/presentation/widgets/lucky_color_detail_card.dart',
    'lib/features/fortune/presentation/widgets/lucky_food_detail_card.dart',
    'lib/features/fortune/presentation/widgets/lucky_item_detail_card.dart',
    'lib/features/fortune/presentation/widgets/lucky_number_detail_card.dart',
    'lib/features/interactive/presentation/pages/dream_interpretation_page.dart',
    'lib/features/interactive/presentation/pages/tarot_animated_flow_page.dart',
    'lib/presentation/widgets/enhanced_shareable_fortune_card.dart',
    'lib/presentation/widgets/saju_chart_widget.dart',
    'lib/screens/onboarding/widgets/birth_date_preview.dart',
    'lib/screens/onboarding/widgets/onboarding_progress_bar.dart',
    'lib/screens/physiognomy/physiognomy_screen.dart',
    'lib/screens/premium/premium_screen.dart',
    'lib/shared/components/base_card.dart',
    'lib/shared/components/fortune_loading_indicator.dart',
    'lib/shared/components/fortune_result_display.dart',
  ];
  
  for (final filePath in files) {
    await processFile(filePath);
  }
  
  // Also fix const errors in birthstone_fortune_page.dart
  await fixConstErrors();
  
  print('\n✅ Fixed all template placeholder errors!');
}

Future<void> processFile(String filePath) async {
  final file = File(filePath);
  
  if (!await file.exists()) {
    return; // Skip if file doesn't exist
  }
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Fix template placeholders
    final templatePattern = RegExp(r"Theme\.of\(context\)\.textTheme\.\$\{getTextThemeForSize\(size\)\}");
    content = content.replaceAllMapped(templatePattern, (match) {
      replacements++;
      return "Theme.of(context).textTheme.bodyMedium";
    });
    
    // Fix more specific patterns
    final templatePattern2 = RegExp(r"fontSize: Theme\.of\(context\)\.textTheme\.\$\{getTextThemeForSize\(size\)\}!\.fontSize");
    content = content.replaceAllMapped(templatePattern2, (match) {
      replacements++;
      return "fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize";
    });
    
    // Fix patterns with custom variable names
    final templatePattern3 = RegExp(r"Theme\.of\(context\)\.textTheme\.\$\{[^}]+\}");
    content = content.replaceAllMapped(templatePattern3, (match) {
      replacements++;
      return "Theme.of(context).textTheme.bodyMedium";
    });
    
    // Fix patterns with properties
    final templatePattern4 = RegExp(r"\.textTheme\.\$[^.]+\.(\w+)");
    content = content.replaceAllMapped(templatePattern4, (match) {
      replacements++;
      final property = match.group(1);
      return ".textTheme.bodyMedium?.$property";
    });
    
    if (replacements > 0) {
      await file.writeAsString(content);
      print('✓ Fixed $filePath ($replacements replacements)');
    }
  } catch (e) {
    print('Error processing $filePath: $e');
  }
}

Future<void> fixConstErrors() async {
  final file = File('lib/features/fortune/presentation/pages/birthstone_fortune_page.dart');
  
  if (!await file.exists()) {
    return;
  }
  
  try {
    String content = await file.readAsString();
    int replacements = 0;
    
    // Remove const from BoxDecoration with method calls
    content = content.replaceAllMapped(
      RegExp(r'const BoxDecoration\(\s*borderRadius: AppDimensions\.borderRadius\('),
      (match) {
        replacements++;
        return 'BoxDecoration(\n,
    borderRadius: AppDimensions.borderRadius(';
      }
    );
    
    // Remove const from BorderRadius.circular calls
    content = content.replaceAllMapped(
      RegExp(r'const BorderRadius\.circular\(AppSpacing'),
      (match) {
        replacements++;
        return 'BorderRadius.circular(AppSpacing';
      }
    );
    
    // Fix chemistry_page.dart const issue
    final chemFile = File('lib/features/fortune/presentation/pages/chemistry_page.dart');
    if (await chemFile.exists()) {
      String chemContent = await chemFile.readAsString();
      chemContent = chemContent.replaceAll(
        'const BorderRadius.circular(AppSpacing.spacing4 * 0.5)',
        'BorderRadius.circular(AppSpacing.spacing4 * 0.5)'
      );
      await chemFile.writeAsString(chemContent);
      print('✓ Fixed chemistry_page.dart const error');
    }
    
    if (replacements > 0) {
      await file.writeAsString(content);
      print('✓ Fixed birthstone_fortune_page.dart const errors ($replacements replacements)');
    }
  } catch (e) {
    print('Error fixing const,
    errors: $e');
  }
}