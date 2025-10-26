import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/talent_fortune_input_page.dart';
import '../../../features/fortune/presentation/pages/talent_fortune_results_page.dart';
import '../../../features/fortune/domain/models/talent_input_model.dart';
import '../../../core/models/fortune_result.dart';
// Removed merged career pages: career_seeker, employment, career_change, career_future, startup_career
// Removed merged lucky pages: lucky_investment, lucky_stock
// All merged into /career and /investment-enhanced in FortuneListPage

final careerFortuneRoutes = [
  // Talent Input (3단계 입력) - Only used routes remain
  GoRoute(
    path: '/talent-fortune-input',
    name: 'talent-fortune-input',
    builder: (context, state) => const TalentFortuneInputPage()),

  // Talent Results (결과 페이지)
  GoRoute(
    path: '/talent-fortune-results',
    name: 'talent-fortune-results',
    builder: (context, state) {
      // ✅ Map 형태로 전달받음: {'inputData': TalentInputData, 'fortuneResult': FortuneResult}
      final extra = state.extra;

      if (extra is Map<String, dynamic>) {
        // ✅ 입력 페이지에서 API 결과와 함께 전달받은 경우
        final inputData = extra['inputData'] as TalentInputData;
        final fortuneResult = extra['fortuneResult'] as FortuneResult?;
        return TalentFortuneResultsPage(
          inputData: inputData,
          fortuneResult: fortuneResult,
        );
      } else {
        // ✅ Fallback: TalentInputData만 전달받은 경우 (하위 호환성)
        final inputData = extra as TalentInputData;
        return TalentFortuneResultsPage(inputData: inputData);
      }
    }),

  // All other career routes merged into /career in route_config.dart
];