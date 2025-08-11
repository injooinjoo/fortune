import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class LuckyPlaceFortunePage extends BaseFortunePage {
  const LuckyPlaceFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 행운의 장소',
          description: '오늘 당신에게 행운을 가져다줄 장소를 확인해보세요',
          fortuneType: 'lucky-place',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyPlaceFortunePage> createState() => _LuckyPlaceFortunePageState();
}

class _LuckyPlaceFortunePageState extends BaseFortunePageState<LuckyPlaceFortunePage> {
  late AnimationController _compassController;
  String? _selectedEnvironment;
  String? _selectedActivity;
  
  final Map<String, Map<String, dynamic>> _placeCategories = {
    '자연': {
      'icon': Icons.park,
      'places': ['공원': '산', '해변': '강변', '호수': '숲', '정원': '들판'],
      'energy': '자연의 치유와 재충전': 'color': Colors.green,
      'directions': ['동쪽': '남동쪽', '북동쪽']},
    '도시': {
      'icon': Icons.location_city,
      'places': ['카페': '도서관', '백화점': '광장', '전망대': '미술관', '공연장': '시장'],
      'energy': '활기와 영감의 에너지': 'color': Colors.blue,
      'directions': ['서쪽': '남서쪽', '북서쪽']},
    '실내': {
      'icon': Icons.home,
      'places': ['거실': '침실', '서재': '발코니', '욕실': '주방', '다락방': '지하실'],
      'energy': '안정과 집중의 공간': 'color': Colors.orange,
      'directions': ['중앙': '남쪽', '북쪽']},
    '종교/영성': {
      'icon': Icons.temple_buddhist,
      'places': ['절': '교회', '성당': '명상센터', '요가원': '기도실', '묘지': '성지'],
      'energy': '영혼의 평화와 깨달음': 'color': Colors.purple,
      'directions': ['북쪽': '북동쪽', '북서쪽']},
    '업무': {
      'icon': Icons.business,
      'places': ['사무실': '회의실', '로비': '휴게실', '옥상': '주차장', '엘리베이터': '계단'],
      'energy': '성공과 성취의 기운': 'color': Colors.indigo,
      'directions': ['동쪽': '남쪽', '서쪽']},
    '문화': {
      'icon': Icons.museum,
      'places': ['박물관': '갤러리', '극장': '콘서트홀', '도서관': '서점', '영화관': '전시장'],
      'energy': '창의성과 영감의 샘': 'color': Colors.pink,
      'directions': ['남동쪽': '남서쪽', '중앙']}}

  final Map<String, Map<String, dynamic>> _activityInfo = {
    '휴식': {
      'icon': Icons.spa,
      'description': '재충전과 회복을 위한 장소': 'bestPlaces': ['공원': '해변', '침실': '명상센터']},
    '업무': {
      'icon': Icons.work,
      'description': '생산성과 집중력을 높이는 장소': 'bestPlaces': ['도서관': '카페', '사무실': '서재']},
    '만남': {
      'icon': Icons.people,
      'description': '인연과 소통을 원활하게 하는 장소': 'bestPlaces': ['카페': '광장', '공원': '레스토랑']},
    '운동': {
      'icon': Icons.fitness_center,
      'description': '활력과 건강을 증진시키는 장소': 'bestPlaces': ['공원': '산', '체육관': '해변']},
    '쇼핑': {
      'icon': Icons.shopping_bag,
      'description': '행운의 아이템을 찾을 수 있는 장소': 'bestPlaces': ['백화점': '시장', '쇼핑몰': '편의점']},
    '데이트': {
      'icon': Icons.favorite,
      'description': '로맨스와 사랑이 넘치는 장소': 'bestPlaces': ['공원': '카페', '전망대': '해변']}}

  @override
  void initState() {
    super.initState();
    _compassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _compassController.dispose();
    super.dispose();
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호하는 환경 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildEnvironmentSelector(),
        const SizedBox(height: 24),
        Text(
          '오늘의 활동 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildActivitySelector()]
    );
  }

