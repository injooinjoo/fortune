import type { ImageSourcePropType } from 'react-native';

const chatCharacterAvatarSources: Record<string, ImageSourcePropType> = {
  luts: require('../../assets/character/avatars/luts.webp'),
  jung_tae_yoon: require('../../assets/character/avatars/jung_tae_yoon.webp'),
  seo_yoonjae: require('../../assets/character/avatars/seo_yoonjae.webp'),
  kang_harin: require('../../assets/character/avatars/kang_harin.webp'),
  jayden_angel: require('../../assets/character/avatars/jayden_angel.webp'),
  ciel_butler: require('../../assets/character/avatars/ciel_butler.webp'),
  lee_doyoon: require('../../assets/character/avatars/lee_doyoon.webp'),
  han_seojun: require('../../assets/character/avatars/han_seojun.webp'),
  baek_hyunwoo: require('../../assets/character/avatars/baek_hyunwoo.webp'),
  min_junhyuk: require('../../assets/character/avatars/min_junhyuk.webp'),
  fortune_haneul: require('../../assets/character/avatars/fortune_haneul.webp'),
  fortune_muhyeon: require('../../assets/character/avatars/fortune_muhyeon.webp'),
  fortune_stella: require('../../assets/character/avatars/fortune_stella.webp'),
  fortune_dr_mind: require('../../assets/character/avatars/fortune_dr_mind.webp'),
  fortune_rose: require('../../assets/character/avatars/fortune_rose.webp'),
  fortune_james_kim: require('../../assets/character/avatars/fortune_james_kim.webp'),
  fortune_lucky: require('../../assets/character/avatars/fortune_lucky.webp'),
  fortune_marco: require('../../assets/character/avatars/fortune_marco.webp'),
  fortune_lina: require('../../assets/character/avatars/fortune_lina.webp'),
  fortune_luna: require('../../assets/character/avatars/fortune_luna.webp'),
};

export function resolveChatCharacterAvatarSource(
  characterId: string | null | undefined,
) {
  if (!characterId) {
    return null;
  }

  return chatCharacterAvatarSources[characterId] ?? null;
}
