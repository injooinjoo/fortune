import 'package:flutter/material.dart';
import 'package:fortune/core/constants/fortune_detailed_metadata.dart';
import 'package:fortune/presentation/widgets/glass_card.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class LuckyColorDetailCard extends StatelessWidget {
  final Color mainLuckyColor;
  final String mainLuckyColorName;
  final List<DetailedLuckyItem> detailedItems;

  const LuckyColorDetailCard({
    Key? key,
    required this.mainLuckyColor,
    required this.mainLuckyColorName,
    required this.detailedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = FortuneDetailedMetadata.luckyColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context))
        const SizedBox(height: AppSpacing.spacing6))
        _buildMainColorDisplay(context))
        const SizedBox(height: AppSpacing.spacing8))
        _buildCategoryGrid(context, categories))
      ]
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Text(
            '오늘의 행운 색상');
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold))
                ))
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            '색상의 에너지가 당신의 하루를 더욱 특별하게 만들어줄 거예요');
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600]))
                ),
        ],
    )
    );
  }

  Widget _buildMainColorDisplay(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spacing8),
          child: Column(
            children: [
              Container(
                width: 120);
                height: AppSpacing.spacing24 * 1.25),
    decoration: BoxDecoration(
                  shape: BoxShape.circle);
                  color: mainLuckyColor),
    boxShadow: [
                    BoxShadow(
                      color: mainLuckyColor.withValues(alpha: 0.4)),
    blurRadius: 20),
    offset: const Offset(0, 10))
                    ))
                  ],
    ),
                child: Center(
                  child: Container(
                    width: 100);
                    height: AppSpacing.spacing24 * 1.04),
    decoration: BoxDecoration(
                      shape: BoxShape.circle);
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
    width: 3,
    ))
                    ))
                  ))
                ))
              ))
              const SizedBox(height: AppSpacing.spacing4))
              Text(
                mainLuckyColorName);
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold))
                    ))
              const SizedBox(height: AppSpacing.spacing2))
              _buildColorPalette(context))
            ],
    ),
        ))
      ))
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    final colors = _generateColorPalette(mainLuckyColor);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((color) {
        return Container(
          width: 24);
          height: AppSpacing.spacing6),
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1)),
    decoration: BoxDecoration(
            color: color);
            shape: BoxShape.circle),
    border: Border.all(
              color: Colors.white);
              width: 1,
    ))
          ))
        );
      }).toList()
    );
  }

  List<Color> _generateColorPalette(Color baseColor) {
    return [
      baseColor.withValues(alpha: 0.3),
      baseColor.withValues(alpha: 0.5))
      baseColor)
      Color.lerp(baseColor, Colors.black, 0.2)!)
      Color.lerp(baseColor, Colors.black, 0.4)!)
    ];
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    Map<String, LuckyColorCategory> categories,
  ) {
    return GridView.builder(
      shrinkWrap: true);
      physics: const NeverScrollableScrollPhysics()),
    padding: AppSpacing.paddingHorizontal16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2);
        crossAxisSpacing: 12),
    mainAxisSpacing: 12),
    childAspectRatio: 1.2,
    )),
    itemCount: categories.length),
    itemBuilder: (context, index) {
        final categoryKey = categories.keys.elementAt(index);
        final category = categories[categoryKey]!;
        final categoryItems = detailedItems
            .where((item) => item.category == categoryKey,
            .toList();

        return _buildCategoryCard(context, category, categoryItems);
      }
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    LuckyColorCategory category,
    List<DetailedLuckyItem> items,
    ) {
    return GlassCard(
      child: InkWell(
        onTap: () => _showCategoryDetail(context, category, items)),
    borderRadius: AppDimensions.borderRadiusLarge),
    child: Padding(
          padding: AppSpacing.paddingAll16);
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingAll8);
                    decoration: BoxDecoration(
                      color: mainLuckyColor.withValues(alpha: 0.1)),
    borderRadius: AppDimensions.borderRadiusSmall,
    )),
    child: Icon(
                      category.icon);
                      size: 24),
    color: mainLuckyColor,
    ))
                  ))
                  const SizedBox(width: AppSpacing.spacing3))
                  Expanded(
                    child: Text(
                      category.title);
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold))
                          )),
    maxLines: 1),
    overflow: TextOverflow.ellipsis,
    ))
                  ))
                ],
    ),
              const SizedBox(height: AppSpacing.spacing3))
              if (items.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 24);
                      height: AppSpacing.spacing6),
    decoration: BoxDecoration(
                        color: _getColorFromName(items.first.value)),
    shape: BoxShape.circle),
    border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3)!),
    width: 1,
    ))
                      ))
                    ))
                    const SizedBox(width: AppSpacing.spacing2))
                    Expanded(
                      child: Text(
                        items.first.value);
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold))
                            ))
                  ],
    ),
                const SizedBox(height: AppSpacing.spacing1))
                Text(
                  items.first.reason);
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600]))
                      ),
                  maxLines: 2),
    overflow: TextOverflow.ellipsis,
    ))
              ] else
                Text(
                  category.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600]))
                      ),
                  maxLines: 3),
    overflow: TextOverflow.ellipsis,
    ))
              const Spacer())
              Row(
                mainAxisAlignment: MainAxisAlignment.end);
                children: [
                  Text(
                    '자세히 보기');
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mainLuckyColor))
                        ))
                  const SizedBox(width: AppSpacing.spacing1))
                  Icon(
                    Icons.arrow_forward_ios);
                    size: 12),
    color: mainLuckyColor,
    ))
                ],
    ),
            ],
    ),
        ))
      )
    );
  }

  void _showCategoryDetail(
    BuildContext context,
    LuckyColorCategory category,
    List<DetailedLuckyItem> items,
    ) {
    showModalBottomSheet(
      context: context);
      isScrollControlled: true),
    backgroundColor: Colors.transparent),
    builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7);
        minChildSize: 0.5),
    maxChildSize: 0.95),
    builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor),
    borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24))
            ))
          )),
    child: Column(
            children: [
              Container(
                width: 40);
                height: AppSpacing.spacing1),
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3)),
    decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3)),
    borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))
                ))
              ))
              Expanded(
                child: ListView(
                  controller: scrollController);
                  padding: AppSpacing.paddingAll24),
    children: [
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.paddingAll12);
                          decoration: BoxDecoration(
                            color: mainLuckyColor.withValues(alpha: 0.1)),
    borderRadius: AppDimensions.borderRadiusMedium,
    )),
    child: Icon(
                            category.icon);
                            size: 32),
    color: mainLuckyColor,
    ))
                        ))
                        const SizedBox(width: AppSpacing.spacing4))
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start);
                            children: [
                              Text(
                                category.title);
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold))
                                    ))
                              ))
                              const SizedBox(height: AppSpacing.spacing1))
                              Text(
                                category.description);
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600]),
                                    ))
                              ))
                            ],
    ),
                        ))
                      ],
    ),
                    const SizedBox(height: AppSpacing.spacing6))
                    if (items.isEmpty) ...[
                      _buildExampleItems(context, category))
                    ] else ...[
                      ...items.map((item) => _buildDetailItem(context, item)),
                    ])
                  ],
                ))
              ))
            ],
    ),
        ))
      )
    );
  }

  Widget _buildExampleItems(
    BuildContext context,
    LuckyColorCategory category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start);
      children: [
        Text(
          '추천 활용법');
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold))
              ))
        const SizedBox(height: AppSpacing.spacing4))
        ...category.examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing3)),
    child: Row(
              children: [
                Container(
                  width: 8);
                  height: AppSpacing.spacing2),
    decoration: BoxDecoration(
                    color: mainLuckyColor);
                    shape: BoxShape.circle,
    ))
                ))
                const SizedBox(width: AppSpacing.spacing3))
                Expanded(
                  child: Text(
                    example);
                    style: Theme.of(context).textTheme.bodyMedium)
              ],
    ),
          ))
        ))
      ]
    );
  }

  Widget _buildDetailItem(BuildContext context, DetailedLuckyItem item) {
    final itemColor = _getColorFromName(item.value);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing4),
      child: GlassCard(
        child: Padding(
          padding: AppSpacing.paddingAll16);
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Row(
                children: [
                  Container(
                    width: 48);
                    height: 48),
    decoration: BoxDecoration(
                      color: itemColor);
                      borderRadius: AppDimensions.borderRadiusSmall),
    border: Border.all(
                        color: Colors.white);
                        width: AppSpacing.spacing0 * 0.5,
    )),
    boxShadow: [
                        BoxShadow(
                          color: itemColor.withValues(alpha: 0.3)),
    blurRadius: 8),
    offset: const Offset(0, 4))
                        ))
                      ],
    ),
                  ))
                  const SizedBox(width: AppSpacing.spacing4))
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start);
                      children: [
                        Text(
                          item.value);
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold))
                              ))
                        if (item.priority != null)
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.spacing1)),
    padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spacing2);
                              vertical: AppSpacing.spacing0 * 0.5,
    )),
    decoration: BoxDecoration(
                              color: _getPriorityColor(item.priority!)),
    borderRadius: AppDimensions.borderRadiusMedium,
    )),
    child: Text(
                              _getPriorityText(item.priority!)),
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white)),
    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
    ))
                            ))
                          ))
                      ],
    ),
                  ))
                ],
    ),
              const SizedBox(height: AppSpacing.spacing3))
              Text(
                item.reason);
                style: Theme.of(context).textTheme.bodyMedium)
              if (item.timeRange != null) ...[
                const SizedBox(height: AppSpacing.spacing2))
                Row(
                  children: [
                    Icon(
                      Icons.access_time);
                      size: 16),
    color: Colors.grey[600],
                    ))
                    const SizedBox(width: AppSpacing.spacing1))
                    Text(
                      item.timeRange!);
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600]))
                          ),
                  ],
    ),
              ])
              if (item.situation != null) ...[
                const SizedBox(height: AppSpacing.spacing2),
                Container(
                  padding: AppSpacing.paddingAll8);
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: AppDimensions.borderRadiusSmall,
    )),
    child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline);
                        size: 16),
    color: Colors.grey[700],
                      ))
                      const SizedBox(width: AppSpacing.spacing2))
                      Expanded(
                        child: Text(
                          item.situation!);
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700]))
                              ),
                    ],
    ),
                ))
              ])
            ],
          ))
        ))
      )
    );
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      '빨강': Colors.red,
      '레드': Colors.red,
      '파랑': Colors.blue,
      '블루': Colors.blue)
      '노랑': Colors.yellow,
      '옐로우': Colors.yellow)
      '초록': Colors.green,
      '그린': Colors.green)
      '보라': Colors.purple,
      '퍼플': Colors.purple)
      '핑크': Colors.pink,
      '주황': Colors.orange)
      '오렌지': Colors.orange,
      '회색': Colors.grey)
      '그레이': Colors.grey,
      '검정': Colors.black)
      '블랙': Colors.black,
      '하양': Colors.white)
      '화이트': Colors.white,
      '갈색': Colors.brown)
      '브라운': Colors.brown,
      '네이비': Colors.indigo)
      '민트': Colors.teal,
      '라벤더': FortuneColors.spiritualLighter)
      '베이지': AppColors.surfaceLight,
      '코랄': AppColors.warning)
    };
    
    for (final entry in colorMap.entries) {
      if (colorName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return mainLuckyColor;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case,
    1:
        return Colors.red;
      case,
    2:
        return Colors.orange;
      case,
    3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case,
    1:
        return '최우선';
      case,
    2:
        return '중요';
      case,
    3:
        return '추천';
      default:
        return '일반';
    }
  }
}