import { LegalScreen } from '../src/screens/legal-screen';

export default function TermsRoute() {
  return (
    <LegalScreen
      path="/terms-of-service"
      title="이용약관"
      summary="결제, 구독, 계정, 콘텐츠 이용 규칙을 확인할 수 있습니다."
      sections={[
        {
          title: '결제 및 구독',
          body: '스토어 결제와 구독 갱신은 각 플랫폼 정책과 검증 플로우를 따릅니다.',
        },
        {
          title: '계정 책임',
          body: '사용자는 자신의 계정 보안과 제출 정보의 정확성을 유지해야 합니다.',
        },
      ]}
    />
  );
}
