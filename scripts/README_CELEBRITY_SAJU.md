# 유명인 사주팔자 데이터 수집 가이드

## 개요
유명인의 생년월일 정보를 수집하고 사주팔자를 계산하여 데이터베이스에 저장하는 1회성 스크립트입니다.

## 파일 구조
```
scripts/
├── celebrity-data.json          # 유명인 정보 (본명, 생년월일, 출생지)
├── insert-celebrity-saju.sql    # SQL 직접 실행 파일
└── README_CELEBRITY_SAJU.md      # 이 파일

supabase/functions/calculate-celebrity-saju/
├── index.ts                     # Edge Function 메인 파일
├── saju-calculator.ts           # 사주 계산 로직
└── celebrity-data.json         # 데이터 파일 복사본
```

## 실행 방법

### 방법 1: SQL 직접 실행 (권장)
1. Supabase Dashboard 접속
2. SQL Editor 열기
3. `scripts/insert-celebrity-saju.sql` 내용 복사
4. SQL Editor에 붙여넣고 실행

### 방법 2: Edge Function 실행
```bash
# 로컬에서 테스트
supabase functions serve calculate-celebrity-saju

# 배포
supabase functions deploy calculate-celebrity-saju

# 실행
supabase functions invoke calculate-celebrity-saju
```

## 데이터 형식

### celebrity-data.json
```json
{
  "celebrities": [
    {
      "name": "활동명",
      "real_name": "본명",
      "birth_date": "YYYY-MM-DD",
      "birth_time": "HH:MM" or null,
      "birth_place": "출생지",
      "gender": "male/female",
      "category": "singer/actor/athlete/..."
    }
  ]
}
```

### 데이터베이스 스키마
```sql
celebrities 테이블:
- id: 고유 ID (name_birth_date)
- name: 활동명
- real_name: 본명
- birth_date: 생년월일
- birth_time: 생시 (옵션)
- birth_place: 출생지
- year_pillar: 년주 (예: 계유)
- month_pillar: 월주 (예: 정사)
- day_pillar: 일주 (예: 정해)
- hour_pillar: 시주 (옵션)
- saju_string: 전체 사주 (예: 계유 정사 정해 임오)
- wood_count: 목 개수
- fire_count: 화 개수
- earth_count: 토 개수
- metal_count: 금 개수
- water_count: 수 개수
- dominant_element: 지배 오행
- full_saju_data: 상세 사주 정보 (JSONB)
```

## 사주 계산 로직

### 년주 계산
- 입춘(2월 4일경) 기준으로 년도 구분
- 60갑자 순환 적용

### 월주 계산
- 24절기 기준 월 구분
- 년간에 따른 월간 계산

### 일주 계산
- 1900년 1월 1일 기준 일수 계산
- 60갑자 순환 적용

### 시주 계산
- 생시 정보가 있는 경우만 계산
- 2시간 단위 12시진 구분
- 일간에 따른 시간 계산

### 오행 분석
- 천간과 지지의 오행 집계
- 지배 오행 결정

## 주의사항
1. 생시 정보는 정확히 알 수 없는 경우가 많으므로 NULL 처리
2. 음력 생일의 경우 양력 변환 필요
3. 1회성 데이터 수집용이므로 UI는 별도 구현 불필요

## 데이터 확인
```sql
-- 저장된 데이터 확인
SELECT 
    name,
    real_name,
    birth_date,
    saju_string,
    dominant_element
FROM celebrities
WHERE data_source = 'manual_calculated';
```