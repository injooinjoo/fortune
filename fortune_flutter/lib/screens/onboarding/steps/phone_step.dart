import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneStep extends StatefulWidget {
  final String initialPhone;
  final String initialCountryCode;
  final Function(String phone, String countryCode) onPhoneChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  
  const PhoneStep({
    super.key,
    required this.initialPhone,
    required this.initialCountryCode,
    required this.onPhoneChanged,
    required this.onNext,
    this.onBack,
  });

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<PhoneStep> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'KR');
  bool _isValid = false;
  String _phoneValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone.isNotEmpty) {
      _phoneController.text = widget.initialPhone;
      _phoneValue = widget.initialPhone;
    }
    if (widget.initialCountryCode.isNotEmpty) {
      _phoneNumber = PhoneNumber(
        phoneNumber: widget.initialPhone,
        isoCode: widget.initialCountryCode,
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onInputChanged(PhoneNumber number) {
    setState(() {
      _phoneNumber = number;
      _phoneValue = number.phoneNumber ?? '';
      _isValid = _phoneValue.length >= 10; // Basic validation
    });
    
    if (_isValid) {
      widget.onPhoneChanged(
        number.phoneNumber ?? '',
        number.isoCode ?? 'KR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - keyboardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '전화번호를 입력해주세요',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '다른 소셜 계정과 연동하거나\n보안 인증에 사용됩니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: InternationalPhoneNumberInput(
                  onInputChanged: _onInputChanged,
                  onInputValidated: (bool value) {
                    setState(() {
                      _isValid = value && _phoneValue.length >= 10;
                    });
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                    useBottomSheetSafeArea: true,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  initialValue: _phoneNumber,
                  textFieldController: _phoneController,
                  formatInput: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputDecoration: InputDecoration(
                    hintText: '010-1234-5678',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  searchBoxDecoration: InputDecoration(
                    labelText: '국가 검색',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  locale: 'ko',
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '인증번호 받기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onNext,
                child: Text(
                  '나중에 하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              if (widget.onBack != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.onBack,
                  child: Text(
                    '이전으로',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              // Add padding to account for keyboard
              SizedBox(height: keyboardHeight > 0 ? 20 : 0),
            ],
          ),
        ),
      ),
    );
  }
}