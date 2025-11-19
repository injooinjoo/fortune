import 'package:freezed_annotation/freezed_annotation.dart';
import 'talisman_wish.dart';

part 'talisman_design.freezed.dart';
part 'talisman_design.g.dart';

@freezed
class TalismanDesign with _$TalismanDesign {
  const factory TalismanDesign({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'design_type') @Default(TalismanDesignType.traditional) TalismanDesignType designType,
    required TalismanCategory category,
    required String title,
    @JsonKey(name: 'image_url') required String imageUrl,
    @Default({}) Map<String, dynamic> colors,
    @Default({}) Map<String, dynamic> symbols,
    @JsonKey(name: 'mantra_text') required String mantraText,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'effect_score') @Default(0) int effectScore,
    @Default([]) List<String> blessings,
    // 🆕 AI 생성 관련 필드 추가
    @JsonKey(name: 'is_ai_generated') @Default(false) bool isAIGenerated,
    @JsonKey(name: 'custom_characters') List<String>? customCharacters,
    @JsonKey(name: 'generation_prompt') String? generationPrompt,
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