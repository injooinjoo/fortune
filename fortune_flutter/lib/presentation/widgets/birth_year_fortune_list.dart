import 'package:flutter/material.dart';
import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme.dart';

class BirthYearFortuneList extends StatelessWidget {
  final List<BirthYearFortune> fortunes;
  final String? title;
  final String? currentUserZodiac;

  const BirthYearFortuneList({
    Key? key,
    required this.fortunes,
    this.title,
    this.currentUserZodiac,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fortunes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fortunes.length,
            itemBuilder: (context, index) {
              final fortune = fortunes[index];
              final isCurrentUser = fortune.zodiacAnimal == currentUserZodiac;
              
              return BirthYearFortuneCard(
                fortune: fortune,
                isHighlighted: isCurrentUser,
              );
            },
          ),
        ),
      ],
    );
  }
}

class BirthYearFortuneCard extends StatelessWidget {
  final BirthYearFortune fortune;
  final bool isHighlighted;

  const BirthYearFortuneCard({
    Key? key,
    required this.fortune,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: isHighlighted ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighlighted
              ? BorderSide(color: AppTheme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isHighlighted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildZodiacIcon(fortune.zodiacAnimal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${fortune.birthYear}년생 ${fortune.zodiacAnimal}띠',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isHighlighted ? AppTheme.primaryColor : null,
                          ),
                        ),
                        if (isHighlighted)
                          Text(
                            '나의 띠',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  fortune.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppTheme.textColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (fortune.advice != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fortune.advice!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacIcon(String zodiac) {
    final zodiacEmojis = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐖',
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          zodiacEmojis[zodiac] ?? '🔮',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Expanded view for a single birth year fortune
class BirthYearFortuneDetailCard extends StatelessWidget {
  final BirthYearFortune fortune;

  const BirthYearFortuneDetailCard({
    Key? key,
    required this.fortune,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildZodiacIcon(fortune.zodiacAnimal),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fortune.birthYear}년생 ${fortune.zodiacAnimal}띠',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '특별 운세',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              fortune.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppTheme.textColor,
              ),
            ),
            if (fortune.advice != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '특별 조언',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fortune.advice!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacIcon(String zodiac) {
    final zodiacEmojis = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐖',
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          zodiacEmojis[zodiac] ?? '🔮',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}