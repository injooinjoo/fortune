import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  DoDontPair,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
} from '../primitives';

function FamilyResult() {
  const meta = resultMetadataByKind.family;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="👨‍👩‍👧‍👦"
        title={meta.title}
        description="가족 사이의 역할이 다시 정리되는 날이에요. 말보다 기준을 먼저 맞추면 편해집니다."
        chips={['세대 균형', '관계 재정렬', '대화 힌트']}
      />

      <SectionCard
        title="가족 궁합"
        description="가까운 가족 관계를 나눠 읽고, 마지막에 공통의 기준을 정리하는 구성입니다."
      >
        <StatRail
          items={[
            {
              label: '부모와의 흐름',
              value: 86,
              highlight: '감정은 짧게, 기준은 분명하게 말하는 게 좋습니다.',
            },
            {
              label: '형제/자매와의 흐름',
              value: 72,
              highlight: '비교보다 분담이 잘 맞아야 오해가 줄어듭니다.',
            },
            {
              label: '가까운 가족과의 흐름',
              value: 91,
              highlight: '작은 안부 하나가 전체 분위기를 바꾸는 날입니다.',
            },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '좋은 흐름',
          doItems: [
            '집안 일정은 먼저 공유하고 역할을 먼저 나누세요.',
            '상대가 해준 일을 문장으로 인정하면 분위기가 빨리 풀립니다.',
          ],
          dontTitle: '주의 흐름',
          dontItems: [
            '서운함을 길게 누적시키면 말 한마디가 더 커집니다.',
            '기대만 남기고 기준을 말하지 않으면 오해가 쌓입니다.',
          ],
        }}
      />

      <SectionCard title="가족 대화 팁" description="오늘은 해결보다 정렬이 먼저입니다.">
        <BulletList
          items={[
            '한 번에 긴 대화를 하기보다, 짧게 두 번 나눠서 말해보세요.',
            '감정 설명보다 역할 설명이 더 잘 먹힙니다.',
            '늦은 밤보다 점심 전이나 저녁 초입이 대화 타이밍으로 좋습니다.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

function PastLifeResult() {
  const meta = resultMetadataByKind['past-life'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🔮"
        title={meta.title}
        description="상징이 먼저 읽히고, 해석은 천천히 따라오는 날이에요. 기록을 남기면 메시지가 더 선명해집니다."
        chips={['타로 스프레드', '상징 해석', '메시지 읽기']}
      />

      <SectionCard
        title="타로 스프레드"
        description="세 장의 흐름을 먼저 보여준 뒤, 각 카드의 메시지를 이어 읽습니다."
      >
        <View
          style={{
            flexDirection: 'row',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          {[
            {
              label: '과거',
              emoji: '🌙',
              body: '내가 오래 붙잡아온 질문',
            },
            {
              label: '현재',
              emoji: '⭐',
              body: '지금 눈앞에 나타난 징후',
            },
            {
              label: '미래',
              emoji: '☀️',
              body: '다음 선택이 향할 방향',
            },
          ].map((card) => (
            <Card key={card.label} style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
                {card.label}
              </AppText>
              <AppText variant="displaySmall">{card.emoji}</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {card.body}
              </AppText>
            </Card>
          ))}
        </View>
      </SectionCard>

      <SectionCard
        title="해석 카드"
        description="세 장의 서사를 각각 읽고, 마지막에 하나의 메시지로 묶습니다."
      >
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {[
            {
              title: '첫 장 - 질문의 뿌리',
              body: '당장 흔들리는 문제보다, 그 문제를 오래 키운 습관을 먼저 봐야 합니다.',
            },
            {
              title: '둘째 장 - 현재의 징후',
              body: '지금은 사람과 상황이 동시에 움직입니다. 급하게 결론내기보다 흐름을 관찰하세요.',
            },
            {
              title: '셋째 장 - 선택의 방향',
              body: '한 번의 큰 전환보다, 작은 약속을 지키는 쪽이 운의 문을 더 잘 엽니다.',
            },
          ].map((item) => (
            <Card key={item.title} style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge">{item.title}</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {item.body}
              </AppText>
            </Card>
          ))}
        </View>
      </SectionCard>

      <SectionCard title="메시지" description="이 결과는 결론보다 해석의 여운이 중요합니다.">
        <InsetQuote text="오늘은 정답을 찾기보다, 같은 질문을 다른 말로 다시 적어보는 쪽이 훨씬 도움이 됩니다." />
      </SectionCard>
    </View>
  );
}

function WishResult() {
  const meta = resultMetadataByKind.wish;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="✨"
        title={meta.title}
        description="짧지만 확실한 성공 신호가 먼저 보이는 날이에요. 지금은 크게 바꾸기보다, 성공 확률이 높은 한 번을 잡는 게 좋습니다."
        chips={['성공 카드', '실행 지표', '오늘의 기회']}
      />

      <SectionCard title="성공 카드" description="짧고 분명한 성공 메시지부터 먼저 읽는 구성입니다.">
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="heading4">지금은 반복이 성과를 만듭니다.</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            기대치를 크게 잡기보다, 이미 잘 되는 한 가지를 2번 더 해보세요.
          </AppText>
          <KeywordPills keywords={['즉시 실행', '반복', '보상 감각']} />
        </Card>
      </SectionCard>

      <SectionCard
        title="강화 스탯"
        description="핵심 지표를 한눈에 보고 바로 실행으로 옮기기 쉽게 정리했어요."
      >
        <MetricGrid
          items={[
            {
              label: '집중도',
              value: '84',
              note: '짧은 시간에 몰입이 잘 됩니다.',
            },
            {
              label: '도전 의지',
              value: '91',
              note: '시작 버튼을 누르는 힘이 강합니다.',
            },
            {
              label: '회복력',
              value: '76',
              note: '실패 후 다시 붙는 속도가 빠릅니다.',
            },
            {
              label: '보상 운',
              value: '88',
              note: '작은 성공이 다음 성공으로 이어집니다.',
            },
          ]}
        />
      </SectionCard>

      <SectionCard title="오늘의 포인트" description="성공 확률을 높이는 단서만 남깁니다.">
        <BulletList
          items={[
            '한 번에 모든 걸 바꾸기보다, 성공한 한 번을 다시 복제해보세요.',
            '결정 직전의 망설임은 길게 끌지 않는 편이 좋습니다.',
            '사람이 많은 자리보다, 혼자 시작하는 순간에 더 강합니다.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

function PersonalityDnaResult() {
  const meta = resultMetadataByKind['personality-dna'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🧬"
        title={meta.title}
        description="성향의 결이 더 선명해지는 날이에요. 유형보다 축을 읽어야 길이 보입니다."
        chips={['성향 축', '관계 감도', '성장 포인트']}
      />

      <SectionCard
        title="성향 스펙트럼"
        description="네 개의 성향 축을 먼저 읽고, 이어서 성향 설명과 조언을 확인할 수 있어요."
      >
        <StatRail
          items={[
            {
              label: '표현력',
              value: 78,
              highlight: '말은 짧아도 핵심은 또렷하게 전달됩니다.',
            },
            {
              label: '집중력',
              value: 69,
              highlight: '한 번 몰입하면 깊지만, 진입 준비가 필요합니다.',
            },
            {
              label: '회복력',
              value: 81,
              highlight: '흔들려도 다시 중심으로 돌아오는 속도가 빠릅니다.',
            },
            {
              label: '공감력',
              value: 88,
              highlight: '상대의 감정선을 빨리 읽는 편입니다.',
            },
          ]}
        />
      </SectionCard>

      <SectionCard
        title="성향 카드"
        description="성향을 네 개의 카드로 나눠서 한눈에 읽습니다."
      >
        <MetricGrid
          items={[
            {
              label: '표현 스타일',
              value: '선명',
              note: '애매한 말보다 정리된 문장이 강점입니다.',
            },
            {
              label: '문제 해결',
              value: '구조화',
              note: '복잡한 문제를 단계별로 정리하는 편입니다.',
            },
            {
              label: '회복 모드',
              value: '정리 후 재시작',
              note: '정리 시간이 있어야 다음 단계가 보입니다.',
            },
            {
              label: '관계 온도',
              value: '따뜻',
              note: '가까운 관계에서 배려가 크게 드러납니다.',
            },
          ]}
        />
      </SectionCard>

      <SectionCard title="오늘의 인사이트" description="오늘은 성격을 설명하는 문장보다, 쓰는 방식이 중요합니다.">
        <InsetQuote text="너무 많은 가능성을 한 번에 붙잡기보다, 가장 납득되는 한 가지를 먼저 고르는 편이 운을 잘 타게 만듭니다." />
      </SectionCard>

      <SectionCard title="궁합 메모" description="어떤 사람과 잘 맞는지보다, 어떤 상황에서 더 선명해지는지에 가깝습니다.">
        <BulletList
          items={[
            '기준이 분명한 사람과 함께할 때 실행력이 더 올라갑니다.',
            '감정이 섞인 대화에서는 결론보다 경청이 먼저 필요합니다.',
            '즉답보다 생각할 시간을 주는 편이 관계를 부드럽게 만듭니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="성장 팁" description="성향을 바꾸기보다 사용법을 바꾸는 쪽이 좋습니다.">
        <BulletList
          items={[
            '큰 결심은 짧게 적고, 작은 실행은 바로 시작하세요.',
            '정보를 모은 뒤엔 일정 시간을 정해 정리하는 습관이 좋습니다.',
            '기분이 흔들릴 땐 주변보다 먼저 환경을 정돈해보세요.',
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 포인트" description="오늘의 키워드는 정리와 재시작입니다.">
        <KeywordPills keywords={['정리', '재시작', '짧은 문장', '한 번의 확인']} />
      </SectionCard>
    </View>
  );
}

export const ResultBatchC = {
  FamilyResult,
  PastLifeResult,
  WishResult,
  PersonalityDnaResult,
};
