import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/services/fortune_haptic_service.dart';

/// 🎁 공유 카드 - Traditional 한지 스타일 + 이미지 공유
class ShareCard extends ConsumerStatefulWidget {
  final int score;
  final String message;

  // 풀 버전 데이터
  final Map<String, int>? categoryScores;
  final Map<String, String>? luckyItems;
  final Map<String, int>? fiveElements;
  final String? userName;
  final DateTime? date;

  const ShareCard({
    super.key,
    required this.score,
    required this.message,
    this.categoryScores,
    this.luckyItems,
    this.fiveElements,
    this.userName,
    this.date,
  });

  @override
  ConsumerState<ShareCard> createState() => _ShareCardState();
}

class _ShareCardState extends ConsumerState<ShareCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  // 고유 색상: Traditional 한지 공유카드 브랜드 색상
  static const _traditionalBrown = Color(0xFF8D6E63); // 고유 색상: 전통 갈색

  Future<void> _captureAndShare() async {
    if (_isCapturing) return;

    // 공유 액션 햅틱 피드백
    ref.read(fortuneHapticServiceProvider).shareAction();

    setState(() => _isCapturing = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('이미지 캡처 실패');
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/fortune_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _getShareText(),
        subject: '오늘의 운세',
      );
    } catch (e) {
      _shareTextFallback();
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  String _getShareText() {
    return '''
✨ 오늘의 운세

📊 오늘 점수: ${widget.score}점
💬 ${widget.message}

오늘도 좋은 하루 되세요! ✨

#오늘의메시지 #데일리인사이트 #행운
''';
  }

  void _shareTextFallback() {
    Share.share(_getShareText(), subject: '오늘의 운세');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (제목 + 공유 버튼)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 운세 공유하기',
                    style: context.heading3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    '친구들과 함께 나눠보세요',
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // U05: 오른쪽 상단 공유 버튼
            IconButton(
              onPressed: _isCapturing ? null : _captureAndShare,
              icon: _isCapturing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _traditionalBrown,
                      ),
                    )
                  : const Icon(
                      Icons.share_rounded,
                      color: _traditionalBrown,
                      size: 24,
                    ),
              style: IconButton.styleFrom(
                backgroundColor: _traditionalBrown.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: DSSpacing.md),

        // 캡처 대상 영역
        Screenshot(
          controller: _screenshotController,
          child: _TraditionalShareCardContent(
            score: widget.score,
            message: widget.message,
            categoryScores: widget.categoryScores,
            luckyItems: widget.luckyItems,
            fiveElements: widget.fiveElements,
            userName: widget.userName,
            date: widget.date ?? DateTime.now(),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
            begin: const Offset(0.95, 0.95),
            duration: 500.ms,
            curve: Curves.easeOut),

        const SizedBox(height: DSSpacing.md),

        // 이미지로 공유하기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCapturing ? null : _captureAndShare,
            icon: _isCapturing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('📤', style: TextStyle(fontSize: 18)), // 예외: 이모지
            label: Text(
              _isCapturing ? '이미지 생성 중...' : '이미지로 공유하기',
              style: context.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _traditionalBrown,
              disabledBackgroundColor: _traditionalBrown.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 200.ms)
            .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms),
      ],
    );
  }
}

/// Traditional 한지 스타일 공유 카드 콘텐츠
/// 스크린샷 캡처용 - 고정 색상 (테마 비의존)
class _TraditionalShareCardContent extends StatelessWidget {
  final int score;
  final String message;
  final Map<String, int>? categoryScores;
  final Map<String, String>? luckyItems;
  final Map<String, int>? fiveElements;
  final String? userName;
  final DateTime date;

  // 고유 색상: Traditional 한지 공유카드 팔레트 (스크린샷 캡처용 고정 색상)
  static const _hanjiBeige = Color(0xFFFFF8E1); // 고유 색상: 한지 크림
  static const _traditionalBrown = Color(0xFF8D6E63); // 고유 색상: 전통 갈색
  static const _lightBrown = Color(0xFFBCAAA4); // 고유 색상: 밝은 갈색
  static const _darkBrown = Color(0xFF5D4037); // 고유 색상: 진한 갈색
  static const _sealRed = Color(0xFFB71C1C); // 고유 색상: 인장 적색

