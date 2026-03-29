import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/config/environment.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final _testAnonKey = List.filled(120, 'a').join();

SupabaseClient _createTestSupabaseClient(String url) {
  return SupabaseClient(url, _testAnonKey);
}

void main() {
  group('Environment.resolveRuntimeEnvFile', () {
    test('uses .env for test mode', () {
      expect(
        Environment.resolveRuntimeEnvFile(
          isTestMode: true,
          isReleaseMode: false,
        ),
        Environment.defaultEnvFile,
      );
    });

    test('uses .env.development for debug runtime', () {
      expect(
        Environment.resolveRuntimeEnvFile(
          isTestMode: false,
          isReleaseMode: false,
        ),
        Environment.developmentEnvFile,
      );
    });

    test('uses .env for release runtime', () {
      expect(
        Environment.resolveRuntimeEnvFile(
          isTestMode: false,
          isReleaseMode: true,
        ),
        Environment.defaultEnvFile,
      );
    });
  });

  group('Environment.shouldFallbackToDefaultEnv', () {
    test('falls back when development env is still placeholder', () {
      expect(
        Environment.shouldFallbackToDefaultEnv(
          loadedEnvFile: Environment.developmentEnvFile,
          supabaseUrl: 'https://your-dev-project.supabase.co',
          supabaseAnonKey: 'your-dev-anon-key',
        ),
        isTrue,
      );
    });

    test('does not fall back when development env is valid', () {
      expect(
        Environment.shouldFallbackToDefaultEnv(
          loadedEnvFile: Environment.developmentEnvFile,
          supabaseUrl: 'https://real-project.supabase.co',
          supabaseAnonKey: _testAnonKey,
        ),
        isFalse,
      );
    });

    test('does not fall back for the default env file', () {
      expect(
        Environment.shouldFallbackToDefaultEnv(
          loadedEnvFile: Environment.defaultEnvFile,
          supabaseUrl: 'https://test-placeholder.supabase.co',
          supabaseAnonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder-test-signature-not-real-key-for-ci-only-12345678901234567890',
        ),
        isFalse,
      );
    });
  });

  group('Environment.describeSupabaseConfigurationIssue', () {
    test('reports placeholder URL values', () {
      final issue = Environment.describeSupabaseConfigurationIssue(
        supabaseUrl: 'https://test-placeholder.supabase.co',
        supabaseAnonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder-test-signature-not-real-key-for-ci-only-12345678901234567890',
      );

      expect(issue, 'SUPABASE_URL이 placeholder 값입니다.');
    });

    test('reports placeholder anon keys', () {
      final issue = Environment.describeSupabaseConfigurationIssue(
        supabaseUrl: 'https://real-project.supabase.co',
        supabaseAnonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder-not-real-key-1234567890123456789012345678901234567890',
      );

      expect(issue, 'SUPABASE_ANON_KEY가 placeholder 값입니다.');
    });

    test('accepts valid runtime configuration', () {
      final validAnonKey = List.filled(120, 'a').join();
      final issue = Environment.describeSupabaseConfigurationIssue(
        supabaseUrl: 'https://real-project.supabase.co',
        supabaseAnonKey: validAnonKey,
      );

      expect(issue, isNull);
    });
  });

  group('Environment.resolveConfiguredValue', () {
    test('falls back to dotenv when Supabase anon define is invalid', () {
      final resolved = Environment.resolveConfiguredValue(
        'SUPABASE_ANON_KEY',
        defineValue: 'your-prod-anon-key',
        dotenvValue: _testAnonKey,
      );

      expect(resolved, _testAnonKey);
    });

    test('falls back to dotenv when Supabase URL define is invalid', () {
      final resolved = Environment.resolveConfiguredValue(
        'SUPABASE_URL',
        defineValue: 'https://your-prod-project.supabase.co',
        dotenvValue: 'https://real-project.supabase.co',
      );

      expect(resolved, 'https://real-project.supabase.co');
    });

    test('keeps valid define values ahead of dotenv', () {
      final resolved = Environment.resolveConfiguredValue(
        'SUPABASE_URL',
        defineValue: 'https://release-project.supabase.co',
        dotenvValue: 'https://real-project.supabase.co',
      );

      expect(resolved, 'https://release-project.supabase.co');
    });

    test('falls back to dotenv when a non-URL runtime key is placeholder', () {
      final resolved = Environment.resolveConfiguredValue(
        'GOOGLE_WEB_CLIENT_ID',
        defineValue: 'placeholder-google-web-client-id',
        dotenvValue: 'real-google-client-id.apps.googleusercontent.com',
      );

      expect(resolved, 'real-google-client-id.apps.googleusercontent.com');
    });
  });

  group('Environment.describeSupabaseClientConfigurationIssue', () {
    test('reports placeholder live client urls', () {
      final supabase =
          _createTestSupabaseClient('https://test-placeholder.supabase.co');

      final issue = Environment.describeSupabaseClientConfigurationIssue(
        supabase: supabase,
        expectedSupabaseUrl: 'https://real-project.supabase.co',
      );

      expect(issue, '현재 Supabase client가 placeholder 값으로 초기화되었습니다.');
    });

    test('reports live client and env url mismatches', () {
      final supabase =
          _createTestSupabaseClient('https://stale-project.supabase.co');

      final issue = Environment.describeSupabaseClientConfigurationIssue(
        supabase: supabase,
        expectedSupabaseUrl: 'https://real-project.supabase.co',
      );

      expect(issue, '현재 Supabase client가 ENV 설정과 다른 URL로 초기화되었습니다.');
    });
  });
}
