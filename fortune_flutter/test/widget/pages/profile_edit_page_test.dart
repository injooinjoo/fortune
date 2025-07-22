import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/screens/profile/profile_edit_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  group('ProfileEditPage Tests', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuthClient;
    
    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuthClient = MockGoTrueClient();
      
      when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
      when(() => mockAuthClient.currentSession).thenReturn(null);
      
      // Initialize Supabase with mock
      Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-key',
      );
    });

    testWidgets('ProfileEditPage shows loading initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileEditPage(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfileEditPage shows form fields after loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileEditPage(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Check for form fields
      expect(find.text('이름'), findsOneWidget);
      expect(find.text('생년'), findsOneWidget);
      expect(find.text('생월'), findsOneWidget);
      expect(find.text('생일'), findsOneWidget);
      expect(find.text('태어난 시진 (선택사항)'), findsOneWidget);
      expect(find.text('MBTI 성격 유형'), findsOneWidget);
      expect(find.text('성별'), findsOneWidget);
      
      // Check for buttons
      expect(find.text('저장'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('Cancel button navigates back', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const ProfileEditPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Should navigate back (Navigator.pop)
      expect(find.byType(ProfileEditPage), findsNothing);
    });
  });
}