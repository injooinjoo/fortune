import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
import 'base_fortune_page.dart';

/// 태어난 계절 운세 페이지
class BirthSeasonFortunePage extends BaseFortunePage {
  const BirthSeasonFortunePage({super.key})
      : super(
          title: '태어난 계절 운세',
          description: '태어난 계절의 기운으로 당신의 운명을 읽어드립니다',
          fortuneType: 'birth-season',
          requiresUserInfo: true, // 생년월일 필요
        );

  @override
  ConsumerState<BirthSeasonFortunePage> createState() => _BirthSeasonFortunePageState();
}

class _BirthSeasonFortunePageState extends BaseFortunePageState<BirthSeasonFortunePage> {
  // 계절 정보 (UI 참조용)
  final Map<String, Map<String, dynamic>> seasons = const {
    'spring': {
      'name': '봄',
      'icon': Icons.local_florist,
      'color': TossDesignSystem.successGreen,
      'months': [3, 4, 5],
    },
    'summer': {
      'name': '여름',
      'icon': Icons.wb_sunny,
      'color': TossDesignSystem.warningOrange,
      'months': [6, 7, 8],
    },
    'autumn': {
      'name': '가을',
      'icon': Icons.eco,
      'color': TossDesignSystem.gray700,
      'months': [9, 10, 11],
    },
    'winter': {
      'name': '겨울',
      'icon': Icons.ac_unit,
      'color': TossDesignSystem.tossBlue,
      'months': [12, 1, 2],
    },
  };

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    Logger.info('🔮 [BirthSeasonFortune] Calling API');

    try {
      final apiService = ref.read(fortuneApiServiceProvider);

      // API 호출 - FortuneApiService.getFortune 사용
      // Decision service is automatically applied inside getFortune
      final fortune = await apiService.getFortune(
        userId: user.id,
        fortuneType: widget.fortuneType,
        params: params,
      );

      Logger.info('✅ [BirthSeasonFortune] API fortune loaded successfully');
      return fortune;

    } catch (e, stackTrace) {
      Logger.error('❌ [BirthSeasonFortune] API failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If fortune exists, BaseFortunePage automatically shows result
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show custom input UI
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20).copyWith(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: TossDesignSystem.successGreen, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '계절별 운세 안내',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '프로필에 등록된 생년월일을 기반으로 태어난 계절의 운세를 확인합니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossDesignSystem.gray400,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: seasons.length,
                  itemBuilder: (context, index) {
                    final seasonKey = seasons.keys.elementAt(index);
                    final season = seasons[seasonKey]!;

                    return Container(
                      decoration: BoxDecoration(
                        color: (season['color'] as Color).withValues(alpha: 0.1),
                        border: Border.all(
                          color: (season['color'] as Color).withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            season['icon'],
                            size: 32,
                            color: season['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            season['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: season['color'],
                            ),
                          ),
                          Text(
                            '${(season['months'] as List<int>).first}월-${(season['months'] as List<int>).last}월',
                            style: const TextStyle(
                              fontSize: 12,
                              color: TossDesignSystem.gray400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
              padding: const EdgeInsets.all(20),
              child: TossButton(
                text: '내 계절 운세 확인하기',
                onPressed: () => generateFortuneAction(params: {}),
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
