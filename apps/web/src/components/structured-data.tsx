/**
 * schema.org JSON-LD.
 *
 * 홈에 구조화 데이터가 하나도 없었다. 검색 결과에서 사이트 이름·검색창·
 * 서비스 목록이 붙지 않고 그냥 파란 링크 하나로 나온다는 뜻이다. 운세는
 * 브랜드 검색("온도 운세")과 종류 검색("띠별 운세")이 같이 들어오는 분야라
 * 이걸 비워두면 손해가 크다.
 *
 * `<script type="application/ld+json">` 은 실행되지 않고 파서만 읽는다.
 * 값은 전부 우리 카탈로그에서 오고 사용자 입력이 섞이지 않지만, 그래도
 * `<` 를 이스케이프해 태그가 닫히는 일이 없게 한다.
 */
function JsonLd({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(data).replaceAll('<', '\\u003c'),
      }}
      type="application/ld+json"
    />
  );
}

export function WebSiteStructuredData({
  siteUrl,
  name,
  description,
}: {
  siteUrl: string;
  name: string;
  description: string;
}) {
  return (
    <JsonLd
      data={{
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        name,
        alternateName: 'ONDO',
        url: siteUrl,
        description,
        inLanguage: 'ko-KR',
        publisher: { '@type': 'Organization', name, url: siteUrl },
      }}
    />
  );
}

/**
 * 운세 목록을 `ItemList` 로 알린다. 각 항목이 실제 랜딩 URL 을 가리키므로
 * 종류별 페이지가 색인 후보로 같이 잡힌다.
 */
export function FortuneListStructuredData({
  siteUrl,
  items,
}: {
  siteUrl: string;
  items: ReadonlyArray<{ name: string; path: string; description: string }>;
}) {
  return (
    <JsonLd
      data={{
        '@context': 'https://schema.org',
        '@type': 'ItemList',
        name: '온도에서 볼 수 있는 운세',
        numberOfItems: items.length,
        itemListElement: items.map((item, index) => ({
          '@type': 'ListItem',
          position: index + 1,
          name: item.name,
          description: item.description,
          // 한글 경로는 인코딩해서 내보낸다. 구분자(/)는 그대로 둔다.
          url: `${siteUrl}/${encodeURI(item.path)}`,
        })),
      }}
    />
  );
}
