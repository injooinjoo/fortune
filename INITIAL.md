## FEATURE:
[ 여기에 만들고 싶은 기능에 대해 최대한 상세하고 명확하게 작성합니다. ]
[ 예: "AI 운세 생성 시스템을 구현합니다. 사용자의 생년월일, MBTI, 선택한 운세 타입을 기반으로 GPT-4를 사용하여 개인화된 운세를 생성합니다. 결과는 캐시에 저장되어야 하며, 하루에 한 번만 새로 생성됩니다." ]

## EXAMPLES:
[ `examples/` 폴더에 추가한 관련 코드 예시 파일들을 여기에 나열하고, 각 예시의 어떤 부분을 참고해야 하는지 설명합니다. ]
[ 예:
- `src/lib/supabase.ts`: Supabase 클라이언트 초기화 패턴을 따르세요.
- `src/app/api/fortune/daily/route.ts`: API 라우트 구조와 에러 핸들링 방식을 참고하세요.
- `src/lib/services/fortune-service.ts`: 서비스 레이어 패턴과 캐싱 로직을 참고하세요.
]

## DOCUMENTATION:
[ 개발에 필요한 공식 문서, API 명세서, 블로그 게시물 등의 URL을 여기에 나열합니다. ]
[ 예:
- Next.js App Router 공식 문서: https://nextjs.org/docs/app
- Supabase JavaScript 클라이언트: https://supabase.com/docs/reference/javascript
- OpenAI API 문서: https://platform.openai.com/docs/api-reference
- shadcn/ui 컴포넌트: https://ui.shadcn.com/docs/components
]

## OTHER CONSIDERATIONS:
[ AI 어시스턴트가 자주 놓치는 부분이나, 이 기능에만 해당하는 특별한 요구사항, 제약 조건 등을 작성합니다. ]
[ 예:
- **중요**: API 키는 절대 클라이언트 사이드에 노출되면 안 됩니다.
- 에러 응답은 `FortuneError` 클래스를 사용하여 일관된 형식으로 반환해야 합니다.
- 운세 생성 시 사용자의 개인정보(생년월일 등)는 로그에 남기지 않습니다.
- 모바일에서도 원활하게 작동해야 하므로 응답 시간은 3초 이내여야 합니다.
- Rate limiting을 적용하여 사용자당 하루 최대 10회까지만 운세 생성을 허용합니다.
]