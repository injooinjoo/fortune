import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:visibility_detector/visibility_detector.dart';
import '../services/analytics_tracker.dart';

/// Analytics를 자동으로 추적하는 위젯
/// 화면 진입, 이탈, 가시성 등을 자동으로 추적
abstract class AnalyticsAwareWidget extends ConsumerStatefulWidget {
  final String screenName;
  final String? screenClass;
  final Map<String, dynamic>? screenParameters;
  
  const AnalyticsAwareWidget({
    super.key,
    required this.screenName,
    this.screenClass,
    this.screenParameters});
}

abstract class AnalyticsAwareState<T extends AnalyticsAwareWidget> 
    extends ConsumerState<T> with WidgetsBindingObserver {
  
  late AnalyticsTracker _tracker;
  DateTime? _enterTime;
  bool _isScreenActive = false;
  
  @override
  void initState() {
    super.initState();
    _tracker = ref.read(analyticsTrackerProvider);
    WidgetsBinding.instance.addObserver(this);
    
    // 화면 진입 추적
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackScreenEnter();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackScreenExit();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isScreenActive) {
      _trackScreenEnter();
    } else if (state == AppLifecycleState.paused && _isScreenActive) {
      _trackScreenExit();
    }
  }
  
  /// 화면 진입 추적
  void _trackScreenEnter() {
    if (_isScreenActive) return;
    
    _isScreenActive = true;
    _enterTime = DateTime.now();
    
    _tracker.trackScreenView(
      screenName: widget.screenName,
      screenClass: widget.screenClass ?? widget.runtimeType.toString(),
      parameters: widget.screenParameters);
  }
  
  /// 화면 이탈 추적
  void _trackScreenExit() {
    if (!_isScreenActive) return;
    
    _isScreenActive = false;
    
    if (_enterTime != null) {
      final duration = DateTime.now().difference(_enterTime!).inSeconds;
      
      _tracker.trackEvent(
        eventName: 'screen_exit',
        parameters: {
          'screen_name': widget.screenName,
          'duration_seconds': duration,
        },
      );
    }
  }
  
  /// 사용자 액션 추적
  Future<void> trackAction({
    required String action,
    String? target,
    String? value,
    Map<String, dynamic>? parameters}) async {
    await _tracker.trackUserAction(
      action: action,
      target: target,
      value: value,
      parameters: {
        ...?parameters,
        'screen_name': widget.screenName,
      },
    );
  }
  
  /// 전환 추적
  Future<void> trackConversion({
    required String conversionType,
    required dynamic value,
    Map<String, dynamic>? parameters}) async {
    await _tracker.trackConversion(
      conversionType: conversionType,
      value: value,
      parameters: {
        ...?parameters,
        'screen_name': widget.screenName,
      },
    );
  }
  
  /// 에러 추적
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    Map<String, dynamic>? parameters}) async {
    await _tracker.trackError(
      errorType: errorType,
      errorMessage: errorMessage,
      parameters: {
        ...?parameters,
        'screen_name': widget.screenName,
      },
    );
  }
}

/// 자동으로 가시성을 추적하는 위젯
class AnalyticsVisibilityDetector extends ConsumerWidget {
  final String itemId;
  final String itemType;
  final Widget child;
  final Map<String, dynamic>? parameters;
  final Function(dynamic)? onVisibilityChanged;
  final double visibleThreshold;
  
  const AnalyticsVisibilityDetector({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.child,
    this.parameters,
    this.onVisibilityChanged,
    this.visibleThreshold = 0.5, // 50% 이상 보이면 노출로 간주
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder implementation without visibility_detector dependency
    return GestureDetector(
      key: Key('analytics_visibility_$itemId'),
      onTap: () {
        final tracker = ref.read(analyticsTrackerProvider);
        tracker.trackEvent(
          eventName: '${itemType}_impression',
          parameters: {
            'item_id': itemId,
            'visible_fraction': 1.0,
            ...?parameters,
          },
        );
        onVisibilityChanged?.call({'visibleFraction': 1.0});
      },
      child: child,
    );
  }
}

/// 클릭 가능한 Analytics 추적 위젯
class AnalyticsInkWell extends ConsumerWidget {
  final String actionName;
  final String? target;
  final Widget child;
  final VoidCallback? onTap;
  final Map<String, dynamic>? parameters;
  final BorderRadius? borderRadius;
  
  const AnalyticsInkWell({
    super.key,
    required this.actionName,
    this.target,
    required this.child,
    this.onTap,
    this.parameters,
    this.borderRadius});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // 클릭 추적
        ref.read(analyticsTrackerProvider).trackUserAction(
          action: actionName,
          target: target,
          parameters: parameters);
        
        // 원래 콜백 호출
        onTap?.call();
      },
      borderRadius: borderRadius,
      child: child);
  }
}

/// 스크롤 추적 위젯
class AnalyticsScrollTracker extends ConsumerStatefulWidget {
  final String scrollAreaName;
  final ScrollController? controller;
  final Widget child;
  final double scrollThreshold;
  
  const AnalyticsScrollTracker({
    super.key,
    required this.scrollAreaName,
    this.controller,
    required this.child,
    this.scrollThreshold = 0.9, // 90% 스크롤 시 추적
  });
  
  @override
  ConsumerState<AnalyticsScrollTracker> createState() => _AnalyticsScrollTrackerState();
}

class _AnalyticsScrollTrackerState extends ConsumerState<AnalyticsScrollTracker> {
  late ScrollController _scrollController;
  bool _hasTrackedScroll = false;
  double _maxScrollPercentage = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final scrollPercentage = maxScroll > 0 ? currentScroll / maxScroll : 0.0;
      
      // 최대 스크롤 비율 업데이트
      if (scrollPercentage > _maxScrollPercentage) {
        _maxScrollPercentage = scrollPercentage;
      }
      
      // 임계값에 도달하고 아직 추적하지 않았다면
      if (scrollPercentage >= widget.scrollThreshold && !_hasTrackedScroll) {
        _hasTrackedScroll = true;
        
        ref.read(analyticsTrackerProvider).trackEvent(
          eventName: 'scroll_depth_reached',
          parameters: {
            'scroll_area': widget.scrollAreaName,
            'depth_percentage': (scrollPercentage * 100).round(),
          },
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 스크롤 종료 시 최대 스크롤 깊이 기록
        if (_maxScrollPercentage > 0) {
          ref.read(analyticsTrackerProvider).trackEvent(
            eventName: 'scroll_session_end',
            parameters: {
              'scroll_area': widget.scrollAreaName,
              'max_depth_percentage': (_maxScrollPercentage * 100).round(),
            },
          );
        }
        return false;
      },
      child: widget.child);
  }
}