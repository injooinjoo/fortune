# Ondo RN — Changelog

테스트 중 실제 디바이스의 프로필 하단에 표시되는 버전(`v1.x.x`)과 이 문서의 버전을 맞춰 보며 어떤 변경이 반영됐는지 확인할 수 있도록 관리합니다.

표기 규칙:
- `v1.x.y` — `app.config.ts` + `package.json` 의 `version` 과 일치
- 네이티브 모듈 추가/제거가 있으면 새 EAS Build 필요 (OTA로 불가)

---

## v1.0.9 — 2026-04-18

### Ondo 디자인 시스템 1차 마이그레이션
- 신규 컴포넌트 5종: `ToneSlider`, `RelationshipCard`, `CharacterCard`, `OnboardingShell`, `FortuneSummaryCard`
- `profile-relationships-screen` 의 로컬 `CharacterRelationshipCard` → 공용 `CharacterCard` 사용으로 교체
- `@fortune/design-tokens` additive 확장: 五行 컬러 (`elemental.{wood,fire,earth,metal,water}`), `accentPressed`, `accentSubtle`, `fortuneShadows.raised`
- `components/index.ts` 배럴에 5개 컴포넌트 re-export 추가

### Welcome carousel
- 신규 3-slide paging 캐러셀 (`welcome-screen.tsx`, `app/welcome.tsx`)
- `welcome-state.ts` — `expo-secure-store` 기반 `markWelcomeSeen` / `readWelcomeSeen`
- `splash-screen.tsx` — `auth-entry` gate 에서 welcome-seen 체크 후 `/welcome` → `/signup`
- **DEV 플래그**: `splash-screen.tsx:13` `FORCE_WELCOME_FOR_DEV=true` — 개발 중 모든 실행에서 welcome 강제 노출. 개발 완료 후 `false` 로 복원 필요.

### On-device LLM 엄격 모드
- `chat-provider.ts`: `aiMode='on-device'` 일 때 모델 미준비면 `OnDeviceNotReadyError` throw (은폐 클라우드 폴백 제거). `auto` 모드만 폴백 허용.
- `chat-screen.tsx`: `sendStoryPilotMessage` / `sendCharacterChatMessage` 두 경로에 OnDeviceNotReadyError 핸들러 + `sendCharacterChatMessage` 에서도 aiMode 기반 로컬 provider 라우팅 추가
- 자동 다운로드: `on-device-auto-downloader.tsx` → `_layout.tsx` 삽입. `aiMode !== 'cloud'` + `status='not-downloaded'` 이면 백그라운드로 모델 다운로드 시작

### 프로필
- 로그인 페이지 "다른 방법으로 시작" 섹션을 chevron 아코디언으로 변경
- 로그인 페이지에서 guest browse 섹션 제거
- `Screen` 에 `centerContent` prop 추가 (ScrollView 수직 가운데)
- 메시지 리스트 내 친구 행 탭 시 삭제 underlay 비침 버그 fix (asymmetric bubble wrapper에 `backgroundColor: tintBg` 추가)
- 프로필 하단 버전 표시 강화: `v<ver> · rt <runtime>` + OTA/embedded 배지 (`channel · #updateId · createdAt`)

---

## v1.0.8 이전

이 문서 이전 변경은 `git log` 참조.
