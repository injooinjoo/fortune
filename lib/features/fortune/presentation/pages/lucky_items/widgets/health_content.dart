import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 운동/건강 컨텐츠 - ChatGPT 스타일
class HealthContent extends StatelessWidget {
  const HealthContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: const Column(
        children: [
          InfoItem(label: '추천 운동', value: '조깅, 요가'),
          InfoItem(label: '운동 시간', value: '아침 7시~9시'),
          InfoItem(label: '운동 장소', value: '헬스장, 요가 스튜디오'),
          InfoItem(label: '건강 팁', value: '충분한 수분 섭취'),
        ],
      ),
    );
  }
}
