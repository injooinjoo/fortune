import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/toss_bottom_sheet.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../services/ad_service.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';

class LuckyItemsBottomSheet extends ConsumerStatefulWidget {
  const LuckyItemsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    // Riverpod container에서 provider 읽기
    final container = ProviderScope.containerOf(context);
    
    // 네비게이션 바 숨기기
    container.read(navigationVisibilityProvider.notifier).hide();
    
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const LuckyItemsBottomSheet(),
    ).whenComplete(() {
      // Bottom Sheet가 닫힐 때 네비게이션 바 다시 표시
      container.read(navigationVisibilityProvider.notifier).show();
    });
  }

  @override
  ConsumerState<LuckyItemsBottomSheet> createState() => _LuckyItemsBottomSheetState();
}

class _LuckyItemsBottomSheetState extends ConsumerState<LuckyItemsBottomSheet> {
  bool _isLoadingAd = false;

  // 8개 카테고리 정의
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'lotto',
      'title': '로또 번호',
      'icon': Icons.casino,
      'color': Color(0xFFFFB300),
      'description': '행운의 번호와 최적 구매 시간'
    },
    {
      'id': 'shopping',
      'title': '쇼핑',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFE91E63),
      'description': '오늘의 럭키 아이템과 구매 팁'
    },
    {
      'id': 'game',
      'title': '게임',
      'icon': Icons.games,
      'color': Color(0xFF9C27B0),
      'description': '승부운을 높이는 게임 추천'
    },
    {
      'id': 'food',
      'title': '음식',
      'icon': Icons.restaurant,
      'color': Color(0xFFFF5722),
      'description': '행운을 부르는 오늘의 음식'
    },
    {
      'id': 'travel',
      'title': '여행',
      'icon': Icons.flight,
      'color': Color(0xFF2196F3),
      'description': '운이 좋은 여행지와 방향'
    },
    {
      'id': 'health',
      'title': '건강',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF4CAF50),
      'description': '건강 운세와 주의사항'
    },
    {
      'id': 'fashion',
      'title': '패션',
      'icon': Icons.checkroom,
      'color': Color(0xFFFF9800),
      'description': '오늘의 럭키 컬러와 스타일'
    },
    {
      'id': 'lifestyle',
      'title': '라이프스타일',
      'icon': Icons.home,
      'color': Color(0xFF607D8B),
      'description': '일상의 행운을 높이는 팁'
    },
  ];

  void _handleFortuneView() async {
    if (_isLoadingAd) return; // 이미 로딩 중이면 중복 실행 방지

    final isPremium = ref.read(hasUnlimitedAccessProvider);

    if (isPremium) {
      // 프리미엄 사용자는 바로 이동
      _navigateToLuckyItems();
    } else {
      // 무료 사용자는 광고 표시
      setState(() {
        _isLoadingAd = true;
      });

      // AdService를 사용하여 실제 광고 표시
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () {
          if (mounted) {
            setState(() {
              _isLoadingAd = false;
            });
            _navigateToLuckyItems();
          }
        },
        onAdFailed: () {
          // 광고 실패 시에도 페이지로 이동
          if (mounted) {
            setState(() {
              _isLoadingAd = false;
            });
            _navigateToLuckyItems();
          }
        },
      );
    }
  }

  void _navigateToLuckyItems() {
    // 네비게이션 바 복원
    ref.read(navigationVisibilityProvider.notifier).show();
    Navigator.of(context).pop(); // Bottom Sheet 닫기
    context.push('/lucky-items-results');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    return Column(
      children: [
        // 핸들 바
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // 헤더
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 행운 아이템',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191F28),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '당신만을 위한 특별한 행운을 찾아보세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8B95A1),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(navigationVisibilityProvider.notifier).show();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
        ),
        
        // 스크롤 가능한 컨텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 설명 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF1F4EF5),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '오늘만의 특별한 행운',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191F28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '매일 새롭게 업데이트되는 8가지 카테고리의 행운 정보를 확인하세요. 로또 번호부터 오늘의 럭키 컬러까지, 당신의 하루를 더욱 특별하게 만들어 드립니다.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF4E5968),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 카테고리 미리보기
                Text(
                  '확인할 수 있는 행운 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191F28),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 카테고리 그리드
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3.5,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              category['icon'],
                              size: 16,
                              color: category['color'],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category['title'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF191F28),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // 하단 버튼 (FloatingBottomButton과 동일한 위치)
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0, // FloatingBottomButton과 동일하게 상단 패딩 제거
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '🍀 나의 행운 아이템 찾기',
              onPressed: _isLoadingAd ? null : _handleFortuneView,
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
              icon: _isLoadingAd ? null : Icon(Icons.auto_awesome),
              isLoading: _isLoadingAd,
            ),
          ),
        ),
      ],
    );
  }

}