# OpenAI Codex 문법 수정 요청 - profile_screen.dart

**Flutter/Dart 프로젝트 문법 에러 수정 요청**

## 📁 수정 대상 파일
```
lib/screens/profile/profile_screen.dart
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
6. `Column` children 배열에서의 문법 오류
7. 위젯 빌더 메서드에서의 반환 타입 오류

## 🔍 파일 분석
이 파일은 사용자 프로필 화면을 구현합니다. 주로 다음과 같은 구조를 가집니다:
- `ConsumerStatefulWidget` 상속
- Supabase 인증 및 데이터 로드
- 다양한 섹션 (기본 정보, 테스트 계정, 사주, 오행, 통계 등)
- 커스텀 위젯 메서드들 (`_buildInsightItem`, `_buildNextStepItem` 등)

**이 파일의 문법 에러만 수정해주세요.**