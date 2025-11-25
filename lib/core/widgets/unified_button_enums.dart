/// UnifiedButton에서 사용하는 Enum 정의
library;

/// 버튼 스타일 종류
enum UnifiedButtonStyle {
  primary,   // 파란색 배경
  secondary, // 회색 배경
  ghost,     // 테두리만
  text,      // 텍스트만
}

/// 버튼 크기
enum UnifiedButtonSize {
  large,  // 56px
  medium, // 48px
  small,  // 40px
}

/// 로딩 애니메이션 타입
enum UnifiedLoadingType {
  dots,      // 3-dot 애니메이션 (기본)
  circular,  // CircularProgressIndicator
  tarot,     // 타로 회전 애니메이션
  mystical,  // Mystical 파티클 효과
}

/// 버튼 애니메이션 타입
enum UnifiedButtonAnimation {
  fadeIn,
  slideY,
  scale,
}
