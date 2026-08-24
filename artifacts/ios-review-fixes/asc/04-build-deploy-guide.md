# iOS 빌드 + 제출 가이드

커밋 완료 후 실제 빌드·제출까지의 순서. 현재 기본 경로는 **로컬 Xcode Archive → App Store Connect/TestFlight**이며 EAS Cloud Build를 사용하지 않습니다. 최신 정책은 `docs/development/expo-cng-build-and-release.md`가 우선합니다.

---

## 0. 사전 체크 (로컬 머신에서)

```bash
cd /Users/injoo/Desktop/Dev/fortune/apps/mobile-rn

# 1. 로컬 release 환경에 필요한 EXPO_PUBLIC_* 값이 준비됐는지 이름만 확인.
#    비밀 값 자체는 출력하거나 문서/로그에 남기지 않는다.

# 2. Xcode Settings > Accounts에서 Apple Developer 계정/Team이 활성인지 확인.

# 3. App Store Connect 앱의 bundle ID가 com.beyond.fortune인지 확인.
```

필요한 로컬 release 환경 변수(값은 안전한 로컬 환경에서만 제공):
- `EXPO_PUBLIC_SUPABASE_URL`
- `EXPO_PUBLIC_SUPABASE_ANON_KEY`
- `EXPO_PUBLIC_SENTRY_DSN`
- `EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID`
- (필요 시) `EXPO_PUBLIC_KAKAO_APP_KEY`

---

## 1. Prebuild — `ios/` 재생성 (중요)

로컬 `apps/mobile-rn/ios/` 폴더는 `.gitignore` 대상. `app.config.ts` 변경(scheme/다크모드/privacyManifests 등)을 적용하려면 **반드시** fresh prebuild 필요.

```bash
cd /Users/injoo/Desktop/Dev/fortune/apps/mobile-rn

# ios/ 재생성, CocoaPods 설치, workspace/scheme 확인
cd /Users/injoo/Desktop/Dev/fortune
pnpm rn:native:prepare
pnpm rn:native:doctor

# 검증 — 생성된 Info.plist에 실제로 반영됐는지 확인
plutil -p apps/mobile-rn/ios/app/Info.plist | grep CFBundleShortVersionString
plutil -p apps/mobile-rn/ios/app/Info.plist | grep UIUserInterfaceStyle   # → Dark
grep -c "com.beyond.fortune" apps/mobile-rn/ios/app/Info.plist          # → 1 (중복 없음)
plutil -p apps/mobile-rn/ios/app/Info.plist | grep NSSpeechRecognitionUsageDescription
grep "NSPrivacyCollectedDataType" apps/mobile-rn/ios/app/PrivacyInfo.xcprivacy | wc -l  # → 11
```

**위 검증 모두 통과해야 다음 단계 진행.** 하나라도 다르면 `app.config.ts` 설정이 반영 안 된 것.

---

## 2. Deno Edge Function 배포

Supabase edge function 변경분 먼저 배포. 클라이언트가 구 서버를 호출하는 동안 생기는 race 방지를 위해 **서버 먼저**.

### 2a. DB 마이그레이션 (P11 UGC)

```bash
cd /Users/injoo/Desktop/Dev/fortune

# 마이그레이션 파일 확인
ls supabase/migrations/20260423000001_ugc_moderation.sql

# production DB에 적용
npx supabase db push --linked

# 성공 확인
npx supabase migration list --linked
# → 20260423000001_ugc_moderation 이 Applied 로 뜨면 OK
```

### 2b. Edge Functions 배포

```bash
cd /Users/injoo/Desktop/Dev/fortune

# 신규 함수 1개
npx supabase functions deploy report-message --project-ref <PROJECT_REF>

# 수정된 함수들
npx supabase functions deploy character-chat --project-ref <PROJECT_REF>
npx supabase functions deploy kakao-oauth --project-ref <PROJECT_REF>
npx supabase functions deploy fortune-tarot --project-ref <PROJECT_REF>
npx supabase functions deploy fortune-birthstone --project-ref <PROJECT_REF>
npx supabase functions deploy fortune-health --project-ref <PROJECT_REF>
npx supabase functions deploy widget-cache --project-ref <PROJECT_REF>
npx supabase functions deploy delete-account --project-ref <PROJECT_REF>
```

### 2c. OpenAI Moderation 환경변수

```bash
# MODERATION_ENABLED default-on ('false' 만 OFF) — 별도 설정 불필요
# OPENAI_API_KEY 가 이미 설정돼 있는지만 확인
npx supabase secrets list --project-ref <PROJECT_REF> | grep OPENAI_API_KEY
```

### 2d. 스모크 테스트 (curl)

