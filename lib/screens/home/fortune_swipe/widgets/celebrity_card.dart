import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../data/models/celebrity_saju.dart';
import '../../../../presentation/providers/celebrity_saju_provider.dart';

/// 🎭 오늘 운세가 비슷한 유명인 카드
///
/// 사용자의 오늘 운세와 유명인의 오늘 운세를 비교하여 유사한 유명인 표시
/// - 매일 다른 결과 (오늘 일진 기반)
/// - API 비용 없음 (로컬 계산)
/// - 유사도 50점 이상, 최대 3명 표시
class CelebrityCard extends ConsumerWidget {
  const CelebrityCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 오늘 운세가 비슷한 유명인 (매일 다른 결과, 로컬 계산)
    final celebritiesAsync = ref.watch(dailySimilarCelebritiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Text(
          '오늘 운세가 비슷한 유명인',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 나와 비슷한 하루를 보내는 유명인',
          style: context.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        celebritiesAsync.when(
          data: (celebDataList) {
            if (celebDataList.isEmpty) {
              return _buildEmptyState(context);
            }
            // 이미 1~3명으로 필터링되어 있음
            return Column(
              children: celebDataList.map((data) {
                final celeb = data['celebrity'] as CelebritySaju;
                // 오늘 운세 유사도 (100점 만점)
                final similarity = (data['similarity'] ?? data['compatibility']) as int;

                // 설명 생성 (한글 카테고리 또는 출생년도)
                final description = celeb.categoryKorean.isNotEmpty
                    ? celeb.categoryKorean
                    : (celeb.birthDate.isNotEmpty ? '${celeb.birthDate.substring(0, 4)}년생' : '');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CelebrityCardItem(
                    name: celeb.name,
                    description: description,
                    imageUrl: celeb.characterImageUrl,
                    compatibility: similarity,
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
          error: (_, __) => _buildEmptyState(context),
        ),
      ],
    );
  }

  /// 데이터 없을 때 표시할 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '유명인 데이터를 불러오는 중...',
          style: TypographyUnified.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CelebrityCardItem extends StatelessWidget {
  final String name;
  final String description;
  final String? imageUrl;
  final int compatibility;

  const _CelebrityCardItem({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.compatibility,
  });

  /// 전통 오방색 기반 궁합 색상 - 변경 금지
  Color get _compatibilityColor {
    if (compatibility >= 80) return const Color(0xFF2E8B57); // 오방색: 목(木) - 최상
    if (compatibility >= 60) return const Color(0xFFDAA520); // 오방색: 토(土) - 양호
    if (compatibility >= 40) return const Color(0xFF1E3A5F); // 오방색: 수(水) - 보통
    return const Color(0xFFDC143C); // 오방색: 화(火) - 주의
  }

  /// 이름 첫 글자로 아바타 배경색 결정 (전통 오방색) - 변경 금지
  Color get _avatarColor {
    final colors = [
      const Color(0xFF2E8B57), // 오방색: 목(木) - 청록
      const Color(0xFFDC143C), // 오방색: 화(火) - 진홍
      const Color(0xFFDAA520), // 오방색: 토(土) - 금황
      const Color(0xFFC0A062), // 오방색: 금(金) - 금색
      const Color(0xFF1E3A5F), // 오방색: 수(水) - 남색
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  /// 프로필 아바타 위젯 (이미지 또는 이니셜)
  Widget _buildProfileAvatar(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1) : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: imageUrl != null
            ? context.colors.surface
            : _avatarColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitialAvatar(initial),
              ),
            )
          : _buildInitialAvatar(initial),
    );
  }

  /// 이니셜 아바타 위젯
  Widget _buildInitialAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: TypographyUnified.heading4.copyWith(
          color: _avatarColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 프로필 이미지 (이니셜 아바타 fallback)
          _buildProfileAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: context.labelMedium.copyWith(
                    color: context.colors.textSecondary,
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
              style: context.labelLarge.copyWith(
                color: _compatibilityColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
