import 'package:freezed_annotation/freezed_annotation.dart';

part 'talisman_wish.freezed.dart';
part 'talisman_wish.g.dart';

@freezed
class TalismanWish with _$TalismanWish {
  const factory TalismanWish({
    required String id,
    required TalismanCategory category,
    required String specificWish,
    required DateTime createdAt,
    String? userId,
  }) = _TalismanWish;

  factory TalismanWish.fromJson(Map<String, dynamic> json) =>
      _$TalismanWishFromJson(json);
}

enum TalismanCategory {
  @JsonValue('relationship')
  relationship('인간관계', '🤝', '원만한 인간관계와 소통을 위한 부적'),
  
  @JsonValue('wealth')
  wealth('재물운', '💰', '금전운과 경제적 풍요를 위한 부적'),
  
  @JsonValue('career')
  career('직장/사업', '💼', '직업운과 성공적인 사업을 위한 부적'),
  
  @JsonValue('love')
  love('연애/결혼', '❤️', '사랑과 행복한 결혼생활을 위한 부적'),
  
  @JsonValue('study')
  study('학업/시험', '📚', '학습능력 향상과 시험 합격을 위한 부적'),
  
  @JsonValue('health')
  health('건강', '🏥', '건강한 몸과 마음을 위한 부적'),
  
  @JsonValue('goal')
  goal('목표 달성', '🎯', '목표 달성과 성취감을 위한 부적');

  const TalismanCategory(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}