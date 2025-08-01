import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/social_auth_service.dart';
import '../../models/user_profile.dart';
import '../../constants/fortune_constants.dart';
import '../../utils/date_utils.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'steps/name_step.dart';
import 'steps/birth_info_step.dart';
import 'steps/gender_step.dart';
import 'steps/location_step.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  late final SocialAuthService _socialAuthService;
  
  int _currentStep = 0;
  final int _totalSteps = 4; // Name, Birth, Gender, Location
  bool _isLoading = false;
  User? _currentUser;
  bool _isAuthenticated = false;
  
  // Form values
  String _name = '';
  DateTime? _birthDate;
  String? _birthTime;
  Gender? _gender;
  String? _region;

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(Supabase.instance.client);
    // Don't initialize user here, let them complete onboarding first
  }

  Future<void> _initializeUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    _currentUser = session?.user;
    
    setState(() {
      _isAuthenticated = _currentUser != null;
    });
    
    // Set name from user metadata if available
    if (_currentUser != null) {
      _name = _currentUser?.userMetadata?['full_name'] ??
          _currentUser?.userMetadata?['name'] ??
          _currentUser?.email?.split('@')[0] ??
          _name;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: AppAnimations.durationMedium),
        curve: Curves.easeInOut)
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: AppAnimations.durationMedium),
        curve: Curves.easeInOut
      );
    }
  }

  Future<void> _onAuthenticationComplete() async {
    // Authentication successful, update user and sync profile
    await _initializeUser();
    
    // Get the locally stored profile data
    final localProfile = await _storageService.getUserProfile();
    
    if (localProfile != null && _currentUser != null) {
      // Sync the local profile to Supabase with the authenticated user ID
      try {
        await Supabase.instance.client.from('user_profiles').upsert({
          'id': _currentUser!.id)
          'email': _currentUser!.email)
          'name': _name)
          'birth_date': _birthDate!.toIso8601String(),
          'birth_time': _birthTime,
          'gender': _gender?.value,
          'region': _region
          'onboarding_completed': true
          'zodiac_sign': localProfile['zodiac_sign']
          'chinese_zodiac': localProfile['chinese_zodiac']
          'updated_at': DateTime.now().toIso8601String()
        
        // Update local profile with correct user ID
        localProfile['id'] = _currentUser!.id;
        localProfile['email'] = _currentUser!.email;
        await _storageService.saveUserProfile(localProfile);
        
        // Clear guest mode flag
        await _storageService.setGuestMode(false);
        
        debugPrint('Guest profile synced to authenticated account');
      } catch (e) {
        debugPrint('Failed to sync guest profile: $e');
      }
    }
    
    if (mounted) {
      context.go('/home?firstTime=true');
    }
  }

  void _skipAuthentication() async {
    // Complete onboarding as guest user
    if (mounted) {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // Generate a temporary ID for guest users
      final profileId = _currentUser?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      
      // Prepare profile data with location
      final profileData = {
        'id': profileId
        'name': _name
        'email': _currentUser?.email ?? 'guest@fortune.app',
        'birth_date': _birthDate!.toIso8601String(),
        'birth_time': _birthTime,
        'gender': _gender?.value ?? Gender.other.value,
        'region': _region
        'zodiac_sign': FortuneDateUtils.getZodiacSign(_birthDate!.toIso8601String()
        'chinese_zodiac': FortuneDateUtils.getChineseZodiac(_birthDate!.toIso8601String()
        'onboarding_completed': true,
        'subscription_status': 'free',
        'fortune_count': 0,
        'premium_fortunes_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String();

      // Save to local storage
      await _storageService.saveUserProfile(profileData);
      
      // Set guest mode flag if not authenticated
      if (_currentUser == null) {
        await _storageService.setGuestMode(true);
        debugPrint('Profile saved locally for guest user');
      } else {
        await _storageService.setGuestMode(false);
      }

      // Save to Supabase if authenticated
      if (_currentUser != null) {
        try {
          await Supabase.instance.client.from('user_profiles').upsert({
            'id': _currentUser!.id)
            'email': _currentUser!.email)
            'name': _name)
            'birth_date': _birthDate!.toIso8601String(),
            'birth_time': _birthTime, // This is already in Korean format like "축시"
            'gender': _gender?.value,
            'region': _region
            'onboarding_completed': true
            'zodiac_sign': profileData['zodiac_sign']
            'chinese_zodiac': profileData['chinese_zodiac']
            'updated_at': DateTime.now().toIso8601String()
          debugPrint('Profile synced to Supabase');
        } catch (e) {
          debugPrint('Supabase sync failed: $e');
          // More detailed error logging
          if (e.toString().contains('profile_image_url')) {
            debugPrint('Note: profile_image_url column issue - migration may be needed');
          }
          if (e.toString().contains('birth_time')) {
            debugPrint('Note: birth_time format issue - migration may be needed');
          }
        }
      }
      
      if (mounted) {
        context.go('/home?firstTime=true');
      }
    } catch (e) {
      debugPrint('Profile save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.fortuneTheme.errorColor,
          )
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSocialLoginBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Keep transparent for bottom sheet overlay
      isDismissible: false),
        enableDrag: false),
        builder: build,
      er: (context) => DraggableScrollableSheet(,
      initialChildSize: 0.8,
      minChildSize: 0.5),
        maxChildSize: 0.95),
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius),
              topRight: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius))),
      child: Column(
                children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(),
                width: context.fortuneTheme.bottomSheetStyles.handleWidth,
                height: context.fortuneTheme.bottomSheetStyles.handleHeight,
                decoration: BoxDecoration(,
      color: context.isDarkMode ? context.fortuneTheme.dividerColor : AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.handleHeight / 2))))
              
              // Content
              Expanded(
                child: SingleChildScrollView(,
      controller: scrollController,
              ),
              padding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
        vertical: context.fortuneTheme.formStyles.inputPadding.horizontal),
      child: Column(
                children: [
                      // Title
                      Text(
                        '거의 다 왔습니다!',
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(,
      fontWeight: FontWeight.w700,
                          ))
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical),
                      
                      // Subtitle
                      Text(
                        '계정을 연결하면 모든 기기에서\n운세를 확인할 수 있습니다'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
                        textAlign: TextAlign.center)
                      
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
                      
                      // Social Login Buttons
                      Column(
                        children: [
                          // Google Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Google');
                            }
                            type: 'google')
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
                          
                          // Apple Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleAppleLogin();
                            }
                            type: 'apple')
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
                          
                          // Kakao Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Kakao');
                            }
                            type: 'kakao')
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
                          
                          // Naver Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleNaverLogin();
                            }
                            type: 'naver')
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
                          
                          // Instagram Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('Instagram');
                            }
                            type: 'instagram')
                          SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
                          
                          // TikTok Login
                          _buildModernSocialButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pop(context);
                              _handleSocialLogin('TikTok');
                            }
                            type: 'tiktok')))
                      
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
                      
                      Divider(height: 1, color: context.fortuneTheme.dividerColor),
                      
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                      
                      // Terms text
                      Text(
                        '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
        height: 1.5),
      textAlign: TextAlign.center)
                      
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                      
                      // Skip button for guests
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Continue as guest
                          _skipAuthentication();
                        }
                        child: Text(
                          '나중에 하기'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.secondaryText,
                          ),
        decoration: TextDecoration.underline)
                          ))))
                      
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.65))))))))))
      )
  }

  Widget _buildModernSocialButton({
    required VoidCallback? onPressed)
    required String type)
  }) {
    final configs = {
      'google': {
        'text': 'Google로 계속하기'
        'assetPath': 'assets/images/social/google.svg'
      }
      'apple': {
        'text': 'Apple로 계속하기',
        'assetPath': 'assets/images/social/apple.svg'
      'kakao': {
        'text': '카카오로 계속하기',
        'assetPath': 'assets/images/social/kakao.svg'
      'naver': {
        'text': '네이버로 계속하기',
        'assetPath': 'assets/images/social/naver.svg'
      'instagram': {
        'text': 'Instagram으로 계속하기',
        'assetPath': 'assets/images/social/instagram.svg'
      'tiktok': {
        'text': 'TikTok으로 계속하기',
        'assetPath': 'assets/images/social/tiktok.svg'
    };

    final config = configs[type]!;

    return SizedBox(
      width: double.infinity,
      height: context.fortuneTheme.formStyles.inputHeight - 8),
              child: ElevatedButton(,
      onPressed: onPressed),
        style: ElevatedButton.styleFrom(,
      backgroundColor: context.isDarkMode ? context.fortuneTheme.cardSurface : AppColors.textPrimaryDark),
        foregroundColor: context.isDarkMode ? context.fortuneTheme.primaryText : AppColors.textPrimary.withValues(alph,
      a: 0.87),
          shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
            side: BorderSide(,
      color: context.fortuneTheme.dividerColor),
        width: context.fortuneTheme.formStyles.inputBorderWidth)
            ))
          elevation: 0),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.center),
        children: [
            SvgPicture.asset(
              config['assetPath'] as String),
        width: context.fortuneTheme.socialSharing.shareIconSize - 4),
              height: context.fortuneTheme.socialSharing.shareIconSize - 4)
            SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.8),
            Text(
              config['text'] as String),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(,
      fontWeight: FontWeight.w600,
                          ))))))))
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    
    try {
      if (provider == 'Google') {
        final response = await _socialAuthService.signInWithGoogle();
        if (response != null && response.user != null && mounted) {
          await _onAuthenticationComplete();
        }
      } else if (provider == 'Kakao') {
        final response = await _socialAuthService.signInWithKakao();
        if (response != null && response.user != null && mounted) {
          await _onAuthenticationComplete();
        }
      } else if (provider == 'Instagram') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instagram 로그인은 현재 준비 중입니다.'))))
      } else if (provider == 'TikTok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TikTok 로그인은 현재 준비 중입니다.'))))
      }
    } catch (e) {
      debugPrint('Social login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.fortuneTheme.errorColor)))
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _socialAuthService.signInWithApple();
      if (response != null && response.user != null && mounted) {
        await _onAuthenticationComplete();
      }
    } catch (e) {
      debugPrint('Apple login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.fortuneTheme.errorColor)))
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _socialAuthService.signInWithNaver();
      if (response != null && response.user != null && mounted) {
        await _onAuthenticationComplete();
      }
    } catch (e) {
      debugPrint('Naver login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('네이버 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.fortuneTheme.errorColor,
          )
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(,
      child: Column(
                children: [
            // Progress bar
            OnboardingProgressBar(
              currentStep: _currentStep,
              ),
              totalSteps: _totalSteps)
            
            // Main content
            Expanded(
              child: PageView(,
      controller: _pageController),
        physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0: Name
                  NameStep(
                    initialName: _name),
        onNameChanged: (name) => setState(() => _name = name),
                    onNext: _nextStep,
                    onShowSocialLogin: _showSocialLoginBottomSheet)
                  
                  // Step 1: Birth info
                  BirthInfoStep(
                    onBirthInfoChanged: (date, time) {
                      setState(() {
                        _birthDate = date;
                        _birthTime = time;
                      });
                    }
                    onNext: _nextStep,
                    onBack: _previousStep)
                  
                  // Step 2: Gender
                  GenderStep(
                    onGenderChanged: (gender) => setState(() => _gender = gender),
                    onNext: _nextStep,
                    onBack: _previousStep)
                  
                  // Step 3: Location
                  LocationStep(
                    onLocationChanged: (region) {
                      setState(() {
                        _region = region;
                      });
                    }
                    onComplete: () {
                      // Show login bottom sheet after location completion
                      _showSocialLoginBottomSheet();
                    }
                    onBack: _previousStep)))))))
      )
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}