import 'package:equatable/equatable.dart';

class FortuneHistory extends Equatable {
  final String id;
  final String userId;
  final String fortuneType;
  final String title;
  final Map<String, dynamic> summary;
  final DateTime createdAt;

  const FortuneHistory({
    required this.id,
    required this.userId,
    required this.fortuneType,
    required this.title,
    required this.summary,
    required this.createdAt,
  });

  factory FortuneHistory.fromJson(Map<String, dynamic> json) {
    return FortuneHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fortuneType: json['fortune_type'] as String,
      title: json['title'] as String,
      summary: json['summary'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fortune_type': fortuneType,
      'title': title,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, fortuneType, title, summary, createdAt];
}