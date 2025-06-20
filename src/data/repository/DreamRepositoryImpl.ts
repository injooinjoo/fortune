import type { Dream } from '../model/Dream';
import type { DreamRepository } from './DreamRepository';

const DREAMS: Dream[] = [
  {
    id: 1,
    title: '용이 하늘로 올라가는 꿈',
    interpretation: '큰 성공이나 명예를 얻을 수 있는 길몽을 뜻합니다.',
    type: '길몽',
    keywords: ['용', '승천'],
  },
  {
    id: 2,
    title: '이빨이 빠지는 꿈',
    interpretation: '가족이나 가까운 사람과의 이별을 의미할 수 있습니다.',
    type: '흉몽',
    keywords: ['이빨', '치아', '빠짐'],
  },
  {
    id: 3,
    title: '물에서 헤엄치는 꿈',
    interpretation: '새로운 기회가 찾아오거나 재물운이 상승함을 암시합니다.',
    type: '보통',
    keywords: ['물', '헤엄'],
  },
  {
    id: 4,
    title: '높은 곳에서 떨어지는 꿈',
    interpretation: '계획에 차질이 생기거나 좌절을 겪을 수 있음을 경고합니다.',
    type: '흉몽',
    keywords: ['떨어짐', '낙하'],
  },
  {
    id: 5,
    title: '돈을 줍는 꿈',
    interpretation: '예상치 못한 금전적 이득이 찾아올 수 있습니다.',
    type: '길몽',
    keywords: ['돈', '재물'],
  },
];

export class DreamRepositoryImpl implements DreamRepository {
  async searchByKeyword(keyword: string): Promise<Dream[]> {
    const q = keyword.trim();
    if (!q) return [];
    return DREAMS.filter(
      (d) =>
        d.title.includes(q) || d.keywords.some((k) => k.includes(q))
    );
  }
}
