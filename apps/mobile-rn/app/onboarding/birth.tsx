import { useState } from 'react';

import { router } from 'expo-router';
import { Alert, View } from 'react-native';

import { DateInput, type DateInputValue } from '../../src/components/date-input';
import { OnboardingShell } from '../../src/components/onboarding-shell';
import { fortuneTheme } from '../../src/lib/theme';
import { useOnboardingFlow } from '../../src/providers/onboarding-flow-provider';

// Apple 12+ 등급 + 로맨스 페르소나 대화 기능 + 개인정보 수집 (생년월일/사주)
// 기준으로 최소 연령 14세 설정. 한국 정보통신망법 14세 기준과 정렬. (W1)
const MIN_AGE_YEARS = 14;

function computeAgeYears(birth: DateInputValue, now: Date = new Date()): number | null {
  const y = Number.parseInt(birth.y, 10);
  const m = Number.parseInt(birth.m, 10);
  const d = Number.parseInt(birth.d, 10);
  if (!Number.isFinite(y) || !Number.isFinite(m) || !Number.isFinite(d)) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31 || y < 1900 || y > now.getFullYear()) {
    return null;
  }
  let age = now.getFullYear() - y;
  const hasHadBirthday =
    now.getMonth() + 1 > m ||
    (now.getMonth() + 1 === m && now.getDate() >= d);
  if (!hasHadBirthday) age -= 1;
  return age;
}

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
        if (!valid) {
          goNext();
          return;
        }
        const age = computeAgeYears(birth);
        if (age !== null && age < MIN_AGE_YEARS) {
          // 연령 미달 — 온보딩 진행 차단. (W1)
          Alert.alert(
            '이용 연령 안내',
            `온도는 만 ${MIN_AGE_YEARS}세 이상 이용할 수 있어요. 입력하신 생년월일을 다시 확인해 주세요.`,
          );
          return;
        }
        update({ birth });
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
