import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/weather_service.dart';
import '../../screens/home/fortune_story_viewer.dart';
import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../core/utils/logger.dart';
import 'auth_provider.dart';

/// 운세 스토리 상태
class FortuneStoryState {
  final bool isLoading;
  final List<StorySegment>? segments;
  final WeatherInfo? weather;
  final String? error;

  const FortuneStoryState({
    this.isLoading = false,
    this.segments,
    this.weather,
    this.error,
  });

  FortuneStoryState copyWith({
    bool? isLoading,
    List<StorySegment>? segments,
    WeatherInfo? weather,
    String? error,
  }) {
    return FortuneStoryState(
      isLoading: isLoading ?? this.isLoading,
      segments: segments ?? this.segments,
      weather: weather ?? this.weather,
      error: error ?? this.error,
    );
  }
}

/// 운세 스토리 생성 Provider
class FortuneStoryNotifier extends StateNotifier<FortuneStoryState> {
  final Ref ref;
  final SupabaseClient _supabase = Supabase.instance.client;

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

      state = state.copyWith(
        isLoading: false,
        segments: segments,
      );

      Logger.info('✅ Fortune story generated successfully');
    } catch (e) {
      Logger.error('❌ Error generating fortune story: $e');
      
      // 에러 발생 시 기본 스토리 생성
      final defaultSegments = _createDefaultStory(
        userName: userName,
        fortune: fortune,
        userProfile: userProfile,
      );
      
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
      // Supabase Edge Function 호출
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
      );

      // 응답 전체를 로깅
      Logger.info('🔍 GPT Response received:');
      Logger.info('Response type: ${response.data.runtimeType}');
      Logger.info('Response data: ${response.data}');
      
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
          Logger.info('Segments less than 10, expanding...');
          return _expandStorySegments(segmentsData, userName, fortune);
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
    } catch (e) {
      Logger.error('GPT API call failed: $e');
    }

    // GPT 실패 시 확장된 기본 스토리 반환
    return _createExtendedDefaultStory(userName: userName, fortune: fortune, userProfile: userProfile);
  }

  /// 기본 스토리 생성 (GPT 실패 시)
  List<StorySegment> _createDefaultStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) {
    final now = DateTime.now();
    final score = fortune.overallScore ?? 75;
    List<StorySegment> segments = [];

    // 1. 인사
    segments.add(StorySegment(
      subtitle: '인사',
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      subtitle: '오늘은',
      text: '${now.month}월 ${now.day}일\n${_getWeekdayKorean(now.weekday)}',
      fontSize: 28,
      fontWeight: FontWeight.w300,
    ));

    // 3. 총평
    segments.add(StorySegment(
      subtitle: '오늘의 총평',
      text: score >= 80 
          ? '특별한 에너지가\n넘치는 날'
          : score >= 60
          ? '차분하고 안정적인\n하루'
          : '천천히 가도\n괜찮은 날',
      fontSize: 26,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));

    // 4. 핵심 운세
    segments.add(StorySegment(
      subtitle: '운세 이야기',
      text: _getShortFortuneText(score, 1),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 5. 오전 운세
    segments.add(StorySegment(
      subtitle: '오전 운세',
      text: _getShortFortuneText(score, 2),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 6. 오후 운세
    segments.add(StorySegment(
      subtitle: '오후 운세',
      text: _getShortFortuneText(score, 3),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

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

    // 7. 주의사항
    String cautionText = fortune.metadata?['caution'] ?? 
        (score >= 80 ? '과도한 자신감은\n경계하세요' : '충동적인 결정은\n피하세요');
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
      luckyTexts = ['색상: 하늘색', '숫자: 7', '시간: 오후 2-4시'];
    }
    segments.add(StorySegment(
      subtitle: '🍀 행운',
      text: luckyTexts.join('\n'),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ));

    // 9. 조언
    String adviceText = fortune.metadata?['advice'] ?? 
        (score >= 80 
            ? '무엇이든 도전하세요'
            : '신중하게 행동하세요');
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
      subtitle: '인사',
      text: userName.isNotEmpty ? userName + '님' : '오늘의 주인공',
      fontSize: 36,
      fontWeight: FontWeight.w200,
    ));

    // 2. 날짜
    segments.add(StorySegment(
      subtitle: '오늘은',
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
      subtitle: '오늘의 총평',
      text: energyText,
      fontSize: 26,
      fontWeight: FontWeight.w300,
      emoji: score >= 80 ? '✨' : score >= 60 ? '☁️' : '🌙',
    ));

    // 4-6. 운세 상세 (3페이지)
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
          segments.add(StorySegment(
            text: chunk + (chunk.endsWith('.') ? '' : '.'),
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ));
        }
      }
    } else {
      // 점수 기반 기본 텍스트
      segments.add(StorySegment(
        text: score >= 80 
            ? '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다.\n\n용기를 내어\n도전해보세요.'
            : '평범해 보이는\n오늘 하루지만\n\n작은 것에서\n큰 의미를\n발견하게 될 거예요.',
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      
      segments.add(StorySegment(
        text: score >= 80
            ? '주변 사람들과의\n관계에서\n좋은 소식이\n들려올 것입니다.\n\n마음을 열고\n소통해보세요.'
            : '일상 속에서\n예상치 못한\n즐거움을\n발견하게 됩니다.\n\n긍정적인 마음을\n유지하세요.',
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
      
      segments.add(StorySegment(
        text: score >= 80
            ? '오늘 내린 결정이\n미래에 큰\n영향을 미칠 것입니다.\n\n자신감을 가지고\n앞으로 나아가세요.'
            : '차근차근\n계획을 세우고\n실행한다면\n\n원하는 결과를\n얻을 수 있습니다.',
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ));
    }

    // 7. 주의사항
    String cautionText = fortune.metadata?['caution'] ?? 
        (score >= 80 ? '과도한 자신감은 경계하세요.' : '충동적인 결정은 피하세요.');
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

    // 9. 조언
    String adviceText = fortune.metadata?['advice'] ?? 
        (score >= 80 
            ? '무엇이든 도전하세요.\n큰 성과가 기대됩니다.'
            : '신중하게 행동하고\n무리하지 마세요.');
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
        segments.add(StorySegment(
          text: '특별한 팁:\n${fortune.metadata?['special_tip'] ?? "오늘은 자신을 믿고 앞으로 나아가세요"}',
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ));
      } else {
        // 기본 추가 페이지
        segments.add(StorySegment(
          text: '...',
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ));
      }
    }

    return segments;
  }

  // 짧은 운세 텍스트 생성
  String _getShortFortuneText(int score, int part) {
    if (part == 1) {
      // 핵심 운세
      if (score >= 80) {
        return '새로운 기회가\n찾아올 것입니다';
      } else if (score >= 60) {
        return '작은 것에서\n큰 의미를 발견하세요';
      } else {
        return '조금 힘든 하루지만\n성장의 과정입니다';
      }
    } else if (part == 2) {
      // 오전 운세
      if (score >= 80) {
        return '에너지가 넘치는 오전\n적극적으로 행동하세요';
      } else if (score >= 60) {
        return '차분한 오전\n계획을 세워보세요';
      } else {
        return '천천히 시작하세요\n서두르지 마세요';
      }
    } else {
      // 오후 운세
      if (score >= 80) {
        return '좋은 소식이 들려올 시간\n마음을 열고 소통하세요';
      } else if (score >= 60) {
        return '예상치 못한 즐거움\n긍정적인 마음 유지';
      } else {
        return '혼자만의 시간 필요\n자신을 돌보세요';
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