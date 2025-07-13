import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../models/user_profile.dart';
import '../../constants/fortune_constants.dart';
import '../../utils/date_utils.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'steps/social_login_step.dart';
import 'steps/name_step.dart';
import 'steps/birth_info_step.dart';
import 'steps/gender_step.dart';
import 'steps/mbti_step.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();
  
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isLoading = false;
  User? _currentUser;
  bool _isAuthenticated = false;
  
  // Form values
  String _name = '';
  DateTime? _birthDate;
  String? _birthTime;
  Gender? _gender;
  String? _mbti;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    _currentUser = session?.user;
    
    setState(() {
      _isAuthenticated = _currentUser != null;
    });
    
    // If already authenticated, skip to name step
    if (_isAuthenticated) {
      setState(() {
        _currentStep = 1;
        _name = _currentUser?.userMetadata?['full_name'] ??
            _currentUser?.userMetadata?['name'] ??
            _currentUser?.email?.split('@')[0] ??
            '';
      });
      _pageController.jumpToPage(1);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    // Skip social login step when going back
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onAuthenticationComplete() {
    // Authentication successful, update user and move to name step
    _initializeUser();
  }

  void _skipAuthentication() {
    // Skip to name step as guest
    setState(() {
      _currentStep = 1;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // Prepare profile data
      final profile = UserProfile(
        id: _currentUser?.id ?? '',
        name: _name,
        email: _currentUser?.email ?? '',
        birthDate: _birthDate!.toIso8601String(),
        birthTime: _birthTime,
        mbti: _mbti,
        gender: _gender ?? Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(_birthDate!.toIso8601String()),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(_birthDate!.toIso8601String()),
        onboardingCompleted: true,
        subscriptionStatus: SubscriptionStatus.free,
        fortuneCount: 0,
        premiumFortunesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _storageService.saveUserProfile(profile.toJson());

      // Save to Supabase if authenticated
      if (_currentUser != null) {
        try {
          await Supabase.instance.client.from('user_profiles').upsert({
            'id': _currentUser!.id,
            'email': _currentUser!.email,
            'name': _name,
            'birth_date': _birthDate!.toIso8601String(),
            'birth_time': _birthTime,
            'mbti': _mbti,
            'gender': _gender?.value,
            'onboarding_completed': true,
            'zodiac_sign': profile.zodiacSign,
            'chinese_zodiac': profile.chineseZodiac,
            'updated_at': DateTime.now().toIso8601String(),
          });
          debugPrint('Profile synced to Supabase');
        } catch (e) {
          debugPrint('Supabase sync failed: $e');
        }
      }
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Profile save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            OnboardingProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
            
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0: Social Login
                  SocialLoginStep(
                    onNext: _onAuthenticationComplete,
                    onSkip: _skipAuthentication,
                  ),
                  
                  // Step 1: Name
                  NameStep(
                    initialName: _name,
                    onNameChanged: (name) => setState(() => _name = name),
                    onNext: _nextStep,
                  ),
                  
                  // Step 2: Birth info
                  BirthInfoStep(
                    onBirthInfoChanged: (date, time) {
                      setState(() {
                        _birthDate = date;
                        _birthTime = time;
                      });
                    },
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  
                  // Step 3: Gender
                  GenderStep(
                    onGenderChanged: (gender) => setState(() => _gender = gender),
                    onNext: _nextStep,
                    onBack: _previousStep,
                  ),
                  
                  // Step 4: MBTI
                  MbtiStep(
                    onMbtiChanged: (mbti) => setState(() => _mbti = mbti),
                    onComplete: _completeOnboarding,
                    onBack: _previousStep,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}