// Maps production StoryRomancePilotCharacterId → vibe-assigned palette.
// Source palettes derive from story-chars.jsx:15-34 (amber/sky/purple/mint/pink).
import type { StoryRomancePilotCharacterId } from '../../lib/story-romance-pilots';

export interface StoryCharacterPalette {
  gradient: [string, string, string];
  color: string;
  role: string;
}

const amber: StoryCharacterPalette = {
  gradient: ['#FFDFB0', '#E8A268', '#7a4418'],
  color: '#E8A268',
  role: 'barista',
};
const sky: StoryCharacterPalette = {
  gradient: ['#C8DDFF', '#8FB8FF', '#1f3c6e'],
  color: '#8FB8FF',
  role: 'sky',
};
const purple: StoryCharacterPalette = {
  gradient: ['#C4B8FF', '#8B7BE8', '#3b2a94'],
  color: '#8B7BE8',
  role: 'purple',
};
const mint: StoryCharacterPalette = {
  gradient: ['#D8F0E4', '#9BE5B5', '#2a5a3a'],
  color: '#9BE5B5',
  role: 'mint',
};
const pink: StoryCharacterPalette = {
  gradient: ['#FFE0EC', '#FFC7D9', '#7a3850'],
  color: '#FFC7D9',
  role: 'pink',
};

export const storyCharacterPalettes: Record<
  StoryRomancePilotCharacterId,
  StoryCharacterPalette
> = {
  luts: amber,
  min_junhyuk: amber,
  jung_tae_yoon: sky,
  han_seojun: sky,
  seo_yoonjae: purple,
  jayden_angel: purple,
  kang_harin: mint,
  ciel_butler: mint,
  lee_doyoon: pink,
  baek_hyunwoo: pink,
};

export function getStoryCharacterPalette(
  character: StoryRomancePilotCharacterId,
): StoryCharacterPalette {
  return storyCharacterPalettes[character] ?? purple;
}
