import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/services/deep_link_service.dart';

void main() {
  group('DeepLinkService route recovery', () {
    test('auth callback uri resolves to callback route with encoded url', () {
      final service = DeepLinkService();
      final uri = Uri.parse('com.beyond.fortune://auth-callback?code=abc123');

      final route = service.resolveRouteForUri(uri);
      final resolvedUri = Uri.parse(route);
      final encoded = resolvedUri.queryParameters['authCallbackUrl'];

      expect(route.startsWith('/auth/callback?authCallbackUrl='), isTrue);
      expect(encoded, isNotNull);
      expect(Uri.decodeComponent(encoded!), uri.toString());
    });

    test('screen deep link resolves to target route', () {
      final service = DeepLinkService();
      final uri = Uri.parse('com.beyond.fortune://deeplink?screen=chat');

      expect(service.resolveRouteForUri(uri), '/chat');
    });
  });
}
