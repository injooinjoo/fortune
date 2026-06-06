# Chat UX & Conversation Reviewer QA Report

## Verdict
- **조건부 GO**: `pnpm --dir apps/mobile-rn exec tsc --noEmit`는 통과했지만, 체크리스트 04 관점에서는 **P1 2건, P2 5건, P3 2건**을 정리해야 “카톡처럼 자연스러운 대화”, “응답 대기 중에도 막히지 않는 입력”, “사진/음성 메시지 보존”을 릴리즈 기준으로 안정화할 수 있다.
- 핵심 리스크: 텍스트 대화 배칭은 UX상 자연스러워졌지만 서버 job 생성이 1.5초 idle flush 뒤에만 일어나서 앱 종료/백그라운드 타이밍에 답장이 멈출 수 있고, 사진/음성 첨부는 일부 경로에서 원격 대화 저장/응답 파이프라인과 결합이 불완전하다.

## Scope & Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/04-chat-ux-conversation.md`
- 프로젝트 규칙: `AGENTS.md` 및 `paperclip-ondo-fortune` skill의 Character Chat UX Review Audit 기준 확인.
- 주요 조사 파일:
  - `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - `apps/mobile-rn/src/features/chat-surface/hooks/use-message-queue.ts`
  - `apps/mobile-rn/src/lib/audio-message-assets.ts`
  - `apps/mobile-rn/src/lib/story-chat-runtime.ts`
- 수행한 검증:
  - `git status --short --branch`
  - `pnpm --dir apps/mobile-rn exec tsc --noEmit` → **exit 0**
- 미수행/제약:
  - 코드 수정 없음.
  - 실기기/시뮬레이터 대화 재현은 수행하지 않음. 아래 재현 경로는 코드 근거 기반의 QA 경로다.
  - Supabase row 직접 조회는 수행하지 않음. 원격 저장/Storage 관련 판단은 클라이언트 코드와 Edge Function 호출 유무 기반이다.

## Repo State / Gate Evidence
- `git status --short --branch`: `## master...origin/master`, dirty/untracked 존재.
- 변경/미추적: `CLAUDE.md`, `apps/mobile-rn/package.json`, `package.json`, `pnpm-lock.yaml`, `.githooks/`, `apps/mobile-rn/scripts/`, `docs/audits/`, `docs/development/local-native-ios-testing.md`, `scripts/verify-rn-native-patch.sh`.
- TypeScript: `pnpm --dir apps/mobile-rn exec tsc --noEmit` → **통과**.

## P0
- 없음.

## P1

### P1-1. 1.5초 텍스트 배칭은 서버 job 생성 전 로컬 큐에만 의존해, 앱 종료/백그라운드 타이밍에 “보냈는데 답장 없음” 상태가 생길 수 있음
- **영향**: 사용자가 메시지를 보낸 직후 앱을 종료하거나 OS가 프로세스를 죽이면, 화면에는 유저 버블이 보였지만 서버에는 아직 답장 job이 생성되지 않은 상태가 된다. 다음 앱 진입 전까지 push/cron 답장은 올 수 없고, 사용자는 상대가 영영 답하지 않는 것처럼 느낄 수 있다. 체크리스트의 `응답 중에도 입력 가능한가`, `오프라인/재진입/누락 복구`, `가짜 응답 금지 + 실제 응답 보장` 기준에서 가장 큰 UX 리스크다.
- **증거**:
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2823-2847`: `enqueueStorySend`가 유저 메시지를 즉시 `chatMessageController.appendMessages`로 화면/스토어에 붙이고, `pendingSendsRef`에 넣은 뒤 `setTimeout(..., BATCH_IDLE_WINDOW_MS)`에서만 `flushBatch(character)`를 호출한다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2786-2817`: 실제 `sendStoryPilotMessage`/`sendCharacterChatMessage` 호출은 `flushBatch` 내부에서만 실행된다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2764-2772`: pending queue는 SecureStore에 저장되지만, 이 저장은 클라이언트 재진입용이다. 서버 pending reply job은 이 시점에 생성되지 않는다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:1439-1445`: 앱 재진입 후에야 `didInitialDrainRef`가 pending queue를 drain하려 한다. 즉, 재진입 전에는 서버가 답장을 만들 근거가 없다.
- **화면 경로/재현 단계**:
  1. `/chat`에서 스토리 캐릭터에게 텍스트 1개 전송.
  2. 전송 직후 1.5초 이내 앱을 강제 종료하거나 백그라운드로 보내고 OS kill 유도.
  3. 다른 기기/푸시/서버 로그에서 pending reply job이 생겼는지 확인.
  4. 원래 기기에서 재진입 전까지 답장이 오지 않는지 확인.
