import { LegalScreen } from '../src/screens/legal-screen';

export default function PrivacyPolicyRoute() {
  return (
    <LegalScreen
      path="/privacy-policy"
      title="개인정보처리방침"
      summary="수집, 보관, 파기, 권리 행사 경로를 한 화면에서 확인할 수 있습니다."
      sections={[
        {
          title: '수집 항목',
          body: '계정, 프로필, 구매, 사용 맥락은 제품 제공과 복구, 추천 품질 개선에 사용됩니다.',
        },
        {
          title: '보관 및 삭제',
          body: '계정 삭제 요청 전까지는 서비스 이용에 필요한 최소 데이터만 보존합니다.',
        },
      ]}
    />
  );
}
