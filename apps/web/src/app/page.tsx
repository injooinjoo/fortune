import type { Metadata } from 'next';
import { AppLink as Link } from '@/components/app-link';

import { WEB_CHAT_CHARACTERS } from '@/features/chat/characters';
import { WEB_FORTUNES, type WebFortune } from '@/features/fortune/catalog';
import {
  CHAT_INDEX_HREF,
  FORTUNE_INDEX_HREF,
  chatHref,
  fortuneHref,
} from '@/lib/href';

import styles from './home.module.css';

export const metadata: Metadata = {
  alternates: { canonical: '/' },
};

const CATEGORY_TYPES = [
  { type: 'daily', label: '오늘' },
  { type: 'love', label: '연애' },
  { type: 'wealth', label: '재물' },
  { type: 'career', label: '직장' },
  { type: 'health', label: '건강' },
] as const;

const FEATURED_TYPES = [
  { type: 'daily', mark: '01', detail: '오늘의 흐름을 가장 빠르게' },
  { type: 'tarot', mark: '02', detail: '한 가지 질문에 집중해서' },
  { type: 'love', mark: '03', detail: '관계와 마음의 방향을' },
  { type: 'wealth', mark: '04', detail: '지출과 선택의 타이밍을' },
] as const;

function requireFortune(type: string): WebFortune {
  const fortune = WEB_FORTUNES.find((item) => item.fortuneType === type);
  if (!fortune) throw new Error(`Missing web fortune: ${type}`);
  return fortune;
}

const categories = CATEGORY_TYPES.map((item) => ({ ...item, fortune: requireFortune(item.type) }));
const featuredFortunes = FEATURED_TYPES.map((item) => ({ ...item, fortune: requireFortune(item.type) }));
const todayFortune = requireFortune('daily');
const firstCharacter = WEB_CHAT_CHARACTERS[0];

