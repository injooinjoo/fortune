import 'package:go_router/go_router.dart';
import '../../features/trend/presentation/pages/trend_psychology_test_page.dart';
import '../../features/trend/presentation/pages/trend_ideal_worldcup_page.dart';
import '../../features/trend/presentation/pages/trend_balance_game_page.dart';

/// 트렌드 콘텐츠 라우트 (outside shell - 네비게이션 바 숨김)
final trendRoutes = [
  // 심리테스트
  GoRoute(
    path: '/trend/psychology/:contentId',
    name: 'trend-psychology-test',
    builder: (context, state) {
      final contentId = state.pathParameters['contentId']!;
      return TrendPsychologyTestPage(contentId: contentId);
    },
  ),

  // 이상형 월드컵
  GoRoute(
    path: '/trend/worldcup/:contentId',
    name: 'trend-ideal-worldcup',
    builder: (context, state) {
      final contentId = state.pathParameters['contentId']!;
      return TrendIdealWorldcupPage(contentId: contentId);
    },
  ),

  // 밸런스 게임
  GoRoute(
    path: '/trend/balance/:contentId',
    name: 'trend-balance-game',
    builder: (context, state) {
      final contentId = state.pathParameters['contentId']!;
      return TrendBalanceGamePage(contentId: contentId);
    },
  ),
];
