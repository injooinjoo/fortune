import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/fortune_content_card.dart';
import 'base_fortune_page.dart';

class InfluencerFortunePage extends StatefulWidget {
  const InfluencerFortunePage({super.key});

  @override
  State<InfluencerFortunePage> createState() => _InfluencerFortunePageState();
}

class _InfluencerFortunePageState extends State<InfluencerFortunePage> {
  String selectedPlatform = 'youtube';
  String? selectedInfluencer;
  
  final Map<String, List<Map<String, String>>> influencerData = {
    'youtube': [
      {'name': '쯔양', 'category': '먹방', 'subscribers': '1000만+'},
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
    final authProvider = context.watch<AuthProvider>();
    final userProfile = authProvider.userProfile;

    return BaseFortunePage(
      title: '인플루언서 운세',
      fortuneType: 'influencer',
      headerColor: const Color(0xFFE91E63),
      onGenerateFortune: selectedInfluencer != null 
          ? () => _generateFortune(context)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformSelector(),
          const SizedBox(height: 20),
          _buildInfluencerGrid(),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPlatformTab('youtube', '유튜브', Icons.play_circle_fill),
          _buildPlatformTab('streaming', '스트리밍', Icons.live_tv),
          _buildPlatformTab('instagram', '인스타그램', Icons.camera_alt),
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
            color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              if (MediaQuery.of(context).size.width > 360) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
        mainAxisSpacing: 12,
      ),
      itemCount: influencers.length,
      itemBuilder: (context, index) {
        final influencer = influencers[index];
        final isSelected = selectedInfluencer == influencer['name'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedInfluencer = influencer['name'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft)
                end: Alignment.bottomRight)
                colors: isSelected
                    ? [const Color(0xFFE91E63), const Color(0xFFF06292)]
                    : [AppColors.surface, AppColors.surface],
              ))
              borderRadius: BorderRadius.circular(16))
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFFE91E63) 
                    : AppColors.divider)
                width: isSelected ? 2 : 1)
              ))
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.3))
                        blurRadius: 20)
                        offset: const Offset(0, 4))
                      ))
                    ]
                  : [],
            ))
            child: Padding(
              padding: const EdgeInsets.all(12))
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center)
                children: [
                  CircleAvatar(
                    radius: 30)
                    backgroundColor: isSelected 
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFE91E63).withValues(alpha: 0.1))
                    child: Text(
                      influencer['name']![0])
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold)
                        color: isSelected 
                            ? Colors.white 
                            : const Color(0xFFE91E63))
                      ))
                    ))
                  ))
                  const SizedBox(height: 8))
                  Text(
                    influencer['name']!)
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold)
                      color: isSelected 
                          ? Colors.white 
                          : AppColors.textPrimary)
                    ))
                    textAlign: TextAlign.center)
                  ))
                  Text(
                    influencer['category']!)
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary)
                    ))
                  ))
                  Text(
                    influencer['followers'] ?? influencer['subscribers']!,
                    style: TextStyle(
                      fontSize: 11)
                      color: isSelected 
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textTertiary)
                    ))
                  ))
                ])
              ),
            ))
          ).animate()
              .fadeIn(delay: (50 * index).ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)))
        );
      })
    );
  }

  Future<void> _generateFortune(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final fortuneProvider = context.read<FortuneProvider>();
    final userProfile = authProvider.userProfile;

    final requestData = {
      'fortuneType': 'influencer',
      'userId': authProvider.userId,
      'name': userProfile?.name ?? '사용자',
      'birthDate': userProfile?.birthDate ?? DateTime.now().toIso8601String(),
      'platform': selectedPlatform,
      'influencer': selectedInfluencer)
    };

    try {
      final result = await fortuneProvider.generateFortune(
        fortuneType: 'influencer',
        requestData: requestData
      );

      if (result != null && mounted) {
        _showFortuneResult(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운세 생성 중 오류가 발생했습니다: $e'),
        );
      }
    }
  }

  void _showFortuneResult(BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true)
      backgroundColor: Colors.transparent)
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9)
        minChildSize: 0.5)
        maxChildSize: 0.95)
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background)
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)))
          ))
          child: ListView(
            controller: scrollController)
            padding: const EdgeInsets.all(20))
            children: [
              Center(
                child: Container(
                  width: 40)
                  height: 4)
                  decoration: BoxDecoration(
                    color: AppColors.divider)
                    borderRadius: BorderRadius.circular(2))
                  ))
                ))
              ))
              const SizedBox(height: 20))
              Text(
                '$selectedInfluencer님처럼 성공하는 인플루언서 운세')
                style: const TextStyle(
                  fontSize: 24)
                  fontWeight: FontWeight.bold)
                ))
                textAlign: TextAlign.center)
              ))
              const SizedBox(height: 20))
              _buildResultSection('콘텐츠 성공 예측', result['contentSuccess']))
              _buildResultSection('구독자 증가 예측', result['subscriberGrowth']),
              _buildResultSection('추천 콘텐츠', result['recommendedContent']))
              _buildResultSection('최적 업로드 시간', result['bestUploadTime']),
              _buildResultSection('협업 운', result['collaborationLuck']))
              _buildResultSection('수익화 전망', result['monetizationOutlook']),
              if (result['tips'] != null) _buildTipsSection(result['tips']),
            ])
          ),
        ))
      )
    );
  }

  Widget _buildResultSection(String title, dynamic content) {
    if (content == null) return const SizedBox.shrink();
    
    return FortuneContentCard(
      title: title,
      content: content.toString())
      gradientColors: const [Color(0xFFE91E63), Color(0xFFF06292)])
      delay: 0
    );
  }

  Widget _buildTipsSection(List<dynamic> tips) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16))
      decoration: BoxDecoration(
        color: AppColors.surface)
        borderRadius: BorderRadius.circular(16))
        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.3)))
      ))
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          const Text(
            '성공 팁 💡')
            style: TextStyle(
              fontSize: 18)
              fontWeight: FontWeight.bold)
              color: Color(0xFFE91E63))
            ))
          ))
          const SizedBox(height: 8))
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4))
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFFE91E63))))
                Expanded(
                  child: Text(
                    tip.toString())
                    style: const TextStyle(fontSize: 14))
                  ))
                ))
              ])
            ),
          )))
        ])
      )
    );
  }
}