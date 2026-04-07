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
  Timeline,
} from '../primitives';

function CareerResult() {
  const meta = resultMetadataByKind.career;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="💼"
        title={meta.title}
        description="이번 커리어 흐름은 확장보다 정렬이 먼저입니다. 잘 맞는 역할과 집중해야 할 기술을 먼저 고르면 속도가 붙습니다."
        chips={['강점', '역할 정렬', '집중 포인트']}
      />

      <SectionCard title="커리어 요약">
        <MetricGrid
          items={[
            { label: '현재 단계', value: '정비기', note: '기반을 다지는 구간' },
            { label: '역할 적합도', value: '88', note: '책임감 있는 포지션에 강함' },
            { label: '확장 운', value: '73', note: '무리한 확장은 보류' },
            { label: '집중 포인트', value: '우선순위', note: '분산 금지' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '강점',
          doItems: [
            '문제를 구조화해서 말할 때 신뢰가 빠르게 쌓입니다.',
            '역할 범위를 명확히 잡으면 추진력이 커집니다.',
          ],
          dontTitle: '리스크',
          dontItems: [
            '잘하는 일을 너무 많이 동시에 맡으면 집중력이 떨어집니다.',
            '당장 눈에 띄는 제안보다 오래 남는 구조를 먼저 봐야 합니다.',
          ],
        }}
      />

      <SectionCard title="역할 / 스킬 페어">
        <MetricGrid
          items={[
          { label: '잘 맞는 역할', value: '기획/리드', note: '조율과 정리에 강함' },
          { label: '바로 키울 스킬', value: '우선순위 설계', note: '성과 전환 속도 상승' },
        ]}
        />
      </SectionCard>

      <SectionCard title="성장 타이밍">
        <Timeline
          items={[
            { title: '이번 주', tag: '정렬', body: '해야 할 일과 하지 않을 일을 먼저 나눕니다.' },
            { title: '다음 2주', tag: '실행', body: '작은 성과를 보여주는 결과물을 하나 만듭니다.' },
            { title: '다음 달', tag: '확장', body: '정리된 포지션으로 제안하거나 지원하기 좋습니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="주간 아웃룩">
        <InsetQuote text="이번 커리어 운은 새로운 시작보다 '정리된 신뢰'를 쌓는 쪽에서 크게 열립니다." />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['월요일 오전', '정리된 문서', '차분한 블루', '짧은 보고']} />
      </SectionCard>
    </View>
  );
}

function LoveResult() {
  const meta = resultMetadataByKind.love;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="💗"
        title={meta.title}
        description="연애운은 밝지만, 감정보다 리듬을 맞추는 편이 더 중요합니다. 표현은 부드럽게, 기준은 분명하게 가야 합니다."
        chips={['감정 온도', '관계 타이밍', '표현 포인트']}
      />

      <SectionCard title="연애 에너지">
        <MetricGrid
          items={[
            { label: '설렘 지수', value: '89', note: '분위기 형성이 좋음' },
            { label: '솔직함', value: '73', note: '말을 고르는 편이 안전' },
            { label: '타이밍 운', value: '85', note: '너무 늦지 않게 표현' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '지금 좋은 흐름',
          doItems: [
            '짧고 가벼운 제안이 오히려 더 큰 반응을 부릅니다.',
            '상대의 반응을 기다릴 때는 템포를 너무 끌지 않는 편이 좋습니다.',
          ],
          dontTitle: '지금 피할 흐름',
          dontItems: [
            '감정 확인을 지나치게 반복하는 것',
            '확답을 급하게 받으려는 태도',
          ],
        }}
      />

      <SectionCard title="관계 타임라인">
        <Timeline
          items={[
            { title: '초반', tag: '온도', body: '분위기는 빠르게 데워지지만, 속도 조절이 중요합니다.' },
            { title: '중반', tag: '대화', body: '서로의 기준을 말할수록 관계가 안정됩니다.' },
            { title: '후반', tag: '확인', body: '확답보다 일관된 태도가 더 큰 신뢰를 만듭니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 그리드">
        <MetricGrid
          items={[
            { label: '행운 시간', value: '20:30', note: '답장이 잘 오는 편' },
            { label: '행운 장소', value: '조용한 카페', note: '시선 분산 적음' },
            { label: '행운 컬러', value: '로즈 베이지', note: '부드러운 인상' },
            { label: '행운 액션', value: '짧은 안부', note: '가볍게 시작' },
          ]}
        />
      </SectionCard>
    </View>
  );
}

function HealthResult() {
  const meta = resultMetadataByKind.health;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🌿"
        title={meta.title}
        description="큰 이상보다 미세한 피로가 누적되기 쉬운 날입니다. 오늘의 건강운은 컨디션 조절과 회복 루틴에 강하게 반응합니다."
        chips={['웰니스', '회복 루틴', '컨디션 조절']}
      />

      <SectionCard title="건강 점수">
        <MetricGrid
          items={[
            { label: '전체 컨디션', value: '78', note: '무난하지만 과로 주의' },
            { label: '집중력', value: '81', note: '오전 강세' },
            { label: '수면 회복', value: '66', note: '저녁 루틴 보강 필요' },
            { label: '스트레스 지수', value: '59', note: '쌓이기 전에 빼야 함' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '웰니스 플랜',
          doItems: [
            '한 번 길게 쉬기보다 짧은 회복을 여러 번 넣으세요.',
            '수분과 식사 간격을 일정하게 유지하면 오후 피로가 덜합니다.',
          ],
          dontTitle: '경고 포인트',
          dontItems: [
            '점심 이후 카페인 과다',
            '어깨, 목이 뻐근한 상태로 오래 앉아 있는 것',
          ],
        }}
      />

      <SectionCard title="주의 카드">
        <InsetQuote text="오늘은 참는다고 버티는 날이 아닙니다. 피로 신호가 느껴지면 일정을 조금 줄이는 편이 결과적으로 더 좋습니다." />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['미지근한 물', '스트레칭 5분', '햇빛 10분', '저녁 샤워']} />
      </SectionCard>
    </View>
  );
}

function CoachingResult() {
  const meta = resultMetadataByKind.coaching;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🎯"
        title={meta.title}
        description="이번 코칭운은 동기부여보다 실행 구조에 반응합니다. 해야 할 일을 작게 쪼갤수록 결과가 빨라집니다."
        chips={['실행 계획', '작은 승리', '오늘의 동력']}
      />

      <SectionCard title="코칭 점수">
        <MetricGrid
          items={[
            { label: '실행력', value: '87', note: '시작 버튼이 빠름' },
            { label: '지속력', value: '72', note: '중간 이탈을 경계' },
            { label: '복구력', value: '84', note: '한 번 흔들려도 복귀 빠름' },
          ]}
        />
      </SectionCard>

      <SectionCard title="3단계 액션 플랜">
        <Timeline
          items={[
            { title: '1단계', tag: '정의', body: '오늘 끝낼 목표를 한 문장으로 적습니다.' },
            { title: '2단계', tag: '분해', body: '10분 안에 시작할 수 있을 만큼 작게 쪼갭니다.' },
            { title: '3단계', tag: '확인', body: '마무리 후 바로 다음 행동을 하나 예약합니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="코칭 스탯">
        <MetricGrid
          items={[
            { label: '집중도', value: '83', note: '짧은 몰입에 강함' },
            { label: '우선순위', value: '78', note: '기준만 세우면 빨라짐' },
            { label: '피드백 수용', value: '90', note: '수정이 성과로 이어짐' },
          ]}
        />
      </SectionCard>

      <SectionCard title="코칭 메모">
        <BulletList
          items={[
            '오늘은 의욕보다 순서가 중요합니다.',
            '완벽하게 시작하려 하지 말고 70% 상태로 바로 시작하세요.',
            '작은 체크 표시가 동력을 유지해 줍니다.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

export const ResultBatchB = {
  CareerResult,
  LoveResult,
  HealthResult,
  CoachingResult,
};
