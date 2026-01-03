// route_config.dart - Chat-First 아키텍처: 채팅 중심 라우터 설정

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../features/chat/presentation/pages/chat_home_page.dart';
import '../features/face_ai/presentation/pages/face_ai_home_screen.dart';
import '../features/face_ai/presentation/pages/face_ai_camera_page.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_page.dart';
import '../screens/profile/saju_detail_page.dart';
import '../screens/profile/elements_detail_page.dart';
import '../screens/profile/profile_verification_page.dart';
import '../screens/profile/saju_summary_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/history/presentation/pages/fortune_history_detail_page.dart';
import '../features/history/domain/models/fortune_history.dart';
import '../screens/settings/social_accounts_screen.dart';
import '../screens/settings/phone_management_screen.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/premium/premium_screen.dart';

// Import feature pages
import '../features/trend/presentation/pages/trend_page.dart';
import '../features/notification/presentation/pages/notification_settings_page.dart';
import '../features/support/presentation/pages/help_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/payment/presentation/pages/token_purchase_page.dart';
import '../features/payment/presentation/pages/payment_result_page.dart';
import '../features/settings/presentation/pages/font_settings_page.dart';

// Import pages outside shell
import '../features/health/presentation/pages/health_fortune_page.dart';
import '../features/health/presentation/pages/medical_document_result_page.dart';
import '../features/health/domain/models/medical_document_models.dart';
import '../features/exercise/presentation/pages/exercise_fortune_page.dart';
import '../screens/subscription/subscription_page.dart';

// Import admin pages
import '../features/admin/pages/celebrity_crawling_page.dart';

// Import route groups
import 'routes/auth_routes.dart';
import 'routes/interactive_routes.dart';
import 'routes/trend_routes.dart';
import 'routes/wellness_routes.dart';

import '../core/utils/page_transitions.dart';
import '../core/utils/route_observer_logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// 전역 Navigator Key - FCM 딥링크 등에서 사용
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/chat',  // Chat-First 아키텍처: 채팅이 기본 진입점
    debugLogDiagnostics: false,
    observers: kDebugMode ? [RouteObserverLogger()] : [],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
    routes: [
      // Non-authenticated routes (outside shell)
      ...authRoutes,

      // Special onboarding route (not in shell)
      GoRoute(
        path: '/onboarding/toss-style',
        name: 'onboarding-toss-style',
        builder: (context, state) {
          final isPartial = state.uri.queryParameters['partial'] == 'true';
          return OnboardingPage(isPartialCompletion: isPartial);
        },
      ),

      // Face AI Camera (outside shell - full screen camera with Face Mesh)
      GoRoute(
        path: '/face-ai/camera',
        name: 'face-ai-camera',
        builder: (context, state) => const FaceAiCameraPage(),
      ),

      // Face AI Home (Chat에서 진입)
      GoRoute(
        path: '/fortune/face-ai',
        name: 'fortune-face-ai',
        builder: (context, state) => const FaceAiHomeScreen(),
      ),

      // Shell route that provides consistent background
      ShellRoute(
        builder: (context, state, child) => MainShell(
          state: state,
          child: child,
        ),
        routes: [
          // Chat route (Chat-First 홈 - 메인 진입점)
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const ChatHomePage(),
            ),
          ),

          // Home route (인사이트 - 프로필 바텀시트에서 접근)
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const HomeScreen(),
            ),
          ),

          // Profile routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ProfileEditPage(),
                ),
              ),
              GoRoute(
                path: 'saju',
                name: 'profile-saju',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const SajuDetailPage(),
                ),
              ),
              GoRoute(
                path: 'saju-summary',
                name: 'profile-saju-summary',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const SajuSummaryPage(),
                ),
              ),
              GoRoute(
                path: 'elements',
                name: 'profile-elements',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ElementsDetailPage(),
                ),
              ),
              GoRoute(
                path: 'verification',
                name: 'profile-verification',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ProfileVerificationPage(),
                ),
              ),
              GoRoute(
                path: 'history',
                name: 'profile-history',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const FortuneHistoryPage(),
                ),
              ),
              GoRoute(
                path: 'social-accounts',
                name: 'profile-social-accounts',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const SocialAccountsScreen(),
                ),
              ),
              GoRoute(
                path: 'phone-management',
                name: 'profile-phone-management',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const PhoneManagementScreen(),
                ),
              ),
              GoRoute(
                path: 'notifications',
                name: 'profile-notifications',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const NotificationSettingsPage(),
                ),
              ),
              GoRoute(
                path: 'font',
                name: 'profile-font',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const FontSettingsPage(),
                ),
              ),
            ],
          ),

          // Premium & Payment routes
          GoRoute(
            path: '/premium',
            name: 'premium',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const PremiumScreen(),
            ),
          ),

          // Trend page (프로필 바텀시트에서 접근)
          GoRoute(
            path: '/trend',
            name: 'trend',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const TrendPage(),
            ),
          ),

          // Interactive routes (inside shell)
          ...interactiveRoutes,
        ],
      ),

      // Wellness routes (outside shell - for focused wellness experience)
      ...wellnessRoutes,

      // Fortune history detail route (outside shell)
      GoRoute(
        path: '/fortune-history/:id',
        name: 'fortune-history-detail',
        pageBuilder: (context, state) {
          final history = state.extra as FortuneHistory;
          return PageTransitions.slideTransition(
            context,
            state,
            FortuneHistoryDetailPage(history: history),
          );
        },
      ),

      // Trend content routes (outside shell)
      ...trendRoutes,

      // Health routes (outside shell)
      GoRoute(
        path: '/health-toss',
        name: 'fortune-health-toss',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const HealthFortunePage(),
        ),
      ),
      GoRoute(
        path: '/medical-document-result',
        name: 'medical-document-result',
        pageBuilder: (context, state) {
          final uploadResult = state.extra as MedicalDocumentUploadResult;
          return PageTransitions.slideTransition(
            context,
            state,
            MedicalDocumentResultPage(uploadResult: uploadResult),
          );
        },
      ),
      GoRoute(
        path: '/exercise',
        name: 'fortune-exercise',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ExerciseFortunePage(),
        ),
      ),
      GoRoute(
        path: '/sports-game',
        name: 'fortune-sports-game',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ExerciseFortunePage(),
        ),
      ),

      // Other routes outside shell
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: '/token-purchase',
        name: 'token-purchase',
        builder: (context, state) => const TokenPurchasePage(),
      ),
      GoRoute(
        path: '/payment-result',
        name: 'payment-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentResultPage(
            isSuccess: extra?['isSuccess'] ?? false,
            message: extra?['message'],
            productName: extra?['productName'],
            amount: extra?['amount'],
            transactionId: extra?['transactionId'],
            tokenAmount: extra?['tokenAmount'],
            errorCode: extra?['errorCode'],
          );
        },
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServicePage(),
      ),

      // Admin routes (outside shell)
      GoRoute(
        path: '/admin/celebrity-crawling',
        name: 'admin-celebrity-crawling',
        builder: (context, state) => const CelebrityCrawlingPage(),
      ),
    ],
  );
});