  Widget _buildEnvironmentSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _placeCategories.entries.map((entry) {
        final environment = entry.key;
        final info = entry.value;
        final isSelected = _selectedEnvironment == environment;
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info['icon'],
                size: 18,
                color: isSelected ? Colors.white : null),
              const SizedBox(width: 4),
              Text(environment)]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedEnvironment = selected ? environment : null;
            });
          },
          selectedColor: info['color'] as Color);
      }).toList();
  }

  Widget _buildActivitySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _activityInfo.entries.map((entry) {
        final activity = entry.key;
        final info = entry.value;
        final isSelected = _selectedActivity == activity;
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info['icon'],
                size: 18,
                color: isSelected ? Colors.white : null),
              const SizedBox(width: 4),
              Text(activity)]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedActivity = selected ? activity : null;
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8));
      }).toList();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Get user profile for birth date
    final userProfile = await ref.read(userProfileProvider.future);
    
    // Calculate lucky places based on user's birth date and current date
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    
    // Select primary place category
    final categoryKeys = _placeCategories.keys.toList();
    final primaryIndex = (birthDate.day + today.day + today.month) % categoryKeys.length;
    final primaryCategory = _selectedEnvironment ?? categoryKeys[primaryIndex];
    final primaryCategoryInfo = _placeCategories[primaryCategory]!;
    
    // Select specific places
    final places = primaryCategoryInfo['places'] as List<String>;
    final mainPlaceIndex = (birthDate.month + today.day) % places.length;
    final mainPlace = places[mainPlaceIndex];
    
    // Calculate lucky direction
    final directions = primaryCategoryInfo['directions'] as List<String>;
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays + 1;
    final directionIndex = ((birthDate.year + dayOfYear) % directions.length).toInt();
    final luckyDirection = directions[directionIndex];
    
    // Calculate distance
    final luckyDistance = ((birthDate.day + today.day) % 9 + 1) * 100; // 100m ~ 900m
    
    // Get activity-specific recommendations
    String activityRecommendation = '';
    if (_selectedActivity != null) {
      final activityData = _activityInfo[_selectedActivity]!;
      final bestPlaces = activityData['bestPlaces'] as List<String>;
      activityRecommendation = '장소:\n• ${bestPlaces.join('\n• ')}';
    }

    // Calculate best times
    final morningTime = (birthDate.day % 4) + 6; // 6-9 AM
    final afternoonTime = (birthDate.month % 4) + 14; // 2-5 PM
    final eveningTime = (birthDate.year % 3) + 18; // 6-8 PM

    // Special power spot
    final powerSpotIndex = (birthDate.day + birthDate.month + birthDate.year) % places.length;
    final powerSpot = places[powerSpotIndex];

    final description = '''오늘의 메인 행운의 장소는 ${mainPlace}입니다!

${primaryCategory} 환경의 ${mainPlace}에서 ${primaryCategoryInfo['energy']}을(를) 받을 수 있습니다.

🗺️ 행운의 방향과,
    거리:
• 방향: $luckyDirection
• 거리: 약 ${luckyDistance}m 이내
• 특별 파워,
    스팟: $powerSpot

⏰ 장소별 최적,
    시간:
• 오전: ${morningTime}시 - 새로운 시작과 계획
• 오후: ${afternoonTime}시 - 활발한 활동과 만남
• 저녁: ${eveningTime}시 - 휴식과 재충전

📍 추천 장소,
    활용법:
• $mainPlace에서 최소 30분 이상 머물러보세요
• $luckyDirection 방향을 바라보며 심호흡을 하세요
• 중요한 결정은 $powerSpot에서 내리면 좋습니다

💫 오늘 이,
    장소에서는:
• 예상치 못한 좋은 만남이 있을 수 있습니다
• 막혔던 일의 해결책을 찾을 수 있습니다
• 새로운 영감과 아이디어가 떠오를 것입니다
• 몸과 마음의 균형을 되찾을 수 있습니다$activityRecommendation''';

    final overallScore = 75 + (today.day % 20);

    return Fortune(
      id: 'lucky_place_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'lucky-place',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '장소 에너지': 80 + (today.day % 15),
        '방향 조화': 75 + (today.hour % 20),
        '시간 싱크': 70 + (today.minute % 25)},
      description: description,
      luckyItems: {
        '메인 장소': mainPlace,
        '파워 스팟': powerSpot,
        '방향': luckyDirection,
        '거리': '${luckyDistance}m': '최적 시간': '${morningTime}시, ${afternoonTime}시, ${eveningTime}시'},
      recommendations: [
        '$mainPlace에 가기 전 마음을 비우고 가세요': '장소에 도착하면 주변을 천천히 둘러보세요',
        '직감적으로 끌리는 곳으로 발걸음을 옮기세요': '장소의 에너지를 온몸으로 느껴보세요'],
      metadata: {
        'primaryCategory': primaryCategory,
        'primaryCategoryInfo': primaryCategoryInfo,
        'mainPlace': mainPlace,
        'powerSpot': powerSpot,
        'luckyDirection': luckyDirection,
        'luckyDistance': luckyDistance,
        'bestTimes': {
          'morning': morningTime,
          'afternoon': afternoonTime,
          'evening': eveningTime},
        'selectedEnvironment': _selectedEnvironment,
        'selectedActivity': _selectedActivity,
        'activityInfo': _selectedActivity != null ? _activityInfo[_selectedActivity] : null});
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMainPlaceCard(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildDirectionCompass(),
          _buildPlaceCategoryGrid(),
          _buildTimeSchedule(),
          _buildPlaceEnergyMap(),
          _buildPlaceVisitTips(),
          const SizedBox(height: 32)]));
  }

  Widget _buildMainPlaceCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final mainPlace = fortune.metadata?['mainPlace'] as String?;
    final primaryCategory = fortune.metadata?['primaryCategory'] as String?;
    final primaryCategoryInfo = fortune.metadata?['primaryCategoryInfo'] as Map<String, dynamic>?;
    
    if (mainPlace == null || primaryCategoryInfo == null) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '오늘의 메인 행운의 장소',
            style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (primaryCategoryInfo['color'] as Color).withOpacity(0.3),
                  (primaryCategoryInfo['color'] as Color).withOpacity(0.6)]),
              boxShadow: [
                BoxShadow(
                  color: (primaryCategoryInfo['color'] as Color).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10)]),
            child: Center(
              child: Icon(
                primaryCategoryInfo['icon'],
                size: 64,
                color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            mainPlace,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (primaryCategoryInfo['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            child: Text(
              '$primaryCategory • ${primaryCategoryInfo['energy']}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600)]);
  }

  Widget _buildDirectionCompass() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final luckyDirection = fortune.metadata?['luckyDirection'] as String?;
    final luckyDistance = fortune.metadata?['luckyDistance'] as int?;
    
    if (luckyDirection == null || luckyDistance == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '행운의 방향',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2)),
                  child: AnimatedBuilder(
                    animation: _compassController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _compassController.value * 2 * math.pi,
                        child: CustomPaint(
                          painter: CompassPainter(
                            direction: luckyDirection,
                            color: Theme.of(context).colorScheme.primary));
                    })),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      luckyDirection,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text(
                      '약 ${luckyDistance}m',
                      style: Theme.of(context).textTheme.bodyMedium)])]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 방향으로 ${luckyDistance}m 이내의 $luckyDirection 지역을 탐색해보세요',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center)])]));
  }

  Widget _buildPlaceCategoryGrid() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final primaryCategory = fortune.metadata?['primaryCategory'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '장소 카테고리별 운세',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _placeCategories.entries.map((entry) {
                final category = entry.key;
                final info = entry.value;
                final isPrimary = category == primaryCategory;
                
                return GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  borderColor: isPrimary
                      ? (info['color'] as Color).withOpacity(0.5)
                      : Colors.transparent,
                  borderWidth: isPrimary ? 2 : 0,
                  gradient: LinearGradient(
                    colors: isPrimary
                        ? [
                            (info['color'] as Color).withOpacity(0.15),
                            (info['color'] as Color).withOpacity(0.25)]
                        : [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        info['icon'],
                        size: 32,
                        color: info['color']),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal),
                        textAlign: TextAlign.center),
                      if (isPrimary),
            Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (info['color'] as Color).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          child: Text(
                            '오늘',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)]);
              }).toList(),);
  }

  Widget _buildTimeSchedule() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final bestTimes = fortune.metadata?['bestTimes'] as Map<String, dynamic>?;
    if (bestTimes == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.05)]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '시간대별 최적 활동',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            _buildTimeSlot(
              '오전': '${bestTimes['morning']}:00': '새로운 시작과 계획',
              Icons.wb_sunny,
              Colors.orange),
            const SizedBox(height: 12),
            _buildTimeSlot(
              '오후': '${bestTimes['afternoon']}:00': '활발한 활동과 만남',
              Icons.wb_cloudy,
              Colors.blue),
            const SizedBox(height: 12),
            _buildTimeSlot(
              '저녁': '${bestTimes['evening']}:00': '휴식과 재충전',
              Icons.nightlight_round,
              Colors.indigo)]));
  }

  Widget _buildTimeSlot(String period, String time, String activity, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle),
            child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      period,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 4),
                Text(
                  activity,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)])]));
  }

  Widget _buildPlaceEnergyMap() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final selectedActivity = fortune.metadata?['selectedActivity'] as String?;
    final activityInfo = fortune.metadata?['activityInfo'] as Map<String, dynamic>?;

    if (selectedActivity == null || activityInfo == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  activityInfo['icon'],
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '$selectedActivity 최적 장소',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Text(
              activityInfo['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (activityInfo['bestPlaces'] as List<String>).map((place) {
                return Chip(
                  label: Text(place),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5));
              }).toList(),);
  }

  Widget _buildPlaceVisitTips() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '장소 방문 팁',
                style: Theme.of(context).textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          ...[
            '장소에 도착하면 먼저 주변을 천천히 둘러보세요': '깊은 호흡을 하며 장소의 에너지를 느껴보세요',
            '직감적으로 끌리는 자리나 공간을 찾아보세요': '최소 30분 이상 머물러 충분히 에너지를 흡수하세요',
            '중요한 생각이나 결정은 메모해두세요': '장소를 떠날 때는 감사의 마음을 전하세요'].map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium)]);
          }).toList(),);
  }
}

