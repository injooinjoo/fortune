import 'package:flutter/material.dart';
import 'info_item.dart';

/// 게임/엔터 컨텐츠
class GameContent extends StatelessWidget {
  const GameContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            InfoItem(label: '추천 게임', value: 'RPG, 전략 게임'),
            InfoItem(label: '추천 콘텐츠', value: '여행 다큐멘터리'),
            InfoItem(label: '음악', value: '재즈, 클래식'),
            InfoItem(label: '행운 시간', value: '밤 10시 이후'),
          ],
        ),
      ),
    );
  }
}