  const _TraditionalShareCardContent({
    required this.score,
    required this.message,
    this.categoryScores,
    this.luckyItems,
    this.fiveElements,
    this.userName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _hanjiBeige,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _traditionalBrown, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          _buildHeader(context),

          // 콘텐츠 (U06: 컴팩트한 패딩, 하단 여유 추가)
          Padding(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 16),
            child: Column(
              children: [
                // 날짜 & 사용자
                _buildDateUserRow(context),
                const SizedBox(height: 12),

                // 福 인장 스타일 점수
                _buildSealScore(context),
                const SizedBox(height: 12),

                // 카테고리 점수
                if (categoryScores != null && categoryScores!.isNotEmpty) ...[
                  _buildCategoryScores(context),
                  const SizedBox(height: 10),
                ],

                // 럭키 아이템
                if (luckyItems != null && luckyItems!.isNotEmpty) ...[
                  _buildLuckyItems(),
                  const SizedBox(height: 10),
                ],

                // 오행 분석
                if (fiveElements != null && fiveElements!.isNotEmpty) ...[
                  _buildFiveElements(),
                  const SizedBox(height: 10),
                ],

                // 푸터
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: _traditionalBrown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: Center(
        child: Text(
          '⊹ 오늘의 운세 ⊹',
          style: context.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDateUserRow(BuildContext context) {
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final displayName = userName != null && userName!.isNotEmpty
        ? '$userName님의 인사이트'
        : '오늘의 운세';

    return Text(
      '$dateStr  $displayName',
      style: context.labelSmall.copyWith(
        color: _darkBrown,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSealScore(BuildContext context) {
    return Column(
      children: [
        // 福 인장 스타일 (U06: 컴팩트하게 조정)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _sealRed.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border:
                Border.all(color: _sealRed.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '福',
                style: TextStyle(
                  color: _sealRed,
                  fontSize: 24, // 예외: 전통 인장 한자 디자인
                  fontWeight: FontWeight.w700,
                  fontFamily: FontConfig.primary,
                ),
              ),
              Text(
                '$score점',
                style: const TextStyle(
                  color: _sealRed,
                  fontSize: 18, // 예외: 인장 점수 디자인
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        // 사자성어/메시지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _lightBrown.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _lightBrown.withValues(alpha: 0.4)),
          ),
          child: Text(
            message,
            style: context.labelSmall.copyWith(
              color: _darkBrown,
              fontWeight: FontWeight.w600,
              fontFamily: FontConfig.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryScores(BuildContext context) {
    final categories = {
      'love': '♥ 연애',
      'money': '💰 금전',
      'work': '💼 직장',
      'study': '📚 학업',
      'health': '❤️ 건강',
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: categories.entries.map((entry) {
          final scoreVal = categoryScores?[entry.key] ?? 70;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _hanjiBeige,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _lightBrown.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${entry.value} $scoreVal',
              style: context.labelTiny.copyWith(
                color: _darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// U07: 시간 포맷 변경 ("저녁6시에서8시" → "저녁6~8시")
  String _formatTimeRange(String time) {
    // "저녁6시에서8시" 또는 "오전10시에서12시" 패턴을 "저녁6~8시"로 변환
    final regex = RegExp(r'^(.+?)(\d+)시에서(\d+)시$');
    final match = regex.firstMatch(time);
    if (match != null) {
      final prefix = match.group(1) ?? ''; // 저녁, 오전, 오후 등
      final startHour = match.group(2) ?? '';
      final endHour = match.group(3) ?? '';
      return '$prefix$startHour~$endHour시';
    }
    // 매칭되지 않으면 원본 반환
    return time;
  }

  Widget _buildLuckyItems() {
    // 4개만 표시 (시간, 색상, 숫자, 방향)
    final rawTime = luckyItems?['시간'] ?? luckyItems?['time'] ?? '오전 10시';
    final displayItems = {
      '🕐': _formatTimeRange(rawTime),
      '🎨': luckyItems?['색상'] ?? luckyItems?['color'] ?? '파란색',
      '🔢': luckyItems?['숫자'] ?? luckyItems?['number'] ?? '7',
      '🧭': luckyItems?['방향'] ?? luckyItems?['direction'] ?? '동쪽',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayItems.entries.map((entry) {
          return Column(
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 16)), // 예외: 이모지
              const SizedBox(height: 2),
              Text(
                entry.value,
                style: const TextStyle(
                  color: _darkBrown,
                  fontSize: 10, // 예외: 공유 카드 초소형 텍스트
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFiveElements() {
    final elements = {
      '木': fiveElements?['wood'] ?? fiveElements?['목(木)'] ?? 20,
      '火': fiveElements?['fire'] ?? fiveElements?['화(火)'] ?? 20,
      '土': fiveElements?['earth'] ?? fiveElements?['토(土)'] ?? 20,
      '金': fiveElements?['metal'] ?? fiveElements?['금(金)'] ?? 20,
      '水': fiveElements?['water'] ?? fiveElements?['수(水)'] ?? 20,
    };

    // 오방색 기반 오행 색상 (공유 카드 전용 - 스크린샷 캡처용 고정 색상)
    final elementColors = {
      '木': const Color(0xFF2E7D32), // 오방색: 목
      '火': const Color(0xFFD32F2F), // 오방색: 화
      '土': const Color(0xFFFF8F00), // 오방색: 토
      '金': const Color(0xFF757575), // 오방색: 금
      '水': const Color(0xFF1976D2), // 오방색: 수
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: elements.entries.map((entry) {
          final percentage = entry.value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: elementColors[entry.key],
                      fontSize: 13, // 예외: 오행 한자 디자인
                      fontWeight: FontWeight.w700,
                      fontFamily: FontConfig.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: _lightBrown.withValues(alpha: 0.3),
                      color: elementColors[entry.key],
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: _darkBrown,
                      fontSize: 8, // 예외: 공유 카드 초소형 퍼센트
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 24, height: 1, color: _lightBrown),
            const SizedBox(width: 10),
            const Text(
              '福',
              style: TextStyle(
                color: _sealRed,
                fontSize: 14, // 예외: 전통 福 한자 디자인
                fontWeight: FontWeight.w700,
                fontFamily: FontConfig.primary,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 24, height: 1, color: _lightBrown),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Face AI · 행운이 가득하길',
          style: TextStyle(
            color: _lightBrown,
            fontSize: 10, // 예외: 공유 카드 푸터
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
