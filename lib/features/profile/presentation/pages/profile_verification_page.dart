import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/components/toast.dart';

class ProfileVerificationPage extends ConsumerStatefulWidget {
  const ProfileVerificationPage({super.key});

  @override
  ConsumerState<ProfileVerificationPage> createState() => _ProfileVerificationPageState();
}

class _ProfileVerificationPageState extends ConsumerState<ProfileVerificationPage> {
  int _currentStep = 0;
  bool _isPhoneVerified = false;
  bool _isEmailVerified = false;
  bool _isIdentityVerified = false;
  bool _isLoading = false;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userProfileAsync = ref.read(userProfileProvider);
    userProfileAsync.when(
      data: (profile) {
        if (profile != null) {
          _phoneController.text = profile.phoneNumber ?? '';
          _emailController.text = profile.email ?? '';
          // Check verification status from profile
          setState(() {
            // TODO: Add these fields to UserProfile model when implementing verification
            _isPhoneVerified = false; // profile.phoneVerified ?? false;
            _isEmailVerified = false; // profile.emailVerified ?? false;
            _isIdentityVerified = false; // profile.identityVerified ?? false;
          });
        }
      },
      error: (_, __) {},
      loading: () {},
    );
  }

  Future<void> _sendPhoneVerification() async {
    if (_phoneController.text.isEmpty) {
      Toast.show(
        context,
        message: '전화번호를 입력해주세요',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate sending verification code
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      HapticUtils.mediumImpact();

      Toast.show(
        context,
        message: '인증번호가 발송되었습니다',
        type: ToastType.success,
      );

      setState(() {
        _currentStep = 1;
      });
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        message: '인증번호 발송에 실패했습니다',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPhone() async {
    if (_verificationCodeController.text.isEmpty) {
      Toast.show(
        context,
        message: '인증번호를 입력해주세요',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate verification
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      HapticUtils.success();

      setState(() {
        _isPhoneVerified = true;
        _currentStep = 0;
      });

      Toast.show(
        context,
        message: '전화번호가 인증되었습니다',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        message: '인증에 실패했습니다',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendEmailVerification() async {
    if (_emailController.text.isEmpty) {
      Toast.show(
        context,
        message: '이메일을 입력해주세요',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate sending verification email
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      HapticUtils.mediumImpact();

      Toast.show(
        context,
        message: '인증 이메일이 발송되었습니다',
        type: ToastType.success,
      );

      setState(() {
        _isEmailVerified = true;
      });
    } catch (e) {
      if (!mounted) return;
      Toast.show(
        context,
        message: '이메일 발송에 실패했습니다',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get verificationLevel {
    int level = 0;
    if (_isPhoneVerified) level++;
    if (_isEmailVerified) level++;
    if (_isIdentityVerified) level++;
    return level;
  }

  Color get verificationColor {
    switch (verificationLevel) {
      case 0:
        return TossDesignSystem.gray500;
      case 1:
        return TossDesignSystem.warningOrange;
      case 2:
        return TossDesignSystem.primaryBlue;
      case 3:
        return TossDesignSystem.success;
      default:
        return TossDesignSystem.gray500;
    }
  }

  String get verificationBadge {
    switch (verificationLevel) {
      case 0:
        return '미인증';
      case 1:
        return '기본 인증';
      case 2:
        return '신뢰 인증';
      case 3:
        return '공식 인증';
      default:
        return '미인증';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TossDesignSystem.gray900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '프로필 인증',
          style: context.heading3.copyWith(
            color: TossDesignSystem.gray900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    verificationColor.withValues(alpha: 0.2),
                    verificationColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: verificationColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: verificationColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user,
                          color: verificationColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '현재 인증 상태',
                              style: context.bodySmall.copyWith(
                                color: TossDesignSystem.gray600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: verificationColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    verificationBadge,
                                    style: context.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: TossDesignSystem.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lv.$verificationLevel',
                                  style: context.buttonMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: verificationColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '인증 진행도',
                            style: context.labelMedium.copyWith(
                              color: TossDesignSystem.gray600,
                            ),
                          ),
                          Text(
                            '$verificationLevel/3',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: verificationColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: verificationLevel / 3,
                          backgroundColor: TossDesignSystem.gray200,
                          valueColor: AlwaysStoppedAnimation<Color>(verificationColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Benefits Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증 혜택',
                    style: context.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.security,
                    title: '계정 보안 강화',
                    description: '2단계 인증으로 계정을 안전하게 보호하세요',
                  ),
                  _buildBenefitItem(
                    icon: Icons.star,
                    title: '프리미엄 기능 우선 체험',
                    description: '새로운 기능을 먼저 사용해보실 수 있습니다',
                  ),
                  _buildBenefitItem(
                    icon: Icons.badge,
                    title: '인증 배지 표시',
                    description: '프로필에 공식 인증 배지가 표시됩니다',
                  ),
                  _buildBenefitItem(
                    icon: Icons.card_giftcard,
                    title: '특별 보상',
                    description: '인증 완료 시 보너스 토큰을 지급합니다',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Verification Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증 단계',
                    style: context.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Verification
                  _buildVerificationStep(
                    title: '전화번호 인증',
                    description: 'SMS로 본인 확인',
                    isCompleted: _isPhoneVerified,
                    isExpanded: _currentStep == 0 && !_isPhoneVerified,
                    onTap: _isPhoneVerified ? null : () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    content: Column(
                      children: [
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: context.bodySmall,
                          decoration: InputDecoration(
                            hintText: '010-0000-0000',
                            hintStyle: context.bodySmall.copyWith(
                              color: TossDesignSystem.gray600,
                            ),
                            prefixIcon: const Icon(Icons.phone, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.gray200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.gray200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.tossBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendPhoneVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TossDesignSystem.tossBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TossDesignSystem.white,
                                    ),
                                  )
                                : Text(
                                    '인증번호 발송',
                                    style: context.buttonSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Verification Code Input (shown after phone number is submitted)
                  if (_currentStep == 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '인증번호 입력',
                            style: context.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _verificationCodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: context.bodySmall,
                            decoration: InputDecoration(
                              hintText: '6자리 인증번호',
                              hintStyle: context.bodySmall.copyWith(
                                color: TossDesignSystem.gray600,
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: TossDesignSystem.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: TossDesignSystem.gray200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: TossDesignSystem.tossBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentStep = 0;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: TossDesignSystem.gray200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    '취소',
                                    style: context.buttonSmall.copyWith(
                                      color: TossDesignSystem.gray600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyPhone,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TossDesignSystem.tossBlue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: TossDesignSystem.white,
                                          ),
                                        )
                                      : Text(
                                          '확인',
                                          style: context.buttonSmall.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: TossDesignSystem.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Email Verification
                  _buildVerificationStep(
                    title: '이메일 인증',
                    description: '이메일로 본인 확인',
                    isCompleted: _isEmailVerified,
                    isExpanded: _currentStep == 2 && !_isEmailVerified,
                    onTap: _isEmailVerified ? null : () {
                      setState(() {
                        _currentStep = 2;
                      });
                    },
                    content: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: context.bodySmall,
                          decoration: InputDecoration(
                            hintText: 'example@email.com',
                            hintStyle: context.bodySmall.copyWith(
                              color: TossDesignSystem.gray600,
                            ),
                            prefixIcon: const Icon(Icons.email, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.gray200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.gray200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: TossDesignSystem.tossBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendEmailVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TossDesignSystem.tossBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TossDesignSystem.white,
                                    ),
                                  )
                                : Text(
                                    '인증 이메일 발송',
                                    style: context.buttonSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: TossDesignSystem.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Identity Verification
                  _buildVerificationStep(
                    title: '신원 인증',
                    description: '본인 확인 서류로 인증',
                    isCompleted: _isIdentityVerified,
                    isLocked: !_isPhoneVerified || !_isEmailVerified,
                    onTap: (_isIdentityVerified || !_isPhoneVerified || !_isEmailVerified)
                        ? null
                        : () {
                            Toast.show(
                              context,
                              message: '신원 인증은 준비 중입니다',
                              type: ToastType.info,
                            );
                          },
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
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: TossDesignSystem.tossBlue,
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
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.labelMedium.copyWith(
                    color: TossDesignSystem.gray600,
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

  Widget _buildVerificationStep({
    required String title,
    required String description,
    required bool isCompleted,
    bool isExpanded = false,
    bool isLocked = false,
    VoidCallback? onTap,
    Widget? content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? TossDesignSystem.success.withValues(alpha: 0.3)
              : isLocked
                  ? TossDesignSystem.gray200
                  : TossDesignSystem.tossBlue.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? TossDesignSystem.success.withValues(alpha: 0.1)
                          : isLocked
                              ? TossDesignSystem.gray200
                              : TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isLocked
                              ? Icons.lock
                              : Icons.radio_button_unchecked,
                      color: isCompleted
                          ? TossDesignSystem.success
                          : isLocked
                              ? TossDesignSystem.gray600
                              : TossDesignSystem.tossBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.buttonMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLocked ? TossDesignSystem.gray600 : TossDesignSystem.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: context.labelMedium.copyWith(
                            color: TossDesignSystem.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '완료',
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.success,
                        ),
                      ),
                    )
                  else if (!isLocked && onTap != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: TossDesignSystem.gray600,
                    ),
                ],
              ),
              if (isExpanded && content != null) ...[
                const SizedBox(height: 16),
                content,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
