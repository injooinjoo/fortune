import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../services/phone_auth_service.dart';
import '../onboarding/steps/phone_step.dart';
import '../onboarding/steps/phone_verification_step.dart';

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
    final theme = Theme.of(context);
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
                backgroundColor: Colors.red,
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
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
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
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '전화번호 관리',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '전화번호는 계정 보안과 다른 소셜 계정 연동에 사용됩니다.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Current phone number
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: AppColors.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '등록된 전화번호',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDisplayPhone(userProfile?['phone']),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
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
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '인증됨',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPhoneInput = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              hasPhone ? '전화번호 변경' : '전화번호 등록',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Benefits
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전화번호 등록 혜택',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
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