import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 2단계: 이사 정보 입력
class MovingInputStep2 extends StatefulWidget {
  final Function(String currentArea, String targetArea, String period) onComplete;

  const MovingInputStep2({
    super.key,
    required this.onComplete,
  });

  @override
  State<MovingInputStep2> createState() => _MovingInputStep2State();
}

class _MovingInputStep2State extends State<MovingInputStep2> {
  String? _currentArea;
  String? _targetArea;
  String? _movingPeriod;

  final List<String> _areas = [
    '서울시 강남구',
    '서울시 서초구',
    '서울시 송파구',
    '서울시 강서구',
    '서울시 마포구',
    '서울시 성동구',
    '서울시 용산구',
    '서울시 종로구',
    '서울시 중구',
    '경기도 성남시',
    '경기도 수원시',
    '경기도 안양시',
    '경기도 부천시',
    '인천시 연수구',
    '인천시 남동구',
    '부산시 해운대구',
    '부산시 부산진구',
    '대구시 수성구',
    '기타',
  ];

  final List<Map<String, String>> _periods = [
    {'title': '1개월 이내', 'subtitle': '급하게 이사해야 해요'},
    {'title': '3개월 이내', 'subtitle': '적당한 시간 여유가 있어요'},
    {'title': '6개월 이내', 'subtitle': '충분한 시간이 있어요'},
  ];

  bool _canContinue() {
    return _currentArea != null && 
           _targetArea != null && 
           _movingPeriod != null;
  }

  void _handleNext() {
    if (_canContinue()) {
      widget.onComplete(_currentArea!, _targetArea!, _movingPeriod!);
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
            '어디서 어디로\n이사하시나요?',
            style: TossTheme.heading2,
          ),
          
          const SizedBox(height: TossTheme.spacingXXL),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 현재 거주지
                  Text(
                    '현재 살고 있는 곳',
                    style: TossTheme.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TossTheme.spacingM),
                  AppCard(
                    onTap: () => _showAreaSelector(true),
                    padding: const EdgeInsets.all(TossTheme.spacingM),
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: _currentArea != null 
                              ? TossTheme.primaryBlue 
                              : TossTheme.textGray400,
                          size: 20,
                        ),
                        const SizedBox(width: TossTheme.spacingM),
                        Expanded(
                          child: Text(
                            _currentArea ?? '현재 거주지를 선택하세요',
                            style: _currentArea != null
                                ? TossTheme.inputStyle
                                : TossTheme.hintStyle,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: TossTheme.textGray400,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: TossTheme.spacingXL),
                  
                  // 이사 희망지
                  Text(
                    '이사하고 싶은 곳',
                    style: TossTheme.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TossTheme.spacingM),
                  AppCard(
                    onTap: () => _showAreaSelector(false),
                    padding: const EdgeInsets.all(TossTheme.spacingM),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: _targetArea != null 
                              ? TossTheme.primaryBlue 
                              : TossTheme.textGray400,
                          size: 20,
                        ),
                        const SizedBox(width: TossTheme.spacingM),
                        Expanded(
                          child: Text(
                            _targetArea ?? '이사할 곳을 선택하세요',
                            style: _targetArea != null
                                ? TossTheme.inputStyle
                                : TossTheme.hintStyle,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: TossTheme.textGray400,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: TossTheme.spacingXL),
                  
                  // 이사 시기
                  Text(
                    '언제 이사하시나요?',
                    style: TossTheme.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TossTheme.spacingM),
                  
                  ..._periods.map((period) => Padding(
                    padding: const EdgeInsets.only(bottom: TossTheme.spacingS),
                    child: AppCard(
                      onTap: () {
                        setState(() {
                          _movingPeriod = period['title']!;
                        });
                      },
                      padding: const EdgeInsets.all(TossTheme.spacingM),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _movingPeriod == period['title']
                                    ? TossTheme.primaryBlue
                                    : TossTheme.borderGray300,
                                width: 2,
                              ),
                              color: _movingPeriod == period['title']
                                  ? TossTheme.primaryBlue
                                  : TossDesignSystem.transparent,
                            ),
                            child: _movingPeriod == period['title']
                                ? const Icon(
                                    Icons.check,
                                    color: TossDesignSystem.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: TossTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  period['title']!,
                                  style: TossTheme.body2,
                                ),
                                Text(
                                  period['subtitle']!,
                                  style: TossTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // 다음 버튼
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: UnifiedButton(
                text: '다음',
                onPressed: _canContinue() ? _handleNext : null,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAreaSelector(bool isCurrentArea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TossTheme.borderGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(TossTheme.spacingL),
              child: Text(
                isCurrentArea ? '현재 거주지 선택' : '이사할 곳 선택',
                style: TossTheme.heading2,
              ),
            ),
            
            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _areas.length,
                itemBuilder: (context, index) {
                  final area = _areas[index];
                  return ListTile(
                    title: Text(
                      area,
                      style: TossTheme.body2,
                    ),
                    onTap: () {
                      setState(() {
                        if (isCurrentArea) {
                          _currentArea = area;
                        } else {
                          _targetArea = area;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}