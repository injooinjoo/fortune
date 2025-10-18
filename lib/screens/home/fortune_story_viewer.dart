import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../presentation/providers/navigation_visibility_provider.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/theme/typography_unified.dart';

/// 운세 스토리를 페이지별로 보여주는 뷰어
class FortuneStoryViewer extends ConsumerStatefulWidget {
  final List<StorySegment> segments;
  final String? userName;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool showProgressIndicator;
  final bool showSkipButton;

  const FortuneStoryViewer({
    super.key,
    required this.segments,
    this.userName,
    this.onComplete,
    this.onSkip,
    this.showProgressIndicator = true,
    this.showSkipButton = true,
  });

  @override
  ConsumerState<FortuneStoryViewer> createState() => _FortuneStoryViewerState();
}

class _FortuneStoryViewerState extends ConsumerState<FortuneStoryViewer> {
  late PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
    
    // 네비게이션 바 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
    });
    
    // 시스템 UI (상태바, 네비게이션 바) 숨기기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    
    // 시스템 UI 복원
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // 마지막 페이지에 도달했을 때
    if (page == widget.segments.length - 1) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // 시스템 UI 복원
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          
          // 네비게이션 바 다시 표시
          ref.read(navigationVisibilityProvider.notifier).show();
          
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark 
                  ? [
                      Color(0xFF1a1a2e),  // 진한 남색
                      Color(0xFF16213e),  // 더 진한 남색
                      Color(0xFF0f1624),  // 거의 검정
                    ]
                  : [
                      TossDesignSystem.white,        // 흰색
                      Color(0xFFF8F9FA),   // 연한 회색
                      Color(0xFFF1F3F4),   // 더 연한 회색
                    ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 메인 콘텐츠 - PageView with fade effect
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.segments.length,
            itemBuilder: (context, index) {
              return _buildStoryPage(widget.segments[index], index);
            },
          ),

          // 스킵 버튼
          if (widget.showSkipButton && widget.onSkip != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: TextButton(
                onPressed: () {
                  // 시스템 UI 복원
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                  
                  // 네비게이션 바 다시 표시
                  ref.read(navigationVisibilityProvider.notifier).show();
                  
                  widget.onSkip?.call();
                },
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: isDark
                      ? TossDesignSystem.white.withValues(alpha: 0.5)
                      : TossDesignSystem.black.withValues(alpha: 0.5),
                    
                  ),
                ),
              ),
            ),

          // 진행 인디케이터
          if (widget.showProgressIndicator)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: _buildProgressIndicator(),
            ),

          // 스크롤 힌트 (첫 페이지에만)
          if (_currentPage == 0)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 0,
              right: 0,
              child: Icon(
                Icons.swipe_up,
                color: isDark
                  ? TossDesignSystem.white.withValues(alpha: 0.3)
                  : TossDesignSystem.black.withValues(alpha: 0.3),
                size: 24,
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).moveY(
                begin: 0,
                end: -10,
                duration: const Duration(seconds: 1),
              ).fadeIn(duration: const Duration(milliseconds: 500)),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryPage(StorySegment segment, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 페이지 오프셋 계산 (스크롤 진행도)
    double pageOffset = _pageOffset;
    double diff = (index - pageOffset).abs();
    
    // 페이드 효과 계산 - 더 극적으로!
    double opacity = 1.0;
    double scale = 1.0;
    double translateY = 0.0;
    
    if (diff < 1.0) {
      // 현재 페이지이거나 전환 중인 페이지
      if (index == pageOffset.floor()) {
        // 현재 페이지가 위로 스크롤되면서 사라짐
        double progress = pageOffset - index;
        
        // 아주 조금만 스크롤해도 빠르게 사라지도록
        if (progress > 0.05) {  // 5%만 스크롤해도
          opacity = math.max(0.0, 1.0 - (progress * 5));  // 5배 빠르게 페이드 아웃
          if (progress > 0.2) {  // 20% 이상 스크롤하면
            opacity = 0.0;  // 완전히 사라짐
          }
        } else {
          opacity = 1.0;
        }
        
        // 위로 살짝 이동하며 사라짐
        translateY = -progress * 50;
        scale = 1.0 - (progress * 0.1);
        
      } else if (index == pageOffset.ceil()) {
        // 다음 페이지가 아래에서 올라오면서 나타남
        double progress = pageOffset - index + 1;
        
        // 중앙에 가까워질 때만 나타나도록
        if (progress < 0.7) {  // 70% 전까지는 안 보임
          opacity = 0.0;
        } else {
          // 70% 이후부터 급격히 나타남
          opacity = (progress - 0.7) / 0.3;  // 0.7~1.0 구간에서 0~1로 변화
        }
        
        // 아래에서 위로 올라오는 효과
        translateY = (1.0 - progress) * 30;
        scale = 0.9 + (progress * 0.1);
      }
    } else {
      // 보이지 않는 페이지
      opacity = 0.0;
    }
    
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform(
        transform: Matrix4.identity()
          ..translate(0.0, translateY, 0.0)
          ..scale(scale),
        alignment: Alignment.center,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 소제목 제거됨
                
                // 이모지가 있으면 표시
                if (segment.emoji != null) ...[
                  Text(
                    segment.emoji!,
                    style: TextStyle(fontSize: 48),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // 메인 텍스트
                Text(
                  segment.text,
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.black,
                    fontSize: segment.fontSize ?? 32,
                    fontWeight: segment.isBold 
                        ? FontWeight.w600 
                        : (segment.fontWeight ?? FontWeight.w300),
                    height: 1.8,
                    letterSpacing: 0.5,
                    shadows: isDark 
                      ? [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: TossDesignSystem.black.withValues(alpha: 0.3),
                          ),
                        ]
                      : [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: TossDesignSystem.gray400.withValues(alpha: 0.3),
                          ),
                        ],
                  ),
                  textAlign: segment.alignment ?? TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.segments.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: index == _currentPage
                ? isDark
                  ? TossDesignSystem.white.withValues(alpha: 0.8)
                  : TossDesignSystem.black.withValues(alpha: 0.8)
                : isDark
                  ? TossDesignSystem.white.withValues(alpha: 0.3)
                  : TossDesignSystem.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

/// 스토리 세그먼트 데이터 클래스
class StorySegment {
  final String? subtitle;  // 소제목
  final String text;       // 메인 텍스트
  final double? fontSize;
  final double? subtitleFontSize;
  final FontWeight? fontWeight;
  final FontWeight? subtitleFontWeight;
  final TextAlign? alignment;
  final Duration? displayDuration;
  final String? emoji;     // 장식용 이모지
  final bool isBold;       // 굵은 글씨 여부

  const StorySegment({
    this.subtitle,
    required this.text,
    this.fontSize,
    this.subtitleFontSize,
    this.fontWeight,
    this.subtitleFontWeight,
    this.alignment,
    this.displayDuration,
    this.emoji,
    this.isBold = false,
  });

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      subtitle: json['subtitle'] as String?,
      text: json['text'] as String,
      fontSize: json['fontSize'] as double?,
      subtitleFontSize: json['subtitleFontSize'] as double?,
      fontWeight: json['fontWeight'] != null 
          ? FontWeight.values[json['fontWeight'] as int]
          : null,
      subtitleFontWeight: json['subtitleFontWeight'] != null
          ? FontWeight.values[json['subtitleFontWeight'] as int]
          : null,
      alignment: json['alignment'] != null
          ? TextAlign.values[json['alignment'] as int]
          : null,
      displayDuration: json['displayDuration'] != null
          ? Duration(milliseconds: json['displayDuration'] as int)
          : null,
      emoji: json['emoji'] as String?,
      isBold: json['isBold'] as bool? ?? false,
    );
  }
}

