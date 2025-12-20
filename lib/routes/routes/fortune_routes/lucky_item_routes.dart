import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/lucky_items_page.dart';
import '../../../features/fortune/presentation/pages/lotto/lotto_fortune_page.dart';
// Removed merged pages: lucky_outfit, lucky_series, five_blessings
// All merged into /lucky-items in FortuneListPage

final luckyItemRoutes = [
  // Lucky Items (Unified) - 색깔/숫자/음식/아이템 통합
  GoRoute(
    path: '/lucky-items',
    name: 'fortune-lucky-items',
    builder: (context, state) => const LuckyItemsPage()),

  // Lotto Fortune - 로또 행운 번호 (분리됨)
  GoRoute(
    path: '/lotto',
    name: 'fortune-lotto',
    builder: (context, state) => const LottoFortunePage()),

  // Lucky Items Results Page
  // (결과 페이지는 메인에서 호출되므로 유지)
];