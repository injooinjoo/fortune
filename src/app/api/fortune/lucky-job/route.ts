import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';

// 요청 본문의 타입을 정의합니다.
interface JobInfo {
  name: string;
  birth_date: string;
  gender?: string;
  mbti?: string;
  job_experience?: string;
  career_goals?: string[];
  // Genkit 플로우에서 사용하는 다른 필드들
  business_type: string; 
  experience_years: string;
  current_stage: string;
  goals: string[];
}

export async function POST(request: NextRequest) {
  try {
    const body: JobInfo = await request.json();
    
    // 필수 필드 검증
    if (!body.name || !body.birth_date || !body.job_experience || !body.career_goals) {
      return NextResponse.json(
        { error: '필수 정보(이름, 생년월일, 경력, 목표)가 누락되었습니다.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    // BusinessInfoSchema에 맞게 데이터를 변환합니다.
    const userInfo = {
      name: body.name,
      birth_date: body.birth_date,
      gender: body.gender,
      mbti: body.mbti,
      business_type: 'job', // 운세 타입을 명확히 지정
      experience_years: body.job_experience,
      current_stage: body.job_experience, // job_experience를 current_stage로 매핑
      goals: body.career_goals,
    };

    // generateSpecializedFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSpecializedFortune(
      'lucky-job',
      userInfo
    );

    return NextResponse.json(fortuneResult);
    
  } catch (error: any) {
    console.error('Lucky job API error:', error);
    return NextResponse.json(
      { error: '직업운 분석 중 오류가 발생했습니다.', details: error.message },
      { status: 500 }
    );
  }
} 