import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/tojeong_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/traditional_saju_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/palmistry_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/physiognomy_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/physiognomy_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/physiognomy_input_page.dart';
import '../../../features/fortune/presentation/pages/physiognomy_result_page.dart';
import '../../../features/fortune/presentation/pages/salpuli_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/saju_psychology_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/traditional_fortune_unified_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/traditional_fortune_result_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/face_reading_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/face_reading_unified_page.dart' as fortune_pages;

final traditionalFortuneRoutes = [
  // Traditional Fortune Unified
  GoRoute(
    path: 'traditional',
    name: 'fortune-traditional',
    builder: (context, state) => const fortune_pages.TraditionalFortuneUnifiedPage()),
  
  // Traditional Fortune Unified (Alternative route)
  GoRoute(
    path: 'traditional-unified',
    name: 'fortune-traditional-unified',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      if (extra != null && extra['fortuneData'] != null) {
        return fortune_pages.TraditionalFortuneResultPage(
          fortuneData: extra['fortuneData']);
      }
      // If no fortune data, navigate to input page
      return const fortune_pages.TraditionalFortuneEnhancedPage();
    }),
  
  // Tojeong
  GoRoute(
    path: 'tojeong',
    name: 'fortune-tojeong',
    builder: (context, state) => const fortune_pages.TojeongFortunePage()),
  
  // Traditional Saju
  GoRoute(
    path: 'traditional-saju',
    name: 'fortune-traditional-saju',
    builder: (context, state) => const fortune_pages.TraditionalSajuFortunePage()),
  
  // Palmistry
  GoRoute(
    path: 'palmistry',
    name: 'fortune-palmistry',
    builder: (context, state) => const fortune_pages.PalmistryFortunePage()),
  
  // Physiognomy
  GoRoute(
    path: 'physiognomy',
    name: 'fortune-physiognomy',
    builder: (context, state) => const PhysiognomyEnhancedPage(),
    routes: [
      GoRoute(
        path: 'input',
        name: 'physiognomy-input',
        builder: (context, state) => const PhysiognomyInputPage()),
      GoRoute(
        path: 'result',
        name: 'physiognomy-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final data = extra?['data'] as PhysiognomyData?;
          if (data == null) {
            // If no data, redirect to main physiognomy page
            return const PhysiognomyEnhancedPage();
          }
          return PhysiognomyResultPage(data: data);
        })]),
  
  // Physiognomy Old
  GoRoute(
    path: 'physiognomy-old',
    name: 'fortune-physiognomy-old',
    builder: (context, state) => const fortune_pages.PhysiognomyFortunePage()),
  
  // Salpuli
  GoRoute(
    path: 'salpuli',
    name: 'fortune-salpuli',
    builder: (context, state) => const fortune_pages.SalpuliFortunePage()),
  
  // Saju Psychology
  GoRoute(
    path: 'saju-psychology',
    name: 'fortune-saju-psychology',
    builder: (context, state) => const fortune_pages.SajuPsychologyFortunePage()),
  
  // Face Reading
  GoRoute(
    path: 'face-reading',
    name: 'fortune-face-reading',
    builder: (context, state) => const fortune_pages.FaceReadingUnifiedPage())];