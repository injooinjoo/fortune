String buildUnknownUserNameGuard({
  required String characterName,
  String? knownUserName,
}) {
  final trimmedName = knownUserName?.trim();
  if (trimmedName != null && trimmedName.isNotEmpty) {
    return '';
  }

  return '''
[사용자 호칭 안전 규칙]
사용자 이름은 제공되지 않았습니다.
절대 사용자 이름이나 별명을 추측하지 마세요.
절대 캐릭터 이름 "$characterName"을 사용자 호칭으로 쓰지 마세요.
이름이 꼭 필요하면 "회원님" 같은 중립 호칭을 쓰거나, 호칭을 생략하고 바로 본론으로 답하세요.
''';
}
