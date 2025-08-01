import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../models/user_profile.dart';
import '../../constants/fortune_constants.dart';
import '../../utils/date_utils.dart';
import '../../core/utils/profile_validation.dart';
import '../../shared/components/custom_calendar_date_picker.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class EnhancedOnboardingFlow extends StatefulWidget {
  const EnhancedOnboardingFlow({super.key});

  @override
  State<EnhancedOnboardingFlow> createState() => _EnhancedOnboardingFlowState();
}

class _EnhancedOnboardingFlowState extends State<EnhancedOnboardingFlow> {
  final StorageService _storageService = StorageService();
  User? _currentUser;
  
  // Form values collected from user
  String _name = '';
  DateTime? _birthDate;
  String? _birthTime;
  Gender? _gender;
  String? _mbti;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    // Start the onboarding flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOnboardingFlow();
    });
  }

  Future<void> _initializeUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    _currentUser = session?.user;
    
    // Load any existing partial profile data
    try {
      final existingProfile = await _storageService.getUserProfile();
      if (existingProfile != null) {
        setState(() {
          _name = existingProfile['name'] ?? 
              _currentUser?.userMetadata?['full_name'] ??
              _currentUser?.userMetadata?['name'] ??
              '';
          
          if (existingProfile['birth_date'] != null) {
            try {
              _birthDate = DateTime.parse(existingProfile['birth_date']);
            } catch (e) {
              debugPrint('Error parsing existing birth date: $e');
            }
          }
          
          _birthTime = existingProfile['birth_time'];
          if (existingProfile['gender'] != null) {
            _gender = Gender.values.firstWhere(
              (g) => g.value == existingProfile['gender']
              orElse: () => Gender.other
            );
          }
          _mbti = existingProfile['mbti'];
        });
      }
    } catch (e) {
      debugPrint('Error loading existing profile: $e');
    }
  }

  Future<void> _startOnboardingFlow() async {
    // Check what information is missing
    final missingFields = await _getMissingFields();
    
    if (missingFields.isEmpty) {
      // All information is complete, go to home
      if (mounted) context.go('/home');
      return;
    }
    
    // Start collecting missing information
    for (final field in missingFields) {
      final shouldContinue = await _collectField(field);
      if (!shouldContinue) {
        // User cancelled or error occurred
        return;
      }
    }
    
    // Save complete profile
    await _saveProfile();
  }

  Future<List<String>> _getMissingFields() async {
    final fields = <String>[];
    
    if (_name.isEmpty) fields.add('name');
    if (_birthDate == null) fields.add('birthdate');
    if (_birthTime == null) fields.add('birthtime');
    if (_gender == null) fields.add('gender');
    if (_mbti == null) fields.add('mbti');
    
    return fields;
  }

  Future<bool> _collectField(String field) async {
    switch (field) {
      case 'name':
        return await _showNameBottomSheet();
      case 'birthdate':
        return await _showBirthdateBottomSheet();
      case 'birthtime':
        return await _showBirthTimeBottomSheet();
      case 'gender':
        return await _showGenderBottomSheet();
      case 'mbti':
        return await _showMbtiBottomSheet();
      default:
        return true;
    }
  }

  Future<bool> _showNameBottomSheet() async {
    final TextEditingController nameController = TextEditingController(text: _name);
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(,
      padding: EdgeInsets.only(bott,
      om: MediaQuery.of(context).viewInsets.bottom),
        child: Container(,
      decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(25),
              topRight: Radius.circular(25))),
      padding: AppSpacing.paddingAll24,
          child: Column(,
      mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(,
      width: 40,
        ),
        height: AppSpacing.spacing1,
              ),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall))))))
              SizedBox(height: AppSpacing.spacing6),
              
              // Title
              Text(
                '이름을 알려주세요'),
        style: Theme.of(context).textTheme.headlineLarge)
              SizedBox(height: AppSpacing.spacing6),
              
              // Name input
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(,
      hintText: '이름',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(,
      borderRadius: AppDimensions.borderRadiusMedium),
        borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
      style: Theme.of(context).textTheme.titleMedium)
              SizedBox(height: AppSpacing.spacing6),
              
              // Done button
              SizedBox(
                width: double.infinity),
              height: 52),
        child: ElevatedButton(,
      onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('이름을 입력해주세요')))
                    }
                  }
                  style: ElevatedButton.styleFrom(,
      backgroundColor: AppColors.textPrimary),
        foregroundColor: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
      elevation: 0),
      child: Text(
                    '확인'),
        style: Theme.of(context).textTheme.titleMedium)))))
              SizedBox(height: AppSpacing.spacing4))))
      )
    
    if (result == true) {
      setState(() {
        _name = nameController.text.trim();
      });
    }
    
    return result ?? false;
  }

  Future<bool> _showBirthdateBottomSheet() async {
    DateTime selectedDate = _birthDate ?? DateTime(1980, 1, 1);
    DateTime tempSelectedDate = selectedDate;
    
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(,
      height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(25),
            topRight: Radius.circular(25))),
      child: Column(
                children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
              child: Row(,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('취소', style: Theme.of(context).textTheme.titleMedium)
                  Text(
                    '생년월일',
              ),
              style: Theme.of(context).textTheme.titleLarge)
                  SizedBox(width: AppSpacing.spacing12), // Balance the header
                ])))
            
            Divider(height: 1),
            
            // Custom calendar date picker
            Expanded(
              child: CustomCalendarDatePicker(,
      initialDate: tempSelectedDate),
        firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  tempSelectedDate = date;
                }
                onConfirm: () {
                  selectedDate = tempSelectedDate;
                  Navigator.pop(context, true);
                })))))
      )
    
    if (result == true) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
    
    return result ?? false;
  }

  Future<bool> _showBirthTimeBottomSheet() async {
    final List<String> timeOptions = [
      '모름',
      '자시 (23:00 - 01:00)',
      '축시 (01:00 - 03:00)',
      '인시 (03:00 - 05:00)',
      '묘시 (05:00 - 07:00)',
      '진시 (07:00 - 09:00)',
      '사시 (09:00 - 11:00)',
      '오시 (11:00 - 13:00)',
      '미시 (13:00 - 15:00)',
      '신시 (15:00 - 17:00)',
      '유시 (17:00 - 19:00)',
      '술시 (19:00 - 21:00)',
      '해시 (21:00 - 23:00)';
    
    String? selectedTime = _birthTime;
    
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(,
      height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(25),
            topRight: Radius.circular(25))),
      padding: AppSpacing.paddingAll24,
        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(,
      width: 40,
        ),
        height: AppSpacing.spacing1,
              ),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall))))))
            SizedBox(height: AppSpacing.spacing6),
            
            // Title
            Text(
              '태어난 시간 (사주)',
              style: Theme.of(context).textTheme.headlineLarge)
            SizedBox(height: AppSpacing.spacing2),
            Text(
              '정확한 시간을 모르시면 "모름"을 선택해주세요'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: AppColors.textSecondary,
                          ))
            SizedBox(height: AppSpacing.spacing6),
            
            // Time options
            Expanded(
              child: ListView.builder(,
      itemCount: timeOptions.length),
        itemBuilder: (context, index) {
                  final option = timeOptions[index];
                  final isSelected = selectedTime == option;
                  
                  return Container(
                    margin: EdgeInsets.only(botto,
      m: AppSpacing.xSmall),
                    child: InkWell(,
      onTap: () {
                        selectedTime = option;
                        Navigator.pop(context, true);
                      }
                      borderRadius: AppDimensions.borderRadiusMedium,
                      child: Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing4, vertical: AppSpacing.spacing4),
                        decoration: BoxDecoration(,
      color: isSelected ? AppColors.textPrimary : AppColors.surface,
      borderRadius: AppDimensions.borderRadiusMedium),
      child: Text(
                          option,
        ),
        style: Theme.of(context).textTheme.labelLarge)))))))
                })))))
      )
    
    if (result == true && selectedTime != null) {
      setState(() {
        _birthTime = selectedTime == '모름' ? null : selectedTime;
      });
    }
    
    return result ?? false;
  }

  Future<bool> _showGenderBottomSheet() async {
    Gender? selectedGender = _gender;
    
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(,
      decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(25),
            topRight: Radius.circular(25))),
      padding: AppSpacing.paddingAll24,
        child: Column(,
      mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(,
      width: 40,
        ),
        height: AppSpacing.spacing1,
              ),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall))))))
            SizedBox(height: AppSpacing.spacing6),
            
            // Title
            Text(
              '성별'),
        style: Theme.of(context).textTheme.headlineLarge)
            SizedBox(height: AppSpacing.spacing6),
            
            // Gender buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(,
      onTap: () {
                      selectedGender = Gender.female;
                      Navigator.pop(context, true);
                    }
                    borderRadius: AppDimensions.borderRadiusMedium,
                    child: Container(,
      padding: AppSpacing.paddingVertical16),
        decoration: BoxDecoration(,
      color: selectedGender == Gender.female 
                            ? AppColors.textPrimary 
                            : AppColors.surface
                        borderRadius: AppDimensions.borderRadiusMedium),
      child: Center(
                        child: Text(
                          '여',
        ),
        style: Theme.of(context).textTheme.titleLarge)))))))))
                SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: InkWell(,
      onTap: () {
                      selectedGender = Gender.male;
                      Navigator.pop(context, true);
                    }
                    borderRadius: AppDimensions.borderRadiusMedium,
                    child: Container(,
      padding: AppSpacing.paddingVertical16),
        decoration: BoxDecoration(,
      color: selectedGender == Gender.male 
                            ? AppColors.textPrimary 
                            : AppColors.surface
                        borderRadius: AppDimensions.borderRadiusMedium),
      child: Center(
                        child: Text(
                          '남',
        ),
        style: Theme.of(context).textTheme.titleLarge)))))))))))
            SizedBox(height: AppSpacing.spacing6))
      )
    
    if (result == true && selectedGender != null) {
      setState(() {
        _gender = selectedGender;
      });
    }
    
    return result ?? false;
  }

  Future<bool> _showMbtiBottomSheet() async {
    String mbtiResult = _mbti ?? '';
    Map<String, String> selections = {
      'EI': ''
      'SN': ''
      'FT': '',
      'JP': '';
    
    // Parse existing MBTI if available
    if (mbtiResult.length == 4) {
      selections['EI'] = mbtiResult[0];
      selections['SN'] = mbtiResult[1];
      selections['FT'] = mbtiResult[2];
      selections['JP'] = mbtiResult[3];
    }
    
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => StatefulBuilder(,
      builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(,
      color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(25),
              topRight: Radius.circular(25))),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        ),
        children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(to,
      p: AppSpacing.small),
                child: Center(,
      child: Container(,
      width: 40,
              ),
              height: AppSpacing.spacing1),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall))))))))
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(,
      padding: AppSpacing.paddingAll24),
        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                      // Title
                      Text(
                        'MBTI'),
        style: Theme.of(context).textTheme.headlineLarge)
                      SizedBox(height: AppSpacing.spacing2),
                      Text(
                        '본인의 MBTI 유형을 선택해주세요'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: AppColors.textSecondary,
                          ))
                      SizedBox(height: AppSpacing.spacing6),
                      
                      // MBTI selections
                      _buildMbtiRow('EI', 'E', 'I', '외향형', '내향형', selections, setModalState),
                      SizedBox(height: AppSpacing.spacing4),
                      _buildMbtiRow('SN', 'S', 'N', '감각형', '직관형', selections, setModalState),
                      SizedBox(height: AppSpacing.spacing4),
                      _buildMbtiRow('FT', 'F', 'T', '감정형', '사고형', selections, setModalState),
                      SizedBox(height: AppSpacing.spacing4),
                      _buildMbtiRow('JP', 'J', 'P', '판단형', '인식형', selections, setModalState),
                      
                      SizedBox(height: AppSpacing.spacing6),
                      
                      // Result display
                      Container(
                        padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
                        decoration: BoxDecoration(,
      color: AppColors.surface,
        ),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.center),
        children: [
                        Text(
                          'MBTI: ',
                          style: Theme.of(context).textTheme.labelLarge)
                            Text(
                              selections.values.join('').isEmpty 
                                  ? '----' 
                                  : selections.values.join(''),
                              style: Theme.of(context).textTheme.titleLarge)))))))))))
              
              // Bottom button with safe area
              Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: SafeArea(,
      top: false,
                  child: SizedBox(,
      width: double.infinity),
              height: 52),
        child: ElevatedButton(,
      onPressed: selections.values.where((v) => v.isNotEmpty).length == 4
                          ? () {
                              mbtiResult = selections.values.join('');
                              Navigator.pop(context, true);
                            }
                          : null
                      style: ElevatedButton.styleFrom(,
      backgroundColor: AppColors.textPrimary),
        foregroundColor: AppColors.textPrimaryDark),
        disabledBackgroundColor: AppColors.textSecondary),
        disabledForegroundColor: AppColors.textSecondary),
        shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
      elevation: 0),
      child: Text(
                        '확인'),
        style: Theme.of(context).textTheme.titleMedium)))))))))))))
      )
    
    if (result == true && mbtiResult.length == 4) {
      setState(() {
        _mbti = mbtiResult;
      });
    }
    
    return result ?? false;
  }

  Widget _buildMbtiRow(
    String key,
    String option1,
    String option2,
    String label1,
    String label2)
    Map<String, String> selections)
    StateSetter setModalState)
  ) {
    return Row(
      children: [
        Expanded(
          child: InkWell(,
      onTap: () {
              setModalState(() {
                selections[key] = option1;
              });
            }
            borderRadius: AppDimensions.borderRadiusMedium,
            child: Container(,
      padding: AppSpacing.paddingVertical16),
        decoration: BoxDecoration(,
      color: selections[key] == option1 
                    ? AppColors.textPrimary 
                    : AppColors.surface
                borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(
                children: [
                  Text(
                    option1,
        ),
        style: Theme.of(context).textTheme.headlineMedium)
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    label1,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: selections[key] == option1 
                          ? AppColors.textPrimaryDark.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                          )))))))))))
        SizedBox(width: AppSpacing.spacing3),
        Expanded(
          child: InkWell(,
      onTap: () {
              setModalState(() {
                selections[key] = option2;
              });
            }
            borderRadius: AppDimensions.borderRadiusMedium,
            child: Container(,
      padding: AppSpacing.paddingVertical16),
        decoration: BoxDecoration(,
      color: selections[key] == option2 
                    ? AppColors.textPrimary 
                    : AppColors.surface
                borderRadius: AppDimensions.borderRadiusMedium),
      child: Column(
                children: [
                  Text(
                    option2,
        ),
        style: Theme.of(context).textTheme.headlineMedium)
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    label2,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: selections[key] == option2 
                          ? AppColors.textPrimaryDark.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                          )))))))))))))
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Prepare profile data
      final profile = UserProfile(
        id: _currentUser?.id ?? ''),
        name: _name,
      email: _currentUser?.email ?? ''),
        birthDate: _birthDate!.toIso8601String(),
        birthTime: _birthTime,
        mbti: _mbti,
        gender: _gender ?? Gender.other,
        zodiacSign: FortuneDateUtils.getZodiacSign(_birthDate!.toIso8601String(),
      chineseZodiac: FortuneDateUtils.getChineseZodiac(
        _birthDate!.toIso8601String(
      ),
      onboardingCompleted: true,
        subscriptionStatus: SubscriptionStatus.free,
        fortuneCount: 0,
        premiumFortunesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now())

      // Save to local storage
      await _storageService.saveUserProfile(profile.toJson();

      // Save to Supabase if authenticated
      if (_currentUser != null) {
        try {
          await Supabase.instance.client.from('user_profiles').upsert({
            'id': _currentUser!.id)
            'email': _currentUser!.email)
            'name': _name)
            'birth_date': _birthDate!.toIso8601String(),
            'birth_time': _birthTime,
            'mbti': _mbti,
            'gender': _gender?.value,
            'onboarding_completed': true
            'zodiac_sign': profile.zodiacSign
            'chinese_zodiac': profile.chineseZodiac,
            'updated_at': DateTime.now().toIso8601String()
          debugPrint('Profile synced to Supabase');
        } catch (e) {
          debugPrint('Supabase sync failed: $e');
        }
      }
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필이 완성되었습니다!'),
            backgroundColor: AppColors.success)))
        
        // Navigate to home
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Profile save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: AppColors.error)))
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
      backgroundColor: AppColors.textPrimaryDark),
        body: Center(,
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.spacing4),
            Text(
              '정보를 수집하고 있습니다...'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      color: AppColors.textSecondary,
                          ))))
      )
  }
}