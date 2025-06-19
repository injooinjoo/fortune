import type { MbtiInfo } from '../model/MbtiInfo';
import type { MbtiRepository } from './MbtiRepository';

const MBTI_INFOS: MbtiInfo[] = [
  { type: 'ISTJ', description: '신중하고 책임감이 강한 현실주의자' },
  { type: 'ISFJ', description: '성실하고 온화하며 협조를 잘하는 조력자' },
  { type: 'INFJ', description: '통찰력이 뛰어나며 사람을 돌보는 조언자' },
  { type: 'INTJ', description: '독창적이고 철저한 계획을 세우는 전략가' },
  { type: 'ISTP', description: '과묵하지만 필요할 때 단호한 행동파' },
  { type: 'ISFP', description: '따뜻하고 겸손하며 조화를 중시하는 예술가' },
  { type: 'INFP', description: '이상주의적이며 사람과 가치에 충실한 중재자' },
  { type: 'INTP', description: '호기심이 많고 아이디어가 풍부한 논리학자' },
  { type: 'ESTP', description: '현실적이며 대담한 문제 해결사' },
  { type: 'ESFP', description: '사교적이고 열정적인 엔터테이너' },
  { type: 'ENFP', description: '상상력이 풍부하고 자유로운 활동가' },
  { type: 'ENTP', description: '지적 도전을 즐기는 토론가' },
  { type: 'ESTJ', description: '체계적이고 책임감 있는 관리자' },
  { type: 'ESFJ', description: '사람을 돕고 협동을 중시하는 사교가' },
  { type: 'ENFJ', description: '타인을 이끄는 데 능숙한 선도자' },
  { type: 'ENTJ', description: '목표 지향적이며 통솔력이 뛰어난 지도자' },
];

export class MbtiRepositoryImpl implements MbtiRepository {
  async getMbtiInfoByType(type: string): Promise<MbtiInfo> {
    const info = MBTI_INFOS.find((item) => item.type === type.toUpperCase());
    if (!info) {
      throw new Error(`Unknown MBTI type: ${type}`);
    }
    return info;
  }
}
