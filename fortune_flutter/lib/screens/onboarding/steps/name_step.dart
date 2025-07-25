import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NameStep extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  final VoidCallback? onShowSocialLogin;
  
  const NameStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
    this.onShowSocialLogin,
  });

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late TextEditingController _nameController;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
              Hero(
                tag: 'start-button-hero',
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Colors.black,
                              Colors.transparent,
                              animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              28 * (1 - animation.value),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20 * (1 - animation.value),
                            vertical: 16 * (1 - animation.value),
                          ),
                          child: Center(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 18 + (14 * animation.value),
                                fontWeight: FontWeight.bold,
                                color: Color.lerp(
                                  Colors.white,
                                  Colors.black,
                                  animation.value,
                                ),
                              ),
                              child: Text(
                                animation.value < 0.5 ? '시작하기' : '이름을 알려주세요',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '이름을 알려주세요',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).shimmer(
                duration: 1200.ms,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '운세의 주인공이 되어주세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
              const SizedBox(height: 48),
              TextField(
                controller: _nameController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '이름',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ).animate(delay: 500.ms).fadeIn(duration: 600.ms).slideY(
                begin: 0.1,
                end: 0,
                curve: Curves.easeOutQuart,
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
                    '확인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
              const SizedBox(height: 16),
              if (widget.onShowSocialLogin != null)
                GestureDetector(
                  onTap: widget.onShowSocialLogin,
                  child: Text(
                    '잠깐, 저 아이디 있어요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[700],
                    ),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
              // Add padding to account for keyboard
              SizedBox(height: keyboardHeight > 0 ? 20 : 0),
            ],
          ),
        ),
      ),
    );
  }
}