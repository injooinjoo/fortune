import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../fortune/domain/models/yearly_encounter_result.dart';

/// 채팅용 올해의 인연 결과 카드 - 전통 스타일 인포그래픽
///
/// 디자인 요소:
/// - 베이지 배경 + 전통 구름 문양
/// - 황금 회문(回文) 패턴 원형 프레임
/// - 매화꽃 장식
/// - 2열 그리드 정보 박스
/// - 그라데이션 궁합 점수 배지
class ChatYearlyEncounterResultCard extends ConsumerStatefulWidget {
  final YearlyEncounterResult result;

  const ChatYearlyEncounterResultCard({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<ChatYearlyEncounterResultCard> createState() =>
      _ChatYearlyEncounterResultCardState();
}

class _ChatYearlyEncounterResultCardState
    extends ConsumerState<ChatYearlyEncounterResultCard> {
  // 디자인 색상 → DSColors 기반 (ChatGPT monochrome style)
  static const _beigeLight = DSColors.backgroundSecondary;
  static const _beigeDark = DSColors.background;
  static const _goldLight = DSColors.warning;
  static const _brownTitle = DSColors.textPrimary;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  /// 이미지 풀스크린 확대 보기
  void _showFullScreenImage(BuildContext context) {
    final colors = context.colors;
    DSHaptics.light();

    showDialog(
      context: context,
      barrierColor: DSColors.overlay,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SmartImage(
                    path: widget.result.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: _buildDefaultImage(),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DSColors.background.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: colors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_beigeLight, _beigeDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 배경 장식 (구름 문양)
          _buildBackgroundDecorations(),

          // 메인 콘텐츠
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 타이틀
              _buildTitle().animate().fadeIn(duration: 500.ms),

              // 2. 이미지 섹션 (황금 프레임 + 매화꽃)
              _buildImageSection()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms),

              // 3. 2열 그리드 (외모 + 첫만남 장소)
              _buildInfoGrid()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),

              // 4. 인연의 시그널 + 성격/특징 박스
              _buildSignalAndPersonalityBox()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),

              const SizedBox(height: 16),
            ],
          ),

