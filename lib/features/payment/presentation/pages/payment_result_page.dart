import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/hanji_background.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HanjiScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 모란꽃 장식 (성공 시만, 우측 상단)
            if (widget.isSuccess)
              Positioned(
                top: -20,
                right: -40,
                child: Opacity(
                  opacity: isDark ? 0.15 : 0.25,
                  child: Image.asset(
                    'assets/images/peony_decoration.PNG',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  _buildIcon(),
                  const SizedBox(height: 32),
                  _buildTitle(isDark),
                  const SizedBox(height: 16),
                  _buildMessage(isDark),
                  if (widget.isSuccess && widget.tokenAmount != null) ...[
                    const SizedBox(height: 32),
                    _buildTokenInfo(isDark),
                  ],
                  if (widget.transactionId != null) ...[
                    const SizedBox(height: 16),
                    _buildTransactionId(isDark),
                  ],
                  const Spacer(flex: 2),
                  _buildActions(isDark),
                  if (!widget.isSuccess) ...[
                    const SizedBox(height: 16),
                    _buildRetryInfo(isDark),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.isSuccess) {
      // 낙관(도장) 스타일 성공 아이콘
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: ObangseokColors.inju.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/nakwan_success.PNG',
            fit: BoxFit.contain,
          ),
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: 600.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 400.ms);
    } else {
      // 수묵화 스타일 실패 아이콘
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: ObangseokColors.meokFaded.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/payment_fail.PNG',
            fit: BoxFit.contain,
          ),
        ),
      )
          .animate()
          .shake(duration: 600.ms, hz: 3)
          .fadeIn(duration: 400.ms);
    }
  }

  Widget _buildTitle(bool isDark) {
    final textColor = widget.isSuccess
        ? ObangseokColors.inju
        : ObangseokColors.getMeok(context);

    return Text(
      widget.isSuccess ? '결제 완료' : '결제 실패',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 2,
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMessage(bool isDark) {
    String displayMessage;
    if (widget.message != null) {
      displayMessage = widget.message!;
    } else if (widget.isSuccess) {
      displayMessage = widget.productName != null
          ? '${widget.productName} 구매가\n완료되었습니다'
          : '결제가 성공적으로 완료되었습니다';
    } else {
      displayMessage = '결제 처리 중 오류가 발생했습니다';
    }

    return Text(
      displayMessage,
      style: TextStyle(
        fontSize: 16,
        color: ObangseokColors.meokFaded,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTokenInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ObangseokColors.hwang.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ObangseokColors.hwang.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 복주머니 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ObangseokColors.hwang.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/bokjumoni_icon.PNG',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '충전된 복주머니',
                style: TextStyle(
                  fontSize: 14,
                  color: ObangseokColors.hwangDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.tokenAmount}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: ObangseokColors.hwangDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '개',
                    style: TextStyle(
                      fontSize: 18,
                      color: ObangseokColors.hwangDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTransactionId(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ObangseokColors.misaekDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '거래번호: ',
            style: TextStyle(
              fontSize: 12,
              color: ObangseokColors.meokFaded,
            ),
          ),
          Text(
            widget.transactionId!,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: ObangseokColors.meokFaded,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _copyTransactionId,
            child: Icon(
              Icons.copy,
              size: 16,
              color: ObangseokColors.meokFaded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    if (widget.isSuccess) {
      return Column(
        children: [
          // 메인 버튼 - 인주색
          UnifiedButton(
            onPressed: _navigateToHome,
            text: '홈으로 돌아가기',
            gradient: LinearGradient(
              colors: [ObangseokColors.inju, ObangseokColors.injuDark],
            ),
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          // 보조 버튼
          UnifiedButton(
            onPressed: _navigateToFortuneList,
            text: '운세 보러가기',
            style: UnifiedButtonStyle.ghost,
            width: double.infinity,
          ),
        ],
      ).animate().fadeIn(delay: 500.ms);
    } else {
      return Column(
        children: [
          // 다시 시도 버튼 - 먹색
          UnifiedButton(
            onPressed: _retry,
            text: '다시 시도',
            gradient: LinearGradient(
              colors: [ObangseokColors.meokLight, ObangseokColors.meok],
            ),
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          UnifiedButton(
            onPressed: _navigateToHome,
            text: '홈으로 돌아가기',
            style: UnifiedButtonStyle.ghost,
            width: double.infinity,
          ),
        ],
      ).animate().fadeIn(delay: 500.ms);
    }
  }

  Widget _buildRetryInfo(bool isDark) {
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
        helpText = '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObangseokColors.cheong.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ObangseokColors.cheong.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ObangseokColors.cheong,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              helpText,
              style: TextStyle(
                fontSize: 13,
                color: ObangseokColors.cheong,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyTransactionId() {
    Clipboard.setData(ClipboardData(text: widget.transactionId ?? ''));
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('거래번호가 복사되었습니다.')),
    );
  }

  void _navigateToHome() {
    // Navigator로 들어왔으므로 Navigator로 나가야 함
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  void _navigateToFortuneList() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/fortune',
      (route) => false,
    );
  }

  void _retry() {
    Navigator.of(context).pop();
  }
}
