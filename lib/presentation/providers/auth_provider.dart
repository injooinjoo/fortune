import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/supabase_helper.dart';
import '../../data/models/user_profile.dart';
import '../../services/user_statistics_service.dart';
import '../../services/storage_service.dart';
import '../../services/widget_service.dart';
import '../../services/widget_data_service.dart';
import '../../services/oauth_in_app_browser_coordinator.dart';
import '../../services/notification/fcm_service.dart';
import '../../features/character/data/services/active_character_chat_registry.dart';
import '../../features/character/data/services/character_chat_service.dart';
import '../../features/character/data/services/follow_up_scheduler.dart';
import '../../features/character/presentation/providers/active_chat_provider.dart';
import '../../features/character/presentation/providers/character_chat_provider.dart';
import '../../features/character/presentation/providers/character_chat_survey_provider.dart';
import '../../features/character/presentation/providers/sorted_characters_provider.dart';
import '../../core/services/chat_sync_service.dart';
import '../../core/services/user_scope_service.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Auth token provider
final authTokenProvider = FutureProvider<String?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final session = client.auth.currentSession;
  return session?.accessToken;
});

// Current user provider
final userProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);

  Logger.info('🔍 [userProvider] Creating user provider stream');
  Logger.info('user: ${client.auth.currentUser?.id}');
  Logger.info('email: ${client.auth.currentUser?.email}');

  // Listen to auth state changes
  ref.listen(authStateProvider, (previous, next) {
    Logger.info('🔍 [userProvider] Auth state changed');
    Logger.info(
        '🔍 [userProvider] Previous: ${previous?.value?.session?.user.id}');
    Logger.info('🔍 [userProvider] Next: ${next.value?.session?.user.id}');
    Logger.info('🔍 [userProvider] Session: ${next.value?.session != null}');
    Logger.info('type: ${next.value?.event}');
  });

  final user = client.auth.currentUser;
  if (user == null) {
    Logger.info('❌ [userProvider] No current user found');
  } else {
    Logger.info('found: ${user.id}');
  }

  return Stream.value(user);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final storageService = StorageService();
  final statisticsService = UserStatisticsService(client, storageService);
  return AuthService(client, statisticsService);
});

/// 로그인 직후 대화 목록 일괄 복원 진행 상태
final chatRestorationInProgressProvider = StateProvider<bool>((ref) => false);

bool shouldBlockChatRestorationOverlay(AuthChangeEvent event) {
  return event == AuthChangeEvent.initialSession;
}

final notificationDeviceSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
    next.whenData((authState) async {
      if (authState == null) return;

      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.tokenRefreshed ||
          authState.event == AuthChangeEvent.initialSession) {
        await FCMService().syncCurrentDevice();
      }
    });
  });
});

// Auth service class
class AuthService {
  final SupabaseClient _client;
  final UserStatisticsService _statisticsService;

  AuthService(this._client, this._statisticsService);

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signUp(
      {required String email,
      required String password,
      Map<String, dynamic>? metadata}) async {
    try {
      final response = await _client.auth
          .signUp(email: email, password: password, data: metadata);

      if (response.user != null) {
        Logger.securityCheckpoint('up: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      Logger.error('Sign up failed', e);
      rethrow;
    }
  }

  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        Logger.securityCheckpoint('in: ${response.user!.id}');

        // Update consecutive days on sign in
        try {
          await _statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
      }

      return response;
    } catch (e) {
      Logger.error('Sign in failed', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      try {
        await FCMService().deactivateCurrentDevice();
      } catch (e) {
        Logger.warning('[AuthService] FCM 디바이스 비활성화 실패 (무시): $e');
      }
      await _client.auth.signOut();
      Logger.securityCheckpoint('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      Logger.info('Supabase initialized successfully');
    } catch (e) {
      Logger.error('Password reset failed', e);
      rethrow;
    }
  }

  Future<UserResponse> updateUser(
      {String? email, String? password, Map<String, dynamic>? metadata}) async {
    try {
      final response = await _client.auth.updateUser(
          UserAttributes(email: email, password: password, data: metadata));

      Logger.info('User updated');
      return response;
    } catch (e) {
      Logger.error('User update failed', e);
      rethrow;
    }
  }

  Future<UserProfile?> ensureUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // Use helper function to ensure profile exists
      final profileData = await SupabaseHelper.ensureUserProfile(
          userId: user.id,
          email: user.email ?? 'unknown@example.com',
          name: user.userMetadata?['name'] as String? ??
              user.userMetadata?['full_name'],
          profileImageUrl: user.userMetadata?['avatar_url']);

      if (profileData != null) {
        return UserProfile.fromJson(profileData);
      }

      return null;
    } catch (e) {
      Logger.error('Failed to ensure user profile', e);
      return null;
    }
  }

