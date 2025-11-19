import 'dart:ui'; // ✅ ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/avoid_people_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/floating_bottom_button.dart'; // ✅ FloatingBottomButton용
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../core/utils/logger.dart'; // ✅ 로그용

class AvoidPeopleFortunePage extends ConsumerStatefulWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  ConsumerState<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}

class _AvoidPeopleFortunePageState extends ConsumerState<AvoidPeopleFortunePage> {
  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 입력 필드들
  String _environment = '';
  String _importantSchedule = '';
  int _moodLevel = 3;
  int _stressLevel = 3;
  int _socialFatigue = 3;
  bool _hasImportantDecision = false;
  bool _hasSensitiveConversation = false;
  bool _hasTeamProject = false;

  bool get _canSubmit =>
      _environment.isNotEmpty && _importantSchedule.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'avoid-people',
      title: '피해야 할 사람',
      description: '오늘 주의해야 할 사람 유형을 분석해드립니다',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // 메인 입력 화면
            SingleChildScrollView(
              padding: const EdgeInsets.all(20).copyWith(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 섹션
                  TossCard(
                    style: TossCardStyle.elevated,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TossDesignSystem.warningOrange,
                                TossDesignSystem.warningOrange.withValues(alpha: 0.8)
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline_rounded,
                              color: TossDesignSystem.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text('오늘 피해야 할 사람',
                            style: TossDesignSystem.heading3.copyWith(
                              color: isDark
                                  ? TossDesignSystem.white
                                  : TossDesignSystem.gray900,
                            )),
                        const SizedBox(height: 8),
                        Text(
                            '현재 상태와 일정을 입력하면\n오늘 주의해야 할 사람 유형을 분석해드립니다',
                            style: TossDesignSystem.body2.copyWith(
                              color: isDark
                                  ? TossDesignSystem.grayDark400
                                  : TossDesignSystem.gray600,
                            ),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 환경 & 일정
                  _buildEnvironmentSection(isDark),
                  const SizedBox(height: 24),

                  // 상태 슬라이더들
                  _buildStateSection(isDark),
                  const SizedBox(height: 24),

                  // 상황 체크박스
                  _buildSituationSection(isDark),
                ],
              ),
            ),

            // FloatingProgressButton
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBottomButton(
                text: '오늘 피해야 할 사람 확인하기',
                onPressed: onComplete,
                isEnabled: _canSubmit,
              ),
            ),
          ],
        );
      },

      conditionsBuilder: () async {
        return AvoidPeopleFortuneConditions(
          environment: _environment,
          importantSchedule: _importantSchedule,
          moodLevel: _moodLevel,
          stressLevel: _stressLevel,
          socialFatigue: _socialFatigue,
          hasImportantDecision: _hasImportantDecision,
          hasSensitiveConversation: _hasSensitiveConversation,
          hasTeamProject: _hasTeamProject,
        );
      },

      resultBuilder: (context, result) {
        // ✅ Blur 상태 동기화
        if (_isBlurred != result.isBlurred) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = result.isBlurred
                    ? ['people_types', 'situation_tips', 'advice']
                    : [];
              });
            }
          });
        }

        final theme = Theme.of(context);
        final content = result.data['content'] as String? ?? '';

        return Stack(
          children: [
            // 메인 콘텐츠
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 섹션 1: 주의 지수 + 종합 요약 (무료)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '피해야 할 사람 분석 결과',
                          style: theme.textTheme.headlineMedium,
                        ),
                        if (result.score != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            '주의 지수: ${result.score}/100',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: TossDesignSystem.warningOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          content.split('\n\n').first,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 섹션 2: 피해야 할 사람 유형 (Premium)
                  _buildBlurWrapper(
                    sectionKey: 'people_types',
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_off, color: TossDesignSystem.errorRed),
                              const SizedBox(width: 8),
                              Text(
                                '피해야 할 사람 유형',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.data['people_types'] as String? ?? '오늘 특별히 주의해야 할 사람 유형 정보',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 섹션 3: 상황별 대처 방법 (Premium)
                  _buildBlurWrapper(
                    sectionKey: 'situation_tips',
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: TossDesignSystem.tossBlue),
                              const SizedBox(width: 8),
                              Text(
                                '상황별 대처 방법',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.data['situation_tips'] as String? ?? '상황별 대처 방법 정보',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 섹션 4: 오늘의 조언 (Premium)
                  _buildBlurWrapper(
                    sectionKey: 'advice',
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tips_and_updates, color: TossDesignSystem.successGreen),
                              const SizedBox(width: 8),
                              Text(
                                '오늘의 조언',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.data['advice'] as String? ?? '오늘의 조언 정보',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // 버튼 공간
                ],
              ),
            ),

            // ✅ FloatingBottomButton (블러 상태일 때만 표시)
            if (_isBlurred)
              FloatingBottomButton(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        );
      },
    );
  }

  // 환경 & 일정 섹션
  Widget _buildEnvironmentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘의 주요 환경',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['직장', '학교', '모임', '가족', '데이트', '집']
              .map((env) => _buildChip(
                  env, _environment == env, () => setState(() => _environment = env), isDark))
              .toList(),
        ),
        const SizedBox(height: 24),
        Text('중요한 일정',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['면접', '프레젠테이션', '미팅', '시험', '데이트', '가족모임', '없음']
              .map((schedule) => _buildChip(schedule, _importantSchedule == schedule,
                  () => setState(() => _importantSchedule = schedule), isDark))
              .toList(),
        ),
      ],
    );
  }

  // 상태 슬라이더 섹션
  Widget _buildStateSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSlider('기분 상태', _moodLevel, (v) => setState(() => _moodLevel = v), isDark),
        const SizedBox(height: 24),
        _buildSlider('스트레스 정도', _stressLevel, (v) => setState(() => _stressLevel = v), isDark),
        const SizedBox(height: 24),
        _buildSlider('사람 만나기 피로도', _socialFatigue,
            (v) => setState(() => _socialFatigue = v), isDark),
      ],
    );
  }

  // 상황 체크박스 섹션
  Widget _buildSituationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('주의할 상황',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        _buildCheckbox('중요한 결정을 해야 함', _hasImportantDecision,
            (v) => setState(() => _hasImportantDecision = v!), isDark),
        _buildCheckbox('민감한 대화가 예상됨', _hasSensitiveConversation,
            (v) => setState(() => _hasSensitiveConversation = v!), isDark),
        _buildCheckbox('팀 프로젝트가 있음', _hasTeamProject,
            (v) => setState(() => _hasTeamProject = v!), isDark),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? TossDesignSystem.tossBlue : (isDark ? TossDesignSystem.white : TossDesignSystem.gray900),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }

  Widget _buildSlider(String label, int value, Function(int) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TossDesignSystem.body1.copyWith(
          color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: value.toString(),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(value.toString(), style: TossDesignSystem.heading2.copyWith(
                color: TossDesignSystem.tossBlue,
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged, bool isDark) {
    return CheckboxListTile(
      title: Text(label, style: TossDesignSystem.body1.copyWith(
        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
      )),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ===== 광고 & 블러 해제 =====

  // ✅ RewardedAd 패턴
  Future<void> _showAdAndUnblur() async {
    debugPrint('[피해야 할 사람] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      if (!adService.isRewardedAdReady) {
        debugPrint('[피해야 할 사람] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[피해야 할 사람] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[피해야 할 사람] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[피해야 할 사람] 광고 표시 실패', e, stackTrace);

      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  // ✅ Blur wrapper helper
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
