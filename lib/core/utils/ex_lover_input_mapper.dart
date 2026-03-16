class ExLoverInputMapper {
  static const Map<String, String> _healingMomentLabels = {
    'morning': '아침에 일어날 때',
    'night': '밤에 잠들기 전',
    'places': '우리 갔던 장소 볼 때',
    'alone': '혼자 있을 때',
    'couples': '커플 볼 때',
  };

  static const Map<String, String> _reunionChangeLabels = {
    'i_changed': '내가 변했어',
    'they_changed': '상대가 변했을 것 같아',
    'situation_changed': '상황이 달라졌어',
    'both_grew': '둘 다 성장했어',
    'not_sure': '잘 모르겠어',
    'unsure': '잘 모르겠어',
  };

  static const Map<String, String> _newStartPriorityLabels = {
    'trust': '신뢰/소통',
    'stability': '감정적 안정',
    'values': '비슷한 가치관',
    'passion': '설렘과 열정',
    'growth': '서로의 성장',
    'trust_communication': '신뢰와 소통',
    'emotional_stability': '감정적 안정',
    'similar_values': '비슷한 가치관',
    'excitement': '설렘과 열정',
  };

  const ExLoverInputMapper._();

  static Map<String, dynamic> normalize(Map<String, dynamic> input) {
    final normalized = Map<String, dynamic>.from(input);
    final primaryGoal = asTrimmedString(
          normalized['primaryGoal'] ?? normalized['primary_goal'],
        ) ??
        'healing';

    normalized['primaryGoal'] = primaryGoal;

    _setAliasPair(
      normalized,
      primaryKey: 'breakupTime',
      aliasKey: 'time_since_breakup',
      rawValue: normalized['time_since_breakup'] ?? normalized['breakupTime'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'exPartnerName',
      aliasKey: 'ex_name',
      rawValue: normalized['ex_name'] ?? normalized['exPartnerName'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'exPartnerMbti',
      aliasKey: 'ex_mbti',
      rawValue: normalized['ex_mbti'] ?? normalized['exPartnerMbti'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'exPartnerBirthYear',
      aliasKey: 'ex_birth_date',
      rawValue: normalized['ex_birth_date'] ?? normalized['exPartnerBirthYear'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'breakupInitiator',
      aliasKey: 'breakup_initiator',
      rawValue:
          normalized['breakup_initiator'] ?? normalized['breakupInitiator'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'contactStatus',
      aliasKey: 'contact_status',
      rawValue: normalized['contact_status'] ?? normalized['contactStatus'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'coreReason',
      aliasKey: 'breakup_reason',
      rawValue: normalized['breakup_reason'] ?? normalized['coreReason'],
    );
    _setAliasPair(
      normalized,
      primaryKey: 'detailedStory',
      aliasKey: 'breakup_detail',
      rawValue: normalized['breakup_detail'] ?? normalized['detailedStory'],
    );

    final currentState = _normalizeStringList(normalized['currentState']);
    if (currentState != null) {
      normalized['currentState'] = currentState;
    }

    final goalSpecific = _buildGoalSpecific(
      primaryGoal: primaryGoal,
      input: normalized,
    );
    if (goalSpecific.isNotEmpty) {
      normalized['goalSpecific'] = goalSpecific;
    }

    return normalized;
  }

  static String? asTrimmedString(dynamic value) {
    if (value == null) return null;
    if (value is! String && value is! num && value is! bool) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  static Map<String, dynamic> _buildGoalSpecific({
    required String primaryGoal,
    required Map<String, dynamic> input,
  }) {
    final existingGoalSpecific = _asStringKeyedMap(input['goalSpecific']);
    final goalSpecific = <String, dynamic>{
      if (existingGoalSpecific != null) ...existingGoalSpecific,
    };

    switch (primaryGoal) {
      case 'healing':
        final hardestMoment = asTrimmedString(
          goalSpecific['hardestMoment'] ?? input['healingDeep'],
        );
        if (hardestMoment != null) {
          goalSpecific['hardestMoment'] =
              _healingMomentLabels[hardestMoment] ?? hardestMoment;
        }
        break;
      case 'reunion_strategy':
        final whatWillChange = asTrimmedString(
          goalSpecific['whatWillChange'] ?? input['reunionDeep'],
        );
        if (whatWillChange != null) {
          goalSpecific['whatWillChange'] =
              _reunionChangeLabels[whatWillChange] ?? whatWillChange;
        }
        break;
      case 'read_their_mind':
        final exCharacteristics = asTrimmedString(
          goalSpecific['exCharacteristics'] ??
              input['exCharacteristics'] ??
              input['exPartnerMbti'] ??
              input['ex_mbti'],
        );
        if (exCharacteristics != null) {
          goalSpecific['exCharacteristics'] =
              exCharacteristics == 'unknown' ? '모름' : exCharacteristics;
        }
        break;
      case 'new_start':
        final newRelationshipPriority = asTrimmedString(
          goalSpecific['newRelationshipPriority'] ?? input['newStartDeep'],
        );
        if (newRelationshipPriority != null) {
          goalSpecific['newRelationshipPriority'] =
              _newStartPriorityLabels[newRelationshipPriority] ??
                  newRelationshipPriority;
        }
        break;
    }

    goalSpecific.removeWhere((_, value) => asTrimmedString(value) == null);
    return goalSpecific;
  }

  static void _setAliasPair(
    Map<String, dynamic> target, {
    required String primaryKey,
    required String aliasKey,
    required dynamic rawValue,
  }) {
    final value = asTrimmedString(rawValue);
    if (value == null) {
      return;
    }
    target[primaryKey] = value;
    target[aliasKey] = value;
  }

  static List<String>? _normalizeStringList(dynamic value) {
    if (value is! List) {
      return null;
    }

    final items =
        value.map(asTrimmedString).whereType<String>().toList(growable: false);
    if (items.isEmpty) {
      return null;
    }
    return items;
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }
}
