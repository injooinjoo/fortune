import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/image_upload_selector.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../services/ad_service.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart' as core_models;
import '../../domain/models/conditions/face_reading_fortune_conditions.dart';
import 'package:crypto/crypto.dart';

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
      appBar: const StandardFortuneAppBar(
        title: '관상',
      ),
      body: _fortuneResult != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildTossStyleResult(context, _fortuneResult!, isDark),
            )
          : _buildTossStyleInputSection(context, isDark),
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
            // 광고 시작과 동시에 API 호출 시작 (async parallel pattern)
            final apiCallFuture = _startAnalysis();

            await AdService.instance.showInterstitialAdWithCallback(
              onAdCompleted: () async {
                // 광고 완료 후 API 결과 대기
                await apiCallFuture;
              },
              onAdFailed: () async {
                // 광고 실패해도 API 결과 대기
                await apiCallFuture;
              },
            );
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
      Map<String, dynamic> inputConditions = {
        'analysis_type': 'comprehensive',
        'include_character': true,
        'include_fortune': true,
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
          _fortuneResult = _convertToFortuneResult(result);
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

  FortuneResult _convertToFortuneResult(core_models.FortuneResult coreResult) {
    final sectionsData = coreResult.data['sections'] as Map<String, dynamic>?;
    final Map<String, String>? sections = sectionsData?.map((key, value) => MapEntry(key, value.toString()));

    return FortuneResult(
      mainFortune: coreResult.summary['message'] as String?,
      sections: sections,
      recommendations: (coreResult.data['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      details: coreResult.data,
    );
  }
  
  Widget _buildTossStyleResult(BuildContext context, FortuneResult result, bool isDark) {
    final data = result.details ?? {};
    
    return Column(
      children: [
        // Face Analysis Summary
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TossDesignSystem.purple.withValues(alpha:0.1),
                TossDesignSystem.tossBlue.withValues(alpha:0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.face,
                size: 64,
                color: TossDesignSystem.purple,
              ),
              const SizedBox(height: 16),
              Text(
                data['face_type'] ?? '관상 분석 완료',
                style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 8),
              if (data['overall_fortune'] != null)
                Text(
                  data['overall_fortune'],
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
        
        const SizedBox(height: 20),
        // Main Fortune
        if (result.mainFortune != null) ...[
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: TossDesignSystem.purple),
                    const SizedBox(width: 8),
                    Text(
                      '종합 관상 분석',
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.mainFortune!,
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 20),
        ],
        
        // Face Parts Analysis
        if (result.sections != null && result.sections!.isNotEmpty) ...[
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.face_retouching_natural, color: TossDesignSystem.tossBlue),
                    const SizedBox(width: 8),
                    Text(
                      '부위별 분석',
                      style: TossDesignSystem.heading4.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.sections!.entries.map((entry) => _buildFacePartAnalysis(
                  _translateFacePart(entry.key),
                  entry.value,
                  _getFacePartIcon(entry.key),
                  isDark
                )),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
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
}