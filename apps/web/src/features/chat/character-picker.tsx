/**
 * `/대화` 목록. 순수 컴포넌트라 서버에서 그대로 렌더된다 — 첫 화면에 캐릭터
 * 소개가 HTML 로 들어가야 검색/링크 프리뷰에 잡힌다.
 */

import { AppLink as Link } from '@/components/app-link';
import { getFortuneCostPoints } from '@fortune/product-contracts';

import { chatHref } from '@/lib/href';

import { CharacterAvatar } from './character-avatar';
import { WEB_CHAT_CHARACTERS } from './characters';
import styles from './chat.module.css';

export function CharacterPicker() {
  return (
    <div className={styles.characterGrid}>
      {WEB_CHAT_CHARACTERS.map((character) => (
        <Link
          className={`ondo-card ${styles.characterCard}`}
          href={chatHref(character.id)}
          key={character.id}
        >
          <span className={styles.characterCardBody}>
            <span className={styles.characterIdentity}>
              <CharacterAvatar character={character} large />
              <span>
                <span className="ondo-kicker">{character.relationship}</span>
                <span className="ondo-h3">{character.name}</span>
              </span>
            </span>
            <span className="ondo-muted">{character.tagline}</span>

            <span className={styles.tagRow}>
              {character.tags.map((tag) => (
                <span className={styles.tag} key={tag}>
                  #{tag}
                </span>
              ))}
            </span>
            <span className={styles.openerPreview}>“{character.opener}”</span>
            <span className={styles.characterCardAction}>
              <span>대화 시작하기 <span aria-hidden="true">→</span></span>
              <small>답장당 온도 {getFortuneCostPoints('character-chat')}개</small>
            </span>
          </span>
        </Link>
      ))}
    </div>
  );
}