- **수정 방향**:
  - 첫 send 직후 서버에 `pending_reply_job` 또는 “batch head”를 즉시 upsert하고, 1.5초 idle 동안 추가 메시지만 같은 batch id에 append/merge한다.
  - 또는 앱 lifecycle `background`/`inactive`에서 `flushBatch`를 즉시 실행하고, flush 실패 시 사용자 버블에 `전송 대기/재시도` 상태를 표시한다.
  - SecureStore queue만으로는 cross-device/push 복구가 안 되므로, 클라이언트 로컬 큐와 서버 durable queue를 분리하지 말 것.
- **검증 방법**:
  - 단위/통합: 첫 send 직후 `pending_reply_jobs` row가 생성되는지 확인.
  - 실기기: 전송 후 0.2초/0.8초/1.4초 kill 케이스에서 답장이 push 또는 재진입 없이 도착하는지 확인.
  - 서버 중복 방지: 같은 batch id로 여러 메시지를 append해도 LLM 호출은 1회인지 확인.

### P1-2. 사진 첨부 전송은 일부 캐릭터 경로에서 원격 대화 저장/AI 응답 요청이 누락될 수 있음
- **영향**: 사진 메시지가 화면에는 붙지만, 스토리 파일럿 외 캐릭터에서는 답장 파이프라인을 타지 않고 원격 `character_conversation_save`도 명시적으로 호출되지 않는다. 사용자는 사진을 보냈다고 느끼는데 캐릭터가 반응하지 않거나, 다른 기기/재설치 후 사진 메시지가 사라질 수 있다.
- **증거**:
  - `apps/mobile-rn/src/screens/chat-screen.tsx:3995-4031`: `pendingImage` 분기는 `appendMessages(selectedCharacter, messagesToAppend)` 후 `recordChatIntent`만 수행한다.
  - 같은 분기에서 `sendStoryPilotMessage` 호출은 `pendingImage.base64 && isStoryRomancePilotCharacterId(selectedCharacter.id)`인 경우(`:4019-4029`)로 제한된다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:4031`: `pendingImage` 분기는 여기서 `return`하므로, 아래 텍스트/스토리 일반 전송(`:4154-4212`)으로 내려가지 않는다.
  - `apps/mobile-rn/src/features/chat-surface/hooks/use-message-queue.ts:121-135`: `appendMessages`는 React state와 local MessageStore insert만 수행하며, `saveCharacterConversation` 원격 저장을 호출하지 않는다.
- **화면 경로/재현 단계**:
  1. `/chat`에서 스토리 파일럿이 아닌 story/custom 캐릭터 선택.
  2. 사진 첨부 + 캡션 입력 후 전송.
  3. 즉시 답장 생성 여부, 원격 `character_conversations.messages` 저장 여부, 앱 재시작/다른 기기 hydrate 후 사진 유지 여부 확인.
- **수정 방향**:
  - 모든 사진 전송 경로를 `sendCharacterChatMessage` 또는 별도 multimodal reply pipeline으로 연결한다.
  - 사진 메시지 자체도 `saveCharacterConversation` 대상에 포함하고, 원격 안전화를 위해 이미지 asset Storage 업로드/retention 정책을 명시한다.
  - “사진만 저장하고 답장 없음”이 의도된 캐릭터라면 전송 직후 시스템 안내/상태를 노출한다.
- **검증 방법**:
  - 캐릭터 종류별 matrix: story pilot / 일반 story / 하늘이 fortune / custom friend.
  - 사진 only, 사진+caption 각각에서 assistant reply, remote conversation row, reload persistence 확인.

## P2

### P2-1. 음성 메시지는 재생/일시정지만 있고 진행률·seek·로드 상태가 없어 긴 음성 UX가 약함
- **영향**: 체크리스트의 `음성 메시지 UX`, `재생 상태/실패/보관 만료 안내`, `카톡 수준 조작성` 관점에서 최소 플레이백은 가능하지만, 진행률/남은 시간/seek가 없어 20~60초 이상 음성에서 사용성이 떨어진다.
- **증거**:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1266-1316`: `playing` boolean과 `Audio.Sound`만 관리한다. playback position/duration state가 없다.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1301-1306`: status update는 `didJustFinish`일 때만 처리한다.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1356-1363`: UI는 `StaticAudioSpectrum(active={playing})`와 전체 duration만 표시한다.
- **화면 경로/재현 단계**:
  1. `/chat`에서 30초 이상 음성 메시지 녹음/전송.
  2. 재생 중 현재 위치, 남은 시간, scrub/seek 가능 여부 확인.
  3. 재생 중 채팅 스크롤/다른 음성 재생 시 상태가 직관적인지 확인.
