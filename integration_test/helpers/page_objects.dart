import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object pattern for better test maintainability
/// Each page object represents a screen/page in the app

class LoginPage {
  final WidgetTester tester;

  LoginPage(this.tester);

  // Finders
  Finder get emailField => find.byType(TextFormField).at(0);
  Finder get passwordField => find.byType(TextFormField).at(1);
  Finder get loginButton => find.text('로그인').last;
  Finder get signupButton => find.text('회원가입');
  Finder get forgotPasswordLink => find.text('비밀번호 찾기');
  Finder get googleLoginButton => find.byWidgetPredicate(
    (widget) => widget is Container && 
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).color == Colors.white
  );
  Finder get kakaoLoginButton => find.byWidgetPredicate(
    (widget) => widget is Container && 
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).color == const Color(0xFFFEE500,
    );

  // Actions
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
  }

  Future<void> tapLogin() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapSignup() async {
    await tester.tap(signupButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapGoogleLogin() async {
    await tester.tap(googleLoginButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapKakaoLogin() async {
    await tester.tap(kakaoLoginButton);
    await tester.pumpAndSettle();
  }

  // Verification
  bool hasEmailError() {
    return find.text('올바른 이메일 형식이 아닙니다').evaluate().isNotEmpty;
  }

  bool hasPasswordError() {
    return find.text('비밀번호는 8자 이상이어야 합니다').evaluate().isNotEmpty;
  }
}

class HomePage {
  final WidgetTester tester;

  HomePage(this.tester);

  // Finders
  Finder get homeTab => find.byIcon(Icons.home);
  Finder get fortuneTab => find.byIcon(Icons.auto_awesome);
  Finder get profileTab => find.byIcon(Icons.person);
  Finder get tokenDisplay => find.byWidgetPredicate(
    (widget) => widget is Text && 
      widget.data != null && 
      widget.data!.contains('토큰',
    );
  Finder get dailyFortuneCard => find.text('오늘의 운세');
  Finder get weeklyFortuneCard => find.text('이번주 운세');

  // Actions
  Future<void> navigateToFortune() async {
    await tester.tap(fortuneTab);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToProfile() async {
    await tester.tap(profileTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapDailyFortune() async {
    await tester.tap(dailyFortuneCard);
    await tester.pumpAndSettle();
  }

  // Verification
  int getTokenBalance() {
    final tokenText = tokenDisplay.evaluate().first.widget as Text;
    final match = RegExp(r'(\d+)\s*토큰').firstMatch(tokenText.data ?? '');
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  bool isOnHomePage() {
    return find.byIcon(Icons.home).evaluate().isNotEmpty;
  }
}

class FortunePage {
  final WidgetTester tester;

  FortunePage(this.tester);

  // Finders
  Finder get fortuneTypeCards => find.byType(Card);
  Finder get compatibilityCard => find.text('궁합');
  Finder get marriageCard => find.text('결혼운');
  Finder get chemistryCard => find.text('케미');
  Finder get historyButton => find.byIcon(Icons.history);
  Finder get generateButton => find.textContaining('보기');

  // Actions
  Future<void> selectFortuneType(String type) async {
    await tester.tap(find.text(type));
    await tester.pumpAndSettle();
  }

  Future<void> tapGenerateFortune() async {
    await tester.tap(generateButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> openHistory() async {
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
  }

  // Verification
  bool hasFortuneResult() {
    return find.byWidgetPredicate(
      (widget) => widget is Card && widget.child != null
    ).evaluate().length > 1;
  }

  bool hasInsufficientTokensWarning() {
    return find.textContaining('토큰이 부족').evaluate().isNotEmpty;
  }
}

class ProfilePage {
  final WidgetTester tester;

  ProfilePage(this.tester);

  // Finders
  Finder get editButton => find.byIcon(Icons.edit);
  Finder get nameField => find.byType(TextFormField).first;
  Finder get saveButton => find.text('저장');
  Finder get logoutButton => find.text('로그아웃');
  Finder get deleteAccountButton => find.text('계정 삭제');
  Finder get notificationSettings => find.text('알림 설정');
  Finder get tokenHistory => find.text('토큰 사용 내역');
  Finder get profileAvatar => find.byType(CircleAvatar).first;

  // Actions
  Future<void> tapEdit() async {
    await tester.tap(editButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> updateName(String name) async {
    await tester.enterText(nameField, name);
  }

  Future<void> saveChanges() async {
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapLogout() async {
    await tester.scrollUntilVisible(logoutButton, 100);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
  }

  Future<void> confirmLogout() async {
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
  }

  Future<void> openNotificationSettings() async {
    await tester.scrollUntilVisible(notificationSettings, 100);
    await tester.tap(notificationSettings);
    await tester.pumpAndSettle();
  }

  // Verification
  String getCurrentName() {
    final nameWidget = find.byWidgetPredicate(
      (widget) => widget is Text && 
        widget.style?.fontSize != null &&
        widget.style!.fontSize! > 20
    ).evaluate().first.widget as Text;
    return nameWidget.data ?? '';
  }

  bool isInEditMode() {
    return saveButton.evaluate().isNotEmpty;
  }
}

class TokenPurchasePage {
  final WidgetTester tester;

  TokenPurchasePage(this.tester);

  // Finders
  Finder get smallPackage => find.text('10 토큰');
  Finder get mediumPackage => find.text('50 토큰');
  Finder get largePackage => find.text('100 토큰');
  Finder get purchaseButton => find.text('구매하기');
  Finder get creditCardOption => find.text('신용카드');
  Finder get kakaoPayOption => find.text('카카오페이');

  // Actions
  Future<void> selectPackage(String packageName) async {
    await tester.tap(find.text(packageName));
    await tester.pumpAndSettle();
  }

  Future<void> tapPurchase() async {
    await tester.tap(purchaseButton);
    await tester.pumpAndSettle();
  }

  Future<void> selectPaymentMethod(String method) async {
    await tester.tap(find.text(method));
    await tester.pumpAndSettle();
  }

  // Verification
  bool isPackageSelected(String packageName) {
    final packageWidget = find.ancestor(
      of: find.text(packageName),
      matching: find.byType(Container),
    ).evaluate().first.widget as Container;
    
    return packageWidget.decoration is BoxDecoration &&
           (packageWidget.decoration as BoxDecoration).border != null;
  }

  String getPackagePrice(String packageName) {
    final priceWidget = find.descendant(
      of: find.ancestor(
        of: find.text(packageName),
        matching: find.byType(Card),
      ),
      matching: find.textContaining('₩'),
    ).evaluate().first.widget as Text;
    
    return priceWidget.data ?? '';
  }
}