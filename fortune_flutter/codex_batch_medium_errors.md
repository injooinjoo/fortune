# OpenAI Codex 문법 수정 요청 - 중간 에러 파일 배치

**Flutter/Dart 프로젝트 문법 에러 수정 요청**

## 📁 수정 대상 파일 (5개 파일, 총 404 에러)

```
lib/features/fortune/presentation/pages/sports_fortune_page.dart (95 errors)
lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart (61 errors)
lib/screens/onboarding/onboarding_flow_page.dart (55 errors)
lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart (98 errors)
lib/features/fortune/presentation/widgets/career_fortune_selector.dart (116 errors)
```

## 📋 중요 제약사항
- **오직 문법 에러만 수정** (세미콜론, 괄호, 콤마 누락 등)
- **로직 변경 금지**
- **기능 변경 금지**
- **주석 추가 금지**
- **import 문 유지**

## 🛠️ 주요 문법 에러 패턴
1. 누락된 세미콜론 (`;`)
2. 닫히지 않은 괄호 (`{}`, `[]`, `()`)
3. 누락된 콤마 (`,`)
4. 잘못된 따옴표
5. 괄호 매칭 오류

**이 5개 파일의 문법 에러만 수정해주세요.**