import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/toss_theme.dart';
import '../../landing_page.dart';

class TossStyleNameStep extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  
  const TossStyleNameStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
  });

  @override
  State<TossStyleNameStep> createState() => _TossStyleNameStepState();
}

class _TossStyleNameStepState extends State<TossStyleNameStep> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _isValid = _nameController.text.isNotEmpty;
    
    _nameController.addListener(() {
      setState(() {
        _isValid = _nameController.text.trim().isNotEmpty;
      });
      widget.onNameChanged(_nameController.text.trim());
    });
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSocialLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Title
                    Text(
                      '로그인',
                      style: TossTheme.heading2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '기존 계정으로 로그인하세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: TossTheme.textGray600,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Social Login Buttons (simplified)
                    _buildSocialLoginButton(
                      context: context,
                      label: 'Google로 계속하기',
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      borderColor: Colors.grey[300]!,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement Google login
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: 'Apple로 계속하기',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      borderColor: Colors.black,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement Apple login
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: '카카오로 계속하기',
                      backgroundColor: const Color(0xFFFEE500),
                      textColor: Colors.black87,
                      borderColor: const Color(0xFFFEE500),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement Kakao login
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSocialLoginButton(
                      context: context,
                      label: '네이버로 계속하기',
                      backgroundColor: const Color(0xFF03C75A),
                      textColor: Colors.white,
                      borderColor: const Color(0xFF03C75A),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement Naver login
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Terms text
                    Text(
                      '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: TossTheme.textGray600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required BuildContext context,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer to center the input field
            const Spacer(),
            
            // Center content - Input field only
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _nameController,
                focusNode: _focusNode,
                style: TossTheme.inputStyle,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '이름을 알려주세요',
                  hintStyle: TossTheme.inputStyle.copyWith(
                    color: TossTheme.textGray400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 800),
              ),
            ),
            
            const Spacer(),
            
            // Bottom button area - Only show when text is entered
            AnimatedOpacity(
              opacity: _isValid ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isValid ? 58 : 0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                margin: EdgeInsets.only(
                  bottom: _isValid ? 24.0 : 0,
                ),
                child: _isValid
                    ? SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: widget.onNext,
                          style: TossTheme.primaryButtonStyle(true),
                          child: Text(
                            '다음',
                            style: TossTheme.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            
            // "계정이 있어요" link at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: GestureDetector(
                onTap: () => _showSocialLoginBottomSheet(context),
                child: Text(
                  '계정이 있어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossTheme.textGray600,
                    decoration: TextDecoration.underline,
                    decorationColor: TossTheme.textGray600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}