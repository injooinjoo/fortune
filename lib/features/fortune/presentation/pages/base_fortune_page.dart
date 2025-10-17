import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/widgets/fortune_explanation_bottom_sheet.dart';
import '../../../../presentation/widgets/user_info_visualization.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../shared/components/soul_earn_animation.dart';
import '../../../../shared/components/soul_consume_animation.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../services/ad_service.dart';
import '../../../../services/fortune_history_service.dart';

abstract class BaseFortunePage extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String fortuneType;
  final bool requiresUserInfo;
  final bool showShareButton;
  final bool showFontSizeSelector;
  final Map<String, dynamic>? initialParams;
  final Color? backgroundColor;

  const BaseFortunePage({
    super.key,
    required this.title,
    required this.description,
    required this.fortuneType,
    this.requiresUserInfo = true,
    this.showShareButton = true,
    this.showFontSizeSelector = false,
    this.initialParams,
    this.backgroundColor});
}

abstract class BaseFortunePageState<T extends BaseFortunePage>
    extends ConsumerState<T> with TickerProviderStateMixin {
  Fortune? _fortune;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userParams;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  UserProfile? _userProfile;
  
  // Scroll controller and variables for navigation bar hiding
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;
  
  // Protected getters for subclasses
  Fortune? get fortune => _fortune;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile? get userProfile => _userProfile;
  ScrollController get scrollController => _scrollController;

  @override
  void initState() {
    super.initState();
    Logger.info('🎯 [BaseFortunePage] Initializing fortune page', {
      'fortuneType': widget.fortuneType,
      'title': widget.title,
      'requiresUserInfo': widget.requiresUserInfo,
      'hasInitialParams': widget.initialParams != null
    });
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800)
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack
    ));
    
    // Initialize scroll controller with navigation bar hiding logic
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Load user profile if authenticated
    _loadUserProfile();
    
    // Check if we should auto-generate fortune
    final autoGenerate = widget.initialParams?['autoGenerate'] as bool? ?? false;
    final fortuneParams = widget.initialParams?['fortuneParams'] as Map<String, dynamic>?;
    
    // If autoGenerate flag is set or initial params with fortuneParams are provided, generate fortune immediately
    if (autoGenerate || fortuneParams != null) {
      Logger.debug('🚀 [BaseFortunePage] Auto-generating fortune', {
        'autoGenerate': autoGenerate,
        'hasFortuneParams': fortuneParams != null,
        'initialParams': null,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        generateFortuneAction(params: fortuneParams ?? widget.initialParams);
      });
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      Logger.debug('👤 [BaseFortunePage] Loading user profile');
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.when(
        data: (profile) {
          if (mounted) {
            Logger.debug('✅ [BaseFortunePage] User profile loaded', {
              'hasProfile': profile != null,
              'userName': null,
            });
            setState(() {
              _userProfile = profile;
            });
          }
        },
        error: (error, stackTrace) {
          Logger.warning('⚠️ [BaseFortunePage] Failed to load user profile', error);
          // Silently handle error - user profile is optional
        },
        loading: () {
          Logger.debug('⏳ [BaseFortunePage] User profile is loading');
          // Profile is loading
        }
      );
    } catch (e) {
      Logger.error('❌ [BaseFortunePage] Error loading user profile', e);
      // Silently handle any errors
    }
  }

  /// 운세를 fortune_history 테이블에 영구 저장 (모든 운세 타입 공통)
  Future<void> _saveFortuneToHistory(Fortune fortune, Map<String, dynamic> fortuneParams) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('[BaseFortunePage] User not authenticated, skipping fortune history save');
        return;
      }

      final now = DateTime.now();
      final fortuneTypeName = FortuneTypeNames.getName(widget.fortuneType);
      final title = '$fortuneTypeName - ${now.year}년 ${now.month}월 ${now.day}일';

      // 운세 요약 데이터 생성
      final summary = {
        'score': fortune.overallScore ?? 75,
        'content': fortune.content,
        'advice': fortune.advice ?? fortune.recommendations?.firstOrNull,
        'caution': fortune.caution ?? fortune.warnings?.firstOrNull,
        'summary': fortune.summary,
        'greeting': fortune.greeting,
        'luckyColor': fortune.luckyColor,
        'luckyNumber': fortune.luckyNumber,
      };

      // 메타데이터 (사용자 입력 정보 포함)
      final metadata = {
        'fortuneParams': fortuneParams,
        'userParams': _userParams,
        'hexagonScores': fortune.hexagonScores,
        'scoreBreakdown': fortune.scoreBreakdown,
        'recommendations': fortune.recommendations,
        'warnings': fortune.warnings,
        'luckyItems': fortune.luckyItems,
      };

      // 태그 생성
      final tags = <String>[fortuneTypeName, '${now.year}년${now.month}월'];
      final score = fortune.overallScore ?? 75;
      if (score >= 90) {
        tags.add('최고운');
      } else if (score >= 80) {
        tags.add('대길');
      } else if (score >= 70) {
        tags.add('길');
      } else if (score >= 60) {
        tags.add('보통');
      } else {
        tags.add('주의');
      }

      // FortuneHistoryService에 저장
      final historyService = FortuneHistoryService();
      await historyService.saveFortuneResult(
        fortuneType: widget.fortuneType,
        title: title,
        summary: summary,
        fortuneData: fortune.toJson(),
        metadata: metadata,
        tags: tags,
        score: fortune.overallScore,
      );

      Logger.info('[BaseFortunePage] Fortune saved to history: $title');
    } catch (error) {
      Logger.error('[BaseFortunePage] Error saving fortune to history', error);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final currentScrollPosition = _scrollController.offset;
    const scrollDownThreshold = 10.0; // Minimum scroll down distance
    const scrollUpThreshold = 3.0; // Ultra sensitive scroll up detection
    
    // Always show navigation when at the top
    if (currentScrollPosition <= 10.0) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        ref.read(navigationVisibilityProvider.notifier).show();
      }
      _lastScrollOffset = currentScrollPosition;
      return;
    }
    
    if (currentScrollPosition > _lastScrollOffset + scrollDownThreshold && !_isScrollingDown) {
      // Scrolling down - hide navigation
      _isScrollingDown = true;
      ref.read(navigationVisibilityProvider.notifier).hide();
    } else if (currentScrollPosition < _lastScrollOffset - scrollUpThreshold && _isScrollingDown) {
      // Scrolling up - show navigation (very sensitive)
      _isScrollingDown = false;
      ref.read(navigationVisibilityProvider.notifier).show();
    }
    
    _lastScrollOffset = currentScrollPosition;
  }

  // Abstract method to be implemented by each fortune page
  Future<Fortune> generateFortune(Map<String, dynamic> params);

  // Common method to handle fortune generation - made protected for subclasses
  @protected
  Future<void> generateFortuneAction({Map<String, dynamic>? params}) async {
    Logger.info('🔵 [TRACE-1] generateFortuneAction() STARTED', {
      'fortuneType': widget.fortuneType,
      'hasParams': params != null,
    });

    final stopwatch = Logger.startTimer('Fortune Generation - ${widget.fortuneType}');

    Logger.info('🎲 [BaseFortunePage] Starting fortune generation', {
      'fortuneType': widget.fortuneType,
      'hasParams': params != null,
      'timestamp': DateTime.now().toIso8601String()
    });
    
    // Check if user has unlimited access (premium,
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);
    final isPremium = tokenState.hasUnlimitedAccess;
    
    Logger.debug('💎 [BaseFortunePage] User premium status', {
      'isPremium': isPremium,
      'currentSouls': null,
    });
    
    // 프리미엄 운세인 경우 영혼 확인
    if (!isPremium && SoulRates.isPremiumFortune(widget.fortuneType)) {
      final canAccess = tokenNotifier.canAccessFortune(widget.fortuneType);
      final requiredSouls = -SoulRates.getSoulAmount(widget.fortuneType);
      
      Logger.debug('💰 [BaseFortunePage] Soul check for premium fortune', {
        'fortuneType': widget.fortuneType,
        'requiredSouls': requiredSouls,
        'canAccess': canAccess});
      
      if (!canAccess) {
        Logger.warning('⛔ [BaseFortunePage] Insufficient souls for fortune', {
          'fortuneType': widget.fortuneType,
          'requiredSouls': requiredSouls,
          'currentSouls': null,
        });
        
        // 영혼 부족 모달 표시
        HapticUtils.warning();
        await TokenInsufficientModal.show(
          context: context,
          requiredTokens: requiredSouls,
          fortuneType: widget.fortuneType
        );
        Logger.endTimer('Fortune Generation - ${widget.fortuneType}', stopwatch);
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use provided params or get default params
      final fortuneParams = params ?? await getFortuneParams() ?? {};
      
      Logger.debug('📝 [BaseFortunePage] Fortune parameters prepared', {
        'fortuneType': widget.fortuneType,
        'paramKeys': null,
      });
      
      // Store user params for visualization
      _userParams = fortuneParams;

      // Show interstitial ad before generating fortune
      Logger.debug('📺 [BaseFortunePage] Attempting to show interstitial ad');

      // Function to generate fortune after ad
      Future<void> generateFortuneAfterAd() async {
        Logger.info('🔵 [TRACE-8] generateFortuneAfterAd() ENTERED');

        try {
          Logger.info('🔵 [TRACE-9] Inside generateFortuneAfterAd try block');
          Logger.debug('🔮 [BaseFortunePage] Calling generateFortune implementation');
          final fortuneStopwatch = Logger.startTimer('API Call - ${widget.fortuneType}');

          Logger.info('🔵 [TRACE-10] About to call generateFortune()');
          final fortune = await generateFortune(fortuneParams);
          Logger.info('🔵 [TRACE-11] generateFortune() returned', {'fortuneId': fortune.id});

          Logger.endTimer('API Call - ${widget.fortuneType}', fortuneStopwatch);
          Logger.info('✨ [BaseFortunePage] Fortune generated successfully', {
            'fortuneType': widget.fortuneType,
            'fortuneId': fortune.id,
            'overallScore': fortune.overallScore,
            'hasDescription': fortune.description?.isNotEmpty ?? false,
            'luckyItemsCount': null,
          });

          // ✅ 운세를 fortune_history 테이블에 영구 저장
          Logger.debug('💾 [BaseFortunePage] Saving fortune to history...');
          try {
            await _saveFortuneToHistory(fortune, fortuneParams);
            Logger.debug('✅ [BaseFortunePage] Fortune saved to history successfully');
          } catch (historyError) {
            Logger.warning('⚠️ [BaseFortunePage] Failed to save fortune to history (non-fatal): $historyError');
          }

          Logger.info('🔵 [TRACE-12] About to call setState()');
          Logger.debug('🔄 [BaseFortunePage] Setting state with fortune...');
          setState(() {
            _fortune = fortune;
            _isLoading = false;
          });
          Logger.info('🔵 [TRACE-13] setState() completed');
          Logger.debug('✅ [BaseFortunePage] State updated - isLoading: false, fortune: ${fortune.id}');

          // Track fortune access in statistics
          final currentUser = ref.read(authStateProvider).value;
          if (currentUser != null) {
            Logger.debug('📊 [BaseFortunePage] Updating user statistics');
            try {
              await ref.read(userStatisticsNotifierProvider.notifier)
                  .incrementFortuneCount(widget.fortuneType);
              Logger.debug('✅ [BaseFortunePage] Statistics updated successfully');
            } catch (e) {
              Logger.error('❌ [BaseFortunePage] Failed to update statistics', e);
            }

            // Also add to recent fortunes
            ref.read(recentFortunesProvider.notifier).addFortune(
              widget.fortuneType,
              widget.title);

            // Add to storage service for offline access
            final storageService = ref.read(storageServiceProvider);
            await storageService.addRecentFortune(
              widget.fortuneType,
              widget.title);
            Logger.debug('💾 [BaseFortunePage] Fortune saved to recent history');
          }

          // 영혼 시스템 처리
          // 프리미엄 회원이 아닌 경우에만 영혼 처리
          if (!isPremium) {
            Logger.debug('💫 [BaseFortunePage] Processing soul transaction');
            final result = await ref.read(tokenProvider.notifier).processSoulForFortune(
              widget.fortuneType
            );

            final soulAmount = SoulRates.getSoulAmount(widget.fortuneType);
            if (result == true) {
              // Show soul animation based on the amount
              if (mounted) {
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  if (soulAmount > 0) {
                    // Soul earned (free fortune)
                    SoulEarnAnimation.show(
                      context: context,
                      soulAmount: soulAmount
                    );
                  } else if (soulAmount < 0) {
                    // Soul consumed (premium fortune)
                    SoulConsumeAnimation.show(
                      context: context,
                      soulAmount: -soulAmount
                    );
                  }
                }
              }
              Logger.info('💫 [BaseFortunePage] Soul transaction successful', {
                'fortuneType': widget.fortuneType,
                'soulAmount': soulAmount,
              });
            } else {
              Logger.warning('⚠️ [BaseFortunePage] Soul transaction failed');
            }
          }
        } catch (e, stackTrace) {
          Logger.error('❌ [BaseFortunePage] Fatal error in generateFortuneAfterAd', e, stackTrace);

          // 에러 발생 시에도 반드시 로딩 중지
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = 'Fortune generation failed: ${e.toString()}';
            });
          }
        }
      }

      // Try to show ad first
      Logger.info('🔵 [TRACE-2] Entering ad flow section', {'adShown': false});

      bool adShown = false;
      try {
        Logger.info('🔵 [TRACE-3] Inside ad try block');
        Logger.debug('📺 [BaseFortunePage] Checking ad readiness...');

        // Check if ad is ready
        if (!AdService.instance.isInterstitialAdReady) {
          Logger.debug('📺 [BaseFortunePage] Interstitial ad not ready, attempting to load...');
          // Try to load ad with a timeout
          final loadStartTime = DateTime.now();
          await Future.any([
            AdService.instance.loadInterstitialAd(),
            Future.delayed(const Duration(seconds: 2)), // 2 second timeout for loading
          ]);
          final loadDuration = DateTime.now().difference(loadStartTime).inMilliseconds;
          Logger.debug('📺 [BaseFortunePage] Ad load attempt finished in ${loadDuration}ms, ready: ${AdService.instance.isInterstitialAdReady}');
        } else {
          Logger.debug('📺 [BaseFortunePage] Interstitial ad already ready');
        }

        // Show ad if ready
        if (AdService.instance.isInterstitialAdReady) {
          Logger.info('📺 [BaseFortunePage] Showing interstitial ad...');
          await AdService.instance.showInterstitialAdWithCallback(
            onAdCompleted: () async {
              Logger.info('✅ [BaseFortunePage] Ad completed successfully, generating fortune');
              await generateFortuneAfterAd();
            },
            onAdFailed: () async {
              Logger.warning('⚠️ [BaseFortunePage] Ad failed to show, generating fortune anyway');
              await generateFortuneAfterAd();
            },
          );
          adShown = true;
          Logger.debug('📺 [BaseFortunePage] Ad show initiated, waiting for callback...');
        } else {
          Logger.warning('⚠️ [BaseFortunePage] Ad still not ready after load attempt');
        }

        Logger.info('🔵 [TRACE-4] Exiting ad try block', {'adShown': adShown});

      } catch (e) {
        Logger.error('❌ [BaseFortunePage] Error in ad flow', e);
      }

      Logger.info('🔵 [TRACE-5] After ad try-catch, checking adShown', {'adShown': adShown});

      // If ad wasn't shown, generate fortune directly
      if (!adShown) {
        Logger.info('🔵 [TRACE-6] adShown is false, calling generateFortuneAfterAd()');
        Logger.info('📺 [BaseFortunePage] No ad shown, generating fortune directly');
        await generateFortuneAfterAd();
        Logger.info('🔵 [TRACE-7] generateFortuneAfterAd() returned');
      } else {
        Logger.debug('📺 [BaseFortunePage] Ad was initiated, fortune will be generated in callback');
        // Ad was shown, fortune will be generated in the callback
        return;
      }

      // Success haptic feedback
      HapticUtils.success();
      _animationController.forward();
      
      Logger.endTimer('Fortune Generation - ${widget.fortuneType}', stopwatch);
      Logger.info('🎉 [BaseFortunePage] Fortune generation completed successfully', {
        'fortuneType': widget.fortuneType,
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});
    } catch (e, stackTrace) {
      Logger.error('❌ [BaseFortunePage] Fortune generation failed', e, stackTrace);
      Logger.endTimer('Fortune Generation - ${widget.fortuneType}', stopwatch);
      
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

  // Common UI for input form - deprecated, use bottom sheet instead
  @Deprecated('설정 폼은 FortuneExplanationBottomSheet에서 처리합니다')
  Widget buildInputForm() {
    return const SizedBox.shrink();
  }

  // Common UI for fortune result
  Widget buildFortuneResult() {
    if (_fortune == null) {
      Logger.debug('🚫 [BaseFortunePage] buildFortuneResult called but fortune is null');
      return const SizedBox.shrink();
    }

    Logger.debug('🏗️ [BaseFortunePage] Building fortune result UI', {
      'fortuneType': widget.fortuneType,
      'fortuneId': _fortune?.id,
      'hasUserParams': _userParams != null
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Add user info visualization if params exist
              if (_userParams != null && _userParams!.isNotEmpty) ...[
                UserInfoVisualization(
                  userInfo: _userParams!,
                  fortuneType: widget.fortuneType),
                const SizedBox(height: 20)],
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.2),
                      scoreColor.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.3),
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
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      color: TossDesignSystem.white,
                      size: 20),
                    onPressed: () {
                      HapticUtils.lightImpact();
                      FortuneExplanationBottomSheet.show(
                        context,
                        fortuneType: widget.fortuneType,
                        fortuneData: {
                          'score': score,
                          'luckyItems': _fortune?.luckyItems,
                          'recommendations': null,
                        });
                    },
                    tooltip: '${FortuneTypeNames.getName(widget.fortuneType)} 가이드',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
            style: Theme.of(context).textTheme.headlineSmall),
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
                        style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        '$score점',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
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
            style: Theme.of(context).textTheme.headlineSmall),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상세 운세',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  HapticUtils.lightImpact();
                  FortuneExplanationBottomSheet.show(
                    context,
                    fortuneType: widget.fortuneType,
                    fortuneData: {
                      'score': _fortune?.overallScore,
                      'luckyItems': _fortune?.luckyItems,
                      'recommendations': null});
                },
                tooltip: '${FortuneTypeNames.getName(widget.fortuneType)} 가이드'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: _getFontSize(fontSize),
                  height: 1.6),
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
          }),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight),
      appBar: StandardFortuneAppBar(
        title: widget.title,
        onBackPressed: _fortune != null
            ? () {
                // When fortune result is displayed, navigate to fortune list
                GoRouter.of(context).go('/fortune');
              }
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const FortuneResultSkeleton()
                : _error != null
                    ? _buildErrorState()
                    : _fortune != null
                        ? buildFortuneResult()
                        : _buildInitialState(),
            if (_fortune == null && !_isLoading && _error == null)
              FloatingBottomButton(
                text: '운세 보기',
                onPressed: () async {
                  Logger.info('🖱️ [BaseFortunePage] User clicked generate fortune button', {
                    'fortuneType': widget.fortuneType,
                    'title': widget.title,
                    'hasUserProfile': _userProfile != null,
                    'requiresUserInfo': widget.requiresUserInfo,
                  });

                  await AdService.instance.showInterstitialAdWithCallback(
                    onAdCompleted: () async {
                      await generateFortuneAction();
                    },
                    onAdFailed: () async {
                      await generateFortuneAction();
                    },
                  );
                },
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
                icon: Icon(Icons.auto_awesome_rounded),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero image at the top
          Hero(
            tag: 'fortune-hero-${widget.fortuneType}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.asset(
                  FortuneCardImages.getImagePath(widget.fortuneType),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback gradient if image fails
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 64,
                        color: TossDesignSystem.white.withValues(alpha: 0.8),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  '아래 버튼을 눌러 운세를 확인해보세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const BottomButtonSpacing(),
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
              color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _error ?? '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TossButton(
              text: '다시 시도',
              onPressed: generateFortuneAction,
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

}