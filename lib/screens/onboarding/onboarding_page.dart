import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/fortune_constants.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../utils/date_utils.dart';
import '../../core/theme/toss_design_system.dart';
import 'steps/toss_style_name_step.dart';
import 'steps/toss_style_birth_step.dart';

class OnboardingPage extends StatefulWidget {
  final bool isPartialCompletion;
  
  const OnboardingPage({
    super.key,
    this.isPartialCompletion = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();

  int _currentStep = 0;
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
      // First try to get profile from database for authenticated users
      Map<String, dynamic>? existingProfile;
      
      if (_currentUser != null) {
        try {
          final dbProfile = await Supabase.instance.client
              .from('user_profiles')
              .select()
              .eq('id', _currentUser!.id)
              .maybeSingle();
          
          if (dbProfile != null) {
            existingProfile = dbProfile;
          }
        } catch (e) {
          debugPrint('Error loading profile from database: $e');
        }
      }
      
      // Fall back to local storage if no database profile
      existingProfile ??= await _storageService.getUserProfile();
      
      if (existingProfile != null) {
        setState(() {
          // Pre-fill name
          // Kakao 사용자의 경우 email.split('@')[0]를 사용하지 않음
          String defaultName = '';
          if (_currentUser?.email != null && 
              !_currentUser!.email!.contains('kakao_')) {
            defaultName = _currentUser!.email!.split('@')[0];
          }
          
          _name = existingProfile!['name'] ?? 
              _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              defaultName;
          
          // Pre-fill birth date if available
          if (existingProfile['birth_date'] != null) {
            try {
              _birthDate = DateTime.parse(existingProfile['birth_date']);
            } catch (e) {
              debugPrint('Error parsing birth date: $e');
            }
          }
          
          // Pre-fill birth time if available
          if (existingProfile['birth_time'] != null) {
            try {
              final timeStr = existingProfile['birth_time'];
              final parts = timeStr.split(':');
              if (parts.length >= 2) {
                _birthTime = TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                );
              }
            } catch (e) {
              debugPrint('Error parsing birth time: $e');
            }
          }
        });
      } else if (_currentUser != null) {
        // No existing profile, just use auth metadata
        setState(() {
          // Kakao 사용자의 경우 email.split('@')[0]를 사용하지 않음
          String defaultName = '';
          if (_currentUser?.email != null && 
              !_currentUser!.email!.contains('kakao_')) {
            defaultName = _currentUser!.email!.split('@')[0];
          }
          
          _name = _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              defaultName;
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
          
          // 사주 계산 API 호출 (계정당 1회만)
          try {
            debugPrint('🔮 사주 계산 API 호출 중...');
            final sajuResponse = await Supabase.instance.client.functions.invoke(
              'calculate-saju',
              body: {
                'birthDate': _birthDate!.toIso8601String().split('T')[0],
                'birthTime': birthTimeString,
                'isLunar': false,
                'timezone': 'Asia/Seoul'
              },
            ).timeout(
              const Duration(seconds: 45),
              onTimeout: () {
                debugPrint('⏱️ 사주 계산 시간 초과');
                throw Exception('사주 계산 시간 초과 (45초)');
              },
            );
            
            debugPrint('✅ 사주 계산 완료: ${sajuResponse.status}');
            if (sajuResponse.status == 200) {
              final sajuData = sajuResponse.data;
              if (sajuData['success'] == true) {
                debugPrint('✅ 사주 데이터 저장 성공');
                // 사주 계산 플래그 업데이트
                await Supabase.instance.client.from('user_profiles').update({
                  'saju_calculated': true,
                  'updated_at': DateTime.now().toIso8601String()
                }).eq('id', _currentUser!.id);
                debugPrint('✅ 사주 계산 플래그 업데이트 완료');
              } else {
                debugPrint('⚠️ 사주 계산 응답 오류: ${sajuData['error']}');
              }
            }
          } catch (e) {
            debugPrint('⚠️ 사주 계산 오류 (무시하고 계속 진행): $e');
            // 사주 계산 실패해도 온보딩은 완료되도록 함
          }
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
            backgroundColor: TossDesignSystem.errorRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.white,
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