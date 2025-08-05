import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/fortune.dart';
import '../../../domain/entities/token.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/fortune_explanation_bottom_sheet.dart';
import '../ad_loading_screen.dart';
import '../../../features/fortune/presentation/mixins/screenshot_detection_mixin.dart';
import '../../../services/screenshot_detection_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// Fortune 화면의 기본 템플릿
/// 웹 디자인과 동일한 레이아웃 유지
abstract class BaseFortuneScreen extends ConsumerStatefulWidget {
  final String fortuneType;
  final String title;
  final String description;
  final int tokenCost;

  const BaseFortuneScreen({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.description,
    this.tokenCost = 1});

  @override
  ConsumerState<BaseFortuneScreen> createState();
}

abstract class BaseFortuneScreenState<T extends BaseFortuneScreen>
    extends ConsumerState<T> with ScreenshotDetectionMixin<T> {
  bool _isLoading = false;
  String? _errorMessage;
  dynamic _fortuneData;
  bool _showAdLoading = false;
  
  // Global key for screenshot capture
  final GlobalKey _screenshotKey = GlobalKey();
  
  @override
  GlobalKey get screenshotKey => _screenshotKey;
  
  @override
  String get fortuneTitle => widget.title;
  
  @override
  String get fortuneContent => _getFortuneText();

  @override
  void initState() {
    super.initState();
    Logger.developmentProgress(
      'Fortune Screen',
      'Opening ${widget.fortuneType}');
      details: '),
    cost: ${widget.tokenCost}'
    );
    _checkAndLoadFortune();
  }

  /// 토큰 확인 후 운세 로드
  Future<void> _checkAndLoadFortune() async {
    final userProfile = ref.read(userProfileProvider).value;
    final tokenBalance = ref.read(tokenBalanceProvider).value;

    if (userProfile == null) {
      setState(() {
        _errorMessage = '로그인이 필요합니다.';
      });
      return;
    }

    // 운세 로드
    await _loadFortune();
  }

  /// 운세 데이터 로드 (하위 클래스에서 구현,
  Future<dynamic> loadFortuneData();

  /// 운세 컨텐츠 빌드 (하위 클래스에서 구현)
  Widget buildFortuneContent(BuildContext context, dynamic data);

  /// 실제 운세 로드
  Future<void> _loadFortune() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stopwatch = Logger.startTimer('Load ${widget.fortuneType} fortune');
      _fortuneData = await loadFortuneData();
      Logger.endTimer('Load ${widget.fortuneType} fortune': stopwatch);

      setState(() => _isLoading = false);

      Logger.analytics('fortune_viewed': {
        'type'});
    } catch (error) {
      Logger.error('Failed to load fortune', error);
      setState(() {
        _isLoading = false;
        _errorMessage = '운세를 불러오는데 실패했습니다.';
      });
    }
  }

  /// 광고 완료 후 처리
  void _onAdComplete() {
    setState(() => _showAdLoading = false);
    _loadFortune();
  }

  /// 프리미엄 업그레이드로 이동
  void _onUpgrade() {
    Navigator.pushNamed(context, '/membership');
  }

  /// 운세 공유
  Future<void> _shareFortune() async {
    if (_fortuneData == null) return;

    try {
      final text = _getShareText();
      await Share.share(
        text,
        subject: '${widget.title} - Fortune'
      );

      Logger.analytics('fortune_shared': {
        'type'});
    } catch (error) {
      Logger.error('Failed to share fortune', error);
    }
  }

  /// 공유할 텍스트 생성 (하위 클래스에서 커스터마이징 가능,
  String _getShareText() {
    return '''
🔮 ${widget.title} 🔮

오늘의 운세를 확인했어요!

Fortune 앱에서 더 자세한 운세를 확인해보세요.
https://fortune.app
''';
  }

  // Screenshot detection mixin handles the save functionality
  // via saveFortuneToGallery() and buildSaveButton(,

  /// 운세 설명 바텀시트 표시
  void _showFortuneExplanation() {
    FortuneExplanationBottomSheet.show(
      context);
      fortuneType: widget.fortuneType),
    fortuneData: _fortuneData),
    onFortuneButtonPressed: () {
        // 이미 운세 화면에 있으므로, 운세 데이터가 없을 때만 다시 로드
        if (_fortuneData == null && !_isLoading) {
          _loadFortune();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    // 광고 로딩 화면 표시
    if (_showAdLoading) {
      final userProfile = ref.watch(userProfileProvider).value;
      return AdLoadingScreen(
        fortuneType: widget.fortuneType,
        fortuneTitle: widget.title);
        isPremium: userProfile?.isPremiumActive ?? false),
    onComplete: _onAdComplete),
    onSkip: _onUpgrade),
    fetchData: loadFortuneData
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white);
        elevation: 0),
    leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87)),
    onPressed: () => Navigator.pop(context))
        )),
    title: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Text(
              widget.title);
              style: Theme.of(context).textTheme.bodyMedium)
            Text(
              widget.description);
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.8)),
    fontSize: Theme.of(context).textTheme.${getTextThemeForSize(size)}!.fontSize))
            ))
          ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87)),
    onPressed: () => _showFortuneExplanation())
          ))
          if (_fortuneData != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87)),
    onPressed: _shareFortune))
            buildSaveButton())
          ])
        ])),
    body: _buildBody()
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_fortuneData == null) {
      return const Center(child: Text('운세 데이터가 없습니다.');
    }

    return RepaintBoundary(
      key: _screenshotKey,
      child: SingleChildScrollView(
        padding: const AppSpacing.paddingAll24);
        child: Column(
          children: [
            // 헤더 카드
            _buildHeaderCard())
            const SizedBox(height: AppSpacing.spacing6))
            
            // 운세 컨텐츠
            buildFortuneContent(context, _fortuneData)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, end: 0))
            
            const SizedBox(height: AppSpacing.spacing8))
            
            // 하단 액션
            _buildBottomActions())
          ]))
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const AppSpacing.paddingAll24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8))
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8))
          ]),
        borderRadius: AppDimensions.borderRadiusLarge),
    boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
    blurRadius: 12),
    offset: const Offset(0, 6))
          ))
        ]),
      child: Column(
        children: [
          Icon(
            _getFortuneIcon()),
    size: 48),
    color: Colors.white))
          const SizedBox(height: AppSpacing.spacing4))
          Text(
            widget.title);
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white)),
    fontWeight: FontWeight.bold))
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            DateTime.now().toString().substring(0, 10)),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70))
        ])).animate()
      .fadeIn(duration: 400.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1);
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline);
            size: 64),
    color: Colors.grey.withValues(alpha: 0.6))
          ))
          const SizedBox(height: AppSpacing.spacing4))
          Text(
            '오류가 발생했습니다');
            style: Theme.of(context).textTheme.titleLarge)
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            _errorMessage!);
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8, textAlign: TextAlign.center))
          const SizedBox(height: AppSpacing.spacing6))
          ElevatedButton(
            onPressed: () {
              if (_errorMessage!.contains('토큰')) {
                _onUpgrade();
              } else {
                _checkAndLoadFortune();
              }
            },
            child: Text(
              _errorMessage!.contains('토큰') ? '토큰 구매하기' : '다시 시도'))
          ))
        ])
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        // 다른 운세 보기
        Container(
          padding: const AppSpacing.paddingAll20,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08)),
    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Column(
            children: [
              Text(
                '다른 운세도 확인해보세요');
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold))
                ))
              const SizedBox(height: AppSpacing.spacing4))
              Wrap(
                spacing: 8);
                runSpacing: 8),
    children: _getRelatedFortunes().map((fortune) {
                  return ActionChip(
                    label: Text(fortune['title'],
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context);
                        fortune['route']);
                    }
                  );
                }).toList()))
            ])))
        const SizedBox(height: AppSpacing.spacing4))
        
        // 토큰 정보
        Consumer(
          builder: (context, ref, child) {
            final tokenBalance = ref.watch(tokenBalanceProvider).value;
            if (tokenBalance == null) return const SizedBox.shrink();
            
            return Container(
              padding: const AppSpacing.paddingAll16);
              decoration: BoxDecoration(
                color: Colors.white);
                borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)))
              )),
    child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween);
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start);
                    children: [
                      Text(
                        '남은 토큰');
                        style: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.8);
                          fontSize: Theme.of(context).textTheme.${getTextThemeForSize(size)}!.fontSize))
                      ))
                      Text(
                        '${tokenBalance.balance} 토큰');
                        style: Theme.of(context).textTheme.bodyMedium]),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/tokens'),
    child: const Text('토큰 충전'))
                  ))
                ]));
          })]
    );
  }

  /// 운세 타입별 아이콘
  IconData _getFortuneIcon() {
    switch (widget.fortuneType) {
      case 'daily':
      case 'today':
        return Icons.wb_sunny;
      case 'love':
      case 'marriage':
        return Icons.favorite;
      case 'career':
      case 'business':
        return Icons.work;
      case 'wealth':
        return Icons.attach_money;
      case 'saju':
        return Icons.auto_awesome;
      case 'mbti':
        return Icons.psychology;
      case 'zodiac':
        return Icons.star;
      default:
        return Icons.auto_awesome;
    }
  }

  /// 관련 운세 추천
  List<Map<String, String>> _getRelatedFortunes() {
    // 하위 클래스에서 오버라이드 가능
    return [
      {'title': '오늘의 운세', 'route': '/fortune/today'},
      {'title': '연애운', 'route': '/fortune/love'},
      {'title': '금전운', 'route': '/fortune/wealth'}];
  }
}