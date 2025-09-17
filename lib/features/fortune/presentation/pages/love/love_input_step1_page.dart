import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../core/theme/toss_design_system.dart';

enum RelationshipStatus { single, dating, breakup, crush }

class LoveInputStep1Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  
  const LoveInputStep1Page({super.key, required this.onNext});

  @override
  State<LoveInputStep1Page> createState() => _LoveInputStep1PageState();
}

class _LoveInputStep1PageState extends State<LoveInputStep1Page> {
  int _age = 25;
  String? _gender;
  RelationshipStatus? _relationshipStatus;

  bool get _canProceed => _gender != null && _relationshipStatus != null;

  String _getRelationshipStatusText(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.single:
        return '싱글 (새로운 만남 희망)';
      case RelationshipStatus.dating:
        return '연애중 (관계 발전)';
      case RelationshipStatus.breakup:
        return '이별 후 (재회 또는 새출발)';
      case RelationshipStatus.crush:
        return '짝사랑 중';
    }
  }

  String _getRelationshipStatusEmoji(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.single:
        return '💫';
      case RelationshipStatus.dating:
        return '💕';
      case RelationshipStatus.breakup:
        return '🌱';
      case RelationshipStatus.crush:
        return '💘';
    }
  }

  void _handleNext() {
    if (!_canProceed) return;
    
    widget.onNext({
      'age': _age,
      'gender': _gender,
      'relationshipStatus': _relationshipStatus.toString().split('.').last,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '기본 정보를 알려주세요',
            style: TossTheme.heading2.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w800,
            ),
          ).animate().slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            '더 정확한 연애운세를 위해 필요해요',
            style: TossTheme.body1.copyWith(
              color: TossTheme.textGray600,
            ),
          ).animate(delay: 200.ms).slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 40),
          
          // Age Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TossTheme.borderGray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '나이',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '필수',
                        style: TossTheme.caption.copyWith(
                          color: TossTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '18세',
                      style: TossTheme.body2.copyWith(color: TossTheme.textGray500),
                    ),
                    Text(
                      '50세',
                      style: TossTheme.body2.copyWith(color: TossTheme.textGray500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: TossTheme.primaryBlue,
                    inactiveTrackColor: TossTheme.borderGray200,
                    thumbColor: TossTheme.primaryBlue,
                    overlayColor: TossTheme.primaryBlue.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _age.toDouble(),
                    min: 18,
                    max: 50,
                    divisions: 32,
                    onChanged: (value) {
                      setState(() {
                        _age = value.round();
                      });
                    },
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: TossTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_age세',
                      style: TossTheme.body1.copyWith(
                        color: TossDesignSystem.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Gender Section
          Text(
            '성별',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton('남성', '남성', Icons.male),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderButton('여성', '여성', Icons.female),
              ),
            ],
          ).animate(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Relationship Status Section
          Text(
            '현재 연애 상태',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: RelationshipStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRelationshipStatusButton(status),
              );
            }).toList(),
          ).animate(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 40),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '다음 단계',
              onPressed: _canProceed ? _handleNext : null,
              style: _canProceed ? TossButtonStyle.primary : TossButtonStyle.secondary,
            ),
          ).animate(delay: 1000.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.1) : TossTheme.backgroundSecondary,
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? TossTheme.primaryBlue : TossTheme.textGray600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TossTheme.body1.copyWith(
                color: isSelected ? TossTheme.primaryBlue : TossTheme.textGray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipStatusButton(RelationshipStatus status) {
    final isSelected = _relationshipStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _relationshipStatus = status;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue.withValues(alpha: 0.1) : TossTheme.backgroundSecondary,
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              _getRelationshipStatusEmoji(status),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getRelationshipStatusText(status),
                style: TossTheme.body1.copyWith(
                  color: isSelected ? TossTheme.primaryBlue : TossTheme.textBlack,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: TossTheme.primaryBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}