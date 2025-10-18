import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import '../../../../core/theme/typography_unified.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final LatLng? initialLocation;
  final String? initialAddress;
  final bool showDirectionOverlay;
  final List<String>? auspiciousDirections;
  
  const MapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.initialAddress,
    this.showDirectionOverlay = false,
    this.auspiciousDirections});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? const LatLng(37.5665, 126.9780); // 서울 중심
    _selectedAddress = widget.initialAddress ?? '';
    
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
}
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
        _showSnackBar('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.');
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      
      _mapController.move(currentLocation, 15);
      await _updateLocationAndAddress(currentLocation);
    } catch (e) {
      _showSnackBar('현재 위치를 가져올 수 없습니다');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.move(newLocation, 15);
        await _updateLocationAndAddress(newLocation);
      } else {
        _showSnackBar('주소를 찾을 수 없습니다');
}
    } catch (e) {
      _showSnackBar('주소 검색 중 오류가 발생했습니다');
}
    
    setState(() => _isLoading = false);
}

  Future<void> _updateLocationAndAddress(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // 광역시/도 단위로 간소화된 주소 생성
        String simplifiedAddress = _getSimplifiedKoreanAddress(place);
        
        setState(() {
          _selectedAddress = simplifiedAddress;
          _searchController.text = _selectedAddress;
        });
        
        widget.onLocationSelected(location, _selectedAddress);
      }
    } catch (e) {
      debugPrint('주소 변환 실패: $e');
    }
  }
  
  /// 영어 지역명을 그대로 반환 (GPT가 처리하도록)
  String _getSimplifiedKoreanAddress(Placemark place) {
    // GPT나 Edge Function에서 지역명을 처리하도록
    // 여기서는 간단한 포맷팅만 수행
    String address = '';
    
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      address += place.administrativeArea!;
      
      if (place.locality != null && place.locality!.isNotEmpty) {
        address += ' ${place.locality!}';
      }
    } else if (place.locality != null && place.locality!.isNotEmpty) {
      address = place.locality!;
    }
    
    return address.trim().isEmpty ? 'Seoul' : address.trim();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)));
  }

  Widget _buildDirectionOverlay() {
    if (!widget.showDirectionOverlay || widget.auspiciousDirections == null) {
      return const SizedBox.shrink();
}
    
    final directions = {
      '동쪽': {'angle': 0.0, 'color': TossDesignSystem.primaryBlue},
      '서쪽': {'angle': 180.0, 'color': TossDesignSystem.warningOrange},
      '남쪽': {'angle': 90.0, 'color': TossDesignSystem.errorRed},
      '북쪽': {'angle': 270.0, 'color': TossDesignSystem.purple}};
    
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: DirectionOverlayPainter(
            auspiciousDirections: widget.auspiciousDirections!,
            directions: directions,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 바
        Container(
          padding: AppSpacing.paddingAll16,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '주소를 입력하세요',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium,
                    ),
                    filled: true,
                    fillColor: TossDesignSystem.gray400.withValues(alpha:0.9),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
              const SizedBox(width: AppSpacing.spacing2),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _isLoading ? null : _getCurrentLocation,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: TossDesignSystem.white,
                ),
              ),
            ],
          ),
        ),

        // 지도
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation!,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) =>
                      _updateLocationAndAddress(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fortune.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_selectedLocation != null)
                        Marker(
                          point: _selectedLocation!,
                          width: 80,
                          height: 80,
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
              _buildDirectionOverlay(),
              if (_isLoading)
                Container(
                  color: TossDesignSystem.black.withValues(alpha: 0.26),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),

        // 선택된 주소 표시
        if (_selectedAddress.isNotEmpty)
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray400.withValues(alpha:0.9),
              border: Border(
                top: BorderSide(
                  color: TossDesignSystem.gray400.withValues(alpha:0.5),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선택된 주소',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.spacing1),
                Text(
                  _selectedAddress,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DirectionOverlayPainter extends CustomPainter {
  final List<String> auspiciousDirections;
  final Map<String, Map<String, dynamic>> directions;
  
  DirectionOverlayPainter({
    required this.auspiciousDirections,
    required this.directions});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 3 : size.height / 3;
    
    for (var entry in directions.entries) {
      final direction = entry.key;
      final data = entry.value;
      final angle = data['angle'] as double;
      final color = data['color'] as Color;
      final isAuspicious = auspiciousDirections.contains(direction);
      
      final paint = Paint()
        ..color = isAuspicious 
            ? color.withValues(alpha:0.4) 
            : TossDesignSystem.gray400.withValues(alpha:0.2)
        ..style = PaintingStyle.fill;
      
      // 방향별 섹터 그리기
      final path = ui.Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        (angle - 45) * (3.14159 / 180),
        90 * (3.14159 / 180),
        false
      );
      path.close();
      
      canvas.drawPath(path, paint);
      
      // 방향 텍스트
      final textPainter = TextPainter(
        text: TextSpan(
          text: direction,
          style: TypographyUnified.bodySmall.copyWith(
            color: TossDesignSystem.black,
            fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
      textPainter.layout();
      
      final textAngle = angle * (3.14159 / 180);
      final textOffset = Offset(
        center.dx + radius * 0.7 * math.cos(textAngle),
        center.dy + radius * 0.7 * math.sin(textAngle) - textPainter.height / 2
      );
      
      textPainter.paint(canvas, textOffset);
}
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}