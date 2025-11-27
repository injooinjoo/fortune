import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../fortune/domain/models/conditions/dream_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/blurred_fortune_content.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';

/// 꿈 해몽 페이지 (UnifiedFortuneService 버전)
///
/// **개선 사항**:
/// - ✅ UnifiedFortuneService 사용 (72% API 비용 절감)
/// - ✅ BlurredFortuneContent 사용 (자동 블러/광고 처리)
/// - ✅ FortuneResult 모델 사용 (일관성)
class DreamInterpretationPage extends ConsumerStatefulWidget {
  const DreamInterpretationPage({super.key});

  @override
  ConsumerState<DreamInterpretationPage> createState() =>
      _DreamInterpretationPageState();
}

class _DreamInterpretationPageState
    extends ConsumerState<DreamInterpretationPage> {
  // ==================== State ====================

  final _nameController = TextEditingController();
  final _dreamController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _selectedEmotion;

  // 운세 결과 관련 상태
  FortuneResult? _fortuneResult;
  bool _isLoading = false;
  bool _showResult = false;

  static const List<Map<String, dynamic>> _emotions = [
    {'label': '😊 기분 좋은', 'value': 'happy', 'color': Color(0xFFFBBF24)},
    {'label': '😟 불안한', 'value': 'anxious', 'color': Color(0xFFF59E0B)},
    {'label': '😱 무서운', 'value': 'scary', 'color': Color(0xFFEF4444)},
    {'label': '😢 슬픈', 'value': 'sad', 'color': Color(0xFF3B82F6)},
    {'label': '🤔 이상한', 'value': 'weird', 'color': Color(0xFF8B5CF6)},
    {'label': '😌 평온한', 'value': 'peaceful', 'color': Color(0xFF10B981)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _showResult
            ? null // 결과 화면에서는 백버튼 숨김
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        automaticallyImplyLeading: !_showResult, // 결과 화면에서는 자동 백버튼도 숨김
        title: Text(
          '꿈 해몽',
          style: TypographyUnified.heading4.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: _showResult
            ? [
                // 결과 화면에서는 오른쪽에 X 버튼
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _showResult && _fortuneResult != null
                      ? _buildResultView(_fortuneResult!)
                      : _buildInputForm(),
                ),
              ],
            ),

            // 버튼
            if (!_showResult && _dreamController.text.isNotEmpty)
              UnifiedButton.floating(
                text: '🔮 꿈 해석하기',
                onPressed: _isLoading ? null : _handleSubmit,
                isLoading: _isLoading,
              ),

            if (_showResult && _fortuneResult != null)
              UnifiedButton.floating(
                text: '다시 해석하기',
                onPressed: _resetForm,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== Input Form ====================

  Widget _buildInputForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 입력
          Text(
            '이름',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              filled: true,
              fillColor: isDark
                  ? TossDesignSystem.surfaceBackgroundDark
                  : TossDesignSystem.surfaceBackgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 생년월일 입력
          NumericDateInput(
            label: '생년월일',
            selectedDate: _selectedBirthDate,
            onDateChanged: (date) => setState(() => _selectedBirthDate = date),
            minDate: DateTime(1950),
            maxDate: DateTime.now(),
            showAge: true,
          ),

          const SizedBox(height: 24),

          // 꿈 감정 선택
          Text(
            '꿈의 느낌',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotions.map((emotion) {
              final isSelected = _selectedEmotion == emotion['value'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedEmotion = emotion['value'] as String;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (emotion['color'] as Color).withValues(alpha: 0.2)
                        : (isDark
                            ? TossDesignSystem.surfaceBackgroundDark
                            : TossDesignSystem.surfaceBackgroundLight),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: emotion['color'] as Color, width: 2)
                        : null,
                  ),
                  child: Text(
                    emotion['label'] as String,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isSelected
                          ? (emotion['color'] as Color)
                          : (isDark
                              ? TossDesignSystem.textPrimaryDark
                              : TossDesignSystem.textPrimaryLight),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 꿈 내용 입력
          Text(
            '꿈 내용',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dreamController,
            maxLines: 8,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: '꾼 꿈의 내용을 자세히 적어주세요.\n예: 하늘을 날아다니는 꿈을 꿨어요.',
              filled: true,
              fillColor: isDark
                  ? TossDesignSystem.surfaceBackgroundDark
                  : TossDesignSystem.surfaceBackgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ==================== Result View ====================

  Widget _buildResultView(FortuneResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 종합 운세 카드
          _buildOverallCard(result),
          const SizedBox(height: 16),

          // 꿈 상징 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildSymbolsCard(result),
          ),
          const SizedBox(height: 16),

          // 해석 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildInterpretationCard(result),
          ),
          const SizedBox(height: 16),

          // 조언 (블러 대상)
          BlurredFortuneContent(
            fortuneResult: result,
            child: _buildAdviceCard(result),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOverallCard(FortuneResult result) {
    final score = result.score ?? 75;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${result.data['dreamType'] ?? '길몽'} 📖',
            style: TypographyUnified.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '행운 점수',
            style: TypographyUnified.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: TypographyUnified.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolsCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbols = (result.data['relatedSymbols'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔮 주요 상징',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symbols.map((symbol) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  symbol,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final interpretation = FortuneTextCleaner.clean(result.data['interpretation'] as String? ?? '해석 정보가 없습니다.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 꿈 해석',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            interpretation,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(FortuneResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advice = FortuneTextCleaner.clean(result.data['todayGuidance'] as String? ?? '조언 정보가 없습니다.');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossDesignSystem.surfaceBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 조언',
            style: TypographyUnified.heading4.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            advice,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Actions ====================

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _selectedBirthDate == null ||
        _dreamController.text.isEmpty) {
      Toast.show(
        context,
        message: '모든 정보를 입력해주세요',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      // Conditions 생성
      final conditions = DreamFortuneConditions(
        dreamContent: _dreamController.text,
        dreamDate: DateTime.now(),
        dreamEmotion: _selectedEmotion,
      );

      // UnifiedFortuneService 호출
      final supabase = Supabase.instance.client;
      final fortuneService = UnifiedFortuneService(supabase);
      var result = await fortuneService.getFortune(
        fortuneType: 'dream',
        dataSource: FortuneDataSource.api,
        inputConditions: {
          'name': _nameController.text,
          'birth_date': _selectedBirthDate!.toIso8601String(),
          'dream_content': _dreamController.text,
          'dream_emotion': _selectedEmotion,
        },
        conditions: conditions,
        isPremium: isPremium,
      );

      // 일반 사용자는 블러 적용
      if (!isPremium) {
        result = result.copyWith(
          isBlurred: true,
          blurredSections: ['relatedSymbols', 'interpretation', 'todayGuidance'],
        );
      }

      if (mounted) {
        setState(() {
          _fortuneResult = result;
          _showResult = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('[DreamInterpretationPage] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Toast.show(
          context,
          message: '꿈 해석에 실패했습니다',
          type: ToastType.error,
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _showResult = false;
      _fortuneResult = null;
      _nameController.clear();
      _dreamController.clear();
      _selectedBirthDate = null;
      _selectedEmotion = null;
    });
  }
}
