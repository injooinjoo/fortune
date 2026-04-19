import { useState } from 'react';

import { router } from 'expo-router';
import { View } from 'react-native';

import { DateInput, type DateInputValue } from '../../src/components/date-input';
import { OnboardingShell } from '../../src/components/onboarding-shell';
import { fortuneTheme } from '../../src/lib/theme';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

export default function BirthStep() {
  const { data, update } = useOnboardingFlow();
  const [birth, setBirth] = useState<DateInputValue>(
    data.birth ?? { y: '', m: '', d: '' },
  );

  const valid =
    birth.y.length === 4 && birth.m.length >= 1 && birth.d.length >= 1;

  const goNext = () => router.push('/onboarding/mbti');

  return (
    <OnboardingShell
      step={2}
      total={6}
      title="생년월일을 알려주세요"
      caption="사주·운세 해석과 대화 톤에 참고해요"
      onBack={() => router.back()}
      onSkip={goNext}
      onNext={() => {
        if (valid) update({ birth });
        goNext();
      }}
      nextDisabled={!valid}
    >
      <View style={{ paddingTop: fortuneTheme.spacing.lg }}>
        <DateInput value={birth} onChange={setBirth} autoFocus />
      </View>
    </OnboardingShell>
  );
}
