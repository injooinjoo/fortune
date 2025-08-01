import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class NameStep extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  final VoidCallback? onShowSocialLogin;
  
  const NameStep(
    {
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
    this.onShowSocialLogin,
  )});

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
      widget.onNameChanged(
    _nameController.text.trim(,
  )});
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
      backgroundColor: Colors.transparent, // Keep transparent for overlay effect
      resizeToAvoidBottomInset: true),
        body: SingleChildScrollView(,
      physics: const BouncingScrollPhysics(),
        child: Container(,
      height: MediaQuery.of(context).size.height - keyboardHeight,
          padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
          child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'start-button-hero',
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext)
                ) {
                  return AnimatedBuilder(
                    animation: animation,
              ),
              builder: (context, child) {
                      return Material(
                        color: Colors.transparent,
                        child: Container(,
      decoration: BoxDecoration(
          color: Color.lerp(
                              context.isDarkMode ? context.fortuneTheme.primaryText : AppColors.textPrimary)
                              Colors.transparent)
                              animation.value)
                            borderRadius: BorderRadius.circular(
                              (context.fortuneTheme.bottomSheetStyles.borderRadius + 4) * (1 - animation.value))))
                          padding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25 * (1 - animation.value),
                            vertical: context.fortuneTheme.formStyles.inputPadding.horizontal * (1 - animation.value),
      child: Center(,
      child: DefaultTextStyle(,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(,
      fontWeight: FontWeight.bold,
                          ),
        color: Color.lerp(
                                  context.isDarkMode ? context.fortuneTheme.cardBackground : AppColors.textPrimaryDark)
                                  context.fortuneTheme.primaryText)
                                  animation.value)
                                ))
                              child: Text(
                                animation.value < 0.5 ? '시작하기' : '이름을 알려주세요')
                              ))))))))
                    }
                  );
                }
                child: Material(,
      color: Colors.transparent,
                  child: Text(
                    '이름을 알려주세요'),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(,
      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          ),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: context.fortuneTheme.primaryText),
      textAlign: TextAlign.center)))))).animate().fadeIn(durati,
      on: 600.ms).shimmer(,
      duration: 1200.ms),
        color: AppColors.textPrimaryDark.withValues(alph,
      a: 0.3)
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              Text(
                '운세의 주인공이 되어주세요'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
                  height: 1.4),
      textAlign: TextAlign.center)).animate(del,
      ay: 300.ms).fadeIn(duratio,
      n: 600.ms),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
              TextField(
                controller: _nameController,
                autofocus: true,
                textAlign: TextAlign.center),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.w500,
                          ),
        decoration: InputDecoration(,
      hintText: '이름'),
        hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText.withValues(alp,
      ha: 0.7),
                    fontWeight: FontWeight.normal),
      border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(,
      borderSide: BorderSide(,
      color: context.fortuneTheme.dividerColor,
                      width: context.fortuneTheme.formStyles.inputBorderWidth)
                    ))
                  focusedBorder: UnderlineInputBorder(,
      borderSide: BorderSide(,
      color: Theme.of(context).primaryColor,
                      width: context.fortuneTheme.formStyles.focusBorderWidth)))),
      textCapitalization: TextCapitalization.words)).animate(delay: 500.ms).fadeIn(durati,
      on: 600.ms).slideY(,
      begin: 0.1),
        end: 0),
        curve: Curves.easeOutQuart)
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 5),
              SizedBox(
                width: double.infinity,
                height: context.fortuneTheme.formStyles.inputHeight,
                child: ElevatedButton(,
      onPressed: _isValid ? widget.onNext : null),
        style: ElevatedButton.styleFrom(,
      backgroundColor: context.fortuneTheme.primaryText),
        foregroundColor: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4),
      elevation: 0),
      child: Text(
                    '확인'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.w600,
                          ))).animate(delay: 700.ms).fadeIn(duratio,
      n: 600.ms),
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              if (widget.onShowSocialLogin != null)
                GestureDetector(
                  onTap: widget.onShowSocialLogin,
                  child: Text(
                    '잠깐, 저 아이디 있어요'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: AppColors.textPrimary,
                          ))).animate(delay: 800.ms).fadeIn(duratio,
      n: 600.ms),
              // Add padding to account for keyboard
              SizedBox(height: keyboardHeight > 0 ? 20 : 0),
            ]))))))
  }
}