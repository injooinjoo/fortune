# P10 / B5 — fortune-health 의료 조언 리스크 제거

## 문제 (5.1.2 리젝 위험)
`supabase/functions/fortune-health/index.ts`가 Apple Health 데이터 중 **의료 Vitals**(혈압, 혈당, SpO₂, 심박수)를 LLM 프롬프트 컨텍스트(521-528줄)에 주입하고 지시형 처방(식단/운동 강도·시간)을 출력. Apple은 AI가 사용자 실측 vitals를 해석해 조언하는 앱을 의료 앱 범주로 간주하여 상습 리젝.

## 수용 기준
1. **LLM 프롬프트에서 의료 vitals 제거**: 제거 대상
   - `average_heart_rate`, `resting_heart_rate` (심박)
   - `systolic_bp`, `diastolic_bp` (혈압)
   - `blood_glucose` (혈당)
   - `blood_oxygen` (SpO₂)
2. **Wellness/fitness 데이터는 유지**: 걸음, 수면 시간, 체중, 운동 횟수, 소모 칼로리 (Apple이 fitness 앱에 허용하는 범위)
3. **클라이언트 반환 payload에서도 동일 필드 제거**: `healthAppDataSummary`에서 `heartRate` 삭제
4. **지시형 문구 완화 (JSON 스키마 label)**: "증상 원인 / 관리법 / 예방법" → "컨디션 체크 / 생활 루틴 / 오늘의 팁"
5. **응답에 disclaimer 필드 추가**: "본 조언은 참고·오락 목적입니다. 의학적 진단·치료가 아니며 증상이 지속되면 전문의와 상담하세요."
6. Premium 티어가 vitals 기반 가치 제안이라면 Apple 심사 통과 후 별도 의료 디바이스 인증 경로 필요. 이 phase에서는 vitals-free 상태로 Premium 유지 (Premium 여전히 걸음/수면/체중 기반 personalization 제공)

## 비수용 기준
- hero-health.tsx UI 변경 금지 (별도 phase로 disclaimer frame)
- 결과 카드 전체에 적용되는 disclaimer UI는 별도 (P11 다음 별도)
- Apple Health 데이터 수집 API 권한 제거 금지 (fitness만 유지)
- JSON schema 자체의 key/구조 변경 금지 (client breakage 방지) — label만 소프트닝

## Quality Gate
- [ ] Reviewer PASS (5.1.2 risk evaluation)
- [ ] 응답 schema는 client에서 optional 필드로 소비 — 추가 `disclaimer` 필드 안전
- [ ] vitals 필드 완전 제거 확인 (grep 없음)

## RCA
- WHY: Premium 차별화 포인트로 Apple Health vitals 연동 도입. 의료 앱 규정 검토 누락.
- WHERE: `fortune-health/index.ts:517-534`, `850-856`, JSON schema 569.
- HOW: Fitness tracking 범위로 제한 + disclaimer로 의료 조언 경계 명시.
