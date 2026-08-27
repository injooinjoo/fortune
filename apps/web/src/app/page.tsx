import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  alternates: { canonical: '/' },
};

import { WEB_CHAT_CHARACTERS } from '@/features/chat/characters';
import { WEB_FORTUNES, type WebFortune } from '@/features/fortune/catalog';
import {
  CHAT_INDEX_HREF,
  FORTUNE_INDEX_HREF,
  chatHref,
  fortuneHref,
} from '@/lib/href';

import styles from './home.module.css';

const FEATURED = [
  { type: 'daily', label: '오늘의 운세', mark: '☼', tone: 'sand' },
  { type: 'tarot', label: '오늘의 타로', mark: '◇', tone: 'lavender' },
  { type: 'love', label: '연애운', mark: '♡', tone: 'rose' },
  { type: 'wealth', label: '재물운', mark: '✦', tone: 'sage' },
] as const;

const PURPOSES = [
  {
    label: '오늘',
    title: '하루의 흐름과 타이밍',
    description: '지금 밀어도 되는 일과 잠시 두어야 할 일을 봐요.',
    slug: '오늘',
    mark: '☼',
  },
  {
    label: '사랑',
    title: '마음과 관계의 온도',
    description: '관계에서 놓치고 있던 감정의 방향을 짚어봐요.',
    slug: '연애',
    mark: '♡',
  },
  {
    label: '일과 돈',
    title: '커리어와 금전의 방향',
    description: '오늘 집중할 일과 지출의 흐름을 차분히 살펴봐요.',
    slug: '직업',
    mark: '△',
  },
  {
    label: '마음과 생활',
    title: '컨디션과 일상 리듬',
    description: '몸과 마음의 속도를 조절할 작은 단서를 찾아요.',
    slug: '건강',
    mark: '○',
  },
] as const;

const TRUST_POINTS = [
  ['로그인 없이 시작 가능', '계정은 결과를 저장하고 싶을 때 만들어도 돼요.'],
  ['약 1분 내 확인', '생년월일 하나로 오늘의 흐름을 읽어요.'],
  ['모르는 정보는 건너뛰어요.', '선택 입력을 비워도 결과를 볼 수 있어요.'],
  ['재미로 보는 리딩이에요.', '의료·법률·투자 등 전문적 조언을 대체하지 않아요.'],
] as const;

function requireFortune(type: string): WebFortune {
  const fortune = WEB_FORTUNES.find((item) => item.fortuneType === type);
  if (!fortune) throw new Error(`Missing web fortune: ${type}`);
  return fortune;
}

const featuredFortunes = FEATURED.map((item) => ({ ...item, fortune: requireFortune(item.type) }));
const todayFortune = requireFortune('daily');

