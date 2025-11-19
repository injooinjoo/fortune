import 'dart:convert';
import 'dart:ui';  // ✅ ImageFilter.blur 사용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/components/image_upload_selector.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart' as core_models;
import '../../domain/models/conditions/face_reading_fortune_conditions.dart';
import 'package:crypto/crypto.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';

class FaceReadingFortunePage extends ConsumerStatefulWidget {
  const FaceReadingFortunePage({super.key});

  @override
  ConsumerState<FaceReadingFortunePage> createState() => _FaceReadingFortunePageState();
}

class _FaceReadingFortunePageState extends ConsumerState<FaceReadingFortunePage> {
  final PageController _pageController = PageController();
  ImageUploadResult? _uploadResult;
  bool _isAnalyzing = false;
  FortuneResult? _fortuneResult;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _fortuneResult == null
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null, // 결과 화면에서는 백버튼 숨김
        automaticallyImplyLeading: _fortuneResult == null, // 결과 화면에서는 자동 백버튼도 숨김
        title: Text(
          '관상',
          style: TypographyUnified.heading4.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: _fortuneResult != null
            ? [
                // 결과 화면에서는 오른쪽에 X 버튼
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _fortuneResult != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildTossStyleResult(context, _fortuneResult!, isDark),
                  )
                : _buildTossStyleInputSection(context, isDark),
            // ✅ FloatingBottomButton - 결과 화면에서 블러 상태일 때만 표시
            if (_fortuneResult != null && _fortuneResult!.isBlurred)
              FloatingBottomButton(
                text: '남은 운세 모두 보기',
                onPressed: _showAdAndUnblur,
                isLoading: false,
                isEnabled: true,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTossStyleInputSection(BuildContext context, bool isDark) {
    return Stack(
      children: [
        Positioned.fill(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(context, isDark),
              _buildStep2(context, isDark),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStep1(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'AI가 당신의\n관상을 분석합니다',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            '사진이나 인스타그램 프로필로\n숨겨진 운명과 성격을 알아보세요',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          // Image Upload Selector
          ImageUploadSelector(
            title: '분석 방법 선택',
            description: '원하는 방법으로 사진을 제공해주세요',
            onImageSelected: (result) {
              setState(() {
                _uploadResult = result;
                if (result.imageFile != null || result.instagramUrl != null) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              });
            },
            showInstagramOption: true,
            guidelines: const [
              '정면을 바라보는 사진을 사용해주세요',
              '밝은 조명에서 촬영된 사진이 좋습니다',
              '선글라스나 마스크는 제거해주세요',
              '한 명만 나온 사진을 사용해주세요',
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep2(BuildContext context, bool isDark) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Title
          Text(
            '분석을 시작할\n준비가 되었습니다',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'AI가 당신의 관상을 상세하게 분석합니다',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          // Preview Card
          if (_uploadResult != null)
            TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _uploadResult!.type == ImageUploadType.instagram
                            ? Icons.link
                            : Icons.check_circle,
                        color: TossDesignSystem.successGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _uploadResult!.type == ImageUploadType.instagram
                            ? '인스타그램 프로필 준비됨'
                            : '사진 준비됨',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_uploadResult!.imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _uploadResult!.imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_uploadResult!.instagramUrl != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [TossDesignSystem.purple, TossDesignSystem.pinkPrimary, TossDesignSystem.warningOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: TossDesignSystem.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _uploadResult!.instagramUrl!,
                            style: TossDesignSystem.body2.copyWith(
                              color: TossDesignSystem.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Analysis Features
          TossCard(
            style: TossCardStyle.outlined,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI가 분석할 내용',
                  style: TossDesignSystem.heading4.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem('얼굴형과 이목구비 특징', Icons.face, isDark),
                _buildFeatureItem('성격과 기질 분석', Icons.psychology, isDark),
                _buildFeatureItem('재물운과 사업운', Icons.attach_money, isDark),
                _buildFeatureItem('연애운과 결혼운', Icons.favorite, isDark),
                _buildFeatureItem('종합 운세와 조언', Icons.auto_awesome, isDark),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

              const SizedBox(height: 100), // Bottom spacing for floating button
            ],
          ),
        ),

        // Floating Bottom Button
        TossFloatingProgressButtonPositioned(
          text: _isAnalyzing ? 'AI가 분석 중...' : 'AI 관상 분석 시작',
          isEnabled: !_isAnalyzing,
          showProgress: false,
          isVisible: true,
          onPressed: _isAnalyzing ? null : () async {
            // ✅ InterstitialAd 제거: 바로 분석 시작
            await _startAnalysis();
          },
          isLoading: _isAnalyzing,
          icon: _isAnalyzing ? null : const Icon(Icons.psychology, size: 20, color: TossDesignSystem.white),
        ),
      ],
    );
  }
  
  Widget _buildFeatureItem(String text, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: TossDesignSystem.purple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _startAnalysis() async {
    debugPrint('🎯 [FaceReadingFortunePage] _startAnalysis started');
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // ✅ Premium 상태 확인
      // ⚠️ 관상 테스트용: Debug Premium 무시, 실제 토큰만 체크
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = realPremium;  // Debug Premium 무시

      debugPrint('💎 [FaceReadingFortunePage] Premium 상태: $isPremium (real: $realPremium)');

      Map<String, dynamic> inputConditions = {
        'analysis_type': 'comprehensive',
        'include_character': true,
        'include_fortune': true,
        'isPremium': isPremium, // ✅ isPremium 추가
      };

      debugPrint('📸 [FaceReadingFortunePage] Upload result type: ${_uploadResult?.type}');

      if (_uploadResult?.imageFile != null) {
        final bytes = await _uploadResult!.imageFile!.readAsBytes();
        debugPrint('📏 [FaceReadingFortunePage] Image size: ${bytes.length} bytes (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');

        if (bytes.length > 5 * 1024 * 1024) {
          throw '이미지 크기가 너무 큽니다. 5MB 이하의 이미지를 선택해주세요.';
        }
        inputConditions['image'] = base64Encode(bytes);
        inputConditions['analysis_source'] = 'image';
        debugPrint('✅ [FaceReadingFortunePage] Image encoded to base64, source: image');
      } else if (_uploadResult?.instagramUrl != null) {
        inputConditions['instagram_url'] = _uploadResult!.instagramUrl;
        inputConditions['analysis_source'] = 'instagram';
        debugPrint('✅ [FaceReadingFortunePage] Using Instagram URL: ${_uploadResult!.instagramUrl}');
      } else {
        debugPrint('❌ [FaceReadingFortunePage] No image or Instagram URL provided');
        throw '분석할 이미지를 선택해주세요.';
      }

      // 이미지 해시 생성
      String imageHash;
      if (_uploadResult?.imageFile != null) {
        final bytes = await _uploadResult!.imageFile!.readAsBytes();
        imageHash = sha256.convert(bytes).toString();
      } else if (_uploadResult?.instagramUrl != null) {
        imageHash = sha256.convert(utf8.encode(_uploadResult!.instagramUrl!)).toString();
      } else {
        throw '분석할 이미지를 선택해주세요.';
      }

      // Optimization conditions 생성
      final conditions = FaceReadingFortuneConditions(
        faceImageHash: imageHash,
        gender: inputConditions['gender'] as String?,
        age: inputConditions['age'] as int?,
      );

      final fortuneService = UnifiedFortuneService(Supabase.instance.client);
      final result = await fortuneService.getFortune(
        fortuneType: 'face-reading',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
      );

      if (mounted) {
        setState(() {
          _fortuneResult = _convertToFortuneResult(result, isPremium);
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [FaceReadingFortunePage] Error in _startAnalysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  FortuneResult _convertToFortuneResult(core_models.FortuneResult coreResult, bool isPremium) {
    // ✅ Edge Function 응답 구조에 맞게 수정
    final detailsData = coreResult.data['details'] as Map<String, dynamic>?;

    // details를 sections 형식으로 변환 (UI 호환성)
    final Map<String, String>? sections = detailsData?.map(
      (key, value) => MapEntry(key, value?.toString() ?? '')
    );

    // ✅ 블러 처리 로직
    final isBlurred = !isPremium;
    final blurredSections = isBlurred
        ? [
            'personality',        // 성격과 기질
            'wealth_fortune',     // 재물운
            'love_fortune',       // 애정운
            'health_fortune',     // 건강운
            'career_fortune',     // 직업운
            'special_features',   // 특별한 관상 특징
            'advice',             // 조언과 개운법
            'full_analysis',      // 전체 분석
          ]
        : <String>[];

    debugPrint('🔒 [FaceReadingFortunePage] isBlurred: $isBlurred, blurredSections: $blurredSections');

    return FortuneResult(
      mainFortune: coreResult.data['mainFortune'] as String?,  // ✅ 무료: 전체적인 인상
      sections: sections,  // 🔒 프리미엄: 상세 분석
      overallScore: coreResult.data['luckScore'] as int?,  // ✅ 무료: 운세 점수
      recommendations: (coreResult.data['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      details: coreResult.data,
      isBlurred: isBlurred,  // ✅ 블러 상태
      blurredSections: blurredSections,  // ✅ 블러 섹션
    );
  }

  // ✅ 광고 시청 후 블러 해제 메서드
  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    debugPrint('[FaceReadingFortunePage] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService();

      // 광고가 준비 안됐으면 로드 (두 번 클릭 방지)
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 광고 로드 시작
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 타임아웃 처리
        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      // 2. 광고 표시
      debugPrint('[FaceReadingFortunePage] 광고 표시 시작');
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[FaceReadingFortunePage] 광고 보상 획득, 블러 해제');

          // ✅ 블러 해제 - copyWith로 isBlurred를 false로 변경
          if (mounted) {
            setState(() {
              _fortuneResult = _fortuneResult!.copyWith(
                isBlurred: false,
                blurredSections: [],
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('관상 운세가 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[FaceReadingFortunePage] 광고 표시 실패: $e\n$stackTrace');

      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (_fortuneResult != null && mounted) {
        setState(() {
          _fortuneResult = _fortuneResult!.copyWith(
            isBlurred: false,
            blurredSections: [],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시에 실패했지만 운세를 확인할 수 있습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 🌟 운세 섹션 빌더 (점수바 + 블러 지원)
  Widget _buildFortuneSection({
    required IconData icon,
    required String title,
    required String content,
    required int score,
    required Color color,
    required bool isDark,
    required FortuneResult result,
    required String sectionKey,
    required int delay,
  }) {
    Widget cardContent = TossCard(
      style: TossCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 점수 바
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? TossDesignSystem.grayDark300.withValues(alpha: 0.3)
                                  : TossDesignSystem.gray300.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$score점',
                          style: TossDesignSystem.body2.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );

    // 블러가 필요 없거나, 해당 섹션이 블러 대상이 아니면 그대로 반환
    if (!result.isBlurred || !result.blurredSections.contains(sectionKey)) {
      return cardContent.animate().fadeIn(duration: 500.ms, delay: delay.ms).slideY(begin: 0.1);
    }

    // ✅ MBTI 스타일 블러 적용
    return Stack(
      children: [
        // 원본 콘텐츠 (블러 처리)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: cardContent,
        ),

        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.3),
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // 중앙 잠금 아이콘만 표시
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 40,
              color: (isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight)
                  .withValues(alpha: 0.4),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: TossDesignSystem.tossBlue.withValues(alpha: 0.2)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).slideY(begin: 0.1);
  }

  // ✅ _buildBlurWrapper 제거 - UnifiedBlurWrapper 사용

  Widget _buildTossStyleResult(BuildContext context, FortuneResult result, bool isDark) {
    // ✅ 실제 데이터는 result.details.details에 있음!
    final rawData = result.details ?? {};
    final data = (rawData['details'] as Map<String, dynamic>?) ?? rawData;
    final luckScore = ((rawData['luckScore'] ?? result.overallScore) ?? 75).toInt();

    // 🔍 디버그: 데이터 구조 확인
    print('🔍 [FaceReading] rawData keys: ${rawData.keys.toList()}');
    print('🔍 [FaceReading] data keys: ${data.keys.toList()}');
    print('🔍 [FaceReading] ogwan: ${data['ogwan']}');
    print('🔍 [FaceReading] wealth_fortune: ${data['wealth_fortune']}');
    print('🔍 [FaceReading] overall_fortune: ${data['overall_fortune']}');

    return Column(
      children: [
        // 🎯 관상 점수 게이지
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.purple.withValues(alpha:0.15),
                TossDesignSystem.tossBlue.withValues(alpha:0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: TossDesignSystem.purple.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 얼굴 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [TossDesignSystem.purple, TossDesignSystem.tossBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.purple.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.face,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // 관상 타입
              Text(
                data['face_type'] ?? '관상 분석 완료',
                style: TossDesignSystem.heading2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // 점수 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$luckScore',
                    style: TypographyUnified.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [TossDesignSystem.purple, TossDesignSystem.tossBlue],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '점',
                    style: TossDesignSystem.heading4.copyWith(
                      color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 점수 게이지 바
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: luckScore / 100,
                  minHeight: 12,
                  backgroundColor: isDark
                    ? TossDesignSystem.grayDark300.withValues(alpha: 0.3)
                    : TossDesignSystem.gray300.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(
                    luckScore >= 80 ? TossDesignSystem.purple : TossDesignSystem.tossBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 전체적인 인상
              if (data['overall_fortune'] != null)
                Text(
                  data['overall_fortune'],
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),

        const SizedBox(height: 24),

        // 🌟 전통 관상학: 오관(五官) 분석
        if (data['ogwan'] != null) ...[
          _buildOgwanSection(
            data: data,
            result: result,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],

        // 🌟 구버전 하위 호환: 4대 운세 (기존 DB 데이터용)
        if (data['ogwan'] == null && data['wealth_fortune'] != null) ...[
          _buildFortuneSection(
            icon: Icons.monetization_on,
            title: '재물운',
            content: data['wealth_fortune']?.toString() ?? '재물운이 상승하는 시기입니다.',
            score: 85,
            color: Colors.amber,
            isDark: isDark,
            result: result,
            sectionKey: 'wealth_fortune',
            delay: 100,
          ),
          const SizedBox(height: 16),

          _buildFortuneSection(
            icon: Icons.favorite,
            title: '애정운',
            content: data['love_fortune']?.toString() ?? '인연이 다가오고 있습니다.',
            score: 78,
            color: Colors.pink,
            isDark: isDark,
            result: result,
            sectionKey: 'love_fortune',
            delay: 200,
          ),
          const SizedBox(height: 16),

          _buildFortuneSection(
            icon: Icons.health_and_safety,
            title: '건강운',
            content: data['health_fortune']?.toString() ?? '건강 관리에 신경쓰면 좋은 결과가 있을 것입니다.',
            score: 72,
            color: Colors.green,
            isDark: isDark,
            result: result,
            sectionKey: 'health_fortune',
            delay: 300,
          ),
          const SizedBox(height: 16),

          _buildFortuneSection(
            icon: Icons.work,
            title: '직업운',
            content: data['career_fortune']?.toString() ?? '새로운 기회가 찾아올 것입니다.',
            score: 80,
            color: TossDesignSystem.tossBlue,
            isDark: isDark,
            result: result,
            sectionKey: 'career_fortune',
            delay: 400,
          ),
          const SizedBox(height: 24),
        ],

        // 🌟 전통 관상학: 삼정(三停) 분석
        if (data['samjeong'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'samjeong',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.linear_scale, color: TossDesignSystem.tossBlue, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '삼정(三停) 분석',
                        style: TossDesignSystem.heading3.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '상정(초년운), 중정(중년운), 하정(말년운)',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['samjeong'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 🌟 전통 관상학: 십이궁(十二宮) 분석
        if (data['sibigung'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'sibigung',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.grid_view, color: TossDesignSystem.purple, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '십이궁(十二宮) 분석',
                        style: TossDesignSystem.heading3.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '얼굴 12개 영역의 상세 분석',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['sibigung'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 🧠 성격과 기질 (🔒 프리미엄)
        if (data['personality'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'personality',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: TossDesignSystem.purple),
                      const SizedBox(width: 8),
                      Text(
                        '성격과 기질',
                        style: TossDesignSystem.heading4.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: TossDesignSystem.purple),
                            const SizedBox(width: 4),
                            Text(
                              '프리미엄',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['personality'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
          const SizedBox(height: 16),
        ],

        // ✨ 특별한 관상 특징 (🔒 프리미엄)
        if (data['special_features'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'special_features',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: TossDesignSystem.tossBlue),
                      const SizedBox(width: 8),
                      Text(
                        '특별한 관상 특징',
                        style: TossDesignSystem.heading4.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: TossDesignSystem.tossBlue),
                            const SizedBox(width: 4),
                            Text(
                              '프리미엄',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.tossBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['special_features'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
          const SizedBox(height: 16),
        ],

        // 💡 조언과 개운법 (🔒 프리미엄)
        if (data['advice'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'advice',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '조언과 개운법',
                        style: TossDesignSystem.heading4.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '프리미엄',
                              style: TossDesignSystem.caption.copyWith(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['advice'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
          const SizedBox(height: 16),
        ],

        // 📖 전체 분석 (🔒 프리미엄)
        if (data['full_analysis'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: result.isBlurred,
            blurredSections: result.blurredSections,
            sectionKey: 'full_analysis',
            child: TossCard(
              style: TossCardStyle.filled,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: TossDesignSystem.gray700),
                      const SizedBox(width: 8),
                      Text(
                        '전체 분석',
                        style: TossDesignSystem.heading4.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TossDesignSystem.gray700.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: TossDesignSystem.gray700),
                            const SizedBox(width: 4),
                            Text(
                              '프리미엄',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.gray700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['full_analysis'].toString(),
                    style: TossDesignSystem.body1.copyWith(
                      color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
          const SizedBox(height: 20),
        ],
        
        // Character Analysis
        if (data['character_traits'] != null) ...[
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: TossDesignSystem.warningOrange),
                    const SizedBox(width: 8),
                    Text(
                      '성격 분석',
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (data['character_traits'] as List<dynamic>).map((trait) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.warningOrange.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TossDesignSystem.warningOrange.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        trait.toString(),
                        style: TossDesignSystem.body3.copyWith(
                          color: TossDesignSystem.warningOrange,
                        ),
                      ),
                    )
                  ).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          const SizedBox(height: 20),
        ],
        
        // Recommendations
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen.withValues(alpha:0.1),
                  TossDesignSystem.tossBlue.withValues(alpha:0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: TossDesignSystem.successGreen),
                    const SizedBox(width: 8),
                    Text(
                      '운세 개선 조언',
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: TossDesignSystem.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TossDesignSystem.body2.copyWith(
                            color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
        ],
      ],
    );
  }
  
  Widget _buildFacePartAnalysis(String part, String analysis, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part,
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analysis,
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
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
  
  String _translateFacePart(String part) {
    final translations = {
      'forehead': '이마',
      'eyes': '눈',
      'nose': '코',
      'mouth': '입',
      'chin': '턱',
      'cheeks': '볼',
      'eyebrows': '눈썹',
      'ears': '귀'
    };
    return translations[part] ?? part;
  }
  
  IconData _getFacePartIcon(String part) {
    final icons = {
      'forehead': Icons.face,
      'eyes': Icons.remove_red_eye,
      'nose': Icons.face,
      'mouth': Icons.sentiment_satisfied,
      'chin': Icons.face,
      'cheeks': Icons.face,
      'eyebrows': Icons.face,
      'ears': Icons.hearing
    };
    return icons[part] ?? Icons.face;
  }

  // 🌟 오관(五官) 섹션 빌더
  Widget _buildOgwanSection({
    required Map<String, dynamic> data,
    required FortuneResult result,
    required bool isDark,
  }) {
    final ogwan = data['ogwan'] as Map<String, dynamic>?;
    if (ogwan == null) return const SizedBox.shrink();

    final ogwanItems = [
      {
        'key': 'ear',
        'title': '귀(耳) - 채청관',
        'subtitle': '복록과 수명',
        'icon': Icons.hearing,
        'color': TossDesignSystem.purple,
      },
      {
        'key': 'eyebrow',
        'title': '눈썹(眉) - 보수관',
        'subtitle': '형제와 친구',
        'icon': Icons.remove_red_eye_outlined,
        'color': TossDesignSystem.tossBlue,
      },
      {
        'key': 'eye',
        'title': '눈(目) - 감찰관',
        'subtitle': '마음의 창',
        'icon': Icons.remove_red_eye,
        'color': TossDesignSystem.successGreen,
      },
      {
        'key': 'nose',
        'title': '코(鼻) - 심변관',
        'subtitle': '재물의 중심',
        'icon': Icons.air,
        'color': Colors.amber,
      },
      {
        'key': 'mouth',
        'title': '입(口) - 출납관',
        'subtitle': '식복과 언변',
        'icon': Icons.sentiment_satisfied,
        'color': Colors.pink,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오관 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.face_retouching_natural, color: TossDesignSystem.purple, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오관(五官) 분석',
                    style: TossDesignSystem.heading2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '전통 관상학의 핵심 - 얼굴 5대 관문',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 오관 카드들
        ...ogwanItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final key = item['key'] as String;
          final content = ogwan[key]?.toString();

          if (content == null || content.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UnifiedBlurWrapper(
              isBlurred: result.isBlurred,
              blurredSections: result.blurredSections,
              sectionKey: 'ogwan',
              child: TossCard(
                style: TossCardStyle.filled,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: item['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TossDesignSystem.heading4.copyWith(
                                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: TossDesignSystem.caption.copyWith(
                                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TossDesignSystem.body1.copyWith(
                        color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: (100 * index).ms),
          );
        }),
      ],
    );
  }
}