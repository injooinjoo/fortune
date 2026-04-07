import type { FortuneTypeId } from '@fortune/product-contracts';

import { resultMetadataByKind } from '../fortune-results/mapping';
import type { MetricTileData, ResultKind } from '../fortune-results/types';
import type { EmbeddedResultPayload } from './types';

export interface EmbeddedResultSeed {
  score?: number;
  summary: string;
  metrics?: MetricTileData[];
  highlights?: string[];
  recommendations?: string[];
  warnings?: string[];
  luckyItems?: string[];
  specialTip?: string;
}

interface EmbeddedResultDisplayMetadata {
  eyebrow: string;
  subtitle: string;
  title: string;
}

const displayMetadataByFortuneType: Partial<
  Record<FortuneTypeId, EmbeddedResultDisplayMetadata>
> = {
  daily: {
    title: '오늘 운세',
    subtitle: '하루 에너지와 타이밍을 가볍게 읽는 결과',
    eyebrow: '오늘의 하루 흐름',
  },
  'new-year': {
    title: '신년 운세',
    subtitle: '한 해의 기운과 전환 포인트를 정리한 결과',
    eyebrow: '올해의 흐름 요약',
  },
  'fortune-cookie': {
    title: '포춘쿠키',
    subtitle: '짧고 선명한 행운 메시지를 꺼내보는 결과',
    eyebrow: '오늘의 한마디',
  },
  'face-reading': {
    title: '관상',
    subtitle: '인상과 분위기에서 읽히는 포인트를 정리한 결과',
    eyebrow: '오늘의 인상 흐름',
  },
  naming: {
    title: '작명',
    subtitle: '이름의 기운과 어감 포인트를 정리한 결과',
    eyebrow: '오늘의 이름 흐름',
  },
  zodiac: {
    title: '별자리 운세',
    subtitle: '별자리 흐름과 감정 리듬을 정리한 결과',
    eyebrow: '오늘의 별 흐름',
  },
  birthstone: {
    title: '탄생석 가이드',
    subtitle: '탄생석 분위기와 추천 포인트를 묶은 결과',
    eyebrow: '오늘의 탄생석 힌트',
  },
  compatibility: {
    title: '궁합',
    subtitle: '두 사람의 리듬과 관계 포인트를 읽는 결과',
    eyebrow: '오늘의 궁합 흐름',
  },
  'blind-date': {
    title: '소개팅 운세',
    subtitle: '첫인상과 대화 흐름, 만남 포인트를 담은 결과',
    eyebrow: '오늘의 만남 흐름',
  },
  'ex-lover': {
    title: '재회 운세',
    subtitle: '관계 여운과 재접점 가능성을 읽는 결과',
    eyebrow: '오늘의 재회 흐름',
  },
  'avoid-people': {
    title: '피해야 할 인연',
    subtitle: '거리 조절이 필요한 관계 신호를 정리한 결과',
    eyebrow: '오늘의 관계 경계',
  },
  celebrity: {
    title: '연예인 궁합',
    subtitle: '캐릭터 취향과 관계 감각을 가볍게 읽는 결과',
    eyebrow: '오늘의 케미 흐름',
  },
  'yearly-encounter': {
    title: '올해의 인연운',
    subtitle: '올해 만남과 관계 전개 리듬을 압축한 결과',
    eyebrow: '올해의 인연 흐름',
  },
  exam: {
    title: '시험운',
    subtitle: '집중 타이밍과 준비 전략을 정리한 결과',
    eyebrow: '오늘의 집중 흐름',
  },
  'lucky-items': {
    title: '행운 아이템',
    subtitle: '지금 잘 맞는 행운 포인트와 추천 아이템을 담은 결과',
    eyebrow: '오늘의 행운 포인트',
  },
  lotto: {
    title: '로또 운세',
    subtitle: '운의 밀도와 가볍게 참고할 포인트를 담은 결과',
    eyebrow: '오늘의 행운 흐름',
  },
  'match-insight': {
    title: '경기 인사이트',
    subtitle: '경기 흐름과 집중 타이밍을 읽는 결과',
    eyebrow: '오늘의 경기 흐름',
  },
  moving: {
    title: '이사 운세',
    subtitle: '공간 이동과 자리 변화의 흐름을 읽는 결과',
    eyebrow: '오늘의 공간 흐름',
  },
  dream: {
    title: '꿈 해몽',
    subtitle: '꿈 상징과 현재 감정의 연결을 정리한 결과',
    eyebrow: '오늘의 꿈 메시지',
  },
  biorhythm: {
    title: '바이오리듬',
    subtitle: '컨디션 리듬과 감정 파동을 정리한 결과',
    eyebrow: '오늘의 리듬 흐름',
  },
  breathing: {
    title: '명상 가이드',
    subtitle: '호흡 리듬과 이완 포인트를 짧게 정리한 결과',
    eyebrow: '지금의 호흡 흐름',
  },
  'pet-compatibility': {
    title: '반려동물 궁합',
    subtitle: '반려동물과의 케미와 돌봄 포인트를 담은 결과',
    eyebrow: '오늘의 반려 케미',
  },
  talisman: {
    title: '부적',
    subtitle: '마음을 붙잡는 상징과 보호 포인트를 담은 결과',
    eyebrow: '오늘의 보호 메시지',
  },
  'weekly-review': {
    title: '주간 리뷰',
    subtitle: '한 주의 패턴과 다음 주 전환 포인트를 정리한 결과',
    eyebrow: '이번 주 정리 흐름',
  },
  'chat-insight': {
    title: '카톡 대화 분석',
    subtitle: '대화 리듬과 반응 포인트를 읽는 결과',
    eyebrow: '이번 대화의 흐름',
  },
};

