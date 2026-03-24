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
            'generationMode': 'prebuilt',
            'purpose': 'love_relationship',
            'situation': 'exam',
          },
          dataSource: GeneratorDataSource.api,
        );

        expect(primaryBody?['userId'], 'user-1');
        expect(primaryBody?['generationMode'], 'prebuilt');
        expect(primaryBody?['category'], 'love_relationship');
        expect(fallbackBody?['userId'], 'user-1');
        expect(fallbackBody?['generationMode'], 'prebuilt');
        expect(fallbackBody?['category'], 'love_relationship');
        expect(result.id, 'legacy-talisman-id');
        expect(result.title, '부적');
        expect(result.summary['message'], '행운을 불러오는 부적이에요.');
        expect(result.data['imageUrl'], 'https://example.com/talisman.png');
      },
    );

    test(
      'accepts wrapped talisman fallback response when image generation is skipped',
      () async {
        when(
          () => functionsClient.invoke(
            'generate-talisman',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 200,
            data: {
              'success': true,
              'data': {
                'id': 'talisman-fallback-1',
                'category': 'disaster_removal',
                'generationMode': 'premium_ai',
                'imageSource': 'catalog',
                'catalogAssetId': 'catalog-1',
                'shortDescription': '삼재와 액운을 막아주는 설명형 부적이에요.',
                'summary': '삼재와 액운을 막아주는 설명형 부적이에요.',
                'content': '삼재와 액운을 막아주는 설명형 부적이에요.',
                'imageGenerationSkipped': true,
                'imageGenerationFailed': true,
                'imageGenerationFailureReason': 'high_cost_model_blocked',
                'imageGenerationReason': 'high_cost_model_blocked',
                'warnings': ['현재 이미지 생성이 제한되어 설명형 부적으로 전환되었어요.'],
              },
            },
          ),
        );

        final result = await generatorFactory.generate(
          fortuneType: 'talisman',
          inputConditions: const {
            'userId': 'user-1',
            'generationMode': 'premium_ai',
            'purpose': 'disaster_removal',
          },
          dataSource: GeneratorDataSource.api,
        );

        expect(result.id, 'talisman-fallback-1');
        expect(result.title, '부적');
        expect(result.summary['message'], '삼재와 액운을 막아주는 설명형 부적이에요.');
        expect(result.data['imageGenerationSkipped'], isTrue);
        expect(result.data['imageGenerationFailed'], isTrue);
        expect(result.data['generationMode'], 'premium_ai');
        expect(result.data['imageSource'], 'catalog');
        expect(result.data['catalogAssetId'], 'catalog-1');
        expect(
          result.data['imageGenerationReason'],
          'high_cost_model_blocked',
        );
      },
    );
  });
}
