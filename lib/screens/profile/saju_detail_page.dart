import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/toss_design_system.dart';
import '../../services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SajuDetailPage extends ConsumerStatefulWidget {
  const SajuDetailPage({super.key});

  @override
  ConsumerState<SajuDetailPage> createState() => _SajuDetailPageState();
}

class _SajuDetailPageState extends ConsumerState<SajuDetailPage> {
  final supabase = Supabase.instance.client;
  final _storageService = StorageService();
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? localProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load from local storage first
      localProfile = await _storageService.getUserProfile();

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (mounted) {
          setState(() {
            userProfile = response;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            userProfile = localProfile;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingL,
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingS,
      ),
      child: Text(
        title,
        style: TossDesignSystem.caption.copyWith(
          color: _getSecondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.marginHorizontal,
        vertical: TossDesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _getDividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TossDesignSystem.body2.copyWith(
              color: _getTextColor(context),
            ),
          ),
          Text(
            value,
            style: TossDesignSystem.body2.copyWith(
              color: _getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '사주 정보',
            style: TossDesignSystem.heading4.copyWith(
              color: _getTextColor(context),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
          ),
        ),
      );
    }

    final profile = userProfile ?? localProfile;

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '사주 정보',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              // 기본 정보 섹션
              _buildSectionHeader('기본 정보'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
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
                  children: [
                    _buildInfoItem(
                      title: '이름',
                      value: profile?['name'] ?? '미입력',
                    ),
                    _buildInfoItem(
                      title: '생년월일',
                      value: _formatBirthDate(profile?['birth_date']),
                    ),
                    _buildInfoItem(
                      title: '출생시간',
                      value: profile?['birth_time'] ?? '미입력',
                    ),
                    _buildInfoItem(
                      title: '성별',
                      value: _formatGender(profile?['gender']),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 사주 팔자 섹션
              _buildSectionHeader('사주 팔자'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
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
                  children: [
                    _buildInfoItem(
                      title: '년주 (年柱)',
                      value: '미계산', // TODO: 사주 계산 API 연동
                    ),
                    _buildInfoItem(
                      title: '월주 (月柱)',
                      value: '미계산',
                    ),
                    _buildInfoItem(
                      title: '일주 (日柱)',
                      value: '미계산',
                    ),
                    _buildInfoItem(
                      title: '시주 (時柱)',
                      value: '미계산',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 십이지 정보 섹션
              _buildSectionHeader('십이지 정보'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
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
                  children: [
                    _buildInfoItem(
                      title: '띠',
                      value: profile?['chinese_zodiac'] ?? '미입력',
                    ),
                    _buildInfoItem(
                      title: '별자리',
                      value: profile?['zodiac_sign'] ?? '미입력',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),

              // 안내 메시지
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: TossDesignSystem.tossBlue,
                        size: 20,
                      ),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          '정확한 사주 팔자 계산을 위해서는 출생시간 정보가 필요합니다.',
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return '미입력';

    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return '미입력';
    }
  }

  String _formatGender(String? gender) {
    if (gender == null) return '미입력';
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      case 'other':
        return '선택 안함';
      default:
        return '미입력';
    }
  }
}
