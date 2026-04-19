import { useState, type ReactNode } from 'react';

import { router } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../../src/components/app-text';
import { OnboardingShell } from '../../src/components/onboarding-shell';
import { ToneSlider } from '../../src/components/tone-slider';
import { fortuneTheme } from '../../src/lib/theme';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

export default function ToneStep() {
  const { data, update } = useOnboardingFlow();
  const [tone, setTone] = useState(data.tone);

  return (
    <OnboardingShell
      step={5}
      total={6}
      title="어떤 말투가 좋으세요?"
      caption="아무 때나 설정에서 바꿀 수 있어요"
      onBack={() => router.back()}
      onNext={() => {
        update({ tone });
        router.push('/onboarding/topics');
      }}
    >
      <View
        style={{
          gap: fortuneTheme.spacing.xl,
          paddingTop: fortuneTheme.spacing.lg,
        }}
      >
        <Group label="말투">
          <ToneSlider
            leftLabel="존댓말"
            rightLabel="반말"
            value={tone.formality}
            onChange={(v) => setTone({ ...tone, formality: v })}
          />
        </Group>
        <Group label="온도">
          <ToneSlider
            leftLabel="따뜻하게"
            rightLabel="직설적으로"
            value={tone.warmth}
            onChange={(v) => setTone({ ...tone, warmth: v })}
          />
        </Group>
        <Group label="길이">
          <ToneSlider
            leftLabel="짧게"
            rightLabel="길게"
            value={tone.length}
            onChange={(v) => setTone({ ...tone, length: v })}
          />
        </Group>
      </View>
    </OnboardingShell>
  );
}

function Group({ label, children }: { label: string; children: ReactNode }) {
  return (
    <View>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.textSecondary}
        style={{
          letterSpacing: 1.2,
          marginBottom: fortuneTheme.spacing.sm,
          fontWeight: '600',
        }}
      >
        {label}
      </AppText>
      {children}
    </View>
  );
}
