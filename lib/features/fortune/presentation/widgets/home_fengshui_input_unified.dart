import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import 'package:flutter/services.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../services/region_service.dart';
import '../../../../core/widgets/accordion_input_section.dart';

/// 집 풍수 진단 통합 입력 페이지 - 토스 스타일
class HomeFengshuiInputUnified extends StatefulWidget {
  final Function(String address, String homeType, int floor, String doorDirection) onComplete;

  const HomeFengshuiInputUnified({
    super.key,
    required this.onComplete,
  });

  @override
  State<HomeFengshuiInputUnified> createState() => _HomeFengshuiInputUnifiedState();
}

class _HomeFengshuiInputUnifiedState extends State<HomeFengshuiInputUnified> with TickerProviderStateMixin {
  String? _address;
  String? _homeType;
  int? _floor;
  String? _doorDirection;
  bool _isLoading = false;

  late AnimationController _buttonController;

  List<Region> _popularRegions = [];
  List<Region> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingPopularRegions = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  // 아코디언 섹션
  late List<AccordionInputSection> _accordionSections;

  // 집 유형 목록
  final List<Map<String, String>> _homeTypes = [
    {'icon': '🏢', 'title': '아파트', 'subtitle': '고층 주거'},
    {'icon': '🏘️', 'title': '빌라', 'subtitle': '다세대/다가구'},
    {'icon': '🏠', 'title': '주택', 'subtitle': '단독주택'},
    {'icon': '🏙️', 'title': '오피스텔', 'subtitle': '주거용'},
  ];

  // 층수 목록 (1~50층)
  final List<int> _floors = List.generate(50, (index) => index + 1);

  // 8방위 목록
  final List<Map<String, String>> _directions = [
    {'icon': '🧭', 'title': '동', 'subtitle': '해 뜨는 곳'},
    {'icon': '🧭', 'title': '서', 'subtitle': '해 지는 곳'},
    {'icon': '🧭', 'title': '남', 'subtitle': '따뜻한 양기'},
    {'icon': '🧭', 'title': '북', 'subtitle': '차가운 음기'},
    {'icon': '🧭', 'title': '동북', 'subtitle': '귀문 방향'},
    {'icon': '🧭', 'title': '동남', 'subtitle': '생기 방향'},
    {'icon': '🧭', 'title': '서북', 'subtitle': '천문 방향'},
    {'icon': '🧭', 'title': '서남', 'subtitle': '인문 방향'},
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
        id: 'address',
        title: '지역',
        displayValue: _address,
        icon: Icons.location_on_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildAddressSelector(onComplete),
      ),
      AccordionInputSection(
        id: 'home_type',
        title: '집 유형',
        displayValue: _homeType,
        icon: Icons.home_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildHomeTypeSelector(onComplete),
      ),
      AccordionInputSection(
        id: 'floor',
        title: '층수',
        displayValue: _floor != null ? '$_floor층' : null,
        icon: Icons.layers_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildFloorSelector(onComplete),
      ),
      AccordionInputSection(
        id: 'door_direction',
        title: '대문 방향',
        displayValue: _doorDirection,
        icon: Icons.explore_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildDirectionSelector(onComplete),
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
    return _address != null &&
           _homeType != null &&
           _floor != null &&
           _doorDirection != null &&
           !_isLoading;
  }

