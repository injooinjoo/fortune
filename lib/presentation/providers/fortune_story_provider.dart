import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/weather_service.dart';
import '../../screens/home/fortune_story_viewer.dart';
import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../core/utils/logger.dart';
import 'auth_provider.dart';
import 'dart:async';
import 'dart:math' as math;

/// 운세 스토리 상태
class FortuneStoryState {
  final bool isLoading;
  final List<StorySegment>? segments;
  final WeatherInfo? weather;
  final Map<String, dynamic>? sajuAnalysis;
  final String? error;
  
  // Enhanced fortune data
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? weatherSummary;
  final Map<String, dynamic>? overall;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? sajuInsight;
  final List<Map<String, dynamic>>? personalActions;
  final Map<String, dynamic>? notification;
  final Map<String, dynamic>? shareCard;

  const FortuneStoryState({
    this.isLoading = false,
    this.segments,
    this.weather,
    this.sajuAnalysis,
    this.error,
    this.meta,
    this.weatherSummary,
    this.overall,
    this.categories,
    this.sajuInsight,
    this.personalActions,
    this.notification,
    this.shareCard,
  });

  FortuneStoryState copyWith({
    bool? isLoading,
    List<StorySegment>? segments,
    WeatherInfo? weather,
    Map<String, dynamic>? sajuAnalysis,
    String? error,
    Map<String, dynamic>? meta,
    Map<String, dynamic>? weatherSummary,
    Map<String, dynamic>? overall,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? sajuInsight,
    List<Map<String, dynamic>>? personalActions,
    Map<String, dynamic>? notification,
    Map<String, dynamic>? shareCard,
  }) {
    return FortuneStoryState(
      isLoading: isLoading ?? this.isLoading,
      segments: segments ?? this.segments,
      weather: weather ?? this.weather,
      sajuAnalysis: sajuAnalysis ?? this.sajuAnalysis,
      error: error ?? this.error,
      meta: meta ?? this.meta,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      overall: overall ?? this.overall,
      categories: categories ?? this.categories,
      sajuInsight: sajuInsight ?? this.sajuInsight,
      personalActions: personalActions ?? this.personalActions,
      notification: notification ?? this.notification,
      shareCard: shareCard ?? this.shareCard,
    );
  }
}

/// 운세 스토리 생성 Provider
class FortuneStoryNotifier extends StateNotifier<FortuneStoryState> {
  final Ref ref;
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _lastResponseData;

  FortuneStoryNotifier(this.ref) : super(const FortuneStoryState());

  /// 운세 스토리 생성
  Future<void> generateFortuneStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 날씨 정보 가져오기
      Logger.info('🌤️ Getting weather information...');
      final weather = await WeatherService.getCurrentWeather();
      
      state = state.copyWith(weather: weather);

      // 2. GPT API를 통한 스토리 생성
      Logger.info('📝 Generating fortune story with GPT...');
      final segments = await _generateStoryWithGPT(
        userName: userName,
        weather: weather,
        fortune: fortune,
        userProfile: userProfile,
      );

      // Edge Function에서 확장된 데이터 추출
      Map<String, dynamic>? sajuAnalysis;
      Map<String, dynamic>? meta;
      Map<String, dynamic>? weatherSummary;
      Map<String, dynamic>? overall;
      Map<String, dynamic>? categories;
      Map<String, dynamic>? sajuInsight;
      List<Map<String, dynamic>>? personalActions;
      Map<String, dynamic>? notification;
      Map<String, dynamic>? shareCard;
      
      if (_lastResponseData != null) {
        sajuAnalysis = _lastResponseData!['sajuAnalysis'] as Map<String, dynamic>?;
        meta = _lastResponseData!['meta'] as Map<String, dynamic>?;
        weatherSummary = _lastResponseData!['weatherSummary'] as Map<String, dynamic>?;
        overall = _lastResponseData!['overall'] as Map<String, dynamic>?;
        categories = _lastResponseData!['categories'] as Map<String, dynamic>?;
        sajuInsight = _lastResponseData!['sajuInsight'] as Map<String, dynamic>?;
        personalActions = (_lastResponseData!['personalActions'] as List?)?.cast<Map<String, dynamic>>();
        notification = _lastResponseData!['notification'] as Map<String, dynamic>?;
        shareCard = _lastResponseData!['shareCard'] as Map<String, dynamic>?;
      }
      
      state = state.copyWith(
        isLoading: false,
        segments: segments,
        sajuAnalysis: sajuAnalysis,
        meta: meta,
        weatherSummary: weatherSummary,
        overall: overall,
        categories: categories,
        sajuInsight: sajuInsight,
        personalActions: personalActions,
        notification: notification,
        shareCard: shareCard,
      );

