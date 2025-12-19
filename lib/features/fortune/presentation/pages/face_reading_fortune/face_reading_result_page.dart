import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../domain/models/fortune_result.dart';
import '../../widgets/face_reading/celebrity_match_carousel.dart';
import '../../../../../core/services/fortune_haptic_service.dart';

/// 관상운세 결과 페이지 - 세분화된 관상 분석
class FaceReadingResultPage extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback? onUnlockRequested;
  final File? uploadedImageFile;

  const FaceReadingResultPage({
    super.key,
    required this.result,
    this.onUnlockRequested,
    this.uploadedImageFile,
  });

  @override
  ConsumerState<FaceReadingResultPage> createState() => _FaceReadingResultPageState();
}

class _FaceReadingResultPageState extends ConsumerState<FaceReadingResultPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();

    // 관상 분석 결과 공개 햅틱 (신비로운 공개)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hapticTriggered) {
        _hapticTriggered = true;
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 데이터 추출
    final rawData = widget.result.details ?? {};
    final data = (rawData['details'] as Map<String, dynamic>?) ?? rawData;
    final luckScore =
        ((rawData['luckScore'] ?? widget.result.overallScore) ?? 75).toInt();
    final faceType = data['face_type'] as String? ?? '타원형';
    final overallFortune = data['overall_fortune'] as String? ?? '';

    // ChatGPT 스타일 색상
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final cardColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F7F8);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final accentColor = const Color(0xFF10A37F);

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 업로드 이미지 + 관상 맵 이미지 나란히
            _buildHeaderWithFaceMap(
              isDark: isDark,
              faceType: faceType,
              luckScore: luckScore,
              cardColor: cardColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              accentColor: accentColor,
            ),

            const SizedBox(height: 20),

            // 총평 바로 아래
            if (overallFortune.isNotEmpty)
              _buildSummarySection(
                content: overallFortune,
                isDark: isDark,
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

            const SizedBox(height: 24),

            // 닮은꼴 연예인
            if (data['similar_celebrities'] != null &&
                (data['similar_celebrities'] as List).isNotEmpty) ...[
              CelebrityMatchCarousel(
                celebrities: (data['similar_celebrities'] as List)
                    .map((e) => e as Map<String, dynamic>)
                    .toList(),
                isBlurred: false,
              ),
              const SizedBox(height: 24),
            ],

            // 닮은꼴 상(相) 분류 - 2025 트렌드
            if (data['faceTypeClassification'] != null) ...[
              _buildFaceTypeClassification(
                data: data['faceTypeClassification'] as Map<String, dynamic>,
                isDark: isDark,
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 24),
            ],

            // 세분화된 부위별 분석
            _buildDetailedAnalysis(
              data: data,
              isDark: isDark,
              cardColor: cardColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              accentColor: accentColor,
            ),

            // 하단 여백
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithFaceMap({
    required bool isDark,
    required String faceType,
    required int luckScore,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 두 이미지 나란히
          Row(
            children: [
              // 업로드한 얼굴 이미지
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.uploadedImageFile != null
                        ? Image.file(
                            widget.uploadedImageFile!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isDark
                                ? const Color(0xFF3D3D3D)
                                : const Color(0xFFE5E5E5),
                            child: Icon(
                              Icons.face,
                              size: 48,
                              color: textSecondary,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 관상 맵 이미지
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/face_reading/face_map_korean.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark
                              ? const Color(0xFF3D3D3D)
                              : const Color(0xFFE5E5E5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face_retouching_natural,
                                size: 40,
                                color: textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '관상 맵',
                                style: context.labelSmall.copyWith(
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 얼굴형 + 점수
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faceType,
                      style: context.heading2.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '관상 분석 결과',
                      style: context.labelSmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$luckScore점',
                  style: context.heading3.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 점수 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: luckScore / 100,
              backgroundColor:
                  isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E5E5),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummarySection({
    required String content,
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '총평',
                style: context.bodyLarge.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            FortuneTextCleaner.clean(content),
            style: context.bodyLarge.copyWith(
              color: textPrimary,
              height: 1.7,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  /// 닮은꼴 상(相) 분류 섹션 - 동물상 + 인상 분류
  Widget _buildFaceTypeClassification({
    required Map<String, dynamic> data,
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final animalType = data['animalType'] as Map<String, dynamic>?;
    final impressionType = data['impressionType'] as Map<String, dynamic>?;

    // 동물상 이모지 매핑
    const animalEmojis = {
      '강아지상': '🐶',
      '고양이상': '🐱',
      '여우상': '🦊',
      '토끼상': '🐰',
      '곰상': '🐻',
      '늑대상': '🐺',
      '사슴상': '🦌',
      '다람쥐상': '🐿️',
    };

    // 인상 이모지 매핑
    const impressionEmojis = {
      '아랍상': '🧊',
      '두부상': '🫧',
      '하이브리드': '✨',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              const Text(
                '✨',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '닮은꼴 상(相) 분류',
                style: context.bodyLarge.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 동물상 카드
          if (animalType != null) ...[
            _buildAnimalTypeCard(
              animalType: animalType,
              emojis: animalEmojis,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 12),
          ],

          // 인상 분류 카드
          if (impressionType != null)
            _buildImpressionTypeCard(
              impressionType: impressionType,
              emojis: impressionEmojis,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  /// 동물상 카드 위젯
  Widget _buildAnimalTypeCard({
    required Map<String, dynamic> animalType,
    required Map<String, String> emojis,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final primary = animalType['primary'] as String? ?? '알 수 없음';
    final secondary = animalType['secondary'] as String?;
    final matchScore = (animalType['matchScore'] as num?)?.toInt() ?? 75;
    final description = animalType['description'] as String? ?? '';
    final traits = (animalType['traits'] as List?)?.cast<String>() ?? [];

    final emoji = emojis[primary] ?? '🐾';
    final accentColor = isDark ? const Color(0xFF10A37F) : const Color(0xFF10A37F);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 동물상 타이틀 + 점수
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          primary,
                          style: context.heading2.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (secondary != null && secondary.isNotEmpty) ...[
                          Text(
                            ' + ',
                            style: context.bodyMedium.copyWith(
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            secondary,
                            style: context.bodyMedium.copyWith(
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '매칭 점수 $matchScore점',
                      style: context.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 설명
          if (description.isNotEmpty)
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: textPrimary,
                height: 1.5,
              ),
            ),

          // 특징 태그
          if (traits.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: traits.map((trait) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$trait',
                    style: context.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 인상 분류 카드 위젯
  Widget _buildImpressionTypeCard({
    required Map<String, dynamic> impressionType,
    required Map<String, String> emojis,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final type = impressionType['type'] as String? ?? '알 수 없음';
    final matchScore = (impressionType['matchScore'] as num?)?.toInt() ?? 75;
    final description = impressionType['description'] as String? ?? '';

    final emoji = emojis[type] ?? '✨';
    final accentColor = isDark ? const Color(0xFF7C4DFF) : const Color(0xFF5E35B1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: context.bodyLarge.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$matchScore점',
                      style: context.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.bodySmall.copyWith(
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis({
    required Map<String, dynamic> data,
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    // 오관(五官) 정의 - 5가지 감각 기관
    final ogwanItems = [
      {'key': 'ear', 'name': '귀', 'hanja': '耳', 'gwanName': '채청관', 'desc': '복록과 수명, 지혜'},
      {'key': 'eyebrow', 'name': '눈썹', 'hanja': '眉', 'gwanName': '보수관', 'desc': '형제운, 수명'},
      {'key': 'eye', 'name': '눈', 'hanja': '目', 'gwanName': '감찰관', 'desc': '마음의 창, 성품'},
      {'key': 'nose', 'name': '코', 'hanja': '鼻', 'gwanName': '심판관', 'desc': '재물운, 건강'},
      {'key': 'mouth', 'name': '입', 'hanja': '口', 'gwanName': '출납관', 'desc': '식복, 언어운'},
    ];

    // 십이궁(十二宮) 정의 - 12가지 운세 영역 (Edge Function과 key 일치)
    final sibigungItems = [
      {'key': 'myeongGung', 'name': '명궁', 'hanja': '命宮', 'location': '인당(미간)', 'desc': '운명, 성격, 의지력'},
      {'key': 'jaeBaekGung', 'name': '재백궁', 'hanja': '財帛宮', 'location': '코', 'desc': '재물운, 금전'},
      {'key': 'hyeongJeGung', 'name': '형제궁', 'hanja': '兄弟宮', 'location': '눈썹', 'desc': '형제/자매운'},
      {'key': 'jeonTaekGung', 'name': '전택궁', 'hanja': '田宅宮', 'location': '눈과 눈썹 사이', 'desc': '가정운, 부동산'},
      {'key': 'namNyeoGung', 'name': '남녀궁', 'hanja': '男女宮', 'location': '누당(눈 아래)', 'desc': '자녀운'},
      {'key': 'noBokGung', 'name': '노복궁', 'hanja': '奴僕宮', 'location': '볼/턱', 'desc': '부하/직원운'},
      {'key': 'cheoCheobGung', 'name': '처첩궁', 'hanja': '妻妾宮', 'location': '눈꼬리', 'desc': '배우자운, 연애운'},
      {'key': 'jilAekGung', 'name': '질액궁', 'hanja': '疾厄宮', 'location': '산근(코 시작)', 'desc': '건강운'},
      {'key': 'cheonIGung', 'name': '천이궁', 'hanja': '遷移宮', 'location': '이마 양쪽', 'desc': '이사/여행운'},
      {'key': 'gwanRokGung', 'name': '관록궁', 'hanja': '官祿宮', 'location': '이마 중앙', 'desc': '직업운, 명예'},
      {'key': 'bokDeokGung', 'name': '복덕궁', 'hanja': '福德宮', 'location': '이마 상단', 'desc': '복덕, 정신적 행복'},
      {'key': 'buMoGung', 'name': '부모궁', 'hanja': '父母宮', 'location': '일월각', 'desc': '부모운, 조상'},
    ];

    final ogwan = data['ogwan'] as Map<String, dynamic>?;
    final sibigung = data['sibigung'] as Map<String, dynamic>?;

    final allSections = <Widget>[];
    int sectionIndex = 0;

    // ==================== 오관(五官) 섹션 ====================
    final ogwanSections = <Widget>[];
    if (ogwan != null) {
      for (final item in ogwanItems) {
        final key = item['key'] as String;
        final value = ogwan[key];
        if (value is Map<String, dynamic>) {
          final observation = value['observation'] as String? ?? '';
          final interpretation = value['interpretation'] as String? ?? '';
          final score = (value['score'] as num?)?.toInt() ?? 0;
          final advice = value['advice'] as String? ?? '';

          if (observation.isNotEmpty || interpretation.isNotEmpty || advice.isNotEmpty) {
            ogwanSections.add(
              _buildZoneCard(
                name: item['name'] as String,
                hanja: item['hanja'] as String,
                desc: '${item['gwanName']} · ${item['desc']}',
                observation: observation,
                interpretation: interpretation,
                score: score,
                advice: advice,
                isDark: isDark,
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accentColor: accentColor,
                index: sectionIndex++,
              ),
            );
          }
        }
      }
    }

    if (ogwanSections.isNotEmpty) {
      allSections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오관(五官)',
              style: context.heading2.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '5가지 감각 기관으로 보는 관상',
              style: context.labelSmall.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...ogwanSections,
          ],
        ),
      );
    }

    // ==================== 십이궁(十二宮) 섹션 ====================
    final sibigungSections = <Widget>[];
    if (sibigung != null) {
      for (final item in sibigungItems) {
        final key = item['key'] as String;
        final value = sibigung[key];
        if (value is Map<String, dynamic>) {
          final observation = value['observation'] as String? ?? '';
          final interpretation = value['interpretation'] as String? ?? '';
          final score = (value['score'] as num?)?.toInt() ?? 0;
          final advice = value['advice'] as String? ?? '';

          if (observation.isNotEmpty || interpretation.isNotEmpty || advice.isNotEmpty) {
            sibigungSections.add(
              _buildZoneCard(
                name: item['name'] as String,
                hanja: item['hanja'] as String,
                desc: '${item['location']} · ${item['desc']}',
                observation: observation,
                interpretation: interpretation,
                score: score,
                advice: advice,
                isDark: isDark,
                cardColor: cardColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accentColor: accentColor,
                index: sectionIndex++,
              ),
            );
          }
        }
      }
    }

    if (sibigungSections.isNotEmpty) {
      if (allSections.isNotEmpty) {
        allSections.add(const SizedBox(height: 24));
      }
      allSections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '십이궁(十二宮)',
              style: context.heading2.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12가지 운세 영역으로 보는 관상',
              style: context.labelSmall.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...sibigungSections,
          ],
        ),
      );
    }

    // ==================== 프리미엄 섹션들 ====================
    final premiumSections = _buildPremiumSections(
      data: data,
      isDark: isDark,
      cardColor: cardColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      accentColor: accentColor,
      startIndex: sectionIndex,
    );

    if (premiumSections.isNotEmpty) {
      if (allSections.isNotEmpty) {
        allSections.add(const SizedBox(height: 24));
      }
      allSections.addAll(premiumSections);
    }

    if (allSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...allSections,
      ],
    );
  }

  Widget _buildZoneCard({
    required String name,
    required String hanja,
    required String desc,
    required String observation,
    required String interpretation,
    required int score,
    required String advice,
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: UnifiedBlurWrapper(
        isBlurred: widget.result.isBlurred,
        blurredSections: widget.result.blurredSections,
        sectionKey: 'detailed_analysis',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  // 한자 뱃지
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        hanja,
                        style: context.bodyMedium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name ($hanja)',
                          style: context.heading3.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          desc,
                          style: context.labelSmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (score > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score',
                        style: context.bodyMedium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              // 점수 바
              if (score > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor:
                        isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E5E5),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 4,
                  ),
                ),
              ],

              // 관찰
              if (observation.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  observation,
                  style: context.bodyMedium.copyWith(
                    color: textPrimary,
                    height: 1.6,
                  ),
                ),
              ],

              // 해석
              if (interpretation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  interpretation,
                  style: context.bodyMedium.copyWith(
                    color: textSecondary,
                    height: 1.6,
                  ),
                ),
              ],

              // 조언
              if (advice.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advice,
                          style: context.bodyMedium.copyWith(
                            color: textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (80 * index).ms);
  }

  List<Widget> _buildPremiumSections({
    required Map<String, dynamic> data,
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required int startIndex,
  }) {
    final sections = <Map<String, dynamic>>[];

    if (data['personality'] != null) {
      sections.add({
        'key': 'personality',
        'title': '성격과 기질',
        'content': data['personality'],
        'icon': Icons.psychology_outlined,
      });
    }

    if (data['special_features'] != null) {
      sections.add({
        'key': 'special_features',
        'title': '특별한 관상 특징',
        'content': data['special_features'],
        'icon': Icons.star_outline,
      });
    }

    if (data['advice'] != null) {
      sections.add({
        'key': 'advice',
        'title': '조언과 개운법',
        'content': data['advice'],
        'icon': Icons.lightbulb_outline,
      });
    }

    if (data['wealth_fortune'] != null) {
      sections.add({
        'key': 'wealth_fortune',
        'title': '재물운',
        'content': data['wealth_fortune'],
        'icon': Icons.account_balance_wallet_outlined,
      });
    }

    if (data['love_fortune'] != null) {
      sections.add({
        'key': 'love_fortune',
        'title': '연애운',
        'content': data['love_fortune'],
        'icon': Icons.favorite_outline,
      });
    }

    if (data['career_fortune'] != null) {
      sections.add({
        'key': 'career_fortune',
        'title': '직업운',
        'content': data['career_fortune'],
        'icon': Icons.work_outline,
      });
    }

    if (data['health_fortune'] != null) {
      sections.add({
        'key': 'health_fortune',
        'title': '건강운',
        'content': data['health_fortune'],
        'icon': Icons.favorite_border,
      });
    }

    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;
      final content = section['content'];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: UnifiedBlurWrapper(
          isBlurred: widget.result.isBlurred,
          blurredSections: widget.result.blurredSections,
          sectionKey: section['key'] as String,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      section['icon'] as IconData,
                      color: textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      section['title'] as String,
                      style: context.bodyLarge.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.result.isBlurred &&
                        widget.result.blurredSections.contains(section['key'])) ...[
                      const Spacer(),
                      Icon(
                        Icons.lock_outline,
                        color: textSecondary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // personality가 Map인 경우 구조화된 UI로 표시
                if (content is Map<String, dynamic>)
                  _buildStructuredContent(
                    content: content,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  )
                else
                  Text(
                    FortuneTextCleaner.clean(content is String ? content : content.toString()),
                    style: context.bodyMedium.copyWith(
                      color: textPrimary,
                      height: 1.7,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: (80 * (startIndex + index)).ms);
    }).toList();
  }

  /// Map 형태의 content를 구조화된 UI로 표시
  /// personality: {traits: [...], strengths: [...], growthAreas: [...]}
  Widget _buildStructuredContent({
    required Map<String, dynamic> content,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    final List<Widget> children = [];

    // traits (성격 특성)
    if (content['traits'] != null && content['traits'] is List) {
      final traits = (content['traits'] as List).cast<String>();
      if (traits.isNotEmpty) {
        children.add(_buildChipSection(
          label: '성격 특성',
          items: traits,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ));
      }
    }

    // strengths (강점)
    if (content['strengths'] != null && content['strengths'] is List) {
      final strengths = (content['strengths'] as List).cast<String>();
      if (strengths.isNotEmpty) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 16));
        children.add(_buildChipSection(
          label: '강점',
          items: strengths,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
          chipColor: const Color(0xFF4CAF50),
        ));
      }
    }

    // growthAreas (성장 영역)
    if (content['growthAreas'] != null && content['growthAreas'] is List) {
      final growthAreas = (content['growthAreas'] as List).cast<String>();
      if (growthAreas.isNotEmpty) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 16));
        children.add(_buildChipSection(
          label: '성장 영역',
          items: growthAreas,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
          chipColor: const Color(0xFFFF9800),
        ));
      }
    }

    // 기타 String 필드들
    content.forEach((key, value) {
      if (value is String &&
          value.isNotEmpty &&
          !['traits', 'strengths', 'growthAreas'].contains(key)) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 12));
        children.add(Text(
          FortuneTextCleaner.clean(value),
          style: context.bodyMedium.copyWith(
            color: textPrimary,
            height: 1.7,
          ),
        ));
      }
    });

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> items,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    Color? chipColor,
  }) {
    final color = chipColor ?? accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              item,
              style: context.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
