import type { FortuneTypeId } from '@fortune/product-contracts';

import { resultMetadataByKind } from '../fortune-results/mapping';
import type { MetricTileData, ResultKind } from '../fortune-results/types';
import type { EmbeddedResultPayload } from './types';

interface EmbeddedResultSeed {
  score?: number;
  summary: string;
  metrics?: MetricTileData[];
  highlights?: string[];
  recommendations?: string[];
  warnings?: string[];
  luckyItems?: string[];
  specialTip?: string;
}

const payloadSeedByKind: Record<ResultKind, EmbeddedResultSeed> = {
  'traditional-saju': {
    score: 82,
    summary: '기본 사주 흐름은 안정적이고, 타이밍 선택이 전체 분위기를 크게 좌우하는 구간입니다.',
    metrics: [
      { label: '오행 균형', value: '82%', note: '물과 목 기운 우세' },
      { label: '전환 시기', value: '하반기', note: '속도보다 방향 정리' },
    ],
    highlights: ['강점은 꾸준함', '무리한 확장보다 순서 정리가 유리함'],
    recommendations: ['일정과 재정 결정을 분리해서 보세요', '중요 선택은 오전보다 저녁 정리에 강합니다'],
    warnings: ['감정 피로가 쌓이면 판단이 흔들릴 수 있어요'],
    specialTip: '사주는 크게 흔들리는 날을 피하는 방식으로 읽는 편이 지금은 더 정확합니다.',
  },
  'daily-calendar': {
    score: 79,
    summary: '날짜 흐름은 차분하게 올라가는 편이고, 약속보다 개인 리듬을 맞출 때 효율이 좋습니다.',
    metrics: [
      { label: '집중 리듬', value: '오후', note: '실행보다 정리 강세' },
      { label: '대인 운', value: '안정', note: '짧고 명확한 소통 추천' },
    ],
    highlights: ['오늘은 과한 확정보다 체크리스트형 진행이 유리함'],
    recommendations: ['일정 1개만 확실히 끝내세요', '중요 연락은 늦은 오후에 보내세요'],
    warnings: ['한 번에 많은 약속을 넣으면 피로가 커집니다'],
    luckyItems: ['다크 네이비', '종이 메모'],
  },
  mbti: {
    score: 86,
    summary: '기본 성향의 장점이 잘 드러나는 날이고, 감정 소비를 줄이면 집중력이 더 좋아집니다.',
    metrics: [
      { label: '에너지 축', value: '안정', note: '혼자 정리하는 시간 중요' },
      { label: '대화 적합도', value: '높음', note: '짧은 피드백 강점' },
    ],
    highlights: ['관찰력과 맥락 파악이 강하게 드러남'],
    recommendations: ['생각을 글로 정리해보세요', '대화 전에 핵심 문장을 먼저 잡으세요'],
    warnings: ['과한 자기검열은 추진력을 떨어뜨릴 수 있어요'],
  },
  'blood-type': {
    score: 74,
    summary: '기질상 친화력은 좋지만, 오늘은 속도를 너무 맞추려 들면 피로가 빨리 옵니다.',
    metrics: [
      { label: '관계 텐션', value: '부드러움', note: '첫인상 안정적' },
      { label: '회복력', value: '보통', note: '휴식 선행 필요' },
    ],
    highlights: ['분위기 조율 능력이 강함'],
    recommendations: ['오늘은 선택지를 좁혀서 말해보세요'],
    warnings: ['타인 속도를 전부 따라가면 집중이 흐려집니다'],
  },
  'zodiac-animal': {
    score: 77,
    summary: '띠 흐름상 사람보다 타이밍이 더 중요하게 작동하는 날입니다.',
    metrics: [
      { label: '행동 운', value: '상승', note: '짧은 실행 강세' },
      { label: '관계 운', value: '무난', note: '새 약속보단 기존 정리' },
    ],
    highlights: ['오늘은 첫 움직임이 빠를수록 결과가 좋습니다'],
    recommendations: ['오전 안에 우선순위를 확정하세요'],
    warnings: ['한 번에 두 가지 결정을 같이 내리지는 마세요'],
  },
  constellation: {
    score: 81,
    summary: '감정 기복은 크지 않고, 직감보다 현재 컨디션을 믿는 쪽이 더 잘 맞습니다.',
    metrics: [
      { label: '감정 리듬', value: '안정', note: '관계 스트레스 낮음' },
      { label: '표현력', value: '좋음', note: '부드러운 설득 강점' },
    ],
    highlights: ['차분한 설명이 설득력을 높여줍니다'],
    recommendations: ['서두르지 말고 한 문장씩 정리하세요'],
    warnings: ['피곤할 때 감정적 결정은 피하는 편이 좋아요'],
    luckyItems: ['실버 포인트', '밝은 향'],
  },
  career: {
    score: 84,
    summary: '커리어 흐름은 상승 구간이지만, 방향 선명도가 성과 차이를 크게 만듭니다.',
    metrics: [
      { label: '성장 운', value: '84%', note: '학습 흡수력 높음' },
      { label: '변화 적기', value: '준비 단계', note: '바로 이동보다 정리 우선' },
    ],
    highlights: ['실행보다 전략 정리가 먼저 먹히는 흐름'],
    recommendations: ['이번 주 목표를 하나로 줄이세요', '새 제안은 숫자로 정리하세요'],
    warnings: ['여러 방향을 동시에 잡으면 임팩트가 약해집니다'],
    specialTip: '지금은 이직 결정보다 포지셔닝 문장 하나를 정리하는 편이 ROI가 큽니다.',
  },
  love: {
    score: 88,
    summary: '연애 흐름은 열려 있지만, 속도보다 호흡 맞추기가 결과를 좌우합니다.',
    metrics: [
      { label: '끌림 지수', value: '88%', note: '가벼운 대화 강세' },
      { label: '관계 안정도', value: '상승', note: '확신은 천천히 형성' },
    ],
    highlights: ['오늘은 표현의 질이 타이밍보다 중요합니다'],
    recommendations: ['질문형 대화를 늘려보세요', '기대보다 관찰을 먼저 두세요'],
    warnings: ['답을 서둘러 확정하면 관계 리듬이 틀어질 수 있어요'],
    luckyItems: ['로즈 톤', '짧은 산책'],
  },
  health: {
    score: 73,
    summary: '건강 흐름은 회복 위주로 읽히고, 과한 퍼포먼스보다 리듬 복구가 우선입니다.',
    metrics: [
      { label: '에너지 잔량', value: '73%', note: '수면 영향 큼' },
      { label: '회복 속도', value: '느림', note: '무리 금지' },
    ],
    highlights: ['몸보다 먼저 마음 피로를 낮추는 편이 좋습니다'],
    recommendations: ['식사와 수면 시간을 먼저 고정하세요', '카페인보다 물 섭취를 늘려보세요'],
    warnings: ['짧은 무리도 다음날까지 이어질 수 있어요'],
  },
  coaching: {
    score: 80,
    summary: '지금은 동기보다 구조가 성과를 만들기 좋은 구간입니다.',
    metrics: [
      { label: '집중력', value: '80', note: '짧은 몰입 유리' },
      { label: '실행력', value: '76', note: '작은 완료가 중요' },
      { label: '성장도', value: '83', note: '반복에서 탄력' },
    ],
    highlights: ['오늘은 계획보다 완료 경험을 쌓는 편이 좋습니다'],
    recommendations: ['25분 단위로 목표를 자르세요', '완료 기준을 먼저 적으세요'],
    warnings: ['완벽하게 시작하려 하면 시작 자체가 늦어질 수 있어요'],
  },
  family: {
    score: 78,
    summary: '가족운은 크게 나쁘지 않지만, 기대치를 낮추고 톤을 맞추는 것이 중요합니다.',
    metrics: [
      { label: '하모니', value: '78%', note: '작은 조율 필요' },
      { label: '대화 적합도', value: '좋음', note: '짧은 안부 강세' },
    ],
    highlights: ['길게 설명하기보다 먼저 안심시키는 말이 효과적입니다'],
    recommendations: ['가족 한 명에게만 집중해서 말해보세요'],
    warnings: ['과거 얘기를 꺼내면 감정이 커질 수 있어요'],
  },
  'past-life': {
    score: 75,
    summary: '상징과 감각이 강하게 들어오는 흐름이라, 직감형 해석이 잘 맞는 날입니다.',
    metrics: [
      { label: '직감 신호', value: '강함', note: '이미지 기억 선명' },
      { label: '해석 안정도', value: '보통', note: '과몰입 주의' },
    ],
    highlights: ['반복되는 감각에는 현재 삶의 힌트가 섞여 있습니다'],
    recommendations: ['떠오른 키워드를 세 개만 적어두세요'],
    warnings: ['상징을 단정적으로 해석하지는 마세요'],
  },
  wish: {
    score: 83,
    summary: '소원 흐름은 열려 있고, 지금은 바라는 내용을 한 문장으로 줄일수록 힘이 실립니다.',
    metrics: [
      { label: '집중도', value: '83%', note: '하나의 목표 집중' },
      { label: '실현 탄력', value: '상승', note: '작은 시작 추천' },
    ],
    highlights: ['바람을 구체화할수록 체감 속도가 빨라집니다'],
    recommendations: ['소원을 행동 문장으로 바꿔보세요'],
    warnings: ['여러 소원을 동시에 붙잡으면 힘이 분산됩니다'],
  },
  'personality-dna': {
    score: 85,
    summary: '성격 DNA는 강점이 분명한 타입으로 읽히고, 오늘은 장점의 사용처를 좁히는 게 중요합니다.',
    metrics: [
      { label: '강점 밀도', value: '85%', note: '분석력 우세' },
      { label: '확장성', value: '높음', note: '환경 적응 가능' },
    ],
    highlights: ['강점이 많은 대신 우선순위가 흐려지기 쉽습니다'],
    recommendations: ['오늘은 한 가지 강점만 선택해서 쓰세요'],
    warnings: ['모든 면을 잘하려 하면 피로가 빨리 옵니다'],
  },
  wealth: {
    score: 82,
    summary: '재물운은 안정 상승형으로 읽히고, 과감한 투자보다 흐름 관리가 더 중요합니다.',
    metrics: [
      { label: '현금 흐름', value: '82%', note: '유지력 좋음' },
      { label: '리스크 감도', value: '주의', note: '충동 소비 경계' },
    ],
    highlights: ['작은 새는 돈보다 새는 습관을 보는 편이 맞습니다'],
    recommendations: ['고정지출 하나를 먼저 손보세요', '큰 결정은 하루 미뤄보세요'],
    warnings: ['단기 기분 소비가 누적될 수 있어요'],
  },
  talent: {
    score: 87,
    summary: '숨은 재능은 이미 보이기 시작한 상태이고, 반복할수록 강점이 더 선명해집니다.',
    metrics: [
      { label: '표현 재능', value: '상승', note: '결과물 만들기 유리' },
      { label: '지속 가능성', value: '87%', note: '작은 루틴 추천' },
    ],
    highlights: ['재능은 감각보다 습관에서 더 빨리 드러납니다'],
    recommendations: ['이번 주 안에 한 번 공개해보세요'],
    warnings: ['비교가 시작되면 속도가 느려질 수 있어요'],
  },
  exercise: {
    score: 76,
    summary: '운동 운세는 무난한 편이고, 강도보다 루틴 고정이 더 중요합니다.',
    metrics: [
      { label: '체력 흐름', value: '76%', note: '과부하 금지' },
      { label: '꾸준함', value: '상승', note: '짧은 반복 유리' },
    ],
    highlights: ['오늘은 기록보다 반복이 남는 날입니다'],
    recommendations: ['20분 루틴으로 시작하세요'],
    warnings: ['의욕이 올라와도 첫날 강도는 낮게 두세요'],
  },
  tarot: {
    score: 81,
    summary: '타로는 분기점보다는 현재 감정의 결을 읽어주는 방향으로 작동합니다.',
    metrics: [
      { label: '카드 공명', value: '81%', note: '질문 명확도 중요' },
      { label: '행동 힌트', value: '높음', note: '즉시 적용 가능' },
    ],
    highlights: ['지금은 답보다 시야를 넓혀주는 메시지가 강합니다'],
    recommendations: ['카드 해석을 오늘 행동 한 줄로 바꿔보세요'],
    warnings: ['결과를 단정적인 예언으로 보지는 마세요'],
  },
  'game-enhance': {
    score: 79,
    summary: '강화운은 도전 가능 구간이지만, 무작정 연속 시도보다는 템포 관리가 핵심입니다.',
    metrics: [
      { label: '도전 운', value: '79%', note: '짧은 집중 강세' },
      { label: '손실 경계', value: '필요', note: '컷라인 정하기' },
    ],
    highlights: ['두세 번 안에서 판단하는 편이 손실을 줄입니다'],
    recommendations: ['횟수와 종료 기준을 먼저 정하세요'],
    warnings: ['감정이 올라오면 성공률 체감이 왜곡될 수 있어요'],
  },
  'ootd-evaluation': {
    score: 84,
    summary: '스타일 흐름은 좋고, 오늘은 디테일 하나가 전체 인상을 끌어올리는 날입니다.',
    metrics: [
      { label: '첫인상', value: '84%', note: '정리된 무드 강세' },
      { label: '포인트 적합도', value: '좋음', note: '액세서리 유리' },
    ],
    highlights: ['과한 레이어링보다 포인트 하나가 더 먹힙니다'],
    recommendations: ['컬러 포인트를 한 군데만 주세요'],
    warnings: ['메인 포인트를 두 개 이상 쓰면 인상이 분산됩니다'],
    luckyItems: ['실버 액세서리', '딥 블랙'],
  },
};

export function buildEmbeddedResultPayload(
  fortuneType: FortuneTypeId,
  resultKind: ResultKind,
): EmbeddedResultPayload {
  const metadata = resultMetadataByKind[resultKind];
  const seed = payloadSeedByKind[resultKind];

  return {
    widgetType: 'fortune_result_card',
    fortuneType,
    resultKind,
    eyebrow: metadata.eyebrow,
    title: metadata.title,
    subtitle: metadata.subtitle,
    summary: seed.summary,
    score: seed.score,
    metrics: seed.metrics,
    highlights: seed.highlights,
    recommendations: seed.recommendations,
    warnings: seed.warnings,
    luckyItems: seed.luckyItems,
    specialTip: seed.specialTip,
  };
}
