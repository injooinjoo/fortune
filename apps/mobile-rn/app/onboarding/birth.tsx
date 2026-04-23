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

/**
 * 결과:
 *   - `'invalid'`  형식/범위 이상 (ex. 미래 연도, y<1900, m>12, d>31)
 *   - number       계산된 만 나이
 *
 * age gate(W1) 에서 invalid 도 "다음 진행 불가"로 처리해 skip 우회나
 * 오입력을 차단. 이전 구현은 invalid 를 null 로 반환했고, 호출부는
 * null 일 때 그냥 통과시켜 gate 홀을 만들었음.
 */
function computeAgeYears(
  birth: DateInputValue,
  now: Date = new Date(),
): number | 'invalid' {
  const y = Number.parseInt(birth.y, 10);
  const m = Number.parseInt(birth.m, 10);
  const d = Number.parseInt(birth.d, 10);
  if (!Number.isFinite(y) || !Number.isFinite(m) || !Number.isFinite(d)) {
    return 'invalid';
  }
  if (m < 1 || m > 12 || d < 1 || d > 31) return 'invalid';
  if (y < 1900 || y > now.getFullYear()) return 'invalid';
  // Day-of-month 정확 검증 (2월 30일, 4월 31일 등 차단).
  const asDate = new Date(y, m - 1, d);
  if (
    asDate.getFullYear() !== y ||
    asDate.getMonth() !== m - 1 ||
    asDate.getDate() !== d
  ) {
    return 'invalid';
  }
  // 생일이 아직 안 지났으면 1 감산.
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

  // Skip 버튼도 age gate 적용: 생년월일을 이미 입력했는데 14세 미만이면
  // 스킵해도 서비스 이용 불가. 입력 안 한 상태에서 skip 은 그대로 허용.
  const gateAllowsAdvance = (): boolean => {
    if (!valid) return true; // 입력 자체가 없으면 skip 정상
    const age = computeAgeYears(birth);
    if (age === 'invalid') {
      Alert.alert(
        '생년월일 확인',
        '입력하신 날짜가 올바르지 않아요. 다시 확인해 주세요.',
      );
      return false;
    }
    if (age < MIN_AGE_YEARS) {
      Alert.alert(
        '이용 연령 안내',
        `온도는 만 ${MIN_AGE_YEARS}세 이상 이용할 수 있어요. 입력하신 생년월일을 다시 확인해 주세요.`,
      );
      return false;
    }
    return true;
  };

  const goNext = () => {
    if (!gateAllowsAdvance()) return;
    router.push('/onboarding/mbti');
  };

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
        if (!gateAllowsAdvance()) return;
        update({ birth });
        router.push('/onboarding/mbti');
      }}
      nextDisabled={!valid}
    >
      <View style={{ paddingTop: fortuneTheme.spacing.lg }}>
        <DateInput value={birth} onChange={setBirth} autoFocus />
      </View>
    </OnboardingShell>
  );
}
