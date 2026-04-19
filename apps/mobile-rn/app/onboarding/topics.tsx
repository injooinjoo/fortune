import { useState } from 'react';

import { router } from 'expo-router';
import { Alert, View } from 'react-native';

import { OnboardingShell } from '../../src/components/onboarding-shell';
import { SelectableChip } from '../../src/components/selectable-chip';
import { captureError } from '../../src/lib/error-reporting';
import { fortuneTheme } from '../../src/lib/theme';
import { useAppBootstrap } from '../../src/providers/app-bootstrap-provider';
import { useMobileAppState } from '../../src/providers/mobile-app-state-provider';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

const TOPICS: readonly string[] = [
  '일상',
  '감정',
  '연애',
  '친구관계',
  '가족',
  '일/커리어',
  '진로 고민',
  '자기이해',
  '취미',
  '스트레스',
  '불안',
  '수면',
  '건강',
  '운세',
  '사주',
  '타로',
];

export default function TopicsStep() {
  const { data, update } = useOnboardingFlow();
  const { updateOnboardingProgress, completeOnboarding } = useAppBootstrap();
  const { saveProfile } = useMobileAppState();
  const [selected, setSelected] = useState<string[]>(data.topics);
  const [finishing, setFinishing] = useState(false);

  const toggle = (t: string) => {
    setSelected((current) =>
      current.includes(t) ? current.filter((x) => x !== t) : [...current, t],
    );
  };

  const handleFinish = async () => {
    // Final step — flush the in-memory onboarding flow into production
    // MobileAppState.profile so /chat and fortune surfaces see it, mark every
    // onboarding gate complete so ChatScreen stops rendering the gate card,
    // then route to /chat where the user picks a real character from the list.
    setFinishing(true);
    try {
      update({ topics: selected });
      const birthDate = data.birth
        ? `${data.birth.y}-${data.birth.m.padStart(2, '0')}-${data.birth.d.padStart(2, '0')}`
        : '';
      await saveProfile({
        displayName: data.name.trim(),
        birthDate,
        mbti: data.mbti ?? '',
        interestIds: selected,
      });
      await updateOnboardingProgress({
        birthCompleted: birthDate.length > 0,
        interestCompleted: selected.length > 0,
      });
      await completeOnboarding();
      router.replace('/chat');
    } catch (error) {
      await captureError(error, { surface: 'onboarding:topics:finish' });
      Alert.alert('설정 저장 실패', '잠시 후 다시 시도해 주세요.');
      setFinishing(false);
    }
  };

  return (
    <OnboardingShell
      step={6}
      total={6}
      title={'어떤 이야기를\n나누고 싶으세요?'}
      caption="여러 개 골라도 돼요. 나중에 바뀌어도 괜찮아요"
      onBack={() => router.back()}
      onNext={() => void handleFinish()}
      nextLabel="시작하기"
      nextDisabled={selected.length === 0}
      nextLoading={finishing}
    >
      <View
        style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          gap: fortuneTheme.spacing.sm,
          paddingTop: fortuneTheme.spacing.lg,
        }}
      >
        {TOPICS.map((t) => (
          <SelectableChip
            key={t}
            label={t}
            selected={selected.includes(t)}
            onPress={() => toggle(t)}
          />
        ))}
      </View>
    </OnboardingShell>
  );
}
