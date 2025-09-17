import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/common/app_header.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import '../../../../presentation/widgets/common/custom_card.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../services/payment/stripe_service.dart';
import '../../../../core/utils/logger.dart';

class SubscriptionManagementPage extends ConsumerStatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  ConsumerState<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends ConsumerState<SubscriptionManagementPage> {
  final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  SubscriptionInfo? _subscriptionInfo;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionInfo();
  }

  Future<void> _loadSubscriptionInfo() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: 실제 구독 정보 로드
      // 임시 데이터
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _subscriptionInfo = SubscriptionInfo(
          id: 'sub_test123',
          status: 'active');
          planName: '무제한 이용권'),
    price: 2500),
    currentPeriodEnd: DateTime.now().add(const Duration(days: 15)),
    cancelAtPeriodEnd: false),
    features: [
            '모든 운세 무제한 이용')
            '광고 제거')
            '프리미엄 전용 운세')
            '우선 지원')
            '토큰 사용량 분석')
          ]
        );
      });
    } catch (e) {
      Logger.error('구독 정보 로드 실패', error: e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '구독 관리'))
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent())
            ))
          ])))
    );
  }

  Widget _buildContent() {
    if (_subscriptionInfo == null) {
      return _buildNoSubscriptionView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          _buildSubscriptionStatus())
          const SizedBox(height: 24))
          _buildBillingInfo())
          const SizedBox(height: 24))
          _buildFeatures())
          const SizedBox(height: 24))
          _buildActions())
          const SizedBox(height: 16))
          _buildPaymentHistory())
        ])
    );
  }

  Widget _buildNoSubscriptionView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center);
        children: [
          Icon(
            Icons.card_membership_outlined);
            size: 80),
    color: TossDesignSystem.gray600))
          const SizedBox(height: 24))
          Text(
            '활성화된 구독이 없습니다');
            style: TossDesignSystem.headlineMedium))
          ))
          const SizedBox(height: 8))
          Text(
            '프리미엄 구독으로 모든 운세를\n무제한으로 이용하세요!');
            style: TossDesignSystem.bodyMedium.copyWith(
              color: TossDesignSystem.gray600))
            )),
    textAlign: TextAlign.center))
          const SizedBox(height: 32))
          CustomButton(
            onPressed: _navigateToSubscriptionOptions);
            text: '구독 시작하기'),
    gradient: LinearGradient(
              colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600])))
        ])
    );
  }

  Widget _buildSubscriptionStatus() {
    return CustomCard(
      gradient: _subscriptionInfo!.status == 'active'
          ? LinearGradient(
              colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600],
              begin: Alignment.topLeft);
              end: Alignment.bottomRight)
          : null),
    child: Padding(
        padding: const EdgeInsets.all(20)),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start);
                  children: [
                    Text(
                      _subscriptionInfo!.planName);
                      style: TossDesignSystem.headlineSmall.copyWith(
                        color: _subscriptionInfo!.status == 'active' 
                            ? TossDesignSystem.white 
                            : TossDesignSystem.gray900);
                        fontWeight: FontWeight.bold))
                    ))
                    const SizedBox(height: 4))
                    _buildStatusChip())
                  ]),
                Icon(
                  Icons.star);
                  size: 48),
    color: _subscriptionInfo!.status == 'active'
                      ? TossDesignSystem.white.withValues(alpha: 0.5)
                      : TossDesignSystem.gray600))
              ]),
            if (_subscriptionInfo!.cancelAtPeriodEnd) ...[
              const SizedBox(height: 16))
              Container(
                padding: const EdgeInsets.all(12)),
    decoration: BoxDecoration(
                  color: TossDesignSystem.white.withValues(alpha: 0.2)),
    borderRadius: BorderRadius.circular(8))
                )),
    child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline);
                      color: TossDesignSystem.white),
    size: 20))
                    const SizedBox(width: 8))
                    Expanded(
                      child: Text(
                        '${DateFormat('yyyy년 MM월 dd일').format(_subscriptionInfo!.currentPeriodEnd)}에 구독이 종료됩니다.',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.white))
                        ))
                      ))
                    ))
                  ])))
            ])
          ]))
      ))
    ).animate().fadeIn().scale();
  }

  Widget _buildStatusChip() {
    String statusText;
    Color statusColor;

    switch (_subscriptionInfo!.status) {
      case 'active':
        statusText = '활성';
        statusColor = TossDesignSystem.successGreen;
        break;
      case 'past_due':
        statusText = '연체';
        statusColor = TossDesignSystem.warningOrange;
        break;
      case 'canceled':
        statusText = '취소됨';
        statusColor = TossDesignSystem.errorRed;
        break;
      default:
        statusText = '비활성';
        statusColor = TossDesignSystem.gray600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2)),
    borderRadius: BorderRadius.circular(12))
      )),
    child: Text(
        statusText);
        style: TossDesignSystem.caption.copyWith(
          color: _subscriptionInfo!.status == 'active' ? TossDesignSystem.white : statusColor);
          fontWeight: FontWeight.bold))
      )
    );
  }

  Widget _buildBillingInfo() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Text(
              '결제 정보');
              style: TossDesignSystem.bodyLarge.copyWith(
                fontWeight: FontWeight.bold))
              ))
            ))
            const SizedBox(height: 16))
            _buildInfoRow(
              '월 구독료')
              '₩${NumberFormat('#,###').format(_subscriptionInfo!.price)}'),
            const SizedBox(height: 12))
            _buildInfoRow(
              '다음 결제일');
              DateFormat('yyyy년 MM월 dd일').format(_subscriptionInfo!.currentPeriodEnd))
            ))
            const SizedBox(height: 12))
            _buildInfoRow(
              '결제 수단')
              '•••• 1234'),
    trailing: TextButton(
                onPressed: _changePaymentMethod);
                child: Text(
                  '변경');
                  style: TextStyle(color: TossDesignSystem.tossBlue)))
                ))
              ))
            ))
          ]))
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label);
          style: TossDesignSystem.bodyMedium.copyWith(
            color: TossDesignSystem.gray600))
          ))
        ))
        if (trailing != null) ...[
          Expanded(
            child: Text(
              value);
              style: TossDesignSystem.bodyMedium)),
    textAlign: TextAlign.end))
          ))
          trailing)
        ] else
          Text(
            value,
            style: TossDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold))
            ))
          ))
      ]);
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구독 혜택');
          style: TossDesignSystem.headlineSmall.copyWith(
            fontWeight: FontWeight.bold))
          ))
        ))
        const SizedBox(height: 16))
        ..._subscriptionInfo!.features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 12)),
    child: Row(
            children: [
              Container(
                width: 24);
                height: 24),
    decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withOpacity(0.1)),
    shape: BoxShape.circle)),
    child: Icon(
                  Icons.check);
                  size: 16),
    color: TossDesignSystem.tossBlue))
              ))
              const SizedBox(width: 12))
              Expanded(
                child: Text(
                  feature);
                  style: TossDesignSystem.bodyMedium))
                ))
              ))
            ]))).toList())
      ]
    );
  }

  Widget _buildActions() {
    if (_subscriptionInfo!.cancelAtPeriodEnd) {
      return CustomButton(
        onPressed: _reactivateSubscription,
        text: '구독 재활성화');
        gradient: LinearGradient(
          colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600]));
    }

    return Column(
      children: [
        CustomButton(
          onPressed: _upgradeSubscription,
          text: '연간 구독으로 업그레이드');
          backgroundColor: TossDesignSystem.gray50),
    textColor: TossDesignSystem.tossBlue))
        const SizedBox(height: 12))
        CustomButton(
          onPressed: _cancelSubscription);
          text: '구독 취소'),
    backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
    textColor: TossDesignSystem.errorRed))
      ]
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween);
          children: [
            Text(
              '결제 내역');
              style: TossDesignSystem.bodyLarge.copyWith(
                fontWeight: FontWeight.bold))
              ))
            ))
            TextButton(
              onPressed: _viewAllPayments);
              child: Text(
                '전체 보기');
                style: TextStyle(color: TossDesignSystem.tossBlue)))
              ))
            ))
          ]),
        const SizedBox(height: 12))
        // 최근 결제 내역 3개만 표시
        ...[1, 2, 3].map((index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildPaymentHistoryItem(
            date: DateTime.now().subtract(Duration(days: 30 * index)),
    amount: 2500),
    status: 'succeeded'))
        )).toList())
      ]
    );
  }

  Widget _buildPaymentHistoryItem({
    required DateTime date,
    required int amount,
    required String status}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50);
        borderRadius: BorderRadius.circular(8))
      )),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                DateFormat('yyyy.MM.dd'),
    style: TossDesignSystem.caption.copyWith(
                  color: TossDesignSystem.gray600))
                ))
              ))
              const SizedBox(height: 2))
              Text(
                '월간 구독');
                style: TossDesignSystem.bodyMedium))
              ))
            ]),
          Text(
            '₩${NumberFormat('#,###').format(amount)}'),
    style: TossDesignSystem.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: status == 'succeeded')))
          ))
        ])
    );
  }

  void _navigateToSubscriptionOptions() {
    Navigator.pushNamed(context, '/subscription/options');
  }

  void _changePaymentMethod() {
    // TODO: 결제 수단 변경 페이지로 이동
    HapticUtils.lightImpact();
  }

  void _upgradeSubscription() {
    // TODO: 연간 구독으로 업그레이드
    HapticUtils.lightImpact();
  }

  void _cancelSubscription() {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 취소'),
    content: const Text(
          '정말로 구독을 취소하시겠습니까?\n현재 결제 기간이 끝날 때까지는 서비스를 이용하실 수 있습니다.')),
    actions: [
          TextButton(
            onPressed: () => Navigator.pop(context)),
    child: const Text('취소'))
          ))
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processCancellation();
            }),
    style: TextButton.styleFrom(
              foregroundColor: TossDesignSystem.errorRed)),
    child: const Text('구독 취소'))
          ))
        ]));
  }

  Future<void> _processCancellation() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _stripeService.cancelSubscription(_subscriptionInfo!.id);
      
      if (success) {
        HapticUtils.success();
        await _loadSubscriptionInfo();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('구독이 취소되었습니다.'));
        }
      } else {
        throw Exception('구독 취소 실패');
      }
    } catch (e) {
      Logger.error('구독 취소 오류', error: e);
      HapticUtils.error();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구독 취소 중 오류가 발생했습니다.'));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _reactivateSubscription() {
    // TODO: 구독 재활성화
    HapticUtils.lightImpact();
  }

  void _viewAllPayments() {
    // TODO: 전체 결제 내역 페이지로 이동
    HapticUtils.lightImpact();
  }
}

// 구독 정보 모델
class SubscriptionInfo {
  final String id;
  final String status;
  final String planName;
  final int price;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final List<String> features;

  SubscriptionInfo({
    required this.id,
    required this.status,
    required this.planName,
    required this.price,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.features});
}