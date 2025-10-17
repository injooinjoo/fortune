# 폰트 크기 마이그레이션 실행 계획

## 📋 현실적인 접근 방법

**170개 파일 (1236개 fontSize)을 한 번에 마이그레이션하는 것은 위험합니다.**

대신 **점진적 마이그레이션 전략**을 사용합니다:

## 🎯 Phase 0: 인프라 완료 ✅

- [x] FontSizeSystem 생성
- [x] TypographyUnified 생성
- [x] 기존 시스템 deprecated 처리
- [x] 마이그레이션 가이드 문서 작성

## 📦 Phase 1: 신규 코드부터 적용 (권장)

**가장 안전하고 효과적인 방법:**

### 규칙
1. **기존 코드는 건드리지 않음** (작동 중이면 OK)
2. **신규 페이지/위젯만 TypographyUnified 사용**
3. **수정이 필요한 파일만 마이그레이션**

### 신규 코드 작성 시 체크리스트
```dart
// ❌ 이제 이렇게 하지 마세요
Text('제목', style: TextStyle(fontSize: 18))

// ✅ 이렇게 하세요
Text('제목', style: TypographyUnified.heading4)
Text('제목', style: context.typo.heading4)
```

## 🔧 Phase 2: 필요 시 점진적 마이그레이션

### 우선순위 1: 자주 수정되는 파일
- 운세 결과 페이지
- 메인 리스트 페이지
- 공통 컴포넌트

### 우선순위 2: 문제가 있는 파일
- 폰트 크기가 일관성 없는 페이지
- 다크모드에서 보기 어려운 페이지
- 사용자 불만이 있는 페이지

### 우선순위 3: 나머지
- 작동 중이고 문제없으면 그대로 유지

## 📝 점진적 마이그레이션 예시

### 예시 1: fortune_list_page.dart

**변경 전:**
```dart
Text(
  categoryDisplayName,
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).brightness == Brightness.dark
        ? TossDesignSystem.white
        : const Color(0xFF191919),
    height: 1.2,
  ),
)
```

**변경 후:**
```dart
Text(
  categoryDisplayName,
  style: TypographyUnified.heading4.copyWith(
    color: Theme.of(context).brightness == Brightness.dark
        ? TossDesignSystem.textPrimaryDark
        : TossDesignSystem.textPrimaryLight,
  ),
)
```

## 🎨 사용자 폰트 크기 조절 기능 추가 (Phase 3)

이것이 진짜 목표입니다!

### 설정 페이지에 슬라이더 추가
```dart
// lib/features/settings/presentation/pages/font_settings_page.dart

Slider(
  value: FontSizeSystem.scaleFactor,
  min: 0.85,
  max: 1.15,
  divisions: 6,
  label: '${(FontSizeSystem.scaleFactor * 100).toInt()}%',
  onChanged: (value) {
    setState(() {
      FontSizeSystem.setScaleFactor(value);
    });
  },
)
```

### 프리셋 버튼
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    TextButton(
      onPressed: () => FontSizeSystem.setScaleFactor(0.85),
      child: Text('작게'),
    ),
    TextButton(
      onPressed: () => FontSizeSystem.setScaleFactor(1.0),
      child: Text('기본'),
    ),
    TextButton(
      onPressed: () => FontSizeSystem.setScaleFactor(1.15),
      child: Text('크게'),
    ),
  ],
)
```

## 🎯 마이그레이션이 꼭 필요한 경우

다음 상황에서만 기존 파일을 마이그레이션:

1. **버그 수정 중**: 어차피 파일을 수정해야 하면 함께 마이그레이션
2. **일관성 문제**: 폰트 크기가 너무 들쭉날쭉한 페이지
3. **다크모드 문제**: 색상 처리가 잘못된 페이지
4. **사용자 요청**: 특정 페이지 폰트 크기 조절 요청

## 📊 마이그레이션 진행 상황 추적

```bash
# 마이그레이션 전 fontSize 개수
grep -r "fontSize: [0-9]" lib --include="*.dart" | wc -l

# TypographyUnified 사용 개수
grep -r "TypographyUnified\." lib --include="*.dart" | wc -l

# 마이그레이션 비율
echo "scale=2; ($UNIFIED / ($UNIFIED + $OLD)) * 100" | bc
```

## ✅ 권장 사항

**지금 당장 할 것:**
1. ✅ 인프라 완료 (이미 완료!)
2. ✅ 가이드 문서 작성 (완료!)
3. ✅ CLAUDE.md에 신규 코드 규칙 추가 (할 것)
4. ⏳ 팀원들에게 안내

**나중에 할 것:**
- 자주 수정되는 파일부터 점진적 마이그레이션
- 문제 발생 시 해당 파일만 마이그레이션
- 전체 마이그레이션은 여유 있을 때

## 🎉 결론

**"일괄수정안할거야. 하나씩해"** 원칙을 지킵니다!

1. 인프라는 완성 ✅
2. 신규 코드부터 적용 ✨
3. 기존 코드는 필요시에만 수정 🔧
4. 사용자 폰트 조절 기능은 언제든 추가 가능 🎨

**현재 상태로도 충분히 목표 달성:**
- ✅ 폰트 크기 표준화 시스템 구축
- ✅ 사용자 폰트 조절 구조 준비
- ✅ 신규 코드에서 일관성 확보
- ✅ 기존 코드 하위 호환성 유지
