# Fortune Flutter App - Claude Code 개발 규칙

## 앱 개발 완료 후 필수 작업

### 🔄 앱 완전 재설치 및 실행 필수
- **모든 개발 작업 완료 후 반드시 앱을 완전히 재설치하여 변경사항 검증**
- Hot Restart나 Hot Reload는 변경사항이 제대로 반영되지 않을 수 있음
- 다음 명령어 순서로 완전 재설치 실행:

```bash
# 1. 기존 Flutter 프로세스 종료
pkill -f flutter

# 2. 빌드 캐시 정리
flutter clean

# 3. 의존성 재설치
flutter pub get

# 4. 시뮬레이터에서 앱 삭제
xcrun simctl uninstall 1B54EF52-7E41-4040-A236-C169898F5527 com.beyond.fortuneFlutter

# 5. 앱 새로 빌드 및 실행
flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527
```

## Flutter 개발 워크플로우

1. **코드 수정 및 개발**
2. **Hot Reload로 빠른 테스트** (`r` 키)
3. **개발 완료 후 Hot Restart로 전체 검증** (`R` 키)
4. **최종 확인 완료**

## 검증 포인트

### 🚀 앱 시작 플로우
- 스플래시 화면 → 로그인 상태 확인 → 적절한 페이지 라우팅
- 로그인 안 된 경우: LandingPage(시작하기 버튼) 표시
- 로그인 된 경우: 프로필 상태에 따라 onboarding 또는 home 이동

### 🔐 인증 플로우
- 소셜 로그인 (Google, Apple, Kakao, Naver)
- 로그인 상태에 따른 UI 변화
- "오늘의 이야기가 완성되었어요!" 화면은 미로그인 사용자만 표시

### 📱 핵심 기능
- 운세 생성 및 표시
- 사용자 프로필 관리
- 온보딩 플로우

## 개발 시 주의사항

- 로그인 상태와 관계없이 모든 플로우가 정상 작동하는지 확인
- 프로필 완성도에 따른 라우팅 로직 검증
- Hot Restart 후 초기 상태에서의 동작 확인

---

이 파일은 Claude Code가 이 프로젝트에서 작업할 때 자동으로 참조하는 개발 규칙입니다.