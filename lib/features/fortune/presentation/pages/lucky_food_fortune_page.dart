import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class LuckyFoodFortunePage extends BaseFortunePage {
  const LuckyFoodFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 행운의 음식',
          description: '오늘 당신에게 행운을 가져다줄 음식을 확인해보세요',
          fortuneType: 'lucky-food',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyFoodFortunePage> createState() => _LuckyFoodFortunePageState();
}

class _LuckyFoodFortunePageState extends BaseFortunePageState<LuckyFoodFortunePage> {
  String? _selectedPreference;
  String? _selectedMealTime;
  
  final Map<String, Map<String, dynamic>> _foodCategories = {
    '한식': {}
      'icon', '🍚',
      'foods': \['['김치찌개', '비빔밥', '삼겹살', '김밥', '떡볶이', '잡채', '갈비탕', '냉면'],
      'energy', '따뜻한 정과 활력',
      'color': null},
    '중식': {
      'icon', '🥟',
      'foods': ['짜장면', '짬뽕', '탕수육', '마파두부', '깐풍기', '볶음밥', '양장피', '팔보채'],
      'energy', '풍요와 번영',
      'color': null},
    '일식': {
      'icon', '🍱',
      'foods': ['초밥', '라멘', '돈카츠', '우동', '덴푸라', '야키토리', '오코노미야키', '카레'],
      'energy', '섬세함과 균형',
      'color': null},
    '양식': {
      'icon', '🍝',
      'foods': ['파스타', '피자', '스테이크', '리조또', '샐러드', '햄버거', '샌드위치', '수프'],
      'energy', '자유와 창의성',
      'color': null},
    '디저트': {
      'icon', '🍰',
      'foods': ['케이크', '마카롱', '티라미수', '푸딩', '아이스크림', '와플', '팬케이크', '초콜릿'],
      'energy', '달콤한 행복',
      'color': null},
    '음료': {
      'icon', '☕',
      'foods': ['커피', '녹차', '과일주스', '스무디', '에이드', '차', '코코아', '탄산음료'],
      'energy', '상쾌한 활력',
      'color': null}};

