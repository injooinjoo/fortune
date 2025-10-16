import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/utils/logger.dart';

/// 이미지 분석 결과 모델
class ImageAnalysisResult {
    final List<FaceDetection> faces;
    final List<String> labels;
    final List<DominantColor> colors;
    final SafeSearchAnnotation safeSearch;
    final String? webDetection;
    final EmotionalAnalysis? emotionalAnalysis;
    final StyleAnalysis? styleAnalysis;

    ImageAnalysisResult({
      required this.faces,
      required this.labels,
      required this.colors,
      required this.safeSearch,
      this.webDetection,
      this.emotionalAnalysis,
      this.styleAnalysis,
    });
}

/// 얼굴 감지 정보
class FaceDetection {
    final String emotion; // joy, sorrow, anger, surprise
    final double confidence;
    final int? age;
    final String? gender;
    final Map<String, double> emotions;

    FaceDetection({
      required this.emotion,
      required this.confidence,
      this.age,
      this.gender,
      required this.emotions,
    });
}

/// 주요 색상 정보
class DominantColor {
    final int red;
    final int green;
    final int blue;
    final double score;
    final double pixelFraction;

    DominantColor({
      required this.red,
      required this.green,
      required this.blue,
      required this.score,
      required this.pixelFraction,
    });

    String get hexColor => '#${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
}

/// 안전 검색 주석
class SafeSearchAnnotation {
    final String adult;
    final String violence;
    final String racy;

    SafeSearchAnnotation({
      required this.adult,
      required this.violence,
      required this.racy,
    });

    bool get isSafe => 
        adult != 'LIKELY' && adult != 'VERY_LIKELY' &&
        violence != 'LIKELY' && violence != 'VERY_LIKELY' &&
        racy != 'LIKELY' && racy != 'VERY_LIKELY';
}

/// 감정 분석 결과
class EmotionalAnalysis {
    final String dominantEmotion;
    final Map<String, double> emotionScores;
    final String moodDescription;

    EmotionalAnalysis({
      required this.dominantEmotion,
      required this.emotionScores,
      required this.moodDescription,
    });
}

/// 스타일 분석 결과
class StyleAnalysis {
    final String fashionStyle;
    final List<String> detectedItems;
    final String colorPalette;
    final String overallVibe;

    StyleAnalysis({
      required this.fashionStyle,
      required this.detectedItems,
      required this.colorPalette,
      required this.overallVibe,
    });
}

/// Vision API를 사용한 이미지 분석 서비스
class VisionApiService {
  static final VisionApiService _instance = VisionApiService._internal();
  factory VisionApiService() => _instance;
  VisionApiService._internal();

  // Google Cloud Vision API 키 (실제 사용시 환경변수로 관리)
  static const String _apiKey = 'YOUR_GOOGLE_CLOUD_VISION_API_KEY';
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';

