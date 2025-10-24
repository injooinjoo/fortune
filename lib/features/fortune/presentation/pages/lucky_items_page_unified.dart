import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/lucky_items_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'dart:math';

/// 오늘의 행운 가이드 페이지
///
/// 로또 번호, 쇼핑, 게임, 음식, 여행, 건강, 패션, 라이프스타일 등
/// 8개 카테고리의 행운 정보를 제공합니다.
class LuckyItemsPageUnified extends ConsumerStatefulWidget {
  const LuckyItemsPageUnified({super.key});

  @override
  ConsumerState<LuckyItemsPageUnified> createState() => _LuckyItemsPageUnifiedState();
}

class _LuckyItemsPageUnifiedState extends ConsumerState<LuckyItemsPageUnified> {
  int _selectedCategoryIndex = 0;

  // 8개 메인 카테고리
  static const List<CategoryModel> _categories = [
    CategoryModel(
      id: 'lotto',
      title: '로또/복권',
      icon: '🎰',
      description: '행운의 번호와 구매 장소',
      color: Color(0xFFFF6B6B),
    ),
    CategoryModel(
      id: 'shopping',
      title: '쇼핑/구매',
      icon: '🛍️',
      description: '쇼핑 운과 구매 타이밍',
      color: Color(0xFFAB47BC),
    ),
    CategoryModel(
      id: 'game',
      title: '게임/엔터',
      icon: '🎮',
      description: '게임과 엔터테인먼트',
      color: Color(0xFF45B7D1),
    ),
    CategoryModel(
      id: 'food',
      title: '음식/맛집',
      icon: '🍜',
      description: '행운의 음식과 맛집',
      color: Color(0xFF66BB6A),
    ),
    CategoryModel(
      id: 'travel',
      title: '여행/장소',
      icon: '✈️',
      description: '행운의 장소와 여행지',
      color: Color(0xFF4ECDC4),
    ),
    CategoryModel(
      id: 'health',
      title: '운동/건강',
      icon: '💪',
      description: '건강 운과 운동 가이드',
      color: Color(0xFF42A5F5),
    ),
    CategoryModel(
      id: 'fashion',
      title: '패션/뷰티',
      icon: '👗',
      description: '오늘의 스타일링',
      color: Color(0xFFEC407A),
    ),
    CategoryModel(
      id: 'lifestyle',
      title: '라이프',
      icon: '🌟',
      description: '일상 속 행운 가이드',
      color: Color(0xFF26A69A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'lucky_items',
      title: '오늘의 행운 가이드',
      description: '로또부터 라이프스타일까지',
      inputBuilder: _buildInput,
      conditionsBuilder: _buildConditions,
      resultBuilder: _buildResult,
      dataSource: FortuneDataSource.api,
      enableOptimization: false,
    );
  }

  /// 입력 화면 (헤더 카드)
  Widget _buildInput(BuildContext context, VoidCallback onSubmit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F4EF5), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F4EF5).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 52, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                '오늘의 행운 가이드',
                style: TypographyUnified.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '로또부터 라이프스타일까지\n실용적인 행운 정보를 확인하세요',
                style: TypographyUnified.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 운세 보기 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: TossDesignSystem.tossBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              '오늘의 행운 확인하기',
              style: TypographyUnified.buttonLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Conditions 생성
  Future<LuckyItemsFortuneConditions> _buildConditions() async {
    final profile = await ref.read(userProfileProvider.future);
    return LuckyItemsFortuneConditions(
      birthDate: profile?.birthDate ?? DateTime.now(),
      birthTime: profile?.birthTime,
      gender: profile?.gender,
      interests: null,
    );
  }

  /// 결과 화면 (블러 적용됨)
  Widget _buildResult(BuildContext context, FortuneResult result) {
    final lottoNumbers = _generateLottoNumbers();

    return Column(
      children: [
        // 카테고리 탭
        _CategoryTabs(
          categories: _categories,
          selectedIndex: _selectedCategoryIndex,
          onSelect: (index) => setState(() => _selectedCategoryIndex = index),
        ),
        const SizedBox(height: 16),

        // 선택된 카테고리 컨텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCategoryContent(_categories[_selectedCategoryIndex], lottoNumbers),
          ),
        ),
      ],
    );
  }

  /// 로또 번호 생성
  List<int> _generateLottoNumbers() {
    final now = DateTime.now();
    final random = Random(now.day + now.month + now.year);
    final numbers = <int>{};

    while (numbers.length < 6) {
      numbers.add(random.nextInt(45) + 1);
    }

    return numbers.toList()..sort();
  }

  /// 카테고리 컨텐츠
  Widget _buildCategoryContent(CategoryModel category, List<int> lottoNumbers) {
    return Column(
      children: [
        // 카테고리 헤더
        _CategoryHeader(category: category),
        const SizedBox(height: 20),

        // 카테고리별 상세 정보
        _buildCategoryDetails(category.id, lottoNumbers),
      ],
    );
  }

  /// 카테고리별 상세 정보
  Widget _buildCategoryDetails(String categoryId, List<int> lottoNumbers) {
    switch (categoryId) {
      case 'lotto':
        return _LottoContent(numbers: lottoNumbers);
      case 'shopping':
        return const _ShoppingContent();
      case 'game':
        return const _GameContent();
      case 'food':
        return const _FoodContent();
      case 'travel':
        return const _TravelContent();
      case 'health':
        return const _HealthContent();
      case 'fashion':
        return const _FashionContent();
      case 'lifestyle':
        return const _LifestyleContent();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ==================== 모델 ====================

class CategoryModel {
  final String id;
  final String title;
  final String icon;
  final String description;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });
}

