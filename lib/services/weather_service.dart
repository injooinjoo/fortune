import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import '../core/services/location_manager.dart';
import '../core/constants/location_mappings.dart';

/// 날씨 정보를 가져오는 서비스
class WeatherService {
  // OpenWeatherMap API Key
  static const String _apiKey = '378423f7fe3cf4848a8b5573845302b3';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// 현재 위치의 날씨 정보 가져오기 (캐싱 적용)
  static Future<WeatherInfo> getCurrentWeather() async {
    try {
      // 1. LocationManager로부터 현재 위치 가져오기
      final location = await LocationManager.instance.getCurrentLocation();
      developer.log('🌤️ WeatherService: ${location.cityName} 날씨 조회');

      // 2. 좌표가 있으면 좌표로 조회, 없으면 도시명으로 조회
      if (location.latitude != null && location.longitude != null) {
        return await _getWeatherByCoordinates(
          location.latitude!,
          location.longitude!,
          location.cityName,
        );
      } else {
        // 한글 도시명 → 영문 도시명 변환
        final englishName = LocationMappings.toEnglish(location.cityName);
        return await _getWeatherByCity(englishName, location.cityName);
      }
    } catch (e) {
      developer.log('❌ WeatherService 에러: $e');
      return WeatherInfo.defaultWeather();
    }
  }

  /// 좌표로 날씨 가져오기
  static Future<WeatherInfo> _getWeatherByCoordinates(
    double lat,
    double lon,
    String cityName,
  ) async {
    try {
      // 1. 캐시 확인
      final cachedWeather = await _getCachedWeather(cityName);
      if (cachedWeather != null && _isCacheValid(cachedWeather['timestamp'])) {
        developer.log('📋 캐시된 날씨 사용: $cityName');
        return WeatherInfo.fromJson(cachedWeather['data'], cityName);
      }

      // 2. API 호출
      developer.log('🌤️ API에서 날씨 가져오기: $cityName (좌표)');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _cacheWeather(cityName, data);
        return WeatherInfo.fromJson(data, cityName);
      }
    } catch (e) {
      developer.log('❌ 좌표 날씨 조회 실패: $e');
    }
    return WeatherInfo.defaultWeather(cityName: cityName);
  }

  /// 도시 이름으로 날씨 가져오기 (캐싱 적용)
  static Future<WeatherInfo> _getWeatherByCity(String city, String koreanName) async {
    try {
      // 1. 캐시 확인
      final cachedWeather = await _getCachedWeather(koreanName);
      if (cachedWeather != null && _isCacheValid(cachedWeather['timestamp'])) {
        developer.log('📋 캐시된 날씨 사용: $koreanName');
        return WeatherInfo.fromJson(cachedWeather['data'], koreanName);
      }

      // 2. 캐시가 없으면 API 호출
      developer.log('🌤️ API에서 날씨 가져오기: $city');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 3. 캐시에 저장
        await _cacheWeather(koreanName, data);
        return WeatherInfo.fromJson(data, koreanName);
      }
    } catch (e) {
      developer.log('❌ 도시 날씨 조회 실패: $e');
    }
    return WeatherInfo.defaultWeather(cityName: koreanName);
  }
  
  /// 캐시된 날씨 정보 가져오기
  static Future<Map<String, dynamic>?> _getCachedWeather(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'weather_cache_$cityName';
      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        return json.decode(cachedString);
      }
    } catch (e) {
      debugPrint('캐시 읽기 오류: $e');
    }
    return null;
  }
  
  /// 날씨 정보 캐싱
  static Future<void> _cacheWeather(String cityName, Map<String, dynamic> weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'weather_cache_$cityName';
      final cacheData = {
        'data': weatherData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(cacheKey, json.encode(cacheData));
      debugPrint('✅ 날씨 정보 캐싱 완료: $cityName');
    } catch (e) {
      debugPrint('캐시 저장 오류: $e');
    }
  }
  
  /// 캐시 유효성 검증 (30분)
  static bool _isCacheValid(dynamic timestamp) {
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    
    // 30분 이내면 유효
    return difference.inMinutes < 30;
  }
}

/// 날씨 정보 모델
class WeatherInfo {
  final String condition;       // 날씨 상태 (맑음, 흐림, 비, 눈 등)
  final String description;     // 상세 설명
  final double temperature;     // 현재 온도
  final double feelsLike;       // 체감 온도
  final double humidity;        // 습도
  final double windSpeed;       // 풍속
  final String cityName;        // 도시명
  final DateTime sunrise;       // 일출 시간
  final DateTime sunset;        // 일몰 시간
  final String icon;           // 날씨 아이콘 코드

  WeatherInfo({
    required this.condition,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
    required this.sunrise,
    required this.sunset,
    required this.icon,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json, [String? cityNameOverride]) {
    // cityNameOverride가 제공되면 사용 (LocationManager로부터 받은 정확한 지역명)
    final cityName = cityNameOverride ?? LocationMappings.toKorean(json['name'] ?? 'Seoul');

    return WeatherInfo(
      condition: json['weather'][0]['main'] ?? '맑음',
      description: json['weather'][0]['description'] ?? '맑은 날씨',
      temperature: (json['main']['temp'] ?? 20).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 20).toDouble(),
      humidity: (json['main']['humidity'] ?? 50).toDouble(),
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      cityName: cityName,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] ?? 0) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] ?? 0) * 1000,
      ),
      icon: json['weather'][0]['icon'] ?? '01d',
    );
  }

  /// 기본 날씨 정보 (API 실패 시)
  factory WeatherInfo.defaultWeather({String? cityName}) {
    return WeatherInfo(
      condition: 'Clear',
      description: '맑은 날씨',
      temperature: 20.0,
      feelsLike: 20.0,
      humidity: 50.0,
      windSpeed: 2.0,
      cityName: cityName ?? '강남구',
      sunrise: DateTime.now().copyWith(hour: 6, minute: 0),
      sunset: DateTime.now().copyWith(hour: 18, minute: 0),
      icon: '01d',
    );
  }

  /// 날씨를 한국어 감성 표현으로 변환
  String get emotionalDescription {
    if (condition == 'Clear') {
      if (temperature > 25) return '화창하고 따뜻한';
      if (temperature > 15) return '맑고 상쾌한';
      return '쌀쌀하지만 맑은';
    } else if (condition == 'Clouds') {
      if (description.contains('구름조금')) return '구름이 살짝 낀';
      return '잔잔한 구름의';
    } else if (condition == 'Rain') {
      if (windSpeed > 5) return '비바람이 부는';
      return '촉촉한 비가 내리는';
    } else if (condition == 'Snow') {
      return '포근한 눈이 내리는';
    } else if (condition == 'Mist' || condition == 'Fog') {
      return '안개가 자욱한';
    } else if (condition == 'Thunderstorm') {
      return '천둥번개가 치는';
    }
    return '평온한';
  }

  /// 날씨에 따른 운세 키워드
  List<String> get fortuneKeywords {
    List<String> keywords = [];
    
    if (condition == 'Clear') {
      keywords.addAll(['밝은 기운', '긍정적 에너지', '새로운 시작']);
    } else if (condition == 'Rain') {
      keywords.addAll(['내면의 성찰', '정화', '새로운 변화']);
    } else if (condition == 'Clouds') {
      keywords.addAll(['안정', '균형', '차분함']);
    } else if (condition == 'Snow') {
      keywords.addAll(['순수', '새로운 기회', '희망']);
    }
    
    if (temperature > 25) {
      keywords.add('열정');
    } else if (temperature < 10) {
      keywords.add('인내');
    }
    
    return keywords;
  }
}