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
  final TextEditingController _nameController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  int _currentStep = 1;
  bool _isLoading = false;
  User? _currentUser;
  
  // Form values
  String _birthYear = '';
  String _birthMonth = '';
  String _birthDay = '';
  String? _birthTimePeriod;
  String? _mbti;
  Gender? _gender;

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
          _nameController.text = existingProfile['name'] ?? 
              _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              _currentUser?.email?.split('@')[0] ??
              '';
          
          // Pre-fill birth date if available
          if (existingProfile['birth_date'] != null) {
            try {
              final birthDate = DateTime.parse(existingProfile['birth_date']);
              _birthYear = birthDate.year.toString();
              _birthMonth = birthDate.month.toString();
              _birthDay = birthDate.day.toString();
            } catch (e) {
              debugPrint('Error parsing birth date: $e');
            }
          }
          
          // Pre-fill other fields
          _birthTimePeriod = existingProfile['birth_time'];
          _mbti = existingProfile['mbti'];
          if (existingProfile['gender'] != null) {
            _gender = Gender.values.firstWhere(
              (g) => g.value == existingProfile['gender'],
              orElse: () => Gender.other);
          }
        });
      } else if (_currentUser != null) {
        // No existing profile, just use auth metadata
        setState(() {
          final userName = _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              _currentUser?.email?.split('@')[0] ??
              '';
          _nameController.text = userName;
        });
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
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
      // 한국식 날짜를 ISO 형식으로 변환
      final isoDate = FortuneDateUtils.koreanToIsoDate(
        _birthYear,
        _birthMonth,
        _birthDay);
      
      // 프로필 데이터 준비
      final profile = UserProfile(
        id: _currentUser?.id ?? '',
        name: _nameController.text,
        email: _currentUser?.email ?? '',
        birthDate: isoDate,
        birthTime: _birthTimePeriod,
        mbti: _mbti,
        gender: _gender ?? Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(isoDate),
        chineseZodiac: FortuneDateUtils.getChineseZodiac(isoDate),
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
            'name': _nameController.text,
            'birth_date': isoDate,
            'birth_time': _birthTimePeriod,
            'mbti': _mbti,
            'gender': _gender?.value,
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
  
  Future<void> _skipOnboarding() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 설정 건너뛰기'),
        content: const Text('나중에 프로필을 완성하면 더 정확한 운세를 받을 수 있습니다. 지금 건너뛰시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Save minimal profile data with onboarding marked as skipped
              final minimalProfile = {
                'id': _currentUser?.id ?? '',
                'email': _currentUser?.email ?? '',
                'name': _nameController.text.isNotEmpty ? _nameController.text : '사용자',
                'onboarding_completed': false,
                'onboarding_skipped': true,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String()};
              
              await _storageService.saveUserProfile(minimalProfile);
              
              if (mounted) {
                context.go('/home');
              }
            },
            child: const Text('건너뛰기')]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100])),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 진행률 표시 및 Skip 버튼
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _currentStep / 3,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            '건너뛰기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor)))]),
                    const SizedBox(height: 8),
                    Text(
                      '$_currentStep / 3 단계',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600])]),
              
              // 메인 콘텐츠
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))]),
                  child: Column(
                    children: [
                      // 뒤로가기 버튼
                      if (_currentStep > 1)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _previousStep,
                            icon: const Icon(Icons.arrow_back)),
                      
                      // 페이지 뷰
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Step 1: 기본 정보
                            OnboardingStepOne(
                              nameController: _nameController,
                              birthYear: _birthYear,
                              birthMonth: _birthMonth,
                              birthDay: _birthDay,
                              birthTimePeriod: _birthTimePeriod,
                              onNameChanged: (value) {},
                              onBirthYearChanged: (value) {
                                setState(() {
                                  _birthYear = value;
                                  // 년도가 변경되면 일 선택을 초기화
                                  if (_birthDay.isNotEmpty) {
                                    final maxDays = FortuneDateUtils.getDayOptions(
                                      int.parse(value),
                                      _birthMonth.isNotEmpty ? int.parse(_birthMonth) : null).length;
                                    if (int.parse(_birthDay) > maxDays) {
                                      _birthDay = '';
                                    }
                                  }
                                });
                              },
                              onBirthMonthChanged: (value) {
                                setState(() {
                                  _birthMonth = value;
                                  // 월이 변경되면 일 선택을 초기화
                                  if (_birthDay.isNotEmpty && _birthYear.isNotEmpty) {
                                    final maxDays = FortuneDateUtils.getDayOptions(
                                      int.parse(_birthYear),
                                      int.parse(value)).length;
                                    if (int.parse(_birthDay) > maxDays) {
                                      _birthDay = '';
                                    }
                                  }
                                });
                              },
                              onBirthDayChanged: (value) {
                                setState(() => _birthDay = value);
                              },
                              onBirthTimePeriodChanged: (value) {
                                setState(() => _birthTimePeriod = value);
                              },
                              onNext: _nextStep),
                            
                            // Step 2: MBTI
                            OnboardingStepTwo(
                              mbti: _mbti,
                              onMbtiChanged: (value) {
                                setState(() => _mbti = value);
                              },
                              onNext: _nextStep),
                            
                            // Step 3: 성별
                            OnboardingStepThree(
                              gender: _gender,
                              onGenderChanged: (value) {
                                setState(() => _gender = value);
                              },
                              onSubmit: _handleSubmit,
                              isLoading: _isLoading)])]))])));
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}