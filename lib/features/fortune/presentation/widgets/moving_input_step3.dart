import 'package:flutter/material.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';

/// 3단계: 이사 목적 선택
class MovingInputStep3 extends StatefulWidget {
  final Function(String purpose) onComplete;

  const MovingInputStep3({
    super.key,
    required this.onComplete,
  });

  @override
  State<MovingInputStep3> createState() => _MovingInputStep3State();
}

class _MovingInputStep3State extends State<MovingInputStep3> {
  String? _selectedPurpose;

  final List<Map<String, String>> _purposes = [
    {
      'icon': '🏢',
      'title': '직장 때문에',
      'subtitle': '출퇴근이 편한 곳으로'
    },
    {
      'icon': '💑',
      'title': '결혼해서',
      'subtitle': '새로운 보금자리를'
    },
    {
      'icon': '🎓',
      'title': '교육 환경',
      'subtitle': '아이 학군이 좋은 곳으로'
    },
    {
      'icon': '🏡',
      'title': '더 나은 환경',
      'subtitle': '생활 환경 개선을 위해'
    },
    {
      'icon': '💰',
      'title': '투자 목적',
      'subtitle': '부동산 투자를 위해'
    },
    {
      'icon': '👨‍👩‍👧‍👦',
      'title': '가족과 함께',
      'subtitle': '가족이 가까운 곳으로'
    },
  ];

  bool _canContinue() {
    return _selectedPurpose != null;
  }

  void _handleNext() {
    if (_canContinue()) {
      widget.onComplete(_selectedPurpose!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TossTheme.spacingXL),
          
          // 제목
          Text(
            '이사하시는\n이유가 궁금해요',
            style: TossTheme.heading2,
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
          Text(
            '목적에 따라 더 정확한 운세를 알려드릴게요',
            style: TossTheme.subtitle1,
          ),
          
          const SizedBox(height: TossTheme.spacingXXL),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: TossTheme.spacingM,
                mainAxisSpacing: TossTheme.spacingM,
              ),
              itemCount: _purposes.length,
              itemBuilder: (context, index) {
                final purpose = _purposes[index];
                final isSelected = _selectedPurpose == purpose['title'];
                
                return TossCard(
                  onTap: () {
                    setState(() {
                      _selectedPurpose = purpose['title']!;
                    });
                  },
                  style: isSelected ? TossCardStyle.outlined : TossCardStyle.elevated,
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  child: Container(
                    decoration: isSelected 
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(TossTheme.radiusM),
                            border: Border.all(
                              color: TossTheme.primaryBlue,
                              width: 2,
                            ),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          purpose['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: TossTheme.spacingS),
                        Text(
                          purpose['title']!,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? TossTheme.primaryBlue 
                                : TossTheme.textBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TossTheme.spacingXS),
                        Text(
                          purpose['subtitle']!,
                          style: TossTheme.caption.copyWith(
                            color: isSelected 
                                ? TossTheme.primaryBlue 
                                : TossTheme.textGray600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 다음 버튼
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue() ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canContinue() 
                      ? TossTheme.primaryBlue 
                      : TossTheme.disabledGray,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TossTheme.radiusM),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '이사운 확인하기',
                  style: TossTheme.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