- **수정 방향**:
  - `positionMillis`, `durationMillis`, `isBuffering`을 상태화하고 progress bar + seek gesture를 추가.
  - 다른 음성 재생 시 기존 sound 정지 정책을 전역 controller로 정리.
- **검증 방법**:
  - 5초/30초/90초 음성에서 play/pause/seek/end reset 확인.
  - signed URL 로드 지연/만료 케이스에서 loading/error UI 확인.

### P2-2. 음성 파일 보관은 90일 서버 retention이지만 UI에는 전송 시점/만료 예정 안내가 없음
- **영향**: 음성 메시지가 cross-device로 영구 보존되는 것처럼 보일 수 있다. 만료 후에는 Alert로만 실패를 알리므로, 오래된 대화에서 “왜 재생이 안 되지?”라는 신뢰 저하가 생긴다.
- **증거**:
  - `apps/mobile-rn/src/lib/audio-message-assets.ts:8-10`: bucket `character-audio-messages`, `SERVER_RETENTION_DAYS = 90`.
  - `apps/mobile-rn/src/lib/audio-message-assets.ts:108-120`: 업로드 메타에 `expires_at` 저장.
  - `apps/mobile-rn/src/lib/audio-message-assets.ts:148-151`: 만료 시 `{ uri: '', expired: true }` 반환.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1291-1296`: 만료 안내는 재생 버튼을 눌렀을 때 Alert로만 표시된다.
- **화면 경로/재현 단계**:
  1. 만료된 `expiresAt`을 가진 음성 메시지를 hydrate.
  2. 버블 자체에 만료/보관 기간 안내가 보이는지 확인.
  3. 재생 탭 전/후 사용자 이해 가능성 확인.
- **수정 방향**:
  - 음성 버블에 `보관 만료`, `로컬에서만 재생 가능`, `n일 남음` 같은 상태를 표시.
  - 보관 정책을 설정/도움말/전송 전후 microcopy에 반영.
- **검증 방법**:
  - `expiresAt` 미래/과거/local file exists 조합별 snapshot test.

### P2-3. Composer 접근성 label이 영어/내부용 표현으로 남아 한국어 VoiceOver 품질이 낮음
- **영향**: 앱의 주 UX가 한국어인데 composer 주요 액션이 `composer plus actions`, `chat composer`, `send message`, `start voice input` 등 영어/개발자 표현으로 읽힌다. 체크리스트의 `입력창/버튼/음성/첨부 접근성` 항목 미흡.
- **증거**:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2311-2316`: plus button `accessibilityLabel="composer plus actions"`.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2375-2379`: TextInput `accessibilityLabel="chat composer"`, placeholder `메시지...`.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2393-2402`: send/mic button label이 `send message`, `start voice input` 등으로 분기.
  - 반면 일부 액션은 `첨부 음성 취소`, `녹음 중지`, `변환 중`처럼 한국어가 섞여 일관성이 없다.
