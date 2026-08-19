import Link from 'next/link';
import { CHAT_INDEX_HREF, FORTUNE_INDEX_HREF, fortuneHref } from '@/lib/href';

import { getFortuneCostPoints } from '@fortune/product-contracts';

import { FortuneLinkCard } from '@/components/fortune-link-card';
import { WEB_FORTUNES } from '@/features/fortune/catalog';

/**
 * 주 CTA 는 `/운세/오늘` 하나로 유지한다 — 첫 방문자가 결과까지 가는 경로 중
 * 실제로 검증된 건 이거다. 나머지 운세와 대화는 그 아래에서 전부 눈에 보이고
 * 닿을 수 있게 둔다 (설치 없이도 쓸 게 있다는 걸 첫 화면에서 알려야 한다).
 */
const OTHER_FORTUNES = WEB_FORTUNES.filter((fortune) => fortune.fortuneType !== 'daily');

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
          <Link className="ondo-button" href={fortuneHref('오늘')}>
            오늘의 운세 보기
          </Link>
          <Link className="ondo-button ondo-button--secondary" href={FORTUNE_INDEX_HREF}>
            운세 전체 보기
          </Link>
        </div>
        <p className="ondo-muted">일일 운세 1회에 온도 {dailyCost}개가 사용됩니다.</p>
      </header>

      <section className="ondo-stack" aria-labelledby="other-fortunes-heading">
        <h2 className="ondo-h2" id="other-fortunes-heading">
          오늘 말고도 볼 수 있는 것
        </h2>
        <div className="ondo-grid-2">
          {OTHER_FORTUNES.map((fortune) => (
            <FortuneLinkCard fortune={fortune} key={fortune.slug} />
          ))}
        </div>
      </section>

      <section className="ondo-stack" aria-labelledby="chat-heading">
        <h2 className="ondo-h2" id="chat-heading">
          운세만 보고 끝내지 않아도 돼요
        </h2>
        <Link className="ondo-card ondo-stack" href={CHAT_INDEX_HREF} style={{ gap: 'var(--ondo-spacing-xxs)' }}>
          <h3 className="ondo-h3">캐릭터와 대화하기</h3>
          <p className="ondo-muted">
            결과를 두고 이야기를 이어갈 수 있어요. 대화가 쌓일수록 캐릭터가 나를 기억합니다.
          </p>
        </Link>
      </section>

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
    </main>
  );
}
