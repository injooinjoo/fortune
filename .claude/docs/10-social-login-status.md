# 소셜 로그인 상태 문서

## 현재 상태 (2025-11-27)

### 활성화된 로그인 방법
- **Google Sign In** - 활성화
- **Apple Sign In** - 활성화

### 임시 비활성화된 로그인 방법
- **카카오 로그인** - 임시 숨김 (코드 보존됨)
- **네이버 로그인** - 임시 숨김 (코드 보존됨)

---

## 비활성화 사유

1. **App Store 초기 런칭 집중**: Google/Apple에 집중하여 안정적인 런칭 진행
2. **App Store Guideline 4.0 준수**: Apple Sign In에서 제공하는 정보를 다시 요청하지 않도록 수정
3. **테스트 및 QA 범위 축소**: 초기 런칭 시 테스트 케이스 단순화

---

## 재활성화 방법

### 1. `social_login_bottom_sheet.dart` (랜딩 페이지 모달)
**파일 위치**: `lib/presentation/widgets/social_login_bottom_sheet.dart`

주석 처리된 부분을 찾아서 주석 해제:
```dart
// ============================================
// TEMPORARILY HIDDEN: Kakao & Naver Login
// ============================================
// const SizedBox(height: 12),
// // Kakao Login
// _buildSocialButton(...),
// const SizedBox(height: 12),
// // Naver Login
// _buildSocialButton(...),
```

### 2. `toss_style_name_step.dart` (온보딩 페이지 모달)
**파일 위치**: `lib/screens/onboarding/steps/toss_style_name_step.dart`

주석 처리된 부분을 찾아서 주석 해제:
```dart
// ============================================
// TEMPORARILY HIDDEN: Kakao & Naver Login
// ============================================
// const SizedBox(height: 12),
// _buildSocialLoginButton(
//   context: context,
//   label: '카카오로 계속하기',
//   ...
// ),
// const SizedBox(height: 12),
// _buildSocialLoginButton(
//   context: context,
//   label: '네이버로 계속하기',
//   ...
// ),
```

---

## 관련 코드 파일 목록

| 파일 | 역할 | 수정 여부 |
|------|------|----------|
| `lib/presentation/widgets/social_login_bottom_sheet.dart` | 랜딩 페이지 소셜 로그인 모달 | 수정됨 (카카오/네이버 숨김) |
| `lib/screens/onboarding/steps/toss_style_name_step.dart` | 온보딩 소셜 로그인 모달 | 수정됨 (카카오/네이버 숨김) |
| `lib/screens/landing_page.dart` | 랜딩 페이지 로직 | 변경 없음 (로직 보존) |
| `lib/services/social_auth_service.dart` | 소셜 인증 서비스 | 변경 없음 (기능 보존) |

---

## 재활성화 시 확인 사항

1. **카카오 개발자 콘솔 설정 확인**
   - Redirect URI 설정
   - 앱 키 유효성

2. **네이버 개발자 센터 설정 확인**
   - Callback URL 설정
   - Client ID/Secret 유효성

3. **Supabase Auth 설정 확인**
   - Kakao/Naver OAuth Provider 활성화
   - Redirect URL 설정

4. **테스트 케이스**
   - 신규 가입 플로우
   - 기존 계정 로그인
   - 계정 연동 (다른 소셜로 가입 후 연동 시도)

---

## 변경 이력

| 날짜 | 변경 내용 | 담당 |
|------|----------|------|
| 2025-11-27 | 카카오/네이버 로그인 버튼 임시 숨김 | Claude Code |
| 2025-11-27 | App Store Guideline 4.0 준수 (이름 입력 스킵) | Claude Code |
