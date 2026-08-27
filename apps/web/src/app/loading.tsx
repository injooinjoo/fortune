export default function Loading() {
  return (
    <main aria-busy="true" aria-live="polite" className="ondo-container ondo-status-page">
      <span aria-hidden="true" className="ondo-status-pulse" />
      <h1>온도를 맞추고 있어요.</h1>
      <p className="ondo-muted">잠시만 기다려 주세요.</p>
    </main>
  );
}
