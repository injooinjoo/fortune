import { useState } from 'react';

import { router } from 'expo-router';
import { View } from 'react-native';

import { MBTIPicker, type MbtiType } from '../../src/components/mbti-picker';
import { OnboardingShell } from '../../src/components/onboarding-shell';
import { fortuneTheme } from '../../src/lib/theme';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

export default function MbtiStep() {
  const { data, update } = useOnboardingFlow();
  const [mbti, setMbti] = useState<MbtiType | undefined>(
    data.mbti as MbtiType | undefined,
  );

  const goNext = () => router.push('/onboarding/relationship');

  return (
    <OnboardingShell
      step={3}
      total={6}
      title="MBTI를 알려주세요"
      caption="대화 스타일을 맞추는 데 참고돼요. 모르시면 건너뛰세요"
      onBack={() => router.back()}
      onSkip={goNext}
      onNext={() => {
        if (mbti) update({ mbti });
        goNext();
      }}
    >
      <View style={{ paddingTop: fortuneTheme.spacing.lg }}>
        <MBTIPicker value={mbti} onChange={setMbti} />
      </View>
    </OnboardingShell>
  );
}
