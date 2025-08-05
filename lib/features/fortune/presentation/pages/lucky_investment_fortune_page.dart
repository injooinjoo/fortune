import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';

class LuckyInvestmentFortunePage extends ConsumerWidget {
  const LuckyInvestmentFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '투자 운세',
      fortuneType: 'lucky-investment',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
      inputBuilder: (context, onSubmit) => _InvestmentInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _InvestmentFortuneResult(result: result);
  }
}

class _InvestmentInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _InvestmentInputForm({required this.onSubmit});

  @override
  State<_InvestmentInputForm> createState() => _InvestmentInputFormState();
}

class _InvestmentInputFormState extends State<_InvestmentInputForm> {
  String _investmentType = 'stocks';
  String _riskTolerance = 'moderate';
  String _investmentGoal = 'growth';
  String _timeHorizon = 'medium';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 투자 운세를 확인하고\n현명한 투자 결정을 내리세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5)),
        const SizedBox(height: 24),
        
        // Investment Type
        Text(
          '투자 종류',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInvestmentType(theme),
        const SizedBox(height: 24),

        // Risk Tolerance
        Text(
          '위험 감수 성향',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildRiskTolerance(theme),
        const SizedBox(height: 24),

        // Investment Goal
        Text(
          '투자 목표',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInvestmentGoal(theme),
        const SizedBox(height: 24),

        // Time Horizon
        Text(
          '투자 기간',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTimeHorizon(theme),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit({
                'investmentType': _investmentType,
                'riskTolerance': _riskTolerance,
                'investmentGoal': _investmentGoal,
                'timeHorizon': null});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
              elevation: 0),
            child: const Text(
              '투자 운세 보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold))))]
    );
  }

  Widget _buildInvestmentType(ThemeData theme) {
    final types = [
      {'id', 'stocks': 'name', '주식': 'icon'},
      {'id', 'crypto': 'name', '암호화폐': 'icon'},
      {'id', 'real_estate', 'name', '부동산', 'icon'},
      {'id', 'bonds', 'name', '채권', 'icon'}];

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
        final isSelected = _investmentType == type['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _investmentType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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

  Widget _buildRiskTolerance(ThemeData theme) {
    final levels = [
      {'id', 'conservative': 'name', '안정형'},
      {'id', 'moderate': 'name', '중립형'},
      {'id', 'aggressive', 'name', '공격형'},
      {'id', 'very_aggressive', 'name', '초공격형'}];

    return Row(
      children: levels.map((level) {
        final isSelected = _riskTolerance == level['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _riskTolerance = level['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: level != levels.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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

  Widget _buildInvestmentGoal(ThemeData theme) {
    final goals = [
      {'id', 'growth': 'name', '성장': 'icon'},
      {'id', 'income': 'name', '수익': 'icon'},
      {'id', 'preservation', 'name', '보존', 'icon'},
      {'id', 'speculation', 'name', '투기', 'icon'}];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ,
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final isSelected = _investmentGoal == goal['id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _investmentGoal = goal['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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
                  goal['icon'],
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  goal['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])));
      }
    );
  }

  Widget _buildTimeHorizon(ThemeData theme) {
    final horizons = [
      {'id', 'short': 'name', '단기\n(1년 이내)'},
      {'id', 'medium': 'name', '중기\n(1-5년)'},
      {'id', 'long': 'name', '장기\n(5-10년)'},
      {'id', 'very_long': 'name', '초장기\n(10년+)'}];

    return Row(
      children: horizons.map((horizon) {
        final isSelected = _timeHorizon == horizon['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _timeHorizon = horizon['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: horizon != horizons.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ,
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  horizon['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12),
                  textAlign: TextAlign.center)))));
      }).toList();
  }
}

class _InvestmentFortuneResult extends StatelessWidget {
  final FortuneResult result;

  const _InvestmentFortuneResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Fortune Card
        ShimmerGlass(
          shimmerColor: const Color(0xFFF59E0B),
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
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 투자 운세',
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

        // Market Timing
        if (result.details?['marketTiming'] != null) ...[
          _buildSectionCard(
            context,
            title: '마켓 타이밍',
            icon: Icons.access_time,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)]),
            content: result.details!['marketTiming']),
          const SizedBox(height: 16)],

        // Sector Recommendation
        if (result.details?['sectors'] != null) ...[
          _buildSectionCard(
            context,
            title: '추천 섹터',
            icon: Icons.category,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
            content: result.details!['sectors']),
          const SizedBox(height: 16)],

        // Risk Management
        if (result.details?['riskManagement'] != null) ...[
          _buildSectionCard(
            context,
            title: '리스크 관리',
            icon: Icons.warning_amber,
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            content: result.details!['riskManagement']),
          const SizedBox(height: 16)],

        // Investment Strategy
        if (result.details?['strategy'] != null) ...[
          _buildSectionCard(
            context,
            title: '투자 전략',
            icon: Icons.lightbulb_outline,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6366F1)]),
            content: result.details!['strategy'])]]
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