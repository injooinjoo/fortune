# 운세 입력 페이지 아코디언 표준화 가이드

## 📋 개요

모든 운세 입력 페이지에 일관된 UX를 적용하기 위한 표준화 가이드입니다.

## 🎯 6단계 체크리스트

모든 운세 입력 페이지는 다음 6가지 원칙을 따라야 합니다:

### 1️⃣ 적합한 데이터 수집 정의
**운세 목적에 맞는 데이터만 수집**
- 운세 타입별로 필요한 데이터 명확히 정의
- 불필요한 정보 요구 금지
- 사용자 부담 최소화

### 2️⃣ 기존 데이터 확인
**중복 입력 방지**
- 사용자 프로필에 이미 있는 데이터 확인
- 프로필에서 가져올 수 있는 데이터: 이름, 생년월일, 성별, 출생시간
- `userProfileProvider`로 프로필 데이터 접근

### 3️⃣ 데이터 자동 채우기
**미리 입력 가능한 데이터는 자동 채우기**
- 프로필 데이터 자동 채우기
- TextEditingController 초기값 설정
- AccordionInputSection의 `value`, `displayValue`, `isCompleted` 설정

### 4️⃣ 자동 스크롤 (화면 중앙)
**입력 안된 섹션을 화면 중앙으로 자동 스크롤**
- `AccordionInputSection` 자동 제공
- 섹션 확장 시 화면 중앙에 위치
- 부드러운 애니메이션 (400ms, easeInOut)

### 5️⃣ 아코디언 관리
**이미 입력된 섹션은 접혀있음**
- 완료된 섹션: 자동으로 접힘 (체크마크 표시)
- 미완료 섹션: 자동으로 열림
- 탭하여 재수정 가능

### 6️⃣ 다중 선택 섹션 유지
**중복 선택 목록은 선택 후에도 열린 상태 유지**
- `isMultiSelect: true` 플래그 사용
- 한 번 선택해도 자동으로 닫히지 않음
- 여러 항목 선택 가능

---

## 🛠 구현 방법

### Step 1: AccordionInputSection 사용

```dart
import 'package:fortune/core/widgets/accordion_input_section.dart';

class MyFortuneInputPage extends ConsumerStatefulWidget {
  @override
  State<MyFortuneInputPage> createState() => _MyFortuneInputPageState();
}

class _MyFortuneInputPageState extends ConsumerState<MyFortuneInputPage> {
  List<AccordionInputSection> _accordionSections = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;

    if (profile != null && mounted) {
      setState(() {
        // 프로필 데이터 자동 채우기
        _birthDate = profile.birthDate;
        _gender = profile.gender;

        // 아코디언 섹션 초기화
        _initializeAccordionSections();
      });
    } else {
      _initializeAccordionSections();
    }
  }
}
```

### Step 2: 아코디언 섹션 정의

```dart
void _initializeAccordionSections() {
  _accordionSections = [
    // 1. 프로필 데이터 (자동 채움 + 완료 상태)
    AccordionInputSection(
      id: 'birthDate',
      title: '생년월일',
      icon: Icons.cake_rounded,
      inputWidgetBuilder: (context, onComplete) => _buildBirthDateInput(onComplete),
      value: _birthDate,
      isCompleted: _birthDate != null, // ✅ 완료 상태
      displayValue: _birthDate != null
          ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
          : null,
    ),

    // 2. 단일 선택 (선택 후 자동으로 다음 섹션으로 이동)
    AccordionInputSection(
      id: 'gender',
      title: '성별',
      icon: Icons.person_rounded,
      inputWidgetBuilder: (context, onComplete) => _buildGenderInput(onComplete),
      value: _gender,
      isCompleted: _gender != null,
      displayValue: _gender != null
          ? (_gender == 'male' ? '남성' : '여성')
          : null,
    ),

    // 3. 다중 선택 (선택 후에도 닫히지 않음)
    AccordionInputSection(
      id: 'concerns',
      title: '고민 분야',
      icon: Icons.psychology_rounded,
      inputWidgetBuilder: (context, onComplete) => _buildConcernsInput(onComplete),
      value: _selectedConcerns.toList(),
      isCompleted: _selectedConcerns.isNotEmpty,
      displayValue: _selectedConcerns.isNotEmpty
          ? _selectedConcerns.join(', ')
          : null,
      isMultiSelect: true, // ✅ 다중 선택 - 닫히지 않음
    ),
  ];
}
```

