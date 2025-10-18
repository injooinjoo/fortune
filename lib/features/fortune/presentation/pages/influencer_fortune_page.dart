import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

class InfluencerFortunePage extends ConsumerWidget {
  const InfluencerFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '인플루언서 운세',
      fortuneType: 'influencer',
      headerGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TossDesignSystem.errorRed, TossDesignSystem.errorRed.withValues(alpha: 0.8)]),
      inputBuilder: (context, onSubmit) => _InfluencerInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => Container(
        child: Center(child: Text('Influencer Fortune Result'))),
    );
  }
}

class _InfluencerInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _InfluencerInputForm({required this.onSubmit});

  @override
  State<_InfluencerInputForm> createState() => _InfluencerInputFormState();
}

class _InfluencerInputFormState extends State<_InfluencerInputForm> {
  String selectedPlatform = 'youtube';
  String? selectedInfluencer;
  
  final Map<String, List<Map<String, String>>> influencerData = {
    'youtube': [
      {'name': '히밥', 'category': '먹방', 'subscribers': '1000만+'},
      {'name': '침착맨', 'category': '토크/게임', 'subscribers': '200만+'},
      {'name': '햄지', 'category': '브이로그', 'subscribers': '150만+'},
      {'name': '빠니보틀', 'category': '뷰티', 'subscribers': '100만+'},
      {'name': '승우아빠', 'category': '육아', 'subscribers': '80만+'},
    ],
    'streaming': [
      {'name': '감스트', 'category': '종합게임', 'followers': '150만+'},
      {'name': '우왁굳', 'category': '버추얼/게임', 'followers': '100만+'},
      {'name': '풍월량', 'category': '게임/토크', 'followers': '80만+'},
      {'name': '김도', 'category': '토크/라디오', 'followers': '50만+'},
      {'name': '철면수심', 'category': '게임', 'followers': '40만+'},
    ],
    'instagram': [
      {'name': '제시', 'category': '엔터테인먼트', 'followers': '200만+'},
      {'name': '이사배', 'category': '라이프스타일', 'followers': '150만+'},
      {'name': '한혜진', 'category': '패션/뷰티', 'followers': '100만+'},
      {'name': '박막례', 'category': '일상/요리', 'followers': '80만+'},
      {'name': '이시영', 'category': '피트니스', 'followers': '70만+'},
    ],
    'tiktok': [
      {'name': '옐언니', 'category': '댄스/음악', 'followers': '500만+'},
      {'name': '자이언트펭TV', 'category': '코미디', 'followers': '300만+'},
      {'name': '무야호', 'category': '챌린지', 'followers': '200만+'},
      {'name': '빵빵이', 'category': '먹방', 'followers': '150만+'},
      {'name': '춤추는곰돌', 'category': '댄스', 'followers': '100만+'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlatformSelector(),
        const SizedBox(height: 20),
        _buildInfluencerGrid(),
        if (selectedInfluencer != null) ...[
          const SizedBox(height: 24),
          Center(
            child: TossButton(
              text: '운세 확인하기',
              onPressed: () {
                widget.onSubmit({
                  'platform': selectedPlatform,
                  'influencer': selectedInfluencer,
                });
              },
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: TossDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPlatformTab('youtube', '유튜브', Icons.play_circle),
          _buildPlatformTab('streaming', '스트리밍', Icons.stream),
          _buildPlatformTab('instagram', '인스타그램', Icons.photo_camera),
          _buildPlatformTab('tiktok', '틱톡', Icons.music_note),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPlatformTab(String platform, String label, IconData icon) {
    final isSelected = selectedPlatform == platform;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPlatform = platform;
            selectedInfluencer = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? TossDesignSystem.errorRed : TossDesignSystem.white.withValues(alpha: 0.0),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray500,
              ),
              if (MediaQuery.of(context).size.width > 360) ...[
                SizedBox(width: 4),
                Text(
                  label,
                  style: TypographyUnified.labelMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfluencerGrid() {
    final influencers = influencerData[selectedPlatform] ?? [];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12),
      itemCount: influencers.length,
      itemBuilder: (context, index) {
        final influencer = influencers[index];
        final isSelected = selectedInfluencer == influencer['name'
  ];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedInfluencer = influencer['name'
  ];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [TossDesignSystem.errorRed, TossDesignSystem.errorRed.withValues(alpha: 0.7)]
                    : [TossDesignSystem.backgroundPrimary, TossDesignSystem.backgroundPrimary],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.errorRed
                    : TossDesignSystem.gray300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TossDesignSystem.errorRed.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected 
                        ? TossDesignSystem.white.withValues(alpha: 0.2)
                        : TossDesignSystem.errorRed.withValues(alpha: 0.1),
                    child: Text(
                      influencer['name']![0],
                      style: TypographyUnified.displaySmall.copyWith(
                        color: isSelected
                            ? TossDesignSystem.white
                            : TossDesignSystem.errorRed,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    influencer['name']!,
                    style: TypographyUnified.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? TossDesignSystem.white
                          : TossDesignSystem.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    influencer['category']!,
                    style: TypographyUnified.labelMedium.copyWith(
                      color: isSelected
                          ? TossDesignSystem.white.withValues(alpha: 0.8)
                          : TossDesignSystem.gray500,
                    ),
                  ),
                  Text(
                    influencer['followers'] ?? influencer['subscribers']!,
                    style: TypographyUnified.labelSmall.copyWith(
                      color: isSelected
                          ? TossDesignSystem.white.withValues(alpha: 0.7)
                          : TossDesignSystem.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate()
            .fadeIn(delay: (50 * index).ms, duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      },
    );
  }
}