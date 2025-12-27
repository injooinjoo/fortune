import 'package:flutter/material.dart';
import '../../../../core/theme/obangseok_colors.dart';
import 'fortune_entry_card.dart';

/// AI 분석/소개팅/직업 상단 진입 섹션
///
/// 운세 목록 페이지 상단에 고정 배치되어
/// Face AI, 소개팅, 직업 인사이트로 빠르게 진입할 수 있는 카드 영역
///
/// Chat-First 아키텍처: Face AI는 네비게이션 바에서 탐구 탭 내부로 이동
class FortuneEntrySection extends StatelessWidget {
  final bool isDark;

  const FortuneEntrySection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Face AI 진입 카드 (상단 배치 - Chat-First 아키텍처)
          Row(
            children: [
              Expanded(
                child: FortuneEntryCard(
                  title: 'AI 얼굴 분석',
                  subtitle: 'AI가 분석하는 나의 인상',
                  emoji: '🪞',
                  routePath: '/fortune/face-ai',
                  isDark: isDark,
                  accentColor: ObangseokColors.cheong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 기존 카드들
          Row(
            children: [
              Expanded(
                child: FortuneEntryCard(
                  title: '소개팅',
                  subtitle: '오늘의 소개팅 인사이트',
                  imagePath: 'assets/icons/fortune/blind_date.png',
                  routePath: '/blind-date',
                  isDark: isDark,
                  accentColor: ObangseokColors.cheong,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FortuneEntryCard(
                  title: '직업',
                  subtitle: '취업/직업/사업 인사이트',
                  imagePath: 'assets/icons/fortune/career.png',
                  routePath: '/career',
                  isDark: isDark,
                  accentColor: ObangseokColors.hwang,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
