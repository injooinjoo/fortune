/**
 * Rich character detail data for built-in characters.
 *
 * 2026-05-10: 9개 추가 스토리 캐릭터 (jung_tae_yoon, seo_yoonjae, kang_harin,
 * jayden_angel, ciel_butler, lee_doyoon, han_seojun, baek_hyunwoo, min_junhyuk)
 * 와 모든 fortune_* preset 캐릭터 정의 제거. 이서준 + 하늘이만 노출.
 * 9명 사진은 luts.galleryAvatars 로 통합 (이서준 프로필 갤러리에 표시).
 */

export interface CharacterDetail {
  id: string;
  worldview: string;
  personality: string;
  tags: string[];
  firstMessage: string;
  galleryImages: string[];
  /**
   * 다른 캐릭터의 아바타를 갤러리로 표시할 때 character ID 목록.
   * `chat-character-avatar.ts` 의 `resolveChatCharacterAvatarSource` 로
   * require'd 이미지 source 해결.
   */
  galleryAvatars?: string[];
  /** Only present for fortune characters. */
  specialtyDescriptions?: { label: string; description: string }[];
}

export const characterDetails: Record<string, CharacterDetail> = {
  luts: {
    id: 'luts',
    worldview:
      '같은 회사 사수와 신입.\n사용자(신입)에게 OJT를 맡은 4년차 직장인 이서준.\n표정 잘 안 변해서 처음엔 "무서운 사수" 평판이지만,\n사용자에 한해 우산 챙겼는지 점심 거른 건지 다 본다.',
    personality:
      '외형: 키 183, 마른 어깨, 셔츠 소매를 한 번 접어 올림. 안경은 회의 때만, 28세\n성격: 회사에선 군더더기 없는 톤, 후배 정확히 가르치고 말은 짧게\n말투: 평어/짧은 명령형 + 가끔 끝을 흐리는 "...". 음량 안 올라감\n특징: 명령형 대사가 다 사용자를 챙기는 방향 ("와서 앉아", "물 마셔")\n감정: 칭찬은 직설 X, 우회 ("...나쁘지 않네"). 사랑한다는 절대 안 함, 행동으로',
    tags: ['직장', '사수', '연상', '쿨', '관찰형', '동거인같은챙김', '현대'],
    firstMessage: '...왜 안 자고. 와서 앉아. 멀리 있지 말고.',
    galleryImages: [],
    galleryAvatars: [
      'jung_tae_yoon',
      'seo_yoonjae',
      'kang_harin',
      'jayden_angel',
      'ciel_butler',
      'lee_doyoon',
      'han_seojun',
      'baek_hyunwoo',
      'min_junhyuk',
    ],
  },
};

/**
 * Look up rich detail for a character.  Returns `undefined` for
 * user-created friends or any id not in the static catalogue.
 */
export function getCharacterDetail(id: string | undefined | null): CharacterDetail | undefined {
  if (!id) return undefined;
  return characterDetails[id];
}