// ==================== 위젯 컴포넌트 ====================

/// 카테고리 탭 리스트
class _CategoryTabs extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color.withValues(alpha: 0.2)
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? category.color : TossDesignSystem.gray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    category.title,
                    style: TypographyUnified.labelSmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? category.color : TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 카테고리 헤더
class _CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TypographyUnified.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 아이템 위젯
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TypographyUnified.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 카테고리별 컨텐츠 ====================

/// 로또/복권
class _LottoContent extends StatelessWidget {
  final List<int> numbers;

  const _LottoContent({required this.numbers});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 행운 번호',
              style: TypographyUnified.heading4.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers.map((number) {
                return Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TypographyUnified.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const _InfoItem(label: '구매 시간', value: '오후 2시~4시'),
            const _InfoItem(label: '구매 장소', value: '집 근처 편의점'),
            const _InfoItem(label: '행운 번호', value: '1, 7, 21번'),
          ],
        ),
      ),
    );
  }
}

/// 쇼핑/구매
class _ShoppingContent extends StatelessWidget {
  const _ShoppingContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '행운 아이템', value: '블루 톤 액세서리'),
            _InfoItem(label: '쇼핑 장소', value: '온라인 쇼핑몰'),
            _InfoItem(label: '추천 브랜드', value: '자연 친화적 브랜드'),
            _InfoItem(label: '구매 시간', value: '저녁 8시 이후'),
          ],
        ),
      ),
    );
  }
}

/// 게임/엔터
class _GameContent extends StatelessWidget {
  const _GameContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '추천 게임', value: 'RPG, 전략 게임'),
            _InfoItem(label: '추천 콘텐츠', value: '여행 다큐멘터리'),
            _InfoItem(label: '음악', value: '재즈, 클래식'),
            _InfoItem(label: '행운 시간', value: '밤 10시 이후'),
          ],
        ),
      ),
    );
  }
}

/// 음식/맛집
class _FoodContent extends StatelessWidget {
  const _FoodContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '행운 메뉴', value: '매콤한 국물 요리'),
            _InfoItem(label: '추천 장소', value: '한식당, 분식집'),
            _InfoItem(label: '카페', value: '조용한 동네 카페'),
            _InfoItem(label: '식사 시간', value: '점심 12시~1시'),
          ],
        ),
      ),
    );
  }
}

/// 여행/장소
class _TravelContent extends StatelessWidget {
  const _TravelContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '데이트 장소', value: '한강공원 산책로'),
            _InfoItem(label: '드라이브', value: '북한산 둘레길'),
            _InfoItem(label: '산책 장소', value: '남산 타워 주변'),
            _InfoItem(label: '추천 시간', value: '오후 3시~6시'),
          ],
        ),
      ),
    );
  }
}

/// 운동/건강
class _HealthContent extends StatelessWidget {
  const _HealthContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '추천 운동', value: '조깅, 요가'),
            _InfoItem(label: '운동 시간', value: '아침 7시~9시'),
            _InfoItem(label: '운동 장소', value: '헬스장, 요가 스튜디오'),
            _InfoItem(label: '건강 팁', value: '충분한 수분 섭취'),
          ],
        ),
      ),
    );
  }
}

/// 패션/뷰티
class _FashionContent extends StatelessWidget {
  const _FashionContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '럭키 컬러', value: '네이비, 화이트'),
            _InfoItem(label: '스타일링', value: '캐주얼 시크'),
            _InfoItem(label: '액세서리', value: '실버 톤 귀걸이'),
            _InfoItem(label: '뷰티', value: '자연스러운 메이크업'),
          ],
        ),
      ),
    );
  }
}

/// 라이프스타일
class _LifestyleContent extends StatelessWidget {
  const _LifestyleContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '취미 활동', value: '독서, 영화 감상'),
            _InfoItem(label: '만남', value: '친구와 카페에서'),
            _InfoItem(label: 'SNS 시간', value: '저녁 7시~9시'),
            _InfoItem(label: '일상 팁', value: '새로운 시도를 해보세요'),
          ],
        ),
      ),
    );
  }
}
