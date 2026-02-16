/// 캐릭터 보이스 프로필
class CharacterVoiceProfile {
  final String characterId;
  final String displayName;

  /// `formal` | `casual` | `neutral`
  final String defaultSpeech;

  /// `low` | `medium` | `high`
  final String questionAggressiveness;

  /// 사용자 선사용 전 애칭 차단 강도
  final bool strictNicknameGate;

  /// 1단계 기본 브릿지 템플릿 (ko)
  final String? bridgeTemplateFormalKo;
  final String? bridgeTemplateCasualKo;

  /// 페르소나 어휘 힌트 (프롬프트에 삽입)
  final List<String> lexiconHints;

  /// stage key(gettingToKnow/gettingCloser/emotionalBond/romantic)별 추가 가이드
  final Map<String, String> stageGuideOverrides;

  const CharacterVoiceProfile({
    required this.characterId,
    required this.displayName,
    this.defaultSpeech = 'formal',
    this.questionAggressiveness = 'low',
    this.strictNicknameGate = true,
    this.bridgeTemplateFormalKo,
    this.bridgeTemplateCasualKo,
    this.lexiconHints = const [],
    this.stageGuideOverrides = const {},
  });
}

class CharacterVoiceProfileRegistry {
  static const Set<String> storyCharacterIds = {
    'luts',
    'jung_tae_yoon',
    'seo_yoonjae',
    'kang_harin',
    'jayden_angel',
    'ciel_butler',
    'lee_doyoon',
    'han_seojun',
    'baek_hyunwoo',
    'min_junhyuk',
  };

  static const Set<String> pilotCharacterIds = {
    'jung_tae_yoon',
    'seo_yoonjae',
    'han_seojun',
  };

  static const Map<String, CharacterVoiceProfile> _profiles = {
    'luts': CharacterVoiceProfile(
      characterId: 'luts',
      displayName: '러츠',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      bridgeTemplateFormalKo: '요즘 가장 궁금한 건 뭐예요?',
      bridgeTemplateCasualKo: '요즘 제일 궁금한 게 뭐야?',
      lexiconHints: ['차분함', '관찰형 공감', '짧은 리액션'],
    ),
    'jung_tae_yoon': CharacterVoiceProfile(
      characterId: 'jung_tae_yoon',
      displayName: '정태윤',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      bridgeTemplateFormalKo: '편하실 때 오늘 어땠는지 들려주실래요?',
      bridgeTemplateCasualKo: '오늘 어땠는지 편할 때 말해줘.',
      lexiconHints: ['정제된 위트', '짧은 공감'],
    ),
    'seo_yoonjae': CharacterVoiceProfile(
      characterId: 'seo_yoonjae',
      displayName: '서윤재',
      defaultSpeech: 'formal',
      questionAggressiveness: 'medium',
      strictNicknameGate: true,
      bridgeTemplateFormalKo: '지금 기분은 어떤 쪽에 가까워요?',
      bridgeTemplateCasualKo: '지금 기분이 어떤 쪽이야?',
      lexiconHints: ['게임 메타포 소량', '가벼운 장난'],
    ),
    'kang_harin': CharacterVoiceProfile(
      characterId: 'kang_harin',
      displayName: '강하린',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      lexiconHints: ['프로페셔널 톤', '절제된 관심'],
    ),
    'jayden_angel': CharacterVoiceProfile(
      characterId: 'jayden_angel',
      displayName: '제이든',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      lexiconHints: ['시적 표현 소량', '신비로운 어조'],
    ),
    'ciel_butler': CharacterVoiceProfile(
      characterId: 'ciel_butler',
      displayName: '시엘',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      lexiconHints: ['극존칭 유지', '집사 어휘'],
      stageGuideOverrides: {
        'gettingToKnow': '극존칭은 유지하되 관계 강요 없이 예의를 우선하세요.',
      },
    ),
    'lee_doyoon': CharacterVoiceProfile(
      characterId: 'lee_doyoon',
      displayName: '이도윤',
      defaultSpeech: 'formal',
      questionAggressiveness: 'medium',
      strictNicknameGate: true,
      lexiconHints: ['밝은 리액션', '가벼운 텍스트 이모티콘'],
    ),
    'han_seojun': CharacterVoiceProfile(
      characterId: 'han_seojun',
      displayName: '한서준',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      bridgeTemplateFormalKo: '괜찮으면 지금 기분만 짧게 알려줘요.',
      bridgeTemplateCasualKo: '괜찮으면 지금 기분만 짧게 알려줘.',
      lexiconHints: ['짧은 문장', '무심한 톤'],
    ),
    'baek_hyunwoo': CharacterVoiceProfile(
      characterId: 'baek_hyunwoo',
      displayName: '백현우',
      defaultSpeech: 'formal',
      questionAggressiveness: 'medium',
      strictNicknameGate: true,
      lexiconHints: ['관찰형 직답', '분석 톤 과잉 금지'],
    ),
    'min_junhyuk': CharacterVoiceProfile(
      characterId: 'min_junhyuk',
      displayName: '민준혁',
      defaultSpeech: 'formal',
      questionAggressiveness: 'low',
      strictNicknameGate: true,
      bridgeTemplateFormalKo: '무리 없으시면 오늘 컨디션은 어떠세요?',
      bridgeTemplateCasualKo: '무리 없으면 오늘 컨디션 어때?',
      lexiconHints: ['따뜻한 제안형', '부드러운 공감'],
    ),
  };

  static CharacterVoiceProfile profileFor(String characterId) {
    return _profiles[characterId] ??
        CharacterVoiceProfile(
          characterId: characterId,
          displayName: characterId,
          defaultSpeech: 'formal',
          questionAggressiveness: 'low',
          strictNicknameGate: true,
        );
  }
}
