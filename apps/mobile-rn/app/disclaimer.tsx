import { LegalScreen } from '../src/screens/legal-screen';

export default function DisclaimerRoute() {
  return (
    <LegalScreen
      path="/disclaimer"
      title="면책 조항"
      summary="이 앱은 오락 목적으로 제공됩니다."
      sections={[
        {
          title: '오락 목적 안내',
          body: '이 앱은 오락 목적으로 제공됩니다. AI가 생성한 인사이트는 실제 예측이 아니며, 전문적인 조언을 대체하지 않습니다.',
        },
        {
          title: '면책 범위',
          body: '본 앱에서 제공하는 운세, 사주, 궁합 등의 결과는 AI 모델이 생성한 오락용 콘텐츠이며, 의료, 법률, 금융 등 전문 분야의 조언으로 사용해서는 안 됩니다.',
        },
        {
          title: '사용자 책임',
          body: '앱의 콘텐츠를 근거로 한 의사결정에 대한 책임은 사용자 본인에게 있습니다. 전문적인 도움이 필요한 경우 해당 분야의 전문가에게 상담하시기 바랍니다.',
        },
      ]}
    />
  );
}
