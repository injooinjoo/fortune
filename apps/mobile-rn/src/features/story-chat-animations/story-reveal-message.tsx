import { useEffect, useRef, useState } from 'react';
import { View } from 'react-native';

import type { ChatShellStoryRevealMessage } from '../../lib/chat-shell';
import type { StoryRomancePilotCharacterId } from '../../lib/story-romance-pilots';
import { EmotionMeter } from './emotion-meter';
import { MemoryRecall } from './memory-recall';
import { PepCapsules } from './pep-capsules';
import { PhotoRecall } from './photo-recall';
import { PoemCard } from './poem-card';
import { ResonanceOrbs } from './resonance-orbs';

interface StoryRevealMessageProps {
  message: ChatShellStoryRevealMessage;
  /** Pilot character id of the thread head — used to pick the palette. */
  characterId: string;
}

// Dispatches a ChatShellStoryRevealMessage to the matching reveal component
// from the story-chat-animations folder. Each mount assigns a stable `play`
// counter of 1 so the child animates exactly once; subsequent re-mounts
// (FlatList virtualization) also animate once — acceptable for v1. The
// `message.characterId` override takes precedence over the thread head when
// a reveal wants a different palette (e.g. cross-character callout).
export function StoryRevealMessage({
  message,
  characterId,
}: StoryRevealMessageProps) {
  // Palette fallback lives inside getStoryCharacterPalette — unknown ids
  // (custom friends, fortune characters) resolve to the default palette.
  const character = (message.characterId ?? characterId) as StoryRomancePilotCharacterId;
  const { reveal } = message;

  // Initialize play=1 after first paint so the child's own Animated.timing
  // observes the transition from 0 → 1 and runs its intro sequence.
  const [play, setPlay] = useState(0);
  const didStart = useRef(false);
  useEffect(() => {
    if (didStart.current) return;
    didStart.current = true;
    const t = setTimeout(() => setPlay(1), 16);
    return () => clearTimeout(t);
  }, []);

  return (
    <View style={{ width: '100%' }}>
      {reveal.type === 'memory' ? (
        <MemoryRecall
          character={character}
          play={play}
          data={{
            title: reveal.title,
            quote: reveal.quote,
            daysAgo: reveal.daysAgo,
          }}
        />
      ) : reveal.type === 'emotion' ? (
        <EmotionMeter
          character={character}
          play={play}
          data={{
            scoreLabel: reveal.scoreLabel,
            percent: reveal.percent,
            tags: reveal.tags,
          }}
        />
      ) : reveal.type === 'poem' ? (
        <PoemCard
          character={character}
          play={play}
          data={{ lines: reveal.lines }}
        />
      ) : reveal.type === 'pep' ? (
        <PepCapsules
          character={character}
          play={play}
          data={{ items: reveal.items }}
        />
      ) : reveal.type === 'photo' ? (
        <PhotoRecall
          character={character}
          play={play}
          data={{ dateLabel: reveal.dateLabel, caption: reveal.caption }}
        />
      ) : reveal.type === 'resonance' ? (
        <ResonanceOrbs
          character={character}
          play={play}
          data={{
            percent: reveal.percent,
            userTag: reveal.userTag,
            charTag: reveal.charTag,
          }}
        />
      ) : null}
    </View>
  );
}
