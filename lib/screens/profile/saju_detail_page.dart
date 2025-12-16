import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
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
  Map<String, dynamic>? userSaju;  // 사주 데이터
  bool isLoading = true;
  bool isCalculatingSaju = false;  // 사주 계산 중 여부

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
        // 1. 프로필 데이터 로드
        final profileResponse = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        // 2. 사주 데이터 로드
        Map<String, dynamic>? sajuResponse;
        try {
          sajuResponse = await supabase
              .from('user_saju')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error loading saju data: $e');
        }

        if (mounted) {
          setState(() {
            userProfile = profileResponse;
            userSaju = sajuResponse;
            isLoading = false;
          });
        }

        // 3. 사주 데이터가 없고 생년월일이 있으면 자동 계산
        if (sajuResponse == null && profileResponse?['birth_date'] != null) {
          await _calculateSaju(userId);
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

  /// 한국식 시간 형식을 HH:mm으로 변환
  /// 예: "축시 (01:00 - 03:00)" → "02:00"
  String _convertBirthTimeToHHmm(String? birthTime) {
    if (birthTime == null || birthTime.isEmpty) return '12:00';

    // 이미 HH:mm 형식인 경우
    final simpleTimeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');
    if (simpleTimeRegex.hasMatch(birthTime)) {
      return birthTime;
    }

    // "축시 (01:00 - 03:00)" 형식에서 중간 시간 추출
    final rangeRegex = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})');
    final match = rangeRegex.firstMatch(birthTime);
    if (match != null) {
      final startHour = int.parse(match.group(1)!);
      final endHour = int.parse(match.group(3)!);
      // 중간 시간 계산
      final middleHour = ((startHour + endHour) / 2).floor();
      return '${middleHour.toString().padLeft(2, '0')}:00';
    }

    // 시간대 이름으로 매핑
    final timeMap = {
      '자시': '00:00',
      '축시': '02:00',
      '인시': '04:00',
      '묘시': '06:00',
      '진시': '08:00',
      '사시': '10:00',
      '오시': '12:00',
      '미시': '14:00',
      '신시': '16:00',
      '유시': '18:00',
      '술시': '20:00',
      '해시': '22:00',
    };

    for (final entry in timeMap.entries) {
      if (birthTime.contains(entry.key)) {
        return entry.value;
      }
    }

    return '12:00';
  }

  /// 사주 데이터가 없을 때 자동으로 계산
  Future<void> _calculateSaju(String userId) async {
    final profile = userProfile ?? localProfile;
    if (profile?['birth_date'] == null) {
      debugPrint('Cannot calculate saju: birth_date is null');
      return;
    }

    if (mounted) {
      setState(() {
        isCalculatingSaju = true;
      });
    }

    try {
      final birthTimeHHmm = _convertBirthTimeToHHmm(profile!['birth_time']);
      debugPrint('Calculating saju for user: $userId, birthTime: $birthTimeHHmm');

      final response = await supabase.functions.invoke(
        'calculate-saju',
        body: {
          'userId': userId,
          'birthDate': profile['birth_date'],
          'birthTime': birthTimeHHmm,
          'isLunar': profile['is_lunar'] ?? false,
          'timezone': 'Asia/Seoul',
        },
      );

      if (response.status == 200) {
        debugPrint('Saju calculation completed');

        // 계산 완료 후 데이터 다시 로드
        final sajuData = await supabase
            .from('user_saju')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (mounted) {
          setState(() {
            userSaju = sajuData;
            isCalculatingSaju = false;
          });
        }
      } else {
        debugPrint('Saju calculation failed: ${response.status}');
        if (mounted) {
          setState(() {
            isCalculatingSaju = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error calculating saju: $e');
      if (mounted) {
        setState(() {
          isCalculatingSaju = false;
        });
      }
    }
  }

  // Design System Helper Methods
  Color _getTextColor(BuildContext context) {
    return context.colors.textPrimary;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return context.colors.textSecondary;
  }

  Color _getBackgroundColor(BuildContext context) {
    return context.colors.background;
  }

  Color _getCardColor(BuildContext context) {
    return context.colors.surface;
  }

  Color _getDividerColor(BuildContext context) {
    return context.colors.border;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.pageHorizontal,
        DSSpacing.lg,
        DSSpacing.pageHorizontal,
        DSSpacing.sm,
      ),
      child: Text(
        title,
        style: DSTypography.labelSmall.copyWith(
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
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.md,
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
            style: DSTypography.bodySmall.copyWith(
              color: _getTextColor(context),
            ),
          ),
          Text(
            value,
            style: DSTypography.bodySmall.copyWith(
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
            style: DSTypography.labelLarge.copyWith(
              color: _getTextColor(context),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: DSColors.accent,
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
          style: DSTypography.labelLarge.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.md),

              // 기본 정보 섹션
              _buildSectionHeader('기본 정보'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoItem(
                      title: '년주 (年柱)',
                      value: _getSajuPillarValue('year'),
                    ),
                    _buildInfoItem(
                      title: '월주 (月柱)',
                      value: _getSajuPillarValue('month'),
                    ),
                    _buildInfoItem(
                      title: '일주 (日柱)',
                      value: _getSajuPillarValue('day'),
                    ),
                    _buildInfoItem(
                      title: '시주 (時柱)',
                      value: _getSajuPillarValue('hour'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 오행 정보 섹션 (사주 데이터가 있을 때만 표시)
              if (userSaju != null) ...[
                _buildSectionHeader('오행 균형'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                  decoration: BoxDecoration(
                    color: _getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDividerColor(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        title: '목 (木)',
                        value: '${userSaju!['element_wood'] ?? 0}',
                      ),
                      _buildInfoItem(
                        title: '화 (火)',
                        value: '${userSaju!['element_fire'] ?? 0}',
                      ),
                      _buildInfoItem(
                        title: '토 (土)',
                        value: '${userSaju!['element_earth'] ?? 0}',
                      ),
                      _buildInfoItem(
                        title: '금 (金)',
                        value: '${userSaju!['element_metal'] ?? 0}',
                      ),
                      _buildInfoItem(
                        title: '수 (水)',
                        value: '${userSaju!['element_water'] ?? 0}',
                      ),
                      if (userSaju!['weak_element'] != null)
                        _buildInfoItem(
                          title: '부족한 오행',
                          value: userSaju!['weak_element'],
                          isLast: true,
                        ),
                    ],
                  ),
                ),
              ],

              // 십이지 정보 섹션
              _buildSectionHeader('십이지 정보'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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

              const SizedBox(height: DSSpacing.xxl),

              // 사주 재계산 버튼 (사주 데이터가 없는 경우)
              if (userSaju == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCalculatingSaju
                          ? null
                          : () async {
                              final userId = supabase.auth.currentUser?.id;
                              if (userId != null) {
                                await _calculateSaju(userId);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DSColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isCalculatingSaju
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '사주 팔자 계산하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

              if (userSaju == null)
                const SizedBox(height: DSSpacing.lg),

              // 안내 메시지
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: DSColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: DSColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          '정확한 사주 팔자 계산을 위해서는 출생시간 정보가 필요합니다.',
                          style: DSTypography.labelSmall.copyWith(
                            color: DSColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DSSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  /// 사주 기둥 값을 반환 (천간 + 지지)
  String _getSajuPillarValue(String pillar) {
    if (isCalculatingSaju) {
      return '계산 중...';
    }

    if (userSaju == null) {
      return '미계산';
    }

    final cheongan = userSaju!['${pillar}_cheongan'];
    final jiji = userSaju!['${pillar}_jiji'];

    if (cheongan != null && jiji != null) {
      return '$cheongan$jiji';
    }

    return '미계산';
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
