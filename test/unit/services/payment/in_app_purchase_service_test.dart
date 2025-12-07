/// In-App Purchase Service - Unit Test
/// 인앱 결제 서비스 유닛 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/mock_payment_services.dart';

void main() {
  late MockInAppPurchaseService mockPurchaseService;
  late MockTokenService mockTokenService;
  late MockSubscriptionService mockSubscriptionService;

  setUpAll(() {
    registerPaymentFallbackValues();
  });

  setUp(() {
    mockPurchaseService = MockInAppPurchaseService();
    mockTokenService = MockTokenService();
    mockSubscriptionService = MockSubscriptionService();
  });

  group('InAppPurchaseService 테스트', () {
    group('상품 조회', () {
      test('토큰 패키지 목록을 조회할 수 있어야 함', () async {
        final products = await mockPurchaseService.getProducts();

        expect(products, isNotEmpty);
        expect(products.length, equals(4));
        expect(products.any((p) => p['id'] == 'token_100'), isTrue);
      });

      test('구독 상품 목록을 조회할 수 있어야 함', () async {
        final subscriptions = await mockPurchaseService.getSubscriptions();

        expect(subscriptions, isNotEmpty);
        expect(subscriptions.length, equals(2));
        expect(subscriptions.any((s) => s['id'] == 'premium_monthly'), isTrue);
        expect(subscriptions.any((s) => s['id'] == 'premium_yearly'), isTrue);
      });

      test('인기 상품이 표시되어야 함', () async {
        final products = await mockPurchaseService.getProducts();
        final popularProduct = products.firstWhere(
          (p) => p['is_popular'] == true,
          orElse: () => <String, dynamic>{},
        );

        expect(popularProduct, isNotEmpty);
        expect(popularProduct['id'], equals('token_100'));
      });

      test('보너스 토큰이 있는 패키지가 있어야 함', () async {
        final products = await mockPurchaseService.getProducts();
        final bonusProducts = products.where(
          (p) => (p['bonus_tokens'] as int?) != null && p['bonus_tokens'] > 0,
        );

        expect(bonusProducts, isNotEmpty);
      });

      test('가격 문자열이 올바르게 형식화되어야 함', () async {
        final products = await mockPurchaseService.getProducts();
        final product = products.firstWhere((p) => p['id'] == 'token_100');

        expect(product['price_string'], contains('₩'));
        expect(product['price_string'], contains('5,000'));
      });
    });

    group('구매 처리', () {
      test('토큰 구매가 성공해야 함', () async {
        final result = await mockPurchaseService.purchaseProduct('token_100');

        expect(result['status'], equals('completed'));
        expect(result['product_id'], equals('token_100'));
        expect(result['transaction_id'], isNotNull);
      });

      test('구매 결과에 트랜잭션 ID가 포함되어야 함', () async {
        final result = await mockPurchaseService.purchaseProduct('token_100');

        expect(result['transaction_id'], isNotNull);
        expect(result['transaction_id'].toString(), startsWith('txn_'));
      });

      test('구매 결과에 구매 시간이 기록되어야 함', () async {
        final result = await mockPurchaseService.purchaseProduct('token_100');

        expect(result['purchased_at'], isNotNull);
      });
    });

    group('구매 검증', () {
      test('유효한 구매가 검증되어야 함', () async {
        final result = await mockPurchaseService.verifyPurchase('txn_123');

        expect(result['is_valid'], isTrue);
        expect(result['transaction_id'], equals('txn_123'));
      });

      test('검증 결과에 상품 ID가 포함되어야 함', () async {
        final result = await mockPurchaseService.verifyPurchase('txn_123');

        expect(result['product_id'], isNotNull);
      });

      test('검증 시간이 기록되어야 함', () async {
        final result = await mockPurchaseService.verifyPurchase('txn_123');

        expect(result['verified_at'], isNotNull);
      });
    });

    group('구매 복원', () {
      test('구매 복원이 성공해야 함', () async {
        final result = await mockPurchaseService.restorePurchases();

        expect(result, isTrue);
      });
    });
  });

  group('TokenService 테스트', () {
    group('잔액 조회', () {
      test('토큰 잔액을 조회할 수 있어야 함', () async {
        final balance = await mockTokenService.getBalance('test-user-id');

        expect(balance['remaining_tokens'], isNotNull);
        expect(balance['remaining_tokens'], equals(100));
      });

      test('무제한 이용권 상태를 확인할 수 있어야 함', () async {
        final balance = await mockTokenService.getBalance('test-user-id');

        expect(balance['is_unlimited'], isNotNull);
      });
    });

    group('토큰 차감', () {
      test('토큰 차감이 성공해야 함', () async {
        final result = await mockTokenService.deductTokens('test-user-id', 10);

        expect(result, isTrue);
      });
    });

    group('토큰 추가', () {
      test('토큰 추가가 성공해야 함', () async {
        final result = await mockTokenService.addTokens('test-user-id', 100);

        expect(result['remaining_tokens'], greaterThan(100));
      });
    });

    group('사용 내역', () {
      test('토큰 사용 내역을 조회할 수 있어야 함', () async {
        final history = await mockTokenService.getUsageHistory('test-user-id');

        expect(history, isNotEmpty);
        expect(history.length, equals(10));
      });

      test('사용 내역에 운세 타입이 포함되어야 함', () async {
        final history = await mockTokenService.getUsageHistory('test-user-id');

        for (final record in history) {
          expect(record['fortune_type'], isNotNull);
          expect(record['fortune_name'], isNotNull);
        }
      });

      test('사용 내역에 사용 시간이 기록되어야 함', () async {
        final history = await mockTokenService.getUsageHistory('test-user-id');

        for (final record in history) {
          expect(record['used_at'], isNotNull);
        }
      });
    });
  });

  group('SubscriptionService 테스트', () {
    group('구독 상태 조회', () {
      test('구독 상태를 조회할 수 있어야 함', () async {
        final status = await mockSubscriptionService.getStatus('test-user-id');

        expect(status['is_active'], isNotNull);
        expect(status['plan'], isNotNull);
      });

      test('활성 구독의 만료일을 확인할 수 있어야 함', () async {
        final status = await mockSubscriptionService.getStatus('test-user-id');

        expect(status['end_date'], isNotNull);
        expect(status['days_remaining'], isNotNull);
      });

      test('자동 갱신 여부를 확인할 수 있어야 함', () async {
        final status = await mockSubscriptionService.getStatus('test-user-id');

        expect(status['auto_renew'], isNotNull);
      });
    });

    group('구독 취소', () {
      test('구독 취소가 성공해야 함', () async {
        final result = await mockSubscriptionService.cancelSubscription('test-user-id');

        expect(result, isTrue);
      });
    });

    group('구독 신청', () {
      test('월간 구독이 성공해야 함', () async {
        final result = await mockSubscriptionService.subscribe(
          'test-user-id',
          'premium_monthly',
        );

        expect(result['is_active'], isTrue);
        expect(result['plan'], equals('premium_monthly'));
      });

      test('연간 구독이 성공해야 함', () async {
        final result = await mockSubscriptionService.subscribe(
          'test-user-id',
          'premium_yearly',
        );

        expect(result['is_active'], isTrue);
        expect(result['plan'], equals('premium_yearly'));
      });
    });
  });

  group('PaymentTestData 테스트', () {
    group('토큰 잔액 생성', () {
      test('기본 토큰 잔액이 생성되어야 함', () {
        final balance = PaymentTestData.createTokenBalance();

        expect(balance['remaining_tokens'], equals(100));
        expect(balance['is_unlimited'], isFalse);
      });

      test('무제한 토큰 잔액이 생성되어야 함', () {
        final balance = PaymentTestData.createTokenBalance(isUnlimited: true);

        expect(balance['is_unlimited'], isTrue);
      });

      test('커스텀 토큰 잔액이 생성되어야 함', () {
        final balance = PaymentTestData.createTokenBalance(remainingTokens: 500);

        expect(balance['remaining_tokens'], equals(500));
      });
    });

    group('토큰 패키지 생성', () {
      test('기본 토큰 패키지가 생성되어야 함', () {
        final package = PaymentTestData.createTokenPackage();

        expect(package['id'], equals('token_100'));
        expect(package['tokens'], equals(100));
        expect(package['price'], equals(5000));
      });

      test('보너스 토큰이 포함된 패키지가 생성되어야 함', () {
        final package = PaymentTestData.createTokenPackage(
          tokens: 300,
          bonusTokens: 50,
        );

        expect(package['tokens'], equals(300));
        expect(package['bonus_tokens'], equals(50));
        expect(package['total_tokens'], equals(350));
      });
    });

    group('구독 상품 생성', () {
      test('월간 구독 상품이 생성되어야 함', () {
        final product = PaymentTestData.createSubscriptionProduct();

        expect(product['id'], equals('premium_monthly'));
        expect(product['period'], equals('monthly'));
        expect(product['features'], isNotEmpty);
      });

      test('연간 구독 상품이 생성되어야 함', () {
        final product = PaymentTestData.createSubscriptionProduct(
          id: 'premium_yearly',
          period: 'yearly',
          isBestValue: true,
        );

        expect(product['period'], equals('yearly'));
        expect(product['is_best_value'], isTrue);
      });
    });

    group('구매 기록 생성', () {
      test('완료된 구매 기록이 생성되어야 함', () {
        final record = PaymentTestData.createPurchaseRecord();

        expect(record['status'], equals('completed'));
        expect(record['transaction_id'], isNotNull);
      });

      test('다양한 상태의 구매 기록이 생성되어야 함', () {
        final pending = PaymentTestData.createPurchaseRecord(status: 'pending');
        final failed = PaymentTestData.createPurchaseRecord(status: 'failed');
        final refunded = PaymentTestData.createPurchaseRecord(status: 'refunded');

        expect(pending['status'], equals('pending'));
        expect(failed['status'], equals('failed'));
        expect(refunded['status'], equals('refunded'));
      });
    });

    group('구독 상태 생성', () {
      test('활성 구독 상태가 생성되어야 함', () {
        final status = PaymentTestData.createSubscriptionStatus();

        expect(status['is_active'], isTrue);
        expect(status['status'], equals('active'));
      });

      test('취소된 구독 상태가 생성되어야 함', () {
        final status = PaymentTestData.createSubscriptionStatus(
          status: 'cancelled',
          autoRenew: false,
        );

        expect(status['status'], equals('cancelled'));
        expect(status['auto_renew'], isFalse);
      });

      test('만료된 구독 상태가 생성되어야 함', () {
        final status = PaymentTestData.createSubscriptionStatus(
          isActive: false,
          status: 'expired',
        );

        expect(status['is_active'], isFalse);
        expect(status['status'], equals('expired'));
      });
    });

    group('혜택 목록', () {
      test('프리미엄 혜택 목록이 있어야 함', () {
        final benefits = PaymentTestData.getPremiumBenefits();

        expect(benefits, isNotEmpty);
        expect(benefits.length, greaterThanOrEqualTo(4));
      });

      test('각 혜택에 아이콘, 제목, 설명이 있어야 함', () {
        final benefits = PaymentTestData.getPremiumBenefits();

        for (final benefit in benefits) {
          expect(benefit['icon'], isNotNull);
          expect(benefit['title'], isNotNull);
          expect(benefit['description'], isNotNull);
        }
      });
    });

    group('에러 데이터', () {
      test('결제 에러 데이터가 생성되어야 함', () {
        final error = PaymentTestData.createPaymentError();

        expect(error['error'], isTrue);
        expect(error['code'], equals('payment_failed'));
        expect(error['message'], isNotNull);
      });

      test('커스텀 에러 데이터가 생성되어야 함', () {
        final error = PaymentTestData.createPaymentError(
          code: 'insufficient_funds',
          message: '잔액이 부족합니다',
        );

        expect(error['code'], equals('insufficient_funds'));
        expect(error['message'], equals('잔액이 부족합니다'));
      });
    });

    group('검증 결과', () {
      test('유효한 검증 결과가 생성되어야 함', () {
        final result = PaymentTestData.createVerificationResult();

        expect(result['is_valid'], isTrue);
        expect(result['product_id'], isNotNull);
      });

      test('무효한 검증 결과가 생성되어야 함', () {
        final result = PaymentTestData.createVerificationResult(
          isValid: false,
          errorMessage: '유효하지 않은 영수증입니다',
        );

        expect(result['is_valid'], isFalse);
        expect(result['error_message'], isNotNull);
      });
    });
  });
}
