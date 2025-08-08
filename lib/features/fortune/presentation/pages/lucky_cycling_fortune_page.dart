import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class LuckyCyclingFortunePage extends ConsumerWidget {
  const LuckyCyclingFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '자전거 운세',
      fortuneType: 'lucky-cycling',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
      inputBuilder: (context, onSubmit) => _CyclingInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) =>
          _CyclingFortuneResult(result: result, onShare: onShare));
  }
}

class _CyclingInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _CyclingInputForm({required this.onSubmit});

  @override
  State<_CyclingInputForm> createState() => _CyclingInputFormState();
}

class _CyclingInputFormState extends State<_CyclingInputForm> {
  String _bikeType = 'road';
  String _ridingStyle = 'leisure';
  String _distance = 'short';
  String _terrain = 'flat';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 자전거 운세를 확인하고\n안전하고 즐거운 라이딩을 시작하세요!',),
          style: theme.textTheme.bodyLarge?.copyWith()
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5),
        const SizedBox(height: 24),
        
        // Bike Type
        Text(
          '자전거 종류',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildBikeTypeGrid(theme),
        const SizedBox(height: 24),

        // Riding Style
        Text(
          '라이딩 스타일',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildRidingStyle(theme),
        const SizedBox(height: 24),

        // Distance
        Text(
          '예상 거리',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDistance(theme),
        const SizedBox(height: 24),

        // Terrain
        Text(
          '주행 환경',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTerrain(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'bikeType': _bikeType,
                'ridingStyle': _ridingStyle,
                'distance': _distance,
                'terrain': null});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              elevation: 0),
            child: const Text(
              '자전거 운세 보기',),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold))))]
    );
  }

  Widget _buildBikeTypeGrid(ThemeData theme) {
    final types = [
      {'id': 'road', 'name': '로드바이크', 'icon': Icons.directions_bike},
      {'id': 'mtb', 'name': 'MTB', 'icon': Icons.terrain},
      {'id': 'hybrid', 'name': '하이브리드', 'icon': Icons.pedal_bike},
      {'id': 'electric', 'name': '전기자전거', 'icon': Icons.electric_bike}];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _bikeType == type['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _bikeType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFF0D9488)])
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2),
              borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
      });
  }

  Widget _buildRidingStyle(ThemeData theme) {
    final styles = [
      {'id': 'leisure', 'name': '여유롭게'},
      {'id': 'training', 'name': '트레이닝'},
      {'id': 'commute', 'name': '출퇴근'},
      {'id': 'touring', 'name': '투어링'}];

    return Row(
      children: styles.map((style) {
        final isSelected = _ridingStyle == style['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _ridingStyle = style['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: style != styles.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)])
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  style['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))))));
      }).toList());
  }

  Widget _buildDistance(ThemeData theme) {
    final distances = [
      {'id': 'short', 'name': '~20km'},
      {'id': 'medium', 'name': '20-50km'},
      {'id': 'long', 'name': '50-100km'},
      {'id': 'century', 'name': '100km+'}];

    return Row(
      children: distances.map((distance) {
        final isSelected = _distance == distance['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _distance = distance['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: distance != distances.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)])
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  distance['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))))));
      }).toList());
  }

  Widget _buildTerrain(ThemeData theme) {
    final terrains = [
      {'id': 'flat', 'name': '평지', 'icon': Icons.landscape},
      {'id': 'hilly', 'name': '언덕', 'icon': Icons.filter_hdr},
      {'id': 'mountain', 'name': '산악', 'icon': Icons.terrain},
      {'id': 'mixed', 'name': '혼합', 'icon': Icons.layers}];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12),
      itemCount: terrains.length,
      itemBuilder: (context, index) {
        final terrain = terrains[index];
        final isSelected = _terrain == terrain['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _terrain = terrain['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF0D9488)])
                    : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2),
              borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  terrain['icon'] as IconData,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  terrain['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
      });
  }
}

class _CyclingFortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _CyclingFortuneResult({required this.result, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFF14B8A6),
          borderRadius: BorderRadius.circular(20))),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(20))),
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
                          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(
                        Icons.directions_bike,
                        color: Colors.white,
                        size: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 자전거 운세',),
                            style: theme.textTheme.titleLarge?.copyWith()
                              fontWeight: FontWeight.bold)),
                          Text(
                            result.date ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith()
                              color: theme.colorScheme.onSurface.withOpacity(0.6)))]))]),
                const SizedBox(height: 20),
                Text(
                  result.mainFortune ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith()
                    height: 1.6)]))),
        const SizedBox(height: 16),

        // Route Recommendation
        if (result.details?['route'] != null) ...[
          _buildSectionCard(
            context,
            title: '추천 라이딩 코스',
            icon: Icons.route,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
            content: result.details!['route']),
          const SizedBox(height: 16)],

        // Weather & Conditions
        if (result.details?['conditions'] != null) ...[
          _buildSectionCard(
            context,
            title: '라이딩 컨디션',
            icon: Icons.wb_sunny,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
            content: result.details!['conditions']),
          const SizedBox(height: 16)],

        // Safety Tips
        if (result.details?['safety'] != null) ...[
          _buildSectionCard(
            context,
            title: '안전 라이딩 팁',
            icon: Icons.security,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)]),
            content: result.details!['safety']),
          const SizedBox(height: 16)],

        // Lucky Gear
        if (result.details?['gear'] != null) ...[
          _buildSectionCard(
            context,
            title: '오늘의 행운 장비',
            icon: Icons.settings,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
            content: result.details!['gear'])]]
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
      borderRadius: BorderRadius.circular(16))),
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
                style: theme.textTheme.titleMedium?.copyWith()
                  fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith()
              height: 1.5)]));
  }
}