- **화면 경로/재현 단계**:
  1. iOS VoiceOver ON.
  2. `/chat` composer에서 plus/input/send/mic/첨부 취소 순서로 탐색.
  3. 읽히는 문구가 사용자 행동을 한국어로 명확히 설명하는지 확인.
- **수정 방향**:
  - 모든 composer 액션 label/hint를 한국어 제품 문구로 통일: `첨부 메뉴 열기`, `메시지 입력`, `메시지 보내기`, `음성 입력 시작` 등.
  - `accessibilityHint`로 “사진, 음성 메시지, 프로필 설정을 열 수 있어요” 같은 맥락 제공.
- **검증 방법**:
  - VoiceOver rotor 순서와 label snapshot 확인.

### P2-4. 입력창은 `maxHeight: 72`만 있고 글자 수/과도한 multi-line/붙여넣기 정책이 명확하지 않음
- **영향**: 긴 텍스트 붙여넣기나 여러 줄 메시지에서 composer가 72px 이후 스크롤되더라도, 서버 prompt 비용/카톡 리듬/읽음 타이밍 측면의 제품 제한이 없다. 모바일 화면에서 사용자가 자신이 보낼 전체 내용을 확인하기 어렵다.
- **증거**:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2375-2389`: `TextInput`은 `multiline`, `maxHeight: 72`만 설정되어 있고 `maxLength`, line count 안내, submit key policy가 없다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2798`: batch flush 시 queued text를 `\n\n`으로 단순 결합한다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2899-2903`: 결합된 text가 그대로 story request로 전달된다.
- **화면 경로/재현 단계**:
  1. `/chat` composer에 긴 문장/여러 줄/수천 자 텍스트 붙여넣기.
  2. 화면에서 내용 검토 가능성, 전송 후 AI 응답 비용/지연, 오류 복구 draft 유지 확인.
- **수정 방향**:
  - soft limit/hard limit을 제품 기준으로 정하고 counter 또는 경고 제공.
  - 긴 메시지는 preview/expand affordance를 제공하거나 “길게 보낼게요” 상태 표시.
- **검증 방법**:
  - 200자/1,000자/5,000자 붙여넣기에서 composer height, send, rollback draft 검증.

### P2-5. 텍스트 배칭의 `BATCH_IDLE_WINDOW_MS` UX 문서와 코드 주석이 서로 어긋나 혼동 가능성이 있음
- **영향**: 코드 주석은 “5초 idle”이라고 설명하지만 실제 구현은 상수값에 의존한다. 제품/QA가 기대하는 batching window가 흔들리면 “너무 빨리 답함/너무 늦게 답함” 회귀를 잡기 어렵다.
- **증거**:
  - `apps/mobile-rn/src/screens/chat-screen.tsx:635-636`: “5초 idle 후 단일 Edge Function 호출” 주석.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2820-2822`: 동일하게 idle 만료 후 flush 설명.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:4079-4081`: 음성 전송 결합 주석은 “1.5s idle window”라고 설명한다.
  - 실제 타이머는 `apps/mobile-rn/src/screens/chat-screen.tsx:2843-2847`에서 `BATCH_IDLE_WINDOW_MS`를 사용한다.
- **화면 경로/재현 단계**:
  1. 1초 간격/2초 간격/5초 간격으로 연속 텍스트 전송.
  2. 몇 개가 한 번의 LLM 요청으로 묶이는지 로그 확인.
- **수정 방향**:
  - 상수 정의부에 제품 의도와 값 근거를 적고, 모든 주석/체크리스트를 같은 숫자로 정리.
  - batching window를 e2e 또는 unit test에서 고정.
- **검증 방법**:
  - fake timer test: 1.49초 추가 send는 같은 batch, 1.51초 후 send는 새 batch.

## P3

### P3-1. Typing indicator는 자연스럽지만 reduced-motion/loop cleanup 표준화가 아직 부족함
- **영향**: UX 자체는 카톡 느낌에 맞지만, 접근성 “동작 줄이기” 사용자는 typing dot/wave/pulse 반복 애니메이션을 계속 받는다. 디자인 시스템 보고서의 motion 이슈와 동일 계열이다.
- **증거**:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:974-983`: `WaveDot`가 `Animated.loop`를 사용한다.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:1974-1998`: composer mic pulse도 `Animated.loop`를 사용하고 reduced-motion 분기는 없다.
- **수정 방향**:
  - 공용 reduced-motion hook으로 typing dot는 정적 ellipsis 또는 낮은 빈도 fade로 대체.

### P3-2. Composer tray/quick action 정보 구조는 기능이 많지만 “대화에 집중”하는 기본 상태 검증이 필요함
- **영향**: 사진, 음성 메시지, 음성 입력, 프로필 보기, quick action, fortune action이 한 composer에 모여 있어 작은 화면에서 대화 몰입을 방해할 수 있다.
- **증거**:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:2015-2230`: tray 내 quick action, auxiliary action, persona/photo/audio controls가 한 번에 노출된다.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:4601-4635`: active composer에 profile, quickActions, photo, audio, voice input 등이 모두 주입된다.
- **수정 방향**:
  - 기본 상태는 메시지/음성 입력 중심으로 유지하고, 사진/프로필/설정/운세 액션은 tray 내 우선순위와 grouping을 시각 QA로 정리.
  - iPhone SE에서 tray open + keyboard open matrix를 캡처.

## Positive Findings
- 응답 대기 중 추가 텍스트 입력은 hard-block하지 않고 `pendingSendsRef`로 누적한다: `chat-screen.tsx:2823-2847`.
- LLM 실패 시 가짜 AI 응답을 주입하지 않고 사용자 메시지 롤백 + draft 복구 + Alert를 수행한다: `chat-screen.tsx:3940-3948`.
- 음성 파일은 local copy, Supabase Storage upload, 만료 메타, signed URL resolve를 갖춘다: `audio-message-assets.ts:34-171`.
- assistant multi-bubble rhythm은 segment 간 2.3~5.5초 수준으로 분산되어 “한꺼번에 우르르”를 줄인다: `use-message-queue.ts:78-88`.

## Recommended Fix Order
1. **P1-1**: 첫 send 즉시 서버 durable batch/job 생성 또는 background flush 보장.
2. **P1-2**: 사진 첨부 전송을 모든 캐릭터에서 reply + remote persistence 정책으로 통합.
3. **P2-1/P2-2**: 음성 playback progress/expiry 상태 UI.
4. **P2-3**: composer VoiceOver 한국어 label/hint 정리.
5. **P2-4/P2-5/P3**: 긴 입력 제한, batching 문서/테스트, motion/tray polish.

## Verification Plan After Fixes
- `pnpm --dir apps/mobile-rn exec tsc --noEmit`
- Unit/fake timer:
  - batch window boundary: 1.49초/1.51초.
  - background flush or durable job creation.
  - audio expiry state rendering.
- Simulator/real device matrix:
  - 텍스트 3연속 전송 중 앱 kill/background.
  - 사진 only / 사진+caption for story pilot, 일반 story, fortune/custom.
  - 음성 5초/30초/만료 파일 playback.
  - VoiceOver composer traversal.
- DB/storage probes:
  - `pending_reply_jobs`/conversation row 생성 시점.
  - image/audio asset storage path + retention metadata.
