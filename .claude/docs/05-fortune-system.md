# 인사이트 시스템 가이드

> 최종 업데이트: 2026.04.06

Ondo의 운세/인사이트 시스템은 사용자 노출 surface, 카테고리 로딩, 결과 스키마, 비용 정책을 한 묶음으로 다뤄야 합니다. 이 문서는 현재 repo 기준 bucket과 런타임 흐름을 고정합니다.

## 시스템 통계

| 항목 | 수치 |
|------|------|
| Fortune Edge Functions | 44개 |
| Utility Functions | 28개 |
| Total Functions | 72개 (`_shared` 제외) |
| 카테고리 로딩 | Firebase Remote Config + fallback defaults |

### Fortune bucket 기준

- `fortune-*` 접두사 함수 43개
- `personality-dna` 1개
- 합계 44개

`personality-dna`는 접두사는 다르지만 사용자에게 노출되는 성격/운세 분석 surface이고, `FortuneCategory`에도 직접 연결되므로 본 문서와 [25-fortune-result-schemas.md](25-fortune-result-schemas.md)에서는 운세 bucket으로 포함합니다.

## 카테고리 소스 오브 트루스

운세 카테고리는 하드코딩 목록이 아니라 Remote Config 우선 구조입니다.

| 항목 | 기준 |
|------|------|
| 서비스 | `lib/services/remote_config_service.dart` |
| 키 | `fortune_categories_v1` |
| 버전 키 | `fortune_categories_version` |
| fallback | `FortuneCategory.defaults` |
| 엔티티 | `lib/features/fortune/domain/entities/fortune_category.dart` |

### 로딩 규칙

1. 앱 부팅 후 `RemoteConfigService.initialize()` 수행
2. `fortune_categories_v1` JSON 파싱 시도
3. 파싱 성공 시 Remote Config 카테고리 사용
4. 실패 또는 빈 값이면 `FortuneCategory.defaults` 사용

## 운세 실행 흐름

현재 인사이트 조회는 아래 흐름을 기본으로 봅니다.

```text
사용자 입력/설문
    ↓
1. 사용자별 당일 캐시 확인
    ↓
2. cohort/db pool 확인
    ↓
3. 조건 충족 시 기존 결과 재사용 또는 랜덤 선택
    ↓
4. 필요 시 Edge Function / LLM 호출
    ↓
5. 결과 저장 + 결과 surface 또는 채팅 surface로 변환
```

### 핵심 관찰 포인트

- 같은 function이라도 입력 구조는 운세 타입마다 다릅니다.
- 결과 surface는 단일 카드가 아니라 `chat`, `shared fortune cards`, `fortune_bodies` 계층으로 재조립됩니다.
- 상세 응답 스키마는 [25-fortune-result-schemas.md](25-fortune-result-schemas.md)를 기준으로 봅니다.

## 입력 패밀리

운세 함수 입력은 대략 아래 패밀리로 묶입니다.

| 패밀리 | 예시 함수 | 대표 입력 |
|--------|-----------|-----------|
| 시간/일상 | `fortune-daily`, `fortune-time`, `fortune-biorhythm` | 사용자 프로필, 날짜/기간 |
| 관계 | `fortune-love`, `fortune-compatibility`, `fortune-blind-date` | 본인/상대 정보, 관계 상태, 채팅/사진 |
| 전통 분석 | `fortune-traditional-saju`, `fortune-tarot`, `fortune-dream`, `fortune-face-reading` | 생년월일시, 질문, 카드, 이미지, 자유 텍스트 |
| 재물/경력 | `fortune-wealth`, `fortune-investment`, `fortune-career`, `fortune-exam` | 직군, 자산/시험 종류, 목표, 시점 |
| 건강/라이프스타일 | `fortune-health`, `fortune-health-document`, `fortune-exercise`, `fortune-ootd` | 컨디션, 문서/이미지, 생활 패턴 |
| 가족/주거 | `fortune-family-*`, `fortune-naming`, `fortune-moving`, `fortune-home-fengshui` | 가족 구성원, 주거 정보, 예정일 |
| 성격/프로필 | `fortune-mbti`, `fortune-blood-type`, `fortune-constellation`, `fortune-zodiac-animal`, `personality-dna` | MBTI, 혈액형, 별자리, 띠 |

## 결과 스키마 원칙

문서상 모든 운세 응답은 아래 envelope로 해석합니다.

```typescript
type FortuneEnvelope<T> = {
  success: true;
  data: T;
  error?: string;
};
```

실제 payload는 함수별로 다르지만, 문서 기준 공통 필드는 아래를 반복적으로 사용합니다.

- `fortuneType`
- `score`
- `content`
- `summary`
- `advice`
- `timestamp`

## Utility bucket

본문에서 제외하는 utility 28개는 아래 계열입니다.

- 인증: `kakao-oauth`, `naver-oauth`
- 캐릭터/채팅: `character-*`, `chat-conversation-save`, `free-chat`
- 결제/구독/토큰: `payment-verify-purchase`, `subscription-*`, `soul-*`, `token-balance`
- 보조 데이터/캐시: `fetch-tickers`, `sports-schedule`, `widget-cache`, `monitor-llm-usage`
- 부가 생성/보상: `generate-*`, `profile-completion-bonus`, `analyze-wish`

## 관련 문서

- [02-architecture.md](02-architecture.md)
- [18-chat-first-architecture.md](18-chat-first-architecture.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
- [25-fortune-result-schemas.md](25-fortune-result-schemas.md)
