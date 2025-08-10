import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 운세 스토리를 페이지별로 보여주는 뷰어
class FortuneStoryViewer extends StatefulWidget {
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
  State<FortuneStoryViewer> createState() => _FortuneStoryViewerState();
}

class _FortuneStoryViewerState extends State<FortuneStoryViewer> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a1a2e),  // 진한 남색
                  Color(0xFF16213e),  // 더 진한 남색
                  Color(0xFF0f1624),  // 거의 검정
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 메인 콘텐츠 - PageView
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
                onPressed: widget.onSkip,
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
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
                color: Colors.white.withValues(alpha: 0.3),
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
    // 현재 페이지 여부 확인
    bool isCurrentPage = index == _currentPage;
    
    // Simple fade animation - only current page is visible
    return AnimatedOpacity(
      opacity: isCurrentPage ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // 소제목이 있으면 표시
            if (segment.subtitle != null) ...[
              Text(
                segment.subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: segment.subtitleFontSize ?? 14,
                  fontWeight: segment.subtitleFontWeight ?? FontWeight.w300,
                  letterSpacing: 2,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
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
                color: Colors.white,
                fontSize: segment.fontSize ?? 32,
                fontWeight: segment.isBold 
                    ? FontWeight.w600 
                    : (segment.fontWeight ?? FontWeight.w300),
                  height: 1.8,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                textAlign: segment.alignment ?? TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
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
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.3),
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
      fontSize: 32,
      fontWeight: FontWeight.w300,
    ));

    // 날짜
    segments.add(StorySegment(
      text: '${date.month}월 ${date.day}일 ${_getWeekdayKorean(date.weekday)},',
      fontSize: 28,
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
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }

    if (fortuneData['luckyNumber'] != null) {
      segments.add(StorySegment(
        text: '행운의 숫자는\n${fortuneData['luckyNumber']}',
        fontSize: 32,
        fontWeight: FontWeight.w500,
      ));
    }

    // 조언
    if (fortuneData['advice'] != null) {
      segments.add(StorySegment(
        text: fortuneData['advice'] as String,
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }

    // 마무리
    segments.add(StorySegment(
      text: '오늘도 좋은 하루 되세요.',
      fontSize: 28,
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