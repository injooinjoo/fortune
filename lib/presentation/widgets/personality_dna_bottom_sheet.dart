import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/components/loading_elevated_button.dart';
import '../../shared/components/toss_button.dart';
import '../../services/ad_service.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/services/personality_dna_service.dart';
import '../../core/models/personality_dna_model.dart';
import '../../presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

/// 성격 DNA 입력을 위한 BottomSheet
class PersonalityDNABottomSheet extends ConsumerStatefulWidget {
  final Function(PersonalityDNA)? onResult;

  const PersonalityDNABottomSheet({
    super.key,
    this.onResult,
  });

  @override
  ConsumerState<PersonalityDNABottomSheet> createState() => _PersonalityDNABottomSheetState();
}

class _PersonalityDNABottomSheetState extends ConsumerState<PersonalityDNABottomSheet> {
  String? _selectedMbti;
  String? _selectedBloodType;
  String? _selectedZodiac;
  String? _selectedZodiacAnimal;
  bool _isLoading = false;
  bool _showDetailedView = false; // 상세 선택 화면 표시 여부

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile != null && mounted) {
        setState(() {
          _selectedMbti = userProfile.mbtiType;
          _selectedBloodType = userProfile.bloodType;
          _selectedZodiac = userProfile.zodiacSign;
          _selectedZodiacAnimal = userProfile.chineseZodiac;
        });
      }
    } catch (e) {
      // 프로필 로드 실패해도 계속 진행
    }
  }

  bool get _canGenerate => 
    _selectedMbti != null && 
    _selectedBloodType != null && 
    _selectedZodiac != null && 
    _selectedZodiacAnimal != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar (토스 스타일)
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark300
                  : TossDesignSystem.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header (토스 스타일: 심플하고 깔끔)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showDetailedView ? '성격 DNA 정보 입력' : '성격 DNA 분석',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark900
                              : TossDesignSystem.gray900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showDetailedView
                            ? '4가지 정보를 선택해 주세요'
                            : '현재 설정을 확인하고 DNA 분석을 시작하세요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark400
                              : TossDesignSystem.gray600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? TossDesignSystem.grayDark200
                          : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? TossDesignSystem.grayDark400
                          : TossDesignSystem.gray600,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content - 조건부 렌더링
          Expanded(
            child: _showDetailedView
                ? _buildDetailedSelectionView()
                : _buildSummaryView(),
          ),
          
          // Bottom Button (토스 스타일)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark100
                  : TossDesignSystem.white,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.grayDark300
                      : TossDesignSystem.gray200,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: _showDetailedView
                  ? Row(
                      children: [
                        Expanded(
                          child: TossButton(
                            text: '이전',
                            onPressed: () {
                              setState(() {
                                _showDetailedView = false;
                              });
                            },
                            style: TossButtonStyle.secondary,
                            size: TossButtonSize.large,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TossButton(
                            text: '🧬 나만의 성격 DNA 발견하기',
                            onPressed: _canGenerate && !_isLoading
                                ? _generatePersonalityDNA
                                : null,
                            style: TossButtonStyle.primary,
                            size: TossButtonSize.large,
                            isLoading: _isLoading,
                            isEnabled: _canGenerate && !_isLoading,
                          ),
                        ),
                      ],
                    )
                  : TossButton(
                      text: _canGenerate
                          ? '🧬 나만의 성격 DNA 발견하기'
                          : '📝 정보 수정하기',
                      onPressed: _canGenerate && !_isLoading
                          ? _generatePersonalityDNA
                          : () {
                              setState(() {
                                _showDetailedView = true;
                              });
                            },
                      style: TossButtonStyle.primary,
                      size: TossButtonSize.large,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 요약 뷰 - 현재 선택된 값들을 카드 형태로 표시
  Widget _buildSummaryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 설정된 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 20),

          // 정보 카드들
          _buildSummaryCard('MBTI', _selectedMbti ?? '미설정', '🧠'),
          const SizedBox(height: 12),
          _buildSummaryCard('혈액형', _selectedBloodType != null ? '${_selectedBloodType}형' : '미설정', '🩸'),
          const SizedBox(height: 12),
          _buildSummaryCard('별자리', _selectedZodiac ?? '미설정', '⭐'),
          const SizedBox(height: 12),
          _buildSummaryCard('띠 (12지)', _selectedZodiacAnimal ?? '미설정', '🐉'),

          const SizedBox(height: 30),

          // 설명 텍스트
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark200
                  : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 성격 DNA란?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark900
                        : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MBTI, 혈액형, 별자리, 띠를 조합하여 당신만의 독특한 성격 분석 결과를 만들어드립니다.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark600
                        : TossDesignSystem.gray600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// 요약 카드 위젯
  Widget _buildSummaryCard(String title, String value, String emoji) {
    final bool isSet = value != '미설정';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSet
              ? (Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.tossBlue.withOpacity(0.3)
                  : TossDesignSystem.tossBlue.withOpacity(0.2))
              : (Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark300
                  : TossDesignSystem.gray200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSet
                  ? TossDesignSystem.tossBlue.withOpacity(0.1)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? TossDesignSystem.grayDark200
                      : TossDesignSystem.gray100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.grayDark600
                        : TossDesignSystem.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSet
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark900
                            : TossDesignSystem.gray900)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark400
                            : TossDesignSystem.gray400),
                  ),
                ),
              ],
            ),
          ),
          if (!isSet)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark400
                  : TossDesignSystem.gray400,
            ),
        ],
      ),
    );
  }

  /// 상세 선택 뷰 - 기존 선택 UI들
  Widget _buildDetailedSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMbtiSelector(),
          const SizedBox(height: 20),
          _buildBloodTypeSelector(),
          const SizedBox(height: 20),
          _buildZodiacSelector(),
          const SizedBox(height: 20),
          _buildZodiacAnimalSelector(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMbtiSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MBTI 유형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: PersonalityDNAService.mbtiTypes.map((mbti) {
              final isSelected = _selectedMbti == mbti;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMbti = mbti;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark200
                            : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? TossDesignSystem.tossBlue
                          : (Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark300
                              : TossDesignSystem.gray200),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mbti,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossDesignSystem.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.grayDark900
                                : TossDesignSystem.gray900),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '혈액형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: PersonalityDNAService.bloodTypes.map((bloodType) {
              final isSelected = _selectedBloodType == bloodType;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBloodType = bloodType;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.grayDark200
                                : TossDesignSystem.gray100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? TossDesignSystem.grayDark300
                                  : TossDesignSystem.gray200),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${bloodType}형',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? TossDesignSystem.white
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? TossDesignSystem.grayDark900
                                    : TossDesignSystem.gray900),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '별자리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: PersonalityDNAService.zodiacSigns.map((zodiac) {
              final isSelected = _selectedZodiac == zodiac;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedZodiac = zodiac;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark200
                            : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? TossDesignSystem.tossBlue
                          : (Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark300
                              : TossDesignSystem.gray200),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      zodiac,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossDesignSystem.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.grayDark900
                                : TossDesignSystem.gray900),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacAnimalSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '띠 (12지)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: PersonalityDNAService.zodiacAnimals.map((animal) {
              final isSelected = _selectedZodiacAnimal == animal;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedZodiacAnimal = animal;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark200
                            : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? TossDesignSystem.tossBlue
                          : (Theme.of(context).brightness == Brightness.dark
                              ? TossDesignSystem.grayDark300
                              : TossDesignSystem.gray200),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      animal,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossDesignSystem.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.grayDark900
                                : TossDesignSystem.gray900),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePersonalityDNA() async {
    if (!_canGenerate) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 광고 표시 및 완료 대기
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () async {
          await _processPersonalityDNA();
        },
        onAdFailed: () async {
          await _processPersonalityDNA();
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _processPersonalityDNA() async {
    try {
      // 사용자 정보 가져오기
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // PersonalityDNA 생성 (API 호출)
      final personalityDNA = await PersonalityDNAService.generateDNA(
        userId: userProfile.id,
        name: userProfile.name ?? '사용자',
        mbti: _selectedMbti!,
        bloodType: _selectedBloodType!,
        zodiac: _selectedZodiac!,
        zodiacAnimal: _selectedZodiacAnimal!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // BottomSheet 닫기
        Navigator.of(context).pop();

        // 결과 전달 및 결과 페이지로 이동
        if (widget.onResult != null) {
          widget.onResult!(personalityDNA);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('성격 DNA 생성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}