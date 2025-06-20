export interface Dream {
  id: number;
  title: string;
  interpretation: string;
  type: '길몽' | '흉몽' | '보통';
  keywords: string[];
}
