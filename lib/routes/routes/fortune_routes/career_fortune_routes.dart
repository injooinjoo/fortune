import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/talent_fortune_input_page.dart';
import '../../../features/fortune/presentation/pages/talent_fortune_results_page.dart';
import '../../../features/fortune/domain/models/talent_input_model.dart';
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
      final inputData = state.extra as TalentInputData;
      return TalentFortuneResultsPage(inputData: inputData);
    }),

  // All other career routes merged into /career in route_config.dart
];