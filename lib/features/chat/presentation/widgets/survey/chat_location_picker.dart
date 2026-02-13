import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../services/region_service.dart';
import '../../../domain/models/location_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// 채팅 설문용 지역 선택 위젯
/// GPS, 텍스트 검색, 드롭다운, 지도 탭, 인기 지역 칩 지원
class ChatLocationPicker extends StatefulWidget {
  final String questionTitle;
  final void Function(LocationData location) onLocationSelected;
  final LocationData? initialLocation;
  final bool showMap;

  const ChatLocationPicker({
    super.key,
    required this.questionTitle,
    required this.onLocationSelected,
    this.initialLocation,
    this.showMap = false,
  });

  @override
  State<ChatLocationPicker> createState() => _ChatLocationPickerState();
}

class _ChatLocationPickerState extends State<ChatLocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  final RegionService _regionService = RegionService();

  bool _isLoading = false;
  bool _showMapView = false;
  LocationData? _selectedLocation;
  List<Region> _searchResults = [];

  // 드롭다운 선택
  String? _selectedSido;
  String? _selectedSigungu;
  List<String> _sigunguList = [];

  // 지도 컨트롤러
  MapController? _mapController;
  LatLng _mapCenter = const LatLng(37.5665, 126.9780); // 서울 기본값

  // 인기 지역 목록
  static const List<Map<String, String>> _popularRegions = [
    {'sido': '서울특별시', 'sigungu': '강남구', 'display': '서울 강남'},
    {'sido': '서울특별시', 'sigungu': '송파구', 'display': '서울 송파'},
    {'sido': '경기도', 'sigungu': '성남시', 'display': '경기 성남'},
    {'sido': '경기도', 'sigungu': '수원시', 'display': '경기 수원'},
    {'sido': '부산광역시', 'sigungu': '해운대구', 'display': '부산 해운대'},
    {'sido': '인천광역시', 'sigungu': '연수구', 'display': '인천 연수'},
  ];

  // 시/도 목록
  static const List<String> _sidoList = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  // 시/군/구 매핑 (간략화)
  static const Map<String, List<String>> _sigunguMap = {
    '서울특별시': [
      '강남구',
      '강동구',
      '강북구',
      '강서구',
      '관악구',
      '광진구',
      '구로구',
      '금천구',
      '노원구',
      '도봉구',
      '동대문구',
      '동작구',
      '마포구',
      '서대문구',
      '서초구',
      '성동구',
      '성북구',
      '송파구',
      '양천구',
      '영등포구',
      '용산구',
      '은평구',
      '종로구',
      '중구',
      '중랑구'
    ],
    '부산광역시': [
      '강서구',
      '금정구',
      '남구',
      '동구',
      '동래구',
      '부산진구',
      '북구',
      '사상구',
      '사하구',
      '서구',
      '수영구',
      '연제구',
      '영도구',
      '중구',
      '해운대구',
      '기장군'
    ],
    '인천광역시': [
      '계양구',
      '남동구',
      '동구',
      '미추홀구',
      '부평구',
      '서구',
      '연수구',
      '중구',
      '강화군',
      '옹진군'
    ],
    '경기도': [
      '수원시',
      '성남시',
      '고양시',
      '용인시',
      '부천시',
      '안산시',
      '안양시',
      '남양주시',
      '화성시',
      '평택시',
      '의정부시',
      '시흥시',
      '파주시',
      '광명시',
      '김포시',
      '군포시',
      '광주시',
      '이천시',
      '양주시',
      '오산시',
      '구리시',
      '안성시',
      '포천시',
      '의왕시',
      '하남시',
      '여주시',
      '양평군',
      '동두천시',
      '과천시',
      '가평군',
      '연천군'
    ],
    '대구광역시': ['남구', '달서구', '동구', '북구', '서구', '수성구', '중구', '달성군'],
    '광주광역시': ['광산구', '남구', '동구', '북구', '서구'],
    '대전광역시': ['대덕구', '동구', '서구', '유성구', '중구'],
    '울산광역시': ['남구', '동구', '북구', '중구', '울주군'],
    '세종특별자치시': ['세종시'],
    '강원도': [
      '춘천시',
      '원주시',
      '강릉시',
      '동해시',
      '태백시',
      '속초시',
      '삼척시',
      '홍천군',
      '횡성군',
      '영월군',
      '평창군',
      '정선군',
      '철원군',
      '화천군',
      '양구군',
      '인제군',
      '고성군',
      '양양군'
    ],
    '충청북도': [
      '청주시',
      '충주시',
      '제천시',
      '보은군',
      '옥천군',
      '영동군',
      '증평군',
      '진천군',
      '괴산군',
      '음성군',
      '단양군'
    ],
    '충청남도': [
      '천안시',
      '공주시',
      '보령시',
      '아산시',
      '서산시',
      '논산시',
      '계룡시',
      '당진시',
      '금산군',
      '부여군',
      '서천군',
      '청양군',
      '홍성군',
      '예산군',
      '태안군'
    ],
    '전라북도': [
      '전주시',
      '군산시',
      '익산시',
      '정읍시',
      '남원시',
      '김제시',
      '완주군',
      '진안군',
      '무주군',
      '장수군',
      '임실군',
      '순창군',
      '고창군',
      '부안군'
    ],
    '전라남도': [
      '목포시',
      '여수시',
      '순천시',
      '나주시',
      '광양시',
      '담양군',
      '곡성군',
      '구례군',
      '고흥군',
      '보성군',
      '화순군',
      '장흥군',
      '강진군',
      '해남군',
      '영암군',
      '무안군',
      '함평군',
      '영광군',
      '장성군',
      '완도군',
      '진도군',
      '신안군'
    ],
    '경상북도': [
      '포항시',
      '경주시',
      '김천시',
      '안동시',
      '구미시',
      '영주시',
      '영천시',
      '상주시',
      '문경시',
      '경산시',
      '군위군',
      '의성군',
      '청송군',
      '영양군',
      '영덕군',
      '청도군',
      '고령군',
      '성주군',
      '칠곡군',
      '예천군',
      '봉화군',
      '울진군',
      '울릉군'
    ],
    '경상남도': [
      '창원시',
      '진주시',
      '통영시',
      '사천시',
      '김해시',
      '밀양시',
      '거제시',
      '양산시',
      '의령군',
      '함안군',
      '창녕군',
      '고성군',
      '남해군',
      '하동군',
      '산청군',
      '함양군',
      '거창군',
      '합천군'
    ],
    '제주특별자치도': ['제주시', '서귀포시'],
  };

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (widget.showMap) {
      _mapController = MapController();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// GPS로 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Geolocator 직접 사용
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('위치 서비스를 활성화해주세요');
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('위치 권한이 거부되었습니다');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('위치 권한이 영구 거부되었습니다. 설정에서 변경해주세요.');
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 역지오코딩으로 주소 변환
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final location = LocationData.fromGPS(
          displayName: _formatAddress(place),
          sido: place.administrativeArea,
          sigungu: place.locality ?? place.subAdministrativeArea,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        _selectLocation(location);
      }
    } catch (e) {
      debugPrint('GPS 위치 오류: $e');
      _showSnackBar('현재 위치를 가져오는데 실패했습니다');
    }

    setState(() => _isLoading = false);
  }

  /// 주소 검색
  Future<void> _searchLocation(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _regionService.searchRegions(query);
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint('검색 오류: $e');
    }

    setState(() => _isLoading = false);
  }

  /// 검색 결과 선택
  void _selectSearchResult(Region region) {
    final location = LocationData.fromSearch(
      displayName: region.displayName,
      sido: region.sido,
      sigungu: region.sigungu,
    );
    _selectLocation(location);
    _searchController.clear();
    setState(() => _searchResults = []);
  }

  /// 드롭다운에서 시/도 선택
  void _onSidoSelected(String? sido) {
    setState(() {
      _selectedSido = sido;
      _selectedSigungu = null;
      _sigunguList = sido != null ? (_sigunguMap[sido] ?? []) : [];
    });
  }

  /// 드롭다운에서 시/군/구 선택
  void _onSigunguSelected(String? sigungu) {
    if (_selectedSido != null && sigungu != null) {
      final location = LocationData.fromDropdown(
        sido: _selectedSido!,
        sigungu: sigungu,
      );
      _selectLocation(location);
    }
  }

  /// 인기 지역 선택
  void _selectPopularRegion(Map<String, String> region) {
    final location = LocationData(
      displayName: region['display'] ?? '',
      sido: region['sido'],
      sigungu: region['sigungu'],
      inputMethod: LocationInputMethod.quickSelect,
    );
    _selectLocation(location);
  }

  /// 지도에서 위치 선택
  Future<void> _onMapTap(LatLng position) async {
    setState(() => _isLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final location = LocationData.fromMap(
          displayName: _formatAddress(place),
          sido: place.administrativeArea,
          sigungu: place.locality ?? place.subAdministrativeArea,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        _selectLocation(location);
      }
    } catch (e) {
      debugPrint('지도 위치 변환 오류: $e');
      _showSnackBar('주소를 가져오는데 실패했습니다');
    }

    setState(() => _isLoading = false);
  }

  /// 위치 선택 완료
  void _selectLocation(LocationData location) {
    setState(() {
      _selectedLocation = location;
      if (location.hasCoordinates && _mapController != null) {
        _mapCenter = LatLng(location.latitude!, location.longitude!);
        _mapController!.move(_mapCenter, 13);
      }
    });
    DSHaptics.light();
    widget.onLocationSelected(location);
  }

  /// 주소 포맷팅 (시/도 + 구/군 + 동)
  String _formatAddress(Placemark place) {
    final parts = <String>[];
    final adminArea = place.administrativeArea;

    // 1. 시/도
    if (adminArea != null && adminArea.isNotEmpty) {
      parts.add(adminArea);
    }

    // 2. 구/군 (locality가 administrativeArea와 동일하면 스킵)
    if (place.locality != null &&
        place.locality!.isNotEmpty &&
        place.locality != adminArea) {
      parts.add(place.locality!);
    } else if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty &&
        place.subAdministrativeArea != adminArea) {
      parts.add(place.subAdministrativeArea!);
    }

    // 3. 동/읍/면 (subLocality)
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }

    return parts.join(' ');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 위치 표시
          if (_selectedLocation != null)
            _buildSelectedLocationBadge(colors, typography),

          const SizedBox(height: DSSpacing.sm),

          // GPS 버튼
          _buildGPSButton(colors, typography),

          const SizedBox(height: DSSpacing.sm),

          // 검색창
          _buildSearchField(colors),

          // 검색 결과
          if (_searchResults.isNotEmpty)
            _buildSearchResults(colors, typography),

          const SizedBox(height: DSSpacing.sm),

          // 드롭다운 선택
          _buildDropdowns(colors),

          const SizedBox(height: DSSpacing.sm),

          // 인기 지역 칩
          _buildPopularRegionChips(colors, typography),

          // 지도 보기 토글
          if (widget.showMap) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildMapToggle(colors, typography),
            if (_showMapView) _buildMapView(),
          ],

          // 로딩 표시
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(DSSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedLocationBadge(dynamic colors, dynamic typography) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.textPrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 16, color: colors.textSecondary),
          const SizedBox(width: DSSpacing.xs),
          Text(
            _selectedLocation!.displayName,
            style: typography.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          GestureDetector(
            onTap: () {
              setState(() => _selectedLocation = null);
            },
            child: Icon(Icons.close, size: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSButton(dynamic colors, dynamic typography) {
    return InkWell(
      onTap: _isLoading ? null : _getCurrentLocation,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.my_location, size: 20, color: colors.accent),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '📍 현재 위치 사용하기',
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(dynamic colors) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '🔍 지역 검색 (예: 강남구, 수원시)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        filled: true,
        fillColor: colors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
      ),
      onChanged: _searchLocation,
    );
  }

  Widget _buildSearchResults(dynamic colors, dynamic typography) {
    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.xs),
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final region = _searchResults[index];
          return ListTile(
            dense: true,
            leading: Icon(Icons.location_on_outlined,
                size: 18, color: colors.textSecondary),
            title: Text(
              region.displayName,
              style: typography.bodyMedium,
            ),
            onTap: () => _selectSearchResult(region),
          );
        },
      ),
    );
  }

  Widget _buildDropdowns(dynamic colors) {
    return Row(
      children: [
        // 시/도 드롭다운
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border:
                  Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSido,
                hint: const Text('시/도'),
                isExpanded: true,
                items: _sidoList.map((sido) {
                  return DropdownMenuItem(
                    value: sido,
                    child: Text(
                      sido
                          .replaceAll('특별시', '')
                          .replaceAll('광역시', '')
                          .replaceAll('특별자치시', '')
                          .replaceAll('특별자치도', '')
                          .replaceAll('도', ''),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _onSidoSelected,
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        // 구/군 드롭다운
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border:
                  Border.all(color: colors.textPrimary.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSigungu,
                hint: const Text('구/군'),
                isExpanded: true,
                items: _sigunguList.map((sigungu) {
                  return DropdownMenuItem(
                    value: sigungu,
                    child: Text(sigungu, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _sigunguList.isEmpty ? null : _onSigunguSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularRegionChips(dynamic colors, dynamic typography) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인기 지역',
          style: typography.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Wrap(
          spacing: DSSpacing.xs,
          runSpacing: DSSpacing.xs,
          children: _popularRegions.map((region) {
            final isSelected =
                _selectedLocation?.displayName == region['display'];
            return InkWell(
              onTap: () => _selectPopularRegion(region),
              borderRadius: BorderRadius.circular(DSRadius.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.textPrimary.withValues(alpha: 0.1)
                      : colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  border: Border.all(
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  region['display'] ?? '',
                  style: typography.labelMedium.copyWith(
                    color: isSelected ? colors.textPrimary : colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMapToggle(dynamic colors, dynamic typography) {
    return InkWell(
      onTap: () {
        setState(() => _showMapView = !_showMapView);
        if (_showMapView && _mapController == null) {
          _mapController = MapController();
        }
      },
      child: Row(
        children: [
          Icon(
            _showMapView ? Icons.keyboard_arrow_up : Icons.map_outlined,
            size: 20,
            color: colors.textSecondary,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            _showMapView ? '지도 접기' : '지도에서 선택',
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: DSSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _mapCenter,
          initialZoom: 11,
          onTap: (tapPosition, point) => _onMapTap(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.beyond.fortune',
          ),
          if (_selectedLocation?.hasCoordinates == true)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    _selectedLocation!.latitude!,
                    _selectedLocation!.longitude!,
                  ),
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