          // 액션 버튼 (우상단)
          Positioned(
            top: 8,
            right: 8,
            child: FortuneActionButtons(
              contentId:
                  'yearly_encounter_${widget.result.targetGender}_${DateTime.now().millisecondsSinceEpoch}',
              contentType: 'yearly-encounter',
              fortuneType: 'yearly-encounter',
              shareTitle: '2026 올해의 인연',
              shareContent:
                  '${widget.result.hashtagsString}\n\n💕 첫만남: ${widget.result.encounterSpotTitle}\n${widget.result.encounterSpotStory}\n\n✨ 인연의 시그널: ${widget.result.fateSignalTitle}\n\n💝 비주얼 궁합: ${widget.result.compatibilityScore}',
              iconSize: 18,
              iconColor: _brownTitle.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 배경 장식 (구름 문양)
  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CloudPatternPainter(),
      ),
    );
  }

  /// 타이틀: "2026 향라의 인연은?"
  Widget _buildTitle() {
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        '2026 올해의 인연은?',
        textAlign: TextAlign.center,
        style: typography.headingSmall.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _brownTitle,
          letterSpacing: 1.5,
          height: 1.2,
        ),
      ),
    );
  }

  /// 이미지 섹션: 황금 회문 프레임 + 매화꽃
  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 매화꽃 장식 (왼쪽)
          Positioned(
            left: 20,
            top: 20,
            child: _buildCherryBlossomBranch(),
          ),

          // 구름 문양 장식 (오른쪽)
          Positioned(
            right: 30,
            top: 40,
            child: _buildCloudDecoration(),
          ),

          // 구름 문양 장식 (왼쪽 하단)
          Positioned(
            left: 40,
            bottom: 20,
            child: Transform.scale(
              scaleX: -1,
              child: _buildCloudDecoration(),
            ),
          ),

          // 황금 프레임 (PNG) + AI 생성 이미지
          GestureDetector(
            onTap: widget.result.imageUrl.isNotEmpty
                ? () => _showFullScreenImage(context)
                : null,
            child: SizedBox(
              width: 520,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. AI 생성 이미지 (원형, 프레임 안쪽에 맞춤)
                  ClipOval(
                    child: widget.result.imageUrl.isNotEmpty
                        ? SmartImage(
                            path: widget.result.imageUrl,
                            width: 190,
                            height: 190,
                            fit: BoxFit.cover,
                            errorWidget: _buildDefaultImage(),
                          )
                        : _buildDefaultImage(),
                  ),
                  // 2. PNG 프레임 (위에 올라감, 얼굴 원형에 맞춤)
                  IgnorePointer(
                    child: Transform.scale(
                      scale: 1.85, // 프레임만 85% 확대
                      child: Image.asset(
                        'assets/images/fortune/yearly_encounter_frame.webp',
                        width: 520,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 매화꽃 가지 장식
  Widget _buildCherryBlossomBranch() {
    return SizedBox(
      width: 80,
      height: 120,
      child: Stack(
        children: [
          // 가지
          Positioned(
            left: 35,
            top: 0,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 3,
                height: 100,
                decoration: BoxDecoration(
                  color: DSColors.accentSecondary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // 꽃들
          const Positioned(
              left: 10,
              top: 10,
              child: Text('🌸', style: TextStyle(fontSize: 24))),
          const Positioned(
              left: 35,
              top: 25,
              child: Text('🌸', style: TextStyle(fontSize: 20))),
          const Positioned(
              left: 15,
              top: 50,
              child: Text('🌸', style: TextStyle(fontSize: 22))),
          const Positioned(
              left: 40,
              top: 70,
              child: Text('🌸', style: TextStyle(fontSize: 18))),
          const Positioned(
              left: 20,
              top: 85,
              child: Text('🌸', style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  /// 구름 문양 장식
  Widget _buildCloudDecoration() {
    return Opacity(
      opacity: 0.15,
      child: CustomPaint(
        size: const Size(60, 40),
        painter: _TraditionalCloudPainter(),
      ),
    );
  }

  /// 2열 그리드: 외모 해시태그 + 첫만남 장소
  Widget _buildInfoGrid() {
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 왼쪽: 외모
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DSColors.backgroundSecondary.withValues(alpha: 0.5),
                  border: Border.all(
                      color: DSColors.textPrimary.withValues(alpha: 0.2),
                      width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '외모',
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DSColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...widget.result.appearanceHashtags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          tag,
                          style: typography.labelSmall.copyWith(
                            color: DSColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 오른쪽: 첫만남 장소
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DSColors.backgroundSecondary.withValues(alpha: 0.5),
                  border: Border.all(
                      color: DSColors.textPrimary.withValues(alpha: 0.2),
                      width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '첫만남장소와 시간',
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DSColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 짧은 제목
                    Text(
                      widget.result.encounterSpotTitle,
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _brownTitle,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    // 상세 스토리
                    Text(
                      widget.result.encounterSpotStory,
                      style: typography.labelTiny.copyWith(
                        color: DSColors.textPrimary.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 인연의 시그널 + 성격/특징 박스
  Widget _buildSignalAndPersonalityBox() {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DSColors.backgroundSecondary.withValues(alpha: 0.5),
        border: Border.all(
            color: DSColors.textPrimary.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인연의 시그널
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '인연의시그널',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              // 짧은 제목
              Text(
                widget.result.fateSignalTitle,
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _brownTitle,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              // 상세 스토리
              Text(
                widget.result.fateSignalStory,
                style: typography.labelSmall.copyWith(
                  color: DSColors.textPrimary.withValues(alpha: 0.85),
                  height: 1.6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 성격/특징
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이 사람의 성격/특징',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              // 짧은 제목
              Text(
                widget.result.personalityTitle,
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _brownTitle,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              // 상세 스토리
              Text(
                widget.result.personalityStory,
                style: typography.labelSmall.copyWith(
                  color: DSColors.textPrimary.withValues(alpha: 0.85),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: _goldLight.withValues(alpha: 0.3),
      child: const Center(
        child: Text(
          '💕',
          style: TextStyle(fontSize: 60),
        ),
      ),
    );
  }
}

/// 전통 구름 문양 페인터
class _TraditionalCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DSColors.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    // 구름 형태
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.1,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 배경 구름 패턴 페인터
class _CloudPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DSColors.warning.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 우상단 구름
    _drawCloud(canvas, Offset(size.width - 60, 80), 50, paint);

    // 좌하단 구름
    _drawCloud(canvas, Offset(50, size.height - 100), 40, paint);
  }

  void _drawCloud(Canvas canvas, Offset center, double scale, Paint paint) {
    final path = Path();

    path.moveTo(center.dx - scale * 0.5, center.dy);
    path.quadraticBezierTo(
      center.dx - scale * 0.3,
      center.dy - scale * 0.4,
      center.dx,
      center.dy - scale * 0.2,
    );
    path.quadraticBezierTo(
      center.dx + scale * 0.2,
      center.dy - scale * 0.5,
      center.dx + scale * 0.4,
      center.dy - scale * 0.1,
    );
    path.quadraticBezierTo(
      center.dx + scale * 0.6,
      center.dy - scale * 0.3,
      center.dx + scale * 0.5,
      center.dy + scale * 0.1,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
