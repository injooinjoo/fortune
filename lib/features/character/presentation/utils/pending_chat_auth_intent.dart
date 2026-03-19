import 'package:image_picker/image_picker.dart';

import '../../domain/models/character_choice.dart';

enum PendingChatAuthIntentType {
  textMessage,
  choiceSelection,
  fortuneRequest,
  surveySubmission,
  openImagePicker,
}

enum PendingChatImagePickerTarget {
  composerSheet,
  surveyImage,
  surveyOotd,
  surveyFaceReading,
}

class PendingChatAuthIntent {
  static const Duration _maxAge = Duration(minutes: 10);

  final PendingChatAuthIntentType type;
  final String characterId;
  final String? fortuneType;
  final String? text;
  final Map<String, dynamic>? surveyAnswers;
  final CharacterChoice? choice;
  final PendingChatImagePickerTarget? imagePickerTarget;
  final ImageSource? imageSource;
  final DateTime createdAt;

  const PendingChatAuthIntent({
    required this.type,
    required this.characterId,
    required this.createdAt,
    this.fortuneType,
    this.text,
    this.surveyAnswers,
    this.choice,
    this.imagePickerTarget,
    this.imageSource,
  });

  factory PendingChatAuthIntent.textMessage({
    required String characterId,
    required String text,
  }) {
    return PendingChatAuthIntent(
      type: PendingChatAuthIntentType.textMessage,
      characterId: characterId,
      text: text,
      createdAt: DateTime.now(),
    );
  }

  factory PendingChatAuthIntent.choiceSelection({
    required String characterId,
    required CharacterChoice choice,
  }) {
    return PendingChatAuthIntent(
      type: PendingChatAuthIntentType.choiceSelection,
      characterId: characterId,
      choice: choice,
      createdAt: DateTime.now(),
    );
  }

  factory PendingChatAuthIntent.fortuneRequest({
    required String characterId,
    required String fortuneType,
  }) {
    return PendingChatAuthIntent(
      type: PendingChatAuthIntentType.fortuneRequest,
      characterId: characterId,
      fortuneType: fortuneType,
      createdAt: DateTime.now(),
    );
  }

  factory PendingChatAuthIntent.surveySubmission({
    required String characterId,
    required String fortuneType,
    required Map<String, dynamic> surveyAnswers,
  }) {
    return PendingChatAuthIntent(
      type: PendingChatAuthIntentType.surveySubmission,
      characterId: characterId,
      fortuneType: fortuneType,
      surveyAnswers: surveyAnswers,
      createdAt: DateTime.now(),
    );
  }

  factory PendingChatAuthIntent.openImagePicker({
    required String characterId,
    String? fortuneType,
    required PendingChatImagePickerTarget target,
    ImageSource? imageSource,
  }) {
    return PendingChatAuthIntent(
      type: PendingChatAuthIntentType.openImagePicker,
      characterId: characterId,
      fortuneType: fortuneType,
      imagePickerTarget: target,
      imageSource: imageSource,
      createdAt: DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().difference(createdAt) > _maxAge;

  String buildResumeRoute() {
    final queryParameters = <String, String>{
      'openCharacterChat': 'true',
      'characterId': characterId,
      'entrySource': 'auth-resume',
    };

    if (fortuneType != null && fortuneType!.isNotEmpty) {
      queryParameters['fortuneType'] = fortuneType!;
    }

    return Uri(
      path: '/chat',
      queryParameters: queryParameters,
    ).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'characterId': characterId,
      'fortuneType': fortuneType,
      'text': text,
      'surveyAnswers': surveyAnswers,
      'choice': choice?.toJson(),
      'imagePickerTarget': imagePickerTarget?.name,
      'imageSource': imageSource?.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingChatAuthIntent.fromJson(Map<String, dynamic> json) {
    return PendingChatAuthIntent(
      type: _typeFromName(json['type'] as String?),
      characterId: json['characterId'] as String? ?? '',
      fortuneType: json['fortuneType'] as String?,
      text: json['text'] as String?,
      surveyAnswers: _mapFromJson(json['surveyAnswers']),
      choice: _choiceFromJson(json['choice']),
      imagePickerTarget: _imagePickerTargetFromName(
        json['imagePickerTarget'] as String?,
      ),
      imageSource: _imageSourceFromName(json['imageSource'] as String?),
      createdAt: _createdAtFromJson(json['createdAt']),
    );
  }

  static PendingChatAuthIntentType _typeFromName(String? raw) {
    return PendingChatAuthIntentType.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => PendingChatAuthIntentType.textMessage,
    );
  }

  static PendingChatImagePickerTarget? _imagePickerTargetFromName(
    String? raw,
  ) {
    for (final value in PendingChatImagePickerTarget.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }

  static ImageSource? _imageSourceFromName(String? raw) {
    for (final value in ImageSource.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }

  static DateTime _createdAtFromJson(dynamic raw) {
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Map<String, dynamic>? _mapFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  static CharacterChoice? _choiceFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return CharacterChoice.fromJson(raw);
    }
    if (raw is Map) {
      return CharacterChoice.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return null;
  }
}
