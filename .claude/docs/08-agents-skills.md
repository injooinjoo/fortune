# Agents & Skills 레퍼런스

> 최종 업데이트: 2026.04.06

Ondo 저장소의 현재 Agent/Skill 구성을 repo truth 기준으로 정리한 문서입니다. 예전 다수 에이전트 체계보다, 현재 남아 있는 Generator-Evaluator 중심 구성을 기준으로 설명합니다.

## 통계

| 항목 | 수치 |
|------|------|
| Agents | 5개 |
| 참조 문서 | 1개 (`fortune-specialist-reference.md`) |
| Core Skills | 4개 |
| Template Skills | 4개 |
| Utility Skills | 5개 |

## 현재 워크플로우

```text
[Planner]
  └─ contract.md 작성
       ↓
[Generator Agent]
  └─ 구현 + build-log/discovery/rca 작성
       ↓
[Evaluator Agent]
  └─ PASS/FAIL 판정 + eval-report 작성
       ↓
[Planner]
  └─ 재시도 또는 ship
```

### 핵심 원칙

1. Generator와 Evaluator는 fresh context를 사용합니다.
2. 통신은 `artifacts/sprint/current/`의 파일로 수행합니다.
3. Evaluator는 default-fail 원칙을 유지합니다.
4. Hard Block(RCA/Discovery/Verify)은 sprint contract 흐름 안에 흡수됩니다.

## Active Agents

| Agent | 파일 | 역할 |
|-------|------|------|
| Generator | `.claude/agents/generator.md` | contract 기반 구현 |
| Evaluator | `.claude/agents/evaluator.md` | 독립 평가 및 증거 수집 |
| Playwright QA | `.claude/agents/playwright-qa-agent.md` | E2E/브라우저 검증 |
| Character Curator | `.claude/agents/character-curator.md` | 임포트 캐릭터 품질 검수 |
| Character Importer | `.claude/agents/character-importer.md` | 외부 캐릭터 데이터 변환/적재 |

## Supporting Reference

| 문서 | 역할 |
|------|------|
| `.claude/docs/fortune-specialist-reference.md` | 운세 도메인 보조 지식 |

## Active Skills

### Core Skills

| Skill | 위치 | 역할 |
|-------|------|------|
| `sprint` | `.claude/skills/sprint/` | Planner 오케스트레이션 |
| `generate` | `.claude/skills/generate/` | Generator 실행 진입점 |
| `evaluate` | `.claude/skills/evaluate/` | Evaluator 실행 진입점 |
| `quick-fix` | `.claude/skills/quick-fix/` | 경량 수정 워크플로우 |

### Template Skills

| Skill | 위치 | 역할 |
|-------|------|------|
| `feature-fortune` | `.claude/skills/feature-fortune/` | 운세 기능 템플릿 |
| `feature-chat` | `.claude/skills/feature-chat/` | 채팅 기능 가이드 |
| `feature-ui` | `.claude/skills/feature-ui/` | presentation 범위 UI 작업 |
| `backend-service` | `.claude/skills/backend-service/` | Edge Function/서비스 작업 |

### Utility Skills

| Skill | 위치 | 역할 |
|-------|------|------|
| `quality-check` | `.claude/skills/quality-check/` | 품질 규칙, 검증 명령 |
| `design-to-flutter` | `.claude/skills/design-to-flutter/` | 디자인 → Flutter 변환 |
| `generate-character-prompt` | `.claude/skills/generate-character-prompt/` | 캐릭터 프롬프트 생성 |
| `test-character-chat` | `.claude/skills/test-character-chat/` | 캐릭터 채팅 검증 |
| `import-characters` | `.claude/skills/import-characters/` | 캐릭터 일괄 임포트 |

## Artifact 통신 규약

```text
artifacts/sprint/
  current/
    contract.md
    discovery-report.md   # 필요 시
    rca-report.md         # 필요 시
    build-log.md
    eval-report.md
    eval-history/
```

### 책임 분리

- Planner: 범위, contract, Jira, ship
- Generator: 구현, discovery/rca 수행
- Evaluator: 증거 기반 판정
- QA Agent: UI/E2E 검증이 필요한 경우만 추가

## 아카이브 기준

현재 문서 기준 활성 대상이 아닌 에이전트/스킬은 `_archive/`에 둡니다.

- archived example: `quality-guardian.md`
- archived skill lineage: `enforce-discovery`, `enforce-rca`, `enforce-verify`, `troubleshoot`

이들은 역사적 참고용이며, 현재 운용 기준은 본 문서의 5 agent / 13 skill 분류입니다.
