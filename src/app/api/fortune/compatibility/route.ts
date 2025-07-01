import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { person1, person2 } = body;

    if (!person1?.name || !person1?.birth_date || !person2?.name || !person2?.birth_date) {
      return NextResponse.json(
        { error: '두 사람의 이름과 생년월일이 모두 필요합니다.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 사주명리학자입니다. 다음 두 사람의 궁합을 분석해주세요.

첫 번째 사람: ${person1.name} (${person1.birth_date})
두 번째 사람: ${person2.name} (${person2.birth_date})

다음 JSON 형식으로 상세한 궁합 분석을 제공해주세요:

{
  "overallScore": 50-100 사이의 종합 궁합 점수,
  "loveScore": 50-100 사이의 연애 궁합 점수,
  "marriageScore": 50-100 사이의 결혼 궁합 점수,
  "careerScore": 50-100 사이의 사업 궁합 점수,
  "dailyLifeScore": 50-100 사이의 일상생활 궁합 점수,
  "personality": {
    "person1": "${person1.name}님의 성격 특성 분석",
    "person2": "${person2.name}님의 성격 특성 분석"
  },
  "strengths": [
    "이 궁합의 장점 1",
    "이 궁합의 장점 2", 
    "이 궁합의 장점 3",
    "이 궁합의 장점 4"
  ],
  "challenges": [
    "주의해야 할 점 1",
    "주의해야 할 점 2",
    "주의해야 할 점 3"
  ],
  "advice": "두 사람에게 주는 구체적인 조언",
  "luckyElements": {
    "color": "행운의 색상 (HEX 코드)",
    "number": 1-9 사이의 행운의 숫자,
    "direction": "행운의 방향 (동쪽/서쪽/남쪽/북쪽)",
    "date": "행운의 날짜 정보"
  }
}

- 모든 텍스트는 한국어로 작성
- 생년월일을 바탕으로 한 구체적인 분석
- 긍정적이면서도 현실적인 조언
- 개인별 성격 특성을 세밀하게 분석`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      overallScore: Math.floor(Math.random() * 51) + 50,
      loveScore: Math.floor(Math.random() * 51) + 50,
      marriageScore: Math.floor(Math.random() * 51) + 50,
      careerScore: Math.floor(Math.random() * 51) + 50,
      dailyLifeScore: Math.floor(Math.random() * 51) + 50,
      personality: {
        person1: `${person1.name}님은 따뜻하고 섬세한 성격으로 상대방의 감정을 잘 이해하는 공감 능력이 뛰어난 분입니다. 책임감이 강하고 신중한 결정을 내리는 타입입니다.`,
        person2: `${person2.name}님은 적극적이고 활발한 성격으로 새로운 도전을 즐기며 리더십이 뛰어난 분입니다. 솔직하고 직선적인 표현을 선호하는 타입입니다.`
      },
      strengths: [
        `${person1.name}님의 섬세함과 ${person2.name}님의 추진력이 완벽하게 조화를 이룹니다`,
        "서로 다른 관점으로 더 나은 해결책을 찾아내는 능력이 뛰어납니다",
        "상호 보완적인 성격으로 서로의 부족한 점을 채워주는 관계입니다",
        "깊은 신뢰를 바탕으로 한 진정한 파트너십을 구축할 수 있습니다",
        "공통된 목표를 향해 함께 노력할 때 큰 시너지를 발휘합니다"
      ],
      challenges: [
        "의사소통 방식의 차이로 인한 오해가 발생할 수 있습니다",
        "결정을 내리는 속도와 방식에서 갈등이 있을 수 있습니다",
        "서로 다른 우선순위와 가치관을 조율하는 노력이 필요합니다",
        "감정 표현 방식의 차이를 이해하고 존중하는 것이 중요합니다"
      ],
      advice: `${person1.name}님은 ${person2.name}님의 직선적인 표현을 부정적으로 받아들이지 마시고, ${person2.name}님은 ${person1.name}님의 섬세한 감정을 충분히 이해해 주세요. 서로의 다름을 인정하고 존중할 때 더욱 깊은 사랑을 나눌 수 있습니다.`,
      luckyElements: {
        color: generateRandomColor(),
        number: Math.floor(Math.random() * 9) + 1,
        direction: ["동쪽", "서쪽", "남쪽", "북쪽"][Math.floor(Math.random() * 4)],
        date: `매월 ${Math.floor(Math.random() * 28) + 1}일이 특히 좋은 날입니다`
      }
    };

    return NextResponse.json({
      success: true,
      compatibility: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Compatibility fortune API error:', error);
    return NextResponse.json(
      { error: '궁합 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function generateRandomColor(): string {
  const colors = [
    "#EC4899", // Pink
    "#8B5CF6", // Purple  
    "#06B6D4", // Cyan
    "#10B981", // Emerald
    "#F59E0B", // Amber
    "#EF4444", // Red
    "#3B82F6", // Blue
    "#84CC16"  // Lime
  ];
  return colors[Math.floor(Math.random() * colors.length)];
} 