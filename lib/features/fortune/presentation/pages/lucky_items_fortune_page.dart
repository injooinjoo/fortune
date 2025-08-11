import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/auth_provider.dart';

class LuckyItemsFortunePage extends BaseFortunePage {
  const LuckyItemsFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 행운의 아이템',
          description: '오늘 당신에게 행운을 가져다줄 아이템을 확인해보세요',
          fortuneType: 'lucky-items',
          requiresUserInfo: true);

  @override
  ConsumerState<LuckyItemsFortunePage> createState() => _LuckyItemsFortunePageState();
}

class _LuckyItemsFortunePageState extends BaseFortunePageState<LuckyItemsFortunePage> {
  String? _selectedCategory;
  String? _selectedPurpose;
  
  final Map<String, Map<String, dynamic>> _itemCategories = {
    '액세서리': {
      'icon': Icons.auto_awesome,
      'items': ['반지': '목걸이', '팔찌': '시계', '귀걸이': '브로치', '머리핀': '스카프'],
      'energy': '개인의 매력과 운을 증폭': 'color': Colors.purple},
    '문구류': {
      'icon': Icons.edit,
      'items': ['펜': '노트', '다이어리': '책갈피', '스티커': '필통', '지우개': '자'],
      'energy': '집중력과 창의성 향상': 'color': Colors.blue},
    '생활용품': {
      'icon': Icons.home,
      'items': ['머그컵': '쿠션', '담요': '향초', '화분': '액자', '거울': '시계'],
      'energy': '일상의 안정과 평화': 'color': Colors.green},
    '패션': {
      'icon': Icons.checkroom,
      'items': ['가방': '신발', '모자': '벨트', '지갑': '선글라스', '우산': '장갑'],
      'energy': '자신감과 스타일 업그레이드': 'color': Colors.pink},
    '전자기기': {
      'icon': Icons.devices,
      'items': ['휴대폰 케이스': '이어폰', '충전기': '스마트워치', '태블릿': '노트북 파우치', '키보드': '마우스'],
      'energy': '소통과 연결의 원활함': 'color': Colors.cyan},
    '자연물': {
      'icon': Icons.park,
      'items': ['크리스탈': '조개껍질', '나뭇잎': '돌멩이', '꽃': '깃털', '모래': '씨앗'],
      'energy': '자연의 치유와 보호': 'color': Colors.amber}};

