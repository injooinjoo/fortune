import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import '../../../../core/utils/haptic_utils.dart';

abstract class BaseFortunePage extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String fortuneType;
  final bool requiresUserInfo;
  final bool showShareButton;
  final bool showFontSizeSelector;

  const BaseFortunePage({
    Key? key,
    required this.title,
    required this.description,
    required this.fortuneType,
    this.requiresUserInfo = true,
    this.showShareButton = true,
    this.showFontSizeSelector = true,
  }) : super(key: key);
}

abstract class BaseFortunePageState<T extends BaseFortunePage>
    extends ConsumerState<T> with TickerProviderStateMixin {
  Fortune? _fortune;
  bool _isLoading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Protected getters for subclasses
  Fortune? get fortune => _fortune;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Abstract method to be implemented by each fortune page
  Future<Fortune> generateFortune(Map<String, dynamic> params);

  // Common method to handle fortune generation - made protected for subclasses
  @protected
  Future<void> generateFortuneAction() async {
    // Check token availability first
    final tokenState = ref.read(tokenProvider);
    final requiredTokens = tokenState.getTokensForFortuneType(widget.fortuneType);
    
    // Check if user has unlimited access
    if (!tokenState.hasUnlimitedAccess) {
      // Check if user has enough tokens
      if (!tokenState.canConsumeTokens(requiredTokens)) {
        // Show insufficient token modal
        final shouldContinue = await TokenInsufficientModal.show(
          context: context,
          requiredTokens: requiredTokens,
          fortuneType: widget.fortuneType,
        );
        
        if (!shouldContinue) {
          return;
        }
        
        // Re-check after modal (user might have purchased tokens)
        final newTokenState = ref.read(tokenProvider);
        if (!newTokenState.canConsumeTokens(requiredTokens)) {
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final params = await getFortuneParams();
      if (params == null && widget.requiresUserInfo) {
        Toast.warning(context, '운세를 보려면 정보를 입력해주세요');
        setState(() => _isLoading = false);
        return;
      }

      // Consume tokens if not unlimited
      if (!tokenState.hasUnlimitedAccess) {
        final consumed = await ref.read(tokenProvider.notifier).consumeTokens(
          fortuneType: widget.fortuneType,
          amount: requiredTokens,
        );
        
        if (!consumed) {
          setState(() => _isLoading = false);
          HapticUtils.error();
          Toast.error(context, '토큰 처리 중 오류가 발생했습니다');
          return;
        }
      }

      final fortune = await generateFortune(params ?? {});
      
      setState(() {
        _fortune = fortune;
        _isLoading = false;
      });

      // Success haptic feedback
      HapticUtils.success();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      HapticUtils.error();
      Toast.error(context, '운세 생성 중 오류가 발생했습니다');
    }
  }

  // Override this method if your fortune page needs specific parameters
  Future<Map<String, dynamic>?> getFortuneParams() async {
    // Default implementation - override in subclasses
    return {};
  }

  // Common UI for input form - override if needed
  Widget buildInputForm() {
    return const SizedBox.shrink();
  }

  // Common UI for fortune result
  Widget buildFortuneResult() {
    if (_fortune == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOverallScore(),
              const SizedBox(height: 16),
              _buildScoreBreakdown(),
              const SizedBox(height: 16),
              _buildLuckyItems(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildRecommendations(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScore() {
    final score = _fortune?.overallScore ?? 0;
    final scoreColor = _getScoreColor(score);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scoreColor.withOpacity(0.2),
                  scoreColor.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: scoreColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$score점',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(score),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _fortune?.category ?? widget.fortuneType,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    final breakdown = _fortune?.scoreBreakdown ?? {};
    if (breakdown.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 점수',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...breakdown.entries.map((entry) {
            final score = entry.value as int;
            final color = _getScoreColor(score);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$score점',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLuckyItems() {
    final luckyItems = _fortune?.luckyItems ?? {};
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '행운의 아이템',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: luckyItems.entries.map((entry) {
              return GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(16),
                blur: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getLuckyItemIcon(entry.key),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final description = _fortune?.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    final fontSize = ref.watch(fontSizeProvider);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 운세',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: _getFontSize(fontSize),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _fortune?.recommendations ?? [];
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추천 사항',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    final fortuneTheme = context.fortuneTheme;
    if (score >= 80) return fortuneTheme.scoreExcellent;
    if (score >= 60) return fortuneTheme.scoreGood;
    if (score >= 40) return fortuneTheme.scoreFair;
    return fortuneTheme.scorePoor;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 운세입니다! 🎉';
    if (score >= 80) return '아주 좋은 운세입니다! ✨';
    if (score >= 70) return '좋은 운세입니다 😊';
    if (score >= 60) return '평균적인 운세입니다';
    if (score >= 50) return '조심이 필요한 시기입니다';
    if (score >= 40) return '신중히 행동하세요';
    return '어려운 시기지만 극복할 수 있습니다';
  }

  Widget _getLuckyItemIcon(String type) {
    IconData iconData;
    Color color;
    final colorScheme = Theme.of(context).colorScheme;
    final fortuneTheme = context.fortuneTheme;

    switch (type.toLowerCase()) {
      case 'color':
      case '색깔':
        iconData = Icons.palette_rounded;
        color = colorScheme.primary;
        break;
      case 'number':
      case '숫자':
        iconData = Icons.looks_one_rounded;
        color = colorScheme.secondary;
        break;
      case 'direction':
      case '방향':
        iconData = Icons.explore_rounded;
        color = fortuneTheme.scoreExcellent;
        break;
      case 'time':
      case '시간':
        iconData = Icons.access_time_rounded;
        color = fortuneTheme.scoreFair;
        break;
      case 'food':
      case '음식':
        iconData = Icons.restaurant_rounded;
        color = colorScheme.error;
        break;
      case 'person':
      case '사람':
        iconData = Icons.person_rounded;
        color = colorScheme.tertiary;
        break;
      default:
        iconData = Icons.star_rounded;
        color = colorScheme.primary;
    }

    return Icon(iconData, size: 32, color: color);
  }

  double _getFontSize(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 14;
      case FontSize.medium:
        return 16;
      case FontSize.large:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: widget.title,
        showShareButton: widget.showShareButton,
        showFontSizeSelector: widget.showFontSizeSelector,
        currentFontSize: ref.watch(fontSizeProvider),
        onFontSizeChanged: (size) {
          ref.read(fontSizeProvider.notifier).setFontSize(size);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const FortuneResultSkeleton()
                  : _error != null
                      ? _buildErrorState()
                      : _fortune != null
                          ? buildFortuneResult()
                          : _buildInitialState(),
            ),
            if (_fortune == null && !_isLoading) _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildInputForm(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: generateFortuneAction,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: GlassEffects.glassShadow(elevation: 10),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: generateFortuneAction,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            '운세 보기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}