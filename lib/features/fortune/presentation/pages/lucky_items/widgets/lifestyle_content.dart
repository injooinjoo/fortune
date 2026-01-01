import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 라이프스타일 컨텐츠 - API 데이터 사용
class LifestyleContent extends StatelessWidget {
  final Map<String, dynamic>? data;

  const LifestyleContent({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터에서 추출 (없으면 기본값)
    final lifestyleDetail = data?['lifestyleDetail'] as Map<String, dynamic>?;
    final hobby = lifestyleDetail?['hobby'] ?? '독서, 영화 감상';
    final meeting = lifestyleDetail?['meeting'] ?? '친구와 카페에서';
    final snsTime = lifestyleDetail?['snsTime'] ?? '저녁 7시~9시';
    final dailyTip = lifestyleDetail?['dailyTip'] ?? '새로운 시도를 해보세요';
    final avoid = lifestyleDetail?['avoid'];

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
          InfoItem(label: '취미 활동', value: hobby),
          InfoItem(label: '만남', value: meeting),
          InfoItem(label: 'SNS 시간', value: snsTime),
          InfoItem(label: '일상 팁', value: dailyTip),
          if (avoid != null) InfoItem(label: '피해야 할 것', value: avoid),
        ],
      ),
    );
  }
}
