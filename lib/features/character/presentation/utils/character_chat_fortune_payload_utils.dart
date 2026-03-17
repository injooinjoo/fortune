Map<String, dynamic> buildCharacterChatFortuneParams({
  required Map<String, dynamic> normalizedAnswers,
  Map<String, dynamic>? userProfile,
}) {
  return <String, dynamic>{
    ...normalizedAnswers,
    if (userProfile != null) ...userProfile,
  };
}

Map<String, dynamic> buildCharacterChatFortuneApiParams({
  required Map<String, dynamic> normalizedAnswers,
  Map<String, dynamic>? userProfile,
  required String userId,
}) {
  return <String, dynamic>{
    ...buildCharacterChatFortuneParams(
      normalizedAnswers: normalizedAnswers,
      userProfile: userProfile,
    ),
    'userId': userId,
  };
}