```bash
# 신고 엔드포인트 — 401 기대 (JWT 없이 호출)
curl -i -X POST "https://<PROJECT_REF>.supabase.co/functions/v1/report-message" \
  -H "Content-Type: application/json" \
  -d '{"character_id":"test","message_text":"x","reason_code":"spam"}'
# → HTTP/2 401

# Kakao OAuth — 401 기대 (access_token 무효)
curl -i -X POST "https://<PROJECT_REF>.supabase.co/functions/v1/kakao-oauth" \
  -H "Content-Type: application/json" \
  -d '{"access_token":"invalid"}'
# → HTTP/2 401, body: "카카오 인증에 실패했습니다."

# Widget cache — 401 기대 (JWT 없이 호출)
curl -i -X POST "https://<PROJECT_REF>.supabase.co/functions/v1/widget-cache" \
  -H "Content-Type: application/json" \
  -d '{}'
# → HTTP/2 401
```

---

## 3. iOS 빌드 + 제출

### 3a. 로컬 확인용 (시뮬레이터 QA)

```bash
cd /Users/injoo/Desktop/Dev/fortune
pnpm rn:native:build
# 시뮬레이터에서 다음 시나리오 수동 확인:
#   - welcome carousel (신규 설치) → 한 번만 뜸
#   - test@zpzg.com 로그인 → chat 진입 (welcome 건너뜀)
#   - Factory Reset (Profile → 앱 초기화) → 재온보딩
#   - AI 캐릭터와 대화 → long-press → 신고 시트 열림
#   - 캐릭터 프로필 → "차단하기" → 리스트에서 사라짐
#   - 다크모드 고정 확인 (시스템 라이트 모드에서도 앱은 다크)
```

### 3b. 로컬 Production Archive + 업로드

```bash
cd /Users/injoo/Desktop/Dev/fortune
pnpm rn:native:prepare
pnpm rn:ios:xcode
```

Xcode에서 다음 순서로 진행:

1. Ondo 앱 scheme과 `Any iOS Device (arm64)`를 선택한다.
2. Team, bundle ID `com.beyond.fortune`, entitlements, extensions, version/build number를 확인한다.
3. **Product → Archive**를 실행한다.
4. Organizer에서 archive를 Validate한다.
5. **Distribute App → App Store Connect → Upload**를 선택한다.
6. App Store Connect에서 exact version/build가 처리되어 TestFlight에 표시되는지 확인한다.

`eas build`, `eas submit`, `deploy:native`, `deploy:ota`는 기본 절차가 아니다. 사용자가 특정 EAS 작업과 비용/원격 배포를 명시 승인한 경우에만 사용한다.

### 3c. 빌드 검증

로컬 Xcode 로그, Organizer, App Store Connect에서 확인:
- [ ] `pnpm rn:native:prepare` 후 Info.plist/PrivacyInfo 정상 생성
- [ ] Hermes + New Architecture 활성화 확인
- [ ] `llama.rn` 네이티브 모듈 링크 성공
- [ ] dSYM 업로드 성공 (Sentry)
- [ ] 로컬 Archive 검증 성공
- [ ] exact archive 업로드 → ASC "Processing" → TestFlight 표시

---

## 4. ASC (App Store Connect) 작업

업로드된 IPA가 "Processing" → "Ready to Submit" 상태가 되면:

### 4a. App Privacy 답변 업데이트
`artifacts/ios-review-fixes/asc/01-app-privacy-answers.md` 참조. 11 data types 체크 + Publish.

### 4b. Review Notes 입력
`artifacts/ios-review-fixes/asc/02-review-notes.md` 의 Full Notes를 Review Notes 필드에 붙여넣기.

### 4c. 기타 필드
- **Support URL**: `https://zpzg.co.kr/support` (없으면 개설)
- **Marketing URL**: 옵션
- **Privacy Policy URL**: `https://zpzg.co.kr/privacy`
- **Contact Information**: 실제 담당자
- **Demo Account**: `test@zpzg.com / TestPassword123!`

### 4d. 스크린샷
`artifacts/ios-review-fixes/asc/05-screenshots-needed.md` 참조.

### 4e. 제출
Submit for Review.

---

## 5. 제출 후 모니터링

- **평균 리뷰 시간**: 24-48시간 (한국 시간 기준으로 월~금)
- **상태 추적**: ASC 앱 페이지 또는 TestFlight 앱
- **리젝 시**: Response 화면에서 상세 사유 확인 → `artifacts/ios-review/REPORT.md` WARNING 섹션 교차 체크

### 리젝 대응 템플릿 (자주 발생하는 것들)

- **"cannot reproduce"**: Review Notes에 iPad/iPhone 구분해 walkthrough 보강
- **"data collection not disclosed"**: ASC App Privacy와 manifest 재검증
- **"needs more time for review"**: 정상 — 기다리기
- **"crashes on launch"**: Sentry 즉시 확인. 대부분 env var 누락 또는 prebuild 미실행
