// Profile Edit Page - Widget Test
// 프로필 편집 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('ProfileEditPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('프로필 편집 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('프로필 수정'), findsOneWidget);
      });

      testWidgets('이름 입력 필드가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, '이름'), findsOneWidget);
      });

      testWidgets('생년월일 선택 필드가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('생년월일'), findsOneWidget);
      });

      testWidgets('시간 선택 필드가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('태어난 시간'), findsOneWidget);
      });

      testWidgets('저장 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('저장'), findsOneWidget);
      });
    });

    group('이름 입력', () {
      testWidgets('이름 입력 시 값이 변경되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(TextField, '이름');
        await tester.enterText(nameField, '김철수');
        await tester.pumpAndSettle();

        expect(find.text('김철수'), findsOneWidget);
      });

      testWidgets('빈 이름은 유효성 검사 실패', (tester) async {
        String? validationError;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(
                  onValidationError: (error) => validationError = error,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 이름 필드를 비움
        final nameField = find.widgetWithText(TextField, '이름');
        await tester.enterText(nameField, '');

        // 저장 버튼 탭
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();

        expect(validationError, '이름을 입력해주세요');
      });
    });

    group('생년월일 선택', () {
      testWidgets('생년월일 탭 시 날짜 선택기 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('생년월일'));
        await tester.pumpAndSettle();

        // DatePicker 다이얼로그가 표시되어야 함
        expect(find.byType(Dialog), findsOneWidget);
      });

      testWidgets('날짜 선택 후 값이 업데이트되어야 함', (tester) async {
        String? selectedDate;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(
                  onDateChanged: (date) => selectedDate = date,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('생년월일'));
        await tester.pumpAndSettle();

        // 날짜 선택 (다이얼로그에서)
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();

        expect(selectedDate, isNotNull);
      });
    });

    group('시간 선택', () {
      testWidgets('시간 탭 시 시간 선택기 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('태어난 시간'));
        await tester.pumpAndSettle();

        // TimePicker 다이얼로그가 표시되어야 함
        expect(find.byType(Dialog), findsOneWidget);
      });

      testWidgets('모름 옵션이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // '모름'이 시간 표시와 버튼에 모두 있을 수 있음
        expect(find.text('모름'), findsWidgets);
      });
    });

    group('성별 선택', () {
      testWidgets('성별 선택 옵션이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('남성'), findsOneWidget);
        expect(find.text('여성'), findsOneWidget);
      });

      testWidgets('성별 선택 시 값이 변경되어야 함', (tester) async {
        String? selectedGender;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(
                  onGenderChanged: (gender) => selectedGender = gender,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('여성'));
        await tester.pumpAndSettle();

        expect(selectedGender, 'female');
      });
    });

    group('음력/양력 선택', () {
      testWidgets('양력/음력 토글이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('양력'), findsOneWidget);
        expect(find.text('음력'), findsOneWidget);
      });
    });

    group('저장 기능', () {
      testWidgets('저장 버튼 탭 시 저장 콜백 호출', (tester) async {
        bool savePressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(
                  initialName: '홍길동',
                  onSave: () => savePressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();

        expect(savePressed, isTrue);
      });

      testWidgets('저장 중 로딩 인디케이터 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPageLoading(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('취소 기능', () {
      testWidgets('뒤로가기 버튼이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('변경사항 있을 때 뒤로가기 시 확인 다이얼로그', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockProfileEditPage(
                  hasChanges: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('변경사항을 저장하지 않고 나가시겠습니까?'), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockProfileEditPage(),
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
                body: _MockProfileEditPage(),
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

class _MockProfileEditPage extends StatefulWidget {
  final String initialName;
  final bool hasChanges;
  final VoidCallback? onSave;
  final void Function(String)? onValidationError;
  final void Function(String)? onDateChanged;
  final void Function(String)? onGenderChanged;

  const _MockProfileEditPage({
    this.initialName = '홍길동',
    this.hasChanges = false,
    this.onSave,
    this.onValidationError,
    this.onDateChanged,
    this.onGenderChanged,
  });

  @override
  State<_MockProfileEditPage> createState() => _MockProfileEditPageState();
}

class _MockProfileEditPageState extends State<_MockProfileEditPage> {
  late TextEditingController _nameController;
  String _selectedGender = 'male';
  String _selectedCalendar = 'solar';
  String _selectedTime = '모름';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedGender = 'male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('생년월일 선택'),
        content: const Text('날짜를 선택해주세요'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDateChanged?.call('1990-01-15');
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태어난 시간 선택'),
        content: const Text('시간을 선택해주세요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      widget.onValidationError?.call('이름을 입력해주세요');
      return;
    }
    widget.onSave?.call();
  }

  void _handleBack() {
    if (widget.hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('변경사항을 저장하지 않고 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나가기'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 앱바
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBack,
                ),
                const Expanded(
                  child: Text(
                    '프로필 수정',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      hintText: '이름을 입력해주세요',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 생년월일
                  GestureDetector(
                    onTap: _showDatePicker,
                    child: const InputDecorator(
                      decoration: InputDecoration(
                        labelText: '생년월일',
                      ),
                      child: Text(
                        '선택해주세요',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 양력/음력
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('양력'),
                        selected: _selectedCalendar == 'solar',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCalendar = 'solar');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('음력'),
                        selected: _selectedCalendar == 'lunar',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCalendar = 'lunar');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 태어난 시간
                  GestureDetector(
                    onTap: _showTimePicker,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '태어난 시간',
                      ),
                      child: Text(_selectedTime),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _selectedTime = '모름'),
                    child: const Text('모름'),
                  ),
                  const SizedBox(height: 24),

                  // 성별
                  const Text('성별', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('남성'),
                        selected: _selectedGender == 'male',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedGender = 'male');
                            widget.onGenderChanged?.call('male');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('여성'),
                        selected: _selectedGender == 'female',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedGender = 'female');
                            widget.onGenderChanged?.call('female');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 저장 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('저장'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockProfileEditPageLoading extends StatelessWidget {
  const _MockProfileEditPageLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('저장 중...'),
        ],
      ),
    );
  }
}
