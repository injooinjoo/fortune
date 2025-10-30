import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/toss_design_system.dart';
import '../../services/phone_auth_service.dart';
import '../onboarding/steps/phone_step.dart';
import '../onboarding/steps/phone_verification_step.dart';
import '../../core/theme/typography_unified.dart';

class PhoneManagementScreen extends ConsumerStatefulWidget {
  const PhoneManagementScreen({super.key});

  @override
  ConsumerState<PhoneManagementScreen> createState() => _PhoneManagementScreenState();
}

class _PhoneManagementScreenState extends ConsumerState<PhoneManagementScreen> {
  final supabase = Supabase.instance.client;
  final PhoneAuthService _phoneAuthService = PhoneAuthService();

  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  String _phoneNumber = '';
  String _countryCode = 'KR';
  bool _showPhoneInput = false;
  bool _showVerification = false;

  // TOSS Design System Helper Methods
  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.gray50;
  }

  Color _getCardColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      final profileResponse = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      setState(() {
        userProfile = profileResponse;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  String _formatDisplayPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '등록된 전화번호가 없습니다';
    
    // Hide middle digits for privacy
    if (phone.length >= 10) {
      final start = phone.substring(0, phone.length - 7);
      final end = phone.substring(phone.length - 4);
      return '$start****$end';
    }
    return phone;
  }
  
  @override
  Widget build(BuildContext context) {
    final hasPhone = userProfile?['phone'] != null && 
                     userProfile!['phone'].toString().isNotEmpty;
    
    if (_showPhoneInput) {
      return PhoneStep(
        initialPhone: _phoneNumber,
        initialCountryCode: _countryCode,
        onPhoneChanged: (phone, countryCode) {
          setState(() {
            _phoneNumber = phone;
            _countryCode = countryCode;
          });
        },
        onNext: () async {
          try {
            await _phoneAuthService.sendOTP(
              phoneNumber: _phoneNumber,
              countryCode: _countryCode,
            );
            setState(() {
              _showPhoneInput = false;
              _showVerification = true;
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
        },
      );
    }
    
    if (_showVerification) {
      return PhoneVerificationStep(
        phoneNumber: _phoneNumber,
        countryCode: _countryCode,
        onVerify: (otpCode) async {
          try {
            await _phoneAuthService.verifyOTP(
              phoneNumber: _phoneNumber,
              countryCode: _countryCode,
              otpCode: otpCode);
            
            // Update profile with new phone
            final user = supabase.auth.currentUser;
            if (user != null) {
              await _phoneAuthService.updateProfilePhone(
                userId: user.id,
                phoneNumber: _phoneNumber,
                countryCode: _countryCode);
            }
            
            setState(() {
              _showVerification = false;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('전화번호가 성공적으로 변경되었습니다'),
                  backgroundColor: TossDesignSystem.successGreen,
                ),
              );
              context.pop();
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
        },
        onResend: () async {
          try {
            await _phoneAuthService.sendOTP(
              phoneNumber: _phoneNumber,
              countryCode: _countryCode,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('인증번호가 재발송되었습니다'),
                backgroundColor: TossDesignSystem.successGreen,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
        },
        onBack: () {
          setState(() {
            _showVerification = false;
            _showPhoneInput = true;
          });
        },
      );
    }
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '전화번호 관리',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    margin: const EdgeInsets.all(TossDesignSystem.marginHorizontal),
                    padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TossDesignSystem.tossBlue,
                          size: 22,
                        ),
                        const SizedBox(width: TossDesignSystem.spacingM),
                        Expanded(
                          child: Text(
                            '전화번호는 계정 보안과 다른 소셜 계정 연동에 사용됩니다.',
                            style: TossDesignSystem.body2.copyWith(
                              color: _getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Current phone number
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                    padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: _getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDividerColor(context),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TossDesignSystem.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: _getSecondaryTextColor(context),
                              size: 22,
                            ),
                            const SizedBox(width: TossDesignSystem.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '등록된 전화번호',
                                    style: TossDesignSystem.body2.copyWith(
                                      color: _getTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDisplayPhone(userProfile?['phone']),
                                    style: TossDesignSystem.caption.copyWith(
                                      color: _getSecondaryTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (userProfile?['phone_verified'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                                decoration: BoxDecoration(
                                  color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: TossDesignSystem.successGreen,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '인증됨',
                                      style: TextStyle(
                                        color: TossDesignSystem.successGreen,
                                        
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: TossDesignSystem.spacingM),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPhoneInput = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TossDesignSystem.tossBlue,
                              foregroundColor: TossDesignSystem.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: TossDesignSystem.spacingM),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    TossDesignSystem.radiusM),
                              ),
                            ),
                            child: Text(
                              hasPhone ? '전화번호 변경' : '전화번호 등록',
                              style: TossDesignSystem.button.copyWith(
                                color: TossDesignSystem.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Benefits
                  const SizedBox(height: TossDesignSystem.spacingXL),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TossDesignSystem.marginHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전화번호 등록 혜택',
                          style: TossDesignSystem.caption.copyWith(
                            color: _getSecondaryTextColor(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: TossDesignSystem.spacingM),
                        _buildBenefitItem(
                          icon: Icons.security,
                          title: '계정 보안 강화',
                          subtitle: '2단계 인증으로 계정을 안전하게 보호',
                        ),
                        _buildBenefitItem(
                          icon: Icons.link,
                          title: '쉬운 계정 연동',
                          subtitle: '여러 소셜 계정을 하나로 통합 관리',
                        ),
                        _buildBenefitItem(
                          icon: Icons.restore,
                          title: '계정 복구',
                          subtitle: '비밀번호를 잊어도 쉽게 계정 복구',
                        ),
                        _buildBenefitItem(
                          icon: Icons.notifications_active,
                          title: '중요 알림',
                          subtitle: '운세 알림과 이벤트 소식 받기',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: TossDesignSystem.tossBlue,
            size: 22,
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}