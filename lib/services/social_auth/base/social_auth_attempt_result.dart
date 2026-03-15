import 'package:supabase_flutter/supabase_flutter.dart';

enum SocialAuthAttemptStatus {
  authenticated,
  pendingExternalAuth,
  cancelled,
}

class SocialAuthAttemptResult {
  final SocialAuthAttemptStatus status;
  final AuthResponse? response;

  const SocialAuthAttemptResult._({
    required this.status,
    this.response,
  });

  const SocialAuthAttemptResult.authenticated(AuthResponse response)
      : this._(
          status: SocialAuthAttemptStatus.authenticated,
          response: response,
        );

  const SocialAuthAttemptResult.pendingExternalAuth()
      : this._(status: SocialAuthAttemptStatus.pendingExternalAuth);

  const SocialAuthAttemptResult.cancelled()
      : this._(status: SocialAuthAttemptStatus.cancelled);

  bool get isAuthenticated => status == SocialAuthAttemptStatus.authenticated;
  bool get isPendingExternalAuth =>
      status == SocialAuthAttemptStatus.pendingExternalAuth;
  bool get isCancelled => status == SocialAuthAttemptStatus.cancelled;

  User? get user => response?.user;
  Session? get session => response?.session;
}
