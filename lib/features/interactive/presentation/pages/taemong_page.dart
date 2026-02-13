import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../../../data/services/token_api_service.dart';
import '../../../../core/design_system/design_system.dart';

class TaemongPage extends ConsumerStatefulWidget {
  const TaemongPage({super.key});

  @override
  ConsumerState<TaemongPage> createState() => _TaemongPageState();
}

class _TaemongPageState extends ConsumerState<TaemongPage> {
  final TextEditingController _dreamController = TextEditingController();
  final List<String> _selectedKeywords = [];
  bool _isAnalyzing = false;
  String? _analysisResult;
  
  // 태몽 분석에 필요한 토큰 수
  static const int _requiredTokens = 3;
  
  // 태몽 키워드 카테고리
  final Map<String, List<String>> _keywordCategories = {
    '동물': ['용', '호랑이', '뱀', '거북이', '학', '봉황', '사자', '독수리', '물고기', '돼지'],
    '자연': ['해', '달', '별', '구름', '무지개', '산', '바다', '강', '나무', '꽃'],
    '보물': ['금', '은', '보석', '진주', '옥', '거울', '왕관', '반지', '목걸이', '팔찌'],
    '과일/음식': ['복숭아', '사과', '포도', '수박', '밤', '대추', '감', '쌀', '떡', '술'],
    '기타': ['불', '빛', '신선', '부처', '예수', '천사', '아기', '임금', '장군', '선비']};

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '태몽 해석'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInstructions(),
                    const SizedBox(height: DSSpacing.lg),
                    _buildDreamInput(),
                    const SizedBox(height: DSSpacing.lg),
                    _buildKeywordSelection(),
                    const SizedBox(height: DSSpacing.lg),
                    _buildAnalyzeButton(),
                    if (_analysisResult != null) ...[
                      const SizedBox(height: 32),
                      _buildResultSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return GlassContainer(
      child: Column(
        children: [
          const Icon(
            Icons.nights_stay,
            size: 48,
            color: DSColors.accentDark,
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '태몽의 의미를 해석해드립니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '임신 중 꾼 특별한 꿈을 입력하면\n'
            '아기의 미래와 성향을 예측해드립니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DSColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DSColors.accentDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.toll,
                  size: 16,
                  color: DSColors.accentDark,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '$_requiredTokens 토큰 필요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DSColors.accentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildDreamInput() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '태몽 내용을 입력해주세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dreamController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '꿈에서 본 내용을 자세히 적어주세요...',
              hintStyle: TextStyle(color: DSColors.textSecondaryDark.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DSColors.borderDark)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DSColors.borderDark)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DSColors.accentDark, width: 2)),
              filled: true,
              fillColor: DSColors.surfaceDark),
            style: Theme.of(context).textTheme.bodyLarge)])).animate()
      .fadeIn(duration: 600.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildKeywordSelection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '꿈에 나온 상징 선택 (선택사항)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '꿈에 나온 주요 상징을 선택하면 더 정확한 해석이 가능합니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DSColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          ..._keywordCategories.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DSColors.accentDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((keyword) => _buildKeywordChip(keyword)).toList(),
              ),
              const SizedBox(height: DSSpacing.md),
            ],
          ),
        ),
      ],
    ),
  ).animate()
      .fadeIn(duration: 600.ms, delay: 200.ms)
      .slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildKeywordChip(String keyword) {
    final isSelected = _selectedKeywords.contains(keyword);
    
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        setState(() {
          if (isSelected) {
            _selectedKeywords.remove(keyword);
          } else {
            _selectedKeywords.add(keyword);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DSColors.accentDark : DSColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? DSColors.accentDark : DSColors.borderDark,
          ),
        ),
        child: Text(
          keyword,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : DSColors.textPrimaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final canAnalyze = _dreamController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAnalyze && !_isAnalyzing ? _analyzeDream : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DSColors.accentDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isAnalyzing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                '태몽 해석하기',
                style: context.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildResultSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: DSColors.accentDark,
                size: 24,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '태몽 해석 결과',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            _analysisResult!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetAnalysis,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: DSColors.accentDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('다시 해석하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('결과 공유'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0.0);
  }

  Future<void> _analyzeDream() async {
    // 토큰 확인
    final tokenBalance = ref.read(tokenBalanceProvider);
    if (tokenBalance?.remainingTokens != null &&
        tokenBalance!.remainingTokens < _requiredTokens &&
        !tokenBalance.hasUnlimitedAccess) {
      _showInsufficientTokensModal();
      return;
    }

    setState(() => _isAnalyzing = true);
    HapticUtils.mediumImpact();

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 2));
      
      // 토큰 차감
      final userId = ref.read(userProvider).value?.id;
      if (userId != null) {
        await ref.read(tokenApiServiceProvider).consumeTokens(
          userId: userId,
          fortuneType: 'taemong',
          amount: _requiredTokens);
      }

      // 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);
      
      setState(() {
        _analysisResult = '''
【태몽 해석】

당신이 꾼 태몽은 매우 길한 꿈으로 해석됩니다.

${_selectedKeywords.isNotEmpty ? '''
【상징 해석】
${_selectedKeywords.map((keyword) => '• $keyword: ${_getKeywordInterpretation(keyword)}').join('\n')}
''' : ''}

【아기의 성향】
이 태몽으로 보아 아기는 총명하고 리더십이 강한 아이로 성장할 것으로 보입니다. 
특히 예술적 감성과 논리적 사고를 겸비한 균형 잡힌 인재가 될 가능성이 높습니다.

【미래 전망】
• 학업: 뛰어난 집중력과 이해력으로 학업 성취도가 높을 것입니다.
• 대인관계: 친화력이 좋아 많은 사람들에게 사랑받을 것입니다.
• 진로: 창의성이 요구되는 분야에서 두각을 나타낼 것입니다.

【부모님께 드리는 조언】
아이의 창의성과 독립성을 존중해주시고, 다양한 경험을 할 수 있도록 기회를 주세요.
특히 예술 활동이나 독서를 통해 상상력을 키워주시면 좋습니다.

【행운의 숫자】 7
【행운의 색상】 하늘색
【수호 동물】 백호
''';
        _isAnalyzing = false;
      });
      
      HapticUtils.success();
    } catch (e) {
      Logger.error('태몽 해석 실패', e);
      setState(() => _isAnalyzing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('해석에 실패했습니다. 다시 시도해주세요.')));
      }
    }
  }

  String _getKeywordInterpretation(String keyword) {
    final interpretations = {
      '용': '권력과 성공을 상징하며, 큰 인물이 될 징조입니다',
      '호랑이': '용맹과 지혜를 나타내며, 강인한 성격의 소유자가 될 것입니다',
      '뱀': '지혜와 재물을 의미하며, 현명한 판단력을 가질 것입니다',
      '해': '밝은 미래와 명예를 상징합니다',
      '달': '온화하고 포용력 있는 성품을 나타냅니다',
      '복숭아': '장수와 건강을 의미합니다',
      '금': '부귀영화를 누릴 징조입니다',
      // 더 많은 해석 추가 가능
    };
    
    return interpretations[keyword] ?? '길한 의미를 담고 있습니다';
  }

  void _resetAnalysis() {
    HapticUtils.lightImpact();
    setState(() {
      _dreamController.clear();
      _selectedKeywords.clear();
      _analysisResult = null;
    });
  }

  void _shareResult() async {
    HapticUtils.lightImpact();
    if (_analysisResult == null) return;

    try {
      await Share.share(
        '🌙 태몽 분석 결과\n\n$_analysisResult\n\n앱에서 더 자세히 확인해보세요!',
        subject: '태몽 분석 결과 공유',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유에 실패했습니다')));
      }
    }
  }

  void _showInsufficientTokensModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => const TokenInsufficientModal(
        requiredTokens: _requiredTokens,
        fortuneType: 'taemong',
      ),
    );
  }
}