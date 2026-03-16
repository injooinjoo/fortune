import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/services/generator_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('GeneratorFactory talisman fallback routing', () {
    late _MockSupabaseClient supabaseClient;
    late _MockFunctionsClient functionsClient;
    late GeneratorFactory generatorFactory;

    setUp(() {
      supabaseClient = _MockSupabaseClient();
      functionsClient = _MockFunctionsClient();
      generatorFactory = GeneratorFactory(supabaseClient);

      when(() => supabaseClient.functions).thenReturn(functionsClient);
    });

    test(
      'retries legacy talisman function after 404 and normalizes payload',
      () async {
        Map<String, dynamic>? primaryBody;
        Map<String, dynamic>? fallbackBody;

        when(
          () => functionsClient.invoke(
            'generate-talisman',
            body: any(named: 'body'),
          ),
        ).thenAnswer((invocation) async {
          primaryBody = Map<String, dynamic>.from(
            invocation.namedArguments[#body] as Map,
          );
          throw const FunctionException(
            status: 404,
            details: {
              'code': 'NOT_FOUND',
              'message': 'Requested function was not found',
            },
            reasonPhrase: 'Not Found',
          );
        });

        when(
          () => functionsClient.invoke(
            'fortune-talisman',
            body: any(named: 'body'),
          ),
        ).thenAnswer((invocation) async {
          fallbackBody = Map<String, dynamic>.from(
            invocation.namedArguments[#body] as Map,
          );
          return FunctionResponse(
            status: 200,
            data: {
              'success': true,
              'id': 'legacy-talisman-id',
              'imageUrl': 'https://example.com/talisman.png',
              'shortDescription': '행운을 불러오는 부적이에요.',
            },
          );
        });

        final result = await generatorFactory.generate(
          fortuneType: 'talisman',
          inputConditions: const {
            'userId': 'user-1',
            'purpose': 'love_relationship',
            'situation': 'exam',
          },
          dataSource: GeneratorDataSource.api,
        );

        expect(primaryBody?['userId'], 'user-1');
        expect(primaryBody?['category'], 'love_relationship');
        expect(fallbackBody?['userId'], 'user-1');
        expect(fallbackBody?['category'], 'love_relationship');
        expect(result.id, 'legacy-talisman-id');
        expect(result.title, '부적');
        expect(result.summary['message'], '행운을 불러오는 부적이에요.');
        expect(result.data['imageUrl'], 'https://example.com/talisman.png');
      },
    );
  });
}