  /// 이미지 분석 실행
  Future<ImageAnalysisResult?> analyzeImage(XFile imageFile) async {
    try {
      // 이미지를 base64로 인코딩
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // API 요청 생성
      final request = {
        "requests": [
          {
            "image": {
              "content": base64Image
            },
            "features": [
              {"type": "FACE_DETECTION", "maxResults": 10},
              {"type": "LABEL_DETECTION", "maxResults": 20},
              {"type": "IMAGE_PROPERTIES", "maxResults": 10},
              {"type": "SAFE_SEARCH_DETECTION"},
              {"type": "WEB_DETECTION", "maxResults": 5},
            ]
          }
        ]
      };

      // API 호출
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responses = data['responses'][0];

        // 결과 파싱
        return _parseAnalysisResult(responses);
      } else {
        Logger.warning('[VisionAPIService] Vision API 요청 실패 (이미지 분석 불가): ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Logger.warning('[VisionAPIService] 이미지 분석 실패 (기능 비활성화): $e');
      return null;
    }
  }

  /// 여러 이미지 분석
  Future<List<ImageAnalysisResult>> analyzeMultipleImages(
    List<XFile> imageFiles,
  ) async {
    final results = <ImageAnalysisResult>[];
    
    for (final imageFile in imageFiles) {
      final result = await analyzeImage(imageFile);
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }

  /// API 응답 파싱
  ImageAnalysisResult _parseAnalysisResult(Map<String, dynamic> response) {
    // 얼굴 감지 파싱
    final faces = <FaceDetection>[];
    if (response['faceAnnotations'] != null) {
      for (final face in response['faceAnnotations']) {
        faces.add(FaceDetection(
          emotion: _getDominantEmotion(face),
          confidence: (face['detectionConfidence'] ?? 0).toDouble(),
          emotions: {
            'joy': _getLikelihood(face['joyLikelihood']),
            'sorrow': _getLikelihood(face['sorrowLikelihood']),
            'anger': _getLikelihood(face['angerLikelihood']),
            'surprise': _getLikelihood(face['surpriseLikelihood']),
          },
        ));
      }
    }

    // 라벨 파싱
    final labels = <String>[];
    if (response['labelAnnotations'] != null) {
      for (final label in response['labelAnnotations']) {
        labels.add(label['description']);
      }
    }

    // 색상 파싱
    final colors = <DominantColor>[];
    if (response['imagePropertiesAnnotation'] != null) {
      final colorInfo = response['imagePropertiesAnnotation']['dominantColors'];
      if (colorInfo != null && colorInfo['colors'] != null) {
        for (final color in colorInfo['colors']) {
          final rgb = color['color'];
          colors.add(DominantColor(
            red: (rgb['red'] ?? 0).toInt(),
            green: (rgb['green'] ?? 0).toInt(),
            blue: (rgb['blue'] ?? 0).toInt(),
            score: (color['score'] ?? 0).toDouble(),
            pixelFraction: (color['pixelFraction'] ?? 0).toDouble(),
          ));
        }
      }
    }

    // 안전 검색 파싱
    final safeSearch = SafeSearchAnnotation(
      adult: response['safeSearchAnnotation']?['adult'] ?? 'UNKNOWN',
      violence: response['safeSearchAnnotation']?['violence'] ?? 'UNKNOWN',
      racy: response['safeSearchAnnotation']?['racy'] ?? 'UNKNOWN',
    );

    // 추가 분석 생성
    final emotionalAnalysis = _generateEmotionalAnalysis(faces);
    final styleAnalysis = _generateStyleAnalysis(labels, colors);

    return ImageAnalysisResult(
      faces: faces,
      labels: labels,
      colors: colors,
      safeSearch: safeSearch,
      emotionalAnalysis: emotionalAnalysis,
      styleAnalysis: styleAnalysis,
    );
  }

  /// 주요 감정 추출
  String _getDominantEmotion(Map<String, dynamic> face) {
    final emotions = {
      'joy': _getLikelihood(face['joyLikelihood']),
      'sorrow': _getLikelihood(face['sorrowLikelihood']),
      'anger': _getLikelihood(face['angerLikelihood']),
      'surprise': _getLikelihood(face['surpriseLikelihood']),
    };

    String dominantEmotion = 'neutral';
    double maxScore = 0;

    emotions.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantEmotion = emotion;
      }
    });

