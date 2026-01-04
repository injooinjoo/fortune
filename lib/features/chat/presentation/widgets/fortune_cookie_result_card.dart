import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/theme/obangseok_colors.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../domain/entities/fortune.dart';

/// 포춘쿠키 결과 인라인 카드 (프리미엄 버전)
///
/// 채팅 내에서 포춘쿠키 결과를 아름답게 표시합니다.
/// - 전통 한지 스타일 배경 (미색 그라데이션)
/// - 신비로운 메시지 (동양풍 따옴표 「」)
/// - 원형 점수 표시
/// - 행운 요소 2x2 그리드
/// - 행동 미션 (골드 shimmer)
/// - 공유 기능
class FortuneCookieResultCard extends ConsumerStatefulWidget {
  final Fortune fortune;

  const FortuneCookieResultCard({
    super.key,
    required this.fortune,
  });

  @override
  ConsumerState<FortuneCookieResultCard> createState() => _FortuneCookieResultCardState();
}

class _FortuneCookieResultCardState extends ConsumerState<FortuneCookieResultCard> {
  // Fortune 데이터에서 필요한 값 추출
  String get _message => widget.fortune.content;
  String get _cookieType => widget.fortune.luckyItems?['cookie_type'] as String? ?? 'luck';
  String get _emoji => widget.fortune.luckyItems?['emoji'] as String? ?? '🥠';
  String get _luckyColor => widget.fortune.luckyItems?['lucky_color'] as String? ?? '골드';
  String get _luckyColorHex => widget.fortune.luckyItems?['lucky_color_hex'] as String? ?? '#FFD700';
  String get _luckyTime => widget.fortune.luckyItems?['lucky_time'] as String? ?? '12:00 ~ 14:00';
  String get _luckyDirection => widget.fortune.luckyItems?['lucky_direction'] as String? ?? '동쪽';
  String get _luckyItem => widget.fortune.luckyItems?['lucky_item'] as String? ?? '손수건';
  String get _luckyItemColor => widget.fortune.luckyItems?['lucky_item_color'] as String? ?? '노란색';
  String get _luckyPlace => widget.fortune.luckyItems?['lucky_place'] as String? ?? '통창 카페';
  String get _actionMission => widget.fortune.luckyItems?['action_mission'] as String? ?? '';
  int get _luckyNumber => widget.fortune.luckyItems?['lucky_number'] as int? ?? 7;

  // 골드 액센트 색상 (프리미엄 디자인)
  Color get _goldenAccent {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? ObangseokColors.hwangLight : ObangseokColors.hwang;
  }

  // 실제 행운 색상 (행운 컬러 칩에 사용)
  Color get _luckyColorValue {
    try {
      final hex = _luckyColorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return ObangseokColors.hwang;
    }
  }

  String get _cookieTypeName {
    switch (_cookieType) {
      case 'love': return '사랑';
      case 'wealth': return '재물';
      case 'health': return '건강';
      case 'wisdom': return '지혜';
      case 'luck':
      default: return '행운';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // 한지 스타일 배경 그라데이션
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2520),
                ]
              : [
                  ObangseokColors.misaek,
                  ObangseokColors.misaekDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _goldenAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _goldenAccent.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 배경 파티클 (골드)
            ..._buildBackgroundDecorations(isDark),

            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 (이모지 + 타입 + 運 + 원형 점수)
                  _buildHeader(theme, isDark),
                  const SizedBox(height: 16),

                  // 메시지 (핵심) - 「」 동양풍 따옴표
                  _buildMessage(theme, isDark)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 20),

