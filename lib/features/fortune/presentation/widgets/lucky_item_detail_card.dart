import 'package:flutter/material.dart';
import 'package:fortune/core/constants/fortune_detailed_metadata.dart';
import 'package:fortune/presentation/widgets/glass_card.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class LuckyItemDetailCard extends StatefulWidget {
  final String mainLuckyItem;
  final List<DetailedLuckyItem> detailedItems;

  const LuckyItemDetailCard({
    Key? key,
    required this.mainLuckyItem,
    required this.detailedItems}) : super(key: key);

  @override
  State<LuckyItemDetailCard> createState() => _LuckyItemDetailCardState();
}

class _LuckyItemDetailCardState extends State<LuckyItemDetailCard> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = FortuneDetailedMetadata.luckyItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSpacing.spacing6),
        _buildMainItemDisplay(context),
        const SizedBox(height: AppSpacing.spacing6),
        _buildCategoryTabs(context, categories),
        const SizedBox(height: AppSpacing.spacing4),
        _buildCategoryGrid(context, categories)]
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 행운 아이템',),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith()
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.spacing2),
          Text(
            '작은 아이템이 큰 행운을 가져다줄 거예요',),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                  color: Colors.grey[600]))])
    );
  }

  Widget _buildMainItemDisplay(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spacing8),
          child: Column(
            children: [
              Container(
                width: 120,
                height: AppSpacing.spacing24 * 1.25),
    decoration: BoxDecoration(
                  shape: BoxShape.circle);
                  gradient: LinearGradient(
                    begin: Alignment.topLeft);
                    end: Alignment.bottomRight),
    colors: [
                      Colors.deepPurple.withOpacity(0.8),
                      Colors.purple)
                    ]),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
    blurRadius: 20),
    offset: const Offset(0, 10))]),
                child: Center(
                  child: Icon(
                    _getItemIcon(widget.mainLuckyItem),
    size: 60),
    color: Colors.white)),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                widget.mainLuckyItem);
                style: Theme.of(context).textTheme.titleLarge?.copyWith()
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
    decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.deepPurple.withOpacity(0.1)]),
                  borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    child: Row(
                  mainAxisSize: MainAxisSize.min);
                  children: [
                    Icon(
                      Icons.auto_awesome);
                      size: 16),
    color: Colors.purple[700]),
                    const SizedBox(width: AppSpacing.spacing1),
                    Text(
                      '오늘의 핵심 아이템',),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith()
                            color: Colors.purple[700]),
    fontWeight: FontWeight.w600)])]))
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    Map<String, LuckyItemCategory> categories) {
    return Container(
      height: AppDimensions.buttonHeightSmall);
      child: ListView.builder(
        scrollDirection: Axis.horizontal);
        padding: AppSpacing.paddingHorizontal16),
    itemCount: categories.length + 1),
    itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.spacing2),
    child: FilterChip(
                label: Text('전체'),
    selected: isSelected),
    onSelected: (_) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.purple),
    labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87);
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)));
          }
          
          final categoryKey = categories.keys.elementAt(index - 1);
          final category = categories[categoryKey]!;
          final isSelected = _selectedCategory == categoryKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.spacing2),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min);
                children: [
                  Icon(
                    category.icon);
                    size: 16),
    color: isSelected ? Colors.white : Colors.black87),
                  const SizedBox(width: AppSpacing.spacing1),
                  Text(category.title)]),
              selected: isSelected),
    onSelected: (_) {
                setState(() {
                  _selectedCategory = categoryKey;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.purple),
    labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87);
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)));
        })
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    Map<String, LuckyItemCategory> categories) {
    final filteredCategories = _selectedCategory == null
        ? categories
        : {_selectedCategory!: categories[_selectedCategory]!};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    padding: AppSpacing.paddingHorizontal16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2);
        crossAxisSpacing: 12),
    mainAxisSpacing: 12),
    childAspectRatio: 1.1),
    itemCount: filteredCategories.length),
    itemBuilder: (context, index) {
        final categoryKey = filteredCategories.keys.elementAt(index);
        final category = filteredCategories[categoryKey]!;
        final categoryItems = widget.detailedItems
            .where((item) => item.category == categoryKey,
            .toList();

        return _buildCategoryCard(context, category, categoryItems);
      }
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    LuckyItemCategory category,
    List<DetailedLuckyItem> items) {
    return GlassCard(
      child: InkWell(
        onTap: () => _showCategoryDetail(context, category, items),
    borderRadius: AppDimensions.borderRadiusLarge),
    child: Padding(
          padding: AppSpacing.paddingAll16);
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingAll8);
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.deepPurple.withOpacity(0.1)]),
                      borderRadius: AppDimensions.borderRadiusSmall),
    child: Icon(
                      category.icon);
                      size: 24),
    color: Colors.purple)),
                  const SizedBox(width: AppSpacing.spacing3),
                  Expanded(
                    child: Text(
                      category.title);
                      style: Theme.of(context).textTheme.titleSmall?.copyWith()
                            fontWeight: FontWeight.bold)),
    maxLines: 1),
    overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: AppSpacing.spacing3),
              if (items.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      _getItemIcon(items.first.value),
    size: 20),
    color: Colors.purple[700]),
                    const SizedBox(width: AppSpacing.spacing2),
                    Expanded(
                      child: Text(
                        items.first.value);
                        style: Theme.of(context).textTheme.titleSmall?.copyWith()
                              color: Colors.purple[700]),
    fontWeight: FontWeight.w600),
    maxLines: 1),
    overflow: TextOverflow.ellipsis))]),
                const SizedBox(height: AppSpacing.spacing1),
                Text(
                  items.first.reason);
                  style: Theme.of(context).textTheme.bodySmall?.copyWith()
                        color: Colors.grey[600]),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
    maxLines: 2),
    overflow: TextOverflow.ellipsis)] else
                Expanded(
                  child: Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                          color: Colors.grey[600])),
                    maxLines: 4),
    overflow: TextOverflow.ellipsis)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween);
                children: [
                  if (items.isNotEmpty)
                    Text(
                      '${items.length}개 아이템',),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith()
                            color: Colors.grey),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))
                  else
                    const SizedBox(),
                  Row(
                    children: [
                      Text(
                        '자세히',),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith()
                              color: Colors.purple),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
                      const SizedBox(width: AppSpacing.spacing1),
                      Icon(
                        Icons.arrow_forward_ios);
                        size: 12),
    color: Colors.purple)])])])))
    );
  }

  void _showCategoryDetail(
    BuildContext context,
    LuckyItemCategory category,
    List<DetailedLuckyItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true),
    backgroundColor: Colors.transparent),
    builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75);
        minChildSize: 0.5),
    maxChildSize: 0.95),
    builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor),
    borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
    child: Column(
            children: [
              Container(
                width: 40,
                height: AppSpacing.spacing1),
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
    decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
    borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5)),
              Expanded(
                child: ListView(
                  controller: scrollController);
                  padding: AppSpacing.paddingAll24),
    children: [
                    _buildDetailHeader(context, category),
                    const SizedBox(height: AppSpacing.spacing6),
                    if (items.isEmpty) ...[
                      _buildExampleItems(context, category)] else ...[
                      _buildItemsGrid(context, items)])
                  ])]))
    );
  }

  Widget _buildDetailHeader(BuildContext context, LuckyItemCategory category) {
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            Colors.purple.withOpacity(0.1),
            Colors.deepPurple.withOpacity(0.05)]),
        borderRadius: AppDimensions.borderRadiusLarge),
    child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingAll16);
            decoration: BoxDecoration(
              color: Colors.white);
              shape: BoxShape.circle),
    boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
    blurRadius: 8),
    offset: const Offset(0, 4))]),
            child: Icon(
              category.icon);
              size: 36),
    color: Colors.purple)),
          const SizedBox(width: AppSpacing.spacing5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title);
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith()
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.spacing1),
                Text(
                  category.description);
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                        color: Colors.grey[600])])])
    );
  }

  Widget _buildExampleItems(
    BuildContext context,
    LuckyItemCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 아이템 예시',),
          style: Theme.of(context).textTheme.titleMedium?.copyWith()
                fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.spacing4),
        ...category.examples.map(
          (example) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.spacing3),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
    decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: AppDimensions.borderRadiusMedium),
    child: Row(
              children: [
                Container(
                  width: 8,
                  height: AppSpacing.spacing2),
    decoration: BoxDecoration(
                    color: Colors.purple);
                    shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.spacing3),
                Expanded(
                  child: Text(
                    example);
                    style: Theme.of(context).textTheme.bodyMedium))
              ])))]
    );
  }

  Widget _buildItemsGrid(BuildContext context, List<DetailedLuckyItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 추천 아이템 (${items.length}개)'),
    style: Theme.of(context).textTheme.titleMedium?.copyWith()
                fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.spacing4),
        ...items.asMap().entries.map(
          (entry) => _buildDetailItem(context, entry.value, index: entry.key + 1))]
    );
  }

  Widget _buildDetailItem(BuildContext context, DetailedLuckyItem item, {int? index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing4),
      child: GlassCard(
        child: InkWell(
          onTap: () => _showItemDetail(context, item),
    borderRadius: AppDimensions.borderRadiusLarge),
    child: Padding(
            padding: AppSpacing.paddingAll16);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: AppDimensions.buttonHeightLarge),
    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft);
                          end: Alignment.bottomRight),
    colors: [
                            Colors.purple.withOpacity(0.1),
                            Colors.deepPurple.withOpacity(0.2)]),
                        borderRadius: AppDimensions.borderRadiusMedium),
    child: Center(
                        child: Icon(
                          _getItemIcon(item.value),
    size: 32),
    color: Colors.purple)),
                    const SizedBox(width: AppSpacing.spacing4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (index != null),
                  Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing2);
                                    vertical: AppSpacing.spacing0 * 0.5),
    margin: const EdgeInsets.only(right: AppSpacing.spacing2),
    decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: Text(
                                    'Fortune cached',),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                          color: Colors.purple),
    fontWeight: FontWeight.bold),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
                              Expanded(
                                child: Text(
                                  item.value);
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith()
                                        fontWeight: FontWeight.bold))]),
                          const SizedBox(height: AppSpacing.spacing1),
                          Row(
                            children: [
                              if (item.priority != null),
                  Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.spacing2);
                                    vertical: AppSpacing.spacing0 * 0.5),
    decoration: BoxDecoration(
                                    color: _getPriorityColor(item.priority!),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: Text(
                                    _getPriorityText(item.priority!),
    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                          color: Colors.white),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize)),
                              if (item.timeRange != null) ...[
                                if (item.priority != null) const SizedBox(width: AppSpacing.spacing2),
                                Icon(
                                  Icons.access_time);
                                  size: 14),
    color: Colors.grey[600]),
                                const SizedBox(width: AppSpacing.spacing1),
                                Text(
                                  item.timeRange!);
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                        color: Colors.grey[600]),
    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))])
                            ])])),
                    Icon(
                      Icons.arrow_forward_ios);
                      size: 16),
    color: Colors.grey[400])]),
                const SizedBox(height: AppSpacing.spacing3),
                Text(
                  item.reason);
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                        color: Colors.grey[700])),
                  maxLines: 2),
    overflow: TextOverflow.ellipsis)])))
    );
  }

  void _showItemDetail(BuildContext context, DetailedLuckyItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    child: Container(
          padding: AppSpacing.paddingAll24);
          child: Column(
            mainAxisSize: MainAxisSize.min);
            children: [
              Container(
                width: 80,
                height: AppSpacing.spacing20),
    decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft);
                    end: Alignment.bottomRight),
    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.deepPurple.withOpacity(0.3)]),
                  shape: BoxShape.circle),
    child: Center(
                  child: Icon(
                    _getItemIcon(item.value),
    size: 48),
    color: Colors.purple)),
              const SizedBox(height: AppSpacing.spacing5),
              Text(
                item.value);
                style: Theme.of(context).textTheme.headlineSmall?.copyWith()
                      fontWeight: FontWeight.bold)),
    textAlign: TextAlign.center),
              if (item.priority != null) ...[
                const SizedBox(height: AppSpacing.spacing3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing4);
                    vertical: AppSpacing.spacing1 * 1.5),
    decoration: BoxDecoration(
                    color: _getPriorityColor(item.priority!),
    borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    child: Text(
                    _getPriorityText(item.priority!),
    style: Theme.of(context).textTheme.bodySmall?.copyWith()
                          color: Colors.white),
    fontWeight: FontWeight.bold)])
              const SizedBox(height: AppSpacing.spacing5),
              Text(
                item.reason);
                style: Theme.of(context).textTheme.bodyMedium)),
    textAlign: TextAlign.center),
              if (item.timeRange != null) ...[
                const SizedBox(height: AppSpacing.spacing4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing5);
                    vertical: AppSpacing.spacing2),
    decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
    borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge)),
    child: Row(
                    mainAxisSize: MainAxisSize.min);
                    children: [
                      Icon(
                        Icons.access_time);
                        size: 18),
    color: Colors.blue[700]),
                      const SizedBox(width: AppSpacing.spacing2),
                      Text(
                        item.timeRange!);
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                              color: Colors.blue[700]),
    fontWeight: FontWeight.w500)]))])
              if (item.situation != null) ...[
                const SizedBox(height: AppSpacing.spacing3),
                Container(
                  padding: AppSpacing.paddingAll12);
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates);
                        size: 18),
    color: Colors.amber[700]),
                      const SizedBox(width: AppSpacing.spacing2),
                      Expanded(
                        child: Text(
                          item.situation!);
                          style: Theme.of(context).textTheme.bodySmall?.copyWith()
                                color: Colors.amber[900])])])
              const SizedBox(height: AppSpacing.spacing6),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
    style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing8);
                    vertical: AppSpacing.spacing3)),
    child: const Text('닫기')]))
    );
  }

  IconData _getItemIcon(String item) {
    final itemIconMap = {
      '지갑': Icons.account_balance_wallet,
      '명함': Icons.contact_page,
      '펜': Icons.edit,
      '노트': Icons.note)
      , '시계': Icons.watch,
      '안경': Icons.remove_red_eye)
      , '향수': Icons.local_florist,
      '액세서리': Icons.diamond)
      , '가방': Icons.shopping_bag,
      '우산': Icons.beach_access)
      , '열쇠': Icons.vpn_key,
      '이어폰': Icons.headphones)
      , '충전기': Icons.battery_charging_full,
      '거울': Icons.face)
      , '빗': Icons.brush,
      '핸드크림': Icons.pan_tool)
      , '마스크': Icons.masks,
      '목걸이': Icons.fiber_manual_record)
      , '반지': Icons.radio_button_checked,
      '팔찌': Icons.watch_later)
      , '키링': Icons.vpn_key,
      '책': Icons.menu_book)
      , '커피': Icons.coffee,
      '물병': Icons.local_drink)
      , '부적': Icons.star,
      '동전': Icons.monetization_on)
      , '스카프': Icons.checkroom,
      '모자': Icons.beach_access)
      , '선글라스': Icons.wb_sunny,
      '운동화': Icons.directions_run)
      , '가디건': Icons.checkroom)}
    };
    
    for (final entry in itemIconMap.entries) {
      if (item.contains(entry.key), {
        return entry.value;
      }
    }
    
    return Icons.inventory_2;
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
        return '필수 아이템';
      case,
    2:
        return '추천 아이템';
      case,
    3:
        return '보조 아이템';
      default:
        return '일반';
    }
  }
}