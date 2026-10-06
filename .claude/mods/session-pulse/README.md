# session-pulse

Claude Code mod. 최근 세션 29개(2026-09-15 ~ 10-04)에서 반복된 상황을 기준으로 만들었습니다.

- 프롬프트 위 띠: 이 세션에서 실행된 단계(session-start → 테스트/local CI → push → PR → merge-run → attest → session-close)를 성공 ✓ / 실패 ✗ / 잠금·대기 ⏸ / 실행 중 … 로 표시하고, PR 번호와 턴 경과 시간을 함께 보여 줍니다.
- `/pulse`: 같은 요약을 턴 없이 바로 출력합니다. 턴이 돌고 있을 때도 됩니다. `/pulse hide`, `/pulse show`, `/pulse reset`.
- "다한거야?", "진행상황 알려줘", "얼마나남은거야" 같은 40자 이하 질문을 보내면 단계 기록을 토스트로 먼저 보여 주고, 같은 기록을 Claude에게 숨은 context로 붙입니다.
- "fable 낮음으로 이어서", "Opus5 xhigh로 이어서하자", "오퍼스써" 같은 40자 이하 전환 문구는 모델에 보내지 않고 `/model`, `/effort`를 실행한 뒤 "이어서 진행해"를 보냅니다.

단계 판정은 Bash 명령 문자열 기준입니다 (`hooks/pulse.ts`의 `RULES`).

## 설치

```
claude --plugin-dir /path/to/fortune/.claude/mods/session-pulse
```

main에 머지된 뒤에는:

```
/plugin install session-pulse --marketplace injooinjoo/fortune
```

## 검증

```
claude plugin validate .claude/mods/session-pulse
claude plugin test .claude/mods/session-pulse
```
