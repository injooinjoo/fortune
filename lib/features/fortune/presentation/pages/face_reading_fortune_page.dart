import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../shared/components/image_upload_selector.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart' as core_models;
import '../../domain/models/conditions/face_reading_fortune_conditions.dart';
import 'package:crypto/crypto.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/widgets/unified_button.dart';

// Import modular widgets
import 'face_reading_fortune/index.dart';

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
            : null,
        automaticallyImplyLeading: _fortuneResult == null,
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
                    child: ResultWidget(
                      result: _fortuneResult!,
                      isDark: isDark,
                      onUnlockRequested: _showAdAndUnblur,
                    ),
                  )
                : _buildInputSection(context, isDark),
            // Floating Bottom Button - 결과 화면에서 블러 상태일 때만 표시
            if (_fortuneResult != null && _fortuneResult!.isBlurred)
              UnifiedButton.floating(
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

  Widget _buildInputSection(BuildContext context, bool isDark) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InputStep1Widget(
          isDark: isDark,
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
        ),
        InputStep2Widget(
          isDark: isDark,
          uploadResult: _uploadResult,
          isAnalyzing: _isAnalyzing,
          onStartAnalysis: _startAnalysis,
        ),
      ],
    );
  }

  Future<void> _startAnalysis() async {
    debugPrint('🎯 [FaceReadingFortunePage] _startAnalysis started');
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Premium 상태 확인
      final tokenState = ref.read(tokenProvider);
      final realPremium = (tokenState.balance?.remainingTokens ?? 0) > 0;
      final isPremium = realPremium;

      debugPrint('💎 [FaceReadingFortunePage] Premium 상태: $isPremium (real: $realPremium)');

      Map<String, dynamic> inputConditions = {
        'analysis_type': 'comprehensive',
        'include_character': true,
        'include_fortune': true,
        'isPremium': isPremium,
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
    final detailsData = coreResult.data['details'] as Map<String, dynamic>?;

    final Map<String, String>? sections = detailsData?.map(
      (key, value) => MapEntry(key, value?.toString() ?? '')
    );

    final isBlurred = !isPremium;
    final blurredSections = isBlurred
        ? [
            'personality',
            'wealth_fortune',
            'love_fortune',
            'health_fortune',
            'career_fortune',
            'special_features',
            'advice',
            'full_analysis',
          ]
        : <String>[];

    debugPrint('🔒 [FaceReadingFortunePage] isBlurred: $isBlurred, blurredSections: $blurredSections');

    return FortuneResult(
      mainFortune: coreResult.data['mainFortune'] as String?,
      sections: sections,
      overallScore: coreResult.data['luckScore'] as int?,
      recommendations: (coreResult.data['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      details: coreResult.data,
      isBlurred: isBlurred,
      blurredSections: blurredSections,
    );
  }

  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    debugPrint('[FaceReadingFortunePage] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

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

      debugPrint('[FaceReadingFortunePage] 광고 표시 시작');
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[FaceReadingFortunePage] 광고 보상 획득, 블러 해제');

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
}
