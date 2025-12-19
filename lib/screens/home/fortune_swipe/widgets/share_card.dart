import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/typography_unified.dart';

/// 🎁 공유 카드 - Traditional 한지 스타일 + 이미지 공유
class ShareCard extends StatefulWidget {
  final int score;
  final String message;
  final bool isDark;

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
    required this.isDark,
    this.categoryScores,
    this.luckyItems,
    this.fiveElements,
    this.userName,
    this.date,
  });

  @override
  State<ShareCard> createState() => _ShareCardState();
}

class _ShareCardState extends State<ShareCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  // Traditional 버튼 색상
  static const _traditionalBrown = Color(0xFF8D6E63);

  Future<void> _captureAndShare() async {
    if (_isCapturing) return;
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
🔮 오늘의 운세

📊 총운 점수: ${widget.score}점
💬 ${widget.message}

오늘도 좋은 하루 되세요! ✨

#오늘의운세 #일일운세 #행운
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
        Text(
          '오늘의 운세 공유하기',
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '친구들과 함께 운세를 나눠보세요',
          style: context.bodySmall.copyWith(
            color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

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
        ).animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

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
                : const Text('📤', style: TextStyle(fontSize: 18)),
            label: Text(
              _isCapturing ? '이미지 생성 중...' : '이미지로 공유하기',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
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
        ).animate()
          .fadeIn(duration: 500.ms, delay: 200.ms)
          .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms),
      ],
    );
  }
}

/// Traditional 한지 스타일 공유 카드 콘텐츠
class _TraditionalShareCardContent extends StatelessWidget {
  final int score;
  final String message;
  final Map<String, int>? categoryScores;
  final Map<String, String>? luckyItems;
  final Map<String, int>? fiveElements;
  final String? userName;
  final DateTime date;

  // Traditional 색상 팔레트
  static const _hanjiBeige = Color(0xFFFFF8E1);
  static const _traditionalBrown = Color(0xFF8D6E63);
  static const _lightBrown = Color(0xFFBCAAA4);
  static const _darkBrown = Color(0xFF5D4037);
  static const _sealRed = Color(0xFFB71C1C);

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
          _buildHeader(),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 날짜 & 사용자
                _buildDateUserRow(),
                const SizedBox(height: 16),

                // 福 인장 스타일 점수
                _buildSealScore(),
                const SizedBox(height: 16),

                // 카테고리 점수
                if (categoryScores != null && categoryScores!.isNotEmpty) ...[
                  _buildCategoryScores(),
                  const SizedBox(height: 16),
                ],

                // 럭키 아이템
                if (luckyItems != null && luckyItems!.isNotEmpty) ...[
                  _buildLuckyItems(),
                  const SizedBox(height: 16),
                ],

                // 오행 분석
                if (fiveElements != null && fiveElements!.isNotEmpty) ...[
                  _buildFiveElements(),
                  const SizedBox(height: 16),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: _traditionalBrown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: const Center(
        child: Text(
          '⊹ 오늘의 운세 ⊹',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDateUserRow() {
    final dateStr = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final displayName = userName != null && userName!.isNotEmpty ? '$userName님의 운세' : '오늘의 운세';

    return Text(
      '$dateStr  $displayName',
      style: const TextStyle(
        color: _darkBrown,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSealScore() {
    return Column(
      children: [
        // 福 인장 스타일
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: _sealRed.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: _sealRed.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '福',
                style: TextStyle(
                  color: _sealRed,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ZenSerif',
                ),
              ),
              Text(
                '$score점',
                style: const TextStyle(
                  color: _sealRed,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 사자성어/메시지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _lightBrown.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _lightBrown.withValues(alpha: 0.4)),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: _darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'ZenSerif',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryScores() {
    final categories = {
      'love': '♥ 연애',
      'money': '💰 금전',
      'work': '💼 직장',
      'study': '📚 학업',
      'health': '❤️ 건강',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: categories.entries.map((entry) {
          final scoreVal = categoryScores?[entry.key] ?? 70;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _hanjiBeige,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _lightBrown.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${entry.value} $scoreVal',
              style: const TextStyle(
                color: _darkBrown,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLuckyItems() {
    // 4개만 표시 (시간, 색상, 숫자, 방향)
    final displayItems = {
      '🕐': luckyItems?['시간'] ?? luckyItems?['time'] ?? '오전 10시',
      '🎨': luckyItems?['색상'] ?? luckyItems?['color'] ?? '파란색',
      '🔢': luckyItems?['숫자'] ?? luckyItems?['number'] ?? '7',
      '🧭': luckyItems?['방향'] ?? luckyItems?['direction'] ?? '동쪽',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayItems.entries.map((entry) {
          return Column(
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                entry.value,
                style: const TextStyle(
                  color: _darkBrown,
                  fontSize: 11,
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

    final elementColors = {
      '木': const Color(0xFF2E7D32),
      '火': const Color(0xFFD32F2F),
      '土': const Color(0xFFFF8F00),
      '金': const Color(0xFF757575),
      '水': const Color(0xFF1976D2),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ZenSerif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: _lightBrown.withValues(alpha: 0.3),
                      color: elementColors[entry.key],
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: _darkBrown,
                      fontSize: 9,
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
            Container(width: 30, height: 1, color: _lightBrown),
            const SizedBox(width: 12),
            const Text(
              '福',
              style: TextStyle(
                color: _sealRed,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'ZenSerif',
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 30, height: 1, color: _lightBrown),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Fortune AI · 행운이 가득하길',
          style: TextStyle(
            color: _lightBrown,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
