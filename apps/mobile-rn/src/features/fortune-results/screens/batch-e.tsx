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
  Timeline,
} from '../primitives';

function ExamResult() {
  const meta = resultMetadataByKind.exam;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="📝"
        title={meta.title}
        description="시험운은 실력보다 리듬 관리에서 점수 차이가 벌어지는 구간입니다. 막판 압축보다 실전 템포를 먼저 맞추는 편이 유리합니다."
        chips={['집중 리듬', '실전 감각', '루틴 고정']}
      />

      <SectionCard title="시험 지표">
        <MetricGrid
          items={[
            { label: '집중도', value: '91', note: '짧은 몰입 강세' },
            { label: '실전 감각', value: '84', note: '문제 전환 속도 양호' },
            { label: '회복력', value: '72', note: '쉬는 타이밍이 중요' },
            { label: '범위 정리', value: '88', note: '헷갈리는 파트 재정렬 추천' },
          ]}
        />
      </SectionCard>

      <SectionCard title="시험 타임라인">
        <Timeline
          items={[
            { title: 'D-7', tag: '정리', body: '점수 올리는 문제보다 틀리지 않을 문제를 먼저 고정합니다.' },
            { title: 'D-1', tag: '회복', body: '새 범위 추가보다 루틴 유지와 컨디션 안정이 더 중요합니다.' },
            { title: '시험 당일', tag: '실전', body: '초반 10분에 리듬을 잡고, 모르는 문제는 빠르게 넘기는 편이 좋습니다.' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '잘 맞는 전략',
          doItems: [
            '익숙한 유형부터 빠르게 풀어 감각을 끌어올리세요.',
            '실수 노트를 마지막까지 한 장으로 압축해두세요.',
          ],
          dontTitle: '피할 전략',
          dontItems: [
            '새로운 풀이법을 직전에 억지로 넣는 것',
            '불안해서 쉬는 시간 없이 계속 밀어붙이는 것',
          ],
        }}
      />
    </View>
  );
}

function CompatibilityResult() {
  const meta = resultMetadataByKind.compatibility;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="💞"
        title={meta.title}
        description="궁합운은 감정 강도보다 생활 리듬과 대화 방식에서 차이가 크게 보이는 흐름입니다. 잘 맞는 점과 조정이 필요한 점을 함께 읽어야 합니다."
        chips={['성향 매칭', '대화 온도', '생활 리듬']}
      />

      <SectionCard title="궁합 레일">
        <StatRail
          items={[
            {
              label: '성격 궁합',
              value: 88,
              highlight: '기본 결은 잘 맞고, 반응 속도도 비슷한 편입니다.',
            },
            {
              label: '연애 궁합',
              value: 82,
              highlight: '감정 표현 방식은 다르지만 기대치를 맞추면 안정적입니다.',
            },
            {
              label: '결혼 궁합',
              value: 76,
              highlight: '장기 계획은 기준을 먼저 합의해야 흔들림이 줄어듭니다.',
            },
            {
              label: '소통 궁합',
              value: 90,
              highlight: '짧고 명확한 대화에서 오히려 강점이 크게 드러납니다.',
            },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '잘 맞는 포인트',
          doItems: [
            '서로의 우선순위를 먼저 확인하면 갈등이 빠르게 줄어듭니다.',
            '가벼운 농담과 짧은 피드백이 관계 온도를 잘 유지해 줍니다.',
          ],
          dontTitle: '주의 포인트',
          dontItems: [
            '확답을 너무 빨리 요구하는 것',
            '감정 설명 없이 태도만 보고 결론을 내리는 것',
          ],
        }}
      />

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['저녁 대화', '차분한 톤', '같이 걷기', '짧은 질문']} />
      </SectionCard>
    </View>
  );
}

