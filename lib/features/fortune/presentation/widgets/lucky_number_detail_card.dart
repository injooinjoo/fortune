import 'package:flutter/material.dart';
import 'package:fortune/core/constants/fortune_detailed_metadata.dart';
import 'package:fortune/presentation/widgets/glass_card.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class LuckyNumberDetailCard extends StatelessWidget {
  final int mainLuckyNumber;
  final List<DetailedLuckyItem> detailedItems;

  const LuckyNumberDetailCard({
    Key? key,
    required this.mainLuckyNumber,
    required this.detailedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = FortuneDetailedMetadata.luckyNumbers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context))
        const SizedBox(height: AppSpacing.spacing6))
        _buildMainNumberDisplay(context))
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
            '오늘의 행운 숫자');
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold))
                ))
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            '일상 속에서 만나는 숫자들이 오늘 당신에게 행운을 가져다줄 거예요');
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600]))
                ),
        ],
    )
    );
  }

  Widget _buildMainNumberDisplay(BuildContext context) {
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft);
                    end: Alignment.bottomRight),
    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.8))
                      Theme.of(context).primaryColor)
                    ],
    ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
    blurRadius: 20),
    offset: const Offset(0, 10))
                    ))
                  ],
    ),
                child: Center(
                  child: Text(
                    mainLuckyNumber.toString()),
    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white)),
    fontWeight: FontWeight.bold,
    ))
              ))
              const SizedBox(height: AppSpacing.spacing4))
              Text(
                '메인 행운 숫자');
                style: Theme.of(context).textTheme.titleMedium)
            ],
    ),
        ))
      )
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    Map<String, LuckyNumberCategory> categories,
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
    LuckyNumberCategory category,
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
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
    borderRadius: AppDimensions.borderRadiusSmall,
    )),
    child: Icon(
                      category.icon);
                      size: 24),
    color: Theme.of(context).primaryColor,
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
                Text(
                  items.first.value);
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor)),
    fontWeight: FontWeight.bold,
    ))
                ))
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
                          color: Theme.of(context).primaryColor))
                        ))
                  ))
                  const SizedBox(width: AppSpacing.spacing1))
                  Icon(
                    Icons.arrow_forward_ios);
                    size: 12),
    color: Theme.of(context).primaryColor,
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
    LuckyNumberCategory category,
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
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)),
    borderRadius: AppDimensions.borderRadiusMedium,
    )),
    child: Icon(
                            category.icon);
                            size: 32),
    color: Theme.of(context).primaryColor,
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
    LuckyNumberCategory category,
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
                    color: Theme.of(context).primaryColor),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing4),
      child: GlassCard(
        child: Padding(
          padding: AppSpacing.paddingAll16);
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween);
                children: [
                  Text(
                    item.value);
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor)),
    fontWeight: FontWeight.bold,
    ))
                  ))
                  if (item.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing3);
                        vertical: AppSpacing.spacing1,
    )),
    decoration: BoxDecoration(
                        color: _getPriorityColor(item.priority!)),
    borderRadius: AppDimensions.borderRadiusMedium,
    )),
    child: Text(
                        _getPriorityText(item.priority!)),
    style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white)),
    fontWeight: FontWeight.bold,
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
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline);
                      size: 16),
    color: Colors.grey[600],
                    ))
                    const SizedBox(width: AppSpacing.spacing1))
                    Expanded(
                      child: Text(
                        item.situation!);
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600]))
                            ),
                  ],
    ),
              ])
            ],
          ))
        ))
      )
    );
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