# DESIGN.md Workflow

## 목적

`DESIGN.md` 는 AI 에이전트가 읽는 디자인 계약입니다. 이 저장소에서는 Paper와 Flutter design system이 실제 source of truth이고, 루트 `DESIGN.md` 는 그 기준을 에이전트가 바로 소비할 수 있게 평탄화한 문서입니다.

정리하면 역할은 아래와 같습니다.

- `paper/README.md`, `docs/design/PAPER_*`: 공식 디자인 운영 기준
- `lib/core/design_system/`: 실제 런타임 토큰과 컴포넌트
- `DESIGN.md`: 에이전트 친화적인 요약 디자인 계약

## 외부 소스

이번 `DESIGN.md` 세팅은 아래 리포의 사용 방식을 따릅니다.

- Source repo: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
- Chosen inspiration: `design-md/linear.app/DESIGN.md`

선정 이유:
- 현재 Fortune 토큰이 다크 네이비/차콜 베이스 + 보라 CTA 구조를 사용합니다.
- `linear.app` 컬렉션이 이 구조와 가장 가깝습니다.
- 다만 Fortune은 한국어 중심, 채팅 중심, 운세 콘텐츠라는 점이 달라서 루트 `DESIGN.md` 는 직접 맞춤화했습니다.

## 운영 규칙

1. Paper와 Flutter runtime이 바뀌면 `DESIGN.md` 도 같이 검토합니다.
2. 외부 컬렉션의 내용을 그대로 재복사하지 않습니다.
3. `DESIGN.md` 는 영감 문서가 아니라 현재 프로젝트의 agent-facing contract여야 합니다.
4. `DESIGN.md` 와 Paper가 충돌하면 Paper와 실제 코드가 우선합니다.

## 언제 갱신하나

아래 중 하나가 바뀌면 갱신 후보입니다.

- 핵심 색상 체계
- 타이포그래피 계층
- 버튼, 카드, 입력 필드, 채팅 버블 스타일 규칙
- 모바일 우선 레이아웃 원칙
- 앱의 전반적 미감 방향

## 갱신 체크리스트

1. `paper/README.md` 와 `docs/design/PAPER_*` 를 확인합니다.
2. `lib/core/design_system/tokens/` 와 `lib/core/theme/` 를 확인합니다.
3. 루트 `DESIGN.md` 의 9개 섹션을 현재 상태에 맞게 수정합니다.
4. `docs/design/PAPER_SYNC_CHANGELOG.md` 에 기록합니다.
5. 관련 문서 링크가 바뀌면 `README.md`, `docs/design/README.md` 를 같이 갱신합니다.

## 에이전트 사용 예시

- "Use `DESIGN.md` and build a new premium paywall screen."
- "Match the Fortune `DESIGN.md`, but keep the existing Paper route structure."
- "Use the project `DESIGN.md` instead of inventing a new visual direction."