      Logger.info('✅ Fortune story generated successfully');
      Logger.info('📦 Final segments count: ${segments?.length}');
    } catch (e) {
      Logger.error('❌ Error generating fortune story: $e');
      
      // 에러 발생 시 기본 스토리 생성
      final defaultSegments = _createDefaultStory(
        userName: userName,
        fortune: fortune,
        userProfile: userProfile,
      );
      
      Logger.info('🔄 Using default story with ${defaultSegments.length} segments');
      
      state = state.copyWith(
        isLoading: false,
        segments: defaultSegments,
        error: e.toString(),
      );
    }
  }

  /// GPT를 통한 스토리 생성 (10페이지 분량)
  Future<List<StorySegment>> _generateStoryWithGPT({
    required String userName,
    required WeatherInfo weather,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) async {
    try {
      Logger.info('📡 Calling Edge Function generate-fortune-story...');
      Logger.info('userName: $userName');
      Logger.info('fortune score: ${fortune.overallScore}');
      
      // Supabase Edge Function 호출 (타임아웃 설정)
      final response = await _supabase.functions.invoke(
        'generate-fortune-story',
        body: {
          'userName': userName,
          'userProfile': userProfile != null ? {
            'birthDate': userProfile.birthdate?.toIso8601String(),
            'birthTime': userProfile.birthTime,
            'gender': userProfile.gender,
            'isLunar': userProfile.isLunar,
            'zodiacSign': userProfile.zodiacSign,
            'zodiacAnimal': userProfile.zodiacAnimal,
            'mbti': userProfile.mbti,
            'bloodType': userProfile.bloodType,
          } : null,
          'weather': {
            'condition': weather.condition,
            'description': weather.emotionalDescription,
            'temperature': weather.temperature,
            'cityName': weather.cityName,
            'keywords': weather.fortuneKeywords,
          },
          'fortune': {
            'score': fortune.overallScore ?? 75,
            'summary': fortune.summary ?? fortune.content,
            'content': fortune.content,
            'description': fortune.description,
            'keywords': fortune.recommendations ?? [],
            'luckyColor': fortune.luckyItems?['color'],
            'luckyNumber': fortune.luckyItems?['number'],
            'luckyTime': fortune.luckyItems?['time'],
            'luckyDirection': fortune.luckyItems?['direction'],
            'advice': fortune.metadata?['advice'] ?? fortune.description,
            'caution': fortune.metadata?['caution'],
            'greeting': fortune.metadata?['greeting'],
            'specialTip': fortune.metadata?['special_tip'],
            'elements': {
              'love': fortune.scoreBreakdown?['love'],
              'career': fortune.scoreBreakdown?['career'],
              'money': fortune.scoreBreakdown?['money'],
              'health': fortune.scoreBreakdown?['health'],
            },
          },
          'date': DateTime.now().toIso8601String(),
          'storyConfig': {
            'targetPages': 10,
            'style': 'poetic_novel',
            'includeDetails': true,
            'personalizedContent': true,
          },
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Logger.error('⏱️ Edge Function timeout after 30 seconds - using fallback story');
          // Return a fallback response instead of throwing
          // Create fallback story segments (return empty to trigger fallback in handler)
          return FunctionResponse(
            data: {
              'segments': null,  // Return null to trigger fallback logic
              'error': 'timeout',
              'message': 'Story generation timed out, using fallback'
            },
            status: 200,
          );
        },
      );

      // 응답 전체를 로깅
      Logger.info('🔍 Edge Function Response received:');
      Logger.info('Response status: ${response.status}');
      Logger.info('Response type: ${response.data.runtimeType}');
      
      // 응답 데이터 검증
      if (response.data == null) {
        Logger.error('❌ Response data is null');
        throw Exception('Edge Function returned null data');
      }
      
      Logger.info('Response data keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'Not a Map'}');
      Logger.info('Response data preview: ${response.data.toString().substring(0, math.min(500, response.data.toString().length))}...');
      
      // 응답 데이터 저장 (사주 분석 추출용)
      _lastResponseData = response.data as Map<String, dynamic>?;
      
      // Check for both 'segments' and 'storySegments' keys
      if (response.data != null && (response.data['segments'] != null || response.data['storySegments'] != null)) {
        // GPT 응답을 StorySegment 리스트로 변환
        // segments 또는 storySegments가 List인지 Map인지 확인
        dynamic segmentsRaw = response.data['segments'] ?? response.data['storySegments'];
        Logger.info('Segments raw type: ${segmentsRaw.runtimeType}');
        Logger.info('Segments raw data: $segmentsRaw');
        
        List<dynamic> segmentsData;
        
        if (segmentsRaw is List) {
          segmentsData = segmentsRaw;
          Logger.info('Segments is List with ${segmentsData.length} items');
        } else if (segmentsRaw is Map) {
          // Map인 경우 다양한 형식 처리
          if (segmentsRaw['story'] != null && segmentsRaw['story'] is List) {
            segmentsData = segmentsRaw['story'];
            Logger.info('Found story array in Map with ${segmentsData.length} items');
          } else if (segmentsRaw['pages'] != null && segmentsRaw['pages'] is List) {
            segmentsData = segmentsRaw['pages'];
            Logger.info('Found pages array in Map with ${segmentsData.length} items');
          } else if (segmentsRaw['segments'] != null && segmentsRaw['segments'] is List) {
            segmentsData = segmentsRaw['segments'];
            Logger.info('Found segments array in Map with ${segmentsData.length} items');
          } else if (segmentsRaw['page'] != null || segmentsRaw['text'] != null) {
            // 단일 페이지 객체인 경우 - GPT가 잘못된 형식으로 응답
            Logger.info('Single page object detected, this is wrong format from GPT');
            // 이 경우 기본 스토리로 대체
            segmentsData = [];
          } else {
            // 숫자 키로 된 페이지들 확인 (1, 2, 3... 또는 "1", "2", "3"...)
            List<dynamic> extractedPages = [];
            for (int i = 1; i <= 10; i++) {
              if (segmentsRaw[i.toString()] != null) {
                extractedPages.add(segmentsRaw[i.toString()]);
              } else if (segmentsRaw[i] != null) {
                extractedPages.add(segmentsRaw[i]);
              }
            }
            if (extractedPages.isNotEmpty) {
              segmentsData = extractedPages;
              Logger.info('Extracted ${extractedPages.length} pages from numbered keys');
            } else {
              segmentsData = [];
              Logger.info('No valid segment data found');
            }
          }
        } else {
          // 예상치 못한 타입인 경우 빈 리스트
          segmentsData = [];
          Logger.error('Segments is unexpected type: ${segmentsRaw.runtimeType}');
        }
        
        // 최소 10페이지 보장
        if (segmentsData.length < 10) {
          Logger.info('⚠️ Segments less than 10 (${segmentsData.length}), expanding...');
          final expanded = _expandStorySegments(segmentsData, userName, fortune);
          Logger.info('🔄 Expanded to ${expanded.length} segments');
          return expanded;
        }
        
        // 각 segment 상세 로깅
        List<StorySegment> resultSegments = [];
        
        for (int i = 0; i < segmentsData.length; i++) {
          try {
            final segment = segmentsData[i];
            Logger.info('Processing segment $i: $segment');
            Logger.info('Segment type: ${segment.runtimeType}');
            
            // 각 필드 타입 체크
            if (segment is Map) {
              Logger.info('text field type: ${segment['text']?.runtimeType}');
              Logger.info('text field value: ${segment['text']}');
              Logger.info('fontSize field type: ${segment['fontSize']?.runtimeType}');
              Logger.info('fontSize field value: ${segment['fontSize']}');
              Logger.info('fontWeight field type: ${segment['fontWeight']?.runtimeType}');
              Logger.info('fontWeight field value: ${segment['fontWeight']}');
            }
            
            // text 필드가 String이 아닌 경우 처리
            String textValue;
            if (segment['text'] is String) {
              textValue = segment['text'] as String;
            } else if (segment['text'] != null) {
              textValue = segment['text'].toString();
            } else {
              textValue = '';
            }
            
            // fontSize 안전하게 처리
            double? fontSizeValue;
            if (segment['fontSize'] != null) {
              if (segment['fontSize'] is num) {
                fontSizeValue = (segment['fontSize'] as num).toDouble();
              } else if (segment['fontSize'] is String) {
                fontSizeValue = double.tryParse(segment['fontSize']);
              }
            }
            fontSizeValue ??= 24;
            
            // fontWeight 안전하게 처리
            FontWeight? fontWeightValue;
            try {
              fontWeightValue = _parseFontWeight(segment['fontWeight']);
            } catch (e) {
              Logger.error('Error parsing fontWeight: $e');
              fontWeightValue = FontWeight.w400;
            }
            
            // alignment 안전하게 처리
            TextAlign? alignmentValue;
            try {
              alignmentValue = _parseTextAlign(segment['alignment']);
            } catch (e) {
              Logger.error('Error parsing alignment: $e');
              alignmentValue = TextAlign.center;
            }
            
            final storySegment = StorySegment(
              text: textValue,
              subtitle: segment['subtitle']?.toString(),
              fontSize: fontSizeValue,
              fontWeight: fontWeightValue,
              alignment: alignmentValue,
              emoji: segment['emoji']?.toString(),
            );
            
            resultSegments.add(storySegment);
            Logger.info('Successfully created segment $i');
            
          } catch (e, stack) {
            Logger.error('Error processing segment $i: $e');
            Logger.error('Stack trace: $stack');
            // 에러가 나도 기본 세그먼트 추가
            resultSegments.add(StorySegment(
              text: '...',
              fontSize: 24,
            ));
          }
        }
        
        return resultSegments;
      } else {
        Logger.error('No segments in response or response is null');
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Edge Function call failed: $e');
      Logger.error('Stack trace: $stackTrace');
      
      // 시간 초과 에러인 경우 특별 처리
      if (e is TimeoutException) {
        Logger.error('⏰ Timeout occurred - Edge Function may be taking too long');
      }
    }

    // GPT 실패 시 확장된 기본 스토리 반환
    Logger.info('🎭 Using extended default story due to GPT failure');
    return _createExtendedDefaultStory(userName: userName, fortune: fortune, userProfile: userProfile);
  }

  /// 기본 스토리 생성 (GPT 실패 시)
  List<StorySegment> _createDefaultStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) {
    Logger.info('🎭 Creating default story for $userName');
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];

    // 1. 인사
    segments.add(StorySegment(
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));

    // 3. 총평
    final summaryData = _getDynamicSummaryText(score);
    segments.add(StorySegment(
      text: summaryData['text'] ?? '특별한 하루입니다',
      fontSize: 26,
      fontWeight: FontWeight.w300,
      emoji: summaryData['emoji'] ?? '✨',
    ));

    // 4-6. 실제 운세 내용 사용 (3페이지)
    List<String> fortuneTexts = [];
    
    // 1. content를 3개로 분할
    if (fortune.content != null && fortune.content!.isNotEmpty) {
      final sentences = fortune.content!.split('. ');
      final chunkSize = (sentences.length / 3).ceil();
      
      for (int i = 0; i < 3; i++) {
        final start = i * chunkSize;
        final end = (i + 1) * chunkSize;
        if (start < sentences.length) {
          final chunk = sentences
              .sublist(start, end > sentences.length ? sentences.length : end)
              .join('. ');
          fortuneTexts.add(chunk + (chunk.endsWith('.') ? '' : '.'));
        }
      }
    }
    
    // 2. description 활용
    if (fortune.description != null && fortune.description!.isNotEmpty && fortuneTexts.length < 3) {
      final descSentences = fortune.description!.split('. ');
      for (int i = fortuneTexts.length; i < 3 && i < descSentences.length; i++) {
        fortuneTexts.add(descSentences[i].trim() + (descSentences[i].endsWith('.') ? '' : '.'));
      }
    }
    
    // 3. 기본 텍스트로 보완
    while (fortuneTexts.length < 3) {
      fortuneTexts.add(_getShortFortuneText(score, fortuneTexts.length + 1));
    }
    
    // 각각을 세그먼트로 추가
    for (String text in fortuneTexts) {
      segments.add(StorySegment(
        text: text,
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }

    // 운세 요약
    if (fortune.summary != null && fortune.summary!.isNotEmpty) {
      List<String> summaryParts = fortune.summary!.split('. ');
      for (String part in summaryParts) {
        if (part.trim().isNotEmpty) {
          segments.add(StorySegment(
            text: part.trim() + (part.endsWith('.') ? '' : '.'),
            fontSize: 26,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    }

    // 7. 주의사항 - 실제 데이터 활용
    String cautionText = _getDynamicCautionText(score);
    if (fortune.metadata?['caution'] != null) {
      cautionText = fortune.metadata!['caution'];
    } else if (fortune.description != null && fortune.description!.isNotEmpty) {
      // 운세 내용에서 주의사항 추출
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('주의') || sentence.contains('조심') || 
            sentence.contains('경계') || sentence.contains('피하')) {
          cautionText = sentence.trim();
          break;
        }
      }
    }
    
    segments.add(StorySegment(
      subtitle: '⚠️ 주의',
      text: cautionText,
      fontSize: 22,
      fontWeight: FontWeight.w300,
    ));

    // 8. 행운 요소
    List<String> luckyTexts = [];
    if (fortune.luckyItems != null) {
      if (fortune.luckyItems!['color'] != null) {
        luckyTexts.add('색상: ${_getColorName(fortune.luckyItems!['color'])}');
      }
      if (fortune.luckyItems!['number'] != null) {
        luckyTexts.add('숫자: ${fortune.luckyItems!['number']}');
      }
      if (fortune.luckyItems!['time'] != null) {
        luckyTexts.add('시간: ${fortune.luckyItems!['time']}');
      }
    }
    if (luckyTexts.isEmpty) {
      luckyTexts = _getDynamicLuckyItems();
    }
    segments.add(StorySegment(
      subtitle: '🍀 행운',
      text: luckyTexts.join('\n'),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 9. 조언 - 실제 데이터 활용
    String adviceText = _getDynamicAdviceText(score);
    if (fortune.metadata?['advice'] != null) {
      adviceText = fortune.metadata!['advice'];
    } else if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) {
      // 첫 번째 추천사항을 조언으로 사용
      adviceText = fortune.recommendations!.first;
    } else if (fortune.description != null && fortune.description!.isNotEmpty) {
      // 운세 내용에서 조언성 내용 찾기
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('하세요') || sentence.contains('바랍니다') || 
            sentence.contains('추천') || sentence.contains('좋습니다')) {
          adviceText = sentence.trim();
          break;
        }
      }
    }
    
    segments.add(StorySegment(
      subtitle: '💡 조언',
      text: adviceText,
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 10. 마무리
    segments.add(StorySegment(
      subtitle: '마무리',
      text: '좋은 하루 되세요',
      fontSize: 28,
      fontWeight: FontWeight.w300,
      emoji: '✨',
    ));

    return segments;
  }

  /// 확장된 기본 스토리 생성 (10페이지 분량)
  List<StorySegment> _createExtendedDefaultStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) {
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];

    // 1. 인사
    segments.add(StorySegment(
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));

    // 3. 총평
    String energyText = score >= 80 
        ? '특별한 에너지가\n넘치는 날'
        : score >= 60
        ? '차분하고 안정적인\n하루'
        : '천천히 가도\n괜찮은 날';
    segments.add(StorySegment(
      text: energyText,
      fontSize: 26,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));

    // 4-6. 운세 상세 (3페이지) - 실제 API 데이터 활용
    List<String> fortuneTexts = [];
    
    // 1. 메인 운세 내용 활용
    if (fortune.content != null && fortune.content!.isNotEmpty) {
      final sentences = fortune.content!.split('. ');
      // 문장들을 3개 그룹으로 나누어 각각 다른 페이지에 표시
      final chunkSize = (sentences.length / 3).ceil();
      
      for (int i = 0; i < 3; i++) {
        final start = i * chunkSize;
        final end = (i + 1) * chunkSize;
        if (start < sentences.length) {
          final chunk = sentences
              .sublist(start, end > sentences.length ? sentences.length : end)
              .join('. ');
          fortuneTexts.add(chunk + (chunk.endsWith('.') ? '' : '.'));
        }
      }
    }
    
    // 2. 설명(description) 데이터 활용
    if (fortune.description != null && fortune.description!.isNotEmpty && fortuneTexts.length < 3) {
      final descSentences = fortune.description!.split('. ');
      for (int i = fortuneTexts.length; i < 3 && i < descSentences.length; i++) {
        fortuneTexts.add(descSentences[i].trim() + (descSentences[i].endsWith('.') ? '' : '.'));
      }
    }
    
    // 3. 추천사항(recommendations) 활용
    if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty && fortuneTexts.length < 3) {
      for (int i = fortuneTexts.length; i < 3 && i < fortune.recommendations!.length; i++) {
        fortuneTexts.add('오늘의 조언:\n${fortune.recommendations![i]}');
      }
    }
    
    // 4. 점수별 세부 운세 활용
    if (fortune.scoreBreakdown != null && fortuneTexts.length < 3) {
      final breakdown = fortune.scoreBreakdown!;
      List<String> breakdownTexts = [];
      
      if (breakdown['love'] != null) {
        breakdownTexts.add('연애운 ${breakdown['love']}점\n\n${_getFortuneTextByScore(breakdown['love'], '연애')}');
      }
      if (breakdown['career'] != null) {
        breakdownTexts.add('직장운 ${breakdown['career']}점\n\n${_getFortuneTextByScore(breakdown['career'], '직장')}');
      }
      if (breakdown['money'] != null) {
        breakdownTexts.add('금전운 ${breakdown['money']}점\n\n${_getFortuneTextByScore(breakdown['money'], '금전')}');
      }
      if (breakdown['health'] != null) {
        breakdownTexts.add('건강운 ${breakdown['health']}점\n\n${_getFortuneTextByScore(breakdown['health'], '건강')}');
      }
      
      for (int i = fortuneTexts.length; i < 3 && i < breakdownTexts.length; i++) {
        fortuneTexts.add(breakdownTexts[i]);
      }
    }
    
    // 5. 부족한 경우 날짜 기반 동적 텍스트로 보완
    while (fortuneTexts.length < 3) {
      // 날짜 기반 시드 생성으로 매일 다른 내용
      final dateSeed = now.year * 10000 + now.month * 100 + now.day;
      final indexSeed = dateSeed + fortuneTexts.length;
      final randomIndex = (indexSeed % 1000) / 1000.0;
      
      if (fortuneTexts.length == 0) {
        final options = score >= 80 ? [
          '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다.\n\n용기를 내어\n도전해보세요.',
          '밝은 에너지가\n넘치는 하루입니다.\n\n당신의 열정이\n주변을 밝게 할 거예요.',
          '특별한 만남이나\n좋은 소식이\n기다리고 있습니다.\n\n마음을 열고\n받아들여보세요.',
          '창의적인 아이디어가\n떠오르는 날입니다.\n\n직감을 믿고\n행동해보세요.'
        ] : [
          '평범해 보이는\n오늘 하루지만\n\n작은 것에서\n큰 의미를\n발견하게 될 거예요.',
          '차분한 성찰이\n필요한 시간입니다.\n\n내면의 소리에\n귀 기울여보세요.',
          '안정감 속에서\n새로운 깨달음을\n얻을 수 있습니다.\n\n서두르지 마세요.',
          '조용한 힘이\n당신과 함께합니다.\n\n꾸준히 나아가면\n좋은 결과가 있을 거예요.'
        ];
        fortuneTexts.add(options[(randomIndex * options.length).floor()]);
      } else if (fortuneTexts.length == 1) {
        final options = score >= 80 ? [
          '주변 사람들과의\n관계에서\n좋은 소식이\n들려올 것입니다.\n\n마음을 열고\n소통해보세요.',
          '협력하면\n더 큰 성과를\n얻을 수 있습니다.\n\n팀워크의 힘을\n믿어보세요.',
          '예상치 못한\n도움의 손길이\n나타날 것입니다.\n\n감사하는 마음을\n잊지 마세요.',
          '리더십을 발휘할\n절호의 기회입니다.\n\n자신 있게\n앞장서보세요.'
        ] : [
          '일상 속에서\n예상치 못한\n즐거움을\n발견하게 됩니다.\n\n긍정적인 마음을\n유지하세요.',
          '인내심을 갖고\n기다린다면\n\n좋은 기회가\n찾아올 것입니다.',
          '작은 변화가\n큰 결과를\n만들어낼 수 있습니다.\n\n세심한 관찰을\n해보세요.',
          '안전한 선택이\n현명할 때입니다.\n\n신중하게\n판단해보세요.'
        ];
        fortuneTexts.add(options[(randomIndex * options.length).floor()]);
      } else {
        final options = score >= 80 ? [
          '오늘 내린 결정이\n미래에 큰\n영향을 미칠 것입니다.\n\n자신감을 가지고\n앞으로 나아가세요.',
          '당신의 노력이\n결실을 맺을\n시간이 다가왔습니다.\n\n끝까지 포기하지 마세요.',
          '새로운 도전에\n성공할 가능성이\n높습니다.\n\n과감하게\n시작해보세요.',
          '직감이 맞을\n확률이 높습니다.\n\n망설이지 말고\n행동해보세요.'
        ] : [
          '차근차근\n계획을 세우고\n실행한다면\n\n원하는 결과를\n얻을 수 있습니다.',
          '서두르지 말고\n꾸준히 진행하면\n\n분명 좋은 일이\n생길 것입니다.',
          '때로는 기다림도\n필요합니다.\n\n지금은 준비하는\n시간으로 여기세요.',
          '작은 성취라도\n소중히 여기면\n\n더 큰 행운이\n찾아올 것입니다.'
        ];
        fortuneTexts.add(options[(randomIndex * options.length).floor()]);
      }
    }
    
    // 각각을 세그먼트로 추가
    for (String text in fortuneTexts) {
      segments.add(StorySegment(
        text: text,
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }

    // 7. 주의사항 - 실제 운세 데이터 사용 + 동적 생성
    String cautionText = fortune.metadata?['caution'] ?? '';
    
    // 운세 내용에서 주의사항 추출 시도
    if (cautionText.isEmpty && fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('주의') || sentence.contains('조심') || sentence.contains('경계') || 
            sentence.contains('피하') || sentence.contains('신중')) {
          cautionText = sentence.trim();
          break;
        }
      }
    }
    
    // 여전히 비어있다면 날짜 기반 동적 생성
    if (cautionText.isEmpty) {
      final cautionSeed = now.year * 100 + now.month * 10 + now.day;
      final cautionIndex = cautionSeed % 8;
      
      final cautionOptions = score >= 80 ? [
        '과도한 자신감은 경계하세요',
        '성급한 결정보다 신중한 판단이 필요합니다',
        '다른 사람의 의견도 경청해보세요',
        '완벽함을 추구하다 기회를 놓치지 마세요',
        '감정적 반응보다는 이성적 접근이 좋겠습니다',
        '과욕을 부리면 오히려 역효과가 날 수 있어요',
        '주변 상황을 꼼꼼히 살펴보고 행동하세요',
        '너무 많은 일을 동시에 처리하려 하지 마세요'
      ] : [
        '충동적인 결정은 피하세요',
        '소극적인 태도보다는 적극적인 자세가 필요해요',
        '부정적인 생각에 매몰되지 마세요',
        '작은 일에도 꼼꼼한 주의가 필요합니다',
        '타인과의 갈등은 피하는 것이 현명해요',
        '체력 관리에 신경 쓰시기 바랍니다',
        '중요한 약속이나 일정을 놓치지 마세요',
        '무리한 계획보다는 현실적인 목표를 세우세요'
      ];
      
      cautionText = cautionOptions[cautionIndex];
    }
    
    segments.add(StorySegment(
      text: '잠깐,\n\n$cautionText',
      fontSize: 22,
      fontWeight: FontWeight.w300,
    ));

    // 8. 행운의 요소들
    String luckyText = '';
    if (fortune.luckyItems != null) {
      if (fortune.luckyItems!['color'] != null) {
        luckyText += '오늘의 색: ${_getColorName(fortune.luckyItems!['color'])}\n';
      }
      if (fortune.luckyItems!['number'] != null) {
        luckyText += '행운의 숫자: ${fortune.luckyItems!['number']}\n';
      }
      if (fortune.luckyItems!['time'] != null) {
        luckyText += '최고의 시간: ${fortune.luckyItems!['time']}';
      }
    }
    if (luckyText.isEmpty) {
      luckyText = '오늘의 색: 하늘색\n행운의 숫자: 7\n최고의 시간: 오후 2-4시';
    }
    segments.add(StorySegment(
      text: luckyText,
      fontSize: 26,
      fontWeight: FontWeight.w300,
    ));

    // 9. 조언 - 실제 API 데이터 활용
    String adviceText = (score >= 80 
        ? '무엇이든 도전하세요.\n큰 성과가 기대됩니다.'
        : '신중하게 행동하고\n무리하지 마세요.');
    
    // 1. metadata에서 조언 찾기
    if (fortune.metadata?['advice'] != null) {
      adviceText = fortune.metadata!['advice'];
    }
    // 2. recommendations에서 조언 찾기 
    else if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) {
      // 가장 긴 추천사항을 조언으로 사용
      String bestRecommendation = fortune.recommendations!.first;
      for (String rec in fortune.recommendations!) {
        if (rec.length > bestRecommendation.length) {
          bestRecommendation = rec;
        }
      }
      adviceText = bestRecommendation;
    }
    // 3. description에서 조언성 내용 찾기
    else if (fortune.description != null && fortune.description!.isNotEmpty) {
      final sentences = fortune.description!.split('.');
      for (String sentence in sentences) {
        if (sentence.contains('조언') || sentence.contains('추천') || 
            sentence.contains('하세요') || sentence.contains('바랍니다')) {
          adviceText = sentence.trim();
          break;
        }
      }
    }
    
    segments.add(StorySegment(
      text: adviceText,
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 10. 마무리
    segments.add(StorySegment(
      text: '오늘도\n멋진 하루가\n되길 바라요\n\n✨',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));

    return segments;
  }

  /// 스토리 세그먼트 확장 (10페이지 미만일 때)
  List<StorySegment> _expandStorySegments(
    List<dynamic> segmentsData,
    String userName,
    fortune_entity.Fortune fortune,
  ) {
    List<StorySegment> segments = segmentsData.map((segment) {
      // 안전한 타입 변환
      String textValue = segment['text']?.toString() ?? '';
      double? fontSizeValue;
      if (segment['fontSize'] != null) {
        if (segment['fontSize'] is num) {
          fontSizeValue = (segment['fontSize'] as num).toDouble();
        } else if (segment['fontSize'] is String) {
          fontSizeValue = double.tryParse(segment['fontSize']);
        }
      }
      
      return StorySegment(
        text: textValue,
        fontSize: fontSizeValue,
        fontWeight: _parseFontWeight(segment['fontWeight']),
        alignment: _parseTextAlign(segment['alignment']),
      );
    }).toList();

    // 부족한 페이지 수만큼 추가
    while (segments.length < 10) {
      if (segments.length == 7) {
        // 각 분야별 운세 추가
        segments.add(StorySegment(
          text: '연애운: ${fortune.scoreBreakdown?['love'] ?? 70}점\n직장운: ${fortune.scoreBreakdown?['career'] ?? 70}점',
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ));
      } else if (segments.length == 8) {
        segments.add(StorySegment(
          text: '금전운: ${fortune.scoreBreakdown?['money'] ?? 70}점\n건강운: ${fortune.scoreBreakdown?['health'] ?? 70}점',
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ));
      } else if (segments.length == 9) {
        // 실제 데이터에서 팁 찾기
        String tipText;
        if (fortune.metadata?['special_tip'] != null) {
          tipText = '특별한 팁:\n${fortune.metadata!['special_tip']}';
        } else if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) {
          // recommendations에서 마지막 항목을 팁으로 사용
          tipText = '특별한 팁:\n${fortune.recommendations!.last}';
        } else if (fortune.description != null && fortune.description!.isNotEmpty) {
          // description에서 팁성 내용 찾기
          final sentences = fortune.description!.split('.');
          String? tipSentence;
          for (String sentence in sentences.reversed) { // 뒤에서부터 찾기
            if (sentence.contains('팁') || sentence.contains('도움') || sentence.contains('좋을')) {
              tipSentence = sentence.trim();
              break;
            }
          }
          tipText = tipSentence != null 
              ? '특별한 팁:\n$tipSentence'
              : '특별한 팁:\n오늘은 자신을 믿고 앞으로 나아가세요';
        } else {
          tipText = '특별한 팁:\n오늘은 자신을 믿고 앞으로 나아가세요';
        }
        
        segments.add(StorySegment(
          text: tipText,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ));
      } else {
        // 실제 운세 데이터로 추가 페이지 생성
        String additionalText;
        if (fortune.content != null && fortune.content!.isNotEmpty) {
          // content에서 추가 문장 사용
          final sentences = fortune.content!.split('.');
          final randomIndex = (segments.length - 3) % sentences.length;
          additionalText = sentences[randomIndex].trim() + '.';
        } else if (fortune.description != null && fortune.description!.isNotEmpty) {
          // description에서 추가 문장 사용
          final sentences = fortune.description!.split('.');
          final randomIndex = (segments.length - 3) % sentences.length;
          additionalText = sentences[randomIndex].trim() + '.';
        } else {
          additionalText = '긍정적인 마음으로\n하루를 시작하세요';
        }
        
        segments.add(StorySegment(
          text: additionalText,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ));
      }
    }

    Logger.info('🎆 Default story created with ${segments.length} segments');
    return segments;
  }

  // 분야별 점수에 따른 운세 텍스트 생성
  String _getFortuneTextByScore(int score, String category) {
    if (category == '연애') {
      if (score >= 80) return '새로운 만남이나 관계 발전의 기회가 있습니다';
      if (score >= 60) return '현재 관계에서 안정감을 느낄 수 있습니다';
      return '서두르지 말고 자신을 돌아보는 시간을 가지세요';
    } else if (category == '직장') {
      if (score >= 80) return '업무에서 좋은 성과를 거둘 수 있습니다';
      if (score >= 60) return '동료들과의 협력이 원활할 것입니다';
      return '신중하게 업무를 처리하고 무리하지 마세요';
    } else if (category == '금전') {
      if (score >= 80) return '투자나 부업에서 좋은 결과가 기대됩니다';
      if (score >= 60) return '계획적인 소비로 안정적인 하루를 보내세요';
      return '불필요한 지출은 피하고 절약하는 것이 좋습니다';
    } else if (category == '건강') {
      if (score >= 80) return '컨디션이 좋고 활기찬 하루가 될 것입니다';
      if (score >= 60) return '적당한 운동으로 건강을 유지하세요';
      return '충분한 휴식을 취하고 몸을 아끼세요';
    }
    return '긍정적인 마음가짐으로 하루를 시작하세요';
  }

  // 짧은 운세 텍스트 생성 (동적 컨텐츠)
  String _getShortFortuneText(int score, int part) {
    final now = DateTime.now();
    
    // Date-based seed for daily variation
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final partSeed = dateSeed + part + score;
    final randomIndex = (partSeed % 1000) / 1000.0;
    
    if (part == 1) {
      // 핵심 운세 - 8가지 변형
      final highScoreTexts = [
        '새로운 기회가\n찾아올 것입니다',
        '특별한 행운이\n기다리고 있어요',
        '중요한 만남이\n예정되어 있습니다',
        '창의적인 아이디어가\n떠오를 시간',
        '오늘이 전환점이\n될 수 있어요',
        '용기 있는 도전이\n큰 성과를 가져올 것',
        '직감을 믿고\n행동해보세요',
        '긍정적인 변화의\n시작점입니다'
      ];
      
      final midScoreTexts = [
        '작은 것에서\n큰 의미를 발견하세요',
        '차근차근 준비하면\n좋은 결과가 있을 것',
        '주변 사람들의 조언에\n귀 기울여보세요',
        '평온함 속에서\n새로운 깨달음을',
        '꾸준함이 가장\n큰 힘이 됩니다',
        '현재에 집중하며\n감사한 마음으로',
        '균형을 찾아가는\n하루가 될 것',
        '작은 실천이\n큰 변화를 만들어요'
      ];
      
      final lowScoreTexts = [
        '조금 힘든 하루지만\n성장의 과정입니다',
        '천천히 걸어가도\n괜찮아요',
        '휴식을 통해\n새로운 힘을 얻으세요',
        '어려운 순간이지만\n지나갈 것입니다',
        '자신에게 너그러운\n마음을 가져보세요',
        '작은 행복에\n집중해보는 시간',
        '내면의 평화를\n찾아보세요',
        '힘든 시간도\n소중한 경험입니다'
      ];
      
      if (score >= 80) {
        final index = (randomIndex * highScoreTexts.length).floor();
        return highScoreTexts[index];
      } else if (score >= 60) {
        final index = (randomIndex * midScoreTexts.length).floor();
        return midScoreTexts[index];
      } else {
        final index = (randomIndex * lowScoreTexts.length).floor();
        return lowScoreTexts[index];
      }
    } else if (part == 2) {
      // 오전 운세 - 8가지 변형
      final highScoreTexts = [
        '에너지가 넘치는 오전\n적극적으로 행동하세요',
        '좋은 아이디어가\n떠오르는 시간',
        '중요한 대화가\n성공적으로 진행될 것',
        '새로운 시작에\n완벽한 타이밍',
        '집중력이 최고조에\n달하는 시간',
        '협업이 빛을 발하는\n오전입니다',
        '창의력이 폭발하는\n황금 시간대',
        '리더십을 발휘할\n좋은 기회'
      ];
      
      final midScoreTexts = [
        '차분한 오전\n계획을 세워보세요',
        '정리정돈으로\n마음도 정리해보세요',
        '소중한 사람에게\n안부를 물어보세요',
        '새로운 정보를\n찾아보는 시간',
        '건강한 습관을\n시작해보세요',
        '독서나 학습에\n좋은 시간',
        '자연과 가까워지는\n여유로운 오전',
        '명상이나 성찰의\n시간을 가져보세요'
      ];
      
      final lowScoreTexts = [
        '천천히 시작하세요\n서두르지 마세요',
        '충분한 휴식으로\n에너지를 보충하세요',
        '무리하지 말고\n자신의 페이스로',
        '조용한 시간을\n가져보세요',
        '스트레칭으로\n몸을 풀어보세요',
        '따뜻한 차 한 잔과\n함께하는 여유',
        '좋은 음악을 들으며\n마음을 달래보세요',
        '작은 목표부터\n차근차근 시작'
      ];
      
      if (score >= 80) {
        final index = (randomIndex * highScoreTexts.length).floor();
        return highScoreTexts[index];
      } else if (score >= 60) {
        final index = (randomIndex * midScoreTexts.length).floor();
        return midScoreTexts[index];
      } else {
        final index = (randomIndex * lowScoreTexts.length).floor();
        return lowScoreTexts[index];
      }
    } else {
      // 오후 운세 - 8가지 변형
      final highScoreTexts = [
        '좋은 소식이 들려올 시간\n마음을 열고 소통하세요',
        '예상치 못한 즐거운\n만남이 있을 것',
        '창의적인 프로젝트가\n성공적으로 마무리될 것',
        '사교 활동에서\n좋은 인연을 만날 수 있어요',
        '재능을 발휘할\n완벽한 기회',
        '중요한 결정을 내리기\n좋은 시간',
        '여행이나 외출에\n행운이 따를 것',
        '새로운 취미나 관심사를\n발견할 수 있어요'
      ];
      
      final midScoreTexts = [
        '예상치 못한 즐거움\n긍정적인 마음 유지',
        '가족이나 친구와\n따뜻한 시간을',
        '취미 활동으로\n스트레스를 해소하세요',
        '맛있는 음식으로\n에너지를 충전',
        '산책이나 가벼운 운동을\n해보세요',
        '새로운 장소를\n탐험해보는 시간',
        '책이나 영화로\n여유로운 오후를',
        '감사한 일들을\n떠올려보세요'
      ];
      
      final lowScoreTexts = [
        '혼자만의 시간 필요\n자신을 돌보세요',
        '충분한 휴식으로\n마음의 평화를',
        '좋아하는 음악과 함께\n힐링 타임을',
        '따뜻한 목욕으로\n하루의 피로를',
        '일찍 잠자리에 들어\n내일을 준비하세요',
        '편안한 공간에서\n마음을 정리해보세요',
        '감정을 글로 써보며\n정리하는 시간',
        '내일은 더 나은 하루가\n될 것이라 믿으세요'
      ];
      
      if (score >= 80) {
        final index = (randomIndex * highScoreTexts.length).floor();
        return highScoreTexts[index];
      } else if (score >= 60) {
        final index = (randomIndex * midScoreTexts.length).floor();
        return midScoreTexts[index];
      } else {
        final index = (randomIndex * lowScoreTexts.length).floor();
        return lowScoreTexts[index];
      }
    }
  }

  // Helper 메서드들
  String _getWeekdayKorean(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  String _getColorName(String hexColor) {
    Map<String, String> colorNames = {
      '#FF6B6B': '붉은색',
      '#4ECDC4': '청록색',
      '#45B7D1': '하늘색',
      '#FFA07A': '살구색',
      '#98D8C8': '민트색',
      '#F7DC6F': '노란색',
      '#BB8FCE': '보라색',
      '#85C1E2': '연한 파란색',
      '#F8B739': '주황색',
      '#52D681': '초록색',
    };
    
    return colorNames[hexColor.toUpperCase()] ?? '특별한 색';
  }

  FontWeight? _parseFontWeight(dynamic weight) {
    if (weight == null) return null;
    
    // int로 들어온 경우 처리
    if (weight is int) {
      switch (weight) {
        case 100: return FontWeight.w100;
        case 200: return FontWeight.w200;
        case 300: return FontWeight.w300;
        case 400: return FontWeight.w400;
        case 500: return FontWeight.w500;
        case 600: return FontWeight.w600;
        case 700: return FontWeight.w700;
        case 800: return FontWeight.w800;
        case 900: return FontWeight.w900;
        default: return FontWeight.w400;
      }
    }
    
    // String으로 들어온 경우
    if (weight is String) {
      // 숫자만 있는 경우
      final numWeight = int.tryParse(weight);
      if (numWeight != null) {
        return _parseFontWeight(numWeight);
      }
      
      switch (weight) {
        case 'w100': return FontWeight.w100;
        case 'w200': return FontWeight.w200;
        case 'w300': return FontWeight.w300;
        case 'w400': return FontWeight.w400;
        case 'w500': return FontWeight.w500;
        case 'w600': return FontWeight.w600;
        case 'w700': return FontWeight.w700;
        case 'w800': return FontWeight.w800;
        case 'w900': return FontWeight.w900;
        default: return FontWeight.w400;
      }
    }
    return null;
  }

  // 동적 총평 텍스트 생성
  Map<String, String?> _getDynamicSummaryText(int score) {
    final now = DateTime.now();
    
    // Date-based seed for daily variation
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final summarySeed = dateSeed + score + 50;
    final randomIndex = (summarySeed % 1000) / 1000.0;
    
    final highSummaries = [
      {'text': '특별한 에너지가\n넘치는 날', 'emoji': '✨'},
      {'text': '행운이 함께하는\n황금 같은 하루', 'emoji': '🌟'},
      {'text': '모든 것이 순조로운\n완벽한 타이밍', 'emoji': '🎯'},
      {'text': '창의력이 폭발하는\n영감의 날', 'emoji': '💡'},
      {'text': '새로운 가능성이\n열리는 시간', 'emoji': '🚀'},
      {'text': '최고의 컨디션으로\n빛나는 순간', 'emoji': '⭐'},
      {'text': '도전이 성공으로\n이어지는 날', 'emoji': '🏆'},
      {'text': '긍정 에너지가\n가득한 하루', 'emoji': '🌈'}
    ];
    
    final midSummaries = [
      {'text': '차분하고 안정적인\n하루', 'emoji': '☁️'},
      {'text': '평온함 속에서\n찾는 소중함', 'emoji': '🍃'},
      {'text': '균형이 잡힌\n조화로운 시간', 'emoji': '⚖️'},
      {'text': '작은 행복들이\n모이는 날', 'emoji': '🌸'},
      {'text': '자신만의 리듬으로\n흘러가는 하루', 'emoji': '🎵'},
      {'text': '따뜻한 마음으로\n채우는 시간', 'emoji': '☕'},
      {'text': '여유롭게 즐기는\n일상의 아름다움', 'emoji': '🌺'},
      {'text': '내면의 평화를\n느끼는 날', 'emoji': '🕊️'}
    ];
    
    final lowSummaries = [
      {'text': '천천히 가도\n괜찮은 날', 'emoji': '🌙'},
      {'text': '휴식이 필요한\n자신을 돌보는 시간', 'emoji': '🛌'},
      {'text': '충전의 시간으로\n삼는 하루', 'emoji': '🔋'},
      {'text': '조용히 내면을\n들여다보는 날', 'emoji': '🤲'},
      {'text': '작은 것에서\n위로를 찾는 시간', 'emoji': '🕯️'},
      {'text': '나를 이해하고\n받아들이는 날', 'emoji': '💙'},
      {'text': '힘든 순간도\n소중한 경험으로', 'emoji': '🌱'},
      {'text': '내일을 위한\n준비의 시간', 'emoji': '🌅'}
    ];
    
    if (score >= 80) {
      final index = (randomIndex * highSummaries.length).floor();
      return highSummaries[index];
    } else if (score >= 60) {
      final index = (randomIndex * midSummaries.length).floor();
      return midSummaries[index];
    } else {
      final index = (randomIndex * lowSummaries.length).floor();
      return lowSummaries[index];
    }
  }

  // 동적 행운 아이템 생성
  List<String> _getDynamicLuckyItems() {
    final now = DateTime.now();
    
    // Date-based seed for daily variation
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final luckySeed = dateSeed + 200;
    final randomIndex = (luckySeed % 1000) / 1000.0;
    
    final colors = ['하늘색', '분홍색', '연두색', '보라색', '노란색', '주황색', '민트색', '라벤더색'];
    final numbers = [3, 7, 9, 11, 13, 17, 21, 23];
    final times = ['오전 8-10시', '오후 2-4시', '저녁 6-8시', '오전 10-12시', '오후 4-6시', '저녁 8-10시', '오전 6-8시', '오후 12-2시'];
    
    final colorIndex = (randomIndex * colors.length).floor();
    final numberIndex = ((randomIndex * 1000) % numbers.length).floor();
    final timeIndex = ((randomIndex * 10000) % times.length).floor();
    
    return [
      '색상: ${colors[colorIndex]}',
      '숫자: ${numbers[numberIndex]}',
      '시간: ${times[timeIndex]}'
    ];
  }

  // 동적 조언 텍스트 생성
  String _getDynamicAdviceText(int score) {
    final now = DateTime.now();
    
    // Date-based seed for daily variation
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final adviceSeed = dateSeed + score + 150;
    final randomIndex = (adviceSeed % 1000) / 1000.0;
    
    final highAdvices = [
      '무엇이든 도전하세요',
      '적극적으로 행동할 때입니다',
      '새로운 시도를 해보세요',
      '자신감을 갖고 앞으로 나아가세요',
      '기회를 놓치지 마세요',
      '창의적인 아이디어를 실행해보세요',
      '리더십을 발휘해보세요',
      '소통을 통해 더 큰 성과를'
    ];
    
    final midAdvices = [
      '신중하게 행동하세요',
      '차근차근 준비하며 나아가세요',
      '주변의 조언에 귀 기울이세요',
      '균형을 맞춰가며 진행하세요',
      '꾸준함이 가장 큰 힘입니다',
      '작은 실천부터 시작해보세요',
      '감사한 마음으로 하루를 보내세요',
      '협력을 통해 더 좋은 결과를'
    ];
    
    final lowAdvices = [
      '충분히 휴식을 취하세요',
      '자신에게 너그러운 마음을 가지세요',
      '무리하지 말고 천천히 가세요',
      '주변의 도움을 받아보세요',
      '작은 변화부터 시작해보세요',
      '내면의 평화를 찾아보세요',
      '건강 관리에 신경 쓰세요',
      '긍정적인 마음가짐을 유지하세요'
    ];
    
    if (score >= 80) {
      final index = (randomIndex * highAdvices.length).floor();
      return highAdvices[index];
    } else if (score >= 60) {
      final index = (randomIndex * midAdvices.length).floor();
      return midAdvices[index];
    } else {
      final index = (randomIndex * lowAdvices.length).floor();
      return lowAdvices[index];
    }
  }

  // 동적 주의사항 텍스트 생성
  String _getDynamicCautionText(int score) {
    final now = DateTime.now();
    
    // Date-based seed for daily variation
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final cautionSeed = dateSeed + score + 100;
    final randomIndex = (cautionSeed % 1000) / 1000.0;
    
    final highScoreCautions = [
      '과도한 자신감은\n경계하세요',
      '성급한 판단보다는\n신중함을 선택하세요',
      '좋은 기운에 취하지 말고\n겸손함을 유지하세요',
      '모든 것이 순조로워도\n방심하지 마세요',
      '타인의 조언도\n겸허히 들어보세요',
      '완벽을 추구하다\n중요한 것을 놓칠 수 있어요',
      '에너지가 넘쳐도\n무리는 금물입니다',
      '작은 실수가\n큰 문제가 될 수 있으니'
    ];
    
    final midScoreCautions = [
      '충동적인 결정은\n피하세요',
      '서두르지 말고\n천천히 생각해보세요',
      '감정에 휩쓸리기보다는\n이성적인 판단을',
      '작은 변화에도\n민감하게 반응하지 마세요',
      '타인의 말에\n너무 흔들리지 마세요',
      '계획 없는 행동은\n후회를 가져올 수 있어요',
      '피곤할 때의 결정은\n미루는 것이 좋아요',
      '스트레스를 받더라도\n침착함을 유지하세요'
    ];
    
    final lowScoreCautions = [
      '무리하지 말고\n충분히 쉬세요',
      '부정적인 생각에\n빠지지 않도록 주의',
      '혼자 끙끙 앓지 말고\n도움을 요청하세요',
      '건강 관리에\n특별히 신경 쓰세요',
      '작은 일에도\n예민하게 반응할 수 있어요',
      '우울한 기분이 들면\n밖으로 나가보세요',
      '중요한 결정은\n컨디션이 좋을 때',
      '완벽하려 하지 말고\n자신에게 관대하게'
    ];
    
    if (score >= 80) {
      final index = (randomIndex * highScoreCautions.length).floor();
      return highScoreCautions[index];
    } else if (score >= 60) {
      final index = (randomIndex * midScoreCautions.length).floor();
      return midScoreCautions[index];
    } else {
      final index = (randomIndex * lowScoreCautions.length).floor();
      return lowScoreCautions[index];
    }
  }

  TextAlign? _parseTextAlign(dynamic align) {
    if (align == null) return null;
    if (align is String) {
      switch (align) {
        case 'left': return TextAlign.left;
        case 'right': return TextAlign.right;
        case 'center': return TextAlign.center;
        case 'justify': return TextAlign.justify;
        default: return TextAlign.center;
      }
    }
    return null;
  }
}

/// Provider 정의
final fortuneStoryProvider = StateNotifierProvider<FortuneStoryNotifier, FortuneStoryState>((ref) {
  return FortuneStoryNotifier(ref);
});