import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/providers/user_settings_provider.dart';
import '../../services/phone_auth_service.dart';
import '../onboarding/steps/phone_step.dart';
import '../onboarding/steps/phone_verification_step.dart';

class PhoneManagementScreen extends ConsumerStatefulWidget {
  const PhoneManagementScreen({super.key});

  @override
  ConsumerState<PhoneManagementScreen> createState() =>
      _PhoneManagementScreenState();
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
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);
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
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: colors.error,
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

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('전화번호가 성공적으로 변경되었습니다'),
                  backgroundColor: colors.success,
                ),
              );
              context.pop();
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: colors.error,
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
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('인증번호가 재발송되었습니다'),
                backgroundColor: colors.success,
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: colors.error,
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
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '전화번호 관리',
          style: typography.headingSmall.copyWith(
            color: colors.textPrimary,
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
                    margin: const EdgeInsets.all(DSSpacing.pageHorizontal),
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.accent,
                          size: 22,
                        ),
                        const SizedBox(width: DSSpacing.md),
                        Expanded(
                          child: Text(
                            '전화번호는 계정 보안과 다른 소셜 계정 연동에 사용됩니다.',
                            style: typography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Current phone number
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.pageHorizontal),
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(DSRadius.md),
                      border: Border.all(
                        color: colors.border,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.04),
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
                              color: colors.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(width: DSSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '등록된 전화번호',
                                    style: typography.bodySmall.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDisplayPhone(userProfile?['phone']),
                                    style: typography.labelSmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (userProfile?['phone_verified'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: colors.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '인증됨',
                                      style: TextStyle(
                                        color: colors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showPhoneInput = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.ctaBackground,
                              foregroundColor: colors.ctaForeground,
                              padding: const EdgeInsets.symmetric(
                                  vertical: DSSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(DSRadius.md),
                              ),
                            ),
                            child: Text(
                              hasPhone ? '전화번호 변경' : '전화번호 등록',
                              style: typography.buttonMedium.copyWith(
                                color: colors.ctaForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Benefits
                  const SizedBox(height: DSSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.pageHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전화번호 등록 혜택',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: DSSpacing.md),
                        _buildBenefitItem(
                          context,
                          icon: Icons.security,
                          title: '계정 보안 강화',
                          subtitle: '2단계 인증으로 계정을 안전하게 보호',
                        ),
                        _buildBenefitItem(
                          context,
                          icon: Icons.link,
                          title: '쉬운 계정 연동',
                          subtitle: '여러 소셜 계정을 하나로 통합 관리',
                        ),
                        _buildBenefitItem(
                          context,
                          icon: Icons.restore,
                          title: '계정 복구',
                          subtitle: '비밀번호를 잊어도 쉽게 계정 복구',
                        ),
                        _buildBenefitItem(
                          context,
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

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
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
