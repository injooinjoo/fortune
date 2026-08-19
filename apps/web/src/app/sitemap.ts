import type { MetadataRoute } from 'next';

import { siteUrl } from '@/lib/env';

/**
 * 공개 색인 대상만 넣는다. `/app/*` 과 `/auth/*` 는 robots 에서 제외한
 * 로그인 뒤 화면이라 sitemap 에도 넣지 않는다.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: siteUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      // 한글 경로는 sitemap 에서 퍼센트 인코딩돼야 한다.
      url: `${siteUrl}/${encodeURI('운세/오늘')}`,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.9,
    },
  ];
}
