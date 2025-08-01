import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/data/services/fortune_api_service.dart';
import 'package:fortune/core/network/api_client.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late FortuneApiService fortuneApiService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    fortuneApiService = FortuneApiService(mockApiClient);
  });

  group('PersonalityFortune Tests', () {
    const testUserId = 'test-user-123';
    final testDate = DateTime.now();

    group('MBTI Fortune Tests', () {
      test('should generate MBTI fortune successfully', () async {
        // Arrange
        const mbtiType = 'INTJ';
        final params = {
          'personalityType': 'mbti',
          'mbti': mbtiType,
          'name': 'Test User',
          'birthDate': '1990-01-01',
          'gender': 'male',
        };

        final expectedFortune = Fortune(
          id: 'fortune-123',
          userId: testUserId,
          type: 'personality-mbti',
          content: 'Your INTJ fortune for today shows great analytical thinking...',
          createdAt: testDate,
          overallScore: 85,
          additionalInfo: {
            'personalityTraits': ['분석적', '전략적', '독립적'],
            'compatibility': {
              'best': 'ENFP',
              'good': 'ENTP',
              'caution': 'ESFP',
            },
          },
          advice: 'Focus on your strategic planning today',
          tokenCost: 15,
        );

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => {
          'id': expectedFortune.id,
          'user_id': expectedFortune.userId,
          'type': expectedFortune.type,
          'content': expectedFortune.content,
          'created_at': expectedFortune.createdAt.toIso8601String(),
          'overall_score': expectedFortune.overallScore,
          'additional_info': expectedFortune.additionalInfo,
          'metadata': {
            'advice': expectedFortune.advice,
          },
          'token_cost': expectedFortune.tokenCost,
        });

        // Act
        final result = await fortuneApiService.getPersonalityFortune(
          userId: testUserId,
          params: params,
        );

        // Assert
        expect(result.id, equals(expectedFortune.id));
        expect(result.userId, equals(expectedFortune.userId));
        expect(result.type, equals(expectedFortune.type));
        expect(result.content, equals(expectedFortune.content));
        expect(result.overallScore, equals(expectedFortune.overallScore));
        expect(result.additionalInfo?['personalityTraits'], isNotNull);
        expect(result.additionalInfo?['personalityTraits'], hasLength(3));
        expect(result.additionalInfo?['compatibility'], isNotNull);
        expect(result.advice, equals(expectedFortune.advice));
      });

      test('should handle all 16 MBTI types', () async {
        // Arrange
        const mbtiTypes = [
          'INTJ', 'INTP', 'ENTJ', 'ENTP',
          'INFJ', 'INFP', 'ENFJ', 'ENFP',
          'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
          'ISTP', 'ISFP', 'ESTP', 'ESFP'
        ];

        for (final mbtiType in mbtiTypes) {
          final params = {
            'personalityType': 'mbti',
            'mbti': mbtiType,
          };

          when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {
            'id': 'fortune-$mbtiType',
            'user_id': testUserId,
            'type': 'personality-mbti',
            'content': 'Fortune for $mbtiType',
            'created_at': testDate.toIso8601String(),
            'overall_score': 80,
            'token_cost': 15,
          });

          // Act
          final result = await fortuneApiService.getPersonalityFortune(
            userId: testUserId,
            params: params,
          );

          // Assert
          expect(result.content, contains(mbtiType));
          expect(result.type, equals('personality-mbti'));
        }
      });
    });

    group('Blood Type Fortune Tests', () {
      test('should generate blood type fortune successfully', () async {
        // Arrange
        const bloodType = 'A';
        final params = {
          'personalityType': 'blood-type',
          'bloodType': bloodType,
          'name': 'Test User',
          'birthDate': '1990-01-01',
          'gender': 'female',
        };

        final expectedFortune = Fortune(
          id: 'fortune-456',
          userId: testUserId,
          type: 'personality-blood-type',
          content: 'A형의 신중한 성격이 오늘은 큰 도움이 될 것입니다...',
          createdAt: testDate,
          overallScore: 78,
          additionalInfo: {
            'personalityTraits': ['신중함', '꼼꼼함', '책임감'],
            'compatibility': {
              'best': 'O형',
              'good': 'AB형',
              'caution': 'B형',
            },
          },
          advice: '오늘은 세부사항에 주의를 기울이세요',
          tokenCost: 15,
        );

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => {
          'id': expectedFortune.id,
          'user_id': expectedFortune.userId,
          'type': expectedFortune.type,
          'content': expectedFortune.content,
          'created_at': expectedFortune.createdAt.toIso8601String(),
          'overall_score': expectedFortune.overallScore,
          'additional_info': expectedFortune.additionalInfo,
          'metadata': {
            'advice': expectedFortune.advice,
          },
          'token_cost': expectedFortune.tokenCost,
        });

        // Act
        final result = await fortuneApiService.getPersonalityFortune(
          userId: testUserId,
          params: params,
        );

        // Assert
        expect(result.type, equals('personality-blood-type'));
        expect(result.content, contains('A형'));
        expect(result.overallScore, equals(78));
        expect(result.additionalInfo?['personalityTraits'], hasLength(3));
      });

      test('should handle all 4 blood types', () async {
        // Arrange
        const bloodTypes = ['A', 'B', 'O', 'AB'];

        for (final bloodType in bloodTypes) {
          final params = {
            'personalityType': 'blood-type',
            'bloodType': bloodType,
          };

          when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {
            'id': 'fortune-$bloodType',
            'user_id': testUserId,
            'type': 'personality-blood-type',
            'content': 'Fortune for $bloodType type',
            'created_at': testDate.toIso8601String(),
            'overall_score': 75,
            'token_cost': 15,
          });

          // Act
          final result = await fortuneApiService.getPersonalityFortune(
            userId: testUserId,
            params: params,
          );

          // Assert
          expect(result.content, contains(bloodType));
          expect(result.type, equals('personality-blood-type'));
        }
      });
    });

    group('Fortune Entity Tests', () {
      test('should create Fortune entity with all personality fields', () {
        // Arrange & Act
        final fortune = Fortune(
          id: 'test-id',
          userId: testUserId,
          type: 'personality-mbti',
          content: 'Test fortune content',
          createdAt: testDate,
          overallScore: 88,
          additionalInfo: {
            'personalityTraits': ['trait1', 'trait2', 'trait3'],
            'compatibility': {
              'best': 'Type1',
              'good': 'Type2',
              'caution': 'Type3',
            },
            'todayKeyword': '성장',
            'luckyAction': '새로운 도전',
          },
          advice: 'Test advice',
          tokenCost: 15,
          luckyItems: {
            'color': '파란색',
            'number': 7,
            'direction': '북쪽',
            'time': '오후 3시',
          },
        );

        // Assert
        expect(fortune.id, equals('test-id'));
        expect(fortune.userId, equals(testUserId));
        expect(fortune.type, equals('personality-mbti'));
        expect(fortune.content, equals('Test fortune content'));
        expect(fortune.overallScore, equals(88));
        expect(fortune.score, equals(88)); // Backward compatibility
        expect(fortune.message, equals('Test fortune content')); // Backward compatibility
        expect(fortune.advice, equals('Test advice'));
        expect(fortune.luckyColor, equals('파란색'));
        expect(fortune.luckyNumber, equals(7));
        expect(fortune.luckyDirection, equals('북쪽'));
        expect(fortune.bestTime, equals('오후 3시'));
      });

      test('should handle null optional fields', () {
        // Arrange & Act
        final fortune = Fortune(
          id: 'test-id',
          userId: testUserId,
          type: 'personality',
          content: 'Test content',
          createdAt: testDate,
        );

        // Assert
        expect(fortune.additionalInfo, isNull);
        expect(fortune.overallScore, isNull);
        expect(fortune.score, equals(80)); // Default value
        expect(fortune.advice, isNull);
        expect(fortune.luckyColor, isNull);
        expect(fortune.luckyNumber, isNull);
        expect(fortune.tokenCost, equals(1)); // Default value
      });

      test('should convert Fortune to JSON correctly', () {
        // Arrange
        final fortune = Fortune(
          id: 'test-id',
          userId: testUserId,
          type: 'personality-mbti',
          content: 'Test content',
          createdAt: testDate,
          overallScore: 85,
          additionalInfo: {
            'personalityTraits': ['분석적', '논리적'],
          },
          tokenCost: 15,
        );

        // Act
        final json = fortune.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['userId'], equals(testUserId));
        expect(json['type'], equals('personality-mbti'));
        expect(json['content'], equals('Test content'));
        expect(json['createdAt'], equals(testDate.toIso8601String()));
        expect(json['overallScore'], equals(85));
        expect(json['additionalInfo'], isNotNull);
        expect(json['tokenCost'], equals(15));
      });

      test('should implement Equatable correctly', () {
        // Arrange
        final fortune1 = Fortune(
          id: 'test-id',
          userId: testUserId,
          type: 'personality',
          content: 'Test content',
          createdAt: testDate,
        );

        final fortune2 = Fortune(
          id: 'test-id',
          userId: testUserId,
          type: 'personality',
          content: 'Test content',
          createdAt: testDate,
        );

        final fortune3 = Fortune(
          id: 'different-id',
          userId: testUserId,
          type: 'personality',
          content: 'Test content',
          createdAt: testDate,
        );

        // Assert
        expect(fortune1, equals(fortune2));
        expect(fortune1, isNot(equals(fortune3)));
      });
    });

    group('Error Handling Tests', () {
      test('should handle API errors gracefully', () async {
        // Arrange
        final params = {
          'personalityType': 'mbti',
          'mbti': 'INTJ',
        };

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => fortuneApiService.getPersonalityFortune(
            userId: testUserId,
            params: params,
          ),
          throwsException,
        );
      });

      test('should validate required parameters', () async {
        // Arrange - Missing personality type
        final invalidParams = {
          'mbti': 'INTJ',
        };

        when(() => mockApiClient.post(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => {
          'id': 'fortune-123',
          'user_id': testUserId,
          'type': 'personality',
          'content': 'Default personality fortune',
          'created_at': testDate.toIso8601String(),
          'token_cost': 15,
        });

        // Act
        final result = await fortuneApiService.getPersonalityFortune(
          userId: testUserId,
          params: invalidParams,
        );

        // Assert - Should default to 'personality' type
        expect(result.type, equals('personality'));
      });
    });
  });
}