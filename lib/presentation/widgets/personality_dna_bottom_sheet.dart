import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/widgets/unified_button_enums.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../core/services/personality_dna_service.dart';
import '../../core/models/personality_dna_model.dart';
import '../../presentation/providers/providers.dart';

import '../../features/fortune/presentation/widgets/personality_dna/personality_dna_result_page.dart';
import '../providers/subscription_provider.dart';

/// 성격 DNA 입력을 위한 BottomSheet
class PersonalityDNABottomSheet extends ConsumerStatefulWidget {
  final Function(PersonalityDNA)? onResult;

  const PersonalityDNABottomSheet({
    super.key,
    this.onResult,
  });

  @override
  ConsumerState<PersonalityDNABottomSheet> createState() =>
      _PersonalityDNABottomSheetState();
}

class _PersonalityDNABottomSheetState
    extends ConsumerState<PersonalityDNABottomSheet> {
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar (토스 스타일)
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: context.isDark
                  ? DSColors.border
                  : DSColors.borderDark,
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
                        _showDetailedView ? '성격 탐구 정보 입력' : '나의 성격 탐구',
                        style: context.displaySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.isDark
                              ? DSColors.textPrimary
                              : DSColors.textPrimaryDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showDetailedView
                            ? '4가지 정보를 선택해 주세요'
                            : '현재 설정을 확인하고 DNA 분석을 시작하세요',
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          color: context.isDark
                              ? DSColors.toggleInactive
                              : DSColors.textSecondaryDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? DSColors.surfaceSecondary
                          : DSColors.backgroundSecondaryDark,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.isDark
                          ? DSColors.toggleInactive
                          : DSColors.textSecondaryDark,
                      size: 20.0,
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

          // Bottom Button (Floating 스타일 - 배경 없음)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            color: Colors.transparent, // 완전히 투명한 배경
            child: SafeArea(
              child: _showDetailedView
                  ? Row(
                      children: [
                        Expanded(
                          child: UnifiedButton(
                            text: '이전',
                            onPressed: () {
                              setState(() {
                                _showDetailedView = false;
                              });
                            },
                            style: UnifiedButtonStyle.secondary,
                            size: UnifiedButtonSize.large,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: UnifiedButton(
                            text: '🧬 나의 성격 탐구하기',
                            onPressed: _canGenerate && !_isLoading
                                ? _generatePersonalityDNA
                                : null,
                            style: UnifiedButtonStyle.primary,
                            size: UnifiedButtonSize.large,
                            isLoading: _isLoading,
                            isEnabled: _canGenerate && !_isLoading,
                          ),
                        ),
                      ],
                    )
                  : UnifiedButton(
                      text: _canGenerate ? '🧬 나의 성격 탐구하기' : '📝 정보 수정하기',
                      onPressed: _canGenerate && !_isLoading
                          ? _generatePersonalityDNA
                          : () {
                              setState(() {
                                _showDetailedView = true;
                              });
                            },
                      style: UnifiedButtonStyle.primary,
                      size: UnifiedButtonSize.large,
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
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDark
                  ? DSColors.textPrimary
                  : DSColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 20),

          // 정보 카드들
          _buildSummaryCard('MBTI', _selectedMbti ?? '미설정', '🧠'),
          const SizedBox(height: 12),
          _buildSummaryCard(
              '혈액형',
              _selectedBloodType != null ? '$_selectedBloodType형' : '미설정',
              '🩸'),
          const SizedBox(height: 12),
          _buildSummaryCard('별자리', _selectedZodiac ?? '미설정', '⭐'),
          const SizedBox(height: 12),
          _buildSummaryCard('띠 (12지)', _selectedZodiacAnimal ?? '미설정', '🐉'),

          const SizedBox(height: 30),

          // 설명 텍스트
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.isDark
                  ? DSColors.surfaceSecondary
                  : DSColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 성격 DNA란?',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.isDark
                        ? DSColors.textPrimary
                        : DSColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MBTI, 혈액형, 별자리, 띠를 조합하여 당신만의 독특한 성격 분석 결과를 만들어드립니다.',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w400,
                    color: context.isDark
                        ? DSColors.textTertiary
                        : DSColors.textSecondaryDark,
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
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSet
              ? (context.isDark
                  ? DSColors.accentDark.withValues(alpha: 0.3)
                  : DSColors.accentDark.withValues(alpha: 0.2))
              : (context.isDark
                  ? DSColors.border
                  : DSColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSet
                  ? DSColors.accentDark.withValues(alpha: 0.1)
                  : (context.isDark
                      ? DSColors.surfaceSecondary
                      : DSColors.backgroundSecondaryDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: context.heading3,
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
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.isDark
                        ? DSColors.textTertiary
                        : DSColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSet
                        ? (context.isDark
                            ? DSColors.textPrimary
                            : DSColors.textPrimaryDark)
                        : (context.isDark
                            ? DSColors.toggleInactive
                            : DSColors.textDisabledDark),
                  ),
                ),
              ],
            ),
          ),
          if (!isSet)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.isDark
                  ? DSColors.toggleInactive
                  : DSColors.textDisabledDark,
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
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? DSColors.border
              : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MBTI 유형',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDark
                  ? DSColors.textPrimary
                  : DSColors.textPrimaryDark,
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
                        ? DSColors.accentDark
                        : (context.isDark
                            ? DSColors.surfaceSecondary
                            : DSColors.backgroundSecondaryDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.accentDark
                          : (context.isDark
                              ? DSColors.border
                              : DSColors.borderDark),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mbti,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (context.isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimaryDark),
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
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? DSColors.border
              : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '혈액형',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDark
                  ? DSColors.textPrimary
                  : DSColors.textPrimaryDark,
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
                            ? DSColors.accentDark
                            : (context.isDark
                                ? DSColors.surfaceSecondary
                                : DSColors.backgroundSecondaryDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? DSColors.accentDark
                              : (context.isDark
                                  ? DSColors.border
                                  : DSColors.borderDark),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$bloodType형',
                          style: context.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? DSColors.textPrimary
                                    : DSColors.textPrimaryDark),
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
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? DSColors.border
              : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '별자리',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDark
                  ? DSColors.textPrimary
                  : DSColors.textPrimaryDark,
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
                        ? DSColors.accentDark
                        : (context.isDark
                            ? DSColors.surfaceSecondary
                            : DSColors.backgroundSecondaryDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.accentDark
                          : (context.isDark
                              ? DSColors.border
                              : DSColors.borderDark),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      zodiac,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (context.isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimaryDark),
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
        color: context.isDark
            ? DSColors.surface
            : DSColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? DSColors.border
              : DSColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '띠 (12지)',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: context.isDark
                  ? DSColors.textPrimary
                  : DSColors.textPrimaryDark,
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
                        ? DSColors.accentDark
                        : (context.isDark
                            ? DSColors.surfaceSecondary
                            : DSColors.backgroundSecondaryDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? DSColors.accentDark
                          : (context.isDark
                              ? DSColors.border
                              : DSColors.borderDark),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      animal,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (context.isDark
                                ? DSColors.textPrimary
                                : DSColors.textPrimaryDark),
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
      await _processPersonalityDNA();
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
        name: userProfile.name,
        mbti: _selectedMbti!,
        bloodType: _selectedBloodType!,
        zodiac: _selectedZodiac!,
        zodiacAnimal: _selectedZodiacAnimal!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 구독 상태 확인
        final isSubscriber = ref.read(isSubscriptionActiveProvider);

        // BottomSheet 닫기
        Navigator.of(context).pop();

        // 결과 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PersonalityDnaResultPage(
              dna: personalityDNA,
              isPremium: isSubscriber,
            ),
          ),
        );

        // 콜백도 호출 (채팅에서 결과 메시지 추가용)
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
