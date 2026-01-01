import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import 'info_item.dart';

/// 게임/엔터 컨텐츠 - API 데이터 사용
class GameContent extends StatelessWidget {
  final Map<String, dynamic>? data;

  const GameContent({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // API 데이터에서 추출 (없으면 기본값)
    final gameDetail = data?['gameDetail'] as Map<String, dynamic>?;
    final recommendedGame = gameDetail?['recommendedGame'] ?? 'RPG, 전략 게임';
    final content = gameDetail?['content'] ?? '여행 다큐멘터리';
    final music = gameDetail?['music'] ?? '재즈, 클래식';
    final luckyTime = gameDetail?['luckyTime'] ?? '밤 10시 이후';
    final tip = gameDetail?['tip'];

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
          InfoItem(label: '추천 게임', value: recommendedGame),
          InfoItem(label: '추천 콘텐츠', value: content),
          InfoItem(label: '음악', value: music),
          InfoItem(label: '행운 시간', value: luckyTime),
          if (tip != null) InfoItem(label: '팁', value: tip),
        ],
      ),
    );
  }
}
