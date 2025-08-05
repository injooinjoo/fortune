import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../presentation/widgets/ads/common_ad_placements.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final String fortuneType;
  final bool canSkip;

  const AdLoadingScreen({
    Key? key,
    required this.onComplete,
    required this.fortuneType,
    this.canSkip = false}) : super(key: key);

  @override
  ConsumerState<AdLoadingScreen> createState() => _AdLoadingScreenState();
}

class _AdLoadingScreenState extends ConsumerState<AdLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  Timer? _timer;
  int _countdown = 5;
  bool _isSkipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear);

    _startCountdown();
    _controller.forward();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _completeAd();
      }
    });
  }

  void _completeAd() {
    if (!_isSkipped) {
      _timer?.cancel();
      widget.onComplete();
    }
  }

  void _skipAd() {
    setState(() {
      _isSkipped = true;
    });
    _timer?.cancel();
    _controller.stop();
    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider).value;
    final isPremium = userProfile?.isPremiumActive ?? false;

    // Premium users can skip immediately
    if (isPremium) {
      Future.microtask(() => widget.onComplete());
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.fortuneTheme.primaryText.withValues(alpha: 0.87),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      Colors.transparent])),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(context.fortuneTheme.formStyles.inputBorderWidth * 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            Colors.transparent]))).animate(
                      onPlay: (controller) => controller.repeat()).shimmer(
                      duration: const Duration(milliseconds: 3000),
                      delay: Duration(
                        milliseconds: index * 100));
                  }))),

            // Main Content
            Center(
              child: Padding(
                padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fortune Icon
                    Container(
                      width: context.fortuneTheme.microInteractions.fabPressScale * 125,
                      height: context.fortuneTheme.microInteractions.fabPressScale * 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary]),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.875,
                            spreadRadius: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.625)]),
                      child: Icon(
                        _getFortuneIcon(widget.fortuneType),
                        color: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                        size: context.fortuneTheme.formStyles.inputHeight * 1.2)).animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: const Duration(milliseconds: 500))
                      .then()
                      .rotate(
                        begin: 0,
                        end: 1,
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeInOut),

                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5),

                    // Loading Text
                    Text(
                      '${_getFortuneTitle(widget.fortuneType)} 준비 중...',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold)).animate()
                      .fadeIn()
                      .slideY(begin: 0.2, end: 0),
                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5),

                    Builder(
                      builder: (context) => SizedBox(
                        height: context.fortuneTheme.formStyles.inputPadding.horizontal)),

                    Text(
                      '잠시만 기다려주세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.7))),

                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5),

                    // Progress Bar
                    GlassContainer(
                      width: context.fortuneTheme.formStyles.inputHeight * 6,
                      height: context.fortuneTheme.formStyles.inputHeight * 1.2,
                      padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight * 0.6),
                      blur: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Progress Track
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.textPrimaryDark.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight * 0.5))),
                          // Animated Progress
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary]),
                                    borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight * 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                        blurRadius: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.625,
                                        spreadRadius: context.fortuneTheme.formStyles.inputBorderWidth * 2)])));
                            }),
                          // Countdown Text
                          Text(
                            _countdown > 0 ? '$_countdown' : '완료!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.bold))])),

                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2.5),

                    // Ad Message
                    Container(
                      padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
                        border: Border.all(
                          color: AppColors.textPrimaryDark.withValues(alpha: 0.2))),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.textPrimaryDark.withValues(alpha: 0.7),
                                size: context.fortuneTheme.formStyles.inputHeight * 0.4),
                              SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                              Text(
                                '광고를 시청하고 무료로 운세를 확인하세요',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimaryDark.withValues(alpha: 0.7)))]),
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                          Text(
                            '프리미엄 회원은 광고 없이 이용 가능합니다',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary))])),

                    // Premium Upgrade Button
                    Builder(
                      builder: (context) => SizedBox(
                        height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/premium');
                      },
                      icon: Icon(
                        Icons.diamond_rounded,
                        color: Colors.amber),
                      label: Text(
                        '프리미엄으로 업그레이드',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.amber)))]))),

            // Skip Button (if allowed)
            if (widget.canSkip && _countdown <= 3)
              Positioned(
                top: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                right: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                child: GlassButton(
                  onPressed: _skipAd,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal,
                    vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '광고 건너뛰기',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark)),
                      SizedBox(
                        width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.25),
                      Icon(
                        Icons.skip_next_rounded,
                        color: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                        size: context.fortuneTheme.formStyles.inputHeight * 0.4)])).animate().fadeIn(duration: const Duration(milliseconds: 300))),

            // Real Ad Banner (AdMob on mobile, AdSense on web)
            if (!isPremium)
              Positioned(
                bottom: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                left: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                right: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25,
                child: CommonAdPlacements().betweenContentAd(
                  padding: EdgeInsets.symmetric(
                    vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                  backgroundColor: AppColors.textPrimary.withValues(alpha: 0.5)))])));
  }

  IconData _getFortuneIcon(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return Icons.today_rounded;
      case 'love':
        return Icons.favorite_rounded;
      case 'saju':
        return Icons.auto_awesome_rounded;
      case 'compatibility':
        return Icons.people_rounded;
      case 'wealth':
        return Icons.attach_money_rounded;
      case 'mbti':
        return Icons.psychology_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  String _getFortuneTitle(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return '오늘의 운세';
      case 'love':
        return '연애운';
      case 'saju':
        return '사주팔자';
      case 'compatibility':
        return '궁합';
      case 'wealth':
        return '재물운';
      case 'mbti':
        return 'MBTI 운세';
      default:
        return '운세';
    }
  }
}

// Provider for ad state
final adLoadingProvider = StateProvider<bool>((ref) => false);