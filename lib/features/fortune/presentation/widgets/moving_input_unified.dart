import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'package:flutter/services.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../services/region_service.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'standard_fortune_app_bar.dart';

/// 이사운 통합 입력 페이지 - 토스 스타일
class MovingInputUnified extends StatefulWidget {
  final Function(String currentArea, String targetArea, String period, String purpose) onComplete;

  const MovingInputUnified({
    super.key,
    required this.onComplete,
  });

  @override
  State<MovingInputUnified> createState() => _MovingInputUnifiedState();
}

class _MovingInputUnifiedState extends State<MovingInputUnified> with TickerProviderStateMixin {
  String? _currentArea;
  String? _targetArea;
  String? _movingPeriod;
  String? _purpose;
  bool _isLoading = false;

  late AnimationController _buttonController;

  List<Region> _popularRegions = [];
  List<Region> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  final List<Map<String, String>> _periods = [
    {'title': '1개월 이내', 'subtitle': '급하게'},
    {'title': '3개월 이내', 'subtitle': '적당히'},
    {'title': '6개월 이내', 'subtitle': '여유롭게'},
  ];

  final List<Map<String, String>> _purposes = [
    {'icon': '🏢', 'title': '직장 때문에'},
    {'icon': '💑', 'title': '결혼해서'},
    {'icon': '🎓', 'title': '교육 환경'},
    {'icon': '🏡', 'title': '더 나은 환경'},
    {'icon': '💰', 'title': '투자 목적'},
    {'icon': '👨‍👩‍👧‍👦', 'title': '가족과 함께'},
  ];

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadPopularRegions();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPopularRegions() async {
    try {
      final regions = await _regionService.getPopularRegions();
      if (mounted) {
        setState(() {
          _popularRegions = regions;
        });
      }
    } catch (e) {
      // 에러 처리
    }
  }
  