    return dominantEmotion;
  }

  /// 가능성을 숫자로 변환
  double _getLikelihood(String? likelihood) {
    switch (likelihood) {
      case 'VERY_LIKELY':
        return 1.0;
      case 'LIKELY':
        return 0.75;
      case 'POSSIBLE':
        return 0.5;
      case 'UNLIKELY':
        return 0.25;
      case 'VERY_UNLIKELY':
        return 0.0;
      default:
        return 0.0;
    }
  }

  /// 감정 분석 생성
  EmotionalAnalysis? _generateEmotionalAnalysis(List<FaceDetection> faces) {
    if (faces.isEmpty) return null;

    // 모든 얼굴의 감정 평균 계산
    final avgEmotions = <String, double>{};
    for (final emotion in ['joy', 'sorrow', 'anger', 'surprise']) {
      double sum = 0;
      for (final face in faces) {
        sum += face.emotions[emotion] ?? 0;
      }
      avgEmotions[emotion] = sum / faces.length;
    }

    // 주요 감정 결정
    String dominantEmotion = 'neutral';
    double maxScore = 0;
    avgEmotions.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantEmotion = emotion;
      }
    });

    // 무드 설명 생성
    String moodDescription;
    if (dominantEmotion == 'joy') {
      moodDescription = '밝고 긍정적인 에너지가 느껴집니다';
    } else if (dominantEmotion == 'sorrow') {
      moodDescription = '차분하고 사색적인 분위기입니다';
    } else if (dominantEmotion == 'anger') {
      moodDescription = '강렬하고 열정적인 모습입니다';
    } else if (dominantEmotion == 'surprise') {
      moodDescription = '호기심 많고 활발한 성격이 보입니다';
    } else {
      moodDescription = '안정적이고 균형잡힌 인상입니다';
    }

    return EmotionalAnalysis(
      dominantEmotion: dominantEmotion,
      emotionScores: avgEmotions,
      moodDescription: moodDescription,
    );
  }

  /// 스타일 분석 생성
  StyleAnalysis? _generateStyleAnalysis(
    List<String> labels,
    List<DominantColor> colors,
  ) {
    // 패션 관련 라벨 추출
    final fashionItems = <String>[];
    final fashionKeywords = [
      'clothing', 'fashion', 'dress', 'shirt', 'pants', 'jeans',
      'suit', 'casual', 'formal', 'style', 'outfit', 'accessories'
    ];
    
    for (final label in labels) {
      for (final keyword in fashionKeywords) {
        if (label.toLowerCase().contains(keyword)) {
          fashionItems.add(label);
          break;
        }
      }
    }

    // 스타일 결정
    String fashionStyle = '캐주얼';
    if (labels.any((l) => l.toLowerCase().contains('formal')) ||
        labels.any((l) => l.toLowerCase().contains('suit'))) {
      fashionStyle = '포멀';
    } else if (labels.any((l) => l.toLowerCase().contains('sports')) ||
               labels.any((l) => l.toLowerCase().contains('athletic'))) {
      fashionStyle = '스포티';
    } else if (labels.any((l) => l.toLowerCase().contains('vintage')) ||
               labels.any((l) => l.toLowerCase().contains('retro'))) {
      fashionStyle = '빈티지';
    }

    // 색상 팔레트 분석
    String colorPalette = '모노톤';
    if (colors.isNotEmpty) {
      final avgBrightness = colors.fold<double>(
        0,
        (sum, color) => sum + (color.red + color.green + color.blue) / 3,
      ) / colors.length;
      
      if (avgBrightness > 200) {
        colorPalette = '밝은 톤';
      } else if (avgBrightness < 100) {
        colorPalette = '어두운 톤';
      } else {
        colorPalette = '중간 톤';
      }
    }

    // 전체적인 분위기
    String overallVibe = '편안한';
    if (labels.any((l) => l.toLowerCase().contains('outdoor'))) {
      overallVibe = '활동적인';
    } else if (labels.any((l) => l.toLowerCase().contains('night')) ||
               labels.any((l) => l.toLowerCase().contains('party'))) {
      overallVibe = '화려한';
    } else if (labels.any((l) => l.toLowerCase().contains('nature'))) {
      overallVibe = '자연친화적인';
    }

    return StyleAnalysis(
      fashionStyle: fashionStyle,
      detectedItems: fashionItems,
      colorPalette: colorPalette,
      overallVibe: overallVibe,
    );
  }

  /// 소개팅 매칭 분석
  Future<BlindDateAnalysis> analyzeForBlindDate({
    required List<XFile> myPhotos,
    List<XFile>? partnerPhotos,
  }) async {
    // 내 사진 분석
    final myResults = await analyzeMultipleImages(myPhotos);
    
    // 상대방 사진 분석 (있는 경우)
    List<ImageAnalysisResult>? partnerResults;
    if (partnerPhotos != null && partnerPhotos.isNotEmpty) {
      partnerResults = await analyzeMultipleImages(partnerPhotos);
    }

    // 분석 결과 종합
    return _generateBlindDateAnalysis(myResults, partnerResults);
  }

  /// 소개팅 분석 결과 생성
  BlindDateAnalysis _generateBlindDateAnalysis(
    List<ImageAnalysisResult> myResults,
    List<ImageAnalysisResult>? partnerResults,
  ) {
    // 내 스타일 분석
    final myStyle = _aggregateStyleAnalysis(myResults);
    final myEmotion = _aggregateEmotionalAnalysis(myResults);
    
    // 상대방 스타일 분석 (있는 경우)
    String? partnerStyle;
    String? partnerEmotion;
    if (partnerResults != null) {
      partnerStyle = _aggregateStyleAnalysis(partnerResults);
      partnerEmotion = _aggregateEmotionalAnalysis(partnerResults);
    }

    // 매칭 점수 계산
    final matchingScore = _calculateMatchingScore(
      myStyle: myStyle,
      myEmotion: myEmotion,
      partnerStyle: partnerStyle,
      partnerEmotion: partnerEmotion,
    );

    // 조언 생성
    final advice = _generateDateAdvice(myResults, partnerResults);

    return BlindDateAnalysis(
      myStyle: myStyle,
      myPersonality: myEmotion,
      partnerStyle: partnerStyle,
      partnerPersonality: partnerEmotion,
      matchingScore: matchingScore,
      firstImpressionTips: advice.firstImpressionTips,
      conversationTopics: advice.conversationTopics,
      styleRecommendations: advice.styleRecommendations,
    );
  }

  /// 스타일 종합 분석
  String _aggregateStyleAnalysis(List<ImageAnalysisResult> results) {
    final styles = <String, int>{};
    
    for (final result in results) {
      if (result.styleAnalysis != null) {
        final style = result.styleAnalysis!.fashionStyle;
        styles[style] = (styles[style] ?? 0) + 1;
      }
    }
    
    if (styles.isEmpty) return '캐주얼';
    
    // 가장 많이 나온 스타일 반환
    return styles.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 감정 종합 분석
  String _aggregateEmotionalAnalysis(List<ImageAnalysisResult> results) {
    final emotions = <String, double>{};
    
    for (final result in results) {
      if (result.emotionalAnalysis != null) {
        result.emotionalAnalysis!.emotionScores.forEach((emotion, score) {
          emotions[emotion] = (emotions[emotion] ?? 0) + score;
        });
      }
    }
    
    if (emotions.isEmpty) return '차분한';
    
    // 평균 감정 계산
    final avgEmotions = emotions.map((key, value) => 
        MapEntry(key, value / results.length));
    
    // 주요 감정을 성격으로 변환
    final dominantEmotion = avgEmotions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    switch (dominantEmotion) {
      case 'joy':
        return '밝고 긍정적인';
      case 'sorrow':
        return '차분하고 사색적인';
      case 'anger':
        return '열정적이고 적극적인';
      case 'surprise':
        return '호기심 많고 활발한';
      default:
        return '안정적이고 균형잡힌';
    }
  }

  /// 매칭 점수 계산
  int _calculateMatchingScore({
    required String myStyle,
    required String myEmotion,
    String? partnerStyle,
    String? partnerEmotion,
  }) {
    if (partnerStyle == null || partnerEmotion == null) {
      // 상대방 정보가 없으면 내 정보만으로 기본 점수
      return 60 + (myEmotion.contains('긍정') ? 10 : 0);
    }
    
    int score = 50;
    
    // 스타일 호환성
    if (myStyle == partnerStyle) {
      score += 20; // 같은 스타일
    } else if (_areStylesCompatible(myStyle, partnerStyle)) {
      score += 10; // 호환되는 스타일
    }
    
    // 성격 호환성
    if (_arePersonalitiesCompatible(myEmotion, partnerEmotion)) {
      score += 30;
    }
    
    return score.clamp(0, 100);
  }

  /// 스타일 호환성 확인
  bool _areStylesCompatible(String style1, String style2) {
    final compatible = {
      '캐주얼': ['스포티', '빈티지'],
      '포멀': ['캐주얼'],
      '스포티': ['캐주얼'],
      '빈티지': ['캐주얼'],
    };
    
    return compatible[style1]?.contains(style2) ?? false;
  }

  /// 성격 호환성 확인
  bool _arePersonalitiesCompatible(String personality1, String personality2) {
    // 보완적인 성격 조합
    if (personality1.contains('긍정') && personality2.contains('차분')) return true;
    if (personality1.contains('활발') && personality2.contains('안정')) return true;
    if (personality1.contains('열정') && personality2.contains('사색')) return true;
    
    // 비슷한 성격도 좋음
    if (personality1 == personality2) return true;
    
    return false;
  }

  /// 데이트 조언 생성
  DateAdvice _generateDateAdvice(
    List<ImageAnalysisResult> myResults,
    List<ImageAnalysisResult>? partnerResults,
  ) {
    final tips = <String>[];
    final topics = <String>[];
    final styleRecs = <String>[];
    
    // 내 분석 결과 기반 조언
    for (final result in myResults) {
      // 감정 기반 조언
      if (result.emotionalAnalysis != null) {
        final emotion = result.emotionalAnalysis!.dominantEmotion;
        if (emotion == 'joy') {
          tips.add('밝은 미소를 유지하세요');
        } else if (emotion == 'neutral') {
          tips.add('좀 더 편안하게 웃어보세요');
        }
      }
      
      // 라벨 기반 대화 주제
      for (final label in result.labels) {
        if (label.toLowerCase().contains('travel')) {
          topics.add('여행');
        } else if (label.toLowerCase().contains('food')) {
          topics.add('맛집');
        } else if (label.toLowerCase().contains('nature')) {
          topics.add('자연/힐링');
        } else if (label.toLowerCase().contains('sports')) {
          topics.add('운동/건강');
        }
      }
      
      // 스타일 조언
      if (result.styleAnalysis != null) {
        final style = result.styleAnalysis!.fashionStyle;
        if (style == '캐주얼') {
          styleRecs.add('편안하면서도 깔끔한 스타일 유지');
        } else if (style == '포멀') {
          styleRecs.add('좀 더 편안한 스타일도 시도해보세요');
        }
      }
    }
    
    // 중복 제거
    final uniqueTips = tips.toSet().toList();
    final uniqueTopics = topics.toSet().toList();
    final uniqueStyleRecs = styleRecs.toSet().toList();
    
    // 기본 조언 추가
    if (uniqueTips.isEmpty) {
      uniqueTips.addAll([
        '자연스러운 미소 유지하기',
        '상대방 이야기에 집중하기',
        '긍정적인 에너지 보여주기',
      ]);
    }
    
    if (uniqueTopics.isEmpty) {
      uniqueTopics.addAll([
        '취미와 관심사',
        '최근 본 영화나 드라마',
        '좋아하는 음식',
      ]);
    }
    
    if (uniqueStyleRecs.isEmpty) {
      uniqueStyleRecs.addAll([
        '깔끔하고 단정한 스타일',
        '자신감 있는 컬러 선택',
        '편안한 신발 착용',
      ]);
    }
    
    return DateAdvice(
      firstImpressionTips: uniqueTips,
      conversationTopics: uniqueTopics,
      styleRecommendations: uniqueStyleRecs,
    );
  }
}

/// 소개팅 분석 결과
class BlindDateAnalysis {
  final String myStyle;
  final String myPersonality;
  final String? partnerStyle;
  final String? partnerPersonality;
  final int matchingScore;
  final List<String> firstImpressionTips;
  final List<String> conversationTopics;
  final List<String> styleRecommendations;

  BlindDateAnalysis({
    required this.myStyle,
    required this.myPersonality,
    this.partnerStyle,
    this.partnerPersonality,
    required this.matchingScore,
    required this.firstImpressionTips,
    required this.conversationTopics,
    required this.styleRecommendations,
  });
}

/// 데이트 조언
class DateAdvice {
  final List<String> firstImpressionTips;
  final List<String> conversationTopics;
  final List<String> styleRecommendations;

  DateAdvice({
    required this.firstImpressionTips,
    required this.conversationTopics,
    required this.styleRecommendations,
  });
}