import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/widgets/face_mesh_overlay.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';
import '../constants/lookalike_celebrities.dart';

/// 관상 분석 결과 위젯
/// Face Mesh + 닮은꼴 연예인 + 예상 나이를 표시
class BlindDateFaceAnalysis extends StatelessWidget {
  /// 상대방의 예상 나이
  final int estimatedAge;

  /// 닮은꼴 연예인 정보
  final Map<String, String> lookalikeData;

  /// 관상 특징 리스트
  final List<String> faceTraits;

  /// 상대방 성별 (닮은꼴 표시용)
  final bool isPartnerMale;

  const BlindDateFaceAnalysis({
    super.key,
    required this.estimatedAge,
    required this.lookalikeData,
    required this.faceTraits,
    required this.isPartnerMale,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final celebrityName = lookalikeData['name'] ?? '알 수 없음';
    final celebrityType = lookalikeData['type'] ?? '';
    final celebrityTrait = lookalikeData['trait'] ?? '';

    return GlassCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          // 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.face_retouching_natural,
                color: Color(0xFF00D9D9),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '상대방 관상 분석',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),

          // Face Mesh 디스플레이
          const DualFaceMeshDisplay(
            size: 100,
          ),
          const SizedBox(height: DSSpacing.lg),

          // 닮은꼴 연예인 + 예상 나이 (가로 배치)
          Row(
            children: [
              // 닮은꼴 연예인
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.star_rounded,
                  label: '닮은꼴',
                  value: celebrityName,
                  subValue: '$celebrityType · $celebrityTrait',
                  iconColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              // 예상 나이
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.cake_rounded,
                  label: '예상 나이',
                  value: '$estimatedAge세',
                  subValue: '±3세 오차 있음',
                  iconColor: Colors.pinkAccent,
                ),
              ),
            ],
          ),

          // 관상 특징
          if (faceTraits.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildFaceTraitsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required Color iconColor,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: DSTypography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: DSTypography.headingSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: DSTypography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFaceTraitsSection(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9D9).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: const Color(0xFF00D9D9).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF00D9D9),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '관상 특징',
                style: DSTypography.labelMedium.copyWith(
                  color: const Color(0xFF00D9D9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...faceTraits.map((trait) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: DSTypography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        trait,
                        style: DSTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// 관상 분석 데이터 생성 헬퍼
class FaceAnalysisData {
  final int estimatedAge;
  final Map<String, String> lookalikeData;
  final List<String> faceTraits;

  FaceAnalysisData({
    required this.estimatedAge,
    required this.lookalikeData,
    required this.faceTraits,
  });

  /// 상대방 정보 기반으로 관상 분석 데이터 생성
  /// [partnerBirthDate] 상대방 생년월일 (없으면 랜덤 나이 생성)
  /// [isPartnerMale] 상대방이 남성인지 여부
  factory FaceAnalysisData.generate({
    DateTime? partnerBirthDate,
    required bool isPartnerMale,
  }) {
    // 예상 나이 계산
    final age = partnerBirthDate != null
        ? estimateAge(partnerBirthDate)
        : 25 + (DateTime.now().millisecondsSinceEpoch % 15); // 25~39세 랜덤

    // 닮은꼴 연예인 선택
    final lookalike = getRandomLookalike(isMale: isPartnerMale);

    // 관상 특징 생성
    final traits = generateFaceTraits(isMale: isPartnerMale);

    return FaceAnalysisData(
      estimatedAge: age,
      lookalikeData: lookalike,
      faceTraits: traits,
    );
  }
}
