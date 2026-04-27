/**
 * /widgets — Ondo iPhone Widgets Showcase.
 *
 * 헤더 타이포 → iPhone 3대 (HomeA / Lock / HomeB) → 전체 Gallery.
 * Live Activity는 HomeB iPhone에 Dynamic Island로 주입.
 */

import { ScrollView, View } from 'react-native';

import { AppText } from '../../src/components/app-text';
import {
  GalleryGrid,
  HomeScreenA,
  HomeScreenB,
  IPhoneFrame,
  LiveActivityCompact,
  LockScreen,
} from '../../src/features/ios-widgets';

export default function WidgetsShowcaseScreen() {
  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: '#0A0A0F' }}
      contentContainerStyle={{ paddingBottom: 80 }}
    >
      {/* Header */}
      <View
        style={{
          paddingHorizontal: 24,
          paddingTop: 32,
          paddingBottom: 28,
          alignItems: 'center',
        }}
      >
        <AppText
          color="rgba(245,246,251,0.35)"
          style={{
            fontSize: 11,
            fontWeight: '700',
            letterSpacing: 2,
            textTransform: 'uppercase',
          }}
        >
          Ondo · iPhone Widget Explorations
        </AppText>
        <AppText
          color="#F5F6FB"
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 28,
            lineHeight: 38,
            fontWeight: '700',
            marginTop: 12,
            textAlign: 'center',
          }}
        >
          호기심과 이야기,{'\n'}손끝에 가까이
        </AppText>
        <AppText
          color="rgba(245,246,251,0.55)"
          style={{
            fontSize: 13,
            lineHeight: 19,
            marginTop: 10,
            textAlign: 'center',
          }}
        >
          하루의 운세, 오늘의 카드, 스토리 캐릭터와의 대화{'\n'}
          — Ondo의 경험을 iPhone 위젯으로 가져왔어요.
        </AppText>
      </View>

      {/* iPhone 3대 */}
      <View style={{ paddingHorizontal: 16, gap: 40, alignItems: 'center' }}>
        <IPhonePreview
          label="홈스크린 — 운세 위주"
          description="매일 눈에 들어오는 점수·타로·4운과 안 읽은 대화"
        >
          <IPhoneFrame>
            <HomeScreenA />
          </IPhoneFrame>
        </IPhonePreview>

        <IPhonePreview
          label="잠금화면"
          description="점수·별자리·안읽음 + 오늘의 운세 / 타로 2단"
        >
          <IPhoneFrame showHomeIndicator>
            <LockScreen />
          </IPhoneFrame>
        </IPhonePreview>

        <IPhonePreview
          label="홈스크린 — 이야기 위주"
          description="캐릭터 추천 + Live Activity (Dynamic Island)"
        >
          <IPhoneFrame liveActivity={<LiveActivityCompact />}>
            <HomeScreenB />
          </IPhoneFrame>
        </IPhonePreview>
      </View>

      {/* Gallery */}
      <View style={{ marginTop: 48 }}>
        <GalleryGrid />
      </View>
    </ScrollView>
  );
}

function IPhonePreview({
  label,
  description,
  children,
}: {
  label: string;
  description: string;
  children: React.ReactNode;
}) {
  return (
    <View style={{ alignItems: 'center', gap: 10 }}>
      {children}
      <AppText
        color="#F5F6FB"
        style={{ fontSize: 13, fontWeight: '700', letterSpacing: 0.2 }}
      >
        {label}
      </AppText>
      <AppText
        color="rgba(245,246,251,0.55)"
        style={{ fontSize: 11, textAlign: 'center', maxWidth: 260 }}
      >
        {description}
      </AppText>
    </View>
  );
}
