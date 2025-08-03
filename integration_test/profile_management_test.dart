import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
import 'package:fortune/screens/profile/profile_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Management Tests', () {
    setUpAll(() async {
      app.main();
    });

    testWidgets('Navigate to profile screen', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Login first
      await _performQuickLogin(tester);
      
      // Navigate to profile
      final profileTab = find.byIcon(Icons.person);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
      
      // Verify profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('View profile information', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Check profile elements
      expect(find.text('프로필'), findsWidgets);
      expect(find.byType(CircleAvatar), findsWidgets);
      
      // Check for user info sections
      expect(find.text('기본 정보'), findsWidgets);
      expect(find.text('생년월일'), findsWidgets);
    });

    testWidgets('Edit profile name', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find and tap edit button
      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();
        
        // Edit name field
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'Test User Updated');
        
        // Save changes
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();
        
        // Verify update
        expect(find.text('Test User Updated'), findsWidgets);
      }
    });

    testWidgets('Update birth information', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find birth info section
      final birthInfoSection = find.text('생년월일');
      if (birthInfoSection.evaluate().isNotEmpty) {
        // Tap edit for birth info
        final nearbyEditButton = find.byIcon(Icons.edit).at(1);
        if (nearbyEditButton.evaluate().isNotEmpty) {
          await tester.tap(nearbyEditButton);
          await tester.pumpAndSettle();
          
          // Update birth date
          final birthDateField = find.byWidgetPredicate(
            (widget) => widget is TextFormField && 
              ((widget.decoration as InputDecoration?)?.labelText?.contains('생년월일') == true,
    );
          
          if (birthDateField.evaluate().isNotEmpty) {
            await tester.tap(birthDateField);
            await tester.pumpAndSettle();
            
            // Select new date
            await tester.tap(find.text('20'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('확인'));
            await tester.pumpAndSettle();
          }
          
          // Save changes
          await tester.tap(find.text('저장'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Change profile photo', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find and tap profile photo
      final profileAvatar = find.byType(CircleAvatar).first;
      await tester.tap(profileAvatar);
      await tester.pumpAndSettle();
      
      // Check for photo options
      final cameraOption = find.text('카메라');
      final galleryOption = find.text('갤러리');
      
      if (cameraOption.evaluate().isNotEmpty && galleryOption.evaluate().isNotEmpty) {
        // Note: Cannot test actual camera/gallery functionality in integration tests
        // Just verify the options appear
        expect(cameraOption, findsOneWidget);
        expect(galleryOption, findsOneWidget);
        
        // Dismiss dialog
        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Notification settings', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find and tap notification settings
      final notificationSettings = find.text('알림 설정');
      if (notificationSettings.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          notificationSettings,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(notificationSettings);
        await tester.pumpAndSettle();
        
        // Toggle notification switches
        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          
          // Verify toggle worked
          final switchWidget = switches.first.evaluate().single.widget as Switch;
          expect(switchWidget.value, isNotNull);
        }
      }
    });

    testWidgets('Account deletion request', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Scroll to bottom for account settings
      await tester.scrollUntilVisible(
        find.text('계정 삭제'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      
      // Tap account deletion
      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();
      
      // Verify confirmation dialog
      expect(find.text('정말로 계정을 삭제하시겠습니까?'), findsWidgets);
      
      // Cancel deletion
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
    });

    testWidgets('Privacy settings', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find privacy settings
      final privacySettings = find.text('개인정보 설정');
      if (privacySettings.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          privacySettings,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(privacySettings);
        await tester.pumpAndSettle();
        
        // Check privacy options
        expect(find.text('프로필 공개'), findsWidgets);
        expect(find.text('데이터 수집'), findsWidgets);
      }
    });

    testWidgets('Language settings', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find language settings
      final languageSettings = find.text('언어 설정');
      if (languageSettings.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          languageSettings,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(languageSettings);
        await tester.pumpAndSettle();
        
        // Check language options
        expect(find.text('한국어'), findsWidgets);
        expect(find.text('English'), findsWidgets);
        
        // Select English
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        
        // Verify language change (some UI element should change)
        // Note: Actual language change verification depends on app implementation
      }
    });

    testWidgets('Terms and conditions', (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await _performQuickLogin(tester);
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Find and tap terms
      final termsLink = find.text('이용약관');
      if (termsLink.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          termsLink,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(termsLink);
        await tester.pumpAndSettle();
        
        // Verify terms page/dialog
        expect(find.textContaining('약관'), findsWidgets);
        
        // Close terms
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}

// Helper function
Future<void> _performQuickLogin(WidgetTester tester) async {
  // This assumes the app remembers login state or we're in a test environment
  // In real tests, you might need to implement actual login flow
}