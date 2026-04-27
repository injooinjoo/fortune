/**
 * saju-interpretation-fallback — Edge Function이 다운되거나 느릴 때
 * 즉시 사용할 수 있는 클라이언트 사이드 규칙 기반 해석 생성기.
 *
 * Edge Function 응답과 동일한 shape의 `SajuInterpretationData`를 반환.
 */

import type {
  Element,
  SajuResult,
  StemKr,
  TenGod,
} from '@fortune/saju-engine';

import type { SajuInterpretationData } from '../hooks/use-saju-interpretation';

/** 일간 오행 기반 성격 요약 (10종) */
const DAY_MASTER_PERSONA: Record<StemKr, string> = {
  갑: '곧고 우직하며 리더십이 강한 큰 나무의 기운. 솔직하고 추진력이 뛰어나요.',
  을: '유연하고 온화한 풀·덩굴의 기운. 섬세하고 친화력이 좋아요.',
  병: '밝고 열정적인 태양의 기운. 존재감이 강하고 모두를 비추는 성향이에요.',
  정: '은은하고 따뜻한 촛불의 기운. 섬세하고 배려심이 깊어요.',
  무: '묵직하고 포용력 있는 큰 산의 기운. 신뢰감을 주고 중심을 잘 잡아요.',
  기: '부드럽고 실용적인 밭흙의 기운. 꼼꼼하고 실속을 잘 챙겨요.',
  경: '단단하고 결단력 있는 쇳덩이의 기운. 정의감과 추진력이 뛰어나요.',
  신: '예리하고 세련된 보석의 기운. 감각이 뛰어나고 날카로운 판단력이 있어요.',
  임: '넓고 깊은 바다·강물의 기운. 포용력·지혜·융통성이 좋아요.',
  계: '차분하고 지혜로운 이슬·빗물의 기운. 사색적이고 통찰력이 깊어요.',
};

/** 일간별 대표 장점 */
const DAY_MASTER_STRENGTHS: Record<StemKr, string[]> = {
  갑: ['리더십', '추진력', '정직함'],
  을: ['친화력', '유연성', '섬세함'],
  병: ['열정', '표현력', '긍정성'],
  정: ['배려심', '집중력', '인내'],
  무: ['신뢰감', '포용력', '끈기'],
  기: ['실용성', '꼼꼼함', '균형'],
  경: ['결단력', '정의감', '추진력'],
  신: ['감각', '세련됨', '분석력'],
  임: ['지혜', '융통성', '포용력'],
  계: ['통찰', '차분함', '섬세함'],
};

/** 일간별 보완점 */
const DAY_MASTER_CHALLENGES: Record<StemKr, string[]> = {
  갑: ['고집', '융통성 부족'],
  을: ['우유부단', '예민함'],
  병: ['즉흥성', '감정 기복'],
  정: ['소심함', '과한 몰입'],
  무: ['느린 변화', '고집'],
  기: ['보수적 성향', '우유부단'],
  경: ['강한 언행', '타협 부족'],
  신: ['까칠함', '예민함'],
  임: ['무절제', '감정 변화'],
  계: ['의존성', '소극성'],
};

/** 오행별 행운의 색 */
const ELEMENT_LUCKY_COLOR: Record<Element, string> = {
  목: '초록색',
  화: '빨간색',
  토: '노란색',
  금: '흰색',
  수: '파란색',
};

/** 오행별 행운의 방위 */
const ELEMENT_LUCKY_DIRECTION: Record<Element, string> = {
  목: '동쪽',
  화: '남쪽',
  토: '중앙',
  금: '서쪽',
  수: '북쪽',
};

/** 십성별 직업 적성 */
const TEN_GOD_CAREER: Record<TenGod, string[]> = {
  비견: ['동업', '자영업', '전문직'],
  겁재: ['영업', '스포츠', '경쟁 분야'],
  식신: ['요리', '교육', '창작'],
  상관: ['예술', '방송', '기획'],
  편재: ['사업', '투자', '무역'],
  정재: ['금융', '회계', '관리'],
  편관: ['군·경', '의료', '법조'],
  정관: ['공직', '대기업', '행정'],
  편인: ['연구', '종교', '학문'],
  정인: ['교육', '문화', '공공기관'],
  일간: ['본업 집중', '전문성'],
};

/** 십성별 성향 키워드 (장점) */
const TEN_GOD_STRENGTHS: Record<TenGod, string> = {
  비견: '독립적이고 주관이 뚜렷해요',
  겁재: '경쟁심이 강하고 추진력이 있어요',
  식신: '여유롭고 표현력이 풍부해요',
  상관: '창의적이고 감각이 뛰어나요',
  편재: '큰 그림을 보고 기회를 잘 잡아요',
  정재: '성실하고 재물 관리가 꼼꼼해요',
  편관: '강단 있고 위기에 강해요',
  정관: '명예를 중시하고 원칙을 지켜요',
  편인: '통찰력과 직관이 날카로워요',
  정인: '학구열이 높고 자애로운 성품이에요',
  일간: '자기 주체성이 강해요',
};

