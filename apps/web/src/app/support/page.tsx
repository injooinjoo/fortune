import type { Metadata } from 'next';

import { LegalPage } from '@/components/legal-page';

export const metadata: Metadata = {
  title: '고객 지원',
  description:
    'Ondo(온도) 사용 문의, 결제 이슈, 계정 삭제 요청, 개인정보 문의 접수 경로를 안내합니다.',
  alternates: { canonical: '/support' },
};

export default function SupportPage() {
  return (
    <LegalPage
      eyebrow="Support"
      title="Ondo 고객 지원"
      intro={<p>서비스 이용 문의, 결제 이슈, 계정 삭제 요청, 개인정보 문의를 아래 경로로 접수할 수 있습니다.</p>}
    >
      <section>
        <h2>1. 문의 채널</h2>
        <ul>
          <li>
            문의 접수: <a href="mailto:injooinjoo@gmail.com">injooinjoo@gmail.com</a> (일반
            지원과 개인정보 문의 모두 같은 주소로 접수합니다)
          </li>
          <li>운영 시간: 평일 10:00~18:00 (주말·공휴일 휴무)</li>
          <li>회신 기준: 영업일 기준 7일 이내</li>
        </ul>
      </section>

      <section>
        <h2>2. 계정 및 결제 안내</h2>
        <ul>
          <li>
            계정 삭제: 앱 내 [프로필 &gt; 계정 삭제]에서 직접 진행할 수 있습니다. 자세한 절차와
            이메일 요청 방법은 <a href="/delete-account">계정 삭제 안내</a>를 확인해 주세요.
          </li>
          <li>
            구매·구독 관리와 환불은 구매한 웹 또는 앱 스토어의 표시 조건과 관련 법령을 적용합니다.
          </li>
          <li>
            문의 시 계정 이메일, 기기 모델, OS 버전, 문제 화면을 함께 보내주면 확인이 빨라집니다.
          </li>
        </ul>
      </section>

      <section>
        <h2>3. 참고 링크</h2>
        <ul>
          <li><a href="/privacy">개인정보처리방침</a></li>
          <li><a href="/terms">이용약관</a></li>
          <li><a href="/delete-account">계정 삭제 안내</a></li>
          <li>
            <a href="/.well-known/apple-app-site-association">Apple universal links file</a>
          </li>
          <li><a href="/.well-known/assetlinks.json">Android asset links file</a></li>
        </ul>
      </section>
    </LegalPage>
  );
}
