/**
 * 타로 덱 cover 이미지 정적 매핑.
 *
 * RN 의 require() 는 literal path 만 받으므로 동적 경로 불가 → 덱 id 별로
 * 한 번씩 static require() 한 후 picker / draw widget 이 이 맵을 lookup.
 *
 * SoT: supabase/functions/fortune-tarot/tarotCatalog.ts (TAROT_DECK_DISPLAY_NAMES).
 * 자산: apps/mobile-rn/assets/tarot-decks/{deck_id}/{suit}/{card}.webp
 *  - 7개 덱은 major/00_fool.webp 가 cover
 *  - grand_etteilla 는 major arcana 가 없어서 cups/01_of_cups.webp 사용
 */

// eslint-disable-next-line @typescript-eslint/no-require-imports
const COVER_REQUIRES = {
  rider_waite: require('../../../assets/tarot-decks/rider_waite/major/00_fool.webp'),
  thoth: require('../../../assets/tarot-decks/thoth/major/00_fool.webp'),
  ancient_italian: require('../../../assets/tarot-decks/ancient_italian/major/00_fool.webp'),
  before_tarot: require('../../../assets/tarot-decks/before_tarot/major/00_fool.webp'),
  after_tarot: require('../../../assets/tarot-decks/after_tarot/major/00_fool.webp'),
  golden_dawn_cicero: require('../../../assets/tarot-decks/golden_dawn_cicero/major/00_fool.webp'),
  golden_dawn_wang: require('../../../assets/tarot-decks/golden_dawn_wang/major/00_fool.webp'),
  grand_etteilla: require('../../../assets/tarot-decks/grand_etteilla/cups/01_of_cups.webp'),
} as const;

export type TarotDeckId = keyof typeof COVER_REQUIRES;

export function getDeckCoverSource(deckId: string): number | null {
  if (deckId in COVER_REQUIRES) {
    return COVER_REQUIRES[deckId as TarotDeckId];
  }
  return null;
}
