import type { MetadataRoute } from 'next';

import { siteUrl } from '@/lib/env';

/**
 * `/app` 이 route group `(app)` 이 아니라 리터럴 세그먼트인 이유가 여기 있다 —
 * Next 는 괄호 세그먼트를 URL 에서 지우므로, 그렇게 만들었으면
 * 로그인 뒤 화면을 robots 로 제외할 방법이 없다.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/app/', '/auth/', '/api/'],
      },
    ],
    sitemap: `${siteUrl}/sitemap.xml`,
  };
}
