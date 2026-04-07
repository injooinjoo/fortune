import { View } from 'react-native';

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

function WealthResult() {
  const meta = resultMetadataByKind.wealth;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="₩"
        title={meta.title}
        description="단기 수입보다 지출 정리와 수익 구조 정비가 먼저 보입니다. 작은 돈이 새지 않게 잡아두면 다음 전환점에서 체감이 커집니다."
        chips={['지출 정리', '현금 흐름', meta.paperNodeId]}
      />

      <SectionCard title="재물 점수" description="Paper F15의 첫 카드처럼 전체 흐름을 한 번에 요약합니다.">
        <MetricGrid
          items={[
            { label: '재물 점수', value: '82', note: '안정 구간 유지' },
            { label: '현금 유동성', value: '74', note: '중간 이상' },
            { label: '지출 통제력', value: '69', note: '충동구매 주의' },
            { label: '기회 포착력', value: '88', note: '협업에 강함' },
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '이번 주에 할 일',
          doItems: [
            '고정비와 변동비를 분리해서 새는 돈을 먼저 찾기',
            '자동 적립이나 작은 수입원을 하나 더 붙이기',
            '정산, 청구, 협상을 미루지 않기',
          ],
          dontTitle: '이번 주에 피할 일',
          dontItems: [
            '감정이 앞선 단타성 지출',
            '근거 없는 레버리지 확대',
            '당장 쓰지 않는 구독 추가',
          ],
        }}
      />

      <SectionCard title="주간 머니 플로우">
        <Timeline
          items={[
            { title: '월-화', tag: '정리', body: '고정비 재검토와 결제일 정리.' },
            { title: '수-목', tag: '실행', body: '입금, 협상, 미수금 회수 처리.' },
            { title: '금-일', tag: '보류', body: '큰 지출은 하루 더 두고 판단.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="적용 팁">
        <BulletList
          items={[
            '이번 주는 수익 확대보다 돈의 빠짐을 줄이는 쪽이 우선입니다.',
            '지출을 3일만 적어도 흐름이 보입니다.',
            '협상성 연락은 금요일 전에 먼저 제안하세요.',
          ]}
        />
      </SectionCard>

      <SectionCard title="행운 포인트">
        <KeywordPills keywords={['18시', '초록색 지갑', '정리된 메모', '목요일']} />
      </SectionCard>
    </View>
  );
}

function TalentResult() {
  const meta = resultMetadataByKind.talent;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🧩"
        title={meta.title}
        description="번뜩이는 한 방보다 여러 축을 묶어 성과로 바꾸는 능력이 강합니다. 낱개 재능을 설명 가능하게 만들 때 효율이 커집니다."
        chips={['문제분석', '표현력', meta.paperNodeId]}
      />

      <SectionCard title="6축 분석">
        <StatRail
          items={[
            { label: '문제분석', value: 90, highlight: '복잡한 문제를 빠르게 구조화' },
            { label: '표현력', value: 74, highlight: '설명할수록 설득력이 올라감' },
            { label: '협업 조율', value: 86, highlight: '맥락을 연결하는 힘' },
            { label: '집중 지속력', value: 68, highlight: '짧은 몰입 반복이 맞음' },
            { label: '실행 전환', value: 79, highlight: '메모를 작업으로 바꾸는 속도' },
            { label: '학습 흡수', value: 88, highlight: '새 패턴을 빨리 익힘' },
          ]}
        />
      </SectionCard>

      <SectionCard title="재능 인사이트">
        <BulletList
          items={[
            '패턴을 발견해 흐름을 정리하는 능력이 좋습니다.',
            '복잡한 상황을 상대가 이해할 말로 바꾸는 힘이 큽니다.',
            '작업 순서를 설계할 때 재능의 배율이 커집니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="주간 개발 계획">
        <Timeline
          items={[
            { title: '1일차', tag: '정리', body: '결과물과 메모를 한 곳에 모읍니다.' },
            { title: '2-3일차', tag: '실험', body: '작은 성과 하나를 반복 구조로 만듭니다.' },
            { title: '4-5일차', tag: '공개', body: '재능을 다른 사람에게 설명해봅니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="성장 로드맵">
        <BulletList
          items={[
            '모든 재능을 넓히기보다 주력 1개를 먼저 고정하세요.',
            '포트폴리오 형태로 남겨야 다음 기회가 빨라집니다.',
            '설명하는 연습이 곧 재능의 선명도를 올립니다.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

function ExerciseResult() {
  const meta = resultMetadataByKind.exercise;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🏃"
        title={meta.title}
        description="이번 흐름은 짧고 자주 움직이는 방식이 맞습니다. 강도를 올리는 일보다 빈도를 만드는 데 더 잘 반응합니다."
        chips={['가벼운 유산소', '회복', meta.paperNodeId]}
      />

      <SectionCard title="추천 루틴">
        <BulletList
          items={[
            '아침 10분 걷기와 관절 풀기로 몸을 깨우기',
            '점심 15분 스트레칭으로 오래 앉은 리듬 끊기',
            '저녁에는 강한 운동보다 회복 루틴에 집중하기',
          ]}
        />
      </SectionCard>

      <SectionCard title="일일 루틴">
        <Timeline
          items={[
            { title: '오전', tag: '활성', body: '물 한 컵과 가벼운 스트레칭.' },
            { title: '오후', tag: '중간점검', body: '앉은 시간을 끊고 5분씩 몸 펴주기.' },
            { title: '밤', tag: '회복', body: '어깨와 허벅지 중심으로 긴장 완화.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="주간 플랜">
        <BulletList
          items={[
            '월수금은 가볍게, 화목토는 회복 위주로 나누세요.',
            '몸 상태가 무거운 날은 강도보다 시간을 줄이세요.',
            '운동 기록은 숫자보다 느낌을 적는 편이 더 좋습니다.',
          ]}
        />
      </SectionCard>

      <DoDontPair
        data={{
          doTitle: '권장',
          doItems: [
            '세트 수보다 자세와 호흡을 먼저 확인하기',
            '운동 전후 수분과 전해질 보충하기',
          ],
          dontTitle: '주의',
          dontItems: [
            '통증이 있는데도 강도를 올리는 것',
            '컨디션이 떨어졌을 때 몰아서 하는 것',
          ],
        }}
      />

      <SectionCard title="영양 가이드">
        <BulletList
          items={[
            '단백질은 하루에 나눠 먹는 편이 좋습니다.',
            '운동 후 회복 식사는 과식보다 균형이 중요합니다.',
            '오늘은 카페인보다 수분과 수면이 더 중요합니다.',
          ]}
        />
      </SectionCard>
    </View>
  );
}

function TarotResult() {
  const meta = resultMetadataByKind.tarot;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🃏"
        title={meta.title}
        description="질문을 구체화할수록 카드의 메시지가 선명해집니다. 감정 해석보다 상황 해석이 먼저 필요한 날입니다."
        chips={['스프레드', '시간축', meta.paperNodeId]}
      />

      <SectionCard title="스프레드">
        <MetricGrid
          items={[
            { label: '과거 카드', value: '완드 4', note: '안정된 기반' },
            { label: '현재 카드', value: '펜타클 7', note: '기다림과 점검' },
            { label: '미래 카드', value: '소드 2', note: '선택 전 균형' },
            { label: '조언 카드', value: '별', note: '희망과 회복' },
          ]}
        />
      </SectionCard>

      <SectionCard title="시간축 해석">
        <Timeline
          items={[
            { title: '지금', tag: '현재', body: '선택지를 한 번 더 정리해야 합니다.' },
            { title: '1-2주', tag: '가까운 미래', body: '결론보다 신호가 먼저 옵니다.' },
            { title: '한 달', tag: '다음 흐름', body: '결과보다 방향성이 중요해집니다.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="총평">
        <InsetQuote text="지금의 카드는 멈춤이 아니라 정렬을 말합니다. 바깥보다 안쪽 질문을 먼저 정리하세요." />
      </SectionCard>

      <SectionCard title="가이드">
        <BulletList
          items={[
            '비교할 선택지가 있으면 먼저 버릴 기준을 세우세요.',
            '카드가 비슷해 보여도 역할은 다릅니다.',
            '24시간 뒤 다시 읽으면 해석이 더 좋아집니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="테마 요약">
        <KeywordPills keywords={['정렬', '희망', '선택', '균형']} />
      </SectionCard>
    </View>
  );
}

function GameEnhanceResult() {
  const meta = resultMetadataByKind['game-enhance'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🎮"
        title={meta.title}
        description="무작정 누르기보다 타이밍을 보는 쪽이 맞습니다. 강화 의식은 짧게, 판단은 냉정하게 가져가야 손실이 줄어듭니다."
        chips={['타이밍', '의식', meta.paperNodeId]}
      />

      <SectionCard title="강화 스탯">
        <MetricGrid
          items={[
            { label: '공격력', value: '84', note: '밀어붙이는 힘 좋음' },
            { label: '방어력', value: '71', note: '보강 필요' },
            { label: '행운', value: '88', note: '좋은 판이 들어옴' },
            { label: '드롭률', value: '77', note: '보상 기대치 중상' },
          ]}
        />
      </SectionCard>

      <SectionCard title="시간대 분석">
        <MetricGrid
          items={[
            { label: '골든타임', value: '21:00', note: '집중도 상승' },
            { label: '위험시간', value: '00:30', note: '연속 시도는 비효율적' },
          ]}
        />
      </SectionCard>

      <SectionCard title="강화 의식">
        <BulletList
          items={[
            '시작 전에 목표를 1줄로 적고 눌러야 합니다.',
            '실패 후 즉시 재도전보다 잠시 쉬는 편이 좋습니다.',
            '성공 로그를 남기면 다음 타이밍이 더 잘 보입니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="로드맵">
        <Timeline
          items={[
            { title: '1단계', tag: '준비', body: '자원과 손실 한도 확인.' },
            { title: '2단계', tag: '실행', body: '조건이 맞을 때만 짧게 진입.' },
            { title: '3단계', tag: '정산', body: '결과를 기록하고 보류.' },
          ]}
        />
      </SectionCard>

      <SectionCard title="한 줄 조언">
        <InsetQuote text="오늘은 한 번에 크게 가는 날이 아니라, 맞는 판만 기다렸다가 잡는 날입니다." />
      </SectionCard>
    </View>
  );
}

function OotdEvaluationResult() {
  const meta = resultMetadataByKind['ootd-evaluation'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="👗"
        title={meta.title}
        description="전체 실루엣은 안정적이고, 포인트 하나만 더 살리면 인상이 훨씬 선명해집니다. 이번 결과는 TPO와 컬러 밸런스를 기준으로 보면 좋습니다."
        chips={['TPO', '컬러 밸런스', meta.paperNodeId]}
      />

      <SectionCard title="스타일 점수">
        <MetricGrid
          items={[
            { label: '전체 점수', value: '86', note: '무난하게 강함' },
            { label: '컬러', value: '79', note: '톤은 안정적' },
            { label: '핏', value: '88', note: '실루엣이 살아남' },
            { label: '완성도', value: '81', note: '포인트만 더하면 상승' },
          ]}
        />
      </SectionCard>

      <SectionCard title="카테고리 레일">
        <StatRail
          items={[
            { label: '상의', value: 84, highlight: '기본 아이템이 안정적으로 받쳐줌' },
            { label: '하의', value: 77, highlight: '비율은 좋지만 변주 여지 있음' },
            { label: '아우터', value: 90, highlight: '전체 분위기를 강하게 만듦' },
            { label: '액세서리', value: 68, highlight: '포인트를 더 줄 수 있음' },
          ]}
        />
      </SectionCard>

      <SectionCard title="TPO 피드백">
        <BulletList
          items={[
            '출근용으로는 충분히 단정하고, 데이트용으로는 한 끗이 부족합니다.',
            '낮보다 밤에 더 잘 보이는 조합입니다.',
            '사진보다 실물에서 더 강한 스타일입니다.',
          ]}
        />
      </SectionCard>

      <SectionCard title="추천 아이템">
        <BulletList
          items={[
            '포인트 목걸이 하나로 목선 비율을 더 정리하기',
            '톤온톤 가방으로 전체 룩의 고급감 올리기',
            '신발은 광택보다 실루엣 정리에 집중하기',
          ]}
        />
      </SectionCard>

      <SectionCard title="셀럽 매치">
        <MetricGrid
          items={[
            { label: '매치 이미지', value: '세련된 미니멀', note: '깔끔한 선이 강점' },
            { label: '매치 포인트', value: '차분한 자신감', note: '과하지 않은 존재감' },
          ]}
        />
      </SectionCard>

      <SectionCard title="스타일 키워드">
        <KeywordPills keywords={['미니멀', '정돈', '선명한 비율', 'TPO 적합']} />
      </SectionCard>
    </View>
  );
}

export const ResultBatchD = {
  WealthResult,
  TalentResult,
  ExerciseResult,
  TarotResult,
  GameEnhanceResult,
  OotdEvaluationResult,
};
