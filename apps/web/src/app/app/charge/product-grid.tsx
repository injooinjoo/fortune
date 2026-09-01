import { productCatalog, storefrontConsumableProductIds } from '@fortune/product-contracts';
import type { ReactNode } from 'react';

export type StorefrontProductId = (typeof storefrontConsumableProductIds)[number];

/**
 * 충전 상품 카드.
 *
 * 결제 화면과 비로그인 안내 화면이 같은 목록을 써야 해서 표현만 떼어냈다.
 * 예전에는 결제 컴포넌트 안에만 있어서, 로그인하지 않은 사람에게는 상품도
 * 가격도 보이지 않고 "Google 계정 연결" 버튼만 나왔다. 얼마인지 모르는 채로
 * 계정부터 연결하라는 순서였고, 통신판매에서 가격은 구매 전에 보여야 한다.
 *
 * `action` 은 카드마다 다른 버튼/링크를 넣는 자리다. 훅을 쓰지 않으므로 서버
 * 컴포넌트에서도 그대로 렌더된다.
 */
export function ChargeProductGrid({
  action,
}: {
  action: (productId: StorefrontProductId) => ReactNode;
}) {
  return (
    <div className="ondo-payment-grid">
      {storefrontConsumableProductIds.map((productId) => {
        const product = productCatalog[productId];
        return (
          <article className="ondo-card ondo-payment-card" key={productId}>
            <p className="ondo-kicker">온도 충전</p>
            {/* 단위 표기는 앱 전체에서 "온도 N개" 로 맞춘다. */}
            <h2>온도 {product.points.toLocaleString('ko-KR')}개</h2>
            <p className="ondo-muted">{product.description}</p>
            <strong>{product.price.toLocaleString('ko-KR')}원</strong>
            {action(productId)}
          </article>
        );
      })}
    </div>
  );
}
