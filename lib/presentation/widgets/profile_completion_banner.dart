import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_animations.dart';
import '../../core/utils/profile_validation.dart';
import '../../services/storage_service.dart';
import '../../shared/glassmorphism/glass_container.dart';

class ProfileCompletionBanner extends StatefulWidget {
  const ProfileCompletionBanner({super.key});

  @override
  State<ProfileCompletionBanner> createState() => _ProfileCompletionBannerState();
}

class _ProfileCompletionBannerState extends State<ProfileCompletionBanner> 
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  bool _isVisible = false;
  bool _isDismissed = false;
  double _completionPercentage = 0.0;
  List<String> _missingFields = [];
  
  static const String _dismissalKey = 'profile_banner_dismissed';
  static const String _dismissalDateKey = 'profile_banner_dismissed_date';
  
  @override
  void initState() {
    super.initState();
    _checkBannerVisibility();
  }
  
  Future<void> _checkBannerVisibility() async {
    try {
      // Check if user is guest
      final isGuest = await _storageService.isGuestMode();
      
      // Check if user needs onboarding
      final needsOnboarding = await ProfileValidation.needsOnboarding();
      
      // For guests, always show banner unless dismissed
      // For authenticated users, show only if profile incomplete
      if (!isGuest && !needsOnboarding) {
        // Profile is complete, don't show banner
        return;
      }
      
      // Check if banner was dismissed
      final prefs = await SharedPreferences.getInstance();
      final isDismissed = prefs.getBool(_dismissalKey) ?? false;
      final dismissalDate = prefs.getString(_dismissalDateKey);
      
      // Check if 24 hours have passed since dismissal
      if (isDismissed && dismissalDate != null) {
        final dismissedAt = DateTime.parse(dismissalDate);
        final now = DateTime.now();
        final difference = now.difference(dismissedAt);
        
        if (difference.inHours < 24) {
          // Still within 24 hours, don't show
          return;
        } else {
          // Reset dismissal after 24 hours
          await prefs.remove(_dismissalKey);
          await prefs.remove(_dismissalDateKey);
        }
      }
      
      // Calculate completion percentage
      final profile = await _storageService.getUserProfile();
      final percentage = ProfileValidation.calculateCompletionPercentage(profile);
      final missing = ProfileValidation.getMissingFields(profile);
      
      if (mounted) {
        setState(() {
          _completionPercentage = percentage;
          _missingFields = missing;
          _isVisible = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking profile banner visibility: $e');
    }
  }
  
  Future<void> _dismissBanner() async {
    setState(() {
      _isDismissed = true;
    });
    
    // Save dismissal state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissalKey, true);
    await prefs.setString(_dismissalDateKey, DateTime.now().toIso8601String());
    
    // Wait for animation to complete
    await Future.delayed(AppAnimations.durationMedium);
    
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }
    
    return AnimatedSlide(
      offset: _isDismissed ? const Offset(1, 0) : Offset.zero,
      duration: AppAnimations.durationMedium,
      curve: Curves.easeOutCubic,
      child: Dismissible(
        key: const Key('profile_completion_banner'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _dismissBanner(),
        background: Container(
          color: TossDesignSystem.white.withValues(alpha: 0.0),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.spacing4),
          child: Icon(
            Icons.close,
            color: TossDesignSystem.gray900.withValues(alpha: 0.54)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: GlassContainer(
              padding: AppSpacing.paddingAll16,
              borderColor: TossDesignSystem.gray900.withValues(alpha: 0.12),
              child: Row(
                children: [
                  // Progress Indicator
                  SizedBox(
                    width: 60,
                    height: AppSpacing.spacing15,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _completionPercentage,
                          strokeWidth: 4,
                          backgroundColor: TossDesignSystem.gray600,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _completionPercentage < 0.5 
                                ? TossDesignSystem.gray900.withValues(alpha: 0.54)
                                : TossDesignSystem.gray900.withValues(alpha: 0.87),
                          ),
                        ),
                        Text(
                          '${(_completionPercentage * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing4),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '프로필을 완성해주세요',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: AppSpacing.spacing1),
                        Text(
                          _missingFields.isEmpty 
                              ? '더 정확한 운세를 위해 프로필을 확인해주세요'
                              : '정보: ${_missingFields.take(2).join(', ')}${_missingFields.length > 2 ? ' 외 ${_missingFields.length - 2}개' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.gray300
                                : TossDesignSystem.gray900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppDimensions.iconSizeXSmall,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.gray400
                        : TossDesignSystem.gray600,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}