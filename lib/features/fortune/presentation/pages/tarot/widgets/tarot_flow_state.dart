/// Tarot page flow states
enum TarotFlowState {
  deckSelection,     // 덱 선택 (NEW - 초반에 덱 선택)
  initial,          // 초기 화면
  questioning,      // 질문 선택/입력
  spreadSelection,  // 스프레드 선택
  loading,         // 로딩 중
  result           // 결과 표시
}
