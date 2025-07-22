import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_flutter/presentation/widgets/social_accounts_section.dart';
import 'package:fortune_flutter/services/social_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('SocialAccountsSection renders without asset errors', (WidgetTester tester) async {
    // Create a mock social auth service
    final mockSupabase = Supabase.instance.client;
    final socialAuthService = SocialAuthService(mockSupabase);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialAccountsSection(
            linkedProviders: ['google'],
            primaryProvider: 'google',
            socialAuthService: socialAuthService,
            onProvidersChanged: (providers) {},
          ),
        ),
      ),
    );

    // Verify the widget renders
    expect(find.text('소셜 계정 관리'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Kakao'), findsOneWidget);
    expect(find.text('Naver'), findsOneWidget);

    // Verify no error widgets are shown
    expect(find.byType(Icon), findsWidgets); // Should find icons
    expect(find.text('K'), findsOneWidget); // Kakao text icon
    expect(find.text('N'), findsOneWidget); // Naver text icon
  });
}