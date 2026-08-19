import Link from 'next/link';

import { getFortuneCostPoints } from '@fortune/product-contracts';

const highlights = [
  {
    kicker: 'SAJU',
    title: '생년월일시로 읽는 오늘',
    body: '만세력 기반으로 사주를 세운 뒤, 오늘 하루의 흐름을 종합·애정·재물·일·학업·건강으로 나눠 정리합니다.',
  },
  {
    kicker: 'CHARACTER',
    title: '나를 기억하는 캐릭터',
    body: '대화가 쌓일수록 관계가 달라집니다. 처음 만난 사이와 오래 본 사이의 말투가 같지 않습니다.',
  },
  {
    kicker: 'HONEST',
    title: '재미로 보는 콘텐츠',
    body: '온도의 운세는 엔터테인먼트 목적입니다. 의료·법률·투자 판단의 근거로 쓰지 않습니다.',
  },
];

export default function LandingPage() {
  const dailyCost = getFortuneCostPoints('daily');

  return (
    <main className="ondo-shell ondo-stack" style={{ gap: 'var(--ondo-spacing-xxl)' }}>
      <header className="ondo-stack">
        <p className="ondo-kicker">온도 · ONDO</p>
        <h1 className="ondo-h1">
          오늘 하루가 어떻게 흘러갈지,
          <br />
          생년월일 하나로 읽어드려요.
        </h1>
        <p className="ondo-muted">
          앱을 설치하지 않아도 웹에서 바로 오늘의 운세를 볼 수 있습니다. 이메일로 로그인하면 결과가 계정에 남습니다.
        </p>
        <div className="ondo-row" style={{ marginTop: 'var(--ondo-spacing-sm)' }}>
          <Link className="ondo-button" href="/app/f/daily">
            오늘의 운세 보기
          </Link>
          <Link className="ondo-button ondo-button--secondary" href="/auth/login">
            이메일로 로그인
          </Link>
        </div>
        <p className="ondo-muted">일일 운세 1회에 온도 {dailyCost}개가 사용됩니다.</p>
      </header>

      <section className="ondo-stack" aria-labelledby="highlights-heading">
        <h2 className="ondo-h2" id="highlights-heading">
          온도가 하는 일
        </h2>
        {highlights.map((item) => (
          <article className="ondo-card ondo-stack" key={item.kicker} style={{ gap: 'var(--ondo-spacing-xs)' }}>
            <p className="ondo-kicker">{item.kicker}</p>
            <h3 className="ondo-h3">{item.title}</h3>
            <p className="ondo-muted">{item.body}</p>
          </article>
        ))}
      </section>

      {/*
        개인정보처리방침 / 이용약관 / 문의 페이지는 아직 루트 `public/*.html` +
        루트 vercel.json rewrite 로만 서빙된다. apps/web 안으로 옮기기 전에는
        여기서 링크하면 404 가 되므로 고지 문구만 둔다.
      */}
      <footer className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-muted">
          온도의 모든 운세 콘텐츠는 엔터테인먼트 목적으로 제공되며, 어떠한 전문적 조언도 대체하지 않습니다.
        </p>
      </footer>
    </main>
  );
}
