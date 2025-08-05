import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/career_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/career_seeker_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/business_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/startup_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/employment_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/talent_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/investment_fortune_unified_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/investment_fortune_enhanced_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/investment_fortune_result_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_investment_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_stock_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_crypto_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_lottery_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_realestate_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_exam_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/widgets/career_fortune_selector.dart';
import '../../../domain/entities/fortune.dart';

final careerFortuneRoutes = [
  // Career
  GoRoute(
    path: 'career',
    name: 'fortune-career',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      // If no specific type, show the selector
      final type = state.uri.queryParameters['type'];
      if (type == null) {
        return const CareerFortuneSelector();
      }
      // Otherwise show the original career fortune page
      return fortune_pages.CareerFortunePage(
        initialParams: extra);
    },
    routes: [
      // Career sub-routes
      GoRoute(
        path: 'seeker',
        name: 'fortune-career-seeker',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return fortune_pages.CareerSeekerFortunePage(
            initialParams: extra);
        }),
      GoRoute(
        path: 'change',
        name: 'fortune-career-change',
        builder: (context, state) {
          // TODO: Create CareerChangeFortunePage
          return const Center(
            child: Text('Career Change Fortune - Coming Soon'));
        }),
      GoRoute(
        path: 'future',
        name: 'fortune-career-future',
        builder: (context, state) {
          // TODO: Create CareerFutureFortunePage
          return const Center(
            child: Text('Career Future Fortune - Coming Soon'));
        }),
      GoRoute(
        path: 'freelance',
        name: 'fortune-career-freelance',
        builder: (context, state) {
          // TODO: Create FreelanceFortunePage
          return const Center(
            child: Text('Freelance Fortune - Coming Soon'));
        }),
      GoRoute(
        path: 'startup',
        name: 'fortune-career-startup',
        builder: (context, state) {
          // TODO: Create StartupFortunePage
          return const Center(
            child: Text('Startup Fortune - Coming Soon'));
        }),
      GoRoute(
        path: 'crisis',
        name: 'fortune-career-crisis',
        builder: (context, state) {
          // TODO: Create CareerCrisisFortunePage
          return const Center(
            child: Text('Career Crisis Fortune - Coming Soon'));
        })]),
  
  // Business
  GoRoute(
    path: 'business',
    name: 'fortune-business',
    builder: (context, state) => const fortune_pages.BusinessFortunePage()),
  
  // Startup
  GoRoute(
    path: 'startup',
    name: 'fortune-startup',
    builder: (context, state) => const fortune_pages.StartupFortunePage()),
  
  // Employment
  GoRoute(
    path: 'employment',
    name: 'fortune-employment',
    builder: (context, state) => const fortune_pages.EmploymentFortunePage()),
  
  // Talent
  GoRoute(
    path: 'talent',
    name: 'fortune-talent',
    builder: (context, state) => const fortune_pages.TalentFortunePage()),
  
  // Investment
  GoRoute(
    path: 'investment',
    name: 'fortune-investment',
    builder: (context, state) => const fortune_pages.InvestmentFortuneUnifiedPage()),
  
  // Investment Enhanced
  GoRoute(
    path: 'investment-enhanced',
    name: 'fortune-investment-enhanced',
    builder: (context, state) => const fortune_pages.InvestmentFortuneEnhancedPage(),
    routes: [
      GoRoute(
        path: 'result',
        name: 'fortune-investment-enhanced-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final fortune = extra?['fortune'] as Fortune?;
          final investmentData = extra?['investmentData'] as InvestmentFortuneData?;
          
          if (fortune == null || investmentData == null) {
            // If no data, redirect to main investment page
            return const fortune_pages.InvestmentFortuneEnhancedPage();
          }
          
          return fortune_pages.InvestmentFortuneResultPage(
            fortune: fortune,
            investmentData: investmentData);
        })]),
  
  // Lucky Investment
  GoRoute(
    path: 'lucky-investment',
    name: 'fortune-lucky-investment',
    builder: (context, state) => const fortune_pages.LuckyInvestmentFortunePage()),
  
  // Lucky Stock
  GoRoute(
    path: 'lucky-stock',
    name: 'fortune-lucky-stock',
    builder: (context, state) => const fortune_pages.LuckyStockFortunePage()),
  
  // Lucky Crypto
  GoRoute(
    path: 'lucky-crypto',
    name: 'fortune-lucky-crypto',
    builder: (context, state) => const fortune_pages.LuckyCryptoFortunePage()),
  
  // Lucky Lottery
  GoRoute(
    path: 'lucky-lottery',
    name: 'fortune-lucky-lottery',
    builder: (context, state) => const fortune_pages.LuckyLotteryFortunePage()),
  
  // Lucky Real Estate
  GoRoute(
    path: 'lucky-realestate',
    name: 'fortune-lucky-realestate',
    builder: (context, state) => const fortune_pages.LuckyRealEstateFortunePage()),
  
  // Lucky Exam
  GoRoute(
    path: 'lucky-exam',
    name: 'fortune-lucky-exam',
    builder: (context, state) => const fortune_pages.LuckyExamFortunePage())];