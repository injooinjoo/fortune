import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/logger.dart';
import '../widgets/ads/cross_platform_ad_widget.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final String fortuneType;
  final String fortuneTitle;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isPremium;
  final Future<dynamic> Function()? fetchData;
  final Future<void> Function()? onAdComplete;
  final String? fortuneRoute; // Add route parameter for navigation
  final Map<String, dynamic>? fortuneParams; // Parameters for fortune generation

  const AdLoadingScreen({
    super.key,
    required this.fortuneType,
    required this.fortuneTitle,
    required this.onComplete,
    required this.onSkip,
    required this.isPremium,
    this.fetchData,
    this.onAdComplete,
    this.fortuneRoute,
    this.fortuneParams,
  });

  @override
  ConsumerState<AdLoadingScreen> createState() => _AdLoadingScreenState();
}

class _AdLoadingScreenState extends ConsumerState<AdLoadingScreen> {
  Timer? _timer;
  int _remainingSeconds = 5;
  bool _isLoading = true;
  dynamic _fetchedData;
  String? _errorMessage;
  bool _canProceed = false; // 버튼 활성화 상태

  @override
  void initState() {
    super.initState();
    Logger.info('AdLoadingScreen opened for ${widget.fortuneType}');
    
    _startLoading();
  }

  void _startLoading() async {
    // 프리미엄 사용자는 바로 데이터 로드
    if (widget.isPremium) {
      await _fetchFortuneData();
      if (mounted) {
        widget.onComplete();
      }
      return;
    }

    // 무료 사용자는 광고 로딩
    
    // 카운트다운 타이머
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _canProceed = true; // 버튼 활성화
        });
      }
    });

    // 동시에 데이터 페치
    _fetchFortuneData();
  }

  Future<void> _fetchFortuneData() async {
    if (widget.fetchData == null) return;

    try {
      final stopwatch = Logger.startTimer('Fortune data fetch');
      _fetchedData = await widget.fetchData!();
      Logger.endTimer('Fortune data fetch', stopwatch);
      
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Logger.error('Failed to fetch fortune data', error);
      setState(() {
        _isLoading = false;
        _errorMessage = '운세 데이터를 불러오는데 실패했습니다.';
      });
    }
  }

  void _completeLoading() async {
    if (_errorMessage != null) {
      // 에러가 있으면 다시 시도하거나 뒤로 가기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
                _remainingSeconds = 5;
              });
              _startLoading();
            },
          ),
        ),
      );
      return;
    }

    // 데이터가 아직 로딩 중이면 잠시 대기
    if (_isLoading && widget.fetchData != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _completeLoading();
        }
      });
      return;
    }

    // 무료 사용자의 경우 광고 시청 완료 후 토큰 보상
    if (!widget.isPremium && widget.onAdComplete != null) {
      try {
        await widget.onAdComplete!();
        Logger.analytics('token_reward_for_ad', {
          'fortune_type': widget.fortuneType,
        });
      } catch (e) {
        Logger.error('Failed to reward tokens for ad', e);
        // 토큰 보상 실패해도 운세는 보여줌
      }
    }

    Logger.analytics('ad_loading_complete', {
      'fortune_type': widget.fortuneType,
      'is_premium': widget.isPremium,
    });

    // If fortune route is provided, navigate to it
    if (widget.fortuneRoute != null && mounted) {
      try {
        print('[AdLoadingScreen] Navigating to: ${widget.fortuneRoute}');
        print('[AdLoadingScreen] Fortune params: ${widget.fortuneParams}');
        
        // Pass any fetched data or params to the fortune page
        // Add a flag to indicate fortune should be auto-generated
        context.pushReplacement(
          widget.fortuneRoute!,
          extra: {
            'fortuneData': _fetchedData,
            'fortuneParams': widget.fortuneParams,
            'autoGenerate': true, // Flag to auto-generate fortune
          },
        );
        print('[AdLoadingScreen] Navigation successful');
      } catch (e) {
        print('[AdLoadingScreen] Navigation error: $e');
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('페이지 이동 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
          // Navigate back
          Navigator.of(context).pop();
        }
      }
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 컨텐츠 - 광고를 중앙에 배치
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 광고 영역 (무료 사용자만)
                  if (!widget.isPremium) ...[
                    // 광고 컨테이너
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // 광고 라벨
                          Text(
                            '광고',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 광고 위젯
                          CommonAdPlacements.largeAd(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 남은 시간 또는 버튼
                    if (_remainingSeconds > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '광고가 ${_remainingSeconds}초 후에 닫힙니다',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ] else if (_canProceed) ...[
                      // 운세 확인 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ElevatedButton(
                          onPressed: _completeLoading,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                '운세 확인하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          ),
                      ),
                    ],
                  ] else ...[
                    // 프리미엄 사용자는 로딩 표시
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '운세를 준비하고 있습니다...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 헤더 영역
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 뒤로가기 버튼
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    // 제목
                    Expanded(
                      child: Text(
                        widget.fortuneTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 하단 프리미엄 업그레이드 영역 (무료 사용자만)
            if (!widget.isPremium)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '광고 없이 바로 운세를 확인하고 싶으신가요?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onSkip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                '프리미엄으로 업그레이드',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}