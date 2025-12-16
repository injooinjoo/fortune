import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
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
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '유명인과의 사주 궁합',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        celebrities.when(
          data: (celebList) {
            if (celebList.isEmpty) {
              return _buildFallbackCelebrityCards();
            }
            return Column(
              children: celebList.take(3).map((celeb) {
                // 설명 생성 (그룹명 또는 카테고리)
                final description = celeb.category.isNotEmpty
                    ? celeb.category
                    : (celeb.birthDate.isNotEmpty ? '${celeb.birthDate.substring(0, 4)}년생' : '');

                // 생년월일 기반 궁합도 계산 (오행 데이터 없을 때)
                int compatibility = 50;
                if (celeb.birthDate.isNotEmpty) {
                  try {
                    final birthYear = int.parse(celeb.birthDate.substring(0, 4));
                    final monthDay = celeb.birthDate.length >= 10
                        ? int.parse(celeb.birthDate.substring(5, 7)) + int.parse(celeb.birthDate.substring(8, 10))
                        : 15;
                    // 생년 + 월일 조합으로 55-95% 범위의 궁합도 생성
                    compatibility = ((birthYear % 40) + monthDay).clamp(55, 95);
                  } catch (e) {
                    compatibility = 65 + (celeb.name.hashCode % 30); // fallback
                  }
                } else {
                  compatibility = 60 + (celeb.name.hashCode.abs() % 35); // 이름 기반 fallback
                }
                compatibility = compatibility.clamp(55, 95);

                debugPrint('🎭 [CELEBRITY_CARD] ${celeb.name}: birthDate=${celeb.birthDate} → compatibility=$compatibility%');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
          padding: const EdgeInsets.only(bottom: 10),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                        size: 22,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DSTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: DSTypography.bodySmall.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 궁합도
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _compatibilityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$compatibility%',
              style: TextStyle(
                color: _compatibilityColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
