import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';

/// 운세 로딩 스켈레톤 UI - 토스 디자인 시스템 적용
class FortuneLoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showHeader;
  final String? loadingMessage;
  final List<String>? loadingMessages;
  
  const FortuneLoadingSkeleton({
    super.key,
    this.itemCount = 3,
    this.showHeader = true,
    this.loadingMessage,
    this.loadingMessages,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        if (showHeader)
          _buildHeaderSkeleton(isDark)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
        
        // 로딩 메시지
        if (loadingMessage != null || loadingMessages != null)
          _buildLoadingMessage(isDark)
              .animate()
              .fadeIn(duration: 600.ms),
        
        // 스켈레톤 카드들
        for (int i = 0; i < itemCount; i++)
          _buildSkeletonCard(isDark, i)
              .animate(
                delay: Duration(milliseconds: i * 100),
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
      ],
    );
  }
  
  Widget _buildHeaderSkeleton(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? DSColors.border : DSColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? DSColors.border : DSColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingMessage(bool isDark) {
    final messages = loadingMessages ?? [
      '운세를 분석하고 있어요...',
      '천체의 움직임을 확인하는 중...',
      '오늘의 기운을 읽어들이는 중...',
      '행운의 메시지를 준비하는 중...',
    ];
    
    return LoadingMessageRotator(
      messages: loadingMessage != null ? [loadingMessage!] : messages,
      isDark: isDark,
    );
  }
  
  Widget _buildSkeletonCard(bool isDark, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 스켈레톤
          Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: isDark ? DSColors.border : DSColors.border,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          
          // 내용 스켈레톤
          for (int i = 0; i < 3; i++) ...[
            Container(
              width: double.infinity,
              height: 16,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? DSColors.border : DSColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
          
          // 마지막 줄은 짧게
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? DSColors.border : DSColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 로딩 메시지 로테이터
class LoadingMessageRotator extends StatefulWidget {
  final List<String> messages;
  final bool isDark;
  final Duration duration;
  
  const LoadingMessageRotator({
    super.key,
    required this.messages,
    required this.isDark,
    this.duration = const Duration(seconds: 2),
  });
  
  @override
  State<LoadingMessageRotator> createState() => _LoadingMessageRotatorState();
}

class _LoadingMessageRotatorState extends State<LoadingMessageRotator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    if (widget.messages.length > 1) {
      _controller.repeat();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.messages.length;
          });
        }
      });
    }
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              widget.messages[_currentIndex],
              style: DSTypography.bodyMedium.copyWith(
                color: widget.isDark
                    ? DSColors.textSecondary
                    : DSColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

/// 유명인 검색 스켈레톤
class CelebritySearchSkeleton extends StatelessWidget {
  final bool isDark;
  
  const CelebritySearchSkeleton({
    super.key,
    required this.isDark,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildCelebrityCardSkeleton(isDark)
            .animate(
              delay: Duration(milliseconds: index * 50),
              onPlay: (controller) => controller.repeat(),
            )
            .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3));
      },
    );
  }
  
  Widget _buildCelebrityCardSkeleton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이미지 스켈레톤
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? DSColors.border : DSColors.border,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          // 텍스트 스켈레톤
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? DSColors.border : DSColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? DSColors.border : DSColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 운세 결과 스켈레톤
class FortuneResultSkeleton extends StatelessWidget {
  final bool showScore;
  final bool isDark;
  
  const FortuneResultSkeleton({
    super.key,
    this.showScore = true,
    required this.isDark,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // 점수 스켈레톤
          if (showScore)
            Container(
              margin: const EdgeInsets.all(20),
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? DSColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? DSColors.border : DSColors.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? DSColors.border : DSColors.border,
                  ),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
          
          // 콘텐츠 스켈레톤
          for (int i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? DSColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? DSColors.border : DSColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isDark ? DSColors.border : DSColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int j = 0; j < 4; j++)
                    Container(
                      width: double.infinity,
                      height: 14,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isDark ? DSColors.border : DSColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            )
                .animate(
                  delay: Duration(milliseconds: 100 + (i * 100)),
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}