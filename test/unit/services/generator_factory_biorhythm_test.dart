import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/services/generator_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('GeneratorFactory biorhythm normalization', () {
    late _MockSupabaseClient supabaseClient;
    late _MockFunctionsClient functionsClient;
    late GeneratorFactory generatorFactory;

    setUp(() {
      supabaseClient = _MockSupabaseClient();
      functionsClient = _MockFunctionsClient();
      generatorFactory = GeneratorFactory(supabaseClient);

      when(() => supabaseClient.functions).thenReturn(functionsClient);
    });

    test('normalizes targetDate object and accepts string summary response',
        () async {
      Map<String, dynamic>? capturedBody;

      when(
        () => functionsClient.invoke(
          'fortune-biorhythm',
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
              'title': '바이오리듬 분석',
              'summary': '내일은 상승 국면이에요.',
              'status_message': '내일은 상승 국면이에요.',
            },
          },
        );
      });

      final result = await generatorFactory.generate(
        fortuneType: 'biorhythm',
        inputConditions: const {
          'targetDate': {
            'date': '2026-03-18T00:00:00.000',
            'selectedDate': '2026-03-18',
            'events': [],
            'eventCount': 0,
          },
        },
        dataSource: GeneratorDataSource.api,
      );

      expect(capturedBody?['targetDate'], '2026-03-18');
      expect(capturedBody?['target_date'], '2026-03-18');
      expect(result.summary['message'], '내일은 상승 국면이에요.');
    });
  });
}