/// 운세 스토리 전체 데이터
class FortuneStory {
  final List<StorySegment> segments;
  final String? backgroundGradient;
  final String? textColor;
  final DateTime date;

  const FortuneStory({
    required this.segments,
    this.backgroundGradient,
    this.textColor,
    required this.date,
  });

  factory FortuneStory.fromFortune({
    required String userName,
    required DateTime date,
    required Map<String, dynamic> fortuneData,
  }) {
    // 운세 데이터를 스토리 세그먼트로 변환
    List<StorySegment> segments = [];

    // 인사말
    segments.add(StorySegment(
      text: '안녕하세요 $userName님,',
      
      fontWeight: FontWeight.w300,
    ));

    // 날짜
    segments.add(StorySegment(
      text: '${date.month}월 ${date.day}일 ${_getWeekdayKorean(date.weekday)},',
      
      fontWeight: FontWeight.w300,
    ));

    // 오늘의 기운
    segments.add(StorySegment(
      text: '오늘의 운세를\n알려드릴게요.',
      fontSize: 30,
      fontWeight: FontWeight.w400,
    ));

    // 운세 내용 추가 (fortuneData에서 추출)
    if (fortuneData['summary'] != null) {
      // 요약을 여러 줄로 나누기
      String summary = fortuneData['summary'] as String;
      List<String> lines = summary.split('. ');
      
      for (String line in lines) {
        if (line.isNotEmpty) {
          segments.add(StorySegment(
            text: line.trim() + (line.endsWith('.') ? '' : '.'),
            fontSize: 26,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    }

    // 행운의 요소들
    if (fortuneData['luckyColor'] != null) {
      segments.add(StorySegment(
        text: '오늘의 행운의 색은\n${fortuneData['luckyColor']}입니다.',
        
        fontWeight: FontWeight.w300,
      ));
    }

    if (fortuneData['luckyNumber'] != null) {
      segments.add(StorySegment(
        text: '행운의 숫자는\n${fortuneData['luckyNumber']}',
        
        fontWeight: FontWeight.w500,
      ));
    }

    // 조언
    if (fortuneData['advice'] != null) {
      segments.add(StorySegment(
        text: fortuneData['advice'] as String,
        
        fontWeight: FontWeight.w300,
      ));
    }

    // 마무리
    segments.add(StorySegment(
      text: '오늘도 좋은 하루 되세요.',
      
      fontWeight: FontWeight.w400,
    ));

    return FortuneStory(
      segments: segments,
      date: date,
    );
  }

  static String _getWeekdayKorean(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }
}