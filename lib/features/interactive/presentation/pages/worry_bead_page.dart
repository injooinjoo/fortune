import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../../../data/services/token_api_service.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_voice_text_field.dart';

class WorryBeadPage extends ConsumerStatefulWidget {
  const WorryBeadPage({super.key});

  @override
  ConsumerState<WorryBeadPage> createState() => _WorryBeadPageState();
}

class _WorryBeadPageState extends ConsumerState<WorryBeadPage> 
    with TickerProviderStateMixin {
  final TextEditingController _worryController = TextEditingController();
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isSpinning = false;
  bool _hasWorry = false;
  String? _adviceResult;
  int _spinCount = 0;
  
  // 걱정 염주 사용에 필요한 토큰 수
  static const int _requiredTokens = 2;
  
  // 염주 구슬 개수
  static const int _beadCount = 108;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this)..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _worryController.addListener(_onWorryTextChanged);
  }

  void _onWorryTextChanged() {
    setState(() {
      _hasWorry = _worryController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _worryController.removeListener(_onWorryTextChanged);
    _worryController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '걱정 염주'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    _buildWorryInput(),
                    const SizedBox(height: 32),
                    _buildWorryBead(),
                    const SizedBox(height: 24),
                    _buildActionButton(),
                    if (_adviceResult != null) ...[
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
            Icons.self_improvement,
            size: 48,
            color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            '걱정을 내려놓으세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음속 걱정을 적고 염주를 돌리면\n'
            '마음의 평안과 함께 조언을 드립니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.toll,
                  size: 16,
                  color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  '$_requiredTokens 복주머니 필요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
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
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildWorryInput() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '무엇이 걱정되시나요?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          UnifiedVoiceTextField(
            controller: _worryController,
            onSubmit: (text) {
              setState(() {
                _hasWorry = text.trim().isNotEmpty;
              });
            },
            hintText: '마음속 걱정을 적어주세요...',
            transcribingText: '듣고 있어요...',
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildWorryBead() {
    return GestureDetector(
      onTap: _hasWorry && !_isSpinning ? _startSpinning : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isSpinning ? _pulseAnimation.value : 1.0,
            child: Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 염주 구슬들
                    ...List.generate(_beadCount ~/ 4, (index) {
                      final angle = (index * 4 * math.pi * 2) / _beadCount;
                      final radius = 80.0;
                      return Positioned(
                        left: 100 + radius * math.cos(angle) - 4,
                        top: 100 + radius * math.sin(angle) - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // 중앙 장식
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 200.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildActionButton() {
    return Column(
      children: [
        if (_isSpinning)
          Text(
            '염주를 $_spinCount번 돌렸습니다...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasWorry && !_isSpinning ? _startSpinning : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSpinning
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _hasWorry ? '염주 돌리기' : '먼저 걱정을 적어주세요',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
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
                Icons.lightbulb_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '마음의 조언',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _adviceResult!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetWorry,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('다른 걱정 상담'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('조언 공유'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
      .slideY(begin: 0.1, end: 0);
  }

  Future<void> _startSpinning() async {
    // 토큰 확인
    final tokenBalance = ref.read(tokenBalanceProvider);
    if (tokenBalance?.remainingTokens != null &&
        tokenBalance!.remainingTokens < _requiredTokens &&
        !tokenBalance.hasUnlimitedAccess) {
      _showInsufficientTokensModal();
      return;
    }

    setState(() {
      _isSpinning = true;
      _spinCount = 0;
      _adviceResult = null;
    });
    
    ref.read(fortuneHapticServiceProvider).cardSelect();

    // 염주 회전 애니메이션
    _rotationController.repeat();
    
    // 3-5초 동안 회전
    final duration = 3 + math.Random().nextInt(3);
    final timer = Stream.periodic(const Duration(milliseconds: 500), (i) => i);
    
    await for (final _ in timer.take(duration * 2)) {
      if (mounted) {
        setState(() {
          _spinCount++;
        });
        ref.read(fortuneHapticServiceProvider).beadRotateTick();
      }
    }
    
    // 회전 멈추기
    await _rotationController.animateTo(
      _rotationController.value.ceil().toDouble(),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut);
    _rotationController.stop();
    
    try {
      // 토큰 차감
      final userId = ref.read(userProvider).value?.id;
      if (userId != null) {
        await ref.read(tokenApiServiceProvider).consumeTokens(
          userId: userId,
          fortuneType: 'worry_bead',
          amount: _requiredTokens);
      }

      // 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);
      
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _adviceResult = '''
【걱정을 놓아주세요】

당신의 걱정을 ${_spinCount * 108}번의 염주알과 함께 우주에 띄워 보냈습니다.

이제 마음을 가볍게 하고 현재에 집중해보세요. 걱정은 아직 일어나지 않은 미래에 대한 두려움일 뿐입니다.

【조언】
• 깊은 호흡을 통해 현재 순간에 머물러보세요.
• 걱정되는 일을 작은 단계로 나누어 하나씩 해결해보세요.
• 통제할 수 없는 것들은 받아들이는 지혜가 필요합니다.
• 긍정적인 결과를 상상하며 마음의 평화를 찾아보세요.

【명상 문구】
"나는 현재에 존재하며, 내 안의 평화와 함께합니다.
걱정은 구름처럼 지나가고, 나는 맑은 하늘처럼 고요합니다."

모든 것은 지나가며, 당신은 충분히 강합니다. 🙏
''';
        _isSpinning = false;
      });

      ref.read(fortuneHapticServiceProvider).mysticalReveal();
    } catch (e) {
      Logger.error('걱정 염주 실패', e);
      setState(() => _isSpinning = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('조언을 받는데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _resetWorry() {
    ref.read(fortuneHapticServiceProvider).selection();
    setState(() {
      _worryController.clear();
      _hasWorry = false;
      _adviceResult = null;
      _spinCount = 0;
    });
  }

  void _shareResult() async {
    ref.read(fortuneHapticServiceProvider).shareAction();
    if (_adviceResult == null) return;

    try {
      await Share.share(
        '🔮 걱정 염주 결과\n\n$_adviceResult\n\n앱에서 더 자세히 확인해보세요!',
        subject: '걱정 염주 결과 공유',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유에 실패했습니다')),
        );
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
        fortuneType: 'worry_bead',
      ),
    );
  }
}