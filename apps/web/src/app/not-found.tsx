import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="ondo-container ondo-status-page">
      <p className="ondo-eyebrow">404</p>
      <h1>요청한 화면을 찾을 수 없어요.</h1>
      <p className="ondo-muted">주소가 바뀌었거나 더 이상 제공하지 않는 화면일 수 있어요.</p>
      <div className="ondo-account-actions">
        <Link className="ondo-button ondo-button--primary" href="/">
          온도 홈으로
        </Link>
        <Link className="ondo-button ondo-button--secondary" href="/support">
          도움받기
        </Link>
      </div>
    </main>
  );
}
