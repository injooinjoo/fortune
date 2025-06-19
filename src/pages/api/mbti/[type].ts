import type { NextApiRequest, NextApiResponse } from 'next'

interface MbtiInfo {
  type: string
  title: string
  description: string
  imageUrl: string
}

const MBTI_DATA: Record<string, MbtiInfo> = {
  INTJ: {
    type: 'INTJ',
    title: 'Architect',
    description: 'Imaginative and strategic thinkers, with a plan for everything.',
    imageUrl: '/images/mbti/intj.png',
  },
  INTP: {
    type: 'INTP',
    title: 'Logician',
    description: 'Innovative inventors with an unquenchable thirst for knowledge.',
    imageUrl: '/images/mbti/intp.png',
  },
  ENTJ: {
    type: 'ENTJ',
    title: 'Commander',
    description: 'Bold, imaginative and strong-willed leaders, always finding a way or making one.',
    imageUrl: '/images/mbti/entj.png',
  },
  ENTP: {
    type: 'ENTP',
    title: 'Debater',
    description: 'Smart and curious thinkers who cannot resist an intellectual challenge.',
    imageUrl: '/images/mbti/entp.png',
  },
  INFJ: {
    type: 'INFJ',
    title: 'Advocate',
    description: 'Quiet and mystical, yet very inspiring and tireless idealists.',
    imageUrl: '/images/mbti/infj.png',
  },
  INFP: {
    type: 'INFP',
    title: 'Mediator',
    description: 'Poetic, kind and altruistic people, always eager to help a good cause.',
    imageUrl: '/images/mbti/infp.png',
  },
  ENFJ: {
    type: 'ENFJ',
    title: 'Protagonist',
    description: 'Charismatic and inspiring leaders, able to mesmerize their listeners.',
    imageUrl: '/images/mbti/enfj.png',
  },
  ENFP: {
    type: 'ENFP',
    title: 'Campaigner',
    description: 'Enthusiastic, creative and sociable free spirits, who can always find a reason to smile.',
    imageUrl: '/images/mbti/enfp.png',
  },
  ISTJ: {
    type: 'ISTJ',
    title: 'Logistician',
    description: 'Practical and fact-minded individuals, whose reliability cannot be doubted.',
    imageUrl: '/images/mbti/istj.png',
  },
  ISFJ: {
    type: 'ISFJ',
    title: 'Defender',
    description: 'Very dedicated and warm protectors, always ready to defend their loved ones.',
    imageUrl: '/images/mbti/isfj.png',
  },
  ESTJ: {
    type: 'ESTJ',
    title: 'Executive',
    description: 'Excellent administrators, unsurpassed at managing things—or people.',
    imageUrl: '/images/mbti/estj.png',
  },
  ESFJ: {
    type: 'ESFJ',
    title: 'Consul',
    description: 'Extraordinarily caring, social and popular people, always eager to help.',
    imageUrl: '/images/mbti/esfj.png',
  },
  ISTP: {
    type: 'ISTP',
    title: 'Virtuoso',
    description: 'Bold and practical experimenters, masters of all kinds of tools.',
    imageUrl: '/images/mbti/istp.png',
  },
  ISFP: {
    type: 'ISFP',
    title: 'Adventurer',
    description: 'Flexible and charming artists, always ready to explore and experience something new.',
    imageUrl: '/images/mbti/isfp.png',
  },
  ESTP: {
    type: 'ESTP',
    title: 'Entrepreneur',
    description: 'Smart, energetic and very perceptive people, who truly enjoy living on the edge.',
    imageUrl: '/images/mbti/estp.png',
  },
  ESFP: {
    type: 'ESFP',
    title: 'Entertainer',
    description: 'Spontaneous, energetic and enthusiastic people—life is never boring around them.',
    imageUrl: '/images/mbti/esfp.png',
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
