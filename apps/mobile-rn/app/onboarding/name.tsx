import { useState } from 'react';

import { router } from 'expo-router';
import { TextInput, View } from 'react-native';

import { OnboardingShell } from '../../src/components/onboarding-shell';
import { fortuneTheme } from '../../src/lib/theme';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

export default function NameStep() {
  const { data, update } = useOnboardingFlow();
  const [name, setName] = useState(data.name);

  return (
    <OnboardingShell
      step={1}
      total={6}
      title="어떻게 불러드릴까요?"
      caption="편하게 부르실 이름이나 별명을 알려주세요"
      // No onBack — this is the first step of the onboarding flow and we
      // arrive here via router.replace() from auth-callback, so there is no
      // prior screen to go back to. OnboardingShell disables the button when
      // onBack is omitted.
      onNext={() => {
        update({ name });
        router.push('/onboarding/birth');
      }}
      nextDisabled={!name.trim()}
    >
      <View style={{ paddingTop: fortuneTheme.spacing.lg }}>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="이름 또는 별명"
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          autoFocus
          returnKeyType="done"
          style={{
            height: 56,
            backgroundColor: fortuneTheme.colors.surface,
            borderRadius: fortuneTheme.radius.md,
            borderWidth: 1,
            borderColor: fortuneTheme.colors.border,
            paddingHorizontal: fortuneTheme.spacing.lg,
            color: fortuneTheme.colors.textPrimary,
            fontSize: 16,
          }}
        />
      </View>
    </OnboardingShell>
  );
}
