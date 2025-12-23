import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';

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
    final int completed = _completedMissions.where((mission) => mission).length;
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
        color: DSColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DSColors.border),
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
                  color: DSColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: DSColors.success,
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
                      style: DSTypography.headingSmall.copyWith(
                        color: DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '완료: ${_completedMissions.where((m) => m).length}/${_completedMissions.length}',
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.textSecondary,
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
                      backgroundColor: DSColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _completionPercentage == 1.0 
                            ? DSColors.success 
                            : DSColors.accent,
                      ),
                    ),
                    Text(
                      '${(_completionPercentage * 100).round()}%',
                      style: DSTypography.labelSmall.copyWith(
                        color: _completionPercentage == 1.0 
                            ? DSColors.success 
                            : DSColors.accent,
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
                color: DSColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DSColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: DSColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 모든 미션 완료! 오늘 하루도 사랑스러운 하루였어요!',
                      style: DSTypography.bodyMedium.copyWith(
                        color: DSColors.success,
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
              ? DSColors.success.withValues(alpha: 0.1)
              : DSColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted 
                ? DSColors.success.withValues(alpha: 0.3)
                : DSColors.border,
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
                    ? DSColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted 
                      ? DSColors.success 
                      : DSColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ).animate().scale(duration: 200.ms)
                  : null,
            ),
            
            const SizedBox(width: 12),
            
            // 미션 텍스트
            Expanded(
              child: Text(
                mission,
                style: DSTypography.bodyLarge.copyWith(
                  color: isCompleted 
                      ? DSColors.success 
                      : DSColors.textPrimary,
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
                  color: DSColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 12,
                ),
              ).animate().scale(duration: 300.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }
}