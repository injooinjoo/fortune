import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/constants/edge_functions_endpoints.dart';
import 'package:ondo/core/fortune/fortune_type_registry.dart';

void main() {
  group('fortune routing contract', () {
    test('routes character fortune types to dedicated edge functions', () {
      expect(
        FortuneTypeRegistry.endpointOf('personality-dna'),
        '/personality-dna',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('personality-dna'),
        '/personality-dna',
      );
      expect(
        EdgeFunctionsEndpoints.mapOldEndpoint('/api/fortune/personality-dna'),
        '/personality-dna',
      );

      expect(
        FortuneTypeRegistry.endpointOf('zodiac'),
        '/fortune-constellation',
      );
      expect(
        FortuneTypeRegistry.resolveApiType('zodiac'),
        'constellation',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('zodiac'),
        '/fortune-constellation',
      );

      expect(
        FortuneTypeRegistry.endpointOf('birthstone'),
        '/fortune-birthstone',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('birthstone'),
        '/fortune-birthstone',
      );

      expect(
        FortuneTypeRegistry.endpointOf('family', answers: {
          'concern': 'health',
        }),
        '/fortune-family-health',
      );
      expect(
        FortuneTypeRegistry.endpointOf('family', answers: {
          'concern': 'relationship',
        }),
        '/fortune-family-relationship',
      );
      expect(
        FortuneTypeRegistry.endpointOf('family', answers: {
          'concern': 'wealth',
        }),
        '/fortune-family-wealth',
      );
    });

    test('keeps explicit endpoint aliases stable', () {
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('zodiac-animal'),
        '/fortune-zodiac-animal',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('constellation'),
        '/fortune-constellation',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('pet-compatibility'),
        '/fortune-pet-compatibility',
      );
      expect(
        EdgeFunctionsEndpoints.getEndpointForType('yearly-encounter'),
        '/fortune-yearly-encounter',
      );
    });
  });
}
