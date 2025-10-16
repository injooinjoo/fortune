import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';

class LoveMissionCard extends StatefulWidget {
  final List<String> missions;
  final Function(int) onMissionComplete;
  
  const LoveMissionCard({
    super.key,
    required this.missions,
    required this.onMissionComplete,
  });

  @override
  State<LoveMissionCard> createState() => _LoveMissionCardState();
}

class _LoveMissionCardState extends State<LoveMissionCard> {
  List<bool> _completedMissions = [];

  @override
  void initState() {
    super.initState();
    _completedMissions = List.filled(widget.missions.length, false);
  }

  double get _completionPercentage {
    if (_completedMissions.isEmpty) return 0;
    int completed = _completedMissions.where((mission) => mission).length;
    return completed / _completedMissions.length;
  }

  void _toggleMission(int index) {
    setState(() {
      _completedMissions[index] = !_completedMissions[index];
    });
    
    if (_completedMissions[index]) {
      widget.onMissionComplete(index);
      _showCompletionAnimation(index);
    }
  }

  void _showCompletionAnimation(int index) {
    // 미션 완료 애니메이션 효과
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TossTheme.borderGray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TossTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.task_alt,
                  color: TossTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 연애 미션',
                      style: TossTheme.heading4.copyWith(
                        color: TossTheme.textBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '완료: ${_completedMissions.where((m) => m).length}/${_completedMissions.length}',
                      style: TossTheme.caption.copyWith(
                        color: TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
              ),
              // 진행률 표시
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _completionPercentage,
                      strokeWidth: 4,
                      backgroundColor: TossTheme.borderGray200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _completionPercentage == 1.0 
                            ? TossTheme.success 
                            : TossTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      '${(_completionPercentage * 100).round()}%',
                      style: TossTheme.caption.copyWith(
                        color: _completionPercentage == 1.0 
                            ? TossTheme.success 
                            : TossTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 미션 리스트
          ...widget.missions.asMap().entries.map((entry) {
            final index = entry.key;
            final mission = entry.value;
            final isCompleted = _completedMissions[index];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMissionItem(
                index,
                mission,
                isCompleted,
              ),
            );
          }),
          
          // 완료 메시지
          if (_completionPercentage == 1.0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: TossTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: TossTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 모든 미션 완료! 오늘 하루도 사랑스러운 하루였어요!',
                      style: TossTheme.body2.copyWith(
                        color: TossTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, duration: 600.ms).fadeIn(),
        ],
      ),
    ).animate(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildMissionItem(int index, String mission, bool isCompleted) {
    return GestureDetector(
      onTap: () => _toggleMission(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted 
              ? TossTheme.success.withValues(alpha: 0.1)
              : TossTheme.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? TossTheme.success.withValues(alpha: 0.3)
                : TossTheme.borderGray200,
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? TossTheme.success
                    : TossDesignSystem.transparent,
                border: Border.all(
                  color: isCompleted 
                      ? TossTheme.success 
                      : TossTheme.borderGray300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      color: TossDesignSystem.white,
                      size: 16,
                    ).animate().scale(duration: 200.ms)
                  : null,
            ),
            
            const SizedBox(width: 12),
            
            // 미션 텍스트
            Expanded(
              child: Text(
                mission,
                style: TossTheme.body1.copyWith(
                  color: isCompleted 
                      ? TossTheme.success 
                      : TossTheme.textBlack,
                  fontWeight: FontWeight.w500,
                  decoration: isCompleted 
                      ? TextDecoration.lineThrough 
                      : TextDecoration.none,
                ),
              ),
            ),
            
            // 완료 아이콘
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: TossTheme.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: TossDesignSystem.white,
                  size: 12,
                ),
              ).animate().scale(duration: 300.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }
}