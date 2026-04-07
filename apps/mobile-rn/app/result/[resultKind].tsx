import { useLocalSearchParams } from 'expo-router';

import { Card } from '../../src/components/card';
import { AppText } from '../../src/components/app-text';
import { FortuneResultLayout } from '../../src/features/fortune-results/primitives';
import { resultMetadataByKind } from '../../src/features/fortune-results/mapping';
import { RenderFortuneResult } from '../../src/features/fortune-results/registry';
import { isResultKind } from '../../src/features/fortune-results/types';

export default function ResultRoute() {
  const params = useLocalSearchParams<{ resultKind?: string }>();
  const resultKind = params.resultKind;

  if (!resultKind || !isResultKind(resultKind)) {
    return (
      <FortuneResultLayout
        metadata={{
          resultKind: 'traditional-saju',
          fortuneCode: 'ERR',
          paperNodeId: 'n/a',
          title: '결과 라우트 오류',
          subtitle: '유효하지 않은 결과 화면 요청입니다.',
          eyebrow: '결과 화면',
        }}
      >
        <Card>
          <AppText variant="heading4">결과 종류를 찾을 수 없습니다.</AppText>
          <AppText variant="bodySmall">
            요청한 결과 화면을 준비하지 못해 기본 결과 화면으로 안내합니다.
          </AppText>
        </Card>
      </FortuneResultLayout>
    );
  }

  return (
    <FortuneResultLayout metadata={resultMetadataByKind[resultKind]}>
      <RenderFortuneResult resultKind={resultKind} />
    </FortuneResultLayout>
  );
}
