import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/obangseok_colors.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/theme/font_config.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../data/services/fortune_api_service.dart';
import '../../../../../../presentation/providers/auth_provider.dart';

/// 꿈해석 기반 로또 번호 생성을 위한 BottomSheet
class DreamLottoBottomSheet extends ConsumerStatefulWidget {
  final void Function(String dreamText, Map<String, dynamic> dreamResult) onDreamAnalyzed;
  final VoidCallback onGenerateNumbers;

  const DreamLottoBottomSheet({
    super.key,
    required this.onDreamAnalyzed,
    required this.onGenerateNumbers,
  });

  @override
  ConsumerState<DreamLottoBottomSheet> createState() => _DreamLottoBottomSheetState();
}

class _DreamLottoBottomSheetState extends ConsumerState<DreamLottoBottomSheet> {
  final TextEditingController _dreamController = TextEditingController();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _dreamResult;
  String? _errorMessage;

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _analyzeDream() async {
    if (_dreamController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '꿈 내용을 입력해주세요';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(userProvider).value;
      final userId = user?.id;
      if (userId == null) {
        setState(() {
          _errorMessage = '로그인이 필요합니다';
          _isAnalyzing = false;
        });
        return;
      }

      final apiService = ref.read(fortuneApiServiceProvider);
      final result = await apiService.getFortune(
        userId: userId,
        fortuneType: 'dream',
        params: {
          'dream': _dreamController.text.trim(),
          'inputType': 'text',
          'forLotto': true, // 로또용 해몽 요청
        },
      );

      if (mounted) {
        setState(() {
          _dreamResult = {
            'content': result.content,
            'dream': _dreamController.text.trim(),
            'symbols': result.additionalInfo?['symbols'] ?? [],
            'sentiment': result.additionalInfo?['sentiment'] ?? 'neutral',
            'luckyElements': result.additionalInfo?['luckyElements'] ?? {},
          };
          _isAnalyzing = false;
        });

        // 부모에게 결과 전달
        widget.onDreamAnalyzed(_dreamController.text.trim(), _dreamResult!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '꿈 해석 중 오류가 발생했습니다';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.hanjiBackgroundDark
            : ObangseokColors.hanjiBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? ObangseokColors.baekDark.withValues(alpha: 0.3)
                  : ObangseokColors.meok.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('💭', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  '꿈해석으로 로또 번호 받기',
                  style: TypographyUnified.heading3.copyWith(
                    fontFamily: FontConfig.primary,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 컨텐츠
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_dreamResult == null) ...[
                    // 꿈 입력 상태
                    Text(
                      '어젯밤 꾼 꿈을 자세히 적어주세요',
                      style: TypographyUnified.bodyMedium.copyWith(
                        color: isDark
                            ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                            : ObangseokColors.meok.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dreamController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: '예: 하늘을 나는 꿈을 꿨어요. 구름 위에서 금빛 용을 봤는데...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? ObangseokColors.baekDark.withValues(alpha: 0.4)
                              : ObangseokColors.meok.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? ObangseokColors.meok.withValues(alpha: 0.3)
                            : ObangseokColors.baek,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: TypographyUnified.bodyMedium.copyWith(
                        color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TypographyUnified.bodySmall.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    UnifiedButton.primary(
                      text: '꿈 해석하기',
                      onPressed: _isAnalyzing ? null : _analyzeDream,
                      isLoading: _isAnalyzing,
                    ),
                  ] else ...[
                    // 꿈 해석 결과 상태
                    _buildDreamResultCard(isDark),
                    const SizedBox(height: 20),
                    UnifiedButton.primary(
                      text: '🎰 이 꿈으로 로또 번호 생성',
                      onPressed: widget.onGenerateNumbers,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dreamResult = null;
                          _dreamController.clear();
                        });
                      },
                      child: Text(
                        '다른 꿈 입력하기',
                        style: TypographyUnified.bodySmall.copyWith(
                          color: isDark
                              ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                              : ObangseokColors.meok.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamResultCard(bool isDark) {
    final content = _dreamResult?['content'] ?? '';
    final symbols = _dreamResult?['symbols'] as List? ?? [];
    final sentiment = _dreamResult?['sentiment'] ?? 'neutral';

    // 감정에 따른 색상
    Color sentimentColor;
    String sentimentLabel;
    switch (sentiment) {
      case 'positive':
        sentimentColor = ObangseokColors.cheong;
        sentimentLabel = '길몽 🌟';
        break;
      case 'negative':
        sentimentColor = ObangseokColors.jeok;
        sentimentLabel = '흉몽 ⚠️';
        break;
      default:
        sentimentColor = ObangseokColors.hwang;
        sentimentLabel = '평몽 ☯️';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? ObangseokColors.meok.withValues(alpha: 0.3)
            : ObangseokColors.baek,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sentimentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 감정 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sentimentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              sentimentLabel,
              style: TypographyUnified.labelSmall.copyWith(
                color: sentimentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 해몽 내용
          Text(
            content.toString(),
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
              height: 1.6,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          if (symbols.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '꿈 속 상징',
              style: TypographyUnified.labelSmall.copyWith(
                color: isDark
                    ? ObangseokColors.baekDark.withValues(alpha: 0.6)
                    : ObangseokColors.meok.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symbols.take(5).map((symbol) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ObangseokColors.hwang.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    symbol.toString(),
                    style: TypographyUnified.bodySmall.copyWith(
                      color: ObangseokColors.hwang,
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
}
