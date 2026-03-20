import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/services/session_cleanup_service.dart';

void main() {
  group('SessionCleanupService', () {
    test('continues cleanup after failures and rethrows sign-out errors',
        () async {
      final calls = <String>[];
      final service = SessionCleanupService.test(
        signOut: () async {
          calls.add('signOut');
          throw StateError('auth failed');
        },
        clearUserProfile: () async => calls.add('clearUserProfile'),
        clearActiveProfileOverride: () async =>
            calls.add('clearActiveProfileOverride'),
        clearGuestMode: () async {
          calls.add('clearGuestMode');
          throw StateError('guest mode failed');
        },
        clearGuestId: () async => calls.add('clearGuestId'),
        clearAllCache: () async => calls.add('clearAllCache'),
        clearAllConversations: () async => calls.add('clearAllConversations'),
        clearAllAffinities: () async => calls.add('clearAllAffinities'),
      );

      await expectLater(
        service.signOutAndClearSession(),
        throwsA(isA<StateError>()),
      );

      expect(
        calls,
        equals([
          'signOut',
          'clearUserProfile',
          'clearActiveProfileOverride',
          'clearGuestMode',
          'clearGuestId',
          'clearAllCache',
          'clearAllConversations',
          'clearAllAffinities',
        ]),
      );
    });
  });
}
