import { useState } from 'react';

import { router } from 'expo-router';
import { View } from 'react-native';

import { OnboardingShell } from '../../src/components/onboarding-shell';
import { RelationshipCard } from '../../src/components/relationship-card';
import { fortuneTheme } from '../../src/lib/theme';
import {
  useOnboardingFlow,
  type RelationshipId,
} from '../../src/providers/onboarding-flow-provider';

const OPTIONS: ReadonlyArray<{
  id: RelationshipId;
  title: string;
  caption: string;
  icon: string;
}> = [
  { id: '친구', title: '친구', caption: '편하게 속마음을 나누는 친구', icon: '友' },
  { id: '선배', title: '선배', caption: '현실적인 조언을 주는 선배', icon: '兄' },
  { id: '연인', title: '연인', caption: '다정하게 곁을 지켜주는 사람', icon: '愛' },
  { id: '멘토', title: '멘토', caption: '깊게 통찰해주는 멘토', icon: '師' },
  {
    id: '전문가',
    title: '운세 전문가',
    caption: '사주·타로로 흐름을 읽어주는 사람',
    icon: '占',
  },
];

export default function RelationshipStep() {
  const { data, update } = useOnboardingFlow();
  const [selected, setSelected] = useState<RelationshipId | undefined>(
    data.relationship,
  );

  return (
    <OnboardingShell
      step={4}
      total={6}
      title={'어떤 사람과\n대화하고 싶으세요?'}
      caption="나중에 언제든 바꿀 수 있어요"
      onBack={() => router.back()}
      onNext={() => {
        if (selected) update({ relationship: selected });
        router.push('/onboarding/tone');
      }}
      nextDisabled={!selected}
    >
      <View style={{ gap: fortuneTheme.spacing.sm, paddingTop: fortuneTheme.spacing.md }}>
        {OPTIONS.map((o) => (
          <RelationshipCard
            key={o.id}
            icon={o.icon}
            title={o.title}
            caption={o.caption}
            selected={selected === o.id}
            onPress={() => setSelected(o.id)}
          />
        ))}
      </View>
    </OnboardingShell>
  );
}
