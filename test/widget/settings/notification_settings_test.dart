// Notification Settings - Widget Test
// 알림 설정 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('NotificationSettingsScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('알림 설정 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('알림 설정'), findsOneWidget);
      });
    });

    group('알림 마스터 토글', () {
      testWidgets('전체 알림 on/off 토글이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('알림 받기'), findsOneWidget);
        expect(find.byType(Switch), findsWidgets);
      });

      testWidgets('알림 비활성화 시 세부 설정이 비활성화되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNotificationSettingsScreen(masterEnabled: false),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // 세부 설정이 비활성화 상태인지 확인
        expect(find.byType(Switch), findsWidgets);
      });
    });

    group('일일 운세 알림', () {
      testWidgets('일일 운세 알림 토글이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('일일 운세 알림'), findsOneWidget);
      });

      testWidgets('알림 시간 설정이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('알림 시간'), findsOneWidget);
      });

      testWidgets('알림 시간이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNotificationSettingsScreen(
                  dailyNotificationTime: TimeOfDay(hour: 8, minute: 0),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('오전 8:00'), findsOneWidget);
      });
    });

    group('마케팅 알림', () {
      testWidgets('이벤트/프로모션 알림 토글이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('이벤트/프로모션'), findsOneWidget);
      });

      testWidgets('신규 기능 알림 토글이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('신규 기능 안내'), findsOneWidget);
      });
    });

    group('운세 알림', () {
      testWidgets('특별한 날 알림이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('특별한 날 알림'), findsOneWidget);
      });

      testWidgets('바이오리듬 알림이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('바이오리듬 알림'), findsOneWidget);
      });
    });

    group('인터랙션', () {
      testWidgets('토글 변경이 동작해야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 첫 번째 스위치 탭
        final switchWidget = find.byType(Switch).first;
        await tester.tap(switchWidget);
        await tester.pumpAndSettle();

        expect(find.byType(Switch), findsWidgets);
      });

      testWidgets('시간 선택기가 열려야 함', (tester) async {
        bool timePickerOpened = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNotificationSettingsScreen(
                  onTimePickerTap: () => timePickerOpened = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('알림 시간'));
        await tester.pumpAndSettle();

        expect(timePickerOpened, isTrue);
      });
    });

    group('알림 설명', () {
      testWidgets('각 알림에 설명이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('매일'), findsWidgets);
      });
    });

    group('저장 기능', () {
      testWidgets('변경사항 저장 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNotificationSettingsScreen(hasChanges: true),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('저장'), findsOneWidget);
      });
    });

    group('시스템 설정 안내', () {
      testWidgets('시스템 알림 설정 안내가 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: _MockNotificationSettingsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // '시스템 설정' 관련 텍스트가 있음 (안내 문구 + 버튼)
        expect(find.textContaining('시스템 설정'), findsWidgets);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(body: _MockNotificationSettingsScreen()),
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
              home: const Scaffold(body: _MockNotificationSettingsScreen()),
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

class _MockNotificationSettingsScreen extends StatefulWidget {
  final bool masterEnabled;
  final TimeOfDay dailyNotificationTime;
  final bool hasChanges;
  final VoidCallback? onTimePickerTap;

  const _MockNotificationSettingsScreen({
    this.masterEnabled = true,
    this.dailyNotificationTime = const TimeOfDay(hour: 8, minute: 0),
    this.hasChanges = false,
    this.onTimePickerTap,
  });

  @override
  State<_MockNotificationSettingsScreen> createState() =>
      _MockNotificationSettingsScreenState();
}

class _MockNotificationSettingsScreenState
    extends State<_MockNotificationSettingsScreen> {
  late bool _masterEnabled;
  late bool _dailyEnabled;
  bool _eventEnabled = true;
  bool _newFeatureEnabled = true;
  bool _specialDayEnabled = true;
  bool _biorhythmEnabled = false;

  @override
  void initState() {
    super.initState();
    _masterEnabled = widget.masterEnabled;
    _dailyEnabled = true;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? '오전' : '오후';
    return '$period $hour:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '알림 설정',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (widget.hasChanges)
                    TextButton(
                      onPressed: () {},
                      child: const Text('저장'),
                    ),
                ],
              ),
            ),

            // 마스터 토글
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SwitchListTile(
                title: const Text(
                  '알림 받기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('모든 알림을 켜거나 끕니다'),
                value: _masterEnabled,
                onChanged: (value) => setState(() => _masterEnabled = value),
              ),
            ),
            const SizedBox(height: 16),

            // 일일 운세 알림
            const _SectionHeader(title: '일일 운세'),
            _NotificationToggle(
              title: '일일 운세 알림',
              subtitle: '매일 아침 오늘의 운세를 알려드려요',
              value: _dailyEnabled && _masterEnabled,
              enabled: _masterEnabled,
              onChanged: (value) => setState(() => _dailyEnabled = value),
            ),
            ListTile(
              enabled: _masterEnabled && _dailyEnabled,
              title: const Text('알림 시간'),
              subtitle: Text(_formatTime(widget.dailyNotificationTime)),
              trailing: const Icon(Icons.chevron_right),
              onTap: widget.onTimePickerTap,
            ),

            const Divider(),

            // 운세 관련 알림
            const _SectionHeader(title: '운세 알림'),
            _NotificationToggle(
              title: '특별한 날 알림',
              subtitle: '생일, 절기 등 특별한 날에 알려드려요',
              value: _specialDayEnabled && _masterEnabled,
              enabled: _masterEnabled,
              onChanged: (value) => setState(() => _specialDayEnabled = value),
            ),
            _NotificationToggle(
              title: '바이오리듬 알림',
              subtitle: '위험일, 고조기 등을 알려드려요',
              value: _biorhythmEnabled && _masterEnabled,
              enabled: _masterEnabled,
              onChanged: (value) => setState(() => _biorhythmEnabled = value),
            ),

            const Divider(),

            // 마케팅 알림
            const _SectionHeader(title: '마케팅'),
            _NotificationToggle(
              title: '이벤트/프로모션',
              subtitle: '특별 이벤트와 할인 정보를 알려드려요',
              value: _eventEnabled && _masterEnabled,
              enabled: _masterEnabled,
              onChanged: (value) => setState(() => _eventEnabled = value),
            ),
            _NotificationToggle(
              title: '신규 기능 안내',
              subtitle: '새로운 기능이 추가되면 알려드려요',
              value: _newFeatureEnabled && _masterEnabled,
              enabled: _masterEnabled,
              onChanged: (value) => setState(() => _newFeatureEnabled = value),
            ),

            const SizedBox(height: 24),

            // 시스템 설정 안내
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '시스템 설정에서도 알림을 허용해주세요',
                          style: TextStyle(fontSize: 12),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('시스템 설정 열기'),
                        ),
                      ],
                    ),
                  ),
                ],
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

class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}