const embeddedResultSeedByFortuneType: Partial<
  Record<FortuneTypeId, EmbeddedResultSeed>
> = {
  breathing: {
    score: 78,
    summary:
      '호흡 가이드는 몸을 밀어붙이기보다 긴장을 낮추는 리듬을 먼저 회복할 때 효과가 커집니다.',
    metrics: [
      { label: '호흡 안정도', value: '78', note: '내쉼을 길게 두기' },
      { label: '이완 포인트', value: '어깨·턱', note: '짧은 체크 추천' },
    ],
    highlights: ['숨을 길게 뺄수록 몸 반응이 빠르게 안정되는 흐름입니다'],
    recommendations: ['4초 들숨, 6초 날숨으로 세 번만 반복해보세요'],
    warnings: ['한 번에 깊게 교정하려 하면 오히려 어지러울 수 있어요'],
    luckyItems: ['조용한 3분', '미지근한 물'],
  },
  'weekly-review': {
    score: 82,
    summary:
      '주간 리뷰는 성과보다 반복된 패턴을 읽을 때 다음 주 흐름이 더 선명해집니다.',
    metrics: [
      { label: '패턴 선명도', value: '82', note: '반복 포인트가 보임' },
      { label: '회복 여지', value: '78', note: '한 가지 정리 필요' },
    ],
    highlights: ['이번 주 자주 흔들린 순간을 한 줄로 남기면 다음 주 결정이 빨라집니다'],
    recommendations: ['잘된 일, 미뤄진 일, 놓친 신호를 각각 한 개만 적어보세요'],
    warnings: ['주간 리뷰를 자기비판으로 바꾸면 다음 주 리듬이 무거워집니다'],
    luckyItems: ['주간 체크리스트', '일요일 저녁 10분'],
  },
  'chat-insight': {
    score: 81,
    summary:
      '대화 분석은 상대의 정답을 찾기보다 내가 반복한 신호를 읽을 때 다음 답장이 쉬워집니다.',
    metrics: [
      { label: '대화 온도', value: '81', note: '호감과 거리감 균형' },
      { label: '반응 힌트', value: '76', note: '속도보다 톤이 중요' },
    ],
    highlights: ['짧은 답장보다 말끝의 뉘앙스가 더 중요한 신호로 읽힙니다'],
    recommendations: ['확인 질문 하나와 감정 표현 한 줄을 분리해서 보내보세요'],
    warnings: ['상대 반응을 한 번에 확정 해석하면 흐름을 오해할 수 있어요'],
    luckyItems: ['보내기 전 1분 텀', '짧은 메모'],
  },
};

