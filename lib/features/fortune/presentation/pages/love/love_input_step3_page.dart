import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';

enum MeetingPlace { cafe, gym, library, meeting, app, hobby }
enum RelationshipGoal { casual, serious, marriage }

class LoveInputStep3Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  
  const LoveInputStep3Page({super.key, required this.onNext});

  @override
  State<LoveInputStep3Page> createState() => _LoveInputStep3PageState();
}

class _LoveInputStep3PageState extends State<LoveInputStep3Page> {
  RangeValues _preferredAgeRange = const RangeValues(20, 30);
  final Set<String> _preferredPersonality = {};
  final Set<MeetingPlace> _preferredMeetingPlaces = {};
  RelationshipGoal? _relationshipGoal;

  final List<String> _personalityTraits = [
    '활발한', '차분한', '유머러스한', '진중한', '외향적인', '내향적인',
    '모험적인', '안정적인', '로맨틱한', '현실적인', '창의적인', '체계적인'
  ];

  bool get _canProceed => _preferredPersonality.isNotEmpty && 
                         _preferredMeetingPlaces.isNotEmpty && 
                         _relationshipGoal != null;

  String _getMeetingPlaceText(MeetingPlace place) {
    switch (place) {
      case MeetingPlace.cafe:
        return '카페·맛집';
      case MeetingPlace.gym:
        return '헬스장·운동시설';
      case MeetingPlace.library:
        return '도서관·문화공간';
      case MeetingPlace.meeting:
        return '소개팅·미팅';
      case MeetingPlace.app:
        return '앱·온라인';
      case MeetingPlace.hobby:
        return '취미모임·동호회';
    }
  }

  String _getMeetingPlaceEmoji(MeetingPlace place) {
    switch (place) {
      case MeetingPlace.cafe:
        return '☕';
      case MeetingPlace.gym:
        return '🏋️';
      case MeetingPlace.library:
        return '📚';
      case MeetingPlace.meeting:
        return '👥';
      case MeetingPlace.app:
        return '📱';
      case MeetingPlace.hobby:
        return '🎭';
    }
  }

  String _getRelationshipGoalText(RelationshipGoal goal) {
    switch (goal) {
      case RelationshipGoal.casual:
        return '가벼운 만남';
      case RelationshipGoal.serious:
        return '진지한 연애';
      case RelationshipGoal.marriage:
        return '결혼 전제';
    }
  }

  String _getRelationshipGoalEmoji(RelationshipGoal goal) {
    switch (goal) {
      case RelationshipGoal.casual:
        return '😊';
      case RelationshipGoal.serious:
        return '💕';
      case RelationshipGoal.marriage:
        return '💍';
    }
  }

  void _handleNext() {
    if (!_canProceed) return;
    
    widget.onNext({
      'preferredAgeRange': {
        'min': _preferredAgeRange.start.round(),
        'max': _preferredAgeRange.end.round(),
      },
      'preferredPersonality': _preferredPersonality.toList(),
      'preferredMeetingPlaces': _preferredMeetingPlaces.map((p) => p.toString().split('.').last).toList(),
      'relationshipGoal': _relationshipGoal.toString().split('.').last,
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
            '이상형을\n알려주세요',
            style: TossTheme.heading2.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ).animate().slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            '구체적일수록 정확한 운세를 알려드려요',
            style: TossTheme.body1.copyWith(
              color: TossTheme.textGray600,
            ),
          ).animate(delay: 200.ms).slideX(begin: -0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 32),
          
          // Preferred Age Range
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
                Text(
                  '선호 나이대',
                  style: TossTheme.heading4.copyWith(
                    color: TossTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
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
                      '45세',
                      style: TossTheme.body2.copyWith(color: TossTheme.textGray500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _preferredAgeRange,
                  min: 18,
                  max: 45,
                  divisions: 27,
                  activeColor: TossTheme.primaryBlue,
                  inactiveColor: TossTheme.borderGray200,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _preferredAgeRange = values;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: TossTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_preferredAgeRange.start.round()}세 ~ ${_preferredAgeRange.end.round()}세',
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
          
          // Preferred Personality
          Text(
            '선호하는 성격',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '최대 4개까지 선택',
            style: TossTheme.body2.copyWith(
              color: TossTheme.textGray600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _personalityTraits.map((trait) {
              return _buildPersonalityChip(trait);
            }).toList(),
          ).animate(delay: 600.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Preferred Meeting Places
          Text(
            '선호하는 만남 장소',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
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
            childAspectRatio: 2.5,
            children: MeetingPlace.values.map((place) {
              return _buildMeetingPlaceChip(place);
            }).toList(),
          ).animate(delay: 700.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          const SizedBox(height: 24),
          
          // Relationship Goal
          Text(
            '원하는 관계',
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: RelationshipGoal.values.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRelationshipGoalButton(goal),
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
          ).animate(delay: 900.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPersonalityChip(String trait) {
    final isSelected = _preferredPersonality.contains(trait);
    final canSelect = _preferredPersonality.length < 4 || isSelected;
    
    return GestureDetector(
      onTap: canSelect ? () {
        setState(() {
          if (isSelected) {
            _preferredPersonality.remove(trait);
          } else if (_preferredPersonality.length < 4) {
            _preferredPersonality.add(trait);
          }
        });
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? TossTheme.primaryBlue 
              : canSelect 
                  ? TossTheme.backgroundSecondary 
                  : TossTheme.disabledGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? TossTheme.primaryBlue 
                : canSelect 
                    ? TossTheme.borderGray200 
                    : TossTheme.disabledGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          trait,
          style: TossTheme.body2.copyWith(
            color: isSelected 
                ? TossDesignSystem.white 
                : canSelect 
                    ? TossTheme.textBlack 
                    : TossTheme.disabledGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingPlaceChip(MeetingPlace place) {
    final isSelected = _preferredMeetingPlaces.contains(place);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _preferredMeetingPlaces.remove(place);
          } else {
            _preferredMeetingPlaces.add(place);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? TossTheme.primaryBlue : TossTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMeetingPlaceEmoji(place),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _getMeetingPlaceText(place),
                style: TossTheme.body2.copyWith(
                  color: isSelected ? TossDesignSystem.white : TossTheme.textBlack,
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

  Widget _buildRelationshipGoalButton(RelationshipGoal goal) {
    final isSelected = _relationshipGoal == goal;
    return GestureDetector(
      onTap: () {
        setState(() {
          _relationshipGoal = goal;
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
              _getRelationshipGoalEmoji(goal),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getRelationshipGoalText(goal),
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