  final Map<String, Map<String, dynamic>> _nutritionInfo = {
    '단백질': {}
      'icon': Icons.fitness_center,
      'benefit', '체력과 집중력 향상',
      'foods': ['닭가슴살', '계란', '두부', '연어': null},
    '비타민': {
      , 'icon': Icons.wb_sunny,
      'benefit', '면역력과 활력 증진',
      'foods': ['과일', '샐러드', '녹색 채소', '견과류': null},
    '탄수화물': {
      , 'icon': Icons.battery_charging_full,
      'benefit', '즉각적인 에너지 공급',
      'foods': ['밥', '빵', '파스타', '감자': null},
    '오메가3': {
      , 'icon': Icons.favorite,
      'benefit', '두뇌 활동과 심장 건강',
      'foods': ['연어', '참치', '호두', '아보카도': null}};

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '음식 선호도 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildPreferenceSelector(),
        const SizedBox(height: 24),
        Text(
          '식사 시간대 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildMealTimeSelector()]
    );
  }

  Widget _buildPreferenceSelector() {
    final preferences = [
      {'id', 'spicy': 'label', '매운맛': 'icon', '🌶️'},
      {'id', 'sweet', 'label', '단맛', 'icon', '🍯'},
      {'id', 'sour', 'label', '신맛', 'icon', '🍋'},
      {'id', 'salty', 'label', '짠맛', 'icon', '🧂'},
      {'id', 'light', 'label', '담백한맛', 'icon', '🥗'},
      {'id', 'rich', 'label', '진한맛', 'icon', '🍖'}];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: preferences.map((pref) {
        final isSelected = _selectedPreference == pref['id'];
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pref['icon'],
              const SizedBox(width: 4),
              Text(pref['label']]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedPreference = selected ? pref['id'],
    String : null;
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2));
      }).toList());
  }

  Widget _buildMealTimeSelector() {
    final mealTimes = [
      {'id', 'breakfast': 'label', '아침': 'icon'},
      {'id', 'lunch', 'label', '점심', 'icon'},
      {'id', 'dinner', 'label', '저녁', 'icon'},
      {'id', 'snack', 'label', '간식', 'icon'}];

    return Row(
      children: mealTimes.map((time) {
        final isSelected = _selectedMealTime == time['id'];
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(16),
              blur: 20,
              borderColor: isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.transparent,
              borderWidth: isSelected ? 2 : 0,
              gradient: LinearGradient(
                colors: isSelected
                    ? [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1)]
                    : [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05)]),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedMealTime = time['id'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      time['icon'],
                      size: 28,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface),
                    const SizedBox(height: 8),
                    Text(
                      time['label'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])))));
      }).toList());
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Get user profile for birth date
    final userProfile = await ref.read(userProfileProvider.future);
    
    // Calculate lucky foods based on user's birth date and current date
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    
    // Select primary food category
    final categoryKeys = _foodCategories.keys.toList();
    final primaryIndex = (birthDate.day + today.day + today.month) % categoryKeys.length;
    final primaryCategory = categoryKeys[primaryIndex];
    final primaryCategoryInfo = _foodCategories[primaryCategory]!;
    
    // Select specific foods
    final foods = primaryCategoryInfo['foods'] as List<String>;
    final mainFoodIndex = (birthDate.month + today.day) % foods.length;
    final mainFood = foods[mainFoodIndex];
    
    // Select secondary food
    final secondaryIndex = (primaryIndex + 2) % categoryKeys.length;
    final secondaryCategory = categoryKeys[secondaryIndex];
    final secondaryCategoryInfo = _foodCategories[secondaryCategory]!;
    final secondaryFoods = secondaryCategoryInfo['foods'] as List<String>;
    final secondaryFood = secondaryFoods[today.day % secondaryFoods.length];
    
    // Calculate nutrition recommendation
    final nutritionKeys = _nutritionInfo.keys.toList();
    final nutritionIndex = (birthDate.day + today.hour) % nutritionKeys.length;
    final recommendedNutrition = nutritionKeys[nutritionIndex];
    final nutritionData = _nutritionInfo[recommendedNutrition]!;

    // Consider user preferences
    String preferenceNote = '';
    if (_selectedPreference != null) {
      preferenceNote = '\n\n선호하신 ${_getPreferenceLabel(_selectedPreference!)} 음식이 특히 좋은 날입니다.';
    }

    String mealTimeNote = '';
    if (_selectedMealTime != null) {
      mealTimeNote = '\n${_getMealTimeLabel(_selectedMealTime!)}에 이 음식을 드시면 더욱 효과적입니다.';
    }

    final description = '''오늘의 메인 행운 음식은 ${mainFood}입니다!

${primaryCategory} 요리가 오늘 당신에게 ${primaryCategoryInfo['energy']}을(를) 가져다줄 것입니다.

🍽️ 추천,
    메뉴:
• 메인: $mainFood
• 서브: $secondaryFood
• 디저트: ${_getRandomDessert(today)}
• 음료: ${_getRandomDrink(today)}

💪 오늘 필요한,
    영양소: $recommendedNutrition
${nutritionData['benefit']}을(를) 위해 ${(nutritionData['foods'] as List<String>).join(', ')} 등을 섭취하세요.

🌟 음식,
    에너지:
• $primaryCategory: ${primaryCategoryInfo['energy']}
• $secondaryCategory: ${secondaryCategoryInfo['energy']}

오늘 이 음식들을,
    섭취하면:
• 에너지가 충전되고 활력이 넘칩니다
• 중요한 순간에 좋은 결과를 얻을 수 있습니다
• 소화가 잘되고 몸이 가벼워집니다$preferenceNote$mealTimeNote''';

    final overallScore = 75 + (today.day % 20);

    return Fortune(
      id: 'lucky_food_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'lucky-food',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '건강운': 80 + (today.day % 15),
        '활력지수': 75 + (today.hour % 20),
        '소화운': null},
      description: description,
      luckyItems: {
        '메인 음식': mainFood,
        '서브 음식': secondaryFood,
        '카테고리': primaryCategory,
        '영양소': recommendedNutrition,
        '최적 시간', '${(birthDate.day % 12 + 11)}시-${(birthDate.day % 12 + 13)}시'},
      recommendations: [
        '$mainFood을(를) 천천히 음미하며 드세요',
        '음식의 색과 향을 충분히 느껴보세요',
        '감사한 마음으로 식사를 즐기세요',
        '식후 가벼운 산책을 하면 더욱 좋습니다'],
      metadata: {
        'primaryCategory': primaryCategory,
        'primaryCategoryInfo': primaryCategoryInfo,
        'secondaryCategory': secondaryCategory,
        'secondaryCategoryInfo': secondaryCategoryInfo,
        'mainFood': mainFood,
        'secondaryFood': secondaryFood,
        'nutritionRecommendation': recommendedNutrition,
        'nutritionData': nutritionData,
        'allFoodCategories': _foodCategories,
        'selectedPreference': _selectedPreference,
        'selectedMealTime': null});
  }

  String _getPreferenceLabel(String preference) {
    final labels = {
      'spicy', '매운맛',
      'sweet', '단맛',
      'sour', '신맛',
      'salty', '짠맛',
      'light', '담백한맛',
      'rich', '진한맛'};
    return labels[preference] ?? preference;
  }

  String _getMealTimeLabel(String mealTime) {
    final labels = {
      'breakfast', '아침',
      'lunch', '점심',
      'dinner', '저녁',
      'snack', '간식 시간'};
    return labels[mealTime] ?? mealTime;
  }

  String _getRandomDessert(DateTime date) {
    final desserts = _foodCategories['디저트']!['foods'] as List<String>;
    return desserts[date.hour % desserts.length];
  }

  String _getRandomDrink(DateTime date) {
    final drinks = _foodCategories['음료']!['foods'] as List<String>;
    return drinks[date.minute % drinks.length];
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMainFoodCard(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildFoodCategoryGrid(),
          _buildNutritionInfo(),
          _buildFoodEnergyChart(),
          _buildEatingTips(),
          const SizedBox(height: 32)]));
  }

  Widget _buildMainFoodCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final mainFood = fortune.metadata?['mainFood'] as String?;
    final primaryCategory = fortune.metadata?['primaryCategory'] as String?;
    final primaryCategoryInfo = fortune.metadata?['primaryCategoryInfo'] as Map<String, dynamic>?;
    
    if (mainFood == null || primaryCategoryInfo == null) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '오늘의 메인 행운 음식',
            style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (primaryCategoryInfo['color'],
                  (primaryCategoryInfo['color']]),
              boxShadow: [
                BoxShadow(
                  color: (primaryCategoryInfo['color'],
                  blurRadius: 30,
                  spreadRadius: 10)]),
            child: Center(
              child: Text(
                primaryCategoryInfo['icon'],
                style: const TextStyle(fontSize: 64)))),
          const SizedBox(height: 16),
          Text(
            mainFood,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (primaryCategoryInfo['color'],
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              '$primaryCategory • ${primaryCategoryInfo['energy']}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primaryCategoryInfo['color'],
                fontWeight: FontWeight.w600)))]));
  }

  Widget _buildFoodCategoryGrid() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final primaryCategory = fortune.metadata?['primaryCategory'] as String?;
    final secondaryCategory = fortune.metadata?['secondaryCategory'] as String?;

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
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '음식 카테고리별 운세',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _foodCategories.entries.map((entry) {
                final category = entry.key;
                final info = entry.value;
                final isPrimary = category == primaryCategory;
                final isSecondary = category == secondaryCategory;
                
                return GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  borderColor: isPrimary 
                      ? (info['color'] as Color).withOpacity(0.5)
                      : isSecondary
                          ? (info['color'] as Color).withOpacity(0.3)
                          : Colors.transparent,
                  borderWidth: isPrimary ? 2 : isSecondary ? 1 : 0,
                  gradient: LinearGradient(
                    colors: isPrimary || isSecondary
                        ? [
                            (info['color'],
                            (info['color']]
                        : [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        info['icon'],
                        style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isPrimary || isSecondary ? FontWeight.bold : FontWeight.normal),
                        textAlign: TextAlign.center),
                      if (isPrimary)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (info['color'],
                            borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '메인',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: info['color'],
                              fontWeight: FontWeight.bold)))]));
              }).toList())])));
  }

  Widget _buildNutritionInfo() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final recommendedNutrition = fortune.metadata?['nutritionRecommendation'] as String?;
    final nutritionData = fortune.metadata?['nutritionData'] as Map<String, dynamic>?;
    
    if (recommendedNutrition == null || nutritionData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05)]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '오늘의 영양 포인트',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3))),
              child: Row(
                children: [
                  Icon(
                    nutritionData['icon'],
                    size: 48,
                    color: Colors.green),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendedNutrition,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          nutritionData['benefit'],
                          style: Theme.of(context).textTheme.bodyMedium)]))])),
            const SizedBox(height: 16),
            Text(
              '추천 음식',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (nutritionData['foods'] as List<String>).map((food) {
                return Chip(
                  label: Text(food),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  side: BorderSide(
                    color: Colors.green.withOpacity(0.5)));
              }).toList())])));
  }

  Widget _buildFoodEnergyChart() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final allCategories = fortune.metadata?['allFoodCategories'] as Map<String, Map<String, dynamic>>?;
    if (allCategories == null) return const SizedBox.shrink();

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
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '음식별 에너지',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...allCategories.entries.take(4).map((entry) {
              final category = entry.key;
              final info = entry.value;
              final energy = info['energy'] as String;
              final color = info['color'] as Color;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          info['icon'],
                          style: const TextStyle(fontSize: 20)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold)),
                          Text(
                            energy,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))]))]));
            }).toList()])));
  }

  Widget _buildEatingTips() {
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
                '음식 섭취 팁',
                style: Theme.of(context).textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          ...[
            '음식을 먹기 전 잠시 감사의 마음을 가져보세요',
            '천천히 씹으며 음식의 맛과 향을 음미하세요',
            '식사 중 스마트폰 사용을 자제하고 음식에 집중하세요',
            '식후 5-10분 정도 가벼운 산책을 해보세요',
            '충분한 물을 함께 섭취하여 소화를 도와주세요',
            '행운의 음식과 함께 긍정적인 생각을 떠올려보세요'].map((tip) {
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
                      style: Theme.of(context).textTheme.bodyMedium))]));
          }).toList()]));
  }
}