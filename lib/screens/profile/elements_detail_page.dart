import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/fortune_design_system.dart';
import '../../core/design_system/design_system.dart';
import '../../services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ElementsDetailPage extends ConsumerStatefulWidget {
  const ElementsDetailPage({super.key});

  @override
  ConsumerState<ElementsDetailPage> createState() => _ElementsDetailPageState();
}

class _ElementsDetailPageState extends ConsumerState<ElementsDetailPage> {
  final supabase = Supabase.instance.client;
  final _storageService = StorageService();
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? localProfile;
  bool isLoading = true;

  // TODO: 실제 API에서 가져와야 함
  final Map<String, int> _elementsBalance = {
    '木 (木)': 20,
    '火 (火)': 15,
    '土 (土)': 25,
    '金 (金)': 30,
    '水 (水)': 10,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      localProfile = await _storageService.getUserProfile();

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (mounted) {
          setState(() {
            userProfile = response;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            userProfile = localProfile;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.gray50;
  }

  Color _getCardColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '木 (木)':
        return DSFortuneColors.elementWood;
      case '火 (火)':
        return DSFortuneColors.elementFire;
      case '土 (土)':
        return DSFortuneColors.elementEarth;
      case '金 (金)':
        return DSFortuneColors.elementMetal;
      case '水 (水)':
        return DSFortuneColors.elementWater;
      default:
        return TossDesignSystem.gray400;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingL,
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingS,
      ),
      child: Text(
        title,
        style: TossDesignSystem.caption.copyWith(
          color: _getSecondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildElementBar({
    required String element,
    required int percentage,
    required Color color,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.marginHorizontal,
        vertical: TossDesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _getDividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                element,
                style: TossDesignSystem.body2.copyWith(
                  color: _getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: TossDesignSystem.body2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: _getDividerColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementDescription({
    required String element,
    required String description,
    required Color color,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.marginHorizontal,
        vertical: TossDesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : _getDividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                element.split(' ')[0],
                style: TossDesignSystem.body2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element,
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _getTextColor(context)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '오행 분석',
            style: TossDesignSystem.heading4.copyWith(
              color: _getTextColor(context),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '오행 분석',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              // 오행 균형 섹션
              _buildSectionHeader('오행 균형'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: _elementsBalance.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final element = entry.value.key;
                    final percentage = entry.value.value;
                    final isLast = index == _elementsBalance.length - 1;

                    return _buildElementBar(
                      element: element,
                      percentage: percentage,
                      color: _getElementColor(element),
                      isLast: isLast,
                    );
                  }).toList(),
                ),
              ),

              // 오행 설명 섹션
              _buildSectionHeader('오행 의미'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildElementDescription(
                      element: '木 (木)',
                      description: '성장, 발전, 창의성을 상징합니다. 봄의 기운을 담고 있습니다.',
                      color: _getElementColor('木 (木)'),
                    ),
                    _buildElementDescription(
                      element: '火 (火)',
                      description: '열정, 활력, 변화를 상징합니다. 여름의 기운을 담고 있습니다.',
                      color: _getElementColor('火 (火)'),
                    ),
                    _buildElementDescription(
                      element: '土 (土)',
                      description: '안정, 신뢰, 포용을 상징합니다. 환절기의 기운을 담고 있습니다.',
                      color: _getElementColor('土 (土)'),
                    ),
                    _buildElementDescription(
                      element: '金 (金)',
                      description: '결단, 강인함, 정의를 상징합니다. 가을의 기운을 담고 있습니다.',
                      color: _getElementColor('金 (金)'),
                    ),
                    _buildElementDescription(
                      element: '水 (水)',
                      description: '지혜, 유연성, 포용을 상징합니다. 겨울의 기운을 담고 있습니다.',
                      color: _getElementColor('水 (水)'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),

              // 안내 메시지
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: TossDesignSystem.tossBlue,
                        size: 20,
                      ),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          '오행 분석은 사주 팔자를 기반으로 계산됩니다. 정확한 분석을 위해 프로필 정보를 완성해주세요.',
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}
