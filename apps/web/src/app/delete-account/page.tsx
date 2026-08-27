import type { Metadata } from 'next';

import { LegalPage } from '@/components/legal-page';

export const metadata: Metadata = {
  title: '계정 삭제 안내',
  description:
    'Ondo(온도)에서 계정을 삭제하는 방법과 서비스에 접근할 수 없을 때 이메일로 삭제를 요청하는 방법을 안내합니다.',
  alternates: { canonical: '/delete-account' },
};

export default function DeleteAccountPage() {
  return (
    <LegalPage
      eyebrow="Account Deletion"
      title="Ondo 계정 삭제 안내"
      intro={
        <p>
          계정 삭제는 앱 안에서 직접 진행하는 것이 가장 빠릅니다. 앱을 열 수 없거나 로그인할 수
          없는 경우에는 아래 이메일 경로로 삭제를 요청할 수 있습니다.
        </p>
      }
    >
      <section>
        <h2>1. 앱에서 직접 삭제하기</h2>
        <ol data-testid="in-app-deletion-steps">
          <li>Ondo 앱을 실행하고 계정에 로그인합니다.</li>
          <li>[프로필] 화면으로 이동합니다.</li>
          <li>화면 아래쪽의 [계정 삭제]를 선택합니다.</li>
          <li>안내 문구를 확인하고, 원하면 삭제 사유를 선택합니다. (선택 사항)</li>
          <li>확인 입력란에 <strong>삭제</strong>를 입력한 뒤 삭제를 진행합니다.</li>
        </ol>
        <div className="ondo-notice">
          <p>
            삭제가 완료되면 프로필 정보, 구매 내역, 채팅 기록이 함께 정리되며 계정은 복구할 수
            없습니다. 법령상 보관 의무가 있는 거래 기록은 관련 법령이 정한 기간 동안 보관될 수
            있습니다. 자세한 보관 기준은 <a href="/privacy">개인정보처리방침</a>에서 확인할 수
            있습니다.
          </p>
        </div>
      </section>

      <section>
        <h2>2. 이메일로 삭제 요청하기</h2>
        <div className="ondo-notice" data-testid="deletion-request-fallback">
          <p>
            앱에 접근할 수 없다면{' '}
            <a href="mailto:injooinjoo@gmail.com">injooinjoo@gmail.com</a>으로 계정 삭제를
            요청해 주세요.
          </p>
          <p>메일에 아래 내용을 포함하면 본인 확인과 처리가 빨라집니다.</p>
          <ul>
            <li>제목: 계정 삭제 요청</li>
            <li>가입에 사용한 이메일 주소</li>
            <li>로그인 방식 (Apple / Google / Kakao / Naver / 이메일)</li>
            <li>사용 기기와 OS 버전</li>
          </ul>
          <p>회신 기준: 영업일 기준 7일 이내</p>
        </div>
      </section>

      <section>
        <h2>3. 삭제 전에 확인해 주세요</h2>
        <ul>
          <li>
            구독 상품은 계정 삭제와 별개로 구매한 결제 채널의 구독 관리 화면에서 직접 해지해야
            결제가 중단됩니다.
          </li>
          <li>남아 있는 온도와 구매 혜택은 계정 삭제 시 함께 사라지며 복구되지 않습니다.</li>
          <li>같은 이메일로 다시 가입할 수 있지만, 이전 데이터는 복구되지 않습니다.</li>
        </ul>
      </section>
    </LegalPage>
  );
}
