/**
 * GalleryGrid — 전체 위젯 카탈로그.
 * 4 섹션 × (SMALL 8 + MEDIUM 6 + LARGE 2 + LOCK 5) = 21 item.
 * 원본: Ondo Widgets.html Gallery().
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  ConstellationMedium,
  ConstellationSmall,
  DailyFortuneLarge,
  DailyFortuneMedium,
  DailyFortuneSmall,
  DreamSmall,
  HealthSmall,
  LoveSmall,
  LuckyItemSmall,
  TarotMedium,
  TarotSmall,
  WealthSmall,
  WeeklyMedium,
} from '../fortune-widgets';
import {
  LockConstellationCircle,
  LockFortuneRect,
  LockScoreCircle,
  LockTarotRect,
  LockUnreadCircle,
} from '../lock-widgets';
import { WIDGET_COLORS } from '../primitives';
import {
  RecommendationMedium,
  StoryPreviewSmall,
  TarotDrawLarge,
  UnreadMedium,
} from '../story-widgets';

export function GalleryGrid() {
  return (
    <View style={{ paddingHorizontal: 24, paddingBottom: 80 }}>
      <AppText
        color={WIDGET_COLORS.whiteDim}
        style={{
          fontSize: 10,
          fontWeight: '700',
          letterSpacing: 2,
          textTransform: 'uppercase',
          marginBottom: 6,
        }}
      >
        Widget Catalog
      </AppText>
      <AppText
        color={WIDGET_COLORS.amber}
        style={{
          fontFamily: 'ZenSerif',
          fontSize: 22,
          fontWeight: '700',
          letterSpacing: 0.3,
          marginBottom: 4,
        }}
      >
        모든 사이즈 · 모든 주제
      </AppText>
      <AppText
        color="rgba(245,246,251,0.55)"
        style={{ fontSize: 12, lineHeight: 18, marginBottom: 32 }}
      >
        Ondo의 운세·스토리 위젯을 iOS의 모든 사이즈에 맞춰 설계했어요.{'\n'}
        다크 모드 네이티브, 하나의 강조색만 살린 미니멀한 구성.
      </AppText>

      <Section title="호기심 · 운세 위젯">
        <GalleryItem label="오늘의 운세" size="SMALL · 155×155">
          <DailyFortuneSmall />
        </GalleryItem>
        <GalleryItem label="타로 한 장" size="SMALL · 155×155">
          <TarotSmall />
        </GalleryItem>
        <GalleryItem label="별자리 운세" size="SMALL · 155×155">
          <ConstellationSmall />
        </GalleryItem>
        <GalleryItem label="연애운" size="SMALL · 155×155">
          <LoveSmall />
        </GalleryItem>
        <GalleryItem label="재물운" size="SMALL · 155×155">
          <WealthSmall />
        </GalleryItem>
        <GalleryItem label="건강운" size="SMALL · 155×155">
          <HealthSmall />
        </GalleryItem>
        <GalleryItem label="럭키 아이템" size="SMALL · 155×155">
          <LuckyItemSmall />
        </GalleryItem>
        <GalleryItem label="꿈 해몽 (밤)" size="SMALL · 155×155">
          <DreamSmall />
        </GalleryItem>
        <GalleryItem label="스토리 프리뷰" size="SMALL · 155×155">
          <StoryPreviewSmall />
        </GalleryItem>
      </Section>

      <Section title="미디움 · 정보 밀도">
        <GalleryItem label="오늘의 운세 · 4운" size="MEDIUM · 330×155">
          <DailyFortuneMedium />
        </GalleryItem>
        <GalleryItem label="타로 · 리딩" size="MEDIUM · 330×155">
          <TarotMedium />
        </GalleryItem>
        <GalleryItem label="별자리 · 리딩" size="MEDIUM · 330×155">
          <ConstellationMedium />
        </GalleryItem>
        <GalleryItem label="주간 운세" size="MEDIUM · 330×155">
          <WeeklyMedium />
        </GalleryItem>
        <GalleryItem label="안 읽은 메시지" size="MEDIUM · 330×155">
          <UnreadMedium />
        </GalleryItem>
        <GalleryItem label="추천 캐릭터" size="MEDIUM · 330×155">
          <RecommendationMedium />
        </GalleryItem>
      </Section>

      <Section title="라지 · 몰입형">
        <GalleryItem label="오늘의 운세 · 풀뷰" size="LARGE · 330×330">
          <DailyFortuneLarge />
        </GalleryItem>
        <GalleryItem label="타로 뽑기 (인터랙티브)" size="LARGE · 330×330">
          <TarotDrawLarge />
        </GalleryItem>
      </Section>

      <Section title="잠금화면 · Lock Screen">
        <GalleryItem label="운세 점수" size="CIRCULAR · 58×58">
          <LockScoreCircle />
        </GalleryItem>
        <GalleryItem label="별자리 순위" size="CIRCULAR · 58×58">
          <LockConstellationCircle />
        </GalleryItem>
        <GalleryItem label="안읽음 뱃지" size="CIRCULAR · 58×58">
          <LockUnreadCircle />
        </GalleryItem>
        <GalleryItem label="오늘의 운세" size="RECTANGULAR · 158×72">
          <LockFortuneRect />
        </GalleryItem>
        <GalleryItem label="오늘의 카드" size="RECTANGULAR · 158×72">
          <LockTarotRect />
        </GalleryItem>
      </Section>
    </View>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <View style={{ marginTop: 32 }}>
      <AppText
        color="rgba(245,246,251,0.7)"
        style={{
          fontSize: 13,
          fontWeight: '700',
          letterSpacing: 0.3,
          marginBottom: 16,
        }}
      >
        {title}
      </AppText>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 24 }}>
        {children}
      </View>
    </View>
  );
}

function GalleryItem({
  label,
  size,
  children,
}: {
  label: string;
  size: string;
  children: ReactNode;
}) {
  return (
    <View style={{ gap: 4 }}>
      {children}
      <AppText
        color={WIDGET_COLORS.textBright}
        style={{ fontSize: 13, fontWeight: '700', marginTop: 4 }}
      >
        {label}
      </AppText>
      <AppText
        color={WIDGET_COLORS.whiteDim}
        style={{ fontSize: 10, fontFamily: 'System' }}
      >
        {size}
      </AppText>
    </View>
  );
}
