import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/services/generator_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('GeneratorFactory dream payload normalization', () {
    late _MockSupabaseClient supabaseClient;
    late _MockFunctionsClient functionsClient;
    late GeneratorFactory generatorFactory;

    setUp(() {
      supabaseClient = _MockSupabaseClient();
      functionsClient = _MockFunctionsClient();
      generatorFactory = GeneratorFactory(supabaseClient);

      when(() => supabaseClient.functions).thenReturn(functionsClient);
    });

    test('normalizes legacy dream survey keys before invoking function',
        () async {
      Map<String, dynamic>? capturedBody;

      when(
        () => functionsClient.invoke(
          'fortune-dream',
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        capturedBody = Map<String, dynamic>.from(
          invocation.namedArguments[#body] as Map,
        );
        return FunctionResponse(
          status: 200,
          data: {
            'success': true,
            'data': {
              'interpretation': '해석 결과',
            },
          },
        );
      });

      final result = await generatorFactory.generate(
        fortuneType: 'dream',
        inputConditions: const {
          'dreamContent': '  똥쌈  ',
          'emotion': 'scary',
        },
        dataSource: GeneratorDataSource.api,
      );

      expect(result.title, '해석 결과');
      expect(capturedBody?['dream'], '똥쌈');
      expect(capturedBody?['dream_content'], '똥쌈');
      expect(capturedBody?['dreamEmotion'], 'scary');
      expect(capturedBody?['dream_emotion'], 'scary');
    });
  });
}
