import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 운동/건강 컨텐츠 - API 데이터 사용
class HealthContent extends StatelessWidget {
  final Map<String, dynamic>? data;

  const HealthContent({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터에서 추출 (없으면 기본값)
    final healthDetail = data?['healthDetail'] as Map<String, dynamic>?;
    final recommendedExercise = healthDetail?['recommendedExercise'] ?? '조깅, 요가';
    final exerciseTime = healthDetail?['exerciseTime'] ?? '아침 7시~9시';
    final exercisePlace = healthDetail?['exercisePlace'] ?? '헬스장, 요가 스튜디오';
    final healthTip = healthDetail?['healthTip'] ?? '충분한 수분 섭취';
    final avoidExercise = healthDetail?['avoidExercise'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          InfoItem(label: '추천 운동', value: recommendedExercise),
          InfoItem(label: '운동 시간', value: exerciseTime),
          InfoItem(label: '운동 장소', value: exercisePlace),
          InfoItem(label: '건강 팁', value: healthTip),
          if (avoidExercise != null)
            InfoItem(label: '피해야 할 운동', value: avoidExercise),
        ],
      ),
    );
  }
}
