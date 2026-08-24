import { Disclaimer } from '@/features/fortune/result';

const PUBLIC_DOCUMENTS = [
  { href: 'https://fortune-mocha.vercel.app/privacy', label: '개인정보처리방침' },
  { href: 'https://fortune-mocha.vercel.app/terms', label: '이용약관' },
  { href: 'https://fortune-mocha.vercel.app/support', label: '고객 지원' },
  { href: 'https://fortune-mocha.vercel.app/delete-account', label: '계정 삭제 안내' },
] as const;

export function SiteFooter() {
  return (
    <footer className="ondo-site-footer">
      <div className="ondo-footer-inner">
        <div className="ondo-footer-brand">
          <strong>온도 · ONDO</strong>
          <Disclaimer />
        </div>
        <nav className="ondo-footer-links" aria-label="운영 정보">
          {PUBLIC_DOCUMENTS.map((document) => (
            <a href={document.href} key={document.href}>{document.label}</a>
          ))}
        </nav>
      </div>
      <p className="ondo-footer-bottom">© ONDO · 오늘의 마음을 읽는 작은 리딩</p>
    </footer>
  );
}
