import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../../services/social_auth_service.dart';
import '../../services/storage_service.dart';
import '../../core/utils/url_cleaner_stub.dart'
    if (dart.library.html) '../../core/utils/url_cleaner_web.dart';
import '../../core/utils/profile_validation.dart';
import '../../core/theme/toss_design_system.dart';

/// State management for LandingPage
/// Extracted from _LandingPageState to separate concerns
mixin LandingPageState<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  bool _isAuthProcessing = false;
  SocialAuthService? _socialAuthService;
  final _storageService = StorageService();
  Timer? _authTimeoutTimer;
  bool _isSupabaseAvailable = false;

  // Getters
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthProcessing => _isAuthProcessing;
  bool get isSupabaseAvailable => _isSupabaseAvailable;
  SocialAuthService? get socialAuthService => _socialAuthService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 상태 초기화 명확히 하기
    _isAuthProcessing = false;
    _isCheckingAuth = false;
    debugPrint('🔵 initState: _isAuthProcessing initialized to false');
    debugPrint('🔵 initState: _isCheckingAuth initialized to false');

    // Supabase 안전하게 초기화
    try {
      final client = Supabase.instance.client;
      _socialAuthService = SocialAuthService(client);
      _isSupabaseAvailable = true;
      debugPrint('✅ [LandingPage] Supabase client initialized successfully');
    } catch (e) {
      debugPrint('⚠️ [LandingPage] Supabase client not available, using offline mode: $e');
      _isSupabaseAvailable = false;
      _socialAuthService = null;
    }

    _initializeAuth();
  }

  void _initializeAuth() {
    // Check auth in background without blocking UI
    Future.microtask(() async {
      if (!_isSupabaseAvailable) {
        debugPrint('⚠️ [LandingPage] Skipping auth check - Supabase not available');
        return;
      }

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        if (mounted) {
          setState(() {
            _isCheckingAuth = true;
          });
        }
        await checkAuthState();
      }
      checkUrlParameters();
    });

    // Add timeout fallback to prevent infinite loading
    Timer(const Duration(seconds: 5), () {
      if (_isCheckingAuth && mounted) {
        debugPrint('⚠️ Auth check timeout - forcing _isCheckingAuth to false');
        setState(() => _isCheckingAuth = false);
      }
    });

    // Listen for auth state changes
    if (_isSupabaseAvailable) {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        await _handleAuthStateChange(data);
      });
    }
  }

  Future<void> _handleAuthStateChange(AuthState data) async {
    debugPrint('🔔 Auth state changed: ${data.event}');

    if (data.event == AuthChangeEvent.signedIn &&
        data.session != null &&
        mounted) {
      debugPrint('🟢 User signed in via OAuth, processing...');

      if (_isAuthProcessing) {
        setState(() => _isAuthProcessing = false);
        _authTimeoutTimer?.cancel();
      }

      await syncProfileFromSupabase();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: TossDesignSystem.successGreen,
          ),
        );
      }

      await _navigateAfterLogin();
    }
  }

  Future<void> _navigateAfterLogin() async {
    final needsOnboarding = await ProfileValidation.needsOnboarding();
    if (!mounted) return;

    if (needsOnboarding) {
      debugPrint('Profile incomplete, redirecting to onboarding...');
      // Note: Navigation should be handled by the widget
    } else {
      debugPrint('Profile complete, redirecting to home...');
      // Note: Navigation should be handled by the widget
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isAuthProcessing && _isSupabaseAvailable) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('🔄 Page resumed with no session - resetting auth state');
        resetAuthProcessing();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isAuthProcessing) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!_isSupabaseAvailable) return;

          final session = Supabase.instance.client.auth.currentSession;
          if (session == null && _isAuthProcessing && mounted) {
            debugPrint('OAuth cancelled - returning to login screen');
            resetAuthProcessing();
          }
        });
      }
    }
  }

  void resetAuthProcessing() {
    debugPrint('🔄 _resetAuthProcessing called - _isAuthProcessing: $_isAuthProcessing');
    if (mounted) {
      setState(() {
        _isAuthProcessing = false;
      });
      _authTimeoutTimer?.cancel();
      debugPrint('🔄 Auth processing reset complete');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 취소되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void startAuthTimeout() {
    _authTimeoutTimer?.cancel();
    _authTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isAuthProcessing && mounted) {
        debugPrint('OAuth timeout - resetting auth state');
        resetAuthProcessing();
      }
    });
  }

  Future<void> updateKakaoProfileName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final userMetadata = user.userMetadata;
      final kakaoId = userMetadata?['kakao_id'];

      debugPrint('🟡 [Kakao Profile Update] Current metadata name: ${userMetadata?['name']}');
      debugPrint('🟡 [Kakao Profile Update] Current metadata nickname: ${userMetadata?['nickname']}');
      debugPrint('🟡 [Kakao Profile Update] Kakao ID: $kakaoId');

      if (kakaoId == null) {
        debugPrint('🟡 [Kakao Profile Update] Not a Kakao user, skipping');
        return;
      }

      try {
        final kakaoUser = await kakao.UserApi.instance.me();
        final kakaoNickname = kakaoUser.kakaoAccount?.profile?.nickname ??
            (kakaoUser.kakaoAccount?.name ?? '사용자');

        debugPrint('🟡 [Kakao Profile Update] Retrieved nickname from Kakao SDK: $kakaoNickname');

        if (kakaoNickname != '사용자') {
          await Supabase.instance.client
              .from('user_profiles')
              .update({'name': kakaoNickname})
              .eq('id', user.id);

          debugPrint('🟡 [Kakao Profile Update] Updated Supabase profile name to: $kakaoNickname');

          final localProfile = await _storageService.getUserProfile();
          if (localProfile != null) {
            localProfile['name'] = kakaoNickname;
            await _storageService.saveUserProfile(localProfile);
            debugPrint('🟡 [Kakao Profile Update] Updated local profile name');
          }
        } else {
          debugPrint('🟡 [Kakao Profile Update] Kakao nickname is still default, not updating');
        }
      } catch (kakaoError) {
        debugPrint('🟡 [Kakao Profile Update] Error fetching from Kakao SDK: $kakaoError');
        debugPrint('🟡 [Kakao Profile Update] Falling back to metadata');
      }
    } catch (e) {
      debugPrint('🟡 [Kakao Profile Update] Error updating profile: $e');
    }
  }

  Future<void> syncProfileFromSupabase() async {
    if (!_isSupabaseAvailable) {
      debugPrint('⚠️ [LandingPage] Skipping profile sync - Supabase not available');
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      debugPrint('user: ${user.id}');

      var response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        debugPrint('Profile found in Supabase, saving to local storage');

        if (response['name'] != null &&
            response['birth_date'] != null &&
            response['gender'] != null) {
          response['onboarding_completed'] = true;
        }

        await _storageService.saveUserProfile(response);
      } else {
        debugPrint('No profile found in Supabase');
        await _createNewProfile(user);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> _createNewProfile(User user) async {
    debugPrint('Creating new profile for OAuth user...');
    debugPrint('metadata: ${user.userMetadata}');
    debugPrint('metadata: ${user.appMetadata}');

    final profileData = {
      'id': user.id,
      'email': user.email,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': null
    };

    if (user.userMetadata != null) {
      if (user.userMetadata?['full_name'] != null) {
        profileData['name'] = user.userMetadata?['full_name'];
      } else if (user.userMetadata?['name'] != null) {
        profileData['name'] = user.userMetadata?['name'];
      } else {
        profileData['name'] = '사용자';
      }

      if (user.userMetadata?['avatar_url'] != null) {
        profileData['profile_image_url'] = user.userMetadata?['avatar_url'];
      } else if (user.userMetadata?['picture'] != null) {
        profileData['profile_image_url'] = user.userMetadata?['picture'];
      }
    } else {
      profileData['name'] = '사용자';
    }

    try {
      final profileWithSocialAuth = Map<String, dynamic>.from(profileData);
      profileWithSocialAuth['primary_provider'] =
          user.appMetadata['provider'] ?? 'google';
      profileWithSocialAuth['linked_providers'] = [
        user.appMetadata['provider'] ?? 'google'
      ];

      await Supabase.instance.client
          .from('user_profiles')
          .insert(profileWithSocialAuth);
      debugPrint('Profile created successfully with social auth columns');

      await _storageService.saveUserProfile(profileWithSocialAuth);
    } catch (insertError) {
      debugPrint('Error saving profile: $insertError');

      if (insertError.toString().contains('linked_providers') ||
          insertError.toString().contains('primary_provider')) {
        debugPrint('Social auth columns not found, creating profile without them...');
        try {
          await Supabase.instance.client
              .from('user_profiles')
              .insert(profileData);
          debugPrint('Profile created successfully without social auth columns');

          await _storageService.saveUserProfile(profileData);
        } catch (fallbackError) {
          debugPrint('Error saving profile: $fallbackError');
        }
      } else {
        debugPrint('Profile creation failed with unexpected error');
      }
    }
  }

  Future<void> checkAuthState() async {
    if (!_isSupabaseAvailable) {
      debugPrint('⚠️ [LandingPage] Skipping auth state check - Supabase not available');
      return;
    }

    debugPrint('🔍 _checkAuthState: Starting auth check, _isCheckingAuth is $_isCheckingAuth');
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        debugPrint('No session found, staying on landing page');
        debugPrint('🔍 _checkAuthState: Setting _isCheckingAuth to false');
        if (mounted) {
          setState(() {
            _isCheckingAuth = false;
            debugPrint('✅ _checkAuthState: _isCheckingAuth set to false');
          });
          WidgetsBinding.instance.ensureVisualUpdate();
          debugPrint('🔍 _checkAuthState: ensureVisualUpdate() called');
        }
        return;
      }

      await syncProfileFromSupabase();

      final needsOnboarding = await ProfileValidation.needsOnboarding();

      if (needsOnboarding) {
        debugPrint('User needs onboarding, staying on landing page');
      } else {
        // Note: Navigation should be handled by the widget
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  void checkUrlParameters() {
    final uri = Uri.base;
    final error = uri.queryParameters['error'];

    if (error != null) {
      String message = '';
      switch (error) {
        case 'session_expired':
          message = '세션이 만료되었습니다. 다시 로그인해 주세요.';
          break;
        case 'auth_failure':
          message = '로그인 처리 중 문제가 발생했습니다. 다시 시도해 주세요.';
          break;
        case 'timeout':
          message = '로그인 처리 시간이 초과되었습니다. 다시 시도해 주세요.';
          break;
        case 'no_session':
          message = '세션을 찾을 수 없습니다. 다시 로그인해 주세요.';
          break;
        case 'pkce_failure':
          message = 'PKCE 인증에 실패했습니다. 다시 로그인해 주세요.';
          break;
        default:
          message = '로그인 중 문제가 발생했습니다.';
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: TossDesignSystem.errorRed));

        if (kIsWeb) {
          final cleanUrl = uri.path;
          cleanUrlInBrowser(cleanUrl);
        }
      });
    }
  }

  void setAuthProcessing(bool value) {
    if (mounted) {
      setState(() {
        _isAuthProcessing = value;
      });
    }
  }
}
