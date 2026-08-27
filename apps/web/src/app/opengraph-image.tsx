import { ImageResponse } from 'next/og';

export const alt = '온도 — 오늘의 흐름을 읽고 마음을 이어가는 곳';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

export default function OpenGraphImage() {
  return new ImageResponse(
    (
      <div
        style={{
          alignItems: 'stretch',
          background: '#f6f7fb',
          color: '#101118',
          display: 'flex',
          height: '100%',
          justifyContent: 'space-between',
          padding: '72px 84px',
          width: '100%',
        }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <div
            style={{
              alignItems: 'center',
              display: 'flex',
              fontSize: 34,
              fontWeight: 800,
              gap: 16,
            }}
          >
            <span
              style={{
                alignItems: 'center',
                background: '#111218',
                borderRadius: 999,
                color: '#fff',
                display: 'flex',
                height: 62,
                justifyContent: 'center',
                width: 62,
              }}
            >
              온
            </span>
            온도 · Ondo
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                fontSize: 76,
                fontWeight: 850,
                letterSpacing: '-3px',
                lineHeight: 1.12,
              }}
            >
              <div style={{ display: 'flex' }}>오늘의 흐름을 읽고,</div>
              <div style={{ display: 'flex' }}>마음을 이어가는 곳</div>
            </div>
            <div style={{ color: '#5f6573', fontSize: 28 }}>
              운세 · 타로 · 사주 · 나를 기억하는 캐릭터 대화
            </div>
          </div>
        </div>
        <div
          style={{
            alignItems: 'center',
            alignSelf: 'center',
            background: '#e7e2ff',
            border: '2px solid #cfc6ff',
            borderRadius: 56,
            display: 'flex',
            fontSize: 48,
            fontWeight: 900,
            height: 260,
            justifyContent: 'center',
            transform: 'rotate(5deg)',
            width: 260,
          }}
        >
          ONDO
        </div>
      </div>
    ),
    size,
  );
}