  void _handleComplete() async {
    if (_isLoading || !_canContinue()) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
    });

    _buttonController.forward();

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      widget.onComplete(_address!, _homeType!, _floor!, _doorDirection!);
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
          completionButtonText: '🏡 집 풍수 진단하기',
        ),
        if (_canContinue() || _isLoading)
          UnifiedButton.floating(
            text: '🏡 집 풍수 진단하기',
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
          '우리 집의 기운을\n진단해보세요',
          style: DSTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : DSColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '집의 위치와 구조를 분석하여\n풍수적 길흉을 알려드려요',
          style: DSTypography.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? DSColors.surface
                : DSColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 지역 선택 빌더
  Widget _buildAddressSelector(Function(dynamic) onComplete) {
    return SizedBox(
      height: 400,
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
                ? _buildSearchResults(onComplete)
                : _buildPopularRegions(onComplete),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Function(dynamic) onComplete) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: DSTypography.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? DSColors.textSecondary
                : DSColors.textSecondary,
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
              _address = region.displayName;
              _accordionSections[0] = AccordionInputSection(
                id: 'address',
                title: '지역',
                displayValue: _address,
                icon: Icons.location_on_outlined,
                inputWidgetBuilder: (context, onComplete) => _buildAddressSelector(onComplete),
              );
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

  Widget _buildPopularRegions(Function(dynamic) onComplete) {
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
          style: DSTypography.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? DSColors.textSecondary
                : DSColors.textSecondary,
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
          leading: const Icon(Icons.star, color: DSColors.accent),
          title: Text(region.displayName),
          onTap: () {
            setState(() {
              _address = region.displayName;
              _accordionSections[0] = AccordionInputSection(
                id: 'address',
                title: '지역',
                displayValue: _address,
                icon: Icons.location_on_outlined,
                inputWidgetBuilder: (context, onComplete) => _buildAddressSelector(onComplete),
              );
            });
            HapticFeedback.lightImpact();
            onComplete(region.displayName);
          },
        );
      },
    );
  }

  // 집 유형 선택 빌더
  Widget _buildHomeTypeSelector(Function(dynamic) onComplete) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _homeTypes.length,
          itemBuilder: (context, index) {
            final homeType = _homeTypes[index];
            final isSelected = _homeType == homeType['title'];
            return AppCard(
              onTap: () {
                setState(() {
                  _homeType = homeType['title']!;
                  _accordionSections[1] = AccordionInputSection(
                    id: 'home_type',
                    title: '집 유형',
                    displayValue: _homeType,
                    icon: Icons.home_outlined,
                    inputWidgetBuilder: (context, onComplete) => _buildHomeTypeSelector(onComplete),
                  );
                });
                HapticFeedback.lightImpact();
                onComplete(homeType['title']!);
              },
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    homeType['icon']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    homeType['title']!,
                    style: DSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? DSColors.accent : null,
                    ),
                  ),
                  Text(
                    homeType['subtitle']!,
                    style: DSTypography.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DSColors.textSecondary
                          : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 층수 선택 빌더
  Widget _buildFloorSelector(Function(dynamic) onComplete) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '층수를 선택해주세요',
              style: DSTypography.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? DSColors.textSecondary
                    : DSColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _floors.length,
              itemBuilder: (context, index) {
                final floor = _floors[index];
                final isSelected = _floor == floor;
                return AppCard(
                  onTap: () {
                    setState(() {
                      _floor = floor;
                      _accordionSections[2] = AccordionInputSection(
                        id: 'floor',
                        title: '층수',
                        displayValue: '$_floor층',
                        icon: Icons.layers_outlined,
                        inputWidgetBuilder: (context, onComplete) => _buildFloorSelector(onComplete),
                      );
                    });
                    HapticFeedback.lightImpact();
                    onComplete(floor);
                  },
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      '$floor',
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? DSColors.accent : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 대문 방향 선택 빌더
  Widget _buildDirectionSelector(Function(dynamic) onComplete) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '대문이 향하는 방향을 선택해주세요',
              style: DSTypography.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? DSColors.textSecondary
                    : DSColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // 방위 컴파스 스타일 레이아웃
            _buildCompassLayout(onComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassLayout(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.textPrimary : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 북쪽 행
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton('서북', onComplete),
              const SizedBox(width: 8),
              _buildDirectionButton('북', onComplete, isMain: true),
              const SizedBox(width: 8),
              _buildDirectionButton('동북', onComplete),
            ],
          ),
          const SizedBox(height: 8),
          // 동서 행
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton('서', onComplete, isMain: true),
              const SizedBox(width: 60), // 중앙 공간
              _buildDirectionButton('동', onComplete, isMain: true),
            ],
          ),
          const SizedBox(height: 8),
          // 남쪽 행
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton('서남', onComplete),
              const SizedBox(width: 8),
              _buildDirectionButton('남', onComplete, isMain: true),
              const SizedBox(width: 8),
              _buildDirectionButton('동남', onComplete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(String direction, Function(dynamic) onComplete, {bool isMain = false}) {
    final isSelected = _doorDirection == direction;
    final directionData = _directions.firstWhere(
      (d) => d['title'] == direction,
      orElse: () => {'icon': '🧭', 'title': direction, 'subtitle': ''},
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _doorDirection = direction;
          _accordionSections[3] = AccordionInputSection(
            id: 'door_direction',
            title: '대문 방향',
            displayValue: _doorDirection,
            icon: Icons.explore_outlined,
            inputWidgetBuilder: (context, onComplete) => _buildDirectionSelector(onComplete),
          );
        });
        HapticFeedback.lightImpact();
        onComplete(direction);
      },
      child: Container(
        width: isMain ? 80 : 70,
        height: isMain ? 80 : 70,
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.accent
              : Theme.of(context).brightness == Brightness.dark
                  ? DSColors.textSecondary
                  : Colors.white,
          borderRadius: BorderRadius.circular(isMain ? 40 : 12),
          border: Border.all(
            color: isSelected
                ? DSColors.accent
                : DSColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DSColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              direction,
              style: DSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : DSColors.textPrimary,
              ),
            ),
            if (isMain) ...[
              const SizedBox(height: 2),
              Text(
                directionData['subtitle']!,
                style: DSTypography.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : Theme.of(context).brightness == Brightness.dark
                          ? DSColors.textSecondary
                          : DSColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
