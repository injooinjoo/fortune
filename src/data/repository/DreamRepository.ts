import type { Dream } from '../model/Dream';

export interface DreamRepository {
  searchByKeyword(keyword: string): Promise<Dream[]>;
}
