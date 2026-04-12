import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

const PAGES: Record<string, { title: string; sections: Array<{ title: string; body: string }> }> = {
  'privacy-policy': {
    title: '개인정보처리방침',
    sections: [
      {
        title: '1. 수집하는 개인정보 항목',
        body: '온도(이하 "앱")는 서비스 제공을 위해 다음 정보를 수집합니다: 이메일 주소, 이름(닉네임), 생년월일, 태어난 시간, MBTI, 혈액형 등 사용자가 직접 입력한 프로필 정보. 소셜 로그인 시 해당 플랫폼에서 제공하는 기본 프로필 정보(이메일, 이름). 서비스 이용 기록, 구매 내역, 기기 정보.',
      },
      {
        title: '2. 개인정보의 수집 및 이용 목적',
        body: '수집된 정보는 맞춤형 운세·인사이트 콘텐츠 제공, 계정 관리 및 본인 확인, 구매·구독 관리, 서비스 품질 개선 및 통계 분석에 사용됩니다.',
      },
      {
        title: '3. 개인정보의 보유 및 이용 기간',
        body: '회원 탈퇴 시 또는 수집 목적 달성 시 지체 없이 파기합니다. 단, 관계 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다 (전자상거래법에 따른 거래 기록: 5년, 소비자 불만 처리 기록: 3년).',
      },
      {
        title: '4. 개인정보의 제3자 제공',
        body: '원칙적으로 사용자의 동의 없이 개인정보를 외부에 제공하지 않습니다. 단, 법령에 의해 요구되는 경우는 예외로 합니다.',
      },
      {
        title: '5. 개인정보의 파기',
        body: '보유 기간이 경과하거나 처리 목적이 달성된 경우, 전자적 파일 형태의 정보는 복구 불가능한 방법으로 영구 삭제하며, 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각합니다.',
      },
      {
        title: '6. 이용자의 권리',
        body: '사용자는 언제든지 자신의 개인정보를 조회·수정·삭제할 수 있으며, 앱 내 프로필 설정 또는 고객센터(injoo1222@naver.com)를 통해 처리 가능합니다. 계정 삭제를 요청하면 관련 데이터를 지체 없이 파기합니다.',
      },
      {
        title: '7. 자동 수집 장치의 설치·운영 및 거부',
        body: '앱은 서비스 개선을 위해 분석 도구(Mixpanel 등)를 사용할 수 있으며, 이를 통해 익명화된 사용 패턴 정보를 수집합니다.',
      },
      {
        title: '8. 개인정보 보호책임자',
        body: '성명: 김인주 / 이메일: injoo1222@naver.com. 개인정보 관련 문의사항은 위 연락처로 접수해 주시기 바랍니다.',
      },
      {
        title: '9. 시행일',
        body: '본 개인정보처리방침은 2026년 4월 11일부터 시행됩니다.',
      },
    ],
  },
  'terms-of-service': {
    title: '이용약관',
    sections: [
      {
        title: '제1조 (목적)',
        body: '본 약관은 온도(이하 "앱")가 제공하는 AI 기반 운세·인사이트·스토리 서비스의 이용 조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.',
      },
      {
        title: '제2조 (서비스의 내용)',
        body: '앱은 AI를 활용한 오락 목적의 운세, 사주, 타로, 별자리, MBTI 분석, 캐릭터 채팅 등의 콘텐츠를 제공합니다. 모든 콘텐츠는 오락 목적으로 제공되며, 전문적인 조언을 대체하지 않습니다.',
      },
      {
        title: '제3조 (회원가입 및 계정)',
        body: '서비스 이용을 위해 소셜 로그인(Apple, Google, 카카오, 네이버) 또는 게스트 모드로 접근할 수 있습니다. 사용자는 자신의 계정 보안과 제출 정보의 정확성을 유지할 책임이 있습니다.',
      },
      {
        title: '제4조 (결제 및 구독)',
        body: '유료 콘텐츠의 결제와 구독 갱신은 Apple App Store 정책을 따릅니다. 구독 해지는 각 플랫폼의 구독 관리 페이지에서 가능합니다. 환불 정책은 해당 플랫폼의 정책에 따릅니다.',
      },
      {
        title: '제5조 (면책)',
        body: 'AI가 생성한 콘텐츠(운세, 사주, 궁합 등)는 오락용이며, 의료·법률·금융 등 전문 분야의 조언으로 사용해서는 안 됩니다. 앱의 콘텐츠를 근거로 한 의사결정에 대한 책임은 사용자에게 있습니다.',
      },
      {
        title: '제6조 (서비스의 변경 및 중단)',
        body: '운영자는 서비스 개선을 위해 사전 공지 후 서비스 내용을 변경하거나 일시 중단할 수 있습니다.',
      },
      {
        title: '부칙',
        body: '본 약관은 2026년 4월 11일부터 시행됩니다.',
      },
    ],
  },
};

function renderPage(pageKey: string): string {
  const page = PAGES[pageKey];
  if (!page) return '';

  const sectionsHtml = page.sections
    .map(
      (s) => `
      <div class="section">
        <h2>${s.title}</h2>
        <p>${s.body}</p>
      </div>`
    )
    .join('');

  return `<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${page.title} - 온도</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0B0B10; color: #E8E8ED; line-height: 1.6; padding: 24px 20px 48px; max-width: 640px; margin: 0 auto; }
    h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; color: #fff; }
    .subtitle { font-size: 14px; color: #9898A6; margin-bottom: 32px; }
    .section { background: #1A1A24; border-radius: 12px; padding: 20px; margin-bottom: 16px; }
    .section h2 { font-size: 16px; font-weight: 600; margin-bottom: 8px; color: #C8C8D4; }
    .section p { font-size: 14px; color: #9898A6; }
    .footer { text-align: center; margin-top: 40px; font-size: 12px; color: #6B6B7B; }
  </style>
</head>
<body>
  <h1>${page.title}</h1>
  <p class="subtitle">온도 - AI 운세 & 스토리</p>
  ${sectionsHtml}
  <div class="footer">© 2026 온도 (Ondo). All rights reserved.</div>
</body>
</html>`;
}

serve((req: Request) => {
  const url = new URL(req.url);
  const path = url.pathname.replace(/^\/legal-pages\/?/, '').replace(/\/$/, '') || '';

  if (path === 'privacy-policy') {
    return new Response(renderPage('privacy-policy'), {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }

  if (path === 'terms-of-service') {
    return new Response(renderPage('terms-of-service'), {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }

  // Default: show index with links
  return new Response(
    `<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>온도 - 법적 고지</title>
<style>body{font-family:-apple-system,sans-serif;background:#0B0B10;color:#E8E8ED;padding:40px 20px;max-width:640px;margin:0 auto;text-align:center}h1{margin-bottom:24px}a{display:block;background:#1A1A24;color:#C8C8D4;text-decoration:none;padding:16px;border-radius:12px;margin-bottom:12px;font-size:16px}a:hover{background:#24243A}</style>
</head>
<body>
  <h1>온도</h1>
  <a href="privacy-policy">개인정보처리방침</a>
  <a href="terms-of-service">이용약관</a>
</body></html>`,
    { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
  );
});
