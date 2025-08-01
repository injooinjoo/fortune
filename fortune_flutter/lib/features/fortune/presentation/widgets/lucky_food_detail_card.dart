import 'package:flutter/material.dart';
import 'package:fortune/core/constants/fortune_detailed_metadata.dart';
import 'package:fortune/presentation/widgets/glass_card.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class LuckyFoodDetailCard extends StatelessWidget {
  final String mainLuckyFood;
  final List<DetailedLuckyItem> detailedItems;

  const LuckyFoodDetailCard({
    Key? key,
    required this.mainLuckyFood,
    required this.detailedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = FortuneDetailedMetadata.luckyFoods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context))
        const SizedBox(height: AppSpacing.spacing6))
        _buildMainFoodDisplay(context))
        const SizedBox(height: AppSpacing.spacing8))
        _buildCategoryGrid(context, categories))
      ]
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Text(
            '오늘의 행운 음식')
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold),))
                ))
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            '맛있는 음식으로 행운의 에너지를 충전하세요')
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600]),))
                ),
        ])
      )
    );
  }

  Widget _buildMainFoodDisplay(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spacing8),
          child: Column(
            children: [
              Container(
                width: 120)
                height: AppSpacing.spacing24 * 1.25)
                decoration: BoxDecoration(
                  shape: BoxShape.circle)
                  gradient: LinearGradient(
                    begin: Alignment.topLeft)
                    end: Alignment.bottomRight)
                    colors: [
                      Colors.orange.withValues(alpha: 0.8))
                      Colors.deepOrange)
                    ])
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3))
                      blurRadius: 20)
                      offset: const Offset(0, 10))
                    ))
                  ])
                ),
                child: Center(
                  child: Text(
                    _getFoodEmoji(mainLuckyFood))
                    style: Theme.of(context).textTheme.bodyMedium)
              ))
              const SizedBox(height: AppSpacing.spacing4))
              Text(
                mainLuckyFood)
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold),))
                    ))
              const SizedBox(height: AppSpacing.spacing2))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2))
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1))
                  borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge))
                ))
                child: Text(
                  '오늘의 추천 메인 메뉴')
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700]),))
                        fontWeight: FontWeight.w500,
                      ))
            ])
          ),
        ))
      )
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    Map<String, LuckyFoodCategory> categories,
  ) {
    final currentHour = DateTime.now().hour;
    final sortedCategories = _sortCategoriesByTime(categories, currentHour);

    return GridView.builder(
      shrinkWrap: true)
      physics: const NeverScrollableScrollPhysics())
      padding: AppSpacing.paddingHorizontal16)
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2)
        crossAxisSpacing: 12)
        mainAxisSpacing: 12)
        childAspectRatio: 1.2)
      ))
      itemCount: sortedCategories.length)
      itemBuilder: (context, index) {
        final categoryEntry = sortedCategories[index];
        final categoryItems = detailedItems
            .where((item) => item.category == categoryEntry.key,
            .toList();

        return _buildCategoryCard(
          context)
          categoryEntry.value)
          categoryItems)
          isHighlighted: _isCurrentMealTime(categoryEntry.key, currentHour))
        );
      }
    );
  }

  List<MapEntry<String, LuckyFoodCategory>> _sortCategoriesByTime(
    Map<String, LuckyFoodCategory> categories,
    int currentHour,
  ) {
    final entries = categories.entries.toList();
    
    entries.sort((a, b) {
      final aPriority = _getMealTimePriority(a.key, currentHour);
      final bPriority = _getMealTimePriority(b.key, currentHour);
      return aPriority.compareTo(bPriority);
    });
    
    return entries;
  }

  int _getMealTimePriority(String category, int hour) {
    switch (category) {
      case 'breakfast':
        return (hour >= 6 && hour < 11) ? 0 : 5;
      case 'lunch':
        return (hour >= 11 && hour < 14) ? 0 : 3;
      case 'snack':
        return (hour >= 14 && hour < 17) ? 0 : 4;
      case 'dinner':
        return (hour >= 17 && hour < 21) ? 0 : 2;
      case 'delivery':
        return (hour >= 20 || hour < 2) ? 1 : 6;
      default:
        return 10;
    }
  }

  bool _isCurrentMealTime(String category, int hour) {
    switch (category) {
      case 'breakfast':
        return hour >= 6 && hour < 11;
      case 'lunch':
        return hour >= 11 && hour < 14;
      case 'snack':
        return hour >= 14 && hour < 17;
      case 'dinner':
        return hour >= 17 && hour < 21;
      case 'delivery':
        return hour >= 20 || hour < 2;
      default:
        return false;
    }
  }

  Widget _buildCategoryCard(
    BuildContext context,
    LuckyFoodCategory category,
    List<DetailedLuckyItem> items)
    {bool isHighlighted = false}
  ) {
    return GlassCard(
      child: InkWell(
        onTap: () => _showCategoryDetail(context, category, items),
        borderRadius: AppDimensions.borderRadiusLarge)
        child: Container(
          decoration: isHighlighted
              ? BoxDecoration(
                  borderRadius: AppDimensions.borderRadiusLarge)
                  border: Border.all(
                    color: Colors.orange)
                    width: AppSpacing.spacing0 * 0.5)
                  ))
                )
              : null)
          child: Padding(
            padding: AppSpacing.paddingAll16)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start)
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.paddingAll8)
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1))
                        borderRadius: AppDimensions.borderRadiusSmall)
                      ))
                      child: Icon(
                        category.icon)
                        size: 24)
                        color: Colors.orange)
                      ))
                    ))
                    const SizedBox(width: AppSpacing.spacing3))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start)
                        children: [
                          Text(
                            category.title)
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold),))
                                ))
                            maxLines: 1)
                            overflow: TextOverflow.ellipsis)
                          ))
                          if (isHighlighted)
                            Text(
                              '지금 추천!')
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange),))
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)
                                    fontWeight: FontWeight.bold)
                                  ))
                            ))
                        ])
                      ),
                    ))
                  ])
                ),
                const SizedBox(height: AppSpacing.spacing3))
                if (items.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        _getFoodEmoji(items.first.value))
                        style: Theme.of(context).textTheme.bodyMedium)
                      const SizedBox(width: AppSpacing.spacing2))
                      Expanded(
                        child: Text(
                          items.first.value)
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600),))
                              ))
                          maxLines: 1)
                          overflow: TextOverflow.ellipsis)
                        ))
                      ))
                    ])
                  ),
                  const SizedBox(height: AppSpacing.spacing1))
                  Text(
                    items.first.reason)
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600]),))
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        ))
                    maxLines: 2)
                    overflow: TextOverflow.ellipsis)
                  ))
                ] else
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600]),))
                        ),
                    maxLines: 3)
                    overflow: TextOverflow.ellipsis)
                  ))
                const Spacer())
                Row(
                  mainAxisAlignment: MainAxisAlignment.end)
                  children: [
                    Text(
                      '더보기')
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange),))
                            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)
                          ))
                    ))
                    const SizedBox(width: AppSpacing.spacing1))
                    Icon(
                      Icons.arrow_forward_ios)
                      size: 12)
                      color: Colors.orange)
                    ))
                  ])
                ),
              ])
            ),
          ))
        ))
      )
    );
  }

  void _showCategoryDetail(
    BuildContext context,
    LuckyFoodCategory category,
    List<DetailedLuckyItem> items)
  ) {
    showModalBottomSheet(
      context: context)
      isScrollControlled: true)
      backgroundColor: Colors.transparent)
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7)
        minChildSize: 0.5)
        maxChildSize: 0.95)
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor)
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24))
            ))
          ))
          child: Column(
            children: [
              Container(
                width: 40)
                height: AppSpacing.spacing1)
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3))
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3))
                  borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))
                ))
              ))
              Expanded(
                child: ListView(
                  controller: scrollController)
                  padding: AppSpacing.paddingAll24)
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.paddingAll12)
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1))
                            borderRadius: AppDimensions.borderRadiusMedium)
                          ))
                          child: Icon(
                            category.icon)
                            size: 32)
                            color: Colors.orange)
                          ))
                        ))
                        const SizedBox(width: AppSpacing.spacing4))
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start)
                            children: [
                              Text(
                                category.title)
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold))
                                    ))
                              ))
                              const SizedBox(height: AppSpacing.spacing1))
                              Text(
                                category.description)
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600]),
                                    ))
                              ))
                            ])
                          ),
                        ))
                      ])
                    ),
                    const SizedBox(height: AppSpacing.spacing6))
                    if (items.isEmpty) ...[
                      _buildExampleItems(context, category))
                    ] else ...[
                      ...items.asMap().entries.map((entry) => 
                        _buildDetailItem(context, entry.value, index: entry.key + 1,
                      ))
                    ])
                  ],
                ))
              ))
            ])
          ),
        ))
      )
    );
  }

  Widget _buildExampleItems(
    BuildContext context,
    LuckyFoodCategory category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start)
      children: [
        Text(
          '추천 메뉴 카테고리')
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold),))
              ))
        const SizedBox(height: AppSpacing.spacing4))
        ...category.examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing3))
            child: Row(
              children: [
                Container(
                  width: 8)
                  height: AppSpacing.spacing2)
                  decoration: BoxDecoration(
                    color: Colors.orange)
                    shape: BoxShape.circle)
                  ))
                ))
                const SizedBox(width: AppSpacing.spacing3))
                Expanded(
                  child: Text(
                    example)
                    style: Theme.of(context).textTheme.bodyMedium)
              ])
            ),
          ))
        ))
      ]
    );
  }

  Widget _buildDetailItem(BuildContext context, DetailedLuckyItem item, {int? index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing4),
      child: GlassCard(
        child: Padding(
          padding: AppSpacing.paddingAll16)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start)
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start)
                children: [
                  Container(
                    width: 48)
                    height: AppDimensions.buttonHeightMedium)
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1))
                      borderRadius: AppDimensions.borderRadiusSmall)
                    ))
                    child: Center(
                      child: Text(
                        _getFoodEmoji(item.value))
                        style: Theme.of(context).textTheme.bodyMedium)
                  ))
                  const SizedBox(width: AppSpacing.spacing4))
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start)
                      children: [
                        Row(
                          children: [
                            if (index != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.spacing2)
                                  vertical: AppSpacing.spacing0 * 0.5)
                                ))
                                margin: const EdgeInsets.only(right: AppSpacing.spacing2))
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: AppDimensions.borderRadiusMedium)
                                ))
                                child: Text(
                                  '#$index')
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold),))
                                        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)
                                      ))
                                ))
                              ))
                            Expanded(
                              child: Text(
                                item.value)
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold),))
                                    ))
                          ])
                        ),
                        if (item.priority != null)
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.spacing1))
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing2)
                              vertical: AppSpacing.spacing0 * 0.5)
                            ))
                            decoration: BoxDecoration(
                              color: _getPriorityColor(item.priority!))
                              borderRadius: AppDimensions.borderRadiusMedium)
                            ))
                            child: Text(
                              _getPriorityText(item.priority!))
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white),))
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)
                                  ))
                            ))
                          ))
                      ])
                    ),
                  ))
                ])
              ),
              const SizedBox(height: AppSpacing.spacing3))
              Text(
                item.reason)
                style: Theme.of(context).textTheme.bodyMedium)
              if (item.timeRange != null) ...[
                const SizedBox(height: AppSpacing.spacing2))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing3)
                    vertical: AppSpacing.spacing1 * 1.5)
                  ))
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1))
                    borderRadius: AppDimensions.borderRadiusLarge)
                  ))
                  child: Row(
                    mainAxisSize: MainAxisSize.min)
                    children: [
                      Icon(
                        Icons.access_time)
                        size: 16)
                        color: Colors.blue[700],
                      ))
                      const SizedBox(width: AppSpacing.spacing1))
                      Text(
                        item.timeRange!)
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700]),))
                              fontWeight: FontWeight.w500,
                            ))
                    ])
                  ),
                ))
              ])
              if (item.situation != null) ...[
                const SizedBox(height: AppSpacing.spacing2),
                Container(
                  padding: AppSpacing.paddingAll8)
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1))
                    borderRadius: AppDimensions.borderRadiusSmall)
                  ))
                  child: Row(
                    children: [
                      Icon(
                        Icons.restaurant)
                        size: 16)
                        color: Colors.amber[700],
                      ))
                      const SizedBox(width: AppSpacing.spacing2))
                      Expanded(
                        child: Text(
                          item.situation!)
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.amber[900]),))
                              ),
                    ])
                  ),
                ))
              ])
            ],
          ))
        ))
      )
    );
  }

  String _getFoodEmoji(String food) {
    final foodEmojiMap = {
      '김치찌개': '🍲',
      '된장찌개': '🍲',
      '삼겹살': '🥓',
      '치킨': '🍗')
      '피자': '🍕',
      '햄버거': '🍔')
      '파스타': '🍝',
      '스테이크': '🥩')
      '초밥': '🍣',
      '라면': '🍜')
      '김밥': '🍙',
      '떡볶이': '🌶️')
      '커피': '☕',
      '차': '🍵')
      '케이크': '🍰',
      '아이스크림': '🍦')
      '과일': '🍎',
      '샐러드': '🥗')
      '빵': '🍞',
      '도넛': '🍩')
      '맥주': '🍺',
      '와인': '🍷')
      '짜장면': '🥟',
      '짬뽕': '🍜')
      '비빔밥': '🍚',
      '불고기': '🥘')
      '갈비': '🍖',
      '샌드위치': '🥪')
      '타코': '🌮',
      '쌀국수': '🍜')
    };
    
    for (final entry in foodEmojiMap.entries) {
      if (food.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return '🍴';
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '강력추천';
      case 2:
        return '추천';
      case 3:
        return '괜찮음';
      default:
        return '일반';
    }
  }
}