### Step 3: 입력 위젯 구현

```dart
// 단일 선택 예시 (성별)
Widget _buildGenderInput(Function(dynamic) onComplete) {
  return Row(
    children: [
      Expanded(
        child: _buildGenderButton('남성', 'male', onComplete),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _buildGenderButton('여성', 'female', onComplete),
      ),
    ],
  );
}

Widget _buildGenderButton(String label, String value, Function(dynamic) onComplete) {
  final isSelected = _gender == value;
  return InkWell(
    onTap: () {
      setState(() {
        _gender = value;
        _updateAccordionSection('gender', value, label);
      });
      TossDesignSystem.hapticLight();
      onComplete(value); // ✅ 완료 콜백 호출
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? TossDesignSystem.tossBlue.withOpacity(0.1)
            : TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(label, style: TypographyUnified.buttonMedium),
      ),
    ),
  );
}

// 다중 선택 예시 (고민 분야)
Widget _buildConcernsInput(Function(dynamic) onComplete) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '복수 선택 가능',
        style: TypographyUnified.labelMedium.copyWith(
          color: TossDesignSystem.gray600,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['진로', '연애', '재정'].map((concern) {
          final isSelected = _selectedConcerns.contains(concern);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedConcerns.remove(concern);
                } else {
                  _selectedConcerns.add(concern);
                }
                _updateAccordionSection(
                  'concerns',
                  _selectedConcerns.toList(),
                  _selectedConcerns.join(', '),
                );
              });
              TossDesignSystem.hapticLight();
              onComplete(_selectedConcerns.toList()); // ✅ 완료 콜백 호출
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossDesignSystem.tossBlue.withOpacity(0.1)
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(concern),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
```

### Step 4: 아코디언 업데이트 메서드

```dart
void _updateAccordionSection(String id, dynamic value, String? displayValue) {
  final index = _accordionSections.indexWhere((section) => section.id == id);
  if (index != -1) {
    setState(() {
      _accordionSections[index] = AccordionInputSection(
        id: _accordionSections[index].id,
        title: _accordionSections[index].title,
        icon: _accordionSections[index].icon,
        inputWidgetBuilder: _accordionSections[index].inputWidgetBuilder,
        value: value,
        isCompleted: value != null && (value is! String || value.isNotEmpty),
        displayValue: displayValue,
        isMultiSelect: _accordionSections[index].isMultiSelect, // ✅ 기존 값 유지
      );
    });
  }
}
```

