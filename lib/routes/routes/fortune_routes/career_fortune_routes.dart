import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/career_fortune_page.dart';
import '../../../features/fortune/presentation/pages/career_seeker_fortune_page.dart';
import '../../../features/fortune/presentation/pages/business_fortune_page.dart';
import '../../../features/fortune/presentation/pages/startup_fortune_page.dart';
import '../../../features/fortune/presentation/pages/employment_fortune_page.dart';
import '../../../features/fortune/presentation/pages/talent_fortune_page.dart';
import '../../../features/fortune/presentation/pages/investment_fortune_unified_page.dart';
import '../../../features/fortune/presentation/pages/investment_fortune_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/investment_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_investment_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_stock_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_crypto_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_lottery_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_realestate_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_exam_fortune_page.dart';
import '../../../features/fortune/presentation/pages/career_change_fortune_page.dart';
import '../../../features/fortune/presentation/pages/career_crisis_fortune_page.dart';
import '../../../features/fortune/presentation/pages/career_future_fortune_page.dart';
import '../../../features/fortune/presentation/pages/freelance_fortune_page.dart';
import '../../../features/fortune/presentation/pages/startup_career_fortune_page.dart';
import '../../../features/fortune/presentation/widgets/career_fortune_selector.dart';
import '../../../domain/entities/fortune.dart';

final careerFortuneRoutes = [
  // Career
  GoRoute(
    path: '/career',
    name: 'fortune-career',
    builder: (context, state) => const CareerFortunePage()),
  
  // Career Seeker
  GoRoute(
    path: '/career-seeker',
    name: 'fortune-career-seeker',
    builder: (context, state) => const CareerSeekerFortunePage()),
  
  // Business
  GoRoute(
    path: '/business',
    name: 'fortune-business',
    builder: (context, state) => const BusinessFortunePage()),
  
  // Startup
  GoRoute(
    path: '/startup',
    name: 'fortune-startup',
    builder: (context, state) => const StartupFortunePage()),
  
  // Employment
  GoRoute(
    path: '/employment',
    name: 'fortune-employment',
    builder: (context, state) => const EmploymentFortunePage()),
  
  // Talent
  GoRoute(
    path: '/talent',
    name: 'fortune-talent',
    builder: (context, state) => const TalentFortunePage()),
  
  // Investment Unified
  GoRoute(
    path: '/investment',
    name: 'fortune-investment',
    builder: (context, state) => const InvestmentFortuneUnifiedPage()),
  
  // Investment Enhanced
  GoRoute(
    path: '/investment-enhanced',
    name: 'fortune-investment-enhanced',
    builder: (context, state) => const InvestmentFortuneEnhancedPage()),
  
  // Lucky Investment
  GoRoute(
    path: '/lucky-investment',
    name: 'fortune-lucky-investment',
    builder: (context, state) => const LuckyInvestmentFortunePage()),
  
  // Lucky Stock
  GoRoute(
    path: '/lucky-stock',
    name: 'fortune-lucky-stock',
    builder: (context, state) => const LuckyStockFortunePage()),
  
  // Lucky Crypto
  GoRoute(
    path: '/lucky-crypto',
    name: 'fortune-lucky-crypto',
    builder: (context, state) => const LuckyCryptoFortunePage()),
  
  // Lucky Lottery
  GoRoute(
    path: '/lucky-lottery',
    name: 'fortune-lucky-lottery',
    builder: (context, state) => const LuckyLotteryFortunePage()),
  
  // Lucky Real Estate
  GoRoute(
    path: '/lucky-realestate',
    name: 'fortune-lucky-realestate',
    builder: (context, state) => const LuckyRealEstateFortunePage()),
  
  // Lucky Exam
  GoRoute(
    path: '/lucky-exam',
    name: 'fortune-lucky-exam',
    builder: (context, state) => const LuckyExamFortunePage()),
  
  // Career Change
  GoRoute(
    path: '/career-change',
    name: 'fortune-career-change',
    builder: (context, state) => const CareerChangeFortunePage()),
  
  // Career Crisis
  GoRoute(
    path: '/career-crisis',
    name: 'fortune-career-crisis',
    builder: (context, state) => const CareerCrisisFortunePage()),
  
  // Career Future
  GoRoute(
    path: '/career-future',
    name: 'fortune-career-future',
    builder: (context, state) => const CareerFutureFortunePage()),
  
  // Freelance
  GoRoute(
    path: '/freelance',
    name: 'fortune-freelance',
    builder: (context, state) => const FreelanceFortunePage()),
  
  // Startup Career
  GoRoute(
    path: '/startup-career',
    name: 'fortune-startup-career',
    builder: (context, state) => const StartupCareerFortunePage()),
];