프로젝트의 아키텍처 규칙 준수 여부를 검증합니다.

## 검증 항목

### 1. 레이어 의존성 검사

```bash
# Presentation → Data 직접 참조 검사
grep -r "import.*data/services" lib/features/*/presentation/
grep -r "import.*data/repositories" lib/features/*/presentation/

# Feature 간 직접 참조 검사
grep -r "import.*features/fortune" lib/features/profile/
grep -r "import.*features/profile" lib/features/fortune/
```

### 2. @riverpod 어노테이션 검사

```bash
# @riverpod 사용 여부 검사
grep -r "@riverpod" lib/
grep -r "extends _\$" lib/
```

### 3. 하드코딩 색상 검사

```bash
# Color() 하드코딩 검사
grep -r "Color(0x" lib/
grep -r "Colors\." lib/ | grep -v "TossDesignSystem"
```

### 4. 하드코딩 fontSize 검사

```bash
# fontSize 하드코딩 검사
grep -r "fontSize:" lib/ | grep -v "TypographyUnified"
```

### 5. TossDesignSystem 폰트 사용 검사

```bash
# deprecated 폰트 스타일 사용 검사
grep -r "TossDesignSystem\.heading" lib/
grep -r "TossDesignSystem\.body" lib/
grep -r "TossDesignSystem\.caption" lib/
```

### 6. 블러 직접 구현 검사

```bash
# ImageFilter.blur 직접 사용 검사
grep -r "ImageFilter.blur" lib/ | grep -v "unified_blur_wrapper"
```

### 7. 뒤로가기 아이콘 검사

```bash
# Icons.arrow_back 사용 검사 (arrow_back_ios 사용해야 함)
grep -r "Icons\.arrow_back[^_]" lib/
```

## 출력 형식

```
============================================
🔍 아키텍처 검증 리포트
============================================

✅ 레이어 의존성: 위반 없음
❌ @riverpod 어노테이션: 2개 파일에서 발견
   - lib/features/fortune/presentation/providers/fortune_provider.dart
   - lib/features/profile/presentation/providers/profile_provider.dart

✅ 하드코딩 색상: 위반 없음
❌ 하드코딩 fontSize: 5개 파일에서 발견
   ...

============================================
총 위반: 7건
============================================
```

## 자동 수정 제안

위반 사항이 발견되면 올바른 패턴으로 수정하는 방법을 제안합니다.

## 관련 Agent

- flutter-architect

