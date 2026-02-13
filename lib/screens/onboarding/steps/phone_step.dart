import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme_extensions.dart';

// Temporary implementation without intl_phone_number_input package
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
  String _countryCode = 'KR';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialPhone;
    _countryCode =
        widget.initialCountryCode.isEmpty ? 'KR' : widget.initialCountryCode;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndUpdate(String value) {
    setState(() {
      _isValid = value.length >= 10; // Simple validation
    });

    if (_isValid) {
      widget.onPhoneChanged(value, _countryCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
              context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: context.fortuneTheme.primaryText),
                  onPressed: widget.onBack,
                ),
              SizedBox(
                  height:
                      context.fortuneTheme.formStyles.inputPadding.horizontal *
                          1.25),
              Text('전화번호를 입력해주세요',
                  style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(
                  height:
                      context.fortuneTheme.formStyles.inputPadding.vertical *
                          0.65),
              Text(
                '서비스 이용 시 본인 확인을 위해 필요합니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.fortuneTheme.subtitleText,
                    ),
              ),
              SizedBox(
                  height:
                      context.fortuneTheme.formStyles.inputPadding.horizontal *
                          2.5),
              // Temporary simple phone input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '01012345678',
                  prefixText: '+82 ',
                  border: OutlineInputBorder(),
                ),
                onChanged: _validateAndUpdate,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? widget.onNext : null,
                  child: const Text('다음'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
