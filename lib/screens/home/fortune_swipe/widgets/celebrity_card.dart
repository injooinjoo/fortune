import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/celebrity_saju_provider.dart';

/// 🎭 유사 사주 연예인 카드 - ChatGPT Pulse 스타일
class CelebrityCard extends ConsumerWidget {
  final bool isDark;

  const CelebrityCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final celebrities = ref.watch(randomCelebritiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '나와 비슷한 사주',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '유명인과의 사주 궁합',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        celebrities.when(
          data: (celebList) {
            if (celebList.isEmpty) {
              return _buildFallbackCelebrityCards();
            }
            return Column(
              children: celebList.take(3).map((celeb) {
                // 사주 문자열로 간단한 설명 생성
                final description = '${celeb.category} · ${celeb.sajuString}';
                // 오행 기반 궁합도 계산 (간단 버전)
                final compatibility = ((celeb.woodCount + celeb.fireCount + celeb.earthCount + celeb.metalCount + celeb.waterCount) * 10).clamp(50, 95);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CelebrityCardItem(
                    name: celeb.name,
                    description: description,
                    imageUrl: null,
                    compatibility: compatibility,
                    isDark: isDark,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _buildFallbackCelebrityCards(),
        ),
      ],
    );
  }

  Widget _buildFallbackCelebrityCards() {
    final fallbackData = [
      {'name': '이순신', 'desc': '강한 리더십과 결단력', 'compatibility': 85},
      {'name': '세종대왕', 'desc': '지혜와 창의성의 조화', 'compatibility': 78},
      {'name': '신사임당', 'desc': '예술적 감각과 지성', 'compatibility': 72},
    ];

    return Column(
      children: fallbackData.map((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CelebrityCardItem(
            name: data['name'] as String,
            description: data['desc'] as String,
            imageUrl: null,
            compatibility: data['compatibility'] as int,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }
}

class _CelebrityCardItem extends StatelessWidget {
  final String name;
  final String description;
  final String? imageUrl;
  final int compatibility;
  final bool isDark;

  const _CelebrityCardItem({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.compatibility,
    required this.isDark,
  });

  Color get _compatibilityColor {
    if (compatibility >= 80) return const Color(0xFF10B981);
    if (compatibility >= 60) return const Color(0xFF3B82F6);
    if (compatibility >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TypographyUnified.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 궁합도
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _compatibilityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$compatibility%',
              style: TextStyle(
                color: _compatibilityColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
