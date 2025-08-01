import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../domain/entities/fortune.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../presentation/screens/ad_loading_screen.dart';

typedef InputBuilder = Widget Function(BuildContext context, Function(Map<String, dynamic>) onSubmit);
typedef ResultBuilder = Widget Function(BuildContext context, FortuneResult result, VoidCallback onShare);

class BaseFortunePageV2 extends ConsumerStatefulWidget {
  final String title;
  final String fortuneType;
  final LinearGradient? headerGradient;
  final InputBuilder inputBuilder;
  final ResultBuilder resultBuilder;
  final bool showShareButton;
  final bool showFontSizeSelector;

  const BaseFortunePageV2({
    Key? key,
    required this.title,
    required this.fortuneType,
    this.headerGradient,
    required this.inputBuilder,
    required this.resultBuilder,
    this.showShareButton = true,
    this.showFontSizeSelector = true,
  }) : super(key: key);

  @override
  ConsumerState<BaseFortunePageV2> createState() => _BaseFortunePageV2State();
}

class _BaseFortunePageV2State extends ConsumerState<BaseFortunePageV2>
    with SingleTickerProviderStateMixin {
  FortuneResult? _fortuneResult;
  bool _isLoading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800)
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, String> _extractSections(Fortune fortune) {
    // Extract sections from additionalInfo for specific fortune types
    final sections = <String, String>{};
    
    if (fortune.additionalInfo != null) {
      fortune.additionalInfo!.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          sections[key] = value;
        }
      });
    }
    
    return sections;
  }

  void _handleShare() async {
    if (_fortuneResult == null) return;
    
    try {
      // Create share text
      final shareText = '''
🔮 ${widget.title} 결과

${_fortuneResult!.content}

${_fortuneResult!.luckyItems?.isNotEmpty == true ? '\n💫 행운의 아이템:\n${_fortuneResult!.luckyItems!.entries.map((e) => '• ${e.key}: ${e.value}').join('\n')}' : ''}

${_fortuneResult!.recommendations?.isNotEmpty == true ? '\n📌 추천 사항:\n${_fortuneResult!.recommendations!.map((r) => '• $r').join('\n')}' : ''}

---
Fortune 앱에서 더 많은 운세를 확인하세요!
''';

      await Share.share(
        shareText,
        subject: '${widget.title} - Fortune 앱'
      );
      
      // Log share event
      debugPrint('Shared fortune: ${widget.fortuneType}');
      
    } catch (e) {
      debugPrint('Share error: $e');
      Toast.error(context, '공유 중 오류가 발생했습니다');
    }
  }

  Future<void> _generateFortune(Map<String, dynamic> params) async {
    // Check if user has unlimited access (premium,
    final tokenState = ref.read(tokenProvider);
    final isPremium = tokenState.hasUnlimitedAccess;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Fortune? generatedFortune;
      
      // Show ad loading screen (or premium loading for premium users,
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdLoadingScreen(
            fortuneType: widget.fortuneType,
            fortuneTitle: widget.title,
            isPremium: isPremium,
            onComplete: () {
              Navigator.pop(context);
            },
            onSkip: () {
              Navigator.pop(context);
              // Navigate to premium page
              Navigator.pushNamed(context, '/premium');
            },
            fetchData: () async {
              // Generate fortune during ad loading
              final fortune = await ref.read(
                fortuneGenerationProvider(
                  FortuneGenerationParams(
                    fortuneType: widget.fortuneType,
                    userInfo: params,
                  ),
                ).future
              );
              generatedFortune = fortune;
              return fortune;
            },
            onAdComplete: isPremium ? null : () async {
              // Reward tokens for watching ad (free users only,
              await ref.read(tokenProvider.notifier).rewardTokensForAd(
                fortuneType: widget.fortuneType,
                rewardAmount: 1,
              );
            },
          ),
          fullscreenDialog: true
        )
      );

      // Check if fortune was successfully generated
      if (generatedFortune != null) {
        // Convert Fortune to FortuneResult
        final fortuneResult = FortuneResult(
          id: generatedFortune!.id,
          type: generatedFortune!.type,
          date: DateTime.now().toString().split(' ')[0],
          mainFortune: generatedFortune!.description,
          summary: generatedFortune!.summary,
          details: generatedFortune!.additionalInfo ?? {},
          sections: _extractSections(generatedFortune!),
          overallScore: generatedFortune!.overallScore,
          scoreBreakdown: generatedFortune!.scoreBreakdown?.map((key, value) => 
            MapEntry(key, value is int ? value : (value as num).toInt())),
          luckyItems: generatedFortune!.luckyItems,
          recommendations: generatedFortune!.recommendations
        );

        setState(() {
          _fortuneResult = fortuneResult;
          _isLoading = false;
        });

        _animationController.forward();
        
        // Show success toast with token reward info
        if (!isPremium && mounted) {
          Toast.success(
            context, 
            '운세가 생성되었습니다! (1토큰 획득)'
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      // More specific error messages
      if (e.toString().contains('network')) {
        Toast.error(context, '네트워크 연결을 확인해주세요');
      } else if (e.toString().contains('unauthorized')) {
        Toast.error(context, '로그인이 필요합니다');
      } else {
        Toast.error(context, '운세 생성 중 오류가 발생했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: widget.headerGradient ?? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: AppHeader(
                title: widget.title,
                showShareButton: widget.showShareButton && _fortuneResult != null,
                showFontSizeSelector: widget.showFontSizeSelector,
                currentFontSize: ref.watch(fontSizeProvider),
                onFontSizeChanged: (size) {
                  ref.read(fontSizeProvider.notifier).setFontSize(size);
                },
                backgroundColor: const Color(0x00000000), // transparent
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: FortuneResultSkeleton())
                  : _error != null
                      ? _buildErrorState()
                      : _fortuneResult != null
                          ? FadeTransition(
                              opacity: _fadeAnimation,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: widget.resultBuilder(
                                  context, 
                                  _fortuneResult!,
                                  _handleShare,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: widget.inputBuilder(context, _generateFortune),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FortuneBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
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
                onPressed: () {
                  setState(() {
                    _error = null;
                    _fortuneResult = null;
                  });
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        )
      )
    );
  }
}