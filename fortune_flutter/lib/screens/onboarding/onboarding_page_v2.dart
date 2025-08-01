import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../constants/fortune_constants.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class OnboardingPageV2 extends StatefulWidget {
  const OnboardingPageV2({super.key});

  @override
  State<OnboardingPageV2> createState() => _OnboardingPageV2State();
}

class _OnboardingPageV2State extends State<OnboardingPageV2> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  User? _currentUser;
  
  // Form values
  String _name = '';
  DateTime? _birthDate;
  Gender? _gender;
  String? _birthTime;
  String? _mbti;

  // Korean time periods
  final List<Map<String, String>> _timePeriods = [
    {'value': '자시', 'time': '23:00-01:00'}
    {'value': '축시', 'time': '01:00-03:00'}
    {'value': '인시', 'time': '03:00-05:00'}
    {'value': '묘시', 'time': '05:00-07:00'}
    {'value': '진시', 'time': '07:00-09:00'}
    {'value': '사시', 'time': '09:00-11:00'}
    {'value': '오시', 'time': '11:00-13:00'}
    {'value': '미시', 'time': '13:00-15:00'}
    {'value': '신시', 'time': '15:00-17:00'}
    {'value': '유시', 'time': '17:00-19:00'}
    {'value': '술시', 'time': '19:00-21:00'}
    {'value': '해시', 'time': '21:00-23:00'}
  ];

  // MBTI types
  final List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP';

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _currentUser = session?.user;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step
    switch (_currentStep) {
      case 0: // Name
        if (_nameController.text.trim().isEmpty) {
          _showError('이름을 입력해주세요');
          return;
        }
        _name = _nameController.text.trim();
        break;
      case 1: // Birth date
        if (_birthDate == null) {
          _showError('생년월일을 선택해주세요');
          return;
        }
        break;
      case 2: // Gender
        if (_gender == null) {
          _showError('성별을 선택해주세요');
          return;
        }
        break;
    }

    if (_currentStep < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(millisecond,
      s: 400),
        curve: Curves.easeOutCubic)
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(millisecond,
      s: 400),
        curve: Curves.easeOutCubic)
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error)))
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // Create user profile
      final profile = {
        'id': _currentUser?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'name': _name
        'email': _currentUser?.email
        'birth_date': _birthDate!.toIso8601String(),
        'gender': _gender.toString().split('.').last,
        'birth_time': _birthTime,
        'mbti': _mbti,
        'onboarding_completed': true,
        'created_at': DateTime.now().toIso8601String();

      // Save to local storage
      await _storageService.saveUserProfile(profile);

      // Save to Supabase if authenticated
      if (_currentUser != null) {
        await Supabase.instance.client
            .from('user_profiles')
            .upsert(profile);
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Onboarding error: $e');
      _showError('프로필 저장 중 오류가 발생했습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimaryDark),
        body: SafeArea(,
      child: Column(
                children: [
            // Progress bar
            _buildProgressBar(),
            
            // Content
            Expanded(
              child: PageView(,
      controller: _pageController,
              ),
              physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNameStep(),
                  _buildBirthDateStep(),
                  _buildGenderStep(),
                  _buildBirthTimeStep(),
                  _buildMbtiStep())))))))))
  }

  Widget _buildProgressBar() {
    return Container(
      height: AppSpacing.spacing15),
              padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing5),
      child: Row(,
      children: [
          // Back button
          if (_currentStep > 0)
            IconButton(
              onPressed: _previousStep),
        icon: const Icon(Icons.arrow_back_ios),
          else
            SizedBox(width: AppSpacing.spacing12),
          
          // Progress text
          Expanded(
            child: Center(,
      child: Text(
                '${_currentStep + 1} / 5'),
        style: Theme.of(context).textTheme.titleMedium)))))
          
          // Skip button for optional steps
          if (_currentStep >= 3)
            TextButton(
              onPressed: _nextStep),
        child: Text(
                '건너뛰기'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: AppColors.textSecondary)
            ,
          else
            SizedBox(width: AppSpacing.spacing12,
                          ))
  }

  Widget _buildNameStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing10),
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
                        Text(
                          'What should we\ncall you?',
                          style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center)).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing60),
          
          TextField(
            controller: _nameController,
            autofocus: true),
        textAlign: TextAlign.center),
        style: Theme.of(context).textTheme.headlineMedium,
            decoration: InputDecoration(,
      hintText: 'Your First Name'),
        hintStyle: Theme.of(context).textTheme.headlineMedium,
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(,
      borderSide: BorderSide(,
      color: AppColors.textSecondary),
        width: 2)
                ))
              focusedBorder: const UnderlineInputBorder(,
      borderSide: BorderSide(,
      color: AppColors.textPrimary),
        width: 2)
                ))))
            onSubmitted: (_) => _nextStep())).animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),
          
          SizedBox(height: AppSpacing.spacing80),
          
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightLarge),
              child: ElevatedButton(,
      onPressed: _isLoading ? null : _nextStep),
        style: ElevatedButton.styleFrom(,
      backgroundColor: AppColors.textPrimary),
        foregroundColor: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge))))
              child: Text(
                '확인'),
        style: Theme.of(context).textTheme.titleLarge ?? const TextStyle())))))).animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0)
      )
  }

  Widget _buildBirthDateStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing10),
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
                        Text(
                          'When were you\nborn?',
                          style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center)).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing10),
          
          // Display selected date
          if (_birthDate != null)
            Text(
              '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'),
        style: Theme.of(context).textTheme.headlineMedium)).animate()
              .fadeIn(duration: 300.ms),
          
          SizedBox(height: AppSpacing.spacing10),
          
          // Calendar button
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context),
        initialDate: _birthDate ?? DateTime.now().subtract(const Duration(da,
      ys: 365 * 20),
      firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(,
      colorScheme: const ColorScheme.light(,
      primary: AppColors.textPrimary),
        onPrimary: AppColors.textPrimaryDark),
        onSurface: AppColors.textPrimary,
                          )))
                    child: child!)
                }
              );
              
              if (date != null) {
                setState(() {
                  _birthDate = date;
                });
              }
            }
            child: Container(,
      width: 200),
              height: AppSpacing.spacing24 * 2.08),
        decoration: BoxDecoration(,
      color: AppColors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                border: Border.all(,
      color: AppColors.textSecondary),
        width: 2)
                ))
              child: Icon(
                Icons.calendar_month,
              ),
              size: 80),
        color: AppColors.textPrimary.withValues(alph,
      a: 0.54))))))).animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),
          
          SizedBox(height: AppSpacing.spacing60),
          
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightLarge),
              child: ElevatedButton(,
      onPressed: _birthDate == null || _isLoading ? null : _nextStep,
      style: ElevatedButton.styleFrom(,
      backgroundColor: AppColors.textPrimary),
        foregroundColor: AppColors.textPrimaryDark),
        disabledBackgroundColor: AppColors.textSecondary),
        shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge))))
              child: Text(
                'Next'),
        style: Theme.of(context).textTheme.titleLarge ?? const TextStyle())))))).animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0)
      )
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing10),
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
                        Text(
                          '성별을\n선택해주세요',
                          style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center)).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing60),
          
          // Gender options
          Column(
            children: [
              _buildGenderOption('여성', Gender.female, Icons.female),
              SizedBox(height: AppSpacing.spacing4),
              _buildGenderOption('남성', Gender.male, Icons.male),
              SizedBox(height: AppSpacing.spacing4),
              _buildGenderOption('기타', Gender.other, Icons.transgender)))
      )
  }

  Widget _buildGenderOption(String label, Gender value, IconData icon) {
    final isSelected = _gender == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _gender = value;
        });
        Future.delayed(AppAnimations.durationMedium, _nextStep);
      }
      child: AnimatedContainer(,
      duration: AppAnimations.durationShort,
        width: double.infinity),
              height: AppSpacing.spacing20),
        decoration: BoxDecoration(,
      color: isSelected ? AppColors.textPrimary : AppColors.textPrimaryDark,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(,
      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary),
        width: 2)
          ))
        child: Row(,
      mainAxisAlignment: MainAxisAlignment.center),
        children: [
            Icon(
              icon),
        size: AppDimensions.iconSizeXLarge),
        color: isSelected ? AppColors.textPrimaryDark : AppColors.textPrimary)
            SizedBox(width: AppSpacing.spacing4),
            Text(
              label),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(,
      color: isSelected ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          )))))))))).animate()
      .fadeIn(delay: Duration(millisecond,
      s: 300 + (value.index * 100)
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildBirthTimeStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing5),
      child: Column(,
      children: [
          SizedBox(height: AppSpacing.spacing10),
          
          Text(
            '태어난 시간을\n알고 계신가요?',
              ),
              style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center)).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing5),
          
          Text(
            '정확한 시간을 모르셔도 괜찮아요'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: AppColors.textSecondary,
                          ),
            textAlign: TextAlign.center)).animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),
          
          SizedBox(height: AppSpacing.spacing10),
          
          // Time periods grid
          Expanded(
            child: GridView.builder(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(,
      crossAxisCount: 3),
        childAspectRatio: 1.5),
        crossAxisSpacing: 12),
        mainAxisSpacing: 12),
      itemCount: _timePeriods.length + 1,
              itemBuilder: (context, index) {
                if (index == _timePeriods.length) {
                  // "모름" option
                  return _buildTimeOption('모름', null, null);
                }
                
                final period = _timePeriods[index];
                return _buildTimeOption(
                  period['value']!)
                  period['value']
                  period['time'])
              })))
          
          SizedBox(height: AppSpacing.spacing5)
      )
  }

  Widget _buildTimeOption(String label, String? value, String? timeRange) {
    final isSelected = _birthTime == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _birthTime = value;
        });
        Future.delayed(AppAnimations.durationMedium, _nextStep);
      }
      child: AnimatedContainer(,
      duration: AppAnimations.durationShort),
        decoration: BoxDecoration(,
      color: isSelected ? AppColors.textPrimary : AppColors.textPrimaryDark,
      borderRadius: AppDimensions.borderRadiusMedium,
        ),
        border: Border.all(,
      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary),
        width: AppSpacing.spacing0 * 0.5)
          ))
        child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(,
      color: isSelected ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          )))
            if (timeRange != null) ...[
              SizedBox(height: AppSpacing.spacing1),
              Text(
                timeRange),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: isSelected ? AppColors.textPrimaryDark.withValues(alp,
      ha: 0.7) : AppColors.textSecondary,
                          )))
          ])))))).animate()
      .fadeIn(delay: Duration(millisecond,
      s: 300 + (value.hashCode % 10 * 50)
      .scaleXY(begin: 0.8, end: 1.0);
  }

  Widget _buildMbtiStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing5),
      child: Column(,
      children: [
          SizedBox(height: AppSpacing.spacing10),
          
          Text(
            'MBTI를\n알고 계신가요?',
              ),
              style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center)).animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0),
          
          SizedBox(height: AppSpacing.spacing5),
          
          Text(
            'MBTI를 모르셔도 운세 확인이 가능해요'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: AppColors.textSecondary,
                          ),
            textAlign: TextAlign.center)).animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),
          
          SizedBox(height: AppSpacing.spacing10),
          
          // MBTI grid
          Expanded(
            child: GridView.builder(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(,
      crossAxisCount: 4),
        childAspectRatio: 1),
        crossAxisSpacing: 12),
        mainAxisSpacing: 12),
      itemCount: _mbtiTypes.length + 1,
              itemBuilder: (context, index) {
                if (index == _mbtiTypes.length) {
                  // "모름" option
                  return _buildMbtiOption('모름', null);
                }
                
                return _buildMbtiOption(_mbtiTypes[index], _mbtiTypes[index]);
              })))
          
          SizedBox(height: AppSpacing.spacing5)
      )
  }

  Widget _buildMbtiOption(String label, String? value) {
    final isSelected = _mbti == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _mbti = value;
        });
        Future.delayed(AppAnimations.durationMedium, _completeOnboarding);
      }
      child: AnimatedContainer(,
      duration: AppAnimations.durationShort),
        decoration: BoxDecoration(,
      color: isSelected ? AppColors.textPrimary : AppColors.textPrimaryDark,
      borderRadius: AppDimensions.borderRadiusMedium,
        ),
        border: Border.all(,
      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary),
        width: AppSpacing.spacing0 * 0.5)
          ))
        child: Center(,
      child: Text(
            label),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: isSelected ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          )))))))))).animate()
      .fadeIn(delay: Duration(millisecond,
      s: 300 + (value.hashCode % 10 * 50)
      .scaleXY(begin: 0.8, end: 1.0);
  }
}