  Future<void> _searchRegions(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    
    try {
      final results = await _regionService.searchRegions(query);
      if (mounted && _searchQuery == query) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  bool _canContinue() {
    return _currentArea != null && 
           _targetArea != null && 
           _movingPeriod != null && 
           _purpose != null &&
           !_isLoading;
  }

  void _handleComplete() async {
    if (!_canContinue()) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isLoading = true;
    });
    
    _buttonController.forward();
    
    // 광고 로딩 시뮬레이션 (3초)
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      widget.onComplete(_currentArea!, _targetArea!, _movingPeriod!, _purpose!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: const StandardFortuneAppBar(
        title: '이사운',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  '이사 정보 입력',
                  style: TossTheme.heading1.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: TossTheme.spacingL),

                // 지역 선택
                _buildLocationSection(),

                const SizedBox(height: TossTheme.spacingXL),

                // 시기 선택
                _buildPeriodSection(),

                const SizedBox(height: TossTheme.spacingXL),

                // 목적 선택
                _buildPurposeSection(),

                const SizedBox(height: TossTheme.spacingXXL),

                const BottomButtonSpacing(),
              ],
            ),
          ),
          FloatingBottomButton(
            text: _isLoading ? '이사운 분석중...' : '이사운 보기',
            onPressed: _canContinue() ? _handleComplete : null,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지역',
              style: TossTheme.body1.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
        const SizedBox(height: TossTheme.spacingM),
        
        // 현재 지역
        TossCard(
          onTap: () => _showAreaSelector(true),
          padding: const EdgeInsets.all(TossTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: TossTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: TossTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                    Text(
                      _currentArea ?? '현재 거주지를 선택하세요',
                      style: TossTheme.body2.copyWith(
                        color: _currentArea != null
                            ? (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                            : (isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
              ),
            ],
          ),
        ),
        
            const SizedBox(height: TossTheme.spacingS),

            // 화살표
            Center(
              child: Icon(
                Icons.arrow_downward,
                color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
                size: 20,
              ),
            ),

            const SizedBox(height: TossTheme.spacingS),
        
        // 목표 지역
        TossCard(
          onTap: () => _showAreaSelector(false),
          padding: const EdgeInsets.all(TossTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossDesignSystem.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: TossDesignSystem.warningOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: TossTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이사할 곳',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                    Text(
                      _targetArea ?? '이사할 곳을 선택하세요',
                      style: TossTheme.body2.copyWith(
                        color: _targetArea != null
                            ? (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                            : (isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
              ),
            ],
          ),
        ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '언제',
              style: TossTheme.body1.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
        const SizedBox(height: TossTheme.spacingM),
        
        Row(
          children: _periods.map((period) {
            final isSelected = _movingPeriod == period['title'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: period == _periods.last ? 0 : TossTheme.spacingS,
                ),
                child: TossCard(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _movingPeriod = period['title']!;
                    });
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: TossTheme.spacingM,
                    horizontal: TossTheme.spacingS,
                  ),
                  child: Container(
                    decoration: isSelected 
                        ? BoxDecoration(
                            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(TossTheme.radiusS),
                          )
                        : null,
                    padding: const EdgeInsets.all(TossTheme.spacingS),
                    child: Column(
                      children: [
                        Text(
                          period['title']!,
                          style: TossTheme.body3.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          period['subtitle']!,
                          style: TossTheme.caption.copyWith(
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
          ],
        );
      },
    );
  }

  Widget _buildPurposeSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '왜',
              style: TossTheme.body1.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
        const SizedBox(height: TossTheme.spacingM),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            crossAxisSpacing: TossTheme.spacingS,
            mainAxisSpacing: TossTheme.spacingS,
          ),
          itemCount: _purposes.length,
          itemBuilder: (context, index) {
            final purpose = _purposes[index];
            final isSelected = _purpose == purpose['title'];
            
            return TossCard(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _purpose = purpose['title']!;
                });
              },
              padding: const EdgeInsets.all(TossTheme.spacingS),
              child: Container(
                decoration: isSelected 
                    ? BoxDecoration(
                        color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(TossTheme.radiusS),
                        border: Border.all(
                          color: TossTheme.primaryBlue,
                          width: 1,
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      purpose['icon']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: TossTheme.spacingXS),
                    Text(
                      purpose['title']!,
                      style: TossTheme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossTheme.primaryBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
          ],
        );
      },
    );
  }

  void _showAreaSelector(bool isCurrentArea) {
    // 검색 초기화
    _searchController.clear();
    _searchResults.clear();
    _isSearching = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.6,
            builder: (context, scrollController) => Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(TossTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentArea ? '현재 거주지 선택' : '이사할 곳 선택',
                        style: TossTheme.heading3.copyWith(
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: TossTheme.spacingM),

                      // 검색 바
                      TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: '지역명을 검색하세요 (예: 강남, 성남)',
                        hintStyle: TossTheme.caption.copyWith(
                          color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setModalState(() {
                                    _searchResults.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TossTheme.radiusM),
                          borderSide: BorderSide(
                            color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TossTheme.radiusM),
                          borderSide: BorderSide(
                            color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TossTheme.radiusM),
                          borderSide: BorderSide(color: TossTheme.primaryBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: TossTheme.spacingM,
                          vertical: TossTheme.spacingM,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {});
                        _searchRegions(value).then((_) {
                          if (mounted) setModalState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // 리스트
              Expanded(
                child: _searchController.text.trim().isNotEmpty
                    ? _buildSearchResults(setModalState, scrollController, isCurrentArea, isDark)
                    : _buildPopularRegions(setModalState, scrollController, isCurrentArea, isDark),
              ),
            ],
          ),
        );
      },
      ),
    );
  }
  
  Widget _buildPopularRegions(StateSetter setModalState, ScrollController scrollController, bool isCurrentArea, bool isDark) {
    if (_popularRegions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: TossTheme.primaryBlue),
      );
    }

    // featured 지역과 일반 지역 분리
    final featured = _popularRegions.where((r) => r.isFeatured).toList();
    final others = _popularRegions.where((r) => !r.isFeatured).toList();

    return ListView(
      controller: scrollController,
      children: [
        if (featured.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
            child: Row(
              children: [
                Text('🔥', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: TossTheme.spacingXS),
                Text('인기 지역', style: TossTheme.body3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                )),
              ],
            ),
          ),
          const SizedBox(height: TossTheme.spacingS),

          ...featured.map((region) => _buildRegionTile(region, setModalState, isCurrentArea, isDark)),

          const SizedBox(height: TossTheme.spacingL),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
            child: Text('전체 지역', style: TossTheme.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            )),
          ),
          const SizedBox(height: TossTheme.spacingS),
        ],

        ...others.map((region) => _buildRegionTile(region, setModalState, isCurrentArea, isDark)),
      ],
    );
  }
  
  Widget _buildSearchResults(StateSetter setModalState, ScrollController scrollController, bool isCurrentArea, bool isDark) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: TossTheme.primaryBlue),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            ),
            const SizedBox(height: TossTheme.spacingM),
            Text('검색 결과가 없어요', style: TossTheme.body2.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            )),
            const SizedBox(height: TossTheme.spacingXS),
            Text('다른 키워드로 다시 검색해보세요', style: TossTheme.caption.copyWith(
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            )),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
          child: Text('검색 결과 ${_searchResults.length}개', style: TossTheme.body3.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          )),
        ),
        const SizedBox(height: TossTheme.spacingS),

        ..._searchResults.map((region) => _buildRegionTile(region, setModalState, isCurrentArea, isDark)),
      ],
    );
  }
  
  Widget _buildRegionTile(Region region, StateSetter setModalState, bool isCurrentArea, bool isDark) {
    return ListTile(
      leading: region.isFeatured
          ? Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star,
                color: TossTheme.primaryBlue,
                size: 16,
              ),
            )
          : null,
      title: Text(
        region.displayName,
        style: TossTheme.body2.copyWith(
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
        ),
      ),
      trailing: region.isFeatured
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TossTheme.spacingXS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '인기',
                style: TossTheme.caption.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
            ),
      onTap: () {
        // 사용 횟수 증가
        _regionService.incrementUsageCount(region.displayName);
        
        setState(() {
          if (isCurrentArea) {
            _currentArea = region.displayName;
          } else {
            _targetArea = region.displayName;
          }
        });
        Navigator.pop(context);
      },
    );
  }
}