import type { ImageSourcePropType } from 'react-native';

const chatCharacterAvatarSources: Record<string, ImageSourcePropType> = {
  luts: require('../../../../assets/images/character/avatars/luts.webp'),
  jung_tae_yoon: require('../../../../assets/images/character/avatars/jung_tae_yoon.webp'),
  seo_yoonjae: require('../../../../assets/images/character/avatars/seo_yoonjae.webp'),
  kang_harin: require('../../../../assets/images/character/avatars/kang_harin.webp'),
  jayden_angel: require('../../../../assets/images/character/avatars/jayden_angel.webp'),
  ciel_butler: require('../../../../assets/images/character/avatars/ciel_butler.webp'),
  lee_doyoon: require('../../../../assets/images/character/avatars/lee_doyoon.webp'),
  han_seojun: require('../../../../assets/images/character/avatars/han_seojun.webp'),
  baek_hyunwoo: require('../../../../assets/images/character/avatars/baek_hyunwoo.webp'),
  min_junhyuk: require('../../../../assets/images/character/avatars/min_junhyuk.webp'),
  fortune_haneul: require('../../../../assets/images/character/avatars/fortune_haneul.webp'),
  fortune_muhyeon: require('../../../../assets/images/character/avatars/fortune_muhyeon.webp'),
  fortune_stella: require('../../../../assets/images/character/avatars/fortune_stella.webp'),
  fortune_dr_mind: require('../../../../assets/images/character/avatars/fortune_dr_mind.webp'),
  fortune_rose: require('../../../../assets/images/character/avatars/fortune_rose.webp'),
  fortune_james_kim: require('../../../../assets/images/character/avatars/fortune_james_kim.webp'),
  fortune_lucky: require('../../../../assets/images/character/avatars/fortune_lucky.webp'),
  fortune_marco: require('../../../../assets/images/character/avatars/fortune_marco.webp'),
  fortune_lina: require('../../../../assets/images/character/avatars/fortune_lina.webp'),
  fortune_luna: require('../../../../assets/images/character/avatars/fortune_luna.webp'),
};

export function resolveChatCharacterAvatarSource(
  characterId: string | null | undefined,
) {
  if (!characterId) {
    return null;
  }

  return chatCharacterAvatarSources[characterId] ?? null;
}
