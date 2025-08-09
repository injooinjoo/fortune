import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/fortune_constants.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../utils/date_utils.dart';
import 'steps/toss_style_name_step.dart';
import 'steps/toss_style_birth_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  User? _currentUser;
  
  // Form values
  String _name = '';
  DateTime? _birthDate;
  TimeOfDay? _birthTime;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    _currentUser = session?.user;
    
    // Load existing profile if available
    try {
      final existingProfile = await _storageService.getUserProfile();
      if (existingProfile != null) {
        setState(() {
          // Pre-fill name
          _name = existingProfile['name'] ?? 
              _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              _currentUser?.email?.split('@')[0] ??
              '';
          
          // Pre-fill birth date if available
          if (existingProfile['birth_date'] != null) {
            try {
              _birthDate = DateTime.parse(existingProfile['birth_date']);
            } catch (e) {
              debugPrint('Error parsing birth date: $e');
            }
          }
        });
      } else if (_currentUser != null) {
        // No existing profile, just use auth metadata
        setState(() {
          _name = _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              _currentUser?.email?.split('@')[0] ??
              '';
        });
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _name.isNotEmpty) {
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    } else if (_currentStep == 1 && _birthDate != null) {
      // Allow submission even if birth time is not provided (default to 12:00)
      _birthTime ??= const TimeOfDay(hour: 12, minute: 0);
      _handleSubmit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    
    try {
      // 프로필 데이터 준비
      final birthTimeString = _birthTime != null 
        ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
        : '12:00';
        
      final profile = UserProfile(
        id: _currentUser?.id ?? '',
        name: _name,
        email: _currentUser?.email ?? '',
        birthDate: _birthDate!.toIso8601String(),
        birthTime: birthTimeString,
        mbti: null,
        gender: Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(_birthDate!.toIso8601String()),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(_birthDate!.toIso8601String()),
        onboardingCompleted: true,
        subscriptionStatus: SubscriptionStatus.free,
        fortuneCount: 0,
        premiumFortunesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

      // 로컬 스토리지에 저장
      await _storageService.saveUserProfile(profile.toJson());

      // 인증된 사용자의 경우 Supabase에도 저장 시도
      if (_currentUser != null) {
        try {
          await Supabase.instance.client.from('user_profiles').upsert({
            'id': _currentUser!.id,
            'email': _currentUser!.email,
            'name': _name,
            'birth_date': _birthDate!.toIso8601String(),
            'birth_time': birthTimeString,
            'mbti': null,
            'gender': Gender.other.value,
            'onboarding_completed': true,
            'zodiac_sign': profile.zodiacSign,
            'chinese_zodiac': profile.chineseZodiac,
            'updated_at': DateTime.now().toIso8601String()});
          debugPrint('Supabase에 프로필 동기화 완료');
        } catch (e) {
          debugPrint('Supabase 프로필 동기화 오류: $e');
          // Supabase 실패해도 로컬 저장은 성공했으므로 계속 진행
        }
      }
      
      if (mounted) {
        context.go('/home?firstTime=true');
      }
    } catch (e) {
      debugPrint('프로필 저장 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red));
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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Step 1: Name
          TossStyleNameStep(
            initialName: _name,
            onNameChanged: (name) {
              setState(() {
                _name = name;
              });
            },
            onNext: _nextStep,
          ),
          
          // Step 2: Birth Date & Time
          TossStyleBirthStep(
            initialDate: _birthDate,
            initialTime: _birthTime,
            onBirthDateChanged: (date) {
              setState(() {
                _birthDate = date;
              });
            },
            onBirthTimeChanged: (time) {
              setState(() {
                _birthTime = time;
              });
            },
            onNext: _nextStep,
            onBack: _previousStep,
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}