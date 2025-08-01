# Flutter 문법 에러 수정 전략 (v2)

## 현재 상황
- Git pull 완료: 11개 파일 업데이트됨
- Flutter analyzer 충돌 발생 (Internal error)
- 이전 분석 기준: 30개 파일에 총 1,851개 에러

## 프롬프트 전략 (미니 배치 접근법)

### 1단계: 저에러 파일 (5-10개 에러)
**파일 개수**: 14개 파일
- `codex_mini_batch_1.md`: 5개 파일 (2-7 에러, 총 30개)
- `codex_mini_batch_2.md`: 5개 파일 (9-19 에러, 총 63개) 
- `codex_mini_batch_3.md`: 4개 파일 (27-36 에러, 총 128개)

### 2단계: 고에러 파일 개별 처리  
**파일 개수**: 11개 파일 (각 100+ 에러)
- `codex_single_1.md`: ex_lover_fortune_result_page.dart (108 errors)
- `codex_single_2.md`: family_fortune_unified_page.dart (135 errors)
- `codex_single_3.md`: tarot_fortune_list_card.dart (172 errors)
- `codex_single_4.md`: tarot_storytelling_page.dart (178 errors)
- `codex_single_5.md`: investment_fortune_unified_page.dart (183 errors)
- `codex_single_6.md`: talisman_enhanced_page.dart (223 errors)
- `codex_single_7.md`: ex_lover_fortune_enhanced_page.dart (227 errors)
- `codex_single_8.md`: physiognomy_result_page.dart (777 errors)
- `codex_single_9.md`: physiognomy_enhanced_page.dart (업데이트됨)
- `codex_single_10.md`: profile_screen.dart (업데이트됨)
- `codex_single_11.md`: 기타 고에러 파일

## 프롬프트 특징
- 문법 에러만 수정하도록 명확히 지시
- 로직/기능 변경 금지 강조
- 주요 에러 패턴 명시 (세미콜론, 괄호, 콤마 등)
- 파일별 에러 개수 표시

## 실행 순서
1. 미니 배치 1 (가장 적은 에러)
2. 미니 배치 2 
3. 미니 배치 3
4. 개별 파일들 (에러가 많은 순서대로)

## 예상 효과
- AI가 한 번에 처리할 수 있는 적절한 양
- 각 배치별로 명확한 범위
- 점진적인 에러 감소 추적 가능