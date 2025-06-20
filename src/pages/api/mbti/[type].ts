import type { NextApiRequest, NextApiResponse } from 'next'

interface MbtiInfo {
  type: string
  title: string
  description: string
  imageUrl: string
  characteristics: string[]
}

const MBTI_DATA: Record<string, MbtiInfo> = {
  INTJ: {
    type: 'INTJ',
    title: 'Architect',
    description: 'Imaginative and strategic thinkers, with a plan for everything.',
    imageUrl: '/images/mbti/intj.png',
    characteristics: ['전략적 사고', '독립적', '완벽주의', '미래지향적', '분석적']
  },
  INTP: {
    type: 'INTP',
    title: 'Logician',
    description: 'Innovative inventors with an unquenchable thirst for knowledge.',
    imageUrl: '/images/mbti/intp.png',
    characteristics: ['논리적', '창의적', '호기심 많음', '이론적', '객관적']
  },
  ENTJ: {
    type: 'ENTJ',
    title: 'Commander',
    description: 'Bold, imaginative and strong-willed leaders, always finding a way or making one.',
    imageUrl: '/images/mbti/entj.png',
    characteristics: ['리더십', '결단력', '목표지향적', '효율적', '카리스마']
  },
  ENTP: {
    type: 'ENTP',
    title: 'Debater',
    description: 'Smart and curious thinkers who cannot resist an intellectual challenge.',
    imageUrl: '/images/mbti/entp.png',
    characteristics: ['토론 좋아함', '창의적', '유연함', '도전적', '혁신적']
  },
  INFJ: {
    type: 'INFJ',
    title: 'Advocate',
    description: 'Quiet and mystical, yet very inspiring and tireless idealists.',
    imageUrl: '/images/mbti/infj.png',
    characteristics: ['통찰력', '이상주의', '공감능력', '신비로움', '헌신적']
  },
  INFP: {
    type: 'INFP',
    title: 'Mediator',
    description: 'Poetic, kind and altruistic people, always eager to help a good cause.',
    imageUrl: '/images/mbti/infp.png',
    characteristics: ['감수성', '친절함', '이타적', '창의적', '가치중시']
  },
  ENFJ: {
    type: 'ENFJ',
    title: 'Protagonist',
    description: 'Charismatic and inspiring leaders, able to mesmerize their listeners.',
    imageUrl: '/images/mbti/enfj.png',
    characteristics: ['카리스마', '영감을 줌', '외향적', '감정적', '협력적']
  },
  ENFP: {
    type: 'ENFP',
    title: 'Campaigner',
    description: 'Enthusiastic, creative and sociable free spirits, who can always find a reason to smile.',
    imageUrl: '/images/mbti/enfp.png',
    characteristics: ['열정적', '창의적', '사교적', '자유로움', '낙관적']
  },
  ISTJ: {
    type: 'ISTJ',
    title: 'Logistician',
    description: 'Practical and fact-minded individuals, whose reliability cannot be doubted.',
    imageUrl: '/images/mbti/istj.png',
    characteristics: ['실용적', '신뢰할 수 있음', '체계적', '책임감', '전통적']
  },
  ISFJ: {
    type: 'ISFJ',
    title: 'Defender',
    description: 'Very dedicated and warm protectors, always ready to defend their loved ones.',
    imageUrl: '/images/mbti/isfj.png',
    characteristics: ['헌신적', '따뜻함', '보호적', '배려심', '성실함']
  },
  ESTJ: {
    type: 'ESTJ',
    title: 'Executive',
    description: 'Excellent administrators, unsurpassed at managing things—or people.',
    imageUrl: '/images/mbti/estj.png',
    characteristics: ['관리능력', '조직적', '실용적', '결단력', '전통적']
  },
  ESFJ: {
    type: 'ESFJ',
    title: 'Consul',
    description: 'Extraordinarily caring, social and popular people, always eager to help.',
    imageUrl: '/images/mbti/esfj.png',
    characteristics: ['배려심', '사교적', '인기있음', '도움을 줌', '협력적']
  },
  ISTP: {
    type: 'ISTP',
    title: 'Virtuoso',
    description: 'Bold and practical experimenters, masters of all kinds of tools.',
    imageUrl: '/images/mbti/istp.png',
    characteristics: ['대담함', '실용적', '실험적', '도구 다루기', '독립적']
  },
  ISFP: {
    type: 'ISFP',
    title: 'Adventurer',
    description: 'Flexible and charming artists, always ready to explore and experience something new.',
    imageUrl: '/images/mbti/isfp.png',
    characteristics: ['유연함', '매력적', '예술적', '탐험적', '새로운 경험']
  },
  ESTP: {
    type: 'ESTP',
    title: 'Entrepreneur',
    description: 'Smart, energetic and very perceptive people, who truly enjoy living on the edge.',
    imageUrl: '/images/mbti/estp.png',
    characteristics: ['똑똑함', '에너지 넘침', '통찰력', '모험적', '즉흥적']
  },
  ESFP: {
    type: 'ESFP',
    title: 'Entertainer',
    description: 'Spontaneous, energetic and enthusiastic people—life is never boring around them.',
    imageUrl: '/images/mbti/esfp.png',
    characteristics: ['즉흥적', '에너지 넘침', '열정적', '재미있음', '사교적']
  },
}

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  const { type } = req.query

  if (typeof type !== 'string') {
    res.status(400).json({ error: 'Invalid type parameter' })
    return
  }

  const data = MBTI_DATA[type.toUpperCase()]

  if (data) {
    res.status(200).json(data)
  } else {
    res.status(404).json({ error: 'MBTI type not found' })
  }
}
