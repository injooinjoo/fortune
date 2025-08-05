import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class LuckyFishingFortunePage extends ConsumerWidget {
  const LuckyFishingFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '낚시 운세',
      fortuneType: 'lucky-fishing',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
      inputBuilder: (context, onSubmit) => _FishingInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _FishingFortuneResult(result: result);
  }
}

class _FishingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _FishingInputForm({required this.onSubmit});

  @override
  State<_FishingInputForm> createState() => _FishingInputFormState();
}

class _FishingInputFormState extends State<_FishingInputForm> {
  String _fishingType = 'freshwater';
  String _experience = 'beginner';
  String _targetFish = 'any';
  String _fishingTime = 'morning';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 낚시 운세를 확인하고\n대어를 낚아보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5)),
        const SizedBox(height: 24),
        
        // Fishing Type
        Text(
          '낚시 종류',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFishingType(theme),
        const SizedBox(height: 24),

        // Experience Level
        Text(
          '경험 수준',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildExperience(theme),
        const SizedBox(height: 24),

        // Target Fish
        Text(
          '목표 어종',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTargetFish(theme),
        const SizedBox(height: 24),

        // Fishing Time
        Text(
          '낚시 시간대',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildFishingTime(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'fishingType': _fishingType,
                'experience': _experience,
                'targetFish': _targetFish,
                'fishingTime': null});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              elevation: 0),
            child: const Text(
              '낚시 운세 보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold))))]
    );
  }

  Widget _buildFishingType(ThemeData theme) {
    final types = [
      {'id', 'freshwater': 'name', '민물낚시': 'icon'},
      {'id', 'sea': 'name', '바다낚시': 'icon'},
      {'id', 'fly', 'name', '플라이낚시', 'icon'},
      {'id', 'ice', 'name', '얼음낚시', 'icon'}];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ,
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _fishingType == type['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _fishingType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ,
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2),
              borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'],
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  type['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
      }
    );
  }

  Widget _buildExperience(ThemeData theme) {
    final levels = [
      {'id', 'beginner': 'name', '초보'},
      {'id', 'intermediate': 'name', '중급'},
      {'id', 'advanced', 'name', '고급'},
      {'id', 'expert', 'name', '전문가'}];

    return Row(
      children: levels.map((level) {
        final isSelected = _experience == level['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _experience = level['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: level != levels.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      ,
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  level['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))))));
      }).toList();
  }

  Widget _buildTargetFish(ThemeData theme) {
    final targets = [
      {'id', 'any': 'name', '상관없음'},
      {'id', 'bass': 'name', '배스'},
      {'id', 'carp', 'name', '잉어'},
      {'id', 'trout', 'name', '송어'}];

    return Row(
      children: targets.map((target) {
        final isSelected = _targetFish == target['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _targetFish = target['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: target != targets.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      ,
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  target['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))))));
      }).toList();
  }

  Widget _buildFishingTime(ThemeData theme) {
    final times = [
      {'id', 'dawn': 'name', '새벽': 'icon'},
      {'id', 'morning': 'name', '아침': 'icon'},
      {'id', 'afternoon', 'name', '오후', 'icon'},
      {'id', 'evening', 'name', '저녁', 'icon'}];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ,
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        final isSelected = _fishingTime == time['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _fishingTime = time['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ,
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2),
              borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  time['icon'],
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  time['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
      }
    );
  }
}

class _FishingFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _FishingFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF0EA5E9),
          borderRadius: BorderRadius.circular(20),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(
                        Icons.sailing,
                        color: Colors.white,
                        size: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 낚시 운세',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                          Text(
                            result.date ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]))]),
                const SizedBox(height: 20),
                Text(
                  result.mainFortune ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6))]))),
        const SizedBox(height: 16),

        // Best Fishing Spot
        if (result.details?['bestSpot'] != null) ...[
          _buildSectionCard(
            context,
            title: '최고의 낚시 포인트',
            icon: Icons.location_on,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
            content: result.details!['bestSpot']),
          const SizedBox(height: 16)],

        // Recommended Bait
        if (result.details?['bait'] != null) ...[
          _buildSectionCard(
            context,
            title: '추천 미끼',
            icon: Icons.set_meal,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)]),
            content: result.details!['bait']),
          const SizedBox(height: 16)],

        // Weather & Conditions
        if (result.details?['conditions'] != null) ...[
          _buildSectionCard(
            context,
            title: '날씨 및 조건',
            icon: Icons.cloud,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
            content: result.details!['conditions']),
          const SizedBox(height: 16)],

        // Fishing Tips
        if (result.details?['tips'] != null) ...[
          _buildSectionCard(
            context,
            title: '낚시 팁',
            icon: Icons.tips_and_updates,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
            content: result.details!['tips'])]]
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required String content}) {
    final theme = Theme.of(context);

    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20)),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5))],
      );
  }
}