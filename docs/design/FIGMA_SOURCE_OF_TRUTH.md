# Fortune Figma Source Of Truth

## 공식 파일

- 공식 Figma 파일명: `Fortune Design Source of Truth`
- Figma file key: `xKO8asAUg2g9fqpQQ9PZwb`
- 직접 링크: [Fortune Design Source of Truth](https://www.figma.com/file/xKO8asAUg2g9fqpQQ9PZwb/Fortune-Design-Source-of-Truth?type=design&node-id=1-2&mode=design)

이 문서가 가리키는 위 파일만 Fortune 앱의 공식 디자인 소스 오브 트루스다.  
임시 캡처 파일, 탐색용 파일, 과거 초안 파일은 참고 자료일 수는 있어도 공식 관리 파일로 간주하지 않는다.

## 목적

- 모든 화면 레이아웃, 레이아웃 셸, 공용 컴포넌트 관리를 한 파일에 집중한다.
- 라우트 변경과 UI 변경이 디자인 파일과 저장소 문서에 동시에 반영되도록 강제한다.
- 산발적인 Figma 파일 생성 관행을 중단하고, 운영 기준을 문서와 파일 구조로 고정한다.

## 파일 구조

- `00 Foundation`
  - 파일 정체성, 운영 규칙, verified home states
- `10 Screen Registry`
  - 라우트 패밀리 기준 화면 인벤토리
- `20 Layout Shells`
  - 앱 셸, 홈 셸, 온보딩 셸, 섹션 셸 인벤토리
- `30 Components`
  - 디자인 시스템 primitives, heritage components, shared product components
- `40 States`
  - 핵심 전후 상태, 빈 상태, 에러 상태, 퍼널 상태
- `90 Archive`
  - 폐기되었지만 이력 보존이 필요한 탐색안

## 운영 규칙

1. 공식 파일은 하나만 유지한다.
2. 새 화면이나 새 컴포넌트를 만들 때 별도 Figma 파일을 정식 산출물로 만들지 않는다.
3. 화면 관리는 라우트 기준으로, 레이아웃 관리는 셸 기준으로, 컴포넌트 관리는 소스 파일 기준으로 정리한다.
4. `lib/routes/route_config.dart` 또는 nested route 파일이 바뀌면 `10 Screen Registry`와 저장소 문서를 같은 작업에서 같이 갱신한다.
5. `lib/shared/layouts/`, `lib/features/**/pages/`, `lib/core/design_system/components/`, `lib/shared/components/`가 바뀌면 관련 registry 페이지와 저장소 문서를 같은 작업에서 같이 갱신한다.
6. Flutter Web canvas 기반 화면은 raw HTML-to-design 변환을 신뢰하지 않는다. 공식 등록은 브라우저 검증 후 screenshot-backed capture를 사용한다.
7. 기존 초안이나 탐색안은 공식 영역과 분리해서 archive로 취급한다.

## 현재 시드 페이지

- `00 Foundation`
  - 운영 규칙, 파일 구조, `/chat` verified states
- `10 Screen Registry`
  - route-backed screen family 정리
- `20 Layout Shells`
  - MainShell, SwipeHomeShell, onboarding, section shell 정리
- `30 Components`
  - DS primitives, heritage components, shared components, token families 정리

## 변경 워크플로우

### 새 라우트나 새 페이지 추가

1. 라우트 파일과 페이지 파일을 기준으로 실제 surface를 확인한다.
2. 공식 Figma 파일의 `10 Screen Registry`에 route family와 surface를 추가한다.
3. 필요하면 `20 Layout Shells`에 연결된 셸도 추가한다.
4. 이 문서와 [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md)를 같은 변경에 포함한다.

### 레이아웃 구조 변경

1. 변경이 screen-level인지 shell-level인지 먼저 구분한다.
2. 공통 구조 변경이면 개별 화면보다 `20 Layout Shells`를 먼저 갱신한다.
3. 영향 받는 verified state가 있으면 `40 States`도 함께 업데이트한다.

### 컴포넌트 변경

1. 디자인 시스템 primitive인지 shared product component인지 분류한다.
2. `30 Components`에서 소스 파일 매핑을 유지한다.
3. legacy 또는 themed component라도 실제 코드에 남아 있으면 registry에서 지우지 않는다.

## 소스 기준

- Router source: `lib/routes/route_config.dart`
- Nested routes: `lib/routes/routes/*.dart`, `lib/routes/character_routes.dart`
- Layout source: `lib/shared/layouts/main_shell.dart`
- Screen source: `lib/features/**/presentation/pages/*.dart`, `lib/screens/**/*.dart`
- Component source:
  - `lib/core/design_system/components/`
  - `lib/shared/components/`

## 문서 동기화 원칙

공식 Figma 파일 변경과 저장소 문서 변경은 분리하지 않는다.  
정식 관리 대상에 변화가 생기면 최소 아래 문서가 같이 검토되어야 한다.

- [README.md](./README.md)
- [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md)
- [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md)
- 필요 시 [../figma-style-guide.md](../figma-style-guide.md)
