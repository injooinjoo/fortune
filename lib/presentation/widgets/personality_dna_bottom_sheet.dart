import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/components/loading_elevated_button.dart';
import '../../shared/components/toss_button.dart';
import '../../services/ad_service.dart';
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
      decoration: const BoxDecoration(
        color: Colors.white, // 토스 스타일: 깨끗한 화이트 배경
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
              color: const Color(0xFFE5E5E5),
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
                      const Text(
                        '성격 DNA 분석',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191F28),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '4가지 정보로 당신만의 DNA를 만들어보세요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8B95A1),
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
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF8B95A1),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
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
            ),
          ),
          
          // Generate Button (토스 스타일)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF0F0F0),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: TossButton(
                text: '🧬 나만의 성격 DNA 발견하기',
                onPressed: _canGenerate && !_isLoading
                    ? _generatePersonalityDNA
                    : null,
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
                isLoading: _isLoading,
                isEnabled: _canGenerate && !_isLoading,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMbtiSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MBTI 유형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
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
                        ? const Color(0xFF1F4EF5) // 토스 블루
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1F4EF5)
                          : const Color(0xFFE5E5E5),
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
                            ? Colors.white 
                            : const Color(0xFF191F28),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '혈액형',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
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
                            ? const Color(0xFF1F4EF5) // 토스 블루
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1F4EF5)
                              : const Color(0xFFE5E5E5),
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
                                ? Colors.white 
                                : const Color(0xFF191F28),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '별자리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
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
                        ? const Color(0xFF1F4EF5) // 토스 블루
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1F4EF5)
                          : const Color(0xFFE5E5E5),
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
                            ? Colors.white 
                            : const Color(0xFF191F28),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '띠 (12지)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
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
                        ? const Color(0xFF1F4EF5) // 토스 블루
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1F4EF5)
                          : const Color(0xFFE5E5E5),
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
                            ? Colors.white 
                            : const Color(0xFF191F28),
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