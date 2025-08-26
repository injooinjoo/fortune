import 'package:freezed_annotation/freezed_annotation.dart';
import 'talisman_wish.dart';

part 'talisman_design.freezed.dart';
part 'talisman_design.g.dart';

@freezed
class TalismanDesign with _$TalismanDesign {
  const factory TalismanDesign({
    required String id,
    required String userId,
    required TalismanDesignType designType,
    required TalismanCategory category,
    required String title,
    required String imageUrl,
    @Default({}) Map<String, dynamic> colors,
    @Default({}) Map<String, dynamic> symbols,
    required String mantraText,
    required DateTime createdAt,
    DateTime? expiresAt,
    @Default(false) bool isPremium,
    @Default(0) int effectScore,
    @Default([]) List<String> blessings,
  }) = _TalismanDesign;

  factory TalismanDesign.fromJson(Map<String, dynamic> json) =>
      _$TalismanDesignFromJson(json);
}

enum TalismanDesignType {
  @JsonValue('traditional')
  traditional('전통 부적', '한국 전통 부적 스타일'),
  
  @JsonValue('modern')
  modern('모던 부적', '현대적이고 미니멀한 스타일'),
  
  @JsonValue('geometric')
  geometric('기하학적', '기하학적 패턴의 부적'),
  
  @JsonValue('nature')
  nature('자연', '자연 요소를 담은 부적');

  const TalismanDesignType(this.displayName, this.description);
  final String displayName;
  final String description;
}

// TalismanCategory import from talisman_wish.dart