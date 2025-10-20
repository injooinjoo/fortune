import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../screens/home/fortune_story_viewer.dart';
import '../../../services/weather_service.dart';
import '../../../domain/entities/fortune.dart' as fortune_entity;
import '../../../domain/entities/user_profile.dart';
import '../../../core/utils/logger.dart';
import 'dart:math' as math;

/// GPT를 통한 스토리 생성
class StoryGenerator {
  final SupabaseClient _supabase;
  Map<String, dynamic>? lastResponseData;

  StoryGenerator(this._supabase);

  /// GPT를 통한 스토리 생성 (10페이지 분량)
  Future<List<StorySegment>> generateWithGPT({
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
          return FunctionResponse(
            data: {
              'segments': null,
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
      lastResponseData = response.data as Map<String, dynamic>?;

      // Check for both 'segments' and 'storySegments' keys
      if (response.data != null && (response.data['segments'] != null || response.data['storySegments'] != null)) {
        // GPT 응답을 StorySegment 리스트로 변환
        dynamic segmentsRaw = response.data['segments'] ?? response.data['storySegments'];
        Logger.info('Segments raw type: ${segmentsRaw.runtimeType}');
        Logger.info('Segments raw data: $segmentsRaw');

        List<dynamic> segmentsData = _extractSegmentsData(segmentsRaw);

        // 최소 10페이지 보장
        if (segmentsData.length < 10) {
          Logger.info('⚠️ Segments less than 10 (${segmentsData.length}), returning empty to trigger fallback');
          return [];
        }

        // 각 segment 변환
        return _parseSegments(segmentsData);
      } else {
        Logger.error('No segments in response or response is null');
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Edge Function call failed: $e');
      Logger.error('Stack trace: $stackTrace');

      if (e is TimeoutException) {
        Logger.error('⏰ Timeout occurred - Edge Function may be taking too long');
      }
    }

    // GPT 실패 시 빈 리스트 반환 (fallback 트리거)
    return [];
  }

  /// segmentsRaw에서 List<dynamic> 추출
  List<dynamic> _extractSegmentsData(dynamic segmentsRaw) {
    if (segmentsRaw is List) {
      Logger.info('Segments is List with ${segmentsRaw.length} items');
      return segmentsRaw;
    } else if (segmentsRaw is Map) {
      // Map인 경우 다양한 형식 처리
      if (segmentsRaw['story'] != null && segmentsRaw['story'] is List) {
        final story = segmentsRaw['story'] as List;
        Logger.info('Found story array in Map with ${story.length} items');
        return story;
      } else if (segmentsRaw['pages'] != null && segmentsRaw['pages'] is List) {
        final pages = segmentsRaw['pages'] as List;
        Logger.info('Found pages array in Map with ${pages.length} items');
        return pages;
      } else if (segmentsRaw['segments'] != null && segmentsRaw['segments'] is List) {
        final segments = segmentsRaw['segments'] as List;
        Logger.info('Found segments array in Map with ${segments.length} items');
        return segments;
      } else if (segmentsRaw['page'] != null || segmentsRaw['text'] != null) {
        Logger.info('Single page object detected, this is wrong format from GPT');
        return [];
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
          Logger.info('Extracted ${extractedPages.length} pages from numbered keys');
          return extractedPages;
        } else {
          Logger.info('No valid segment data found');
          return [];
        }
      }
    } else {
      Logger.error('Segments is unexpected type: ${segmentsRaw.runtimeType}');
      return [];
    }
  }

  /// 세그먼트 데이터 파싱
  List<StorySegment> _parseSegments(List<dynamic> segmentsData) {
    List<StorySegment> resultSegments = [];

    for (int i = 0; i < segmentsData.length; i++) {
      try {
        final segment = segmentsData[i];
        Logger.info('Processing segment $i: $segment');
        Logger.info('Segment type: ${segment.runtimeType}');

        if (segment is Map) {
          Logger.info('text field type: ${segment['text']?.runtimeType}');
          Logger.info('text field value: ${segment['text']}');
          Logger.info('fontSize field type: ${segment['fontSize']?.runtimeType}');
          Logger.info('fontSize field value: ${segment['fontSize']}');
          Logger.info('fontWeight field type: ${segment['fontWeight']?.runtimeType}');
          Logger.info('fontWeight field value: ${segment['fontWeight']}');
        }

        // text 필드가 String이 아닌 경우 처리
        String textValue = segment['text']?.toString() ?? '';

        // fontSize 안전하게 처리
        double fontSizeValue = 24;
        if (segment['fontSize'] != null) {
          if (segment['fontSize'] is num) {
            fontSizeValue = (segment['fontSize'] as num).toDouble();
          } else if (segment['fontSize'] is String) {
            fontSizeValue = double.tryParse(segment['fontSize']) ?? 24;
          }
        }

        // fontWeight 안전하게 처리
        FontWeight fontWeightValue = FontWeight.w400;
        try {
          fontWeightValue = _parseFontWeight(segment['fontWeight']) ?? FontWeight.w400;
        } catch (e) {
          Logger.error('Error parsing fontWeight: $e');
        }

        // alignment 안전하게 처리
        TextAlign alignmentValue = TextAlign.center;
        try {
          alignmentValue = _parseTextAlign(segment['alignment']) ?? TextAlign.center;
        } catch (e) {
          Logger.error('Error parsing alignment: $e');
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
        ));
      }
    }

    return resultSegments;
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
