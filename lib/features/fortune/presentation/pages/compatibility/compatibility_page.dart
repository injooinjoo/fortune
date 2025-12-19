import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/design_system/tokens/ds_love_colors.dart';
import 'package:fortune/core/design_system/components/traditional/traditional_button.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/core/services/unified_fortune_service.dart';
import 'package:fortune/core/services/fortune_haptic_service.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/features/fortune/domain/models/conditions/compatibility_fortune_conditions.dart';
import 'package:fortune/services/ad_service.dart';
import 'package:fortune/core/utils/subscription_snackbar.dart';
import 'package:fortune/screens/profile/widgets/add_profile_sheet.dart';
import 'package:fortune/presentation/providers/secondary_profiles_provider.dart';
import 'widgets/index.dart';

class CompatibilityPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const CompatibilityPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends ConsumerState<CompatibilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _person1NameController = TextEditingController();
  final _person2NameController = TextEditingController();
  DateTime? _person1BirthDate;
  DateTime? _person2BirthDate;

  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = false;

  // 블러 상태 관리 (로컬)
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 직접 입력 여부 추적 (프로필 추가 프롬프트 표시용)
  bool _wasManualInput = false;

  @override
  void initState() {
    super.initState();

    // 사용자 프로필 정보로 미리 채우기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.when(
        data: (userProfile) {
          if (userProfile != null) {
            setState(() {
              _person1NameController.text = userProfile.name ?? '';
              _person1BirthDate = userProfile.birthDate;
            });
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  @override
  void dispose() {
    _person1NameController.dispose();
    _person2NameController.dispose();
    super.dispose();
  }

  Future<void> _analyzeCompatibility() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이름을 입력해주세요'),
          backgroundColor: DSColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_person1BirthDate == null || _person2BirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('생년월일을 선택해주세요'),
          backgroundColor: DSColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 분석 시작 햅틱
    ref.read(fortuneHapticServiceProvider).analysisStart();

    setState(() {
      _isLoading = true;
    });

    await _performCompatibilityAnalysis();
  }

  Future<void> _performCompatibilityAnalysis() async {
    try {
      // 궁합 테스트용: Debug Premium 무시, 실제 토큰만 체크
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = realPremium; // Debug Premium 무시

      debugPrint('💎 [CompatibilityPage] Premium 상태: $isPremium (real: $realPremium)');

      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // input_conditions 정규화
      final inputConditions = {
        'person1': {
          'name': _person1NameController.text,
          'birth_date': _person1BirthDate!.toIso8601String(),
        },
        'person2': {
          'name': _person2NameController.text,
          'birth_date': _person2BirthDate!.toIso8601String(),
        },
        'isPremium': isPremium,
      };

      // Optimization conditions 생성
      final conditions = CompatibilityFortuneConditions(
        person1Name: _person1NameController.text,
        person1BirthDate: _person1BirthDate!,
        person2Name: _person2NameController.text,
        person2BirthDate: _person2BirthDate!,
      );

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'compatibility',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
      );

      // FortuneResult → Fortune 엔티티 변환 (블러 로직 포함)
      final fortune = _convertToFortune(fortuneResult, isPremium);

      debugPrint('📊 [CompatibilityPage] Fortune 변환 완료');
      debugPrint('  ├─ isBlurred: ${fortune.isBlurred}');
      debugPrint('  ├─ blurredSections: ${fortune.blurredSections}');
      debugPrint('  ├─ content 길이: ${fortune.content.length}자');
      debugPrint('  ├─ content 미리보기: ${fortune.content.substring(0, fortune.content.length > 50 ? 50 : fortune.content.length)}...');
      debugPrint('  ├─ advice 길이: ${fortune.advice?.length ?? 0}자');
      debugPrint('  └─ metadata keys: ${fortune.metadata?.keys.toList()}');

      // Parse scores from fortune response
      Map<String, double> scores = {};

      // Extract overall score
      double overallScore = (fortune.overallScore ?? 75) / 100.0;
      scores['전체 궁합'] = overallScore;

      // Parse detailed scores from fortune content or metadata
      if (fortune.metadata != null && fortune.metadata!['scores'] != null) {
        final detailedScores = fortune.metadata!['scores'] as Map<String, dynamic>;
        scores['사랑 궁합'] = (detailedScores['love'] ?? 80) / 100.0;
        scores['결혼 궁합'] = (detailedScores['marriage'] ?? 75) / 100.0;
        scores['일상 궁합'] = (detailedScores['daily'] ?? 70) / 100.0;
        scores['소통 궁합'] = (detailedScores['communication'] ?? 78) / 100.0;
      } else {
        // Calculate based on overall score with slight variations
        scores['사랑 궁합'] = (overallScore + 0.05).clamp(0.0, 1.0);
        scores['결혼 궁합'] = (overallScore - 0.03).clamp(0.0, 1.0);
        scores['일상 궁합'] = (overallScore - 0.07).clamp(0.0, 1.0);
        scores['소통 궁합'] = overallScore;
      }

      setState(() {
        _compatibilityData = {
          'fortune': fortune,
          'scores': scores,
        };
        _isLoading = false;
        // 로컬 블러 상태 설정
        _isBlurred = fortune.isBlurred;
        _blurredSections = fortune.blurredSections;
      });

      debugPrint('🔐 [CompatibilityPage] 로컬 블러 상태 설정');
      debugPrint('  ├─ _isBlurred: $_isBlurred');
      debugPrint('  └─ _blurredSections: $_blurredSections');

      // 궁합 점수 공개 햅틱 (점수에 따른 차별화)
      final overallScoreInt = (fortune.overallScore ?? 75);
      ref.read(fortuneHapticServiceProvider).compatibilityReveal(overallScoreInt);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String errorMessage = '궁합 분석 중 오류가 발생했습니다';
        if (e.toString().contains('404')) {
          errorMessage = '궁합 분석 서비스를 사용할 수 없습니다';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: DSColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResultView = _compatibilityData != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 전통 연애/궁합 색상
    final hanjiBackground = DSLoveColors.getHanjiBackground(isDark);
    final inkColor = isDark ? const Color(0xFFD4D0C8) : const Color(0xFF2C2C2C);
    final primaryColor = DSLoveColors.getPrimary(isDark);

    return Scaffold(
      backgroundColor: hanjiBackground,
      appBar: AppBar(
        backgroundColor: hanjiBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        // 결과 페이지에서는 뒤로가기 버튼 숨김
        leading: isResultView
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TraditionalIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  colorScheme: TraditionalButtonColorScheme.love,
                  size: 40,
                  showBorder: false,
                  onPressed: () => context.pop(),
                ),
              ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '宮合',
              style: context.labelMedium.copyWith(
                fontFamily: 'GowunBatang',
                color: primaryColor.withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ),
            Text(
              '궁합 분석',
              style: context.heading3.copyWith(
                fontFamily: 'GowunBatang',
                color: inkColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        // 결과 페이지에서만 X 버튼 표시
        actions: isResultView
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TraditionalIconButton(
                    icon: Icons.close_rounded,
                    colorScheme: TraditionalButtonColorScheme.love,
                    size: 40,
                    showBorder: false,
                    onPressed: () => context.pop(),
                  ),
                ),
              ]
            : null,
      ),
      body: isResultView ? _buildResultView() : _buildInputView(),
    );
  }

  Widget _buildInputView() {
    return CompatibilityInputView(
      formKey: _formKey,
      person1NameController: _person1NameController,
      person2NameController: _person2NameController,
      person1BirthDate: _person1BirthDate,
      person2BirthDate: _person2BirthDate,
      onPerson1BirthDateChanged: (date) {
        setState(() {
          _person1BirthDate = date;
        });
      },
      onPerson2BirthDateChanged: (date) {
        setState(() {
          _person2BirthDate = date;
        });
      },
      onAnalyze: _analyzeCompatibility,
      isLoading: _isLoading,
      canAnalyze: _canAnalyze(),
      onManualInputChanged: (isManual) {
        _wasManualInput = isManual;
      },
    );
  }

  bool _canAnalyze() {
    return _person1NameController.text.isNotEmpty &&
        _person2NameController.text.isNotEmpty &&
        _person1BirthDate != null &&
        _person2BirthDate != null;
  }

  Widget _buildResultView() {
    final fortune = _compatibilityData!['fortune'] as Fortune;
    final scores = _compatibilityData!['scores'] as Map<String, double>;
    final canAddProfile = ref.watch(canAddSecondaryProfileProvider);

    return CompatibilityResultView(
      fortune: fortune,
      scores: scores,
      person1Name: _person1NameController.text,
      person2Name: _person2NameController.text,
      isBlurred: _isBlurred,
      blurredSections: _blurredSections,
      onShowAdAndUnblur: _showAdAndUnblur,
      // 직접 입력이었고 프로필 추가 가능할 때만 버튼 표시
      showAddProfileButton: _wasManualInput && canAddProfile,
      onAddProfile: _showAddProfileSheet,
    );
  }

  /// 프로필 추가 바텀시트 표시
  Future<void> _showAddProfileSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProfileSheet(
        initialName: _person2NameController.text,
        initialBirthDate: _person2BirthDate,
        title: '상대방 프로필 저장',
        subtitle: '저장하면 다음에 더 빠르게 궁합을 확인할 수 있어요',
      ),
    );

    // 프로필 추가 성공 시 버튼 숨기기
    if (result == true && mounted) {
      setState(() {
        _wasManualInput = false;
      });
    }
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎁 [광고] 블러 해제 프로세스 시작');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('');

    try {
      final adService = AdService();

      debugPrint('1️⃣ 광고 준비 상태 확인');
      debugPrint('   - 광고 준비 상태: ${adService.isRewardedAdReady}');

      if (!adService.isRewardedAdReady) {
        debugPrint('   ⚠️ 광고가 아직 준비되지 않음');
        debugPrint('   → 광고 로드 시작...');
        await adService.loadRewardedAd();
        debugPrint('   ✅ 광고 로드 완료');
      } else {
        debugPrint('   ✅ 광고가 이미 준비됨');
      }

      debugPrint('');
      debugPrint('2️⃣ 리워드 광고 표시');
      debugPrint('   - 현재 블러 상태: isBlurred=$_isBlurred');
      debugPrint('   - 블러된 섹션: $_blurredSections');
      debugPrint('   - 광고 준비 상태: ${adService.isRewardedAdReady}');
      debugPrint('   → 광고 표시 중...');

      // 리워드 광고 표시 및 완료 대기
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('');
          debugPrint('3️⃣ 광고 시청 완료!');
          debugPrint('   - reward.type: ${reward.type}');
          debugPrint('   - reward.amount: ${reward.amount}');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // 광고 시청 완료 시 블러만 해제 (로컬 상태 변경)
          if (mounted) {
            debugPrint('   → 블러 해제 중...');

            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            debugPrint('   ✅ 블러 해제 완료!');
            debugPrint('      - 새 상태: _isBlurred=false');
            debugPrint('      - 새 상태: _blurredSections=[]');

            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );

            debugPrint('');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ [광고] 블러 해제 프로세스 완료!');
            debugPrint('   → 사용자는 이제 전체 운세 내용을 볼 수 있습니다');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('');
          } else {
            debugPrint('   ⚠️ Widget이 이미 dispose됨. 블러 해제 취소.');
          }
        },
      );
    } catch (e) {
      debugPrint('');
      debugPrint('❌ [광고] 에러 발생: $e');
      debugPrint('   → 사용자 경험 우선: 블러 해제 진행');

      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시에 실패했지만 운세를 확인할 수 있습니다.'),
          ),
        );

        debugPrint('   ✅ 블러 해제 완료 (에러 처리)');
      }
      debugPrint('');
    }
  }

  /// FortuneResult를 Fortune 엔티티로 변환 (블러 로직 포함)
  Fortune _convertToFortune(FortuneResult result, bool isPremium) {
    // 블러 처리 로직
    final isBlurred = !isPremium;
    final blurredSections = isBlurred
        ? ['detailed_scores', 'analysis', 'advice'] // 세부 궁합, 분석 결과, 조언 블러
        : <String>[];

    debugPrint('🔒 [CompatibilityPage] isBlurred: $isBlurred, blurredSections: $blurredSections');

    return Fortune(
      id: result.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: result.type,
      content: result.data['content'] as String? ?? result.summary.toString(),
      createdAt: DateTime.now(),
      overallScore: result.score,
      summary: result.summary['message'] as String?,
      metadata: result.data,
      isBlurred: isBlurred,
      blurredSections: blurredSections,
    );
  }
}
