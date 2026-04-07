import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
} from '../primitives';

function TraditionalSajuResult() {
  const meta = resultMetadataByKind['traditional-saju'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="☯️"
        title={meta.title}
        description="오행의 균형은 크게 흔들리지 않지만, 오늘은 강한 기운을 어디에 쓰는지가 더 중요합니다. 힘을 분산하지 말고 우선순위를 먼저 잡아야 합니다."
        chips={['오행 균형', '사주 포인트', meta.paperNodeId]}
      />

      <SectionCard title="사주 기둥" description="Paper F01의 4분할 사주 블록을 RN용 카드 그리드로 정리했습니다.">
        <MetricGrid
          items={[
            { label: '년주', value: '갑인', note: '기본 기질과 시작점' },
            { label: '월주', value: '정사', note: '현재 흐름과 환경' },
            { label: '일주', value: '병오', note: '핵심 에너지' },
            { label: '시주', value: '계해', note: '저녁 이후 집중력' },
          ]}
        />
      </SectionCard>

      <SectionCard title="오행 분포" description="강한 기운과 보완이 필요한 기운을 한눈에 읽는 구간입니다.">
        <StatRail
          items={[
            { label: '목', value: 82, highlight: '확장성과 시작 에너지가 좋습니다.' },
            { label: '화', value: 91, highlight: '표현력과 추진력이 강하게 나옵니다.' },
            { label: '토', value: 64, highlight: '중간 정리 역할을 의식해야 합니다.' },
            { label: '금', value: 58, highlight: '판단을 단단하게 묶는 힘은 보강 필요.' },
            { label: '수', value: 70, highlight: '휴식과 회복은 의외로 괜찮은 편입니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="핵심 포인트">
        <BulletList
          items={[
            '오늘은 강한 화 기운이 보이므로, 새로운 일을 벌이기보다 이미 시작한 일을 밀어붙이는 편이 좋습니다.',
            '토와 금이 약한 편이라 감정이 올라오면 판단이 급해질 수 있습니다.',
            '사람 앞에서 결정을 말하기 전에 메모로 한 번 더 정리하면 흔들림이 줄어듭니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="운세 포인트">
        <MetricGrid
          items={[
            { label: '일 흐름', value: '상', note: '오전부터 속도가 붙습니다.' },
            { label: '대인운', value: '중상', note: '짧고 분명한 대화가 좋음' },
            { label: '재물운', value: '중', note: '수익보다 정리가 우선' },
            { label: '회복운', value: '중상', note: '잠깐 쉬어야 운이 유지됩니다.' },
          ]}
        />
      </SectionCard>
    </View>
  );
}

function DailyCalendarResult() {
  const meta = resultMetadataByKind['daily-calendar'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🗓️"
        title={meta.title}
        description="날짜의 흐름은 차분하지만, 계절 에너지와 개인 리듬이 겹치는 순간에 운이 선명하게 보입니다. 큰 사건보다 타이밍 해석에 강한 화면입니다."
        chips={['날짜 흐름', '계절 포인트', meta.paperNodeId]}
      />

      <SectionCard title="핵심 날짜 카드">
        <MetricGrid
          items={[
            { label: '오늘', value: '4월 7일', note: '기준을 세우는 날' },
            { label: '월령', value: '상현 직전', note: '차오르는 흐름' },
            { label: '절기', value: '청명', note: '정리보다 시작' },
            { label: '권장 시간', value: '14:00', note: '일 처리가 또렷함' },
          ]}
        />
      </SectionCard>

      <SectionCard title="계절 해석" description="Paper F02의 seasonal row 구성을 카드 문장으로 유지합니다.">
        <BulletList
          items={[
            '봄의 기운이 강해 새로운 시도에 유리하지만, 과속하면 마무리가 흐려질 수 있습니다.',
            '지금은 큰 결론보다 “첫 버튼”을 누르는 선택이 더 잘 맞습니다.',
            '외부 자극이 많아도 내 루틴을 잃지 않으면 하루 전체가 안정됩니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="나이와 흐름">
        <MetricGrid
          items={[
            { label: '현재 나이 포인트', value: '전환기', note: '정리와 시작이 동시에 옴' },
            { label: '올해의 키워드', value: '리셋', note: '기준을 다시 세우는 해' },
            { label: '이번 달 톤', value: '가볍게 확장', note: '실험이 어울림' },
            { label: '이번 주 톤', value: '정렬', note: '우선순위 재배치' },
          ]}
        />
      </SectionCard>

      <SectionCard title="만세력 메모">
        <InsetQuote text="오늘은 하루를 완벽히 해석하려 하기보다, 잘 맞는 시간대를 먼저 찾는 쪽이 훨씬 실용적입니다." />
      </SectionCard>
    </View>
  );
}

function MbtiResult() {
  const meta = resultMetadataByKind.mbti;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🧠"
        title={meta.title}
        description="유형 자체보다 오늘 어떤 축이 먼저 드러나는지가 중요합니다. MBTI 결과를 행동 기준으로 번역한 화면입니다."
        chips={['행동 축', '성향 해석', meta.paperNodeId]}
      />

      <SectionCard title="오늘의 MBTI 요약">
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="displaySmall">INFJ</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            오늘은 직관과 판단 축이 더 강하게 올라옵니다. 감정 공감은 좋지만, 기준을 먼저 세우는 편이 안정적입니다.
          </AppText>
          <KeywordPills keywords={['직관', '판단', '공감', '정리']} />
        </Card>
      </SectionCard>

      <SectionCard title="성향 축">
        <StatRail
          items={[
            { label: 'E ↔ I', value: 68, highlight: '혼자 정리한 뒤 말할 때 더 정확합니다.' },
            { label: 'S ↔ N', value: 86, highlight: '맥락과 미래 흐름을 먼저 읽습니다.' },
            { label: 'T ↔ F', value: 61, highlight: '감정 공감이 크지만 오늘은 기준이 필요합니다.' },
            { label: 'J ↔ P', value: 80, highlight: '정리된 계획이 있을수록 힘이 납니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <MetricGrid
          items={[
            { label: '대화 운', value: '87', note: '짧고 깊은 대화에 강함' },
            { label: '집중 운', value: '91', note: '혼자 정리할 때 상승' },
            { label: '협업 운', value: '70', note: '역할 분리가 있어야 편함' },
            { label: '회복 운', value: '75', note: '저녁 고요한 시간이 도움' },
          ]}
        />
      </SectionCard>

      <SectionCard title="주의 문장">
        <InsetQuote text="상대의 감정을 먼저 읽는 습관 때문에 내 결정을 미루지 않도록 주의하세요. 오늘은 ‘내 기준 한 줄’을 먼저 적는 게 중요합니다." />
      </SectionCard>
    </View>
  );
}

function BloodTypeResult() {
  const meta = resultMetadataByKind['blood-type'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🩸"
        title={meta.title}
        description="혈액형 성향은 오늘의 분위기와 만나면 더 현실적인 조언으로 바뀝니다. 프로필형 결과 구조를 RN으로 옮긴 화면입니다."
        chips={['성향', '궁합', meta.paperNodeId]}
      />

      <SectionCard title="혈액형 정보">
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
          <Card style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
              타입
            </AppText>
            <AppText variant="displaySmall">A형</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              꼼꼼하고 기준을 세우는 데 강합니다.
            </AppText>
          </Card>
          <Card style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
              오늘의 키워드
            </AppText>
            <KeywordPills keywords={['정리', '배려', '조심스런 추진']} />
          </Card>
        </View>
      </SectionCard>

      <SectionCard title="궁합 포인트">
        <MetricGrid
          items={[
            { label: '잘 맞는 타입', value: 'O형', note: '속도와 안정의 균형' },
            { label: '조심할 타입', value: 'B형', note: '리듬 차이가 큼' },
          ]}
        />
      </SectionCard>

      <SectionCard title="추천 행동">
        <BulletList
          items={[
            '오늘은 먼저 정리한 사람이 분위기를 주도합니다.',
            '상대를 배려하되, 기준 없는 양보는 하지 않는 편이 좋습니다.',
            '작은 약속을 지키는 행동이 신뢰를 크게 올립니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['연한 네이비', '메모 앱', '오전 11시', '정돈된 책상']} />
      </SectionCard>
    </View>
  );
}

function ZodiacAnimalResult() {
  const meta = resultMetadataByKind['zodiac-animal'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🐉"
        title={meta.title}
        description="띠의 기본 기질과 오늘의 운세가 겹치며, 사람 관계와 타이밍 해석이 더 도드라지는 화면입니다."
        chips={['띠별 흐름', '궁합', meta.paperNodeId]}
      />

      <SectionCard title="오늘의 흐름">
        <StatRail
          items={[
            { label: '대인운', value: 88, highlight: '사람 사이에서 존재감이 커집니다.' },
            { label: '실행운', value: 79, highlight: '시작은 좋지만 마무리를 의식해야 합니다.' },
            { label: '감정운', value: 67, highlight: '과한 해석은 피하는 게 좋습니다.' },
            { label: '타이밍운', value: 84, highlight: '한 번 더 기다리면 더 좋습니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="궁합 메모">
        <BulletList
          items={[
            '오늘은 비슷한 속도의 사람보다, 나를 한 번 더 잡아주는 사람이 잘 맞습니다.',
            '대화가 빠르게 이어지는 상대와 궁합이 좋습니다.',
            '감정이 크게 출렁이는 상대와는 잠시 템포를 늦추세요.',
          ]}
        />
      </SectionCard>

      <SectionCard title="타이밍 팁">
        <InsetQuote text="승부를 보려면 오전보다 오후가 더 낫습니다. 말을 꺼내기 전 10초만 더 정리하면 결과가 좋아집니다." />
      </SectionCard>
    </View>
  );
}

function ConstellationResult() {
  const meta = resultMetadataByKind.constellation;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="⭐"
        title={meta.title}
        description="별자리 해석은 감정의 온도와 관계의 결을 읽는 데 강합니다. 오늘은 무드와 타이밍이 중요한 화면입니다."
        chips={['별자리', '관계 무드', meta.paperNodeId]}
      />

      <SectionCard title="별자리 포인트">
        <MetricGrid
          items={[
            { label: '별자리', value: '천칭자리', note: '균형과 조화의 결' },
            { label: '주요 행성', value: '금성', note: '관계 감각이 예민함' },
            { label: '오늘의 무드', value: '차분한 매력', note: '과하지 않게 빛남' },
            { label: '권장 리듬', value: '느리게 확실하게', note: '속도보다 여운' },
          ]}
        />
      </SectionCard>

      <SectionCard title="관계 해석">
        <BulletList
          items={[
            '지금은 센 표현보다 여지를 남기는 말이 더 잘 맞습니다.',
            '상대의 반응을 바로 해석하지 말고, 한 템포 쉬어가세요.',
            '분위기와 인상이 중요한 자리에서 좋은 운이 들어옵니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['은색 액세서리', '저녁 8시', '부드러운 향', '잔잔한 음악']} />
      </SectionCard>
    </View>
  );
}

export const ResultBatchA = {
  TraditionalSajuResult,
  DailyCalendarResult,
  MbtiResult,
  BloodTypeResult,
  ZodiacAnimalResult,
  ConstellationResult,
};