function BlindDateResult() {
  const meta = resultMetadataByKind['blind-date'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🌹"
        title={meta.title}
        description="소개팅운은 첫 20분의 분위기가 전체 인상을 거의 결정합니다. 무리한 매력 어필보다 편안한 리듬을 만드는 편이 훨씬 유리합니다."
        chips={['첫인상', '대화 리듬', '관심 신호']}
      />

      <SectionCard title="첫 만남 지표">
        <MetricGrid
          items={[
            { label: '첫인상', value: '89', note: '차분한 자신감 강세' },
            { label: '대화 온도', value: '84', note: '질문형 대화 유리' },
            { label: '관심도', value: '78', note: '반응은 천천히 올라옴' },
            { label: '스타일 합', value: '81', note: '과한 포인트는 피하는 편이 좋음' },
          ]}
        />
      </SectionCard>

      <SectionCard title="만남 타임라인">
        <Timeline
          items={[
            { title: '시작 10분', tag: '분위기', body: '가벼운 공감과 관찰형 질문이 긴장을 빠르게 낮춥니다.' },
            { title: '중반', tag: '대화', body: '취향보다 일상 루틴을 묻는 대화가 더 잘 이어집니다.' },
            { title: '마무리', tag: '다음', body: '확답을 받기보다 다음 연결 고리를 하나 남기는 편이 좋습니다.' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '추천 흐름',
          doItems: [
            '짧은 칭찬보다 상대 반응을 잘 듣는 태도를 먼저 보여주세요.',
            '질문을 한 번에 많이 던지지 말고 한 주제씩 이어가세요.',
          ],
          dontTitle: '피할 흐름',
          dontItems: [
            '스펙 확인처럼 느껴지는 질문을 초반에 몰아넣는 것',
            '너무 빨리 감정 결론을 내리는 것',
          ],
        }}
      />
    </View>
  );
}

function AvoidPeopleResult() {
  const meta = resultMetadataByKind['avoid-people'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🛡️"
        title={meta.title}
        description="오늘은 관계를 넓히는 것보다 에너지를 새게 만드는 유형을 빠르게 구분하는 편이 좋습니다. 피해야 할 사람보다 피해야 할 패턴을 읽는 게 중요합니다."
        chips={['경계 신호', '에너지 보호', '대응 전략']}
      />

      <SectionCard title="경계 신호">
        <BulletList
          items={[
            '지나치게 급한 친밀감을 요구하는 사람',
            '내 기준보다 자신의 속도만 밀어붙이는 사람',
            '말보다 피로감이 먼저 느껴지는 관계',
          ]}
        />
      </SectionCard>

      <SectionCard title="조심할 포인트">
        <MetricGrid
          items={[
            { label: '주의 시간', value: '오후 4시', note: '피로가 쌓여 경계가 느슨해짐' },
            { label: '주의 장소', value: '시끄러운 모임', note: '판단 분산 위험' },
            { label: '주의 색', value: '탁한 레드', note: '감정 자극이 커질 수 있음' },
            { label: '주의 숫자', value: '4', note: '반복되는 압박 신호' },
          ]}
        />
      </SectionCard>

      <SectionCard title="대응 전략">
        <BulletList
          items={[
            '감정 설명보다 일정과 기준을 먼저 말해 거리를 조절하세요.',
            '애매한 부탁은 바로 답하지 말고 시간을 두고 정리하세요.',
            '오늘은 “좋은 사람”보다 “편한 사람”을 기준으로 보세요.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

function ExLoverResult() {
  const meta = resultMetadataByKind['ex-lover'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🌙"
        title={meta.title}
        description="재회운은 감정 폭발보다 정리된 태도에서 가능성이 살아나는 흐름입니다. 다시 만날 수 있느냐보다, 만나도 괜찮은 관계가 되느냐를 먼저 봐야 합니다."
        chips={['재접점', '감정 정리', '타이밍']}
      />

      <SectionCard title="재회 레일">
        <StatRail
          items={[
            {
              label: '재회 가능성',
              value: 68,
              highlight: '감정은 남아 있지만, 방식이 정리되지 않으면 반복될 수 있습니다.',
            },
            {
              label: '감정 안정도',
              value: 74,
              highlight: '다시 연결되더라도 속도를 천천히 두는 편이 안전합니다.',
            },
            {
              label: '타이밍 적합도',
              value: 80,
              highlight: '급한 확인보다 한 번의 차분한 접점이 더 유효합니다.',
            },
          ]}
        />
      </SectionCard>

      <SectionCard title="재회 타임라인">
        <Timeline
          items={[
            { title: '지금', tag: '정리', body: '내가 다시 원하는 관계의 기준을 먼저 적어두세요.' },
            { title: '접점', tag: '대화', body: '감정 확인보다 안부와 현실 대화를 먼저 여는 편이 좋습니다.' },
            { title: '이후', tag: '판단', body: '한 번의 반응이 아니라 2~3번의 태도를 보고 판단하세요.' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '추천 행동',
          doItems: [
            '기대보다 기준을 먼저 정리하고 접근하세요.',
            '좋았던 기억보다 지금 달라진 점을 확인하세요.',
          ],
          dontTitle: '주의 행동',
          dontItems: [
            '과거 감정만으로 현재를 덮어보는 것',
            '재회를 “확답”으로만 판단하려는 것',
          ],
        }}
      />
    </View>
  );
}

function YearlyEncounterResult() {
  const meta = resultMetadataByKind['yearly-encounter'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="💫"
        title={meta.title}
        description="올해의 인연운은 한 번의 강한 이벤트보다, 반복해서 눈에 들어오는 신호에서 시작될 가능성이 큽니다. 인상과 장소, 시그널을 함께 읽는 결과예요."
        chips={['만남 장소', '시그널', '궁합 감도']}
      />

      <SectionCard title="인연 스냅샷">
        <MetricGrid
          items={[
            { label: '만남 장소', value: '단골 카페', note: '익숙한 공간에서 흐름이 열림' },
            { label: '시그널', value: '반복되는 숫자', note: '타이밍 신호가 자주 보임' },
            { label: '궁합 감도', value: '84', note: '리듬이 자연스럽게 맞는 편' },
            { label: '첫인상 톤', value: '차분한 따뜻함', note: '강한 매력보다 안정감이 먼저 옴' },
          ]}
        />
      </SectionCard>

      <SectionCard title="올해 인연 키워드">
        <KeywordPills
          keywords={[
            '우디 향',
            '라이트 브라운',
            '정리된 셔츠',
            '낮은 목소리',
          ]}
        />
      </SectionCard>

      <SectionCard title="전개 타임라인">
        <Timeline
          items={[
            { title: '초반', tag: '발견', body: '익숙한 장소에서 같은 흐름이 반복해서 눈에 들어옵니다.' },
            { title: '중반', tag: '신호', body: '작은 우연과 짧은 대화가 관계의 시작점이 됩니다.' },
            { title: '후반', tag: '확신', body: '강한 이벤트보다 일관된 태도가 신뢰를 만들 가능성이 큽니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="올해의 메모">
        <InsetQuote text="이번 인연운은 ‘한 번에 확신’보다 ‘자꾸 생각나는 사람’을 기준으로 읽는 편이 더 정확합니다." />
      </SectionCard>
    </View>
  );
}

function DecisionResult() {
  const meta = resultMetadataByKind.decision;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🤔"
        title={meta.title}
        description="의사결정 운세는 정답을 찾기보다 기준을 선명하게 세우는 쪽에 반응합니다. 오늘은 선택지 수를 줄일수록 결정력이 살아납니다."
        chips={['기준 정렬', '우선순위', '리스크 감각']}
      />

      <SectionCard title="결정 지표">
        <MetricGrid
          items={[
            { label: '명확도', value: '86', note: '기준만 세우면 빠름' },
            { label: '확신도', value: '79', note: '막판 흔들림 관리 필요' },
            { label: '리스크 감각', value: '82', note: '손실 회피 본능 양호' },
            { label: '추진력', value: '77', note: '선택 뒤 바로 실행해야 힘이 붙음' },
          ]}
        />
      </SectionCard>

      <SectionCard title="3단계 판단 흐름">
        <Timeline
          items={[
            { title: '정의', tag: '기준', body: '이번 선택에서 절대 포기 못할 기준을 한 문장으로 적습니다.' },
            { title: '분기', tag: '비교', body: '좋은 점보다 위험 신호를 먼저 비교하면 판단이 빨라집니다.' },
            { title: '확정', tag: '실행', body: '결정 후 첫 행동을 바로 예약해야 후회가 줄어듭니다.' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '지금 좋은 판단',
          doItems: [
            '선택지 셋 이상이면 두 개로 줄여 다시 보세요.',
            '한 번 결정했다면 다음 행동을 바로 연결하세요.',
          ],
          dontTitle: '지금 피할 판단',
          dontItems: [
            '모든 가능성을 다 검토하려고 끝없이 미루는 것',
            '감정이 높은 상태에서 손익 판단을 같이 하는 것',
          ],
        }}
      />
    </View>
  );
}

function DailyReviewResult() {
  const meta = resultMetadataByKind['daily-review'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="📋"
        title={meta.title}
        description="하루 리뷰는 잘한 점을 부풀리는 것보다, 남길 것과 넘길 것을 분리하는 데서 힘이 생깁니다. 오늘은 정리의 밀도가 중요한 날입니다."
        chips={['하루 정리', '감정 회수', '내일 연결']}
      />

      <SectionCard title="오늘의 요약 지표">
        <MetricGrid
          items={[
          { label: '에너지 회수', value: '81', note: '과한 소모는 줄인 편' },
          { label: '관계 만족도', value: '76', note: '짧은 피로 남음' },
          { label: '집중 완성도', value: '84', note: '핵심 한 건은 잘 끝냄' },
          { label: '회복 필요도', value: '69', note: '잠들기 전 정리 필요' },
        ]}
        />
      </SectionCard>

      <SectionCard title="오늘 남길 메모">
        <BulletList
          items={[
            '잘된 한 가지를 문장으로 남겨 내일의 기준점으로 삼으세요.',
            '감정이 남는 대화는 해석보다 사실만 먼저 적어두세요.',
            '오늘 끝낸 일과 아직 열린 일을 따로 구분하세요.',
          ]}
        />
      </SectionCard>

      <SectionCard title="내일로 넘길 것">
        <BulletList
          items={[
            '결정이 덜 선명한 일은 아침에 다시 보기',
            '피곤할 때 시작한 대화는 한 번 쉬고 이어가기',
            '오늘 떠오른 아이디어는 제목만 적고 과제화는 내일 하기',
          ]}
        />
      </SectionCard>

      <SectionCard title="마무리 메모">
        <InsetQuote text="좋은 하루 리뷰는 반성보다 정리에서 시작합니다. 오늘을 깔끔하게 접어야 내일의 에너지가 덜 새어 나갑니다." />
      </SectionCard>
    </View>
  );
}

export const ResultBatchE = {
  ExamResult,
  CompatibilityResult,
  BlindDateResult,
  AvoidPeopleResult,
  ExLoverResult,
  YearlyEncounterResult,
  DecisionResult,
  DailyReviewResult,
};
