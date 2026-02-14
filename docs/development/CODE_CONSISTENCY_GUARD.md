# Code Consistency Guard

`scripts/check_code_consistency.sh`는 레포 전역의 통일성 규칙을 정량 관리하는 회귀 방지 가드입니다.

## 목적

1. 기존 레거시를 한 번에 깨지 않고, 새 불일치 유입을 차단합니다.
2. 규칙 위반을 "감"이 아닌 숫자 기반으로 관리합니다.
3. 점진적으로 베이스라인을 낮추는 개선 루프를 만듭니다.

## 체크 항목

1. 토큰/테마 레이어 외 `Color(0x...)` 직접 사용
2. `Colors.white/black` 직접 사용
3. 테마/타이포 레이어 외 `fontSize:` 직접 사용
4. `Icons.arrow_back` 사용 (`Icons.arrow_back_ios` 권장)
5. `print()` 사용
6. `@riverpod` 어노테이션 사용
7. `presentation -> data` 직접 import
8. 빈 `catch` 블록

## 실행 방법

```bash
# 기본: 베이스라인 대비 회귀만 실패
./scripts/check_code_consistency.sh

# 샘플 매치 포함 출력
./scripts/check_code_consistency.sh --show-matches

# 엄격 모드: 0이 아닌 항목이 있으면 실패
./scripts/check_code_consistency.sh --strict
```

## 베이스라인 운영

기본 베이스라인 파일은 `scripts/code_consistency_baseline.env` 입니다.

```bash
# 현재 수치로 베이스라인 갱신
./scripts/check_code_consistency.sh --update-baseline
```

베이스라인 갱신은 아래 경우에만 수행합니다.

1. 대규모 리팩터로 기존 위반 수치가 실제로 감소했을 때
2. 합의된 예외 규칙이 추가되었을 때

## 테스트 스크립트 연동

`run_all_tests.sh`에서 통일성 가드를 같이 돌릴 수 있습니다.

```bash
./scripts/run_all_tests.sh --consistency
./scripts/run_all_tests.sh --ci
```

## 권장 운영 루프

1. PR 전 `./scripts/check_code_consistency.sh` 실행
2. 회귀 0 유지
3. 개선 PR에서 위반 수치 감소
4. 감소분 확인 후 베이스라인 갱신
