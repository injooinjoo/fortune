import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('shouldBlockChatRestorationOverlay', () {
    test('blocks during initial session restoration', () {
      expect(
        shouldBlockChatRestorationOverlay(AuthChangeEvent.initialSession),
        isTrue,
      );
    });

    test('does not block during interactive sign-in', () {
      expect(
        shouldBlockChatRestorationOverlay(AuthChangeEvent.signedIn),
        isFalse,
      );
    });

    test('does not block during token refresh', () {
      expect(
        shouldBlockChatRestorationOverlay(AuthChangeEvent.tokenRefreshed),
        isFalse,
      );
    });
  });
}
