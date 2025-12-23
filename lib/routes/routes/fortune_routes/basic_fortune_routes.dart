import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/mbti_fortune_page.dart';
import '../../../features/fortune/presentation/pages/wish_fortune_page.dart';
import '../../../features/fortune/presentation/pages/naming/naming_fortune_page.dart';
// Removed merged pages: saju, destiny, network_report
// saju/destiny merged into /traditional in FortuneListPage

final basicFortuneRoutes = [
  // MBTI (MBTI 운세)
  GoRoute(
    path: '/mbti',
    name: 'fortune-mbti',
    builder: (context, state) => const MbtiFortunePage()),

  // Wish (소원 빌기)
  GoRoute(
    path: '/wish',
    name: 'fortune-wish',
    builder: (context, state) => const WishFortunePage()),

  // Naming (작명 운세)
  GoRoute(
    path: '/naming',
    name: 'fortune-naming',
    builder: (context, state) => const NamingFortunePage()),
];