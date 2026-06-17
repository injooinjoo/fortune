# Codex cleanup safety review

Date: 2026-06-16

## Verdict

**조건부 승인.** 현재 워킹트리 기준으로 지정된 cleanup 삭제 파일들은 live route/import graph에서 더 이상 참조되지 않으며, `react-native-keyboard-controller` 제거도 JS/native/config/lock 관점에서 남은 참조가 확인되지 않았다. `pnpm --dir apps/mobile-rn typecheck`도 통과했다.

## Evidence

- Result route는 `apps/mobile-rn/app/result/[resultKind].tsx` -> `RenderFortuneResult` -> `apps/mobile-rn/src/features/fortune-results/registry.tsx` 경로를 사용한다.
- `registry.tsx`는 삭제 대상인 legacy `screens/batch-*`, `screens/birthstone.tsx`, `screens/celebrity.tsx`, `screens/face-reading.tsx`, `screens/lucky-items.tsx`, `screens/moving.tsx`, `screens/naming.tsx`, `screens/pet-compatibility.tsx` 대신 `./screens/ondo-batch`의 `Ondo*Result` 컴포넌트를 참조한다.
- 현재 워킹트리에서 삭제 대상 경로/심볼 검색 결과, 외부 live import는 발견되지 않았다.
- `src/components/index.ts` 삭제는 현재 코드가 `../../src/components/app-text`, `../components/card`처럼 직접 파일 import를 사용하므로 typecheck 기준 안전하다.
- `apps/mobile-rn/src/features/fortune-results/primitives/index.ts` 삭제 후에도 `fortune-results/primitives` import는 남아 있는 `primitives.tsx`로 해석되며 typecheck가 통과했다.
- `react-native-keyboard-controller`, `KeyboardProvider`, `KeyboardController`, `KeyboardAwareScrollView` 등 관련 문자열은 `apps/mobile-rn` 및 lock/package 검색에서 남은 참조가 없었다.
- `pnpm --dir apps/mobile-rn why react-native-keyboard-controller`는 의존 경로를 출력하지 않았다.
- `pnpm --dir apps/mobile-rn typecheck` 통과.

## Risks

- 검증은 dirty 워킹트리의 현재 상태 기준이다. 지정 범위 밖 변경이 최종 PR에서 빠지거나 rebase 중 `registry.tsx`, `chat-screen.tsx`, `app/_layout.tsx`, `app/result/[resultKind].tsx`가 바뀌면 reachability를 다시 확인해야 한다.
- TypeScript는 native autolinking/pod 상태를 보장하지 않는다. `react-native-keyboard-controller`는 native 모듈이므로 실제 dev-client/native 빌드 또는 CI 빌드로 최종 확인이 필요하다.
- 삭제된 legacy 결과 화면과 `ondo-batch` 결과 화면의 시각/콘텐츠 parity는 이 리뷰 범위에서 검증하지 않았다. 본 리뷰는 import/route/dependency safety에 한정한다.

## Required follow-ups

- 최종 cleanup diff에서 `apps/mobile-rn/package.json`, `pnpm-lock.yaml`, `open-source-licenses.tsx`의 `react-native-keyboard-controller` 제거를 같은 변경 단위로 유지한다.
- 최종 PR/커밋 전 `pnpm --dir apps/mobile-rn typecheck`를 다시 실행한다.
- dependency 제거 후 iOS/Android native build 또는 해당 GitHub Actions/EAS build를 한 번 통과시킨다.
- 최종 diff에 지정 범위 밖 dirty 변경이 섞이면, 그 변경은 별도 리뷰 대상으로 분리한다.