/** 대운 십성 → 시기 테마 (한 줄) */
const TEN_GOD_LUCK_THEME: Record<TenGod, { theme: string; summary: string }> = {
  비견: {
    theme: '자립과 협력',
    summary: '스스로의 길을 찾고 동료·형제와의 관계가 중요한 시기예요.',
  },
  겁재: {
    theme: '경쟁과 도전',
    summary: '강한 라이벌과 부딪히며 성장하지만 재물 관리엔 주의가 필요해요.',
  },
  식신: {
    theme: '창의와 여유',
    summary: '재능을 발휘하고 먹고 사는 힘이 넉넉해지는 시기예요.',
  },
  상관: {
    theme: '표현과 변화',
    summary: '아이디어와 표현력이 빛나지만 권위와의 충돌은 조심해야 해요.',
  },
  편재: {
    theme: '기회와 이동',
    summary: '큰 돈의 흐름과 새로운 기회가 많은 역동적인 시기예요.',
  },
  정재: {
    theme: '안정된 소득',
    summary: '성실한 노력이 꾸준한 결실로 이어지는 안정기예요.',
  },
  편관: {
    theme: '시련과 단련',
    summary: '책임과 시련이 크지만 그만큼 내공이 쌓이는 시기예요.',
  },
  정관: {
    theme: '명예와 안정',
    summary: '직장·사회적 위치가 안정되고 인정받는 시기예요.',
  },
  편인: {
    theme: '학문과 내면',
    summary: '깊이 있는 공부와 자기 성찰로 특별한 길을 여는 시기예요.',
  },
  정인: {
    theme: '배움과 보호',
    summary: '어른·스승의 도움으로 배움과 성장의 기회가 많아요.',
  },
  일간: {
    theme: '자기 중심',
    summary: '나를 돌아보고 정체성을 재정비하는 시기예요.',
  },
};

interface ElementBalance {
  strongest: Element;
  weakest: Element;
  hasNone: Element[];
}

function computeElementBalance(saju: SajuResult): ElementBalance {
  const map: Array<[Element, number]> = [
    ['목', saju.elements.wood],
    ['화', saju.elements.fire],
    ['토', saju.elements.earth],
    ['금', saju.elements.metal],
    ['수', saju.elements.water],
  ];
  const hasNone = map.filter(([, v]) => v === 0).map(([el]) => el);
  return {
    strongest: saju.elements.strongest,
    weakest: saju.elements.weakest,
    hasNone,
  };
}

/** 사주 4주의 십성을 집계해 top-2 반환 (일간 제외) */
function topTenGods(saju: SajuResult): TenGod[] {
  const counts = new Map<TenGod, number>();
  const pillars: Array<'year' | 'month' | 'day' | 'hour'> = [
    'year', 'month', 'day', 'hour',
  ];
  for (const p of pillars) {
    const s = saju.tenGods[p].stem;
    const b = saju.tenGods[p].branch;
    if (s !== '일간') counts.set(s, (counts.get(s) ?? 0) + 1);
    counts.set(b, (counts.get(b) ?? 0) + 1);
  }
  return [...counts.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([g]) => g);
}

function pickLuckyColor(saju: SajuResult): string {
  const weakEl = saju.elements.weakest;
  return ELEMENT_LUCKY_COLOR[weakEl];
}

function pickLuckyDirection(saju: SajuResult): string {
  const weakEl = saju.elements.weakest;
  return ELEMENT_LUCKY_DIRECTION[weakEl];
}

function ageRangeLabel(startAge: number): string {
  return `${startAge}~${startAge + 9}세`;
}

