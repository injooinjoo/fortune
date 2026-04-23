# P11-B2 Plan: UGC Moderation + Report/Block (Apple 5.2.3)

## 구현 순서 (MVP 블로커 우선, 비관적 블라스트 순)

1. **SQL migration** — tables + RLS, additive
2. **`_shared/moderation.ts`** — OpenAI `omni-moderation-latest` 래퍼
3. **`report-message` edge function** — JWT 필수, RLS로 self-insert
4. **Client `character-blocks.ts` + profile block button + chat list filter**
5. **Client `MessageReportSheet` + chat-surface long-press**
6. **`character-chat/index.ts` moderation hooks** (env flag 가드)
7. **`delete-account` DELETE_TARGETS 업데이트**

## 신설 테이블
- `message_reports` — 신고 내역
- `character_blocks` — 차단된 캐릭터
- `moderation_flags` — 서버 자동 필터 감사 로그

## 스코프 컷
- **MVP**: report 버튼 + 실제 submit, block 버튼 + 리스트 필터, input moderation 1회, EULA 24h takedown clause
- **Defer**: output moderation, image moderation, blocked chars 관리 화면, 연령 게이트 (W1 별도)

## EULA 업데이트 (user 후속)
zpzg.co.kr/terms 외부 도메인 + `public/terms.html` 미러에 추가:
- "AI 캐릭터에게 타인 괴롭힘/성적/폭력적/미성년 콘텐츠 요청 금지"
- "신고 콘텐츠는 24h 이내 검토, 위반 시 제거"
- "반복 위반 계정 이용 제한"
