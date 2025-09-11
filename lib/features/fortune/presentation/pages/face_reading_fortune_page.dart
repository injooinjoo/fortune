import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/image_upload_selector.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import 'package:fortune/data/services/fortune_api_service.dart';
import 'package:fortune/presentation/providers/providers.dart';
import '../../../../services/ad_service.dart';

class FaceReadingFortunePage extends ConsumerStatefulWidget {
  const FaceReadingFortunePage({super.key});

  @override
  ConsumerState<FaceReadingFortunePage> createState() => _FaceReadingFortunePageState();
}

class _FaceReadingFortunePageState extends ConsumerState<FaceReadingFortunePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  ImageUploadResult? _uploadResult;
  bool _isAnalyzing = false;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BaseFortunePageV2(
      title: 'AI 관상 분석',
      fortuneType: 'face-reading',
      headerGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TossDesignSystem.purple,
          TossDesignSystem.tossBlue,
        ],
      ),
      inputBuilder: (context, onSubmit) => _buildTossStyleInputSection(context, onSubmit, isDark),
      resultBuilder: (context, result, onShare) => _buildTossStyleResult(context, result, isDark)
    );
  }
  
  Widget _buildTossStyleInputSection(BuildContext context, Function(Map<String, dynamic>) onSubmit, bool isDark) {
    return Column(
      children: [
        // Progress Indicator
        _buildProgressIndicator(isDark),
        const SizedBox(height: 24),
        
        // Page View for Steps
        SizedBox(
          height: 600,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(context, isDark),
              _buildStep2(context, onSubmit, isDark),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 1
                        ? TossDesignSystem.purple
                        : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentStep == 0 ? '사진 선택' : 'AI 분석',
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
            ),
          ),
        ],
      ),
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
                  _currentStep = 1;
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
  
  Widget _buildStep2(BuildContext context, Function(Map<String, dynamic>) onSubmit, bool isDark) {
    return SingleChildScrollView(
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
                          colors: [Colors.purple, Colors.pink, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _uploadResult!.instagramUrl!,
                            style: TossDesignSystem.body2.copyWith(
                              color: Colors.white,
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
          
          const SizedBox(height: 32),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: TossButton.primary(
              text: _isAnalyzing ? 'AI가 분석 중...' : 'AI 관상 분석 시작',
              onPressed: _isAnalyzing ? null : () async {
                await AdService.instance.showInterstitialAdWithCallback(
                  onAdCompleted: () {
                    _startAnalysis(onSubmit);
                  },
                  onAdFailed: () {
                    // Still allow fortune generation even if ad fails
                    _startAnalysis(onSubmit);
                  },
                );
              },
              isEnabled: !_isAnalyzing,
              isLoading: _isAnalyzing,
              icon: _isAnalyzing ? null : const Icon(Icons.psychology, size: 20, color: Colors.white),
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: TossButton.secondary(
              text: '다시 선택',
              onPressed: _isAnalyzing ? null : () {
                setState(() {
                  _currentStep = 0;
                  _uploadResult = null;
                });
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),
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
              color: TossDesignSystem.purple.withOpacity(0.1),
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
  
  Future<void> _startAnalysis(Function(Map<String, dynamic>) onSubmit) async {
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      Map<String, dynamic> data = {
        'analysis_type': 'comprehensive',
        'include_character': true,
        'include_fortune': true,
      };
      
      if (_uploadResult?.imageFile != null) {
        final bytes = await _uploadResult!.imageFile!.readAsBytes();
        data['image'] = base64Encode(bytes);
      } else if (_uploadResult?.instagramUrl != null) {
        data['instagram_url'] = _uploadResult!.instagramUrl;
        data['analysis_source'] = 'instagram';
      }
      
      onSubmit(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
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
                TossDesignSystem.purple.withOpacity(0.1),
                TossDesignSystem.tossBlue.withOpacity(0.1),
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
                        color: TossDesignSystem.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TossDesignSystem.warningOrange.withOpacity(0.3),
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
                  TossDesignSystem.successGreen.withOpacity(0.1),
                  TossDesignSystem.tossBlue.withOpacity(0.1),
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
              color: TossDesignSystem.tossBlue.withOpacity(0.1),
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