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
import '../ad_loading_screen.dart';

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
    this.tokenCost = 1,
  });

  @override
  ConsumerState<BaseFortuneScreen> createState();
}

abstract class BaseFortuneScreenState<T extends BaseFortuneScreen>
    extends ConsumerState<T> {
  bool _isLoading = false;
  String? _errorMessage;
  dynamic _fortuneData;
  bool _showAdLoading = false;

  @override
  void initState() {
    super.initState();
    Logger.developmentProgress(
      'Fortune Screen',
      'Opening ${widget.fortuneType}',
      details: 'Token cost: ${widget.tokenCost}',
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

    // 프리미엄 사용자는 바로 로드
    if (userProfile.isPremiumActive) {
      await _loadFortune();
      return;
    }

    // 무료 사용자 토큰 체크
    if (tokenBalance == null || tokenBalance.balance < widget.tokenCost) {
      // 일일 무료 사용 가능 여부 확인
      if (tokenBalance?.canUseFree ?? false) {
        // 광고 보고 운세 확인
        setState(() => _showAdLoading = true);
      } else {
        setState(() {
          _errorMessage = '토큰이 부족합니다. 토큰을 구매하거나 내일 다시 시도해주세요.';
        });
      }
      return;
    }

    // 토큰이 충분한 경우 광고 표시 후 로드
    setState(() => _showAdLoading = true);
  }

  /// 운세 데이터 로드 (하위 클래스에서 구현)
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
      Logger.endTimer('Load ${widget.fortuneType} fortune', stopwatch);

      // 토큰 소비
      final tokenDataSource = ref.read(tokenRemoteDataSourceProvider);
      await tokenDataSource.consumeTokens(widget.tokenCost, widget.fortuneType);

      // 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);

      setState(() => _isLoading = false);

      Logger.analytics('fortune_viewed', {
        'type': widget.fortuneType,
        'token_cost': widget.tokenCost,
      });
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
        subject: '${widget.title} - Fortune',
      );

      Logger.analytics('fortune_shared', {
        'type': widget.fortuneType,
      });
    } catch (error) {
      Logger.error('Failed to share fortune', error);
    }
  }

  /// 공유할 텍스트 생성 (하위 클래스에서 커스터마이징 가능)
  String _getShareText() {
    return '''
🔮 ${widget.title} 🔮

오늘의 운세를 확인했어요!

Fortune 앱에서 더 자세한 운세를 확인해보세요.
https://fortune.app
''';
  }

  /// 운세 이미지 저장
  Future<void> _saveFortuneImage() async {
    // TODO: 운세 이미지 생성 및 저장
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지 저장 기능은 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 광고 로딩 화면 표시
    if (_showAdLoading) {
      final userProfile = ref.watch(userProfileProvider).value;
      return AdLoadingScreen(
        fortuneType: widget.fortuneType,
        fortuneTitle: widget.title,
        isPremium: userProfile?.isPremiumActive ?? false,
        onComplete: _onAdComplete,
        onSkip: _onUpgrade,
        fetchData: loadFortuneData,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (_fortuneData != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87),
              onPressed: _shareFortune,
            ),
            IconButton(
              icon: const Icon(Icons.download_outlined, color: Colors.black87),
              onPressed: _saveFortuneImage,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_fortuneData == null) {
      return const Center(child: Text('운세 데이터가 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 헤더 카드
          _buildHeaderCard(),
          const SizedBox(height: 24),
          
          // 운세 컨텐츠
          buildFortuneContent(context, _fortuneData)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
          
          // 하단 액션
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getFortuneIcon(),
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateTime.now().toString().substring(0, 10),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_errorMessage!.contains('토큰')) {
                _onUpgrade();
              } else {
                _checkAndLoadFortune();
              }
            },
            child: Text(
              _errorMessage!.contains('토큰') ? '토큰 구매하기' : '다시 시도',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        // 다른 운세 보기
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '다른 운세도 확인해보세요',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getRelatedFortunes().map((fortune) {
                  return ActionChip(
                    label: Text(fortune['title'] as String),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        fortune['route'] as String,
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 토큰 정보
        Consumer(
          builder: (context, ref, child) {
            final tokenBalance = ref.watch(tokenBalanceProvider).value;
            if (tokenBalance == null) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '남은 토큰',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${tokenBalance.balance} 토큰',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/tokens'),
                    child: const Text('토큰 충전'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
      {'title': '금전운', 'route': '/fortune/wealth'},
    ];
  }
}