export default function HomePage() {
  return (
    <main className={styles.home}>
      <section className={styles.hero} aria-labelledby="home-title">
        <div className={styles.heroInner}>
          <div className={styles.heroCopy}>
            <p className={styles.eyebrow}>온도 · ONDO</p>
            <h1 id="home-title">오늘 하루가 어떻게 흘러갈지, 생년월일 하나로 읽어드려요.</h1>
            <p className={styles.heroDescription}>
              설치도 로그인도 필요 없어요. 생년월일을 알려주시면 오늘의 흐름을 편지처럼 정리해 드립니다.
            </p>
            <div className={styles.heroActions}>
              <Link className={styles.primaryButton} href={fortuneHref(todayFortune.slug)}>
                오늘의 운세 보기 <span aria-hidden="true">→</span>
              </Link>
              <Link className={styles.textLink} href="#result-preview">
                어떤 결과가 나오나요? <span aria-hidden="true">↓</span>
              </Link>
            </div>
            <p className={styles.heroNote}>
              로그인 없이 바로 시작 · 1회에 온도 {todayFortune.costPoints}개가 사용돼요
            </p>
          </div>

          <div className={styles.heroVisual} aria-label="오늘의 운세 결과 예시">
            <span className={styles.sunHalo} aria-hidden="true">☼</span>
            <article className={styles.previewLetter}>
              <p className={styles.letterKicker}>오늘의 운세 · 예시</p>
              <p className={styles.letterQuote}>서두르지 않아도 흐름이 당신 편인 날이에요.</p>
              <div className={styles.letterDetails}>
                <span><strong>오전</strong> 미뤄둔 연락 하나 보내기</span>
                <span><strong>저녁</strong> 즉흥 지출은 잠시 두기</span>
              </div>
              <div className={styles.letterConversation}>
                <span className={styles.miniAvatar} aria-hidden="true">하</span>
                <span>결과를 두고 하은과 이어서 이야기할 수 있어요.</span>
              </div>
            </article>
          </div>
        </div>

        <div className={styles.trustStrip} aria-label="온도 이용 원칙">
          {TRUST_POINTS.map(([title, description], index) => (
            <div className={styles.trustItem} key={title}>
              <span className={styles.trustNumber} aria-hidden="true">0{index + 1}</span>
              <p><strong>{title}</strong><span>{description}</span></p>
            </div>
          ))}
        </div>
      </section>

      <section className={styles.section} aria-labelledby="purpose-title">
        <div className={styles.sectionHeading}>
          <p className={styles.eyebrow}>오늘의 질문</p>
          <h2 id="purpose-title">지금 어떤 흐름이 궁금한가요?</h2>
          <p>답을 정해주기보다, 지금의 마음을 읽고 다음 한 걸음을 고를 수 있게 도와드려요.</p>
        </div>
        <div className={styles.purposeGrid}>
          {PURPOSES.map((purpose) => (
            <Link className={styles.purposeCard} href={fortuneHref(purpose.slug)} key={purpose.label}>
              <span className={styles.purposeMark} aria-hidden="true">{purpose.mark}</span>
              <span className={styles.cardKicker}>{purpose.label}</span>
              <h3>{purpose.title}</h3>
              <p>{purpose.description}</p>
              <span className={styles.cardArrow} aria-hidden="true">→</span>
            </Link>
          ))}
        </div>
      </section>

      <section className={`${styles.section} ${styles.featuredSection}`} aria-labelledby="featured-title">
        <div className={styles.sectionHeadingRow}>
          <div className={styles.sectionHeading}>
            <p className={styles.eyebrow}>많이 찾는 리딩</p>
            <h2 id="featured-title">가장 많이 찾는 운세</h2>
          </div>
          <Link className={styles.textLink} href={FORTUNE_INDEX_HREF}>전체 보기 <span aria-hidden="true">→</span></Link>
        </div>
        <div className={styles.fortuneGrid}>
          {featuredFortunes.map(({ fortune, label, mark, tone }) => (
            <Link className={styles.fortuneCard} data-tone={tone} href={fortuneHref(fortune.slug)} key={fortune.slug}>
              <div className={styles.fortuneCardTop}>
                <span className={styles.fortuneMark} aria-hidden="true">{mark}</span>
                <span className={styles.cost}>온도 {fortune.costPoints}개</span>
              </div>
              <h3>{label}</h3>
              <p>{fortune.blurb}</p>
              <span className={styles.readLink}>리딩 시작 <span aria-hidden="true">→</span></span>
            </Link>
          ))}
        </div>
      </section>

      <section className={`${styles.section} ${styles.resultSection}`} id="result-preview" aria-labelledby="result-title">
        <div className={styles.sectionHeading}>
          <p className={styles.eyebrow}>결과 예시</p>
          <h2 id="result-title">오늘의 리딩은 이렇게 도착해요</h2>
          <p>긴 설명보다 오늘 기억할 한 문장, 조심할 순간, 바로 해볼 작은 행동을 순서대로 보여줘요.</p>
        </div>
        <div className={styles.resultCard}>
          <div className={styles.resultStars} aria-hidden="true">✦　·　✧</div>
          <div className={styles.resultMain}>
            <p className={styles.resultDate}>오늘 · 오늘의 흐름</p>
            <h3>밀어붙이기보다 정리할 때 길이 보여요.</h3>
            <p className={styles.resultBody}>
              오전에는 답이 늦어도 재촉하지 마세요. 오후가 되면 흐릿했던 우선순위가 자연스럽게 정리됩니다.
              오늘은 새로운 일을 더하기보다, 이미 시작한 한 가지를 끝내는 쪽이 잘 맞아요.
            </p>
            <div className={styles.resultSignals}>
              <span><small>기억할 행동</small> 미뤄둔 연락 하나 보내기</span>
              <span><small>잠시 멈출 것</small> 기분에 따른 즉흥 지출</span>
              <span><small>행운의 단서</small> 따뜻한 차와 저녁 산책</span>
            </div>
          </div>
          <aside className={styles.resultAside}>
            <span className={styles.resultAvatar} aria-hidden="true">하</span>
            <p>“결과에서 마음에 걸린 문장, 그거부터 얘기해 봐.”</p>
            <Link href={chatHref(WEB_CHAT_CHARACTERS[0].id)}>하은과 이야기하기 <span aria-hidden="true">→</span></Link>
          </aside>
        </div>
      </section>

      <section className={`${styles.section} ${styles.characterSection}`} aria-labelledby="character-title">
        <div className={styles.sectionHeadingRow}>
          <div className={styles.sectionHeading}>
            <p className={styles.eyebrow}>AI 캐릭터</p>
            <h2 id="character-title">결과를 보고 끝내지 말고, 오늘의 마음을 이어서 이야기해 보세요.</h2>
            <p>정답을 대신 정하지 않는 네 명의 캐릭터가 각자의 말투로 먼저 말을 걸어요.</p>
          </div>
          <Link className={styles.textLink} href={CHAT_INDEX_HREF}>모두 만나기 <span aria-hidden="true">→</span></Link>
        </div>
        <div className={styles.characterGrid}>
          {WEB_CHAT_CHARACTERS.map((character, index) => (
            <Link className={styles.characterCard} href={chatHref(character.id)} key={character.id}>
              <span className={styles.characterPortrait} data-index={index} aria-hidden="true">
                {character.name.slice(0, 1)}
              </span>
              <span className={styles.cardKicker}>{character.relationship}</span>
              <h3>{character.name}</h3>
              <p>{character.tagline}</p>
              <span className={styles.characterTags}>{character.tags.slice(0, 2).map((tag) => `#${tag}`).join(' ')}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className={`${styles.section} ${styles.guideSection}`} id="ondo-guide" aria-labelledby="guide-title">
        <div className={styles.sectionHeading}>
          <p className={styles.eyebrow}>이용 안내</p>
          <h2 id="guide-title">온도는 이렇게 사용해요</h2>
          <p>운세를 보기 전에 필요한 온도를 확인할 수 있어요. 숨겨진 단계 없이 세 번이면 끝납니다.</p>
        </div>
        <ol className={styles.guideSteps}>
          <li><span>1</span><strong>궁금한 운세를 고르기</strong><p>오늘, 사랑, 일과 돈, 생활 중 지금 필요한 흐름을 선택해요.</p></li>
          <li><span>2</span><strong>사용할 온도 확인하기</strong><p>각 카드에 표시된 온도를 보고 시작 여부를 직접 결정해요.</p></li>
          <li><span>3</span><strong>결과를 읽고 이어가기</strong><p>오늘 해볼 행동을 고르거나 캐릭터와 대화를 이어가요.</p></li>
        </ol>
        <p className={styles.guideNote}>운세 결과는 엔터테인먼트 목적이며 중요한 결정의 근거가 되어서는 안 됩니다.</p>
      </section>

      <section className={styles.finalCta} aria-labelledby="final-title">
        <p className={styles.eyebrow}>오늘의 온도</p>
        <h2 id="final-title">오늘을 바꿀 거창한 답보다, 지금 해볼 한 가지를 만나보세요.</h2>
        <Link className={styles.primaryButton} href={fortuneHref(todayFortune.slug)}>
          오늘의 운세 시작하기 <span aria-hidden="true">→</span>
        </Link>
      </section>
    </main>
  );
}