  Future<bool> hasUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return false;

      return response['onboarding_completed'] == true;
    } catch (e) {
      Logger.error('Error checking user profile', e);
      return false;
    }
  }
}

/// 채팅 데이터 복원 프로바이더
/// 로그인/세션 복구 시 서버에서 모든 캐릭터 대화를 불러와 로컬에 저장
final chatRestorationProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
    next.whenData((authState) async {
      if (authState == null) return;
      await OAuthInAppBrowserCoordinator.onAuthStateChanged(authState);

      // 스코프 갱신은 auth 이벤트마다 수행
      await UserScopeService.instance.refreshCurrentScope();

      if (authState.event == AuthChangeEvent.signedOut) {
        ActiveCharacterChatRegistry.setActiveCharacterId(null);
        ref.read(chatRestorationInProgressProvider.notifier).state = false;
        // 로그아웃 시 캐릭터 세션 경계 강제
        FollowUpScheduler().cancelAll();
        ref.invalidate(characterChatProvider);
        ref.invalidate(characterChatSurveyProvider);
        ref.invalidate(sortedCharactersProvider);
        ref.invalidate(activeCharacterChatProvider);
        return;
      }

      final userId = authState.session?.user.id;
      if (userId == null) return;

      // 로그인/세션 복구 시에만 대화 복원
      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.initialSession) {
        final shouldBlockRestoration =
            shouldBlockChatRestorationOverlay(authState.event);
        ref.read(chatRestorationInProgressProvider.notifier).state =
            shouldBlockRestoration;
        try {
          if (!shouldBlockRestoration) {
            Logger.info('[ChatRestoration] 백그라운드 복원으로 전환');
          }

          // 게스트 큐 owner를 현재 로그인 owner로 승격 후 동기화
          await ChatSyncService.instance.migrateGuestData(userId);

          Logger.info('[ChatRestoration] 대화 복원 시작...');
          final chatService = CharacterChatService();
          final restoredConversations =
              await chatService.loadAllConversations();

          if (restoredConversations.isNotEmpty) {
            Logger.info(
                '[ChatRestoration] ${restoredConversations.length}개 캐릭터 대화 복원 완료');
          } else {
            Logger.info('[ChatRestoration] 복원할 대화 없음');
          }
        } catch (e) {
          Logger.warning('[ChatRestoration] 대화 복원 실패 (비치명적): $e');
        } finally {
          // 복원 완료 시점에 캐시를 무효화해야 목록이 최신 로컬 데이터를 즉시 반영한다.
          ref.invalidate(characterChatProvider);
          ref.invalidate(characterChatSurveyProvider);
          ref.invalidate(sortedCharactersProvider);
          ref.invalidate(activeCharacterChatProvider);
          ref.read(chatRestorationInProgressProvider.notifier).state = false;
        }
      }
    });
  });
});

/// 위젯 데이터 준비 프로바이더
/// auth 상태 변경 시 자동으로 위젯 데이터 준비
/// - Android: 위젯 설치 확인 후 API 호출
/// - iOS: 앱 시작 시 무조건 API 호출 (감지 불가)
final widgetDataPreparationProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
    next.whenData((authState) async {
      if (authState == null) return;

      final userId = authState.session?.user.id;
      if (userId == null) {
        // 로그아웃 시 캐시 해제
        if (authState.event == AuthChangeEvent.signedOut) {
          WidgetService.clearUserId();
          Logger.info('[Widget] 로그아웃 - 사용자 ID 캐시 해제');
        }
        return;
      }

      // 로그인/세션 복구 시 위젯 데이터 준비
      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.tokenRefreshed ||
          authState.event == AuthChangeEvent.initialSession) {
        try {
          await WidgetService.initialize();

          // 위젯 설치 확인 (Android만 실제 확인, iOS는 항상 true)
          final isInstalled = await WidgetDataService.isWidgetInstalled();

          if (isInstalled) {
            WidgetService.setUserId(userId);
            await WidgetService.refreshWidgetData(userId);
            Logger.info('[Widget] 위젯 데이터 준비 완료');
          } else {
            Logger.info('[Widget] 위젯 미설치 - 데이터 준비 건너뜀');
          }
        } catch (e) {
          Logger.warning('[Widget] 위젯 데이터 준비 실패 (비치명적): $e');
        }
      }
    });
  });
});
