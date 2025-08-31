import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/base_card.dart';
import 'dart:math' as math;

class TraditionalFortuneResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> fortuneData;
  
  const TraditionalFortuneResultPage({
    super.key,
    required this.fortuneData,
  });

  @override
  ConsumerState<TraditionalFortuneResultPage> createState() => _TraditionalFortuneResultPageState();
}

class _TraditionalFortuneResultPageState extends ConsumerState<TraditionalFortuneResultPage> {
  final Map<String, bool> _expandedSections = {};
  
  @override
  void initState() {
    super.initState();
    // 기본적으로 일부 섹션은 펼쳐진 상태로
    _expandedSections['coreReading'] = true;
    _expandedSections['todayTheme'] = true;
}

  @override
  Widget build(BuildContext context) {
    final fortune = widget.fortuneData['fortune'] ?? widget.fortuneData;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEF4444).withOpacity(0.1),
              TossDesignSystem.white])),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft),
                  end: Alignment.bottomRight),
                  colors: [
                        Color(0xFFEF4444),
                        Color(0xFFEC4899),
                  child: Stack(
                    children: [
                      // Traditional pattern overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TraditionalPatternPainter(),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded),
                  size: 60),
                  color: Colors.white).animate()
                  .scale(delay: 300.ms, duration: 600.ms)
                              .fade(),
                            const SizedBox(height: 16),
                            Text(
                              '전통운세 종합',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                  color: Colors.white),.animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0)),
                title: const Text('전통운세 종합'),
                centerTitle: true),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  if (fortune['greeting'] != null) _buildGreetingCard(fortune['greeting'])
                        .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Today's Theme
                  if (fortune['todayTheme'] != null) _buildTodayThemeCard(fortune['todayTheme'])
                        .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Core Reading
                  if (fortune['coreReading'] != null) _buildCoreReadingCard(fortune['coreReading'])
                        .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Life Aspects
                  if (fortune['lifeAspects'] != null) _buildLifeAspectsCard(fortune['lifeAspects'])
                        .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Wisdom of Ancients
                  if (fortune['wisdomOfAncients'] != null) _buildWisdomCard(fortune['wisdomOfAncients'])
                        .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Traditional Remedies
                  if (fortune['traditionalRemedies'] != null) _buildRemediesCard(fortune['traditionalRemedies'])
                        .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Weekly Outlook
                  if (fortune['weeklyOutlook'] != null) _buildWeeklyOutlookCard(fortune['weeklyOutlook'])
                        .animate()
                  .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Closing Message
                  if (fortune['closingMessage'] != null) _buildClosingMessageCard(fortune['closingMessage'])
                        .animate()
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32)),;
}

  Widget _buildGreetingCard(String greeting) {
    return BaseCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.waving_hand_rounded),
                  size: 32),
                  color: Color(0xFFEF4444),
            const SizedBox(height: 12),
            Text(
              greeting,
              style: TextStyle(
                fontSize: 16,
                height: 1.6),
                  color: TossDesignSystem.gray900),
              textAlign: TextAlign.center));
}

  Widget _buildTodayThemeCard(Map<String, dynamic> theme) {
    return BaseCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
                  colors: [
          _getElementColor(theme['element'] ?? '화': null,
          _getElementColor(theme['element'] ?? '화'),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getElementColor(theme['element'] ?? '화'),
                borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.today_rounded),
                  color: _getElementColor(theme['element'] ?? '화'),
                size: 24
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 주제'),
                  style: TextStyle(
                      fontSize: 14),
                  color: TossDesignSystem.gray600),
                  Text(
                    theme['title'] ?? ''$1',
                  style: TextStyle(
                      fontSize: 18,
    fontWeight: FontWeight.bold),
                  color: _getElementColor(theme['element'] ?? '화')),
        initiallyExpanded: _expandedSections['todayTheme'],
    onExpansionChanged: (expanded) {
          setState(() {
            _expandedSections['todayTheme'] = expanded;
});
},
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme['description'] ?? ''$1',
                  style: TextStyle(
                    fontSize: 15,
    height: 1.6),
                  color: TossDesignSystem.gray900),
                if (theme['hexagram'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TossDesignSystem.gray200),
                    child: Row(
                      children: [
                        Text(
                          theme['hexagram']['symbol'] ?? '☰'),
                  style: TextStyle(
                            fontSize: 32),
                  color: _getElementColor(theme['element'] ?? '화')),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme['hexagram']['name'] ?? ''$1',
                  style: TextStyle(
                                  fontSize: 16,
    fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900),
                              const SizedBox(height: 4),
                              Text(
                                theme['hexagram']['meaning'] ?? ''$1',
                  style: TextStyle(
                                  fontSize: 14,
    color: TossDesignSystem.gray600)));
}

  Widget _buildCoreReadingCard(Map<String, dynamic> reading) {
    return BaseCard(
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFEF4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.insights_rounded),
                  color: Color(0xFFEF4444),
                size: 24),
            const SizedBox(width: 12),
            Text(
              '핵심 운세 분석',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        initiallyExpanded: _expandedSections['coreReading'],
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedSections['coreReading'] = expanded;
});
},
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                // Saju Analysis
                if (reading['saju'] != null) ...[
                  _buildSajuSection(reading['saju'],
                  const SizedBox(height: 20),
                
                // Tojeong Analysis
                if (reading['tojeong'] != null) ...[
                  _buildTojeongSection(reading['tojeong'],
                  const SizedBox(height: 20),
                
                // Synthesis
                if (reading['synthesis'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  colors: [
                          Color(0xFFEF4444).withOpacity(0.1),
                          Color(0xFFEC4899).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                        Row(
                          children: [
                            Icon(
                              Icons.merge_rounded),
                  size: 20),
                  color: Color(0xFFEF4444),
                            const SizedBox(width: 8),
                            Text(
                              '종합 해석',
                              style: TextStyle(
                                fontSize: 16),
                  fontWeight: FontWeight.bold),
                  color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          reading['synthesis'],
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6),
                  color: TossDesignSystem.gray900)));
}

  Widget _buildSajuSection(Map<String, dynamic> saju) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
        Row(
          children: [
            Icon(
              Icons.account_tree_rounded),
                  size: 20),
                  color: Color(0xFFEF4444),
            const SizedBox(width: 8),
            Text(
              '사주 분석',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        const SizedBox(height: 12),
        
        // Four Pillars
        Row(
          children: [
            Expanded(child: _buildPillarCard('년주', saju['yearPillar'],
            const SizedBox(width: 8,
            Expanded(child: _buildPillarCard('월주', saju['monthPillar'],
            const SizedBox(width: 8,
            Expanded(child: _buildPillarCard('일주', saju['dayPillar'],
            const SizedBox(width: 8,
            Expanded(child: _buildPillarCard('시주', saju['hourPillar']),
        
        // Element Balance
        if (saju['balance'] != null) ...[
          const SizedBox(height: 16),
          _buildElementBalance(saju['balance']);
}

  Widget _buildPillarCard(String title, Map<String, dynamic>? pillar) {
    if (pillar == null) return const SizedBox(),
            return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.gray200),
      child: Column(
        children: [
          Text(
            title),
                  style: TextStyle(
              fontSize: 12),
                  color: TossDesignSystem.gray600),
          const SizedBox(height: 4),
          Text(
            '${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}'),
                  style: TextStyle(
              fontSize: 16,
    fontWeight: FontWeight.bold),
                  color: _getElementColor(pillar['element'] ?? ''$1'),;
}

  Widget _buildElementBalance(Map<String, dynamic> balance) {
    final elements = \['['wood': 'fire', 'earth': 'metal': 'water'
  ];}
    final elementNames = ['목': '화', '토': '금', '수'
  ];
    final elementColors = [
      Color(0xFF4CAF50,
      Color(0xFFFF5252,
      Color(0xFFFFC107),
      Color(0xFF9E9E9E),
      Color(0xFF2196F3);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    children: [
        Text(
          '오행 균형도',
          style: TextStyle(
            fontSize: 14),
                  fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900),
        const SizedBox(height: 8),
        ...List.generate(elements.length, (index) {
          final element = elements[index];
          final value = (balance[element] ?? 0).toDouble();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    elementNames[index],
                    style: TextStyle(
                      fontSize: 14),
                  fontWeight: FontWeight.bold),
                  color: elementColors[index])),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 8),
                  backgroundColor: elementColors[index].withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(elementColors[index])),
                const SizedBox(width: 8),
                Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: TossDesignSystem.gray600)),;
});
}

  Widget _buildTojeongSection(Map<String, dynamic> tojeong) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
        Row(
          children: [
            Icon(
              Icons.menu_book_rounded),
                  size: 20),
                  color: Color(0xFF8B5CF6),
            const SizedBox(width: 8),
            Text(
              '토정비결',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
              Row(
                children: [
                  Text(
                    '${tojeong['upperGua'] ?? ''} + ${tojeong['lowerGua'] ?? ''}'),
                  style: TextStyle(
                      fontSize: 16,
    fontWeight: FontWeight.bold),
                  color: Color(0xFF8B5CF6)),
              const SizedBox(height: 8),
              Text(
                tojeong['combinedMeaning'] ?? ''$1',
                  style: TextStyle(
                  fontSize: 14,
    color: TossDesignSystem.gray900),
              if (tojeong['monthlyMessage'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  '이번 달 메시지',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900),
                const SizedBox(height: 4),
                Text(
                  tojeong['monthlyMessage'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5),
                  color: TossDesignSystem.gray900));
}

  Widget _buildLifeAspectsCard(List<dynamic> aspects) {
    return BaseCard(
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.category_rounded),
                  color: Color(0xFF3B82F6),
                size: 24),
            const SizedBox(width: 12),
            Text(
              '분야별 운세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: aspects.map((aspect) {
                final aspectMap = aspect as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildAspectItem(aspectMap),;
}).toList(),;
}

  Widget _buildAspectItem(Map<String, dynamic> aspect) {
    final category = aspect['category'] ?? '';
    final icon = _getCategoryIcon(category);
    final color = _getCategoryColor(category);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
                  colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
                  color: color),
              if (aspect['currentEnergy'] != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEnergyColor(aspect['currentEnergy'],
                    borderRadius: BorderRadius.circular(12),
                  child: Text(
                    aspect['currentEnergy'],
                    style: TextStyle(
                      fontSize: 12),
                  fontWeight: FontWeight.bold),
                  color: _getEnergyColor(aspect['currentEnergy'])),
          const SizedBox(height: 12),
          Text(
            aspect['reading'] ?? '',
            style: TextStyle(
              fontSize: 14,
    height: 1.5),
                  color: TossDesignSystem.gray900),
          if (aspect['advice'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded),
                  size: 16),
                  color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aspect['advice'],
                  style: TextStyle(
                        fontSize: 13),
                  color: TossDesignSystem.gray900)),
          if (aspect['luckyFactors'] != null && (aspect['luckyFactors'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8),
                  children: (aspect['luckyFactors'] as List).map((factor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3)),
                  child: Text(
                    factor.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: color));
}).toList();
}

  Widget _buildWisdomCard(Map<String, dynamic> wisdom) {
    return BaseCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
                  colors: [
          Color(0xFF795548).withOpacity(0.1),
          Color(0xFF795548).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded),
                  size: 24),
                  color: Color(0xFF795548),
                const SizedBox(width: 8),
                Text(
                  '고전의 지혜',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF795548).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  child: Text(
                    wisdom['source'] ?? ''$1',
                  style: TextStyle(
                      fontSize: 12),
                  color: Color(0xFF795548)),
            const SizedBox(height: 16),
            if (wisdom['originalQuote'] != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TossDesignSystem.gray200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisdom['originalQuote'],
                      style: TextStyle(
                        fontSize: 16),
                  fontStyle: FontStyle.italic),
                  color: TossDesignSystem.gray900),
                    const SizedBox(height: 8),
                    Text(
                      wisdom['translation'] ?? ''$1',
                  style: TextStyle(
                        fontSize: 14,
    color: TossDesignSystem.gray600)),
              const SizedBox(height: 12),
            Text(
              wisdom['modernInterpretation'] ?? '',
              style: TextStyle(
                fontSize: 14,
    height: 1.5),
                  color: TossDesignSystem.gray900),
            if (wisdom['personalApplication'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF795548).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                    Icon(
                      Icons.person_outline_rounded),
                  size: 16),
                  color: Color(0xFF795548),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wisdom['personalApplication'],
                  style: TextStyle(
                          fontSize: 13),
                  color: TossDesignSystem.gray900)));
}

  Widget _buildRemediesCard(Map<String, dynamic> remedies) {
    return BaseCard(
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.spa_rounded),
                  color: Color(0xFF10B981),
                size: 24),
            const SizedBox(width: 12),
            Text(
              '전통 처방',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                // Colors
                if (remedies['colors'] != null) ...[
                  _buildRemedySection(
                    '행운의 색상',
                    Icons.palette_rounded,
                    remedies['colors'],
                  const SizedBox(height: 16),
                
                // Directions
                if (remedies['directions'] != null) ...[
                  _buildRemedySection(
                    '길한 방향',
                    Icons.explore_rounded,
                    remedies['directions'],
                  const SizedBox(height: 16),
                
                // Numbers
                if (remedies['numbers'] != null) ...[
                  _buildRemedySection(
                    '행운의 숫자',
                    Icons.numbers_rounded,
                    remedies['numbers'],
                  const SizedBox(height: 16),
                
                // Activities
                if (remedies['activities'] != null) ...[
                  _buildRemedySection(
                    '추천 활동',
                    Icons.directions_run_rounded,
                    {'recommended': remedies['activities'])),;
}

  Widget _buildRemedySection(String title, IconData icon, Map<String, dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Color(0xFF10B981),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        const SizedBox(height: 8),
        ...items.entries.map((entry) {
          final key = entry.key;
          final values = entry.value;
          
          if (values is List && values.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8),
                  children: values.map((value) {
                  final isAvoid = key == 'avoid';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvoid 
                        ? Colors.red.withOpacity(0.1)
                        : Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAvoid 
                          ? Colors.red.withOpacity(0.3)
                          : Color(0xFF10B981).withOpacity(0.3)),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 13),
                  color: isAvoid ? Colors.red : Color(0xFF10B981)),;
}).toList();
}
          return const SizedBox();
}).toList()
    );
}

  Widget _buildWeeklyOutlookCard(Map<String, dynamic> outlook) {
    final days = \['['monday': 'tuesday', 'wednesday': 'thursday', 'friday': 'saturday', 'sunday'
  ];
    final dayNames = ['월': '화', '수': '목', '금': '토', '일'
  ];
    
    return BaseCard(
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8,
              decoration: BoxDecoration(
                color: Color(0xFF06B6D4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.calendar_view_week_rounded),
                  color: Color(0xFF06B6D4),
                size: 24),
            const SizedBox(width: 12),
            Text(
              '주간 운세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
                  color: TossDesignSystem.gray900)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(days.length, (index) {
                final day = days[index];
                final dayName = dayNames[index];
                final fortune = outlook[day] ?? '';
                final isWeekend = index >= 5;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isWeekend 
                      ? Color(0xFF06B6D4).withOpacity(0.05)
                      : TossDesignSystem.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWeekend
                        ? Color(0xFF06B6D4).withOpacity(0.3)
                        : TossDesignSystem.gray200),
                  child: Row(
                    children: [
                      Container(
                        width: 32),
                  height: 32),
                  decoration: BoxDecoration(
                          color: isWeekend
                            ? Color(0xFF06B6D4).withOpacity(0.2)
                            : TossDesignSystem.gray200.withOpacity(0.3),
                          shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 14),
                  fontWeight: FontWeight.bold),
                  color: isWeekend ? Color(0xFF06B6D4) : TossDesignSystem.gray900
                            )),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fortune),
                  style: TextStyle(
                            fontSize: 14),
                  color: TossDesignSystem.gray900));
}));
}

  Widget _buildClosingMessageCard(String message) {
    return BaseCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
                  colors: [
          Color(0xFFEF4444).withOpacity(0.1),
          Color(0xFFEC4899).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.favorite_rounded),
                  size: 32),
                  color: Color(0xFFEF4444),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: TossDesignSystem.gray900),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center));
}

  Color _getElementColor(String element) {
    switch (element) {
      case '목': case 'wood':
        return Color(0xFF4CAF50);
      case '화':
      case 'fire':
        return Color(0xFFFF5252);
      case '토':
      case 'earth':
        return Color(0xFFFFC107);
      case '금':
      case 'metal':
        return Color(0xFF9E9E9E);
      case '수':
      case , 'water': return Color(0xFF2196F3);
      default:
        return Color(0xFFEF4444);}
}
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '재물운': return Icons.attach_money_rounded;
      case '건강운':
        return Icons.health_and_safety_rounded;
      case '인연운':
        return Icons.favorite_rounded;
      case '사업/직업운':
        return Icons.work_rounded;
      case , '학업/성장운': return Icons.school_rounded;
      default:
        return Icons.star_rounded;}
}
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '재물운': return Color(0xFFF59E0B);
      case '건강운':
        return Color(0xFF10B981);
      case '인연운':
        return Color(0xFFEC4899);
      case '사업/직업운':
        return Color(0xFF3B82F6);
      case , '학업/성장운': return Color(0xFF8B5CF6);
      default:
        return Color(0xFFEF4444);}
}
  }

  Color _getEnergyColor(String energy) {
    switch (energy) {
      case '상': return Color(0xFF10B981);
      case '중':
        return Color(0xFFF59E0B);
      case , '하': return Color(0xFFEF4444);
      default:
        return TossDesignSystem.gray600;}
}
  }}

// Traditional pattern painter
class TraditionalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
     
   
    ..color =,
      Colors.white.withOpacity(0.1);

    // Draw traditional Korean patterns
    final spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawTaegeuk(canvas, Offset(x, y), 15, paint);
}
    }}

  void _drawTaegeuk(Canvas canvas, Offset center, double radius, Paint paint) {
    // Simplified Taegeuk pattern
    canvas.drawCircle(center, radius, paint);
    
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(
      center.dx + radius,
      center.dy);
      center.dx),
            center.dy + radius);
    path.quadraticBezierTo(
      center.dx - radius,
      center.dy);
      center.dx),
            center.dy - radius
    );
    
    canvas.drawPath(path, paint);
}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}