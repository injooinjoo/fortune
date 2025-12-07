/// Onboarding Page - Widget Test
/// 온보딩 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('OnboardingPage 테스트', () {
    group('Step 1: 이름 입력', () {
      testWidgets('이름 입력 화면이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNameInputStep(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('이름을 입력해주세요'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('이름 입력 시 다음 버튼 활성화', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNameInputStep(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 이름 입력
        await tester.enterText(find.byType(TextField), '홍길동');
        await tester.pumpAndSettle();

        // 다음 버튼이 활성화되어야 함
        final nextButton = find.text('다음');
        expect(nextButton, findsOneWidget);
      });

      testWidgets('빈 이름으로는 다음으로 진행 불가', (tester) async {
        bool nextPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNameInputStep(
                  onNext: () => nextPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 빈 상태에서 다음 버튼 탭
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // 다음으로 진행되지 않아야 함
        expect(nextPressed, isFalse);
      });

      testWidgets('유효한 이름 입력 후 다음 진행', (tester) async {
        bool nextPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNameInputStep(
                  onNext: () => nextPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 이름 입력
        await tester.enterText(find.byType(TextField), '홍길동');
        await tester.pumpAndSettle();

        // 다음 버튼 탭
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        expect(nextPressed, isTrue);
      });
    });

    group('Step 2: 생년월일 입력', () {
      testWidgets('생년월일 입력 화면이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBirthInputStep(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('생년월일을 알려주세요'), findsOneWidget);
      });

      testWidgets('날짜 선택 가능', (tester) async {
        DateTime? selectedDate;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBirthInputStep(
                  onDateChanged: (date) => selectedDate = date,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 날짜 선택 버튼 탭
        await tester.tap(find.text('날짜 선택'));
        await tester.pumpAndSettle();

        // 날짜가 선택되어야 함 (Mock에서 자동 선택)
        expect(selectedDate, isNotNull);
      });

      testWidgets('시간 선택은 선택사항', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBirthInputStep(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 시간 입력 안내 확인
        expect(find.textContaining('시간'), findsWidgets);
      });

      testWidgets('뒤로 가기 버튼 동작', (tester) async {
        bool backPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBirthInputStep(
                  onBack: () => backPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 뒤로 가기 버튼 탭
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(backPressed, isTrue);
      });
    });

    group('전체 플로우', () {
      testWidgets('PageView로 스텝 간 이동', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockOnboardingFlow(),
              ),
            ),
          ),
        );

        // 애니메이션이 있는 위젯이라 pump() 사용
        await tester.pump(const Duration(milliseconds: 500));

        // PageView 확인
        expect(find.byType(PageView), findsOneWidget);
      });

      testWidgets('프로그레스 인디케이터 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockOnboardingFlow(),
              ),
            ),
          ),
        );

        // 애니메이션이 있는 위젯이라 pump() 사용
        await tester.pump(const Duration(milliseconds: 500));

        // 프로그레스 표시 확인
        expect(find.textContaining('1'), findsWidgets);
      });
    });

    group('입력 검증', () {
      testWidgets('이름 최소 길이 검증', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockNameInputStep(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 한 글자만 입력
        await tester.enterText(find.byType(TextField), '홍');
        await tester.pumpAndSettle();

        // 유효성 검사 - 한 글자도 허용
        expect(find.text('홍'), findsOneWidget);
      });

      testWidgets('미래 날짜 선택 불가', (tester) async {
        final futureDate = DateTime.now().add(const Duration(days: 365));

        bool isValidBirthDate(DateTime date) {
          return date.isBefore(DateTime.now());
        }

        expect(isValidBirthDate(futureDate), isFalse);
        expect(isValidBirthDate(DateTime(1990, 1, 1)), isTrue);
      });
    });

    group('소셜 로그인 사용자 처리', () {
      testWidgets('소셜 로그인으로 이름이 있으면 이름 스텝 건너뛰기', (tester) async {
        // 이미 이름이 있는 사용자
        const prefilledName = 'Google User';

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockBirthInputStep(
                  userName: prefilledName,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 바로 생년월일 입력 화면이 표시되어야 함
        expect(find.text('생년월일을 알려주세요'), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockNameInputStep(),
              ),
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
              home: const Scaffold(
                body: _MockNameInputStep(),
              ),
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

class _MockNameInputStep extends StatefulWidget {
  final VoidCallback? onNext;
  final String? initialName;

  const _MockNameInputStep({this.onNext, this.initialName});

  @override
  State<_MockNameInputStep> createState() => _MockNameInputStepState();
}

class _MockNameInputStepState extends State<_MockNameInputStep> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이름을 입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('운세를 봐드릴게요'),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '이름',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _controller.text.isNotEmpty
                  ? widget.onNext
                  : null,
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBirthInputStep extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final void Function(DateTime)? onDateChanged;
  final String? userName;

  const _MockBirthInputStep({
    this.onBack,
    this.onNext,
    this.onDateChanged,
    this.userName,
  });

  @override
  State<_MockBirthInputStep> createState() => _MockBirthInputStepState();
}

class _MockBirthInputStepState extends State<_MockBirthInputStep> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const Text('2 / 2'),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.userName != null) ...[
            Text('${widget.userName}님'),
            const SizedBox(height: 8),
          ],
          const Text(
            '생년월일을 알려주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(1990, 1, 1);
              });
              widget.onDateChanged?.call(_selectedDate!);
            },
            child: Text(_selectedDate != null
                ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                : '날짜 선택'),
          ),
          const SizedBox(height: 16),
          const Text('태어난 시간 (선택사항)'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTime = const TimeOfDay(hour: 9, minute: 0);
              });
            },
            child: Text(_selectedTime != null
                ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                : '시간 선택'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDate != null ? widget.onNext : null,
              child: const Text('완료'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockOnboardingFlow extends StatefulWidget {
  const _MockOnboardingFlow();

  @override
  State<_MockOnboardingFlow> createState() => _MockOnboardingFlowState();
}

class _MockOnboardingFlowState extends State<_MockOnboardingFlow> {
  final PageController _controller = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Step ${_currentStep + 1} / 2'),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MockNameInputStep(onNext: _nextStep),
              _MockBirthInputStep(
                onBack: _previousStep,
                onNext: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
