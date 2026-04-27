/**
 * StoryChapterTimeline — 전생 서사 두루마리 타임라인.
 *
 * 각 챕터는 ━━━━ 제N장 ━━━━ 헤더 + emoji/title + 본문 문단 구성.
 * 챕터 사이에는 왼쪽에 얇은 dashed 수직선이 이어져 두루마리 느낌을 만든다.
 *
 * 한국 전통 민화/한지 톤에 맞춰 amber accent(#E0A76B) 사용.
 *
 * 애니메이션: 마운트 시 각 챕터가 index × 200ms delay로 순차 fade-in.
 * (스크롤 기반 IntersectionObserver 대신 단순화된 stagger — 첫 렌더 시점부터 재생.)
 */
import { useEffect, useRef } from 'react';
import { Animated, Easing, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

const AMBER = '#E0A76B';

export interface StoryChapter {
  title?: string;
  content?: string;
  emoji?: string;
}

export interface StoryChapterTimelineProps {
  chapters: StoryChapter[];
}

function toChapterNumber(index: number): string {
  return `제${index + 1}장`;
}

interface ChapterRowProps {
  chapter: StoryChapter;
  index: number;
  isLast: boolean;
}

function ChapterRow({ chapter, index, isLast }: ChapterRowProps) {
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: 1,
      duration: 500,
      delay: index * 200,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: true,
    }).start();
  }, [anim, index]);

  const translateY = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [12, 0],
  });

  const chapterEmoji =
    typeof chapter.emoji === 'string' && chapter.emoji.trim()
      ? chapter.emoji.trim()
      : '📜';
  const chapterTitle =
    typeof chapter.title === 'string' && chapter.title.trim()
      ? chapter.title.trim()
      : toChapterNumber(index);
  const chapterContent =
    typeof chapter.content === 'string' ? chapter.content.trim() : '';

  return (
    <Animated.View
      style={{
        flexDirection: 'row',
        gap: fortuneTheme.spacing.sm,
        opacity: anim,
        transform: [{ translateY }],
      }}
    >
      {/* Left gutter: dot + dashed connector */}
      <View style={{ width: 16, alignItems: 'center' }}>
        <View
          style={{
            width: 10,
            height: 10,
            borderRadius: 5,
            backgroundColor: AMBER,
            marginTop: 6,
          }}
        />
        {!isLast ? (
          <View
            style={{
              flex: 1,
              width: 1,
              borderLeftWidth: 1,
              borderStyle: 'dashed',
              borderLeftColor: withAlpha(AMBER, 0.4),
              marginTop: 4,
              minHeight: 32,
            }}
          />
        ) : null}
      </View>

      {/* Chapter content */}
      <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
        {/* "━━━━ 제N장 ━━━━" divider */}
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <View
            style={{
              flex: 1,
              height: 1,
              backgroundColor: withAlpha(AMBER, 0.35),
            }}
          />
          <AppText
            variant="labelMedium"
            color={AMBER}
            style={{ letterSpacing: 2 }}
          >
            {toChapterNumber(index)}
          </AppText>
          <View
            style={{
              flex: 1,
              height: 1,
              backgroundColor: withAlpha(AMBER, 0.35),
            }}
          />
        </View>

        {/* Title + emoji */}
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            gap: fortuneTheme.spacing.xs,
            marginTop: 2,
          }}
        >
          <AppText style={{ fontSize: 18, lineHeight: 22 }}>
            {chapterEmoji}
          </AppText>
          <AppText
            variant="heading4"
            style={{ fontFamily: 'ZenSerif', flex: 1 }}
          >
            {chapterTitle}
          </AppText>
        </View>

        {/* Content paragraph */}
        {chapterContent ? (
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 22, marginTop: 2 }}
          >
            {chapterContent}
          </AppText>
        ) : null}
      </View>
    </Animated.View>
  );
}

export function StoryChapterTimeline({ chapters }: StoryChapterTimelineProps) {
  const items = chapters.filter(
    (c) => (c && (c.title || c.content || c.emoji)) !== undefined,
  );

  if (items.length === 0) {
    return null;
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {items.map((chapter, index) => (
        <ChapterRow
          key={`chapter-${index}`}
          chapter={chapter}
          index={index}
          isLast={index === items.length - 1}
        />
      ))}
    </View>
  );
}

export default StoryChapterTimeline;
