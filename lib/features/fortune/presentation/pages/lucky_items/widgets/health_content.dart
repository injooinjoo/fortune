import 'package:flutter/material.dart';
import 'info_item.dart';

/// 운동/건강 컨텐츠
class HealthContent extends StatelessWidget {
  const HealthContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            InfoItem(label: '추천 운동', value: '조깅, 요가'),
            InfoItem(label: '운동 시간', value: '아침 7시~9시'),
            InfoItem(label: '운동 장소', value: '헬스장, 요가 스튜디오'),
            InfoItem(label: '건강 팁', value: '충분한 수분 섭취'),
          ],
        ),
      ),
    );
  }
}