  final Map<String, Map<String, dynamic>> _purposeInfo = {
    '연애운': {
      'icon': Icons.favorite,
      'description': '사랑과 인연을 끌어당기는 아이템': 'boostItems': ['분홍색 액세서리': '하트 모양 아이템', '향수': '꽃']},
    '금전운': {
      'icon': Icons.attach_money,
      'description': '재물과 풍요를 가져오는 아이템': 'boostItems': ['금색 아이템': '동전', '지갑': '황금색 장식품']},
    '사업운': {
      'icon': Icons.business,
      'description': '성공과 성취를 돕는 아이템': 'boostItems': ['명함지갑': '고급 펜', '시계': '정장 액세서리']},
    '건강운': {
      'icon': Icons.favorite_border,
      'description': '활력과 건강을 지켜주는 아이템': 'boostItems': ['녹색 아이템': '크리스탈', '향초': '운동용품']},
    '학업운': {
      'icon': Icons.school,
      'description': '집중력과 학습 능력을 높이는 아이템': 'boostItems': ['파란색 문구': '책갈피', '안경': '노트']},
    '대인운': {
      'icon': Icons.groups,
      'description': '인간관계를 원활하게 하는 아이템': 'boostItems': ['밝은색 액세서리': '명함', '향수': '미소 띤 사진']}};

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관심 카테고리 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 24),
        Text(
          '향상시키고 싶은 운 (선택사항)',
          style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildPurposeSelector()]);
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _itemCategories.entries.map((entry) {
        final category = entry.key;
        final info = entry.value;
        final isSelected = _selectedCategory == category;
        
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info['icon'],
                size: 18,
                color: isSelected ? Colors.white : null),
              const SizedBox(width: 4),
              Text(category)]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary);
      }).toList();
  }

  Widget _buildPurposeSelector() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: _purposeInfo.entries.map((entry) {
        final purpose = entry.key;
        final info = entry.value;
        final isSelected = _selectedPurpose == purpose;
        
        return GlassContainer(
          padding: const EdgeInsets.all(12),
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
                _selectedPurpose = purpose;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  info['icon'],
                  size: 28,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 8),
                Text(
                  purpose,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  textAlign: TextAlign.center)]));
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
    
    // Calculate lucky items based on user's birth date and current date
    final birthDate = userProfile?.birthDate ?? DateTime.now();
    final today = DateTime.now();
    
    // Select primary item category
    final categoryKeys = _itemCategories.keys.toList();
    final primaryIndex = (birthDate.day + today.day + today.month) % categoryKeys.length;
    final primaryCategory = _selectedCategory ?? categoryKeys[primaryIndex];
    final primaryCategoryInfo = _itemCategories[primaryCategory]!;
    
    // Select specific items
    final items = primaryCategoryInfo['items'] as List<String>;
    final mainItemIndex = (birthDate.month + today.day) % items.length;
    final mainItem = items[mainItemIndex];
    
    // Select secondary items
    final secondaryIndex = (primaryIndex + 3) % categoryKeys.length;
    final secondaryCategory = categoryKeys[secondaryIndex];
    final secondaryCategoryInfo = _itemCategories[secondaryCategory]!;
    final secondaryItems = secondaryCategoryInfo['items'] as List<String>;
    final secondaryItem = secondaryItems[today.hour % secondaryItems.length];
    
    // Calculate special power item
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays + 1;
    final specialIndex = (birthDate.year + dayOfYear) % items.length;
    final specialItem = items[specialIndex];
    
    // Get purpose-specific recommendations
    String purposeRecommendation = '';
    if (_selectedPurpose != null) {
      final purposeData = _purposeInfo[_selectedPurpose]!;
      final boostItems = purposeData['boostItems'] as List<String>;
      purposeRecommendation = '추천:\n• ${boostItems.join('\n• ')}';
    }

    // Calculate power times
    final powerHour = (birthDate.day + today.day) % 24;
    final luckyMinute = birthDate.minute;

    final description = '''오늘의 메인 행운 아이템은 ${mainItem}입니다!

${primaryCategory} 카테고리의 ${mainItem}이(가) 당신에게 ${primaryCategoryInfo['energy']}을(를) 가져다줄 것입니다.

🎯 오늘의 행운,
    아이템:
• 메인,
    아이템: $mainItem
• 서브,
    아이템: $secondaryItem
• 특별 파워,
    아이템: $specialItem

⏰ 아이템 파워,
    타임:
• 최고 효력,
    시간: ${powerHour}시 ${luckyMinute}분
• 아침,
    활성화: 오전 ${(powerHour % 12) == 0 ? 12 : (powerHour % 12)}시
• 저녁,
    충전: 오후 ${((powerHour + 12) % 12) == 0 ? 12 : ((powerHour + 12) % 12)}시

💫 아이템,
    활용법:
• $mainItem을(를) 항상 소지하거나 가까이 두세요
• 중요한 순간에는 $specialItem을(를) 만지며 에너지를 받으세요
• $secondaryItem은(는) 보조적으로 활용하면 시너지 효과가 있습니다

오늘 이 아이템들과,
    함께라면:
• 예상치 못한 행운이 찾아올 수 있습니다
• 어려운 상황에서 돌파구를 찾을 수 있습니다
• 긍정적인 에너지가 주변으로 퍼져나갑니다$purposeRecommendation''';

    final overallScore = 75 + (today.day % 20);

    return Fortune(
      id: 'lucky_items_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: widget.fortuneType,
      content: description,
      createdAt: DateTime.now(),
      category: 'lucky-items',
      overallScore: overallScore,
      scoreBreakdown: {
        '전체운': overallScore,
        '아이템 파워': 80 + (today.day % 15),
        '시너지 효과': 75 + (today.hour % 20),
        '지속력': null},
      description: description,
      luckyItems: {
        '메인 아이템': mainItem,
        '서브 아이템': secondaryItem,
        '파워 아이템': specialItem,
        '카테고리': primaryCategory,
        '파워 타임': '${powerHour}:${luckyMinute.toString().padLeft(2, '0')}'},
      recommendations: [
        '$mainItem을(를) 매일 소지하는 습관을 들이세요': '아이템을 깨끗하게 관리하면 효과가 배가됩니다',
        '중요한 순간에 아이템을 시각화하며 명상하세요': '주기적으로 아이템에 감사의 마음을 전하세요'],
      metadata: {
        'primaryCategory': primaryCategory,
        'primaryCategoryInfo': primaryCategoryInfo,
        'secondaryCategory': secondaryCategory,
        'secondaryCategoryInfo': secondaryCategoryInfo,
        'mainItem': mainItem,
        'secondaryItem': secondaryItem,
        'specialItem': specialItem,
        'powerHour': powerHour,
        'luckyMinute': luckyMinute,
        'selectedCategory': _selectedCategory,
        'selectedPurpose': _selectedPurpose,
        'purposeInfo': null});
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMainItemCard(),
          const SizedBox(height: 16),
          super.buildFortuneResult(),
          _buildItemCategoryGrid(),
          _buildPowerTimeCard(),
          _buildItemEnergyFlow(),
          _buildItemCareTips(),
          const SizedBox(height: 32)]));
  }

  Widget _buildMainItemCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final mainItem = fortune.metadata?['mainItem'] as String?;
    final primaryCategory = fortune.metadata?['primaryCategory'] as String?;
    final primaryCategoryInfo = fortune.metadata?['primaryCategoryInfo'] as Map<String, dynamic>?;
    
    if (mainItem == null || primaryCategoryInfo == null) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '오늘의 메인 행운 아이템',
            style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryCategoryInfo['color'] as Color,
                  primaryCategoryInfo['color'] as Color]),
              boxShadow: [
                BoxShadow(
                  color: primaryCategoryInfo['color'] as Color,
                  blurRadius: 30,
                  spreadRadius: 10)]),
            child: Center(
              child: Icon(
                primaryCategoryInfo['icon'],
                size: 64,
                color: primaryCategoryInfo['color'])),
          const SizedBox(height: 16),
          Text(
            mainItem,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryCategoryInfo['color'] as Color,
              borderRadius: BorderRadius.circular(20),
            child: Text(
              '$primaryCategory • ${primaryCategoryInfo['energy']}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primaryCategoryInfo['color'] as Color,
                fontWeight: FontWeight.w600)]);
  }

  Widget _buildItemCategoryGrid() {
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
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '아이템 카테고리별 운세',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _itemCategories.entries.map((entry) {
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
                            info['color'] as Color,
                            info['color'] as Color]
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
                          fontWeight: isPrimary || isSecondary ? FontWeight.bold : FontWeight.normal),
                        textAlign: TextAlign.center),
                      if (isPrimary),
            Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: info['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          child: Text(
                            '메인',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: info['color'] as Color,
                              fontWeight: FontWeight.bold)]);
              }).toList(),);
  }

  Widget _buildPowerTimeCard() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final powerHour = fortune.metadata?['powerHour'] as int?;
    final luckyMinute = fortune.metadata?['luckyMinute'] as int?;
    
    if (powerHour == null || luckyMinute == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.amber.withOpacity(0.05)]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '아이템 파워 타임',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 48,
                    color: Colors.amber),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최고 효력 시간',
                        style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${powerHour.toString().padLeft(2, '0')}:${luckyMinute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold))])])),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSlot(
                    '아침 활성화': '${(powerHour % 12) == 0 ? 12 : (powerHour % 12)}:00 AM',
                    Icons.wb_sunny,
                    Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSlot(
                    '저녁 충전': '${((powerHour + 12) % 12) == 0 ? 12 : ((powerHour + 12) % 12)}:00 PM',
                    Icons.nightlight_round,
                    Colors.indigo))])]));
  }

  Widget _buildTimeSlot(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold)]);
  }

  Widget _buildItemEnergyFlow() {
    final fortune = this.fortune;
    if (fortune == null) return const SizedBox.shrink();

    final selectedPurpose = fortune.metadata?['selectedPurpose'] as String?;
    final purposeInfo = fortune.metadata?['purposeInfo'] as Map<String, dynamic>?;

    if (selectedPurpose == null || purposeInfo == null) {
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
                  purposeInfo['icon'],
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '$selectedPurpose 강화 아이템',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Text(
              purposeInfo['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (purposeInfo['boostItems'] as List<String>).map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5));
              }).toList(),);
  }

  Widget _buildItemCareTips() {
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
                '아이템 관리 팁',
                style: Theme.of(context).textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          ...[
            '아이템은 항상 깨끗하게 유지하여 에너지를 보존하세요': '매일 아침 아이템에 하루의 소망을 담아보세요',
            '중요한 순간 5분 전, 아이템을 손에 쥐고 심호흡하세요': '한 달에 한 번 보름달 아래에서 아이템을 정화하세요',
            '아이템과 함께한 행운의 순간을 기록해두세요': '다른 사람이 함부로 만지지 않도록 주의하세요'].map((tip) {
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