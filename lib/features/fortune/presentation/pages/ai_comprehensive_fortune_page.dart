import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/utils/dark_mode_helper.dart';
import '../../../../services/ad_service.dart';

class AiComprehensiveFortunePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const AiComprehensiveFortunePage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<AiComprehensiveFortunePage> createState() => _AiComprehensiveFortunePageState();
}

class _AiComprehensiveFortunePageState extends ConsumerState<AiComprehensiveFortunePage> 
    with TickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _currentStage = '';
  Fortune? _generatedFortune;
  String? _error;
  late AnimationController _animationController;
  late AnimationController _pulseController;

  final List<String> _analysisStages = [
    '개인 정보 분석 중...',
    '운명의 패턴 해석 중...',
    '미래 가능성 예측 중...',
    '종합 운세 생성 중...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this)..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this)..repeat(reverse: true);
    
    // Auto-start analysis if requested
    if (widget.initialParams?['autoStart'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnalysis();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });
    
    HapticUtils.lightImpact();

    // Simulate multi-stage analysis
    for (int i = 0; i < _analysisStages.length; i++) {
      setState(() {
        _currentStage = _analysisStages[i];
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      HapticUtils.lightImpact();
    }

    try {
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'ai-comprehensive',
        userId: ref.read(userProvider).value?.id ?? 'anonymous',
        params: widget.initialParams ?? {}
      );
      
      setState(() {
        _generatedFortune = fortune;
        _isAnalyzing = false;
      });
      
      HapticUtils.mediumImpact();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
      HapticUtils.heavyImpact();
    }
  }

  void _reset() {
    setState(() {
      _isAnalyzing = false;
      _currentStage = '';
      _generatedFortune = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: DarkModeHelper.getColor(
          context: context,
          light: TossDesignSystem.white.withValues(alpha: 0.0),
          dark: TossDesignSystem.grayDark900.withValues(alpha: 0.0),
        ),
        elevation: 0,
        title: Text(
          'AI 종합 운세 분석',
          style: TextStyle(
            color: DarkModeHelper.getColor(
              context: context,
              light: TossDesignSystem.gray900,
              dark: TossDesignSystem.white,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha:0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildError();
    }
    
    if (_generatedFortune != null) {
      return _buildResult();
    }
    
    if (_isAnalyzing) {
      return _buildAnalyzing();
    }
    
    return _buildInitial();
  }

  Widget _buildInitial() {
    final theme = Theme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 120,
                color: theme.colorScheme.primary,
              ).animate()
                .fadeIn(duration: 600.ms)
                .scaleXY(delay: 300.ms),
              const SizedBox(height: 16),
              Text(
                'AI 종합 운세 분석',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                '인공지능이 당신의 모든 정보를 종합하여\n가장 정확한 운세를 제공합니다',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(delay: 600.ms),
              const SizedBox(height: 24),

              // 하단 버튼 공간 확보
              const BottomButtonSpacing(),
            ],
          ),
        ),

        // Floating 버튼
        FloatingBottomButton(
          text: 'AI 분석 시작',
          onPressed: () async {
            await AdService.instance.showInterstitialAdWithCallback(
              onAdCompleted: () async {
                _startAnalysis();
              },
              onAdFailed: () async {
                _startAnalysis();
              },
            );
          },
          style: TossButtonStyle.primary,
          size: TossButtonSize.large,
          icon: Icon(Icons.auto_awesome),
        ),
      ],
    );
  }

  Widget _buildAnalyzing() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 84 * 1.56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha:0.3),
                        theme.colorScheme.primary.withValues(alpha:0.1),
                      ],
                    ),
                  ),
                ).animate(controller: _pulseController)
                  .scaleXY(begin: 0.9, end: 1.1),
                RotationTransition(
                  turns: _animationController,
                  child: Icon(
                    Icons.psychology,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _currentStage,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn()
              .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              backgroundColor: theme.colorScheme.primary.withValues(alpha:0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final theme = Theme.of(context);
    final score = _generatedFortune?.overallScore ?? 0;
    final scoreColor = _getScoreColor(score);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score Card
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 84 * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scoreColor.withValues(alpha:0.2),
                        scoreColor.withValues(alpha:0.05),
                      ],
                    ),
                    border: Border.all(
                      color: scoreColor.withValues(alpha:0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Fortune cached',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreMessage(score),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate()
            .fadeIn()
            .scaleXY(begin: 0.8, end: 1.0),
          
          const SizedBox(height: 8),
          
          // Description
          if (_generatedFortune?.description != null) ...[
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI 종합 분석',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedFortune!.description!,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
          ],
          
          const SizedBox(height: 8),
          
          // Lucky Items
          if (_generatedFortune?.luckyItems != null) ...[
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: DarkModeHelper.getColor(
                          context: context,
                          light: TossDesignSystem.warningOrange,
                          dark: TossDesignSystem.primaryYellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '행운의 아이템',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildLuckyItems(_generatedFortune!.luckyItems!),
                ],
              ),
            ).animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          ],
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TossButton(
                text: '다시 분석',
                onPressed: _reset,
                style: TossButtonStyle.ghost,
                size: TossButtonSize.medium,
                icon: Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              TossButton(
                text: '공유하기',
                onPressed: () {
                  // Share functionality
                },
                style: TossButtonStyle.primary,
                size: TossButtonSize.medium,
                icon: Icon(Icons.share),
              ),
            ],
          ).animate()
            .fadeIn(delay: 600.ms),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '분석 중 오류가 발생했습니다',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? '알 수 없는 오류',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 하단 버튼 공간 확보
              const BottomButtonSpacing(),
            ],
          ),
        ),

        // Floating 버튼
        FloatingBottomButton(
          text: '다시 시도',
          onPressed: _reset,
          style: TossButtonStyle.primary,
          size: TossButtonSize.large,
          icon: Icon(Icons.refresh),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) {
      return DarkModeHelper.getColor(
      context: context,
      light: TossDesignSystem.successGreen,
      dark: TossDesignSystem.primaryGreen,
    );
    }
    if (score >= 60) {
      return DarkModeHelper.getColor(
      context: context,
      light: TossDesignSystem.tossBlue,
      dark: TossDesignSystem.primaryBlue,
    );
    }
    if (score >= 40) {
      return DarkModeHelper.getColor(
      context: context,
      light: TossDesignSystem.warningOrange,
      dark: TossDesignSystem.primaryYellow,
    );
    }
    return DarkModeHelper.getColor(
      context: context,
      light: TossDesignSystem.errorRed,
      dark: TossDesignSystem.primaryRed,
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 80) return '매우 좋은 운세입니다!';
    if (score >= 60) return '좋은 운세가 기대됩니다';
    if (score >= 40) return '평범한 운세입니다';
    return '조심이 필요한 시기입니다';
  }

  Widget _buildLuckyItems(Map<String, dynamic> luckyItems) {
    final theme = Theme.of(context);
    final List<Widget> items = [];
    
    // Handle common lucky item keys
    if (luckyItems['color'] != null) {
      items.add(
        Chip(
          avatar: const Icon(Icons.palette, size: 18),
          label: Text('색상: ${luckyItems['color']}'),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
      );
    }
    
    if (luckyItems['number'] != null) {
      items.add(
        Chip(
          avatar: const Icon(Icons.looks_one, size: 18),
          label: Text('숫자: ${luckyItems['number']}'),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
      );
    }
    
    if (luckyItems['direction'] != null) {
      items.add(
        Chip(
          avatar: const Icon(Icons.explore, size: 18),
          label: Text('방향: ${luckyItems['direction']}'),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
      );
    }
    
    if (luckyItems['item'] != null) {
      items.add(
        Chip(
          avatar: const Icon(Icons.star, size: 18),
          label: Text('아이템: ${luckyItems['item']}'),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
      );
    }
    
    // Handle any additional items
    luckyItems.forEach((key, value) {
        if (!['color', 'number', 'direction', 'item'].contains(key) && value != null) {
        items.add(
          Chip(
            label: Text('$key: $value'),
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
        );
      }
    });
    
    if (items.isEmpty) {
      return Text(
        '행운의 아이템이 준비 중입니다',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha:0.6),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }
}