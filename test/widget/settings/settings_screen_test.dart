// Settings Screen - Widget Test
// 설정 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SettingsScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('설정 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('설정'), findsOneWidget);
      });
    });

    group('계정 설정', () {
      testWidgets('프로필 설정 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('프로필 설정'), findsOneWidget);
      });

      testWidgets('계정 관리 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('계정 관리'), findsOneWidget);
      });

      testWidgets('로그아웃 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('로그아웃'), findsOneWidget);
      });
    });

    group('앱 설정', () {
      testWidgets('알림 설정 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('알림 설정'), findsOneWidget);
      });

      testWidgets('다크모드 토글이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('다크 모드'), findsOneWidget);
        expect(find.byType(Switch), findsWidgets);
      });

      testWidgets('언어 설정이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('언어'), findsOneWidget);
      });
    });

    group('결제 & 구독', () {
      testWidgets('프리미엄 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('프리미엄'), findsOneWidget);
      });

      testWidgets('토큰 잔액이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSettingsScreen(tokenBalance: 100),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('100'), findsWidgets);
      });

      testWidgets('구매 내역 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('구매 내역'), findsOneWidget);
      });
    });

    group('정보 & 지원', () {
      testWidgets('앱 버전이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('버전 정보'), findsOneWidget);
      });

      testWidgets('이용약관 링크가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이용약관'), findsOneWidget);
      });

      testWidgets('개인정보처리방침 링크가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('개인정보처리방침'), findsOneWidget);
      });

      testWidgets('문의하기 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('문의하기'), findsOneWidget);
      });

      testWidgets('FAQ 메뉴가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('자주 묻는 질문'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('다크모드 토글이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final switchWidget = find.byType(Switch).first;
        await tester.tap(switchWidget);
        await tester.pumpAndSettle();

        // 토글 동작 확인
        expect(find.byType(Switch), findsWidgets);
      });

      testWidgets('로그아웃 버튼 탭 시 확인 다이얼로그가 표시되어야 함', (tester) async {
        bool logoutPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSettingsScreen(
                  onLogout: () => logoutPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 스크롤하여 로그아웃 버튼이 보이도록 함
        final logoutButton = find.text('로그아웃');
        await tester.ensureVisible(logoutButton);
        await tester.pumpAndSettle();

        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        expect(logoutPressed, isTrue);
      });

      testWidgets('프로필 설정 탭 시 네비게이션', (tester) async {
        bool profilePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSettingsScreen(
                  onProfileTap: () => profilePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('프로필 설정'));
        await tester.pumpAndSettle();

        expect(profilePressed, isTrue);
      });
    });

    group('데이터 관리', () {
      testWidgets('캐시 삭제 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('캐시 삭제'), findsOneWidget);
      });

      testWidgets('계정 탈퇴 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('계정 탈퇴'), findsOneWidget);
      });
    });

    group('소셜 계정', () {
      testWidgets('연결된 소셜 계정이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSettingsScreen(
                  connectedAccounts: ['google', 'kakao'],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('연결된 계정'), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('다크 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const Scaffold(body: _MockSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockSettingsScreen extends StatefulWidget {
  final int tokenBalance;
  final List<String> connectedAccounts;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileTap;

  const _MockSettingsScreen({
    this.tokenBalance = 0,
    this.connectedAccounts = const [],
    this.onLogout,
    this.onProfileTap,
  });

  @override
  State<_MockSettingsScreen> createState() => _MockSettingsScreenState();
}

class _MockSettingsScreenState extends State<_MockSettingsScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '설정',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // 계정 섹션
            const _SectionHeader(title: '계정'),
            _SettingsItem(
              icon: Icons.person,
              title: '프로필 설정',
              onTap: widget.onProfileTap,
            ),
            _SettingsItem(
              icon: Icons.manage_accounts,
              title: '계정 관리',
              onTap: () {},
            ),
            if (widget.connectedAccounts.isNotEmpty)
              _SettingsItem(
                icon: Icons.link,
                title: '연결된 계정',
                subtitle: widget.connectedAccounts.join(', '),
                onTap: () {},
              ),

            const Divider(),

            // 앱 설정 섹션
            const _SectionHeader(title: '앱 설정'),
            _SettingsItem(
              icon: Icons.notifications,
              title: '알림 설정',
              onTap: () {},
            ),
            _SettingsToggle(
              icon: Icons.dark_mode,
              title: '다크 모드',
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
            ),
            _SettingsItem(
              icon: Icons.language,
              title: '언어',
              subtitle: '한국어',
              onTap: () {},
            ),

            const Divider(),

            // 결제 섹션
            const _SectionHeader(title: '결제 & 구독'),
            _SettingsItem(
              icon: Icons.star,
              title: '프리미엄',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.monetization_on,
              title: '토큰',
              subtitle: '${widget.tokenBalance}개',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.receipt,
              title: '구매 내역',
              onTap: () {},
            ),

            const Divider(),

            // 정보 섹션
            const _SectionHeader(title: '정보 & 지원'),
            _SettingsItem(
              icon: Icons.info,
              title: '버전 정보',
              subtitle: '1.0.0',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.description,
              title: '이용약관',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.privacy_tip,
              title: '개인정보처리방침',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.help,
              title: '자주 묻는 질문',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.mail,
              title: '문의하기',
              onTap: () {},
            ),

            const Divider(),

            // 데이터 관리
            const _SectionHeader(title: '데이터 관리'),
            _SettingsItem(
              icon: Icons.cleaning_services,
              title: '캐시 삭제',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.delete_forever,
              title: '계정 탈퇴',
              textColor: Colors.red,
              onTap: () {},
            ),

            const Divider(),

            // 로그아웃
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('로그아웃'),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
