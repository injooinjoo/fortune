import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../shared/components/floating_bottom_button.dart';

enum LifestyleType { employee, student, freelancer, business }
enum HobbyType { exercise, reading, travel, cooking, gaming, movie }

class LoveInputStep4Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  
  const LoveInputStep4Page({super.key, required this.onNext});

  @override
  State<LoveInputStep4Page> createState() => _LoveInputStep4PageState();
}

class _LoveInputStep4PageState extends State<LoveInputStep4Page> {
  double _appearanceConfidence = 5.0;
  final Set<String> _charmPoints = {};
  LifestyleType? _lifestyle;
  final Set<HobbyType> _hobbies = {};

  final List<String> _charmPointOptions = [
    '유머감각', '배려심', '경제력', '외모', '성실함', '지적능력', 
    '사교성', '요리실력', '운동신경', '예술감각', '리더십', '따뜻함'
  ];

  bool get _canProceed => _charmPoints.isNotEmpty && 
                         _lifestyle != null && 
                         _hobbies.isNotEmpty;

  String _getLifestyleText(LifestyleType lifestyle) {
    switch (lifestyle) {
      case LifestyleType.employee:
        return '직장인';
      case LifestyleType.student:
        return '학생';
      case LifestyleType.freelancer:
        return '프리랜서';
      case LifestyleType.business:
        return '사업가';
    }
  }

  String _getLifestyleEmoji(LifestyleType lifestyle) {
    switch (lifestyle) {
      case LifestyleType.employee:
        return '💼';
      case LifestyleType.student:
        return '📚';
      case LifestyleType.freelancer:
        return '💻';
      case LifestyleType.business:
        return '🏢';
    }
  }

  String _getHobbyText(HobbyType hobby) {
    switch (hobby) {
      case HobbyType.exercise:
        return '운동';
      case HobbyType.reading:
        return '독서';
      case HobbyType.travel:
        return '여행';
      case HobbyType.cooking:
        return '요리';
      case HobbyType.gaming:
        return '게임';
      case HobbyType.movie:
        return '영화';
    }
  }

  String _getHobbyEmoji(HobbyType hobby) {
    switch (hobby) {
      case HobbyType.exercise:
        return '🏃';
      case HobbyType.reading:
        return '📖';
      case HobbyType.travel:
        return '✈️';
      case HobbyType.cooking:
        return '👨‍🍳';
      case HobbyType.gaming:
        return '🎮';
      case HobbyType.movie:
        return '🎬';
    }
  }

  String _getConfidenceText(double confidence) {
    if (confidence <= 3) {
      return '보완이 필요해요';
    } else if (confidence <= 5) {
      return '평범해요';
    } else if (confidence <= 7) {
      return '괜찮은 편이에요';
    } else if (confidence <= 9) {
      return '자신 있어요';
    } else {
      return '매우 자신 있어요';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence <= 3) {
      return TossTheme.error;
    } else if (confidence <= 5) {
      return TossTheme.warning;
    } else if (confidence <= 7) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
    }
  }

  void _handleNext() {
    if (!_canProceed) return;

    // Step4에서는 광고를 호출하지 않고 데이터만 전달
    // MainPage에서 광고를 호출하도록 수정
    widget.onNext({
      'appearanceConfidence': _appearanceConfidence,
      'charmPoints': _charmPoints.toList(),
      'lifestyle': _lifestyle.toString().split('.').last,
      'hobbies': _hobbies.map((h) => h.toString().split('.').last).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '나의 매력을\n알려주세요',
            style: TossTheme.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ).animate().slideX(begin: -0.3, duration: 600.ms).fadeIn(),

          const SizedBox(height: 8),

          Text(
            '솔직하게 답할수록 정확한 조언을 드려요',
            style: TossTheme.body1.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ).animate(delay: 200.ms).slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 32),
          
          // Appearance Confidence
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '외모 자신감',
                  style: TossTheme.heading4.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1점 (전혀 자신 없음) ~ 10점 (매우 자신 있음)',
                  style: TossTheme.body2.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getConfidenceColor(_appearanceConfidence),
                    inactiveTrackColor: TossTheme.borderGray200,
                    thumbColor: _getConfidenceColor(_appearanceConfidence),
                    overlayColor: _getConfidenceColor(_appearanceConfidence).withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _appearanceConfidence,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _appearanceConfidence = value;
                      });
                    },
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(_appearanceConfidence),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_appearanceConfidence.round()}점',
                          style: TossTheme.body1.copyWith(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getConfidenceText(_appearanceConfidence),
                        style: TossTheme.body2.copyWith(
                          color: _getConfidenceColor(_appearanceConfidence),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Charm Points
          Text(
            '나의 매력 포인트',
            style: TossTheme.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '최대 3개까지 선택',
            style: TossTheme.body2.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _charmPointOptions.map((charm) {
              return _buildCharmPointChip(charm, isDark);
            }).toList(),
          ).animate(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Lifestyle
          Text(
            '현재 라이프스타일',
            style: TossTheme.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: LifestyleType.values.map((lifestyle) {
              return _buildLifestyleChip(lifestyle, isDark);
            }).toList(),
          ).animate(delay: 700.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Hobbies
          Text(
            '취미 활동',
            style: TossTheme.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: HobbyType.values.map((hobby) {
              return _buildHobbyChip(hobby, isDark);
            }).toList(),
          ).animate(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),

          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  // Floating Button Widget
  Widget buildFloatingButton() {
    return FloatingBottomButton(
      text: '연애운세 보기',
      onPressed: _canProceed ? _handleNext : null,
      style: _canProceed ? TossButtonStyle.primary : TossButtonStyle.secondary,
    );
  }

  Widget _buildCharmPointChip(String charm, bool isDark) {
    final isSelected = _charmPoints.contains(charm);
    final canSelect = _charmPoints.length < 3 || isSelected;

    return GestureDetector(
      onTap: canSelect ? () {
        setState(() {
          if (isSelected) {
            _charmPoints.remove(charm);
          } else if (_charmPoints.length < 3) {
            _charmPoints.add(charm);
          }
        });
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? TossTheme.primaryBlue
              : canSelect
                  ? (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary)
                  : TossTheme.disabledGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TossTheme.primaryBlue
                : canSelect
                    ? (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200)
                    : TossTheme.disabledGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          charm,
          style: TossTheme.body2.copyWith(
            color: isSelected
                ? TossDesignSystem.white
                : canSelect
                    ? (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)
                    : TossTheme.disabledGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLifestyleChip(LifestyleType lifestyle, bool isDark) {
    final isSelected = _lifestyle == lifestyle;
    return GestureDetector(
      onTap: () {
        setState(() {
          _lifestyle = lifestyle;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossTheme.primaryBlue
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossTheme.primaryBlue
                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getLifestyleEmoji(lifestyle),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _getLifestyleText(lifestyle),
                  style: TossTheme.body1.copyWith(
                    color: isSelected
                        ? TossDesignSystem.white
                        : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbyChip(HobbyType hobby, bool isDark) {
    final isSelected = _hobbies.contains(hobby);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _hobbies.remove(hobby);
          } else {
            _hobbies.add(hobby);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? TossTheme.primaryBlue
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TossTheme.primaryBlue
                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getHobbyEmoji(hobby),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _getHobbyText(hobby),
                style: TossTheme.caption.copyWith(
                  color: isSelected
                      ? TossDesignSystem.white
                      : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}