class CompassPainter extends CustomPainter {
  final String direction;
  final Color color;

  CompassPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw compass needle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final needlePath = Path();
    
    // Calculate angle based on direction
    double angle = 0;
    switch (direction) {
      case '동쪽': angle = 90;
        break;
      case '서쪽':
        angle = 270;
        break;
      case '남쪽':
        angle = 180;
        break;
      case '북쪽':
        angle = 0;
        break;
      case '남동쪽':
        angle = 135;
        break;
      case '남서쪽':
        angle = 225;
        break;
      case '북동쪽':
        angle = 45;
        break;
      case '북서쪽': 
        angle = 315;
        break;
    }
    
    angle = angle * math.pi / 180;
    
    // Draw needle
    final needleLength = radius * 0.8;
    final needleWidth = radius * 0.1;
    
    needlePath.moveTo(
      center.dx + math.sin(angle) * needleLength,
      center.dy - math.cos(angle) * needleLength);
    needlePath.lineTo(
      center.dx + math.sin(angle + math.pi / 2) * needleWidth,
      center.dy - math.cos(angle + math.pi / 2) * needleWidth);
    needlePath.lineTo(
      center.dx - math.sin(angle) * needleLength * 0.3,
      center.dy + math.cos(angle) * needleLength * 0.3);
    needlePath.lineTo(
      center.dx - math.sin(angle + math.pi / 2) * needleWidth,
      center.dy + math.cos(angle + math.pi / 2) * needleWidth
    );
    needlePath.close();
    
    canvas.drawPath(needlePath, paint);
    
    // Draw center circle
    canvas.drawCircle(center, radius * 0.1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}