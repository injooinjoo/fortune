'use client';

import { usePathname } from 'next/navigation';
import Script from 'next/script';
import { useEffect } from 'react';

import { trackProductEvent } from '@/lib/analytics-client';

export function Analytics({ measurementId }: { measurementId: string }) {
  const pathname = usePathname();

  useEffect(() => {
    trackProductEvent('page_view', { path: pathname });
  }, [pathname]);

  useEffect(() => {
    function onError() {
      trackProductEvent('client_error', { error_kind: 'window_error' });
    }
    function onUnhandledRejection() {
      trackProductEvent('client_error', { error_kind: 'unhandled_rejection' });
    }

    window.addEventListener('error', onError);
    window.addEventListener('unhandledrejection', onUnhandledRejection);
    return () => {
      window.removeEventListener('error', onError);
      window.removeEventListener('unhandledrejection', onUnhandledRejection);
    };
  }, []);

  if (!measurementId) return null;

  return (
    <>
      <Script src={`https://www.googletagmanager.com/gtag/js?id=${measurementId}`} strategy="afterInteractive" />
      <Script id="ondo-ga4" strategy="afterInteractive">
        {`window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}window.gtag=gtag;gtag('js',new Date());gtag('config','${measurementId}',{send_page_view:false,allow_google_signals:false});`}
      </Script>
    </>
  );
}
