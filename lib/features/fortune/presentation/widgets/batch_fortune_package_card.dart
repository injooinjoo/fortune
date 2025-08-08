import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/fortune_batch_service.dart';
import '../providers/batch_fortune_provider.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

/// 배치 운세 패키지 카드 위젯
class BatchFortunePackageCard extends ConsumerWidget {
  final BatchPackageType packageType;
  final VoidCallback? onTap;

  const BatchFortunePackageCard({
    Key? key,
    required this.packageType,
    this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchState = ref.watch(batchFortuneProvider);
    final isLoading = batchState.isLoading && batchState.currentPackage == packageType;
    final isGenerated = batchState.currentPackage == packageType && batchState.results != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge,
        side: isGenerated
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none),
      child: InkWell(
        onTap: isLoading ? null : (onTap ?? () => _generatePackage(context, ref)),
        borderRadius: AppDimensions.borderRadiusLarge,
        child: Padding(
          padding: AppSpacing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getPackageIcon(packageType),
                  const SizedBox(width: AppSpacing.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageType.description,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith()
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.spacing1),
                        Text(
                          '${_getFortuneCount(packageType)}개 운세 묶음',),
                          style: Theme.of(context).textTheme.bodySmall)])),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  else if (isGenerated) Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing4),
              _buildTokenInfo(context, ref),
              if (isGenerated) ...[
                const SizedBox(height: AppSpacing.spacing3),
                _buildGeneratedInfo(context, ref)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfo(BuildContext context, WidgetRef ref) {
    final savings = ref.read(fortuneBatchServiceProvider).calculateTokenSavings(packageType);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.toll,
                size: 16,
                color: Theme.of(context).primaryColor),
              const SizedBox(width: AppSpacing.spacing1),
              Text(
                '${packageType.tokenCost} 토큰',),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold))]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: AppDimensions.borderRadiusMedium),
            child: Text(
              '${savings.toStringAsFixed(0)}% 절약',),
              style: Theme.of(context).textTheme.bodyMedium))));)
  }

  Widget _buildGeneratedInfo(BuildContext context, WidgetRef ref) {
    final batchState = ref.watch(batchFortuneProvider);
    final cachedCount = batchState.cachedCount;
    final generatedCount = batchState.generatedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        const SizedBox(height: AppSpacing.spacing2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '생성 완료',),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold)),
            Text(
              '캐시: $cachedCount개, 신규: $generatedCount개',),
              style: Theme.of(context).textTheme.bodySmall)])),
    );
}

  void _generatePackage(BuildContext context, WidgetRef ref) {
    ref.read(batchFortuneProvider.notifier).generatePackageFortunes(packageType);
}

  Icon _getPackageIcon(BatchPackageType type) {
    switch (type) {
      case BatchPackageType.onboarding:
        return const Icon(Icons.rocket_launch, color: Colors.blue);
      case BatchPackageType.dailyRefresh:
        return const Icon(Icons.today, color: Colors.orange);
      case BatchPackageType.loveSingle:
      case BatchPackageType.loveCouple:
        return const Icon(Icons.favorite, color: Colors.pink);
      case BatchPackageType.career:
        return const Icon(Icons.work, color: Colors.green);
      case BatchPackageType.luckyItems:
        return const Icon(Icons.star, color: Colors.amber);
      case BatchPackageType.premiumComplete:
        return const Icon(Icons.diamond, color: Colors.purple);
}
  }

  int _getFortuneCount(BatchPackageType type) {
    switch (type) {
      case BatchPackageType.onboarding:
        return 5;
      case BatchPackageType.dailyRefresh:
        return 4;
      case BatchPackageType.loveSingle:
      case BatchPackageType.loveCouple:
        return 4;
      case BatchPackageType.career:
        return 4;
      case BatchPackageType.luckyItems:
        return 5;
      case BatchPackageType.premiumComplete:
        return 15;
    }
  }
}

/// 배치 운세 결과 리스트
class BatchFortuneResultsList extends ConsumerWidget {
  const BatchFortuneResultsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchState = ref.watch(batchFortuneProvider);
    final results = batchState.results;