### Step 5: UI 렌더링

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
    appBar: StandardFortuneAppBar(
      title: '운세 이름',
    ),
    body: SafeArea(
      child: Stack(
        children: [
          _accordionSections.isEmpty
              ? Center(child: CircularProgressIndicator())
              : AccordionInputFormWithHeader(
                  header: _buildTitleSection(isDark),
                  sections: _accordionSections,
                  onAllCompleted: null,
                  completionButtonText: '운세 보기',
                ),
          if (_canGenerate())
            TossFloatingProgressButtonPositioned(
              text: '운세 보기',
              onPressed: _canGenerate() ? () => _analyzeAndShowResult() : null,
              isEnabled: _canGenerate(),
              showProgress: false,
              isVisible: _canGenerate(),
            ),
        ],
      ),
    ),
  );
}
```

---

## 📊 운세별 적용 우선순위

### 🟢 Phase 1: 완료
- [x] **Talent Fortune** - 참조 구현 완료 (isMultiSelect 추가)

### 🟡 Phase 2: 변환 필요 (PageView → Accordion)
- [x] **Career Coaching** - 2단계 PageView → 5개 아코디언 ✅ **완료**
- [x] **Love Fortune** - 4단계 PageView → 8개 아코디언 ✅ **완료**

### 🟠 Phase 3: 아코디언 검토 완료 ✅
- [x] **Compatibility** - ❌ **아코디언 불필요** (이유: Person 1/2 단순 폼 입력, 단계 구분 없음)
- [x] **Moving Fortune** - ✅ **이미 적용됨** (`MovingInputUnified`가 `AccordionInputForm` 사용 중)

### 🔵 Phase 4: 현재 구조 유지
- [x] **Biorhythm** - 단순 입력 (생년월일만) - 아코디언 불필요
- [x] **Face Reading** - 이미지 업로드 플로우 - 2단계 유지
- [x] **Tarot** - 플로우 기반 (질문 → 스프레드 선택) - 현재 구조 유지

---

## 🚀 구현 가이드라인

### ✅ DO (해야 할 것)
1. 프로필 데이터 자동 채우기 (`userProfileProvider`)
2. 완료된 섹션 자동 접기 (`isCompleted: true`)
3. 다중 선택은 `isMultiSelect: true` 설정
4. 입력 위젯에서 `onComplete(value)` 호출
5. AccordionInputFormWithHeader 사용 (헤더 포함)

### ❌ DON'T (하지 말아야 할 것)
1. PageView 사용 금지 (단계별 입력 페이지 금지)
2. 프로필 데이터 중복 요청 금지
3. 단일 선택 섹션에 `isMultiSelect: true` 사용 금지
4. 섹션 업데이트 시 `isMultiSelect` 플래그 누락 금지

---

## 📚 참조 파일

### 위젯
- **AccordionInputSection**: `lib/core/widgets/accordion_input_section.dart`
- **TossFloatingProgressButton**: `lib/shared/components/toss_floating_progress_button.dart`

### 참조 구현
- **Talent Fortune**: `lib/features/fortune/presentation/pages/talent_fortune_input_page.dart`
- **Career Coaching**: `lib/features/fortune/presentation/pages/career_coaching_input_page.dart` (5개 섹션)
- **Love Fortune**: `lib/features/fortune/presentation/pages/love_fortune_input_page.dart` (8개 섹션, 복합 섹션 포함)

### Provider
- **userProfileProvider**: `lib/presentation/providers/auth_provider.dart`

---

## 🎨 UI/UX 가이드

### 아코디언 상태별 스타일

**완료된 섹션 (접힘)**:
- 배경: gray100 (라이트) / grayDark700 (다크)
- 테두리: tossBlue 30% opacity
- 아이콘: 체크마크 (check_circle)
- 텍스트: displayValue 표시

**미완료 섹션 (접힘)**:
- 배경: gray50 (라이트) / grayDark800 (다크)
- 테두리: gray200 (라이트) / grayDark400 (다크)
- 아이콘: 화살표 (chevron_right)
- 텍스트: title만 표시

**확장된 섹션**:
- 배경: white (라이트) / cardBackgroundDark (다크)
- 테두리: tossBlue 30% opacity, 2px
- 그림자: tossBlue 8% opacity, 24px blur
- 애니메이션: 300ms fadeIn + slideY

### 자동 스크롤 동작
- 트리거: 섹션 확장 시 자동 실행
- 위치: 화면 중앙
- 지연: 300ms (섹션 확장 애니메이션 후)
- 지속시간: 400ms
- 이징: easeInOut

---

## 🧪 테스트 체크리스트

### 기능 테스트
- [ ] 프로필 데이터 자동 채우기 확인
- [ ] 완료된 섹션 접힘 확인
- [ ] 미완료 섹션 자동 확장 확인
- [ ] 다중 선택 섹션 열린 상태 유지 확인
- [ ] 자동 스크롤 중앙 정렬 확인
- [ ] 섹션 탭하여 재수정 가능 확인

### UI 테스트
- [ ] 다크모드 동작 확인
- [ ] 애니메이션 부드러움 확인
- [ ] 햅틱 피드백 확인
- [ ] Floating Button 위치 확인

---

## 💡 예상 효과

### 사용자 경험 개선
- ✅ 중복 입력 제거 → 입력 시간 50% 단축
- ✅ 자동 스크롤 → 입력 집중도 향상
- ✅ 다중 선택 유지 → 선택 편의성 향상
- ✅ 일관된 UX → 학습 곡선 제거

### 개발 효율성 향상
- ✅ 표준화된 컴포넌트 재사용
- ✅ 일관된 데이터 처리 로직
- ✅ 유지보수 용이성 증가

---

## 📞 문의

구현 중 문제가 발생하면 이 문서를 참조하거나, talent_fortune_input_page.dart의 구현을 참고하세요.
