import 'package:flutter/material.dart';
import 'info_item.dart';

/// 여행/장소 컨텐츠
class TravelContent extends StatelessWidget {
  const TravelContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            InfoItem(label: '데이트 장소', value: '한강공원 산책로'),
            InfoItem(label: '드라이브', value: '북한산 둘레길'),
            InfoItem(label: '산책 장소', value: '남산 타워 주변'),
            InfoItem(label: '추천 시간', value: '오후 3시~6시'),
          ],
        ),
      ),
    );
  }
}
