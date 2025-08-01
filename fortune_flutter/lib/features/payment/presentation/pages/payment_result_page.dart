import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../presentation/widgets/common/custom_button.dart';
import '../../../../core/utils/haptic_utils.dart';

class PaymentResultPage extends StatefulWidget {
  final bool isSuccess;
  final String? message;
  final String? productName;
  final String? amount;
  final String? transactionId;
  final int? tokenAmount;
  final String? errorCode;

  const PaymentResultPage({
    super.key,
    required this.isSuccess,
    this.message,
    this.productName,
    this.amount,
    this.transactionId,
    this.tokenAmount,
    this.errorCode,
  });

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  @override
  void initState() {
    super.initState();
    // 햅틱 피드백
    if (widget.isSuccess) {
      HapticUtils.success();
} else {
      HapticUtils.error();
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildMessage(),
              if (widget.isSuccess && widget.tokenAmount != null) ...[
                const SizedBox(height: 24),
                _buildTokenInfo(),
              ],
              if (widget.transactionId != null) ...[
                const SizedBox(height: 16),
                _buildTransactionId(),
              ],
              const SizedBox(height: 48),
              _buildActions(),
              if (!widget.isSuccess) ...[
                const SizedBox(height: 16),
                _buildRetryInfo(),
              ],
            ],
          ),
      ));
}

  Widget _buildIcon() {
    if (widget.isSuccess) {
      // 성공 애니메이션
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          size: 80,
          color: AppColors.success,
        )).animate()
                  .scale(duration: const Duration(milliseconds: 500),
        .fadeIn();
} else {
      // 실패 아이콘
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline,
          size: 80,
          color: AppColors.error,
        )).animate()
                  .shake(duration: const Duration(milliseconds: 500),
        .fadeIn();
}
  }

  Widget _buildTitle() {
    return Text(
      widget.isSuccess ? '결제 완료!' : '결제 실패',
      style: AppTextStyles.headlineLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: widget.isSuccess ? AppColors.success : AppColors.error,
      ));
}

  Widget _buildMessage() {
    String displayMessage;
    if (widget.message != null) {
      displayMessage = widget.message!;
} else if (widget.isSuccess) {
      displayMessage = widget.productName != null 
        ? '${widget.productName} 구매가 완료되었습니다.'
        : '결제가 성공적으로 완료되었습니다.';
} else {
      displayMessage = '결제 처리 중 오류가 발생했습니다.';
}
    
    return Text(
      displayMessage,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondary),
      textAlign: TextAlign.center
    );
}

  Widget _buildTokenInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '충전된 토큰',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary),
              ),
              Text(
                '${widget.tokenAmount}개',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
            ],
          ),
        ],
      )).animate()
                  .fadeIn(delay: const Duration(milliseconds: 300),
      .slideY(begin: 0.2, end: 0);
}

  Widget _buildTransactionId() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '거래번호: ',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary),
          ),
          Text(
            widget.transactionId!,
            style: AppTextStyles.caption.copyWith(
              fontFamily: 'monospace'),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _copyTransactionId,
            child: Icon(
              Icons.copy,
              size: 16,
              color: AppColors.textSecondary,
            ),
        ],
      
    );
}

  Widget _buildActions() {
    if (widget.isSuccess) {
      return Column(
        children: [
          CustomButton(
            onPressed: _navigateToHome,
            text: '홈으로 돌아가기',
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: _navigateToFortuneList,
            text: '운세 보러가기',
            backgroundColor: Colors.transparent,
            textColor: AppColors.primary,
          ),
        ]
      );
} else {
      return Column(
        children: [
          CustomButton(
            onPressed: _retry,
            text: '다시 시도',
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: _navigateToHome,
            text: '홈으로 돌아가기',
            backgroundColor: Colors.transparent,
            textColor: AppColors.textPrimary,
          ),
        ],
      );
}
  }

  Widget _buildRetryInfo() {
    String helpText = '';
    
    switch (widget.errorCode) {
      case 'CANCELLED':
        helpText = '결제를 취소하셨습니다.';
        break;
      case 'card_declined':
        helpText = '카드가 거부되었습니다. 다른 카드를 사용해보세요.';
        break;
      case 'insufficient_funds':
        helpText = '잔액이 부족합니다. 카드 잔액을 확인해주세요.';
        break;
      case 'processing_error':
        helpText = '처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        break;
      default:
        helpText = '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
}

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              helpText,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info),
            ),
        ],
      ));
}

  void _copyTransactionId() {
    // TODO: 클립보드에 복사
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('거래번호가 복사되었습니다.')));
}

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
}

  void _navigateToFortuneList() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/fortune',
      (route) => false
    );
}

  void _retry() {
    Navigator.of(context).pop();
}
}