                  // 행운 요소 2x2 그리드
                  _buildLuckyElementsGrid(theme, isDark)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),

                  // 미션 섹션 (항상 표시)
                  if (_actionMission.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMissionSection(theme, isDark)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  ],

                  const SizedBox(height: 16),

                  // 공유 버튼
                  _buildShareButton(theme, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations(bool isDark) {
    final random = math.Random(42);
    final decorations = <Widget>[];

    // 반짝이는 골드 파티클
    for (int i = 0; i < 8; i++) {
      final left = random.nextDouble() * 300;
      final top = random.nextDouble() * 400;
      final size = 3.0 + random.nextDouble() * 4;
      final delay = random.nextInt(2000);

      decorations.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _goldenAccent.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _goldenAccent.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1500.ms, delay: delay.ms)
            .fadeOut(duration: 1500.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2)),
        ),
      );
    }

    return decorations;
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // 왼쪽: 이모지 + 타입 + 運 한자
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _emoji,
                  style: const TextStyle(fontSize: 28),
                )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1500.ms,
                  ),
                const SizedBox(width: 8),
                Text(
                  '$_cookieTypeName 쿠키',
                  style: context.heading4.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF2C1810),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '運',
              style: TextStyle(
                fontSize: 11,
                color: _goldenAccent.withValues(alpha: 0.6),
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),

        const Spacer(),

        // 오른쪽: 원형 점수
        _buildCircularScore(widget.fortune.score, isDark),
        const SizedBox(width: 8),
        // 좋아요 + 공유 버튼
        FortuneActionButtons(
          contentId: widget.fortune.id ?? 'cookie_${DateTime.now().millisecondsSinceEpoch}',
          contentType: 'cookie',
          shareTitle: '$_cookieTypeName 포춘쿠키',
          shareContent: _message,
          iconSize: 18,
          iconColor: _goldenAccent,
        ),
      ],
    );
  }

  Widget _buildCircularScore(int score, bool isDark) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 3,
              backgroundColor: _goldenAccent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(_goldenAccent),
            ),
          ),
          // 점수 텍스트
          Text(
            '$score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _goldenAccent,
            ),
          ),
        ],
      ),
    )
      .animate()
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: 600.ms,
        curve: Curves.elasticOut,
      );
  }

  Widget _buildMessage(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goldenAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _goldenAccent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 동양풍 여는 따옴표
          Text(
            '「',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: _goldenAccent.withValues(alpha: 0.7),
              height: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // 메시지 본문
          Text(
            _message,
            style: context.bodyLarge.copyWith(
              color: isDark ? Colors.white : const Color(0xFF2C1810),
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          // 동양풍 닫는 따옴표
          Text(
            '」',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: _goldenAccent.withValues(alpha: 0.7),
              height: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyElementsGrid(ThemeData theme, bool isDark) {
    final borderColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // 첫 번째 행: 시간 | 방위
          Row(
            children: [
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.access_time_rounded,
                  label: '시간',
                  value: _luckyTime,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: borderColor.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.explore_rounded,
                  label: '방위',
                  value: _luckyDirection,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          Divider(
            color: borderColor.withValues(alpha: 0.1),
            height: 16,
          ),
          // 두 번째 행: 컬러 | 숫자
          Row(
            children: [
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.palette_rounded,
                  label: '컬러',
                  value: _luckyColor,
                  isDark: isDark,
                  colorDot: _luckyColorValue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: borderColor.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.tag_rounded,
                  label: '숫자',
                  value: '$_luckyNumber',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          Divider(
            color: borderColor.withValues(alpha: 0.1),
            height: 16,
          ),
          // 세 번째 행: 럭키 아이템 | 행운 장소
          Row(
            children: [
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.card_giftcard_rounded,
                  label: '아이템',
                  value: '$_luckyItemColor $_luckyItem',
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: borderColor.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildLuckyGridItem(
                  icon: Icons.place_rounded,
                  label: '장소',
                  value: _luckyPlace,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyGridItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? colorDot,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: _goldenAccent,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.labelSmall.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (colorDot != null) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      value,
                      style: context.labelMedium.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.87)
                            : Colors.black.withValues(alpha: 0.87),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldenAccent.withValues(alpha: 0.12),
            _goldenAccent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _goldenAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _goldenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: _goldenAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 미션',
                style: context.labelMedium.copyWith(
                  color: _goldenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: _goldenAccent,
              )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 1200.ms)
                .fadeOut(duration: 1200.ms),
            ],
          ),
          Divider(
            color: _goldenAccent.withValues(alpha: 0.2),
            height: 16,
          ),
          Text(
            _actionMission,
            style: context.bodySmall.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .shimmer(
        duration: 4000.ms,
        color: _goldenAccent.withValues(alpha: 0.08),
      );
  }

  Widget _buildShareButton(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _shareFortune,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldenAccent.withValues(alpha: 0.3),
                  _goldenAccent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.share_rounded,
                  size: 14,
                  color: _goldenAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  '공유',
                  style: context.labelSmall.copyWith(
                    color: _goldenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _shareFortune() {
    HapticFeedback.mediumImpact();

    final shareText = '''
🥠 $_cookieTypeName 포춘쿠키

「$_message」

⏰ 행운의 시간: $_luckyTime
🧭 행운의 방위: $_luckyDirection
🎨 행운의 컬러: $_luckyColor
🎲 행운의 숫자: $_luckyNumber
🎁 럭키 아이템: $_luckyItemColor $_luckyItem
📍 행운 장소: $_luckyPlace

${_actionMission.isNotEmpty ? '💡 오늘의 미션\n$_actionMission\n\n' : ''}#포춘쿠키 #오늘의운세
''';

    Share.share(shareText);
  }
}
