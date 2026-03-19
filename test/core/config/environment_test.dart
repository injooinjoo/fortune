import 'package:flutter_test/flutter_test.dart';

import 'package:fortune/core/config/environment.dart';

void main() {
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
}
