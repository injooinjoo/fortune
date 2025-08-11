import 'package:flutter/material.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class FortuneDisplay extends StatelessWidget {
  final String title;
  final String description;
  final int overallScore;
  final Map<String, dynamic>? luckyItems;
  final String? advice;
  final Map<String, dynamic>? detailedFortune;
  final String? warningMessage;

  const FortuneDisplay({
    Key? key,
    required this.title,
    required this.description,
    required this.overallScore,
    this.luckyItems,
    this.advice,
    this.detailedFortune,
    this.warningMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSpacing.spacing6),
        _buildOverallScore(context),
        if (luckyItems != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          _buildLuckyItems(context)],
        if (detailedFortune != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          _buildDetailedFortune(context)],
        if (advice != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          _buildAdvice(context)],
        if (warningMessage != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          _buildWarning(context)]]);
}

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.spacing2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium)]));
  }

  Widget _buildOverallScore(BuildContext context) {
    final scoreColor = _getScoreColor(overallScore);
    
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      gradient: LinearGradient(
        colors: [
          scoreColor.withOpacity(0.2),
          scoreColor.withOpacity(0.1)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '종합 운세',
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.spacing1),
              Text(
                _getScoreDescription(overallScore),
                style: Theme.of(context).textTheme.bodyMedium)]),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scoreColor,
                width: 3)),
            child: Center(
              child: Text(
                '$overallScore',
                style: Theme.of(context).textTheme.bodyMedium))]);
  }

  Widget _buildLuckyItems(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: Colors.amber,
                size: 24),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                '오늘의 행운 아이템',
                style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: AppSpacing.spacing4),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: luckyItems!.entries.map((entry) {
              return _buildLuckyItemChip(
                entry.key,
                entry.value.toString(),
                context);
            }).toList()]);
  }

  Widget _buildLuckyItemChip(String label, String value, BuildContext context) {
    IconData icon;
    Color color;
    
    switch (label) {
      case '숫자': case 'number':
        icon = Icons.looks_one;
        color = Colors.blue;
        break;
      case '색상':
      case 'color':
        icon = Icons.palette;
        color = Colors.purple;
        break;
      case '방향':
      case 'direction':
        icon = Icons.explore;
        color = Colors.green;
        break;
      case '시간':
      case 'time':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        icon = Icons.star;
        color = Colors.amber;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.spacing1),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodyMedium)]));
  }

  Widget _buildDetailedFortune(BuildContext context) {
    return Column(
      children: detailedFortune!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.spacing3),
          child: GlassContainer(
            padding: AppSpacing.paddingAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(entry.key),
                      color: _getCategoryColor(entry.key),
                      size: 20),
                    const SizedBox(width: AppSpacing.spacing2),
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium)]),
                const SizedBox(height: AppSpacing.spacing2),
                Text(
                  entry.value.toString(),
                  style: Theme.of(context).textTheme.bodyMedium)])));
      }).toList());
  }

  Widget _buildAdvice(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      gradient: LinearGradient(
        colors: [
          Colors.green.withOpacity(0.2),
          Colors.green.withOpacity(0.1)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.green,
                size: 24),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                '조언',
                style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            advice!,
            style: Theme.of(context).textTheme.bodyMedium)]));
  }

  Widget _buildWarning(BuildContext context) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      gradient: LinearGradient(
        colors: [
          Colors.orange.withOpacity(0.2),
          Colors.orange.withOpacity(0.1)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 24),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                '주의사항',
                style: Theme.of(context).textTheme.bodyMedium)]),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            warningMessage!,
            style: Theme.of(context).textTheme.bodyMedium)]));
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
}

  String _getScoreDescription(int score) {
    if (score >= 80) return '매우 좋음';
    if (score >= 60) return '좋음';
    if (score >= 40) return '보통';
    return '주의 필요';
}

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '재물운': case '금전운':
        return Icons.attach_money;
      case '연애운':
      case '애정운':
        return Icons.favorite;
      case '건강운':
        return Icons.favorite_border;
      case '직업운':
      case '사업운':
        return Icons.work;
      case '학업운':
        return Icons.school;
      default:
        return Icons.auto_awesome;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '재물운': case '금전운':
        return Colors.amber;
      case '연애운':
      case '애정운':
        return Colors.pink;
      case '건강운':
        return Colors.green;
      case '직업운':
      case '사업운':
        return Colors.blue;
      case '학업운':
        return Colors.purple;
      default:
        return Colors.cyan;
    }
  }
}