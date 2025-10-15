import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 날씨 정보를 가져오는 서비스
class WeatherService {
  // OpenWeatherMap API Key
  static const String _apiKey = '378423f7fe3cf4848a8b5573845302b3';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// 현재 위치의 날씨 정보 가져오기 (캐싱 적용)
  static Future<WeatherInfo> getCurrentWeather() async {
    try {
      // 1. 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 위치 권한이 거부되면 서울 날씨 사용
          return await _getWeatherByCity('Seoul');
        }
      }

      // 2. 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // 3. 지역명 가져오기 (캐싱을 위해)
      final cityResponse = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (cityResponse.statusCode == 200) {
        final data = json.decode(cityResponse.body);
        final cityName = data['name'] ?? 'Unknown';
        
        // 4. 캐시 확인
        final cachedWeather = await _getCachedWeather(cityName);
        if (cachedWeather != null && _isCacheValid(cachedWeather['timestamp'])) {
          debugPrint('📋 캐시된 날씨 사용: $cityName');
          return WeatherInfo.fromJson(cachedWeather['data']);
        }
        
        // 5. 캐시가 없거나 만료된 경우 새로 저장
        debugPrint('🌤️ API에서 날씨 가져오기: $cityName');
        await _cacheWeather(cityName, data);
        return WeatherInfo.fromJson(data);
      } else {
        // API 호출 실패 시 기본값
        return WeatherInfo.defaultWeather();
      }
    } catch (e) {
      debugPrint('날씨 정보 가져오기 실패: $e');
      return WeatherInfo.defaultWeather();
    }
  }

  /// 도시 이름으로 날씨 가져오기 (캐싱 적용)
  static Future<WeatherInfo> _getWeatherByCity(String city) async {
    try {
      // 1. 캐시 확인
      final cachedWeather = await _getCachedWeather(city);
      if (cachedWeather != null && _isCacheValid(cachedWeather['timestamp'])) {
        debugPrint('📋 캐시된 날씨 사용: $city');
        return WeatherInfo.fromJson(cachedWeather['data']);
      }

      // 2. 캐시가 없으면 API 호출
      debugPrint('🌤️ API에서 날씨 가져오기: $city');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 3. 캐시에 저장
        await _cacheWeather(city, data);
        return WeatherInfo.fromJson(data);
      }
    } catch (e) {
      debugPrint('도시 날씨 정보 가져오기 실패: $e');
    }
    return WeatherInfo.defaultWeather();
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

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    // 영어 도시명을 한글로 변환
    String cityName = json['name'] ?? '서울';
    cityName = _translateCityName(cityName);
    
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
  
  /// 영어 도시명을 그대로 반환 (GPT가 처리)
  static String _translateCityName(String englishName) {
    // GPT에서 지역명을 한글로 변환하고 해석하도록
    // 여기서는 영어 이름을 그대로 반환
    return englishName;
  }

  /// 기본 날씨 정보 (API 실패 시)
  factory WeatherInfo.defaultWeather() {
    return WeatherInfo(
      condition: 'Clear',
      description: '맑은 날씨',
      temperature: 20.0,
      feelsLike: 20.0,
      humidity: 50.0,
      windSpeed: 2.0,
      cityName: '서울',
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