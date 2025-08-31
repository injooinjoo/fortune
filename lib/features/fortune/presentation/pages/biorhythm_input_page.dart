import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/theme/toss_theme.dart';
import 'biorhythm_loading_page.dart';

class BiorhythmInputPage extends StatefulWidget {
  const BiorhythmInputPage({super.key});

  @override
  State<BiorhythmInputPage> createState() => _BiorhythmInputPageState();
}

class _BiorhythmInputPageState extends State<BiorhythmInputPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDatePickerModal(),
    );
  }

  Widget _buildDatePickerModal() {
    DateTime tempDate = _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TossButton(
                  text: '취소',
                  onPressed: () => Navigator.of(context).pop(),
                  style: TossButtonStyle.tertiary,
                  size: TossButtonSize.small,
                ),
                Text(
                  '생년월일 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TossTheme.textBlack,
                  ),
                ),
                TossButton(
                  text: '확인',
                  onPressed: () {
                    setState(() {
                      _selectedDate = tempDate;
                      _dateController.text = 
                          '${tempDate.year}.${tempDate.month.toString().padLeft(2, '0')}.${tempDate.day.toString().padLeft(2, '0')}';
                    });
                    Navigator.of(context).pop();
                    HapticFeedback.mediumImpact();
                  },
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.small,
                ),
              ],
            ),
          ),
          
          // 날짜 선택기
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: tempDate,
              minimumDate: DateTime(1900),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (date) {
                tempDate = date;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeBiorhythm() {
    if (_selectedDate == null) return;
    
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BiorhythmLoadingPage(birthDate: _selectedDate!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TossTheme.textBlack,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '바이오리듬 분석',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 메인 설명 카드
              FadeTransition(
                opacity: _fadeAnimation,
                child: TossCard(
                  style: TossCardStyle.elevated,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 바이오리듬 아이콘
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  TossTheme.primaryBlue,
                                  const Color(0xFF00C896),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: TossTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.timeline_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        '당신의 생체 리듬을 분석하고\n최적의 타이밍을 찾아드릴게요',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossTheme.textBlack,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        '신체·감정·지적 리듬의 3가지 주기를 분석해\n오늘의 컨디션과 앞으로의 흐름을 알려드려요',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: TossTheme.textGray600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 생년월일 입력 카드
              FadeTransition(
                opacity: _fadeAnimation,
                child: TossCard(
                  style: TossCardStyle.outlined,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '생년월일',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TossTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDate != null 
                                  ? TossTheme.primaryBlue 
                                  : TossTheme.borderGray300,
                              width: _selectedDate != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                                    : '생년월일을 선택해주세요',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _selectedDate != null 
                                      ? TossTheme.textBlack 
                                      : TossTheme.textGray600,
                                  fontWeight: _selectedDate != null 
                                      ? FontWeight.w500 
                                      : FontWeight.w400,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_rounded,
                                color: _selectedDate != null 
                                    ? TossTheme.primaryBlue 
                                    : TossTheme.textGray600,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 분석 시작 버튼
              FadeTransition(
                opacity: _fadeAnimation,
                child: TossButton(
                  text: '바이오리듬 분석하기',
                  onPressed: _selectedDate != null ? _analyzeBiorhythm : null,
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.large,
                  width: double.infinity,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 안내 문구
              Text(
                '분석 결과는 참고용으로만 활용해 주세요',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: TossTheme.textGray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}