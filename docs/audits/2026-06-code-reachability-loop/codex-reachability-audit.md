# Codex 도달성 감사 리포트

- 대상: Ondo/Fortune Expo React Native workspace `apps/mobile-rn`
- 작성일: 2026-06-16
- 작성자: Codex
- 원칙: `AGENTS.md`, `CLAUDE.md` 기준. 앱 코드 삭제/수정 없음. 이미 dirty인 working tree 보존. 이 리포트 파일만 생성.

## 1. 입력 사실과 범위

사용자 제공 선행 사실:

- `source_inventory check` 통과
- `pnpm --filter @fortune/mobile-rn exec tsc --noEmit` 통과
- `knip --workspace apps/mobile-rn --production` unused 후보:
  - `babel.config.js`
  - `plugins/with-ios-prebuilt-react-native.js`
  - `scripts/local-ios.mjs`
  - `scripts/remote-metro.mjs`
  - `components/index.ts`
  - `fortune-results`의 menu, manseryeok, primitives index, story timeline, screens batch-a-e, birthstone, celebrity, face-reading, lucky-items, moving, naming, pet-compatibility, `use-result-data`
  - `haneul-quick-actions`
  - `ios-widgets/types`
  - `birthstone-data`
- `jscpd`: 44 clone groups. 큰 그룹은 fortune-results screens, chat-screen, widget data sync/live, Supabase Edge boilerplate.

본 리포트의 판정 기준:

- `DO_NOT_DELETE_FALSE_POSITIVE`: import 그래프에는 안 보이거나 knip가 놓쳤지만 Expo/CLI/config/route/registry로 현재 기능에 필요.
- `SAFE_DELETE`: 현재 startup/routes/registry 기준으로 production reachable 경로가 없고, cleanup loop에서 그룹 단위 삭제 후 `tsc/knip/source_inventory`로 검증할 후보.
- `NEEDS_FEATURE_VERIFICATION`: 현재 경로에서는 미도달이나 주석, 플래그, 문서, 제품 의도가 남아 있어 삭제 전 기능 의도 확인이 필요한 후보.

## 2. Startup Graph

```text
apps/mobile-rn/package.json
  main: expo-router/entry
    -> app/_layout.tsx
       -> initCrashReporting()
       -> SafeAreaProvider
       -> ThemeProvider(navigationTheme)
       -> AppBootstrapProvider
       -> MobileAppStateProvider
       -> OnDeviceAutoDownloader
       -> WidgetSyncBridge
       -> OnboardingFlowProvider
       -> FriendCreationProvider
       -> SocialAuthProvider
       -> Stack
          - (tabs)
          - result/[resultKind]
    -> app/index.tsx
       -> Redirect /splash
    -> app/splash.tsx
       -> SplashScreen
          gate=auth-entry     -> /welcome 또는 /chat?showList=1
          gate=profile-flow   -> /onboarding
          gate=ready/default  -> /chat
```

핵심 증거:

- `apps/mobile-rn/package.json:4` `main: "expo-router/entry"`
- `apps/mobile-rn/app/_layout.tsx:78-79` Stack에 `(tabs)`, `result/[resultKind]`
- `apps/mobile-rn/app/index.tsx:8` `/splash` redirect
- `apps/mobile-rn/src/screens/splash-screen.tsx:112-129` gate별 다음 route 계산 및 `router.replace(destination)`

## 3. Route Graph

```text
/
  -> /splash

/splash
  -> /welcome
  -> /onboarding
  -> /chat

/chat
  -> /(tabs)/chat
  -> ChatScreen
     -> ChatSurface
     -> embedded-result message
        -> EmbeddedResultCard
        -> RenderFortuneResult
        -> fortune-results registry

/(tabs)
  -> chat
  -> profile

/home
  -> /chat

/trend
  -> /chat

/fortune
  flag legacy/default          -> /chat
  flag redirect_to_haneul      -> /chat?character=haneul_oracle&fortuneType=...
  flag disabled                -> /+not-found

/result/[resultKind]
  -> isResultKind(resultKind)
  -> FortuneResultLayout
  -> RenderFortuneResult
  -> registry[resultKind]

/profile
  -> ProfileScreen
  -> /profile/edit
  -> /profile/notifications
  -> /profile/relationships
  -> /profile/saju-summary
  -> /profile/my-fortunes
     -> /result/[resultKind]?payload=...
  -> /widgets

/widgets
  -> WidgetsShowcaseScreen
  -> src/features/ios-widgets barrel
```

