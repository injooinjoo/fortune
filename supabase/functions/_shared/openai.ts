import { FortuneRequest, FortuneResponse } from './types.ts'

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')

export async function generateFortune(
  fortuneType: string,
  request: FortuneRequest,
  systemPrompt: string
): Promise<Omit<FortuneResponse['fortune'], 'generatedAt'>> {
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured')
  }

  const userPrompt = createUserPrompt(fortuneType, request)

  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.8,
        max_tokens: 1000,
        response_format: { type: 'json_object' }
      }),
    })

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.status}`)
    }

    const data = await response.json()
    const content = data.choices[0].message.content

    return JSON.parse(content)
  } catch (error) {
    console.error('OpenAI generation error:', error)
    throw new Error('Failed to generate fortune')
  }
}

function createUserPrompt(fortuneType: string, request: FortuneRequest): string {
  const parts = [`Generate a ${fortuneType} fortune with the following information:`]

  if (request.name) parts.push(`Name: ${request.name}`)
  if (request.birthDate) parts.push(`Birth Date: ${request.birthDate}`)
  if (request.birthTime) parts.push(`Birth Time: ${request.birthTime}`)
  if (request.isLunar) parts.push(`Calendar Type: Lunar`)
  if (request.gender) parts.push(`Gender: ${request.gender}`)
  if (request.partnerName) parts.push(`Partner Name: ${request.partnerName}`)
  if (request.partnerBirthDate) parts.push(`Partner Birth Date: ${request.partnerBirthDate}`)
  if (request.mbtiType) parts.push(`MBTI Type: ${request.mbtiType}`)
  if (request.bloodType) parts.push(`Blood Type: ${request.bloodType}`)
  if (request.zodiacSign) parts.push(`Zodiac Sign: ${request.zodiacSign}`)

  if (request.additionalInfo) {
    Object.entries(request.additionalInfo).forEach(([key, value]) => {
      parts.push(`${key}: ${value}`)
    })
  }

  parts.push('\nPlease provide the fortune in Korean language with detailed insights and practical advice.')

  return parts.join('\n')
}

export function getSystemPrompt(fortuneType: string): string {
  const basePrompt = `You are a professional fortune teller specializing in ${fortuneType} fortunes.
  Provide insightful, positive, and helpful fortune readings in Korean.

  Return the response in the following JSON format:
  {
    "title": "운세 제목",
    "description": "전체적인 운세 설명 (2-3문단)",
    "details": {
      "overall": "종합운",
      "love": "애정운",
      "career": "직장/사업운",
      "health": "건강운",
      "wealth": "금전운"
    },
    "advice": "조언 및 행동 지침",
    "luckyItems": ["행운의 아이템1", "행운의 아이템2"],
    "warnings": ["주의사항1", "주의사항2"],
    "score": 85,
    "period": "유효 기간"
  }`

  const specificPrompts: Record<string, string> = {
    daily: 'Focus on what will happen today specifically. Be precise about timing.',
    weekly: 'Provide day-by-day breakdown for the upcoming week.',
    monthly: 'Include important dates and overall monthly trends.',
    yearly: 'Provide seasonal breakdowns and major life events for the year.',
    saju: 'Analyze the four pillars of destiny based on birth date and time.',
    mbti: 'Incorporate MBTI personality traits into the fortune reading.',
    compatibility: 'Focus on relationship dynamics and compatibility scores.',
    career: 'Emphasize professional growth, opportunities, and challenges.',
    wealth: 'Focus on financial opportunities, investments, and money management.',
    celebrity: 'Focus on the connection between the user and the celebrity, providing unique insights about their compatibility and shared destiny.',
  }

  return `${basePrompt}\n\n${specificPrompts[fortuneType] || ''}`
}
