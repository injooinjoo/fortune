import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import 'package:flutter/services.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../services/region_service.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';

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
  bool _isLoadingPopularRegions = true; // 인기 지역 로딩 상태
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  // 아코디언 섹션
  late List<AccordionInputSection> _accordionSections;

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
    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      AccordionInputSection(
        id: 'current_area',
        title: '현재 지역',
        displayValue: _currentArea,
        icon: Icons.home_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(true, onComplete),
      ),
      AccordionInputSection(
        id: 'target_area',
        title: '이사갈 곳',
        displayValue: _targetArea,
        icon: Icons.location_on_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(false, onComplete),
      ),
      AccordionInputSection(
        id: 'period',
        title: '언제',
        displayValue: _movingPeriod,
        icon: Icons.calendar_today,
        inputWidgetBuilder: (context, onComplete) => _buildPeriodSelector(onComplete),
      ),
      AccordionInputSection(
        id: 'purpose',
        title: '왜',
        displayValue: _purpose,
        icon: Icons.question_mark_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildPurposeSelector(onComplete),
      ),
    ];
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPopularRegions() async {
    setState(() {
      _isLoadingPopularRegions = true;
    });

    try {
      final regions = await _regionService.getPopularRegions();
      if (mounted) {
        setState(() {
          _popularRegions = regions;
          _isLoadingPopularRegions = false;
        });
      }
    } catch (e) {
      // 에러 발생 시에도 로딩 종료
      if (mounted) {
        setState(() {
          _isLoadingPopularRegions = false;
        });
      }
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
    // 🔒 중복 호출 방지: 이미 로딩 중이면 즉시 리턴
    if (_isLoading || !_canContinue()) return;

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
    return Stack(
      children: [
        AccordionInputForm(
          header: _buildTitleSection(),
          sections: _accordionSections,
          onAllCompleted: null,
          completionButtonText: '🏠 이사운 보기',
        ),
        if (_canContinue() || _isLoading)
          UnifiedButton.floating(
            text: '🏠 이사운 보기',
            onPressed: _canContinue() && !_isLoading ? _handleComplete : null,
            isEnabled: !_isLoading,
            isLoading: _isLoading,
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새로운 보금자리의\n운을 확인해보세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '이사할 지역과 시기를 입력하면\n방위와 타이밍을 고려한 운세를 알려드려요',
          style: TypographyUnified.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 아코디언용 지역 선택 빌더
  Widget _buildAreaSelector(bool isCurrentArea, Function(dynamic) onComplete) {
    return SizedBox(
      height: 400, // 고정 높이 지정
      child: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '지역 검색 (예: 서울 강남구)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchRegions,
            ),
          ),
          // 검색 결과 또는 인기 지역
          Expanded(
            child: _isSearching || _searchResults.isNotEmpty
                ? _buildSearchResults(isCurrentArea, onComplete)
                : _buildPopularRegionsForAccordion(isCurrentArea, onComplete),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isCurrentArea, Function(dynamic) onComplete) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TypographyUnified.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final region = _searchResults[index];
        return ListTile(
          title: Text(region.displayName),
          onTap: () {
            setState(() {
              if (isCurrentArea) {
                _currentArea = region.displayName;
                // 아코디언 displayValue 업데이트
                _accordionSections[0] = AccordionInputSection(
                  id: 'current_area',
                  title: '현재 지역',
                  displayValue: _currentArea,
                  icon: Icons.home_outlined,
                  inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(true, onComplete),
                );
              } else {
                _targetArea = region.displayName;
                // 아코디언 displayValue 업데이트
                _accordionSections[1] = AccordionInputSection(
                  id: 'target_area',
                  title: '이사갈 곳',
                  displayValue: _targetArea,
                  icon: Icons.location_on_outlined,
                  inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(false, onComplete),
                );
              }
              _searchController.clear();
              _searchResults.clear();
            });
            HapticFeedback.lightImpact();
            onComplete(region.displayName);
          },
        );
      },
    );
  }

  Widget _buildPopularRegionsForAccordion(bool isCurrentArea, Function(dynamic) onComplete) {
    if (_isLoadingPopularRegions) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('인기 지역 불러오는 중...'),
          ],
        ),
      );
    }

    if (_popularRegions.isEmpty) {
      return Center(
        child: Text(
          '인기 지역을 불러올 수 없습니다',
          style: TypographyUnified.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.textSecondaryDark
                : TossDesignSystem.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _popularRegions.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final region = _popularRegions[index];
        return ListTile(
          leading: const Icon(Icons.star, color: TossTheme.primaryBlue),
          title: Text(region.displayName),
          onTap: () {
            setState(() {
              if (isCurrentArea) {
                _currentArea = region.displayName;
                _accordionSections[0] = AccordionInputSection(
                  id: 'current_area',
                  title: '현재 지역',
                  displayValue: _currentArea,
                  icon: Icons.home_outlined,
                  inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(true, onComplete),
                );
              } else {
                _targetArea = region.displayName;
                _accordionSections[1] = AccordionInputSection(
                  id: 'target_area',
                  title: '이사갈 곳',
                  displayValue: _targetArea,
                  icon: Icons.location_on_outlined,
                  inputWidgetBuilder: (context, onComplete) => _buildAreaSelector(false, onComplete),
                );
              }
            });
            HapticFeedback.lightImpact();
            onComplete(region.displayName);
          },
        );
      },
    );
  }

  // 아코디언용 시기 선택 빌더
  Widget _buildPeriodSelector(Function(dynamic) onComplete) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _periods.map((period) {
          final isSelected = _movingPeriod == period['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TossCard(
              onTap: () {
                setState(() {
                  _movingPeriod = period['title']!;
                  _accordionSections[2] = AccordionInputSection(
                    id: 'period',
                    title: '언제',
                    displayValue: _movingPeriod,
                    icon: Icons.calendar_today,
                    inputWidgetBuilder: (context, onComplete) => _buildPeriodSelector(onComplete),
                  );
                });
                HapticFeedback.lightImpact();
                onComplete(period['title']!);
              },
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? TossTheme.primaryBlue : TossDesignSystem.gray400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period['title']!,
                          style: TypographyUnified.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? TossTheme.primaryBlue : null,
                          ),
                        ),
                        Text(
                          period['subtitle']!,
                          style: TypographyUnified.bodySmall.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 아코디언용 목적 선택 빌더
  Widget _buildPurposeSelector(Function(dynamic) onComplete) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9, // 높이를 조금 더 늘림
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _purposes.length,
        itemBuilder: (context, index) {
          final purpose = _purposes[index];
          final isSelected = _purpose == purpose['title'];
          return TossCard(
            onTap: () {
              setState(() {
                _purpose = purpose['title']!;
                _accordionSections[3] = AccordionInputSection(
                  id: 'purpose',
                  title: '왜',
                  displayValue: _purpose,
                  icon: Icons.question_mark_rounded,
                  inputWidgetBuilder: (context, onComplete) => _buildPurposeSelector(onComplete),
                );
              });
              HapticFeedback.lightImpact();
              onComplete(purpose['title']!);
            },
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  purpose['icon']!,
                  style: TypographyUnified.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  purpose['title']!,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? TossTheme.primaryBlue : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }
}