핵심 증거:

- `apps/mobile-rn/app/(tabs)/chat.tsx:1-4` `ChatScreen` route
- `apps/mobile-rn/app/chat.tsx:7-9` `/chat` alias가 `/(tabs)/chat`으로 redirect
- `apps/mobile-rn/app/home.tsx:4`, `apps/mobile-rn/app/trend.tsx:4` `/chat` redirect
- `apps/mobile-rn/app/fortune.tsx:73-99` feature flag별 `/chat` 또는 `+not-found`
- `apps/mobile-rn/app/result/[resultKind].tsx:6-9`, `:43-67` dynamic result route
- `apps/mobile-rn/src/screens/my-fortunes-screen.tsx:105-110` 저장된 embedded result가 `/result/${resultKind}` 재사용
- `apps/mobile-rn/app/widgets/index.tsx:20` widgets showcase route

## 4. Result Rendering Graph

```text
ChatScreen
  -> buildEmbeddedResultMessage(...)
  -> ChatShellMessage(kind='embedded-result')
  -> ChatSurface case 'embedded-result'
  -> EmbeddedResultCard
     -> resolveResultKindFromFortuneType(...)
     -> RenderFortuneResult(resultKind, payload)
        -> registry[resultKind]
           -> screens/ondo-batch.tsx 대부분의 Ondo*Result
           -> screens/palm-reading.tsx
           -> screens/poster-guide.tsx

/result/[resultKind]
  -> same RenderFortuneResult path
```

현재 registry가 직접 물고 있는 result screen:

- `screens/ondo-batch.tsx`: `traditional-saju`, `daily-calendar`, `mbti`, `blood-type`, `zodiac-animal`, `career`, `love`, `health`, `coaching`, `family`, `past-life`, `wish`, `personality-dna`, `wealth`, `talent`, `exercise`, `tarot`, `game-enhance`, `match-insight`, `ootd-evaluation`, `exam`, `compatibility`, `blind-date`, `avoid-people`, `ex-lover`, `yearly-encounter`, `decision`, `daily-review`, `face-reading`, `naming`, `birthstone`, `celebrity`, `pet-compatibility`, `lucky-items`, `moving`, `new-year`
- `screens/palm-reading.tsx`: `palm-reading`
- `screens/poster-guide.tsx`: `beauty-simulation`, `hair-style-guide`, `face-reading-guide`, `ootd-guide`, `blind-date-guide`, `past-life-guide`

핵심 증거:

