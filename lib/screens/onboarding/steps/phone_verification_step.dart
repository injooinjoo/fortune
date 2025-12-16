import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/theme/app_theme_extensions.dart';

class PhoneVerificationStep extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final Function(String) onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;
  
  const PhoneVerificationStep({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  @override
  State<PhoneVerificationStep> createState() => _PhoneVerificationStepState();
}

class _PhoneVerificationStepState extends State<PhoneVerificationStep> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode()
  );
  
  Timer? _timer;
  int _resendTimer = 60;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _controllers.every((c) => c.text.isNotEmpty);
  }

  void _onOtpFieldChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    if (_isOtpComplete()) {
      _verifyOtp();
    }
  }

  void _onKeyDown(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete() || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final otpCode = _getOtpCode();
    widget.onVerify(otpCode);
    
    // Loading state will be handled by parent widget
  }

  void _resendOtp() {
    if (!_canResend) return;
    
    widget.onResend();
    _startResendTimer();
    
    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  String _formatPhoneNumber(String phone) {
    // Format phone number for display
    if (phone.length >= 11) {
      return '${phone.substring(0, 3)}-****-${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
          child: Column(
            children: [
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
              Text(
                '인증번호를 입력해주세요',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: context.fortuneTheme.primaryText),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              Text(
                '${widget.countryCode} ${_formatPhoneNumber(widget.phoneNumber)}로\n인증번호를 전송했습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.fortuneTheme.subtitleText,
                  height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: context.fortuneTheme.socialSharing.shareButtonSize - 8,
                    height: context.fortuneTheme.formStyles.inputHeight,
                    margin: EdgeInsets.only(right: 8),
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyDown(event, index),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
                            borderSide: BorderSide(
                              color: context.fortuneTheme.dividerColor)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: context.fortuneTheme.formStyles.focusBorderWidth)),
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? context.fortuneTheme.cardBackground
                              : context.fortuneTheme.cardSurface),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1)],
                        onChanged: (value) => _onOtpFieldChanged(value, index)),
                    ),
                  );
                }),
              ),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2),
              // Resend Timer
              _canResend
                  ? TextButton(
                      onPressed: _resendOtp,
                      child: Text(
                        '인증번호 다시 받기',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600
                        )),
                    )
                  : Text(
                      '$_resendTimer초 후 다시 받기',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.fortuneTheme.subtitleText
                      )),
              const Spacer(),
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: context.fortuneTheme.formStyles.inputHeight,
                child: ElevatedButton(
                  onPressed: _isOtpComplete() && !_isLoading
                      ? _verifyOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.fortuneTheme.primaryText,
                    foregroundColor: context.colors.ctaForeground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4)),
                    elevation: 0),
                  child: _isLoading
                      ? SizedBox(
                          width: context.fortuneTheme.socialSharing.shareIconSize,
                          height: context.fortuneTheme.socialSharing.shareIconSize,
                          child: CircularProgressIndicator(
                            color: context.colors.ctaForeground,
                            strokeWidth: 2),
                        )
                      : Text(
                          '인증 완료',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600
                          )),
                ),
              ),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              TextButton(
                onPressed: widget.onBack,
                child: Text(
                  '번호 다시 입력',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.fortuneTheme.subtitleText
                  )),
              ),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
            ],
          ),
        ),
      ),
    );
  }
}