export default function HomePage() {
  return (
    <main className={styles.home}>
      <section className={styles.todaySection} aria-labelledby="home-title">
        <div className={styles.todayGrid}>
          <article className={styles.todayPanel}>
            <div className={styles.todayHeading}>
              <p className={styles.eyebrow}>오늘의 온도 · Daily reading</p>
              <span className={styles.todayIndex} aria-hidden="true">01</span>
            </div>
            <h1 id="home-title">생년월일로 오늘의 흐름을 읽고,<br />지금 할 한 가지를 골라보세요.</h1>
            <p className={styles.todayDescription}>
              생년월일 하나면 충분해요. 긴 예언보다 오늘 기억할 문장과 바로 해볼 행동을 차분히 정리합니다.
            </p>

            <dl className={styles.todayFacts}>
              <div><dt>입력</dt><dd>생년월일 필수</dd></div>
              <div><dt>시간</dt><dd>약 1분</dd></div>
              <div><dt>사용</dt><dd>온도 {todayFortune.costPoints}개</dd></div>
            </dl>

            <div className={styles.todayActions}>
              <Link className={styles.primaryButton} href={fortuneHref(todayFortune.slug)}>
                오늘의 운세 보기 <span aria-hidden="true">→</span>
              </Link>
              <p>로그인 없이 시작하고, 결과를 남길 때 계정을 연결할 수 있어요.</p>
            </div>
          </article>

          <aside className={styles.sideRail} aria-label="온도 바로가기">
            <Link className={styles.continuePanel} href="/app">
              <span className={styles.eyebrow}>내 기록</span>
              <strong>최근 리딩과 온도 잔액을<br />한곳에서 이어보세요.</strong>
              <span className={styles.inlineAction}>내 기록 열기 <span aria-hidden="true">→</span></span>
            </Link>
            <Link className={styles.chatPanel} href={chatHref(firstCharacter.id)}>
              <span className={styles.eyebrow}>결과 다음 이야기</span>
              <strong>“마음에 걸린 문장부터<br />같이 얘기해 볼까?”</strong>
              <span>{firstCharacter.name}과 대화하기 <span aria-hidden="true">→</span></span>
            </Link>
          </aside>
        </div>

        <nav className={styles.categoryRail} aria-label="운세 카테고리">
          <span>지금 궁금한 흐름</span>
          <div>
            {categories.map(({ fortune, label }) => (
              <Link href={fortuneHref(fortune.slug)} key={fortune.slug}>{label}</Link>
            ))}
          </div>
        </nav>
      </section>

      <section className={styles.section} aria-labelledby="featured-title">
        <header className={styles.sectionHeading}>
          <div>
            <p className={styles.eyebrow}>추천 리딩</p>
            <h2 id="featured-title">지금 필요한 깊이만큼</h2>
          </div>
          <p>가볍게 오늘을 확인하거나, 마음에 남은 질문 하나를 더 깊게 읽어보세요.</p>
        </header>

        <div className={styles.readingList}>
          {featuredFortunes.map(({ fortune, mark, detail }) => (
            <Link className={styles.readingItem} href={fortuneHref(fortune.slug)} key={fortune.slug}>
              <span className={styles.readingIndex}>{mark}</span>
              <span className={styles.readingCopy}>
                <small>{detail}</small>
                <strong>{fortune.title}</strong>
                <span>{fortune.blurb}</span>
              </span>
              <span className={styles.readingCost}>온도 {fortune.costPoints}개</span>
              <span className={styles.readingArrow} aria-hidden="true">↗</span>
            </Link>
          ))}
        </div>
        <Link className={styles.allLink} href={FORTUNE_INDEX_HREF}>운세 전체 보기 <span aria-hidden="true">→</span></Link>
      </section>

      <section className={styles.resultSection} id="result-preview" aria-labelledby="result-title">
        <header className={styles.sectionHeading}>
          <div>
            <p className={styles.eyebrow}>결과의 순서</p>
            <h2 id="result-title">읽고 끝나지 않도록</h2>
          </div>
          <p>한 문장으로 오늘을 이해하고, 중요한 흐름과 지금 해볼 행동으로 이어집니다.</p>
        </header>

        <div className={styles.resultPreview}>
          <article className={styles.resultMain}>
            <p className={styles.resultLabel}>오늘의 리딩 · 구성 예시</p>
            <h3>밀어붙이기보다 정리할 때<br />길이 보이는 날이에요.</h3>
            <div className={styles.temperatureTrack} aria-hidden="true"><span /></div>
            <dl className={styles.resultSignals}>
              <div><dt>기억할 행동</dt><dd>미뤄둔 연락 하나 보내기</dd></div>
              <div><dt>잠시 멈출 것</dt><dd>기분에 따른 즉흥 지출</dd></div>
              <div><dt>행운의 단서</dt><dd>따뜻한 차와 저녁 산책</dd></div>
            </dl>
          </article>
          <aside className={styles.resultConversation}>
            <span className={styles.characterInitial} aria-hidden="true">{firstCharacter.name.slice(0, 1)}</span>
            <p>결과에서 마음에 걸린 문장을 캐릭터와 이어서 이야기할 수 있어요.</p>
            <Link href={chatHref(firstCharacter.id)}>{firstCharacter.name}과 이야기하기 <span aria-hidden="true">→</span></Link>
          </aside>
        </div>
      </section>

      <section className={styles.conversationSection} aria-labelledby="conversation-title">
        <div>
          <p className={styles.eyebrow}>AI 캐릭터 대화</p>
          <h2 id="conversation-title">정답 대신, 오늘의 마음을<br />더 잘 말할 수 있게.</h2>
          <p>각기 다른 말투의 캐릭터가 리딩 다음 이야기를 기억하고 이어갑니다.</p>
          <Link className={styles.secondaryButton} href={CHAT_INDEX_HREF}>대화 상대 고르기 <span aria-hidden="true">→</span></Link>
        </div>
        <ul className={styles.characterList}>
          {WEB_CHAT_CHARACTERS.map((character) => (
            <li key={character.id}>
              <span>{character.name.slice(0, 1)}</span>
              <div><strong>{character.name}</strong><small>{character.relationship}</small></div>
              <em>{character.tags.slice(0, 2).map((tag) => `#${tag}`).join(' ')}</em>
            </li>
          ))}
        </ul>
      </section>

      <section className={styles.guideSection} id="ondo-guide" aria-labelledby="guide-title">
        <header>
          <p className={styles.eyebrow}>시작은 간단하게</p>
          <h2 id="guide-title">세 번이면 충분해요.</h2>
        </header>
        <ol>
          <li><span>1</span><div><strong>궁금한 흐름 고르기</strong><p>오늘, 연애, 재물, 직장, 건강 중 하나를 선택해요.</p></div></li>
          <li><span>2</span><div><strong>사용할 온도 확인하기</strong><p>시작 전에 사용량을 보고 직접 결정해요.</p></div></li>
          <li><span>3</span><div><strong>한 가지 행동으로 이어가기</strong><p>결과를 저장하거나 캐릭터와 더 이야기해요.</p></div></li>
        </ol>
      </section>
    </main>
  );
}
