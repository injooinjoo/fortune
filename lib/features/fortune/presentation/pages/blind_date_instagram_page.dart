import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/blind_date_instagram_model.dart';
import '../../../../services/ad_service.dart';
import '../widgets/standard_fortune_app_bar.dart';

class BlindDateInstagramPage extends ConsumerStatefulWidget {
  const BlindDateInstagramPage({super.key});

  @override
  ConsumerState<BlindDateInstagramPage> createState() => _BlindDateInstagramPageState();
}

class _BlindDateInstagramPageState extends ConsumerState<BlindDateInstagramPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: 인스타그램 정보
  final _partnerInstagramController = TextEditingController();
  final _myInstagramController = TextEditingController();
  DateTime? _meetingDate;
  String? _meetingTime;
  String? _meetingType;
  
  // Step 2: 추가 정보
  List<String> _myInterests = [];
  String? _mainCuriosity;
  final _specialRequestController = TextEditingController();
  
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _partnerInstagramController.dispose();
    _myInstagramController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _validateStep1()) {
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1 && _validateStep2()) {
      _analyzeAndShowResult();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep1() {
    if (_partnerInstagramController.text.isEmpty) {
      _showMessage('상대방의 인스타그램 링크를 입력해주세요');
      return false;
    }
    if (!_isValidInstagramUrl(_partnerInstagramController.text)) {
      _showMessage('올바른 인스타그램 URL을 입력해주세요');
      return false;
    }
    if (_meetingDate == null) {
      _showMessage('소개팅 날짜를 선택해주세요');
      return false;
    }
    if (_meetingTime == null) {
      _showMessage('만날 시간대를 선택해주세요');
      return false;
    }
    if (_meetingType == null) {
      _showMessage('만남 방식을 선택해주세요');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_myInterests.isEmpty) {
      _showMessage('관심사를 최소 1개 이상 선택해주세요');
      return false;
    }
    if (_mainCuriosity == null) {
      _showMessage('가장 궁금한 점을 선택해주세요');
      return false;
    }
    return true;
  }

  bool _isValidInstagramUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?(www\.)?(instagram\.com|instagr\.am)/[A-Za-z0-9_\.]+/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TossDesignSystem.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Future<void> _analyzeAndShowResult() async {
    setState(() {
      _isAnalyzing = true;
    });

    final input = BlindDateInstagramInput(
      partnerInstagramUrl: _partnerInstagramController.text,
      myInstagramUrl: _myInstagramController.text.isNotEmpty 
          ? _myInstagramController.text 
          : null,
      meetingDate: _meetingDate!,
      meetingTime: _meetingTime!,
      meetingType: _meetingType!,
      myInterests: _myInterests,
      mainCuriosity: _mainCuriosity!,
      specialRequest: _specialRequestController.text.isNotEmpty 
          ? _specialRequestController.text 
          : null,
    );

    // Show AdMob interstitial ad before showing results
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        // Add a small delay for better UX after ad
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          
          context.push(
            '/blind-date-coaching',
            extra: input,
          );
        }
      },
      onAdFailed: () async {
        // Even if ad fails, still show results after a delay
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          
          context.push(
            '/blind-date-coaching',
            extra: input,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '소개팅 AI 코칭',
        onBackPressed: () {
          if (_currentStep > 0) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(isDark),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(isDark),
                _buildStep2(isDark),
              ],
            ),
          ),
        ],
      ),
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
            _currentStep == 0 ? '인스타그램 정보' : '추가 정보',
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '인스타그램으로\n상대방을 분석해드릴게요',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'AI가 프로필과 게시물을 분석하여\n맞춤형 소개팅 전략을 제공합니다',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          // Partner Instagram URL
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [TossDesignSystem.purple, TossDesignSystem.pinkPrimary, TossDesignSystem.warningOrange],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: TossDesignSystem.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '상대방 인스타그램 (필수)',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _partnerInstagramController,
                  decoration: InputDecoration(
                    hintText: 'instagram.com/username',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: TossDesignSystem.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // My Instagram URL (Optional)
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: TossDesignSystem.purple,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '내 인스타그램 (선택)',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '입력하시면 더 정확한 궁합 분석이 가능해요',
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _myInstagramController,
                  decoration: InputDecoration(
                    hintText: 'instagram.com/username',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: TossDesignSystem.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          
          const SizedBox(height: 24),
          
          // Meeting Info
          Text(
            '만남 정보',
            style: TossDesignSystem.heading4.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Meeting Date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: TossDesignSystem.purple,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _meetingDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: TossDesignSystem.purple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _meetingDate != null
                          ? '${_meetingDate!.month}월 ${_meetingDate!.day}일'
                          : '날짜를 선택해주세요',
                      style: TossDesignSystem.body1.copyWith(
                        color: _meetingDate != null
                            ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                            : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
          
          const SizedBox(height: 16),
          
          // Meeting Time
          Text(
            '시간대',
            style: TossDesignSystem.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTimeChip('morning', '아침', '☀️', isDark),
              _buildTimeChip('lunch', '점심', '🌤️', isDark),
              _buildTimeChip('evening', '저녁', '🌆', isDark),
              _buildTimeChip('night', '밤', '🌙', isDark),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
          
          const SizedBox(height: 16),
          
          // Meeting Type
          Text(
            '만남 방식',
            style: TossDesignSystem.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('cafe', '카페', '☕', isDark),
              _buildTypeChip('meal', '식사', '🍽️', isDark),
              _buildTypeChip('activity', '활동', '🎮', isDark),
            ],
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
          
          const SizedBox(height: 32),
          
          // Next Button
          SizedBox(
            width: double.infinity,
            child: TossButton.primary(
              text: '다음',
              onPressed: _nextStep,
              isEnabled: _validateStep1(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '당신에 대해\n알려주세요',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            '더 정확한 매칭 전략을 제공해드릴게요',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          // My Interests
          Text(
            '나의 관심사',
            style: TossDesignSystem.heading4.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: interestCards.map((interest) {
              final isSelected = _myInterests.contains(interest.id);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _myInterests.remove(interest.id);
                    } else {
                      _myInterests.add(interest.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossDesignSystem.purple.withValues(alpha: 0.1)
                        : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? TossDesignSystem.purple
                          : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest.emoji,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        interest.title,
                        style: TossDesignSystem.body2.copyWith(
                          color: isSelected
                              ? TossDesignSystem.purple
                              : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          
          const SizedBox(height: 32),
          
          // Main Curiosity
          Text(
            '가장 궁금한 점',
            style: TossDesignSystem.heading4.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 16),
          
          ...curiosityCards.map((curiosity) {
            final isSelected = _mainCuriosity == curiosity.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _mainCuriosity = curiosity.id;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: TossCard(
                  style: TossCardStyle.filled,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TossDesignSystem.purple.withValues(alpha: 0.1)
                              : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            curiosity.icon,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              curiosity.title,
                              style: TossDesignSystem.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              curiosity.description,
                              style: TossDesignSystem.body3.copyWith(
                                color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: TossDesignSystem.purple,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: TossDesignSystem.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList().animate(interval: 100.ms).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Special Request (Optional)
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: TossDesignSystem.purple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '특별 요청사항 (선택)',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _specialRequestController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '예: 첫 만남이라 긴장돼요, 대화 주제를 많이 알려주세요',
                    hintStyle: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: TossDesignSystem.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
          
          const SizedBox(height: 32),
          
          // Analyze Button
          SizedBox(
            width: double.infinity,
            child: TossButton.primary(
              text: _isAnalyzing ? 'AI가 분석 중...' : 'AI 분석 시작',
              onPressed: _isAnalyzing ? null : _analyzeAndShowResult,
              isEnabled: _validateStep2() && !_isAnalyzing,
              isLoading: _isAnalyzing,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Previous Button
          SizedBox(
            width: double.infinity,
            child: TossButton.secondary(
              text: '이전',
              onPressed: _previousStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String id, String label, String emoji, bool isDark) {
    final isSelected = _meetingTime == id;
    return InkWell(
      onTap: () {
        setState(() {
          _meetingTime = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.purple.withOpacity(0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              label,
              style: TossDesignSystem.body2.copyWith(
                color: isSelected
                    ? TossDesignSystem.purple
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String id, String label, String emoji, bool isDark) {
    final isSelected = _meetingType == id;
    return InkWell(
      onTap: () {
        setState(() {
          _meetingType = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.purple.withOpacity(0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(
              label,
              style: TossDesignSystem.body2.copyWith(
                color: isSelected
                    ? TossDesignSystem.purple
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}