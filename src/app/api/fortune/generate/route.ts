import { NextRequest, NextResponse } from 'next/server';
import { 
  generateComprehensiveDailyFortune, 
  generateLifeProfile, 
  generateInteractiveFortune,
  generateGroupFortune,
} from '@/ai/flows/generate-specialized-fortune';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { flowType, ...input } = body;

    let result: any;

    switch (flowType) {
      case 'generateLifeProfile':
        result = await generateLifeProfile(input);
        break;
      case 'generateComprehensiveDailyFortune':
        result = await generateComprehensiveDailyFortune(input);
        break;
      case 'generateInteractiveFortune':
        result = await generateInteractiveFortune(input);
        break;
      case 'generateGroupFortune':
        result = await generateGroupFortune(input);
        break;
      default:
        return NextResponse.json({ error: 'Invalid flowType provided' }, { status: 400 });
    }

    return NextResponse.json(result);
  } catch (error: any) {
    console.error('[API /fortune/generate] Error:', error);
    return NextResponse.json({ error: error.message || 'Internal Server Error' }, { status: 500 });
  }
}