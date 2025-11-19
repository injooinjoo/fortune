import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../services/ad_service.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../widgets/dream_voice_input_widget.dart';
import '../widgets/dream_input_tip_card.dart';
import '../widgets/dream_result_widget.dart';
import '../providers/dream_voice_provider.dart';

/// 음성 중심 꿈 해몽 페이지 (ChatGPT 앱 스타일)
class DreamFortuneVoicePage extends ConsumerStatefulWidget {
  const DreamFortuneVoicePage({super.key});

  @override
  ConsumerState<DreamFortuneVoicePage> createState() => _DreamFortuneVoicePageState();
}

class _DreamFortuneVoicePageState extends ConsumerState<DreamFortuneVoicePage> {
  FortuneResult? _fortuneResult;
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  String _userMessage = ''; // 사용자가 입력한 텍스트
  bool _isShowingAd = false; // 광고 표시 중 플래그

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final voiceState = ref.watch(dreamVoiceProvider);

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        // 결과 표시 시 백버튼 제거
        leading: _fortuneResult == null
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: _fortuneResult == null,
        title: Text(
          '꿈 해몽',
          style: TextStyle(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // 결과 표시 시 X 버튼 표시
        actions: _fortuneResult != null
            ? [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          _buildMainContent(isDark, voiceState),

          // 하단 음성 입력 영역
          if (voiceState.state != VoicePageState.result)
            DreamVoiceInputWidget(
              onTextRecognized: _handleTextRecognized,
            ),

          // 결과 화면일 때 블러 해제 버튼
          if (voiceState.state == VoicePageState.result && _isBlurred)
            FloatingBottomButton(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              isEnabled: true,
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark, DreamVoiceState voiceState) {
    switch (voiceState.state) {
      case VoicePageState.initial:
      case VoicePageState.recording: // 녹음 중에도 초기 화면 유지
        return _buildInitialScreen(isDark, voiceState);
      case VoicePageState.processing:
        return _buildProcessingScreen(isDark);
      case VoicePageState.result:
        return _buildResultScreen(isDark);
    }
  }

  /// 초기 화면 (Tip 표시)
  Widget _buildInitialScreen(bool isDark, DreamVoiceState voiceState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Column(
        children: [
          const SizedBox(height: TossTheme.spacingXL),

          // 제목
          Text(
            '💭 당신의 꿈을 들려주세요',
            style: TossTheme.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: TossTheme.spacingXL * 2),

          // 스피커 아이콘
          Icon(
            Icons.speaker,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),

          const SizedBox(height: TossTheme.spacingXL * 2),

          // 도움말 카드
          const DreamInputTipCard(),

          const SizedBox(height: 100), // 하단 입력 영역 여유 공간
        ],
      ),
    );
  }

  /// 처리 중 화면
  Widget _buildProcessingScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: TossTheme.spacingM),
          Text(
            '꿈을 해몽하고 있어요...',
            style: TossTheme.body3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 결과 화면
  Widget _buildResultScreen(bool isDark) {
    if (_fortuneResult == null) {
      return const Center(child: Text('결과를 불러올 수 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 채팅 버블 (오른쪽 정렬)
          if (_userMessage.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: const EdgeInsets.only(bottom: TossTheme.spacingM),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userMessage,
                  style: TypographyUnified.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

          const SizedBox(height: TossTheme.spacingM),

          // 운세 결과
          DreamResultWidget(
            fortuneResult: _fortuneResult!,
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
          ),
          const SizedBox(height: 100), // 버튼 여유 공간
        ],
      ),
    );
  }

  /// 텍스트 인식 완료 처리
  Future<void> _handleTextRecognized(String text) async {
    if (text.isEmpty) return;

    Logger.info('[DreamVoice] 텍스트 인식 완료: $text');

    // 사용자 메시지 저장
    setState(() {
      _userMessage = text;
    });

    // 상태를 처리 중으로 변경
    ref.read(dreamVoiceProvider.notifier).setState(VoicePageState.processing);

    try {
      // 1. 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      // 2. UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      final result = await fortuneService.getFortune(
        fortuneType: 'dream',
        dataSource: FortuneDataSource.api, // 최적화 비활성화
        inputConditions: {
          'dream': text,
          'inputType': 'voice',
          'isPremium': isPremium,
        },
        isPremium: isPremium,
      );

      if (!mounted) return;

      Logger.info('[DreamVoice] 🎯 결과 수신 완료');
      Logger.info('[DreamVoice]   - isBlurred: ${result.isBlurred}');
      Logger.info('[DreamVoice]   - blurredSections: ${result.blurredSections}');
      Logger.info('[DreamVoice]   - data keys: ${result.data.keys.toList()}');
      Logger.info('[DreamVoice]   - interpretation: ${result.data['interpretation']}');

      setState(() {
        _fortuneResult = result;
        _isBlurred = result.isBlurred;
        _blurredSections = result.blurredSections;
      });

      Logger.info('[DreamVoice] 🔄 상태 변경 → result');
      // 상태를 결과 화면으로 변경
      ref.read(dreamVoiceProvider.notifier).setState(VoicePageState.result);
    } catch (e) {
      Logger.error('[DreamVoice] 꿈 해몽 실패: $e', e);

      if (!mounted) return;

      // 에러 발생 시 초기 화면으로 돌아가기
      ref.read(dreamVoiceProvider.notifier).reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('꿈 해몽에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    // ✅ 이미 광고 표시 중이면 무시
    if (_isShowingAd) {
      Logger.warning('[DreamVoice] ⚠️ 광고가 이미 표시 중입니다. 중복 호출 무시');
      return;
    }

    try {
      _isShowingAd = true; // 광고 표시 시작
      final adService = AdService.instance;

      // 광고가 준비되지 않았다면 백그라운드에서 로드
      if (!adService.isRewardedAdReady) {
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 여전히 준비되지 않았다면 에러 메시지
        if (!adService.isRewardedAdReady) {
          Logger.warning('[DreamVoice] ⚠️ Rewarded ad still not ready after loading');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 준비할 수 없습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      Logger.info('[DreamVoice] 광고 시청 후 블러 해제 시작');

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          Logger.info('[DreamVoice] ✅ User earned reward: ${reward.amount} ${reward.type}');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
              _isShowingAd = false; // ✅ 광고 완료, 플래그 리셋
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('운세가 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      Logger.error('[DreamVoice] ❌ Failed to show rewarded ad: $e', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 표시할 수 없습니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // ✅ 광고가 닫히거나 에러 발생 시 항상 플래그 리셋
      _isShowingAd = false;
    }
  }
}