- `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx:30`, `:58`, `:89`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:46`, `:564`, `:1035`
- `apps/mobile-rn/src/screens/chat-screen.tsx:179`, `:2028`, `:2317-2318`, `:4445-4457`
- `apps/mobile-rn/src/lib/chat-shell.ts:763-785`
- `apps/mobile-rn/src/features/fortune-results/registry.tsx:45-47`, `:79`, `:88-96`

## 5. Candidate 판정표

| 후보 | 판정 | 근거 | 정리 메모 |
|---|---|---|---|
| `apps/mobile-rn/babel.config.js` | `DO_NOT_DELETE_FALSE_POSITIVE` | `babel-preset-expo`, `react-native-reanimated/plugin`이 설정 파일 convention으로 소비됨. `apps/mobile-rn/babel.config.js:5-6` | import되지 않는 것이 정상. Expo/Babel 빌드 경로 보존. |
| `apps/mobile-rn/plugins/with-ios-prebuilt-react-native.js` | `DO_NOT_DELETE_FALSE_POSITIVE` | `apps/mobile-rn/app.config.js:336`에서 config plugin으로 직접 참조 | native prebuild 설정이므로 삭제 금지. |
| `apps/mobile-rn/scripts/local-ios.mjs` | `DO_NOT_DELETE_FALSE_POSITIVE` | `apps/mobile-rn/package.json:11-19`, root `package.json:45-54`, `CLAUDE.md:106-110` | 로컬 native doctor/prepare/build/run 경로. |
| `apps/mobile-rn/scripts/remote-metro.mjs` | `DO_NOT_DELETE_FALSE_POSITIVE` | `apps/mobile-rn/package.json:9`, root `package.json:44`, `docs/development/local-native-ios-testing.md:83` | remote native testing tunnel 경로. |
| `apps/mobile-rn/src/components/index.ts` | `NEEDS_FEATURE_VERIFICATION` | `rg` 결과가 self-comment와 CHANGELOG뿐. 런타임 import 없음. 파일 자체는 "Prefer import ... from '@/components'" 정책 주석 보유 | 현재 production reachable은 아님. 팀이 barrel import 정책을 유지할지 확인 후 삭제/보존 결정. |
| `src/features/fortune-results/fortune-menu-card.tsx` | `NEEDS_FEATURE_VERIFICATION` | 컴포넌트 import 없음. `chat-shell.ts`에는 `fortune-menu` 타입/빌더 흔적이 있으나 `ChatShellMessage` union에 포함되지 않고 현재 `view-all`은 `AllFortunesSheet`로 처리됨 | PR-A 메뉴 카드 의도와 현재 bottom sheet UX 중 어느 쪽이 SoT인지 확인 필요. |
| `src/features/fortune-results/manseryeok-card.tsx` | `SAFE_DELETE` | `ManseryeokCard`는 `screens/batch-a.tsx:9`에서만 import. `batch-a`는 registry 미연결 | `batch-a` 삭제와 같은 cleanup group에서 제거. 단독 삭제는 `batch-a`가 남아 있으면 typecheck 실패 가능. |
| `src/features/fortune-results/primitives.tsx` | `DO_NOT_DELETE_FALSE_POSITIVE` | `app/result/[resultKind].tsx:6`, `embedded-result-card.tsx:11-15`가 import. Extensionless import는 sibling file `primitives.tsx`로 해석되는 현재 live path | directory `primitives/index.ts`와 혼동 금지. 이 파일은 결과 라우트/채팅 fallback에 필요. |
| `src/features/fortune-results/primitives/index.ts` | `SAFE_DELETE` | 현재 live imports는 `primitives.tsx` 또는 `primitives/<file>` direct path. `rg "from .*fortune-results/primitives"`에서 index 소비 없음 | directory barrel만 삭제 후보. 개별 primitive 파일과 혼동 금지. |
| `src/features/fortune-results/primitives/story-chapter-timeline.tsx` | `SAFE_DELETE` | `screens/batch-c.tsx:21`, `:683`에서만 사용. `batch-c`는 registry 미연결 | `batch-c`와 같은 orphan chain으로 삭제. |
| `src/features/fortune-results/screens/batch-a.tsx` | `SAFE_DELETE` | export `ResultBatchA`는 있으나 registry가 import하지 않음. 현재 registry는 `screens/ondo-batch.tsx`만 import | `manseryeok-card`, `use-result-data` 의존 제거와 함께 검증. |
| `src/features/fortune-results/screens/batch-b.tsx` | `SAFE_DELETE` | export `ResultBatchB`, registry import 없음 | old batch chain. |
| `src/features/fortune-results/screens/batch-c.tsx` | `SAFE_DELETE` | export `ResultBatchC`, registry import 없음 | `story-chapter-timeline`도 이 chain에 포함. |
| `src/features/fortune-results/screens/batch-d.tsx` | `SAFE_DELETE` | export `ResultBatchD`, registry import 없음 | old batch chain. |
| `src/features/fortune-results/screens/batch-e.tsx` | `SAFE_DELETE` | export `ResultBatchE`, registry import 없음 | old batch chain. |
| `src/features/fortune-results/screens/birthstone.tsx` | `SAFE_DELETE` | old `BirthstoneResult` export만 존재. registry는 `OndoBirthstoneResult` from `ondo-batch` 사용 (`registry.tsx:88`) | `birthstone-data.ts`와 같은 orphan chain. |
| `src/features/fortune-results/screens/celebrity.tsx` | `SAFE_DELETE` | old `CelebrityResult` export만 존재. registry는 `OndoCelebrityResult` from `ondo-batch` 사용 (`registry.tsx:89`) | 상세형 old screen으로 보임. |
| `src/features/fortune-results/screens/face-reading.tsx` | `SAFE_DELETE` | old `FaceReadingResult` export만 존재. registry는 `OndoFaceReadingResult` from `ondo-batch` 사용 (`registry.tsx:79`) | `palm-reading.tsx`, `poster-guide.tsx`는 registry live이므로 함께 삭제 금지. |
| `src/features/fortune-results/screens/lucky-items.tsx` | `SAFE_DELETE` | old `LuckyItemsResult` export만 존재. registry는 `OndoLuckyItemsResult` from `ondo-batch` 사용 (`registry.tsx:91`) | old screen chain. |
| `src/features/fortune-results/screens/moving.tsx` | `SAFE_DELETE` | old `MovingResult` export만 존재. registry는 `OndoMovingResult` from `ondo-batch` 사용 (`registry.tsx:92`) | old screen chain. |
| `src/features/fortune-results/screens/naming.tsx` | `SAFE_DELETE` | old `NamingResult` export만 존재. registry는 `OndoNamingResult` from `ondo-batch` 사용 (`registry.tsx:87`) | old screen chain. |
| `src/features/fortune-results/screens/pet-compatibility.tsx` | `SAFE_DELETE` | old `PetCompatibilityResult` export만 존재. registry는 `OndoPetCompatibilityResult` from `ondo-batch` 사용 (`registry.tsx:90`) | old screen chain. |
| `src/features/fortune-results/use-result-data.ts` | `SAFE_DELETE` | imports only from orphan old screens/batch files. `ondo-batch.tsx` does not use it | Delete with old result screens, not before. |
| `src/features/haneul/haneul-quick-actions.tsx` | `NEEDS_FEATURE_VERIFICATION` | no import of `HaneulQuickActions`. `direct_chips_enabled` flag exists but default false; product-contract comments still mention quick-actions banner | Confirm whether quick actions banner is paused or abandoned. |
| `src/features/ios-widgets/types.ts` | `SAFE_DELETE` | no import path to `ios-widgets/types`; `ios-widgets/index.ts` already re-exports `WidgetDataBundle`, and primitives barrel exports `WidgetSize` types | Pure type barrel. Current route `/widgets` imports from `src/features/ios-widgets`, not `/types`. |
| `src/lib/birthstone-data.ts` | `SAFE_DELETE` | only old `screens/birthstone.tsx` imports `BIRTHSTONE_COMPATIBILITY/getBirthstone...`; current registry birthstone uses `OndoBirthstoneResult` from `ondo-batch` | Delete with old `birthstone.tsx`. |

## 6. 특별 주의: False Positive와 이름 충돌

- `fortune-results/primitives.tsx`와 `fortune-results/primitives/index.ts`는 이름이 비슷하지만 역할이 다르다.
  - `primitives.tsx`: 현재 live. `/result/[resultKind]`, `EmbeddedResultCard` fallback에서 사용.
  - `primitives/index.ts`: 현재 route graph에서는 미사용 directory barrel.
- `screens/face-reading.tsx`, `screens/birthstone.tsx` 등 old detailed screen과 `screens/ondo-batch.tsx`의 `OndoFaceReadingResult`, `OndoBirthstoneResult`를 혼동하면 안 된다.
  - 삭제 후보는 old individual screens.
  - 현재 registry live path는 `ondo-batch`.
- `palm-reading.tsx`, `poster-guide.tsx`는 삭제 후보로 보지 않는다. registry가 직접 import한다.

## 7. 실행한 증거 명령/Searches

문서/규칙 확인:

```bash
sed -n '1,260p' CLAUDE.md
sed -n '261,560p' CLAUDE.md
sed -n '1,260p' AGENTS.md
git status --short
```

Startup/route inventory:

```bash
find apps/mobile-rn -maxdepth 3 -type f \( -name 'package.json' -o -name 'app.json' -o -name 'app.config.*' -o -name 'index.*' -o -name 'App.*' -o -name '_layout.*' -o -name 'expo-router*' -o -name 'metro.config.*' -o -name 'babel.config.*' \) | sort
find apps/mobile-rn/app -type f \( -name '*.tsx' -o -name '*.ts' \) | sort | sed 's#apps/mobile-rn/app##'
rg -n '"main": "expo-router/entry"|"start:remote-native"|"native:prepare"|"native:build"|"ios:local"|"typecheck"' apps/mobile-rn/package.json package.json
rg -n "Stack.Screen name=|<Redirect href=|router\.replace\(destination\)|nextRoute|RenderFortuneResult|FortuneResultLayout|resultMetadataByKind|isResultKind|ChatScreen|WidgetsShowcaseScreen" apps/mobile-rn/app apps/mobile-rn/src/screens/splash-screen.tsx
```

Expo/config/script false positive 확인:

```bash
rg -n "babel-preset-expo|react-native-reanimated/plugin|plugins: \[|with-ios-prebuilt-react-native|expo-router|@bacons/apple-targets|llama\.rn" apps/mobile-rn/babel.config.js apps/mobile-rn/app.config.js
rg -n "with-ios-prebuilt-react-native|local-ios\.mjs|remote-metro\.mjs|babel\.config|react-native-reanimated/plugin|start:remote-native|native:prepare|native:build|rn:native|ios:local" apps/mobile-rn package.json apps/mobile-rn/package.json apps/mobile-rn/app.config.js CLAUDE.md docs scripts --glob '!node_modules/**'
```

Result route/registry 확인:

```bash
rg -n "from './screens/ondo-batch'|from './screens/palm-reading'|from './screens/poster-guide'|birthstone: OndoBirthstoneResult|celebrity: OndoCelebrityResult|'face-reading': OndoFaceReadingResult|'pet-compatibility': OndoPetCompatibilityResult|'lucky-items': OndoLuckyItemsResult|moving: OndoMovingResult|RenderFortuneResult" apps/mobile-rn/src/features/fortune-results/registry.tsx
rg -n 'buildEmbeddedResultMessage\(|buildEmbeddedResultMessageFromPayload\(|resolveResultKindFromFortuneType\(|RenderFortuneResult|EmbeddedResultCard|case '\''embedded-result'\''|/result/' apps/mobile-rn/src/lib/chat-shell.ts apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx apps/mobile-rn/src/features/chat-surface/chat-surface.tsx apps/mobile-rn/src/screens/chat-screen.tsx apps/mobile-rn/src/screens/my-fortunes-screen.tsx 'apps/mobile-rn/app/result/[resultKind].tsx'
rg -n "from '\./screens/(batch-a|batch-b|batch-c|batch-d|batch-e|birthstone|celebrity|face-reading|lucky-items|moving|naming|pet-compatibility)'|from \"\./screens/(batch-a|batch-b|batch-c|batch-d|batch-e|birthstone|celebrity|face-reading|lucky-items|moving|naming|pet-compatibility)\"|Batch[A-E]|BirthstoneResult|CelebrityResult|FaceReadingResult|LuckyItemsResult|MovingResult|NamingResult|PetCompatibilityResult" apps/mobile-rn/app apps/mobile-rn/src --glob '!**/*.test.*'
```

Candidate별 역참조 확인:

```bash
rg -n "fortune-menu-card|FortuneMenuCard|fortune-menu|ManseryeokCard|manseryeok-card|useResultData|use-result-data|HaneulQuickActions|haneul-quick-actions|birthstone-data|birthstoneData|BIRTHSTONE" apps/mobile-rn/app apps/mobile-rn/src --glob '!**/*.test.*'
rg -n "primitives/index|from ['\"]\.\./primitives['\"]|from ['\"]\.\./\.\./features/fortune-results/primitives['\"]|from ['\"]\.\./fortune-results/primitives['\"]|from ['\"].*fortune-results/primitives['\"]|story-chapter-timeline|StoryChapterTimeline|AnnualCycleTimeline|MonthlyCycleTimeline|LuckCycleTimeline" apps/mobile-rn/app apps/mobile-rn/src --glob '!**/*.test.*'
rg -n "ios-widgets/types|WidgetData|WidgetKind|WidgetSize|FortuneWidget|LiveActivity|widget-data-live|widget-data-mock|from ['\"].*ios-widgets['\"]" apps/mobile-rn/app apps/mobile-rn/src apps/mobile-rn/targets --glob '!**/*.test.*'
rg -n "HaneulQuickActions|haneul-quick-actions|direct_chips|quick actions|quickActions|quick-actions" apps/mobile-rn/app apps/mobile-rn/src packages --glob '!**/*.test.*'
rg -n "from ['\"](.*components|@/components|\.\./components|\.\./\.\./components)['\"]|from ['\"].*src/components['\"]|components/index|@/components\b" apps/mobile-rn/app apps/mobile-rn/src apps/mobile-rn --glob '!node_modules/**'
```

## 8. Cleanup Loop 권고

1. false positive를 먼저 knip config에 명시한다.
   - `babel.config.js`, Expo config plugin, native scripts는 deletion candidate에서 제외한다.
   - 이유: 이 파일들은 import graph가 아니라 Expo/Babel/package script convention으로 소비된다.
2. `SAFE_DELETE`는 한 파일씩 무작위 삭제하지 말고 orphan chain 단위로 처리한다.
   - Group A: old result screens `batch-a`~`batch-e`, individual old screens, `use-result-data`, `manseryeok-card`, `birthstone-data`, `story-chapter-timeline`, `primitives/index.ts`
   - Group B: pure unused barrels `ios-widgets/types.ts`
3. `NEEDS_FEATURE_VERIFICATION`은 삭제 전에 제품 의도를 확인한다.
   - `components/index.ts`: canonical barrel 정책 유지 여부
   - `fortune-menu-card.tsx`: menu card UX가 `AllFortunesSheet`로 완전히 대체됐는지
   - `haneul-quick-actions.tsx`: `direct_chips_enabled`/quick-actions banner가 폐기됐는지
4. 삭제 loop마다 아래 순서로 검증한다.

```bash
pnpm run source-inventory:check
pnpm --filter @fortune/mobile-rn exec tsc --noEmit
pnpm --filter @fortune/mobile-rn exec knip --workspace apps/mobile-rn --production
```

5. jscpd cleanup은 reachability 삭제 후에 한다.
   - old fortune-results screens의 clone group은 삭제로 사라질 가능성이 크다.
   - `chat-screen` clone은 기능 흐름이 살아 있으므로 dead-code cleanup이 아니라 별도 refactor 설계가 필요하다.
   - widget data sync/live clone은 RN showcase data와 native App Group sync의 schema 차이를 확인한 뒤 공통 derive helper로 좁히는 편이 안전하다.
   - Supabase Edge boilerplate clone은 함수별 auth/CORS/error wrapper가 동일한지 확인한 뒤 `_shared` helper로 승격하는 별도 loop가 맞다.

## 9. 결론

이번 knip 결과는 세 종류가 섞여 있다.

- 설정/스크립트 계층 false positive: 삭제 금지.
- registry 교체 이후 남은 old result screen chain: 현재 route graph 기준 삭제 가능.
- 제품 의도 흔적이 남은 미연결 UI/API surface: 기능 확인 후 삭제 여부 결정.

가장 안전한 첫 cleanup loop는 false positive ignore 등록과 old result screen orphan chain 제거다. 이 순서가 jscpd 중복 수를 가장 크게 줄이고, 살아있는 `ChatScreen -> EmbeddedResultCard -> registry -> ondo-batch` 경로를 건드리지 않는다.