/** 메인: SajuResult → 해석 객체 */
export function generateFallbackInterpretation(
  saju: SajuResult,
): SajuInterpretationData {
  const dayMasterKr = saju.dayMaster.korean;
  const persona = DAY_MASTER_PERSONA[dayMasterKr];
  const balance = computeElementBalance(saju);
  const tops = topTenGods(saju);

  const strengths = DAY_MASTER_STRENGTHS[dayMasterKr];
  const challenges = DAY_MASTER_CHALLENGES[dayMasterKr];

  const topKeywords = tops.map((g) => TEN_GOD_STRENGTHS[g]).filter(Boolean);

  const overallSummary =
    `${persona} 사주 전체로는 ${balance.strongest} 기운이 가장 강하고, ` +
    `${balance.weakest} 기운이 상대적으로 약해요.` +
    (balance.hasNone.length > 0
      ? ` ${balance.hasNone.join('·')} 오행은 없어 보완이 필요해요.`
      : '') +
    (topKeywords.length > 0
      ? ` 특히 ${topKeywords.join(' ')}.`
      : '');

  const personalitySummary =
    `${persona}` +
    (topKeywords[0] ? ` ${topKeywords[0]}.` : '');

  // 직업: 가장 많은 십성 기반
  const mainGod = tops[0] ?? '일간';
  const suitableFields = TEN_GOD_CAREER[mainGod] ?? ['전문직'];
  const careerAdvice = `${mainGod} 기운이 강해 ${suitableFields[0]} 계열에서 강점을 발휘해요. ${balance.weakest} 오행을 보완하면 더 안정적이에요.`;

  // 재물
  const wealthGod = tops.find((g) => g === '편재' || g === '정재');
  const wealthSummary = wealthGod
    ? (wealthGod === '정재'
        ? '꾸준한 노력으로 쌓는 재물운이 좋아요. 성실한 저축이 큰 자산이 돼요.'
        : '움직이는 재물·사업수가 강해요. 기회를 잡는 감각이 좋아요.')
    : '재성이 많지 않아 꾸준한 본업 집중이 재물 축적의 열쇠예요.';
  const wealthBestPeriods = saju.luckCycles.cycles
    .filter((c) => c.tenGod === '편재' || c.tenGod === '정재')
    .slice(0, 3)
    .map((c) => ageRangeLabel(c.startAge));
  const wealthCaution =
    mainGod === '겁재'
      ? '겁재의 영향으로 과한 지출·동업에서의 손실을 주의하세요.'
      : '무리한 투자보다 꾸준한 관리가 유리해요.';

  // 애정
  const loveSummary =
    saju.stars.day.includes('도화살') || saju.stars.hour.includes('도화살')
      ? '도화의 기운이 있어 이성에게 매력이 돋보여요. 진정성 있는 관계를 우선하세요.'
      : '깊고 진중한 사랑을 추구해요. 편안한 관계가 오래 가요.';
  const compatibleTypes =
    saju.dayMaster.element === '화' || saju.dayMaster.element === '목'
      ? ['차분한 수·금 성향', '서로 보완되는 토 성향']
      : ['따뜻한 화·목 성향', '안정된 토 성향'];
  const loveAdvice = '서로의 속도를 존중하는 것이 관계를 오래 유지하는 비결이에요.';

  // 건강
  const weakPoints: string[] = [];
  if (balance.hasNone.includes('수')) weakPoints.push('신장·수분 대사');
  if (balance.hasNone.includes('목')) weakPoints.push('간·피로');
  if (balance.hasNone.includes('화')) weakPoints.push('심장·혈액 순환');
  if (balance.hasNone.includes('토')) weakPoints.push('소화기');
  if (balance.hasNone.includes('금')) weakPoints.push('호흡기·피부');
  if (weakPoints.length === 0) weakPoints.push('규칙적인 생활 리듬');
  const healthSummary =
    '오행 밸런스가 건강의 핵심이에요. 부족한 기운을 보완하는 생활습관이 중요해요.';
  const healthAdvice = `${balance.weakest} 오행을 보완하는 음식·환경(예: ${ELEMENT_LUCKY_COLOR[balance.weakest]} 계열)이 도움돼요.`;

  // Daily
  const daily = {
    oneLiner: `${persona.split('.')[0]}.`,
    luckyColor: pickLuckyColor(saju),
    luckyDirection: pickLuckyDirection(saju),
  };

  // 대운 10개
  const luckCycles = saju.luckCycles.cycles.map((c) => {
    const theme = TEN_GOD_LUCK_THEME[c.tenGod] ?? TEN_GOD_LUCK_THEME['일간'];
    return {
      ageRange: ageRangeLabel(c.startAge),
      theme: theme.theme,
      summary: `${c.korean}(${c.tenGod}) · ${theme.summary}`,
    };
  });

  return {
    overallSummary,
    personality: {
      summary: personalitySummary,
      strengths,
      challenges,
    },
    career: {
      summary: `${TEN_GOD_STRENGTHS[mainGod]}. 현재 기운으로는 ${suitableFields.join('·')} 분야와 잘 맞아요.`,
      suitableFields,
      advice: careerAdvice,
    },
    wealth: {
      summary: wealthSummary,
      bestPeriods: wealthBestPeriods.length > 0 ? wealthBestPeriods : ['꾸준한 전 시기'],
      caution: wealthCaution,
    },
    love: {
      summary: loveSummary,
      compatibleTypes,
      advice: loveAdvice,
    },
    health: {
      summary: healthSummary,
      weakPoints,
      advice: healthAdvice,
    },
    daily,
    luckCycles,
  };
}
