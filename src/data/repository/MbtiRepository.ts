import type { MbtiInfo } from '../model/MbtiInfo';

export interface MbtiRepository {
  getMbtiInfoByType(type: string): Promise<MbtiInfo>;
}
