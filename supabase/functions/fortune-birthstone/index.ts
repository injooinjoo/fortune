/**
 * 탄생석 가이드 (Birthstone Fortune) Edge Function
 *
 * @description 생년월일 또는 생월을 기준으로 탄생석과 오늘의 조언을 제공합니다.
 *
 * @endpoint POST /fortune-birthstone
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface BirthstoneRequest {
  userId?: string
  name?: string
  birthDate?: string
  birthMonth?: number
  month?: number
  isPremium?: boolean
}

interface BirthstoneData {
  fortuneType: 'birthstone'
  score: number
  content: string
  summary: string
  advice: string
  timestamp: string
  birthstone: string
  birthstoneEnglish: string
  birthstoneMeaning: string
  birthMonth: number
  birthMonthLabel: string
  color: string
  keywords: string[]
  luckyItems: {
    stone: string
    color: string
    metal: string
  }
  compatibility: {
    best: string[]
    caution: string[]
  }
  specialNote: string
}

const BIRTHSTONE_CATALOG: Record<number, {
  stone: string
  english: string
  meaning: string
  color: string
  keywords: string[]
  metal: string
  summary: string
  advice: string
  specialNote: string
}> = {
  1: {
    stone: '가넷',
    english: 'Garnet',
    meaning: '꾸준함과 신뢰',
    color: '딥 레드',
    keywords: ['지속력', '용기', '신뢰'],
    metal: '실버',
    summary: '차분하게 밀어붙일수록 결과가 쌓이는 날이에요.',
    advice: '중요한 일은 시작만 하지 말고 끝까지 마무리해보세요.',
    specialNote: '새로운 다짐을 구체적인 일정으로 적어두면 좋습니다.',
  },
  2: {
    stone: '자수정',
    english: 'Amethyst',
    meaning: '직관과 안정',
    color: '퍼플',
    keywords: ['직관', '평온', '균형'],
    metal: '화이트 골드',
    summary: '복잡한 생각을 정리할수록 방향이 선명해져요.',
    advice: '잠시 멈추고 우선순위를 다시 정리해보세요.',
    specialNote: '관계를 부드럽게 만드는 말 한마디가 힘이 됩니다.',
  },
  3: {
    stone: '아쿠아마린',
    english: 'Aquamarine',
    meaning: '소통과 유연함',
    color: '아쿠아 블루',
    keywords: ['소통', '순발력', '유연함'],
    metal: '실버',
    summary: '가벼운 대화 속에서 중요한 실마리가 보이는 날이에요.',
    advice: '미뤄둔 연락이나 답장을 오늘 정리해보세요.',
    specialNote: '상대의 반응을 읽는 센스가 유난히 좋아집니다.',
  },
  4: {
    stone: '다이아몬드',
    english: 'Diamond',
    meaning: '결단과 완성',
    color: '클리어',
    keywords: ['완성도', '결단', '집중'],
    metal: '플래티넘',
    summary: '끝맺음이 중요한 일에서 존재감이 강해지는 날이에요.',
    advice: '한 번 더 확인하고 마무리하면 실수가 줄어듭니다.',
    specialNote: '작은 디테일이 전체 인상을 바꿔줍니다.',
  },
  5: {
    stone: '에메랄드',
    english: 'Emerald',
    meaning: '성장과 회복',
    color: '그린',
    keywords: ['성장', '회복', '균형'],
    metal: '골드',
    summary: '회복되는 기운이 강해 다시 속도를 낼 수 있어요.',
    advice: '몸과 마음에 여유를 주는 선택을 해보세요.',
    specialNote: '새로운 시도를 하기에 좋은 출발점입니다.',
  },
  6: {
    stone: '진주',
    english: 'Pearl',
    meaning: '품격과 배려',
    color: '아이보리',
    keywords: ['품격', '배려', '우아함'],
    metal: '실버',
    summary: '사람 사이의 온도가 부드럽게 올라가는 날이에요.',
    advice: '먼저 배려를 건네면 관계가 더 매끄러워집니다.',
    specialNote: '조용한 자신감이 오히려 돋보입니다.',
  },
  7: {
    stone: '루비',
    english: 'Ruby',
    meaning: '열정과 자신감',
    color: '레드',
    keywords: ['열정', '자신감', '표현'],
    metal: '골드',
    summary: '마음이 가는 일에 힘을 실어주기 좋은 날이에요.',
    advice: '하고 싶은 말은 너무 오래 미루지 마세요.',
    specialNote: '가벼운 승부수 하나가 분위기를 바꿉니다.',
  },
  8: {
    stone: '페리도트',
    english: 'Peridot',
    meaning: '정화와 낙관',
    color: '라임 그린',
    keywords: ['정리', '낙관', '정화'],
    metal: '골드',
    summary: '불필요한 부담을 덜어내면 흐름이 가벼워져요.',
    advice: '집중할 일과 버릴 일을 나눠보세요.',
    specialNote: '새로운 제안이 들어와도 충분히 검토한 뒤 움직이세요.',
  },
  9: {
    stone: '사파이어',
    english: 'Sapphire',
    meaning: '통찰과 신뢰',
    color: '블루',
    keywords: ['통찰', '신뢰', '집중'],
    metal: '화이트 골드',
    summary: '핵심을 꿰뚫는 판단력이 빛나는 날이에요.',
    advice: '중심을 잡고 말하면 설득력이 높아집니다.',
    specialNote: '겉보다 본질을 보려는 태도가 유리합니다.',
  },
  10: {
    stone: '오팔',
    english: 'Opal',
    meaning: '변화와 영감',
    color: '오팔 화이트',
    keywords: ['영감', '변화', '감수성'],
    metal: '실버',
    summary: '아이디어가 빠르게 이어지는 창의적인 흐름이에요.',
    advice: '떠오른 생각은 바로 메모해두세요.',
    specialNote: '감각적인 선택이 기대 이상으로 잘 맞습니다.',
  },
  11: {
    stone: '토파즈',
    english: 'Topaz',
    meaning: '명료함과 집중',
    color: '골든 옐로',
    keywords: ['명료함', '집중', '정리'],
    metal: '골드',
    summary: '흐릿했던 계획이 점점 선명해지는 날이에요.',
    advice: '중요한 결정은 숫자보다 기준을 먼저 잡아보세요.',
    specialNote: '한 단계씩 차근히 나가면 결과가 안정적입니다.',
  },
  12: {
    stone: '터키석',
    english: 'Turquoise',
    meaning: '보호와 균형',
    color: '터키블루',
    keywords: ['보호', '균형', '여유'],
    metal: '실버',
    summary: '마무리와 정리가 잘 맞물리는 안정적인 흐름이에요.',
    advice: '올해를 정리하며 내년의 기준을 세워보세요.',
    specialNote: '주변의 조언을 잘 골라 듣는 것이 포인트입니다.',
  },
}

function resolveBirthMonth(request: BirthstoneRequest): number | null {
  if (request.birthDate) {
    const birth = new Date(request.birthDate)
    if (!Number.isNaN(birth.getTime())) {
      return birth.getMonth() + 1
    }
  }

  const month = request.birthMonth ?? request.month
  if (typeof month === 'number' && month >= 1 && month <= 12) {
    return month
  }

  return null
}

function getBirthMonthLabel(month: number): string {
  return `${month}월`
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const request: BirthstoneRequest = await req.json()
    const birthMonth = resolveBirthMonth(request)

    if (!birthMonth) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '생년월일 또는 생월이 필요합니다.',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400,
        }
      )
    }

    const entry = BIRTHSTONE_CATALOG[birthMonth] ?? BIRTHSTONE_CATALOG[1]
    const content = `${getBirthMonthLabel(birthMonth)} 탄생석은 ${entry.stone}예요. ${entry.meaning}의 흐름이 강하게 들어오니, ${entry.summary}`
    const timestamp = new Date().toISOString()
    const score = 72 + ((birthMonth % 5) * 4)

    const data = {
      fortuneType: 'birthstone' as const,
      score,
      content,
      summary: entry.summary,
      advice: entry.advice,
      timestamp,
      birthstone: entry.stone,
      birthstoneEnglish: entry.english,
      birthstoneMeaning: entry.meaning,
      birthMonth,
      birthMonthLabel: getBirthMonthLabel(birthMonth),
      color: entry.color,
      keywords: entry.keywords,
      luckyItems: {
        stone: entry.stone,
        color: entry.color,
        metal: entry.metal,
      },
      compatibility: {
        best: ['신뢰형', '실행형', '균형형'],
        caution: ['충동형', '과열형'],
      },
      specialNote: entry.specialNote,
      name: request.name ?? '회원님',
      userId: request.userId ?? null,
      isPremium: request.isPremium ?? false,
    }

    return new Response(
      JSON.stringify({
        success: true,
        data,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
      }
    )
  } catch (error) {
    console.error('Error in fortune-birthstone:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '탄생석 가이드 생성 중 오류가 발생했습니다.',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500,
      }
    )
  }
})