    if (results == null || results.isEmpty) {
      return const Center(
        child: Text('생성된 운세가 없습니다'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing1),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: result.fromCache
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              child: Icon(
                _getFortuneIcon(result.type),
                color: Colors.white,
                size: 20)),
            title: Text(
              _getFortuneTitle(result.type),
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              result.fortune.summary ?? result.fortune.content.substring(0, 50),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
            trailing: result.fromCache
                ? const Chip(
                    label: Text('캐시'),
                    backgroundColor: Colors.grey)
                : const Chip(
                    label: Text('신규'),
                    backgroundColor: Colors.green),
            onTap: () {
              // 상세 운세 보기
              _showFortuneDetail(context, result);
            }),
        );
      }),
    );
}

  void _showFortuneDetail(BuildContext context, BatchFortuneResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              width: 40,
              height: AppSpacing.spacing1,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5))),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingAll20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getFortuneIcon(result.type),
                          size: 32,
                          color: Theme.of(context).primaryColor),
                        const SizedBox(width: AppSpacing.spacing3),
                        Text(
                          _getFortuneTitle(result.type),
                          style: Theme.of(context).textTheme.headlineSmall)])),
                    const SizedBox(height: AppSpacing.spacing5),
                    if (result.fortune.overallScore != null) ...[
                      Row(
                        children: [
                          const Text('점수: '),
                          Text(
                            '${result.fortune.overallScore}점',),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith()
                              color: Theme.of(context).primaryColor))]),
                      const SizedBox(height: AppSpacing.spacing4)],
                    if (result.fortune.summary != null) ...[
                      Container(
                        padding: AppSpacing.paddingAll12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: AppDimensions.borderRadiusSmall),
                        child: Text(
                          result.fortune.summary!,
                          style: Theme.of(context).textTheme.bodyMedium))),
                      const SizedBox(height: AppSpacing.spacing4)],
                    Text(
                      result.fortune.content,
                      style: Theme.of(context).textTheme.bodyMedium)),
                    if (result.fortune.additionalInfo?['advice'] != null) ...[
                      const SizedBox(height: AppSpacing.spacing5),
                      const Text(
                        '💡 조언',),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.spacing2),
                      Text(
                        result.fortune.additionalInfo!['advice'],
                        style: Theme.of(context).textTheme.bodyMedium)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

  IconData _getFortuneIcon(String type) {
    final iconMap = {
      'daily': Icons.today,
      'saju': Icons.account_tree,
      'love': Icons.favorite,
      'career': Icons.work,
      'wealth': Icons.attach_money,
      'health': Icons.favorite_border,
      'personality': Icons.person,
      'talent': Icons.star,
      'yearly': Icons.calendar_month,
      'biorhythm': Icons.show_chart,
      'lucky-color': Icons.palette};
    return iconMap[type] ?? Icons.auto_awesome;
}

  String _getFortuneTitle(String type) {
    final titleMap = {
      'daily': '오늘의 운세',
      'saju': '사주팔자',
      'love': '연애운',
      'career': '직업운',
      'wealth': '재물운',
      'health': '건강운',
      'personality': '성격운세',
      'talent': '재능운세',
      'yearly': '올해운세',
      'biorhythm': '바이오리듬',
      'lucky-color': '행운의 색',
      'hourly': '시간별 운세',
      'tomorrow': '내일의 운세',
      'weekly': '주간 운세',
      'monthly': '월간 운세',
      'destiny': '운명',
      'blind-date': '소개팅운',
      'celebrity-match': '연예인 매칭',
      'couple-match': '커플 매칭',
      'chemistry': '케미스트리',
      'marriage': '결혼운',
      'business': '사업운',
      'lucky-number': '행운의 숫자',
      'lucky-items': '행운의 아이템',
      'lucky-food': '행운의 음식',
      'lucky-outfit': '행운의 의상',
      'traditional-saju': '전통사주',
      'tojeong': '토정비결',
      'past-life': '전생'};
    return titleMap[type] ?? type;
}
}