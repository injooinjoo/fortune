import 'package:flutter/material.dart';
import '../widgets/bottom_sheet_mbti_picker.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class MbtiStep extends StatefulWidget {
  final Function(String) onMbtiChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final bool isLoading;
  
  const MbtiStep({
    super.key,
    required this.onMbtiChanged,
    required this.onComplete,
    required this.onBack,
    required this.isLoading});

  @override
  State<MbtiStep> createState() => _MbtiStepState();
}

class _MbtiStepState extends State<MbtiStep> {
  String? _e_i;
  String? _n_s;
  String? _t_f;
  String? _j_p;
  
  int _currentDimension = 0;
  
  final List<Map<String, String>> dimensions = [
    {'title': '에너지 방향', 'option1': 'E', 'option2': 'I'},
    {'title': '인식 기능', 'option1': 'N', 'option2': 'S'},
    {'title': '판단 기능', 'option1': 'T', 'option2': 'F'},
    {'title': '생활 양식', 'option1': 'J', 'option2': 'P'}
  ];

  @override
  void initState() {
    super.initState();
  }

  void _showMbtiPicker() async {
    if (_currentDimension >= dimensions.length) return;
    
    final dimension = dimensions[_currentDimension];
    final selected = await BottomSheetMbtiPicker.show(
      context,
      dimension: dimension['title'],
      option1: dimension['option1'],
      option2: dimension['option2'],
      selectedOption: _getSelectedOption(_currentDimension)
    );
    
    if (selected != null) {
      setState(() {
        switch (_currentDimension) {
          case 0:
            _e_i = selected;
            break;
          case 1:
            _n_s = selected;
            break;
          case 2:
            _t_f = selected;
            break;
          case 3:
            _j_p = selected;
            break;
        }
        _currentDimension++;
      });
      
      // Update MBTI if all dimensions are selected
      if (_e_i != null && _n_s != null && _t_f != null && _j_p != null) {
        final mbti = '$_e_i$_n_s$_t_f$_j_p';
        widget.onMbtiChanged(mbti);
      }
      
      // Show next picker or complete
      if (_currentDimension < dimensions.length) {
        Future.delayed(AppAnimations.durationMedium, () {
          _showMbtiPicker();
        });
      }
    }
  }
  
  String? _getSelectedOption(int dimension) {
    switch (dimension) {
      case 0:
        return _e_i;
      case 1:
        return _n_s;
      case 2:
        return _t_f;
      case 3:
        return _j_p;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _e_i != null && _n_s != null && _t_f != null && _j_p != null;
    final mbti = isComplete ? '$_e_i$_n_s$_t_f$_j_p' : '';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back, color: context.fortuneTheme.primaryText),
              padding: EdgeInsets.zero
            )
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MBTI를 선택해주세요',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: context.fortuneTheme.primaryText
                  ),
                  textAlign: TextAlign.center
                ),
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 3),
                
                // MBTI display or start button
                if (_currentDimension == 0 && _e_i == null)
                  // Show start button
                  ElevatedButton(
                    onPressed: _showMbtiPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: AppColors.textPrimaryDark,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 3,
                        vertical: context.fortuneTheme.formStyles.inputPadding.horizontal
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4)
                      )
                    ),
                    child: Text(
                      'MBTI 선택 시작',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600
                      )
                    )
                  )
                else
                  // Show MBTI progress
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 2);
                      vertical: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5)),
    decoration: BoxDecoration(
                      color: context.fortuneTheme.cardBackground);
                      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius + 4))
                    )),
    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center);
                      children: [
                        _buildMbtiLetter(_e_i))
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))
                        _buildMbtiLetter(_n_s))
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))
                        _buildMbtiLetter(_t_f))
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))
                        _buildMbtiLetter(_j_p))
                      ])))
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5))
                
                if (!isComplete)
                  Text(
                    '${_currentDimension}/4 단계',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.fortuneTheme.subtitleText))
                    ))
                
                if (isComplete)
                  Column(
                    children: [
                      Text(
                        mbti);
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
    fontWeight: FontWeight.bold),
    color: Theme.of(context).primaryColor))
                      ))
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentDimension = 0;
                            _e_i = null;
                            _n_s = null;
                            _t_f = null;
                            _j_p = null;
                          });
                          _showMbtiPicker();
                        },
                        child: Text('다시 선택하기')
                      )
                    ],
                
                SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 5),
                
                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: context.fortuneTheme.formStyles.inputHeight,
                  child: ElevatedButton(
                    onPressed: isComplete && !widget.isLoading ? widget.onComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.fortuneTheme.primaryText,
                      foregroundColor: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius + 4)
                      ),
                      elevation: 0
                    ),
                    child: widget.isLoading
                        ? CircularProgressIndicator(
                            color: AppColors.textPrimaryDark,
                            strokeWidth: 2
                          )
                        : Text(
                            '완료',
                            style: Theme.of(context).textTheme.titleLarge
                          )
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
  
  Widget _buildMbtiLetter(String? letter) {
    return Container(
      width: context.fortuneTheme.socialSharing.shareButtonSize - 8,
      height: context.fortuneTheme.socialSharing.shareButtonSize - 8);
      decoration: BoxDecoration(
        color: letter != null ? Theme.of(context).primaryColor : context.fortuneTheme.cardSurface),
    borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 0.67)),
    border: Border.all(
          color: letter != null ? Theme.of(context).primaryColor : context.fortuneTheme.dividerColor),
    width: letter != null ? context.fortuneTheme.formStyles.focusBorderWidth : context.fortuneTheme.formStyles.inputBorderWidth))
      )),
    child: Center(
        child: Text(
          letter ?? '?');
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
    fontWeight: FontWeight.bold),
    color: letter != null ? AppColors.textPrimaryDark : context.fortuneTheme.subtitleText.withOpacity(0.7))
          ))
        ))
      )
    );
  }
}