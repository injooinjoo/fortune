class FortuneEmotionalDescriptions {
  static Map<String, dynamic> getDescription(String fortuneType) {
    final descriptions = {
      'mbti': {
        'emotionalDescription': 'MBTI로 오늘의 운세를 알아봅니다. 같이 있을 상대(애인이나, 직장동료, 같은반 친구 등)와의 오늘 그리고 내일의 예상을 해드립니다. 사랑과 미래, 재물과 건강 등 우리가 필요로 하는 미래를 엿볼 수 있는 기회입니다.',
        'inputLabel': 'MBTI',
        'inputHint': 'ENTJ',
        'inputType': 'dropdown',
        'dropdownOptions': [
          'INTJ', 'INTP', 'ENTJ', 'ENTP',
          'INFJ', 'INFP', 'ENFJ', 'ENFP',
          'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
          'ISTP', 'ISFP', 'ESTP', 'ESFP'
        ]},
      'daily': {
        'emotionalDescription': '오늘 하루, 당신에게 찾아올 특별한 순간들을 미리 만나보세요. 아침의 첫 발걸음부터 저녁의 마지막 인사까지, 당신의 하루를 더욱 빛나게 만들어줄 운세가 기다리고 있습니다.',
        'requiresInput': null},
      'weekly': {
        'emotionalDescription': '이번 주, 당신의 삶에 펼쳐질 7일간의 이야기. 월요일의 시작부터 일요일의 마무리까지, 매일매일 다른 색깔로 물들어갈 당신의 일주일을 미리 들여다보세요.',
        'requiresInput': null},
      'monthly': {
        'emotionalDescription': '한 달 동안 당신을 기다리고 있는 특별한 기회와 행운의 순간들. 달의 변화와 함께 찾아올 당신의 운명적인 전환점을 확인하고, 더 나은 내일을 준비하세요.',
        'requiresInput': null},
      'yearly': {
        'emotionalDescription': '365일, 당신의 인생에 새겨질 특별한 한 해. 봄의 시작부터 겨울의 끝까지, 계절의 변화와 함께 찾아올 당신의 성장과 행복의 이야기를 들려드립니다.',
        'requiresInput': null},
      'saju': {
        'emotionalDescription': '태어난 년, 월, 일, 시를 바탕으로 당신의 타고난 운명을 읽어드립니다. 사주팔자에 담긴 당신만의 특별한 이야기와 앞으로의 인생 항로를 함께 살펴보세요.',
        'inputLabel': '생년월일시',
        'requiresInput': true,
        'multipleInputs': null},
      'zodiac': {
        'emotionalDescription': '별자리가 들려주는 당신의 이야기. 우주의 별들이 당신을 위해 준비한 특별한 메시지를 확인하고, 오늘 하루를 더욱 의미있게 만들어보세요.',
        'requiresInput': null},
      'zodiac-animal': {
        'emotionalDescription': '12간지 동물이 전하는 당신의 운명. 띠별로 다른 특성과 함께, 올해 당신에게 찾아올 특별한 기운과 행운의 순간들을 미리 만나보세요.',
        'requiresInput': null},
      'tarot': {
        'emotionalDescription': '신비로운 타로카드가 당신의 미래를 비춥니다. 78장의 카드 중 당신을 위해 선택된 특별한 카드들이 전하는 메시지를 통해 인생의 방향을 찾아보세요.',
        'requiresInput': null},
      'love': {
        'emotionalDescription': '사랑이 당신을 찾아오는 시간. 운명적인 만남, 설레는 순간, 그리고 영원한 약속까지. 당신의 연애운이 들려주는 달콤하고도 특별한 이야기를 만나보세요.',
        'requiresInput': null},
      'career': {
        'emotionalDescription': '당신의 커리어가 빛나는 순간이 다가옵니다. 새로운 기회, 도전의 시간, 그리고 성공의 열쇠. 직장에서의 당신의 미래를 미리 그려보세요.',
        'requiresInput': null},
      'wealth': {
        'emotionalDescription': '풍요로운 삶을 위한 특별한 신호. 재물운이 들려주는 기회의 시간과 투자의 적기, 그리고 당신에게 찾아올 경제적 행운의 순간들을 확인하세요.',
        'requiresInput': null},
      'health': {
        'emotionalDescription': '건강한 삶, 행복한 일상. 몸과 마음의 균형을 찾고, 더욱 활기찬 하루를 보낼 수 있는 건강운세가 당신의 웰빙 라이프를 도와드립니다.',
        'requiresInput': null},
      'compatibility': {
        'emotionalDescription': '두 사람 사이의 특별한 인연. 서로의 마음이 만나는 지점과 함께 걸어갈 미래의 모습. 궁합이 들려주는 두 사람만의 아름다운 이야기를 확인해보세요.',
        'inputLabel': '상대방 정보',
        'requiresInput': true,
        'multipleInputs': null},
      'chemistry': {
        'emotionalDescription': '첫 만남부터 느껴지는 특별한 케미스트리. 두 사람 사이의 화학작용이 만들어내는 시너지와 서로를 더욱 빛나게 해줄 관계의 비밀을 알아보세요.',
        'inputLabel': '상대방 정보',
        'requiresInput': true,
        'multipleInputs': null},
      'business': {
        'emotionalDescription': '성공적인 비즈니스를 위한 나침반. 사업운이 알려주는 적절한 타이밍과 전략, 그리고 당신의 비즈니스를 한 단계 도약시킬 특별한 기회를 포착하세요.',
        'requiresInput': null},
      'travel': {
        'emotionalDescription': '새로운 세계가 당신을 기다립니다. 여행운이 추천하는 최적의 시기와 목적지, 그리고 당신의 여정을 더욱 특별하게 만들어줄 행운의 순간들을 미리 만나보세요.',
        'requiresInput': null},
      'study': {
        'emotionalDescription': '지식의 문이 활짝 열리는 시간. 학업운이 알려주는 최고의 학습 타이밍과 효과적인 공부법, 그리고 당신의 목표 달성을 도와줄 특별한 기운을 확인하세요.',
        'requiresInput': null},
      'biorhythm': {
        'emotionalDescription': '당신의 신체, 감정, 지성의 리듬을 읽어드립니다. 바이오리듬이 알려주는 최적의 컨디션 타이밍을 활용해 더욱 효율적이고 행복한 일상을 만들어보세요.',
        'requiresInput': null},
      'blood-type': {
        'emotionalDescription': '혈액형에 담긴 당신만의 특별한 성격과 운명. A, B, O, AB형별로 다른 특성과 함께, 오늘 당신에게 찾아올 행운의 신호를 미리 포착해보세요.',
        'inputLabel': '혈액형',
        'inputHint': 'A형',
        'inputType': 'dropdown',
        'dropdownOptions': ['A형', 'B형', 'O형', 'AB형']
      },
      // 추가 운세 타입들
      'personality': {
        'emotionalDescription': '당신만의 독특한 성격이 만들어내는 운명의 길. 내면의 특성이 이끄는 대로 따라가다 보면, 더욱 행복하고 성공적인 미래가 펼쳐집니다.',
        'requiresInput': null},
      'dream': {
        'emotionalDescription': '꿈속에 숨겨진 미래의 신호들. 무의식이 전하는 특별한 메시지를 해석하고, 당신의 내면이 알려주는 진정한 소망과 미래를 발견해보세요.',
        'inputLabel': '꿈 내용',
        'inputHint': '꿈의 주요 내용을 입력하세요',
        'inputType': 'text'},
      'name': {
        'emotionalDescription': '이름에 담긴 운명의 비밀. 한 글자 한 글자에 새겨진 당신만의 특별한 기운과 미래를 읽어드립니다. 이름이 들려주는 당신의 인생 이야기를 만나보세요.',
        'requiresInput': null}};

    // Return the description for the requested fortune type, or a default
    return descriptions[fortuneType] ?? {
      'emotionalDescription': '당신의 미래를 밝혀줄 특별한 운세. 오늘과 내일, 그리고 앞으로 펼쳐질 당신의 이야기를 미리 만나보세요.',
      'requiresInput': null};
  }
}