export const embeddedResultSeedByKind: Record<ResultKind, EmbeddedResultSeed> = {
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
  exam: {
    score: 86,
    summary: '시험운은 벼락치기보다 실전 리듬 정리에서 차이가 크게 나는 날입니다.',
    metrics: [
      { label: '집중도', value: '91%', note: '짧은 몰입 강세' },
      { label: '실전 감각', value: '84%', note: '익숙한 유형에 강함' },
    ],
    highlights: ['정답률보다 실수 줄이기가 더 큰 점수 차이를 만듭니다'],
    recommendations: ['실수 노트를 한 장으로 압축하세요', '시험 당일 루틴을 오늘 미리 맞춰보세요'],
    warnings: ['직전 새로운 풀이법 추가는 오히려 흔들릴 수 있어요'],
    luckyItems: ['얇은 노트', '진한 블루 펜'],
  },
  compatibility: {
    score: 87,
    summary: '궁합운은 감정 강도보다 생활 리듬과 대화 결에서 높은 점수를 보이는 흐름입니다.',
    metrics: [
      { label: '성격 궁합', value: '88', note: '기본 결이 잘 맞음' },
      { label: '소통 궁합', value: '90', note: '짧고 명확한 대화 강세' },
    ],
    highlights: ['서로 다른 템포를 조율하는 순간 관계 만족도가 크게 올라갑니다'],
    recommendations: ['중요한 기대치는 말로 먼저 맞춰보세요'],
    warnings: ['감정만 보고 결론을 서두르면 오해가 커질 수 있어요'],
    luckyItems: ['저녁 산책', '차분한 향'],
  },
  'blind-date': {
    score: 82,
    summary: '소개팅운은 첫인상을 크게 밀기보다 편안한 호흡을 만드는 데서 점수가 올라갑니다.',
    metrics: [
      { label: '첫인상', value: '89', note: '차분한 자신감 강세' },
      { label: '관심도', value: '78', note: '반응은 천천히 상승' },
    ],
    highlights: ['질문형 대화가 어색함을 빠르게 풀어줍니다'],
    recommendations: ['관찰한 포인트를 짧게 말해보세요'],
    warnings: ['스펙 확인처럼 들리는 질문을 초반에 몰아넣지 마세요'],
    luckyItems: ['은은한 향', '로즈 베이지'],
  },
  'avoid-people': {
    score: 79,
    summary: '오늘은 사람보다 패턴을 경계하는 편이 에너지 보존에 더 효과적입니다.',
    metrics: [
      { label: '관계 경계', value: '79', note: '기준 유지 필요' },
      { label: '에너지 보호', value: '85', note: '짧은 거리 두기 유리' },
    ],
    highlights: ['급한 친밀감과 압박형 부탁은 바로 거리를 두는 편이 좋습니다'],
    recommendations: ['답을 바로 주지 말고 시간을 두고 정리하세요'],
    warnings: ['피곤한 상태에선 경계선이 느슨해질 수 있어요'],
    luckyItems: ['무음 시간', '심호흡 3번'],
  },
  'ex-lover': {
    score: 71,
    summary: '재회운은 감정 확인보다 관계 기준을 다시 세울수록 의미가 선명해지는 흐름입니다.',
    metrics: [
      { label: '재접점', value: '68', note: '가능성은 있으나 속도 조절 필요' },
      { label: '감정 안정도', value: '74', note: '기대보다 기준 정리 우선' },
    ],
    highlights: ['다시 만나는 것보다 다시 만나도 괜찮은 관계인지가 더 중요합니다'],
    recommendations: ['안부보다 현재 기준을 먼저 정리하세요'],
    warnings: ['좋았던 기억만으로 현재를 덮어보면 반복될 수 있어요'],
    luckyItems: ['짧은 메모', '느린 호흡'],
  },
  'yearly-encounter': {
    score: 84,
    summary: '올해의 인연운은 한 번의 강한 이벤트보다 반복되는 신호와 익숙한 공간에서 열릴 가능성이 큽니다.',
    metrics: [
      { label: '만남 운', value: '84', note: '일상 공간에서 강세' },
      { label: '궁합 감도', value: '81', note: '리듬이 자연스럽게 맞음' },
    ],
    highlights: ['자꾸 눈에 들어오는 사람이나 장소를 흘려보내지 않는 편이 좋습니다'],
    recommendations: ['익숙한 장소의 반복 신호를 기록해보세요'],
    warnings: ['한 번에 확신하려 하면 오히려 흐름을 놓칠 수 있어요'],
    luckyItems: ['우디 향', '라이트 브라운'],
  },
  decision: {
    score: 83,
    summary: '의사결정 운세는 정답 탐색보다 선택 기준을 줄이는 데서 빠르게 살아납니다.',
    metrics: [
      { label: '명확도', value: '86', note: '기준만 세우면 빠름' },
      { label: '확신도', value: '79', note: '막판 흔들림 주의' },
    ],
    highlights: ['선택지를 두 개로 줄이는 순간 결정 속도가 좋아집니다'],
    recommendations: ['포기 못할 기준 한 줄을 먼저 적어보세요'],
    warnings: ['모든 가능성을 동시에 검토하려 하면 결론이 늦어집니다'],
    luckyItems: ['체크리스트', '조용한 공간'],
  },
  'daily-review': {
    score: 80,
    summary: '일일 리뷰는 반성보다 정리에서 힘이 생기는 흐름입니다. 남길 것과 넘길 것을 분리하면 내일이 가벼워집니다.',
    metrics: [
      { label: '정리 밀도', value: '84', note: '핵심 한 건은 잘 남김' },
      { label: '감정 회수', value: '76', note: '짧은 메모가 도움' },
    ],
    highlights: ['오늘 잘된 한 가지를 명확히 남기면 내일 리듬이 좋아집니다'],
    recommendations: ['열린 일과 끝난 일을 따로 적어두세요'],
    warnings: ['피곤한 상태에서 하루 전체를 평가하려 들면 감정이 과해질 수 있어요'],
    luckyItems: ['짧은 리뷰 노트', '저녁 정리 시간'],
  },
};

export function buildFallbackEmbeddedResultPayload(
  fortuneType: FortuneTypeId,
  resultKind: ResultKind,
): EmbeddedResultPayload {
  const metadata = resultMetadataByKind[resultKind];
  const seed =
    embeddedResultSeedByFortuneType[fortuneType] ??
    embeddedResultSeedByKind[resultKind];
  const displayMetadata = displayMetadataByFortuneType[fortuneType] ?? metadata;

  return {
    widgetType: 'fortune_result_card',
    fortuneType,
    resultKind,
    eyebrow: displayMetadata.eyebrow,
    title: displayMetadata.title,
    subtitle: displayMetadata.subtitle,
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
