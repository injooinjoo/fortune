import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/config/environment.dart';

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
