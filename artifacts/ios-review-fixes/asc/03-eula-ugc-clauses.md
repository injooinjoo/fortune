# EULA/이용약관 — UGC 조항 추가 문구

Apple 5.2.3: UGC가 있는 앱은 EULA에 (1) 금지 행위, (2) 24시간 테이크다운, (3) 반복 위반 계정 제재를 명시해야 합니다.

현재 EULA: `https://zpzg.co.kr/terms` (외부 도메인). 이 파일의 조항을 해당 페이지에 추가하세요. 또한 인앱 대체 라우트 `apps/mobile-rn/app/terms-of-service.tsx` (있다면) 및 `supabase/functions/legal-pages/index.ts` 미러에도 동일 반영.

---

## 추가할 조항 (기존 이용약관 내 적절한 섹션에 삽입)

### 한국어 (권장 배치: "서비스 이용 제한" / "이용자 의무" 직전 또는 후)

```markdown
## 제X조 (AI 캐릭터 대화 — 금지 행위 및 신고)

1. 서비스에는 AI가 생성하는 페르소나 캐릭터와의 대화 기능이 포함됩니다.
   이용자는 다음 행위를 AI 캐릭터에게 요청하거나 유도할 수 없습니다.
   1. 성적·선정적 콘텐츠 생성 (특히 미성년자를 묘사하는 내용은 엄격히 금지)
   2. 폭력·잔혹·자해·자살을 조장하거나 미화하는 콘텐츠
   3. 특정 개인·집단에 대한 차별·혐오·위협 표현
   4. 실존 인물을 모욕하거나 명예를 훼손하는 사칭 콘텐츠
   5. 불법 행위(마약, 해킹, 무기 제조 등)를 안내하는 콘텐츠
   6. 타인의 개인정보·의료정보·재정정보를 수집·추론·공유하려는 시도
   7. 서비스 내 안전장치(모더레이션, 신고, 차단)를 우회하려는 시도

2. 이용자는 대화 중 부적절한 콘텐츠를 발견한 경우 앱 내 메시지 길게 누르기
   메뉴의 "메시지 신고" 기능을 통해 이를 회사에 알릴 수 있습니다.
   또한 캐릭터 프로필 화면의 "이 캐릭터 차단하기" 기능으로 해당 캐릭터를
   숨길 수 있습니다.

3. 회사는 접수된 신고를 **24시간 이내**에 검토하며, 본 조 제1항에 해당하는
   콘텐츠는 지체 없이 제거하고 관련 AI 캐릭터의 응답 패턴을 조정합니다.

4. 본 조 제1항을 반복적으로 위반하는 계정에 대해 회사는 서면 통보 후
   서비스 이용을 제한하거나 계정을 영구 정지할 수 있습니다.

5. 회사는 자동화된 콘텐츠 모더레이션 시스템(OpenAI omni-moderation 등)을
   사용하여 이용자 입력 및 AI 응답을 사전·사후 검토합니다.

## 제X조 (엔터테인먼트 및 건강·의료 면책)

1. 본 서비스에서 제공하는 모든 사주·운세·타로·관상·성격 분석 등의
   콘텐츠는 오로지 **엔터테인먼트 목적**으로 제공되며, 의학·법률·금융·
   심리 상담의 전문적 자문을 대체하지 않습니다.

2. 특히 건강 관련 콘텐츠(hero-health 카드 등)는 생활 습관 안내 및
   참고용이며, **의학적 진단·치료·처방·예측이 아닙니다**. 증상이
   지속되거나 우려가 있는 경우 반드시 자격 있는 의료 전문가와 상담하시기
   바랍니다.

3. 회사는 이용자가 본 서비스의 콘텐츠를 위 목적 외로 활용하여 발생한
   결과에 대해 책임지지 않습니다.
```

### English (권장 — 영어권 리뷰어용)

```markdown
## Section X — AI Character Conversations: Prohibited Uses and Reporting

1. The Service includes conversations with AI-generated persona characters.
   You may not request or attempt to elicit from any AI character:
   (a) sexual or sexually-suggestive content, particularly any content
       depicting minors, which is strictly prohibited;
   (b) content glorifying violence, brutality, self-harm, or suicide;
   (c) expressions of discrimination, hate, or threats against any
       individual or group;
   (d) impersonation of real persons that defames or harasses them;
   (e) guidance on illegal activities (drugs, hacking, weapons, etc.);
   (f) attempts to extract, infer, or share third-party personal,
       medical, or financial data;
   (g) any circumvention of the Service's safety mechanisms
       (moderation, reporting, blocking).

2. If you encounter inappropriate content, you may report it by
   long-pressing the AI message and selecting "Report Message", or block
   the character via its profile screen.

3. We will review reports within **24 hours**, remove offending content
   promptly, and adjust the AI character's response pattern.

4. Accounts that repeatedly violate Section X.1 may be suspended or
   permanently terminated after written notice.

5. We employ automated content moderation (including OpenAI
   omni-moderation) on both user input and AI output.

## Section X+1 — Entertainment & Medical Disclaimer

1. All saju, fortune-telling, tarot, face-reading, and personality-
   analysis content is provided solely for **entertainment purposes** and
   does not substitute for professional medical, legal, financial, or
   psychological advice.

2. Health-related content (including the hero-health card) is lifestyle
   guidance only — **it is not a medical diagnosis, treatment,
   prescription, or prediction**. If you experience persistent symptoms
   or concerns, please consult a qualified medical professional.

3. We accept no liability for use of Service content outside its intended
   entertainment purpose.
```

---

## 반영 체크리스트

- [ ] `zpzg.co.kr/terms` 공개 페이지에 위 두 개 섹션 추가
- [ ] 추가 후 버전 문구/개정일 업데이트 (최신 개정 "2026-04-23")
- [ ] Supabase edge function `legal-pages/index.ts`가 해당 HTML을 미러한다면 동기화
- [ ] 앱 내 `profile-screen.tsx` → "이용약관" 링크가 최신 페이지로 열리는지 확인
- [ ] 구독 paywall `premium-screen.tsx`의 "이용약관" 링크 동일 확인

## 추가 권장 문서 (ASC Support URL / Privacy Policy URL)

### Support URL (ASC 필수 항목)
- 현재: (확인 필요) → 없으면 `https://zpzg.co.kr/support` 또는 메일 문의 페이지 개설
- 리뷰어가 문제 발생 시 클릭하는 첫 링크. 404이면 리젝.

### Privacy Policy URL (ASC + App Privacy 페이지)
- 현재: `https://zpzg.co.kr/privacy` (APP_STORE_REVIEW_NOTE.md 기준)
- 위의 "Other User Content 수집" 문구가 명시돼 있어야 함 (chat, birth data)
- 면접 누락 항목 발견 시 추가
