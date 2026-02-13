// 합충형파해(合沖刑破害) 관계 데이터
//
// 천간과 지지 간의 다양한 관계를 정의합니다:
// - 합(合): 글자들이 만나 새로운 오행을 생성
// - 충(沖): 정반대 위치의 글자가 충돌
// - 형(刑): 서로 해로운 작용
// - 파(破): 깨뜨리는 관계
// - 해(害): 서로 해치는 관계
library;

import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_saju_colors.dart';

/// 관계 유형
enum RelationType {
  /// 합(合) - 결합, 조화
  combination('합', '合', '결합과 조화. 길한 관계'),

  /// 충(沖) - 충돌, 변화
  clash('충', '沖', '충돌과 변화. 이동, 변동을 암시'),

  /// 형(刑) - 형벌, 고통
  punishment('형', '刑', '형벌과 고통. 관재, 질병 주의'),

  /// 파(破) - 파괴
  breakRelation('파', '破', '깨뜨림과 파괴. 계획 차질'),

  /// 해(害) - 해침
  harm('해', '害', '서로 해침. 배신, 갈등');

  final String korean;
  final String hanja;
  final String meaning;

  const RelationType(this.korean, this.hanja, this.meaning);

  /// 관계 유형별 색상
  Color getColor({bool isDark = false}) {
    return SajuColors.getRelationColor(korean, isDark: isDark);
  }

  /// 길흉 판단
  bool get isAuspicious => this == RelationType.combination;
}

/// 개별 관계 정보
class SajuRelation {
  /// 관계 유형
  final RelationType type;

  /// 관련 글자들
  final List<String> characters;

  /// 관련 한자들
  final List<String> hanjaCharacters;

  /// 결과 오행 (합의 경우)
  final String? resultWuxing;

  /// 관계 이름 (예: "자축합토")
  final String name;

  /// 상세 설명
  final String description;

  /// 위치 정보 (년주, 월주, 일주, 시주)
  final List<String>? positions;

  const SajuRelation({
    required this.type,
    required this.characters,
    required this.hanjaCharacters,
    this.resultWuxing,
    required this.name,
    required this.description,
    this.positions,
  });

  @override
  String toString() => '$name (${type.korean})';
}

/// 합충형파해 관계 데이터 및 분석
class StemBranchRelations {
  StemBranchRelations._();

  // ============================================================
  // 천간합(天干合) - 5합
  // ============================================================

  /// 천간합 매핑: {천간1+천간2: 결과 오행}
  static const Map<String, Map<String, dynamic>> cheonGanHap = {
    '갑기': {'result': '토', 'name': '갑기합토', 'hanja': '甲己合土'},
    '을경': {'result': '금', 'name': '을경합금', 'hanja': '乙庚合金'},
    '병신': {'result': '수', 'name': '병신합수', 'hanja': '丙辛合水'},
    '정임': {'result': '목', 'name': '정임합목', 'hanja': '丁壬合木'},
    '무계': {'result': '화', 'name': '무계합화', 'hanja': '戊癸合火'},
  };

  /// 천간 충 매핑
  static const Map<String, String> cheonGanChung = {
    '갑': '경', '경': '갑',
    '을': '신', '신': '을',
    '병': '임', '임': '병',
    '정': '계', '계': '정',
  };

  // ============================================================
  // 지지육합(地支六合)
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiYukHap = {
    '자축': {'result': '토', 'name': '자축합토', 'hanja': '子丑合土'},
    '인해': {'result': '목', 'name': '인해합목', 'hanja': '寅亥合木'},
    '묘술': {'result': '화', 'name': '묘술합화', 'hanja': '卯戌合火'},
    '진유': {'result': '금', 'name': '진유합금', 'hanja': '辰酉合金'},
    '사신': {'result': '수', 'name': '사신합수', 'hanja': '巳申合水'},
    '오미': {'result': '토', 'name': '오미합토', 'hanja': '午未合土'},
  };

  // ============================================================
  // 지지삼합(地支三合) - 방국
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiSamHap = {
    '신자진': {'result': '수', 'name': '수국삼합', 'hanja': '申子辰水局'},
    '해묘미': {'result': '목', 'name': '목국삼합', 'hanja': '亥卯未木局'},
    '인오술': {'result': '화', 'name': '화국삼합', 'hanja': '寅午戌火局'},
    '사유축': {'result': '금', 'name': '금국삼합', 'hanja': '巳酉丑金局'},
  };

  // ============================================================
  // 지지방합(地支方合) - 방위합
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiBangHap = {
    '인묘진': {'result': '목', 'name': '동방목국', 'hanja': '寅卯辰東方木'},
    '사오미': {'result': '화', 'name': '남방화국', 'hanja': '巳午未南方火'},
    '신유술': {'result': '금', 'name': '서방금국', 'hanja': '申酉戌西方金'},
    '해자축': {'result': '수', 'name': '북방수국', 'hanja': '亥子丑北方水'},
  };

  // ============================================================
  // 지지충(地支沖) - 6충
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiChung = {
    '자오': {'name': '자오충', 'hanja': '子午沖', 'meaning': '수화상충, 감정/건강'},
    '축미': {'name': '축미충', 'hanja': '丑未沖', 'meaning': '토토상충, 재물/부동산'},
    '인신': {'name': '인신충', 'hanja': '寅申沖', 'meaning': '목금상충, 이동/변화'},
    '묘유': {'name': '묘유충', 'hanja': '卯酉沖', 'meaning': '목금상충, 관계/직업'},
    '진술': {'name': '진술충', 'hanja': '辰戌沖', 'meaning': '토토상충, 문서/학업'},
    '사해': {'name': '사해충', 'hanja': '巳亥沖', 'meaning': '수화상충, 건강/변화'},
  };

  /// 지지충 역매핑 (편의용)
  static const Map<String, String> _chungPairs = {
    '자': '오', '오': '자',
    '축': '미', '미': '축',
    '인': '신', '신': '인',
    '묘': '유', '유': '묘',
    '진': '술', '술': '진',
    '사': '해', '해': '사',
  };

  // ============================================================
  // 지지형(地支刑) - 삼형
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiHyeong = {
    '인사신': {
      'name': '무은지형',
      'hanja': '無恩之刑',
      'meaning': '은혜를 모르는 형벌. 배은망덕, 관재 주의',
    },
    '축술미': {
      'name': '지세지형',
      'hanja': '持勢之刑',
      'meaning': '세력을 믿고 횡포. 고집, 독선 주의',
    },
    '자묘': {
      'name': '무례지형',
      'hanja': '無禮之刑',
      'meaning': '예의 없는 형벌. 인간관계 갈등',
    },
  };

  /// 자형(自刑) - 같은 글자끼리 형
  static const List<String> jaHyeong = ['진', '오', '유', '해'];

  // ============================================================
  // 지지파(地支破)
  // ============================================================

  static const Map<String, String> jiJiPa = {
    '자': '유', '유': '자',
    '축': '진', '진': '축',
    '인': '해', '해': '인',
    '묘': '오', '오': '묘',
    '사': '신', '신': '사',
    '미': '술', '술': '미',
  };

  // ============================================================
  // 지지해(地支害) - 육해
  // ============================================================

  static const Map<String, Map<String, dynamic>> jiJiHae = {
    '자미': {'name': '자미해', 'hanja': '子未害', 'meaning': '육친 갈등'},
    '축오': {'name': '축오해', 'hanja': '丑午害', 'meaning': '관재 손실'},
    '인사': {'name': '인사해', 'hanja': '寅巳害', 'meaning': '건강 문제'},
    '묘진': {'name': '묘진해', 'hanja': '卯辰害', 'meaning': '문서 손해'},
    '신해': {'name': '신해해', 'hanja': '申亥害', 'meaning': '이동 불리'},
    '유술': {'name': '유술해', 'hanja': '酉戌害', 'meaning': '관계 손상'},
  };

  /// 육해 역매핑
  static const Map<String, String> _haePairs = {
    '자': '미', '미': '자',
    '축': '오', '오': '축',
    '인': '사', '사': '인',
    '묘': '진', '진': '묘',
    '신': '해', '해': '신',
    '유': '술', '술': '유',
  };

  // ============================================================
  // 분석 메서드
  // ============================================================

  /// 두 천간의 관계 분석
  static SajuRelation? analyzeStemRelation(String stem1, String stem2) {
    // 천간합 확인
    final hapKey1 = '$stem1$stem2';
    final hapKey2 = '$stem2$stem1';

    if (cheonGanHap.containsKey(hapKey1)) {
      final data = cheonGanHap[hapKey1]!;
      return SajuRelation(
        type: RelationType.combination,
        characters: [stem1, stem2],
        hanjaCharacters: [_stemToHanja[stem1]!, _stemToHanja[stem2]!],
        resultWuxing: data['result'],
        name: data['name'],
        description: '천간합: ${data['hanja']}',
      );
    }
    if (cheonGanHap.containsKey(hapKey2)) {
      final data = cheonGanHap[hapKey2]!;
      return SajuRelation(
        type: RelationType.combination,
        characters: [stem1, stem2],
        hanjaCharacters: [_stemToHanja[stem1]!, _stemToHanja[stem2]!],
        resultWuxing: data['result'],
        name: data['name'],
        description: '천간합: ${data['hanja']}',
      );
    }

    // 천간충 확인
    if (cheonGanChung[stem1] == stem2) {
      return SajuRelation(
        type: RelationType.clash,
        characters: [stem1, stem2],
        hanjaCharacters: [_stemToHanja[stem1]!, _stemToHanja[stem2]!],
        name: '$stem1$stem2충',
        description: '천간충',
      );
    }

    return null;
  }

  /// 두 지지의 관계 분석
  static List<SajuRelation> analyzeBranchRelation(String branch1, String branch2) {
    final relations = <SajuRelation>[];

    // 육합 확인
    final yukHapKey1 = '$branch1$branch2';
    final yukHapKey2 = '$branch2$branch1';

    if (jiJiYukHap.containsKey(yukHapKey1) || jiJiYukHap.containsKey(yukHapKey2)) {
      final data = jiJiYukHap[yukHapKey1] ?? jiJiYukHap[yukHapKey2]!;
      relations.add(SajuRelation(
        type: RelationType.combination,
        characters: [branch1, branch2],
        hanjaCharacters: [_branchToHanja[branch1]!, _branchToHanja[branch2]!],
        resultWuxing: data['result'],
        name: data['name'],
        description: '지지육합: ${data['hanja']}',
      ));
    }

    // 충 확인
    if (_chungPairs[branch1] == branch2) {
      final chungKey1 = '$branch1$branch2';
      final chungKey2 = '$branch2$branch1';
      final data = jiJiChung[chungKey1] ?? jiJiChung[chungKey2];
      if (data != null) {
        relations.add(SajuRelation(
          type: RelationType.clash,
          characters: [branch1, branch2],
          hanjaCharacters: [_branchToHanja[branch1]!, _branchToHanja[branch2]!],
          name: data['name'],
          description: '${data['hanja']}: ${data['meaning']}',
        ));
      }
    }

    // 해 확인
    if (_haePairs[branch1] == branch2) {
      final haeKey1 = '$branch1$branch2';
      final haeKey2 = '$branch2$branch1';
      final data = jiJiHae[haeKey1] ?? jiJiHae[haeKey2];
      if (data != null) {
        relations.add(SajuRelation(
          type: RelationType.harm,
          characters: [branch1, branch2],
          hanjaCharacters: [_branchToHanja[branch1]!, _branchToHanja[branch2]!],
          name: data['name'],
          description: '${data['hanja']}: ${data['meaning']}',
        ));
      }
    }

    // 파 확인
    if (jiJiPa[branch1] == branch2) {
      relations.add(SajuRelation(
        type: RelationType.breakRelation,
        characters: [branch1, branch2],
        hanjaCharacters: [_branchToHanja[branch1]!, _branchToHanja[branch2]!],
        name: '$branch1$branch2파',
        description: '지지파',
      ));
    }

    // 자형 확인
    if (branch1 == branch2 && jaHyeong.contains(branch1)) {
      relations.add(SajuRelation(
        type: RelationType.punishment,
        characters: [branch1, branch2],
        hanjaCharacters: [_branchToHanja[branch1]!, _branchToHanja[branch2]!],
        name: '$branch1$branch2자형',
        description: '자형(自刑): 같은 글자끼리 형',
      ));
    }

    return relations;
  }

  /// 세 지지의 삼합/삼형 분석
  static SajuRelation? analyzeTripleBranchRelation(
    String branch1,
    String branch2,
    String branch3,
  ) {
    final sorted = [branch1, branch2, branch3]..sort();
    final key = sorted.join('');

    // 삼합 확인
    for (final entry in jiJiSamHap.entries) {
      final samHapChars = entry.key.split('');
      samHapChars.sort();
      if (samHapChars.join('') == key) {
        return SajuRelation(
          type: RelationType.combination,
          characters: [branch1, branch2, branch3],
          hanjaCharacters: [
            _branchToHanja[branch1]!,
            _branchToHanja[branch2]!,
            _branchToHanja[branch3]!,
          ],
          resultWuxing: entry.value['result'],
          name: entry.value['name'],
          description: '지지삼합: ${entry.value['hanja']}',
        );
      }
    }

    // 삼형 확인
    for (final entry in jiJiHyeong.entries) {
      if (entry.key.length == 6) {
        // 인사신, 축술미
        final hyeongChars = [
          entry.key.substring(0, 1),
          entry.key.substring(1, 2),
          entry.key.substring(2, 3),
        ]..sort();
        if (hyeongChars.join('') == key) {
          return SajuRelation(
            type: RelationType.punishment,
            characters: [branch1, branch2, branch3],
            hanjaCharacters: [
              _branchToHanja[branch1]!,
              _branchToHanja[branch2]!,
              _branchToHanja[branch3]!,
            ],
            name: entry.value['name'],
            description: '${entry.value['hanja']}: ${entry.value['meaning']}',
          );
        }
      }
    }

    return null;
  }

  /// 사주 전체 관계 분석
  ///
  /// [yearStem], [monthStem], [dayStem], [hourStem]: 년/월/일/시 천간
  /// [yearBranch], [monthBranch], [dayBranch], [hourBranch]: 년/월/일/시 지지
  static List<SajuRelation> analyzeAllRelations({
    required String yearStem,
    required String monthStem,
    required String dayStem,
    required String hourStem,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    final relations = <SajuRelation>[];
    final stems = [yearStem, monthStem, dayStem, hourStem];
    final branches = [yearBranch, monthBranch, dayBranch, hourBranch];
    final positions = ['년주', '월주', '일주', '시주'];

    // 천간 관계 분석 (인접한 주끼리)
    for (int i = 0; i < stems.length - 1; i++) {
      final relation = analyzeStemRelation(stems[i], stems[i + 1]);
      if (relation != null) {
        relations.add(SajuRelation(
          type: relation.type,
          characters: relation.characters,
          hanjaCharacters: relation.hanjaCharacters,
          resultWuxing: relation.resultWuxing,
          name: relation.name,
          description: relation.description,
          positions: [positions[i], positions[i + 1]],
        ));
      }
    }

    // 지지 관계 분석 (모든 조합)
    for (int i = 0; i < branches.length; i++) {
      for (int j = i + 1; j < branches.length; j++) {
        final branchRelations = analyzeBranchRelation(branches[i], branches[j]);
        for (final relation in branchRelations) {
          relations.add(SajuRelation(
            type: relation.type,
            characters: relation.characters,
            hanjaCharacters: relation.hanjaCharacters,
            resultWuxing: relation.resultWuxing,
            name: relation.name,
            description: relation.description,
            positions: [positions[i], positions[j]],
          ));
        }
      }
    }

    // 삼합/삼형 확인 (3개 조합)
    for (int i = 0; i < branches.length; i++) {
      for (int j = i + 1; j < branches.length; j++) {
        for (int k = j + 1; k < branches.length; k++) {
          final tripleRelation = analyzeTripleBranchRelation(
            branches[i],
            branches[j],
            branches[k],
          );
          if (tripleRelation != null) {
            relations.add(SajuRelation(
              type: tripleRelation.type,
              characters: tripleRelation.characters,
              hanjaCharacters: tripleRelation.hanjaCharacters,
              resultWuxing: tripleRelation.resultWuxing,
              name: tripleRelation.name,
              description: tripleRelation.description,
              positions: [positions[i], positions[j], positions[k]],
            ));
          }
        }
      }
    }

    return relations;
  }

  /// 관계 유형별 필터링
  static List<SajuRelation> filterByType(
    List<SajuRelation> relations,
    RelationType type,
  ) {
    return relations.where((r) => r.type == type).toList();
  }

  /// 길한 관계만 필터링
  static List<SajuRelation> filterAuspicious(List<SajuRelation> relations) {
    return relations.where((r) => r.type.isAuspicious).toList();
  }

  /// 흉한 관계만 필터링
  static List<SajuRelation> filterInauspicious(List<SajuRelation> relations) {
    return relations.where((r) => !r.type.isAuspicious).toList();
  }

  // ============================================================
  // 헬퍼 데이터
  // ============================================================

  static const Map<String, String> _stemToHanja = {
    '갑': '甲', '을': '乙', '병': '丙', '정': '丁', '무': '戊',
    '기': '己', '경': '庚', '신': '辛', '임': '壬', '계': '癸',
  };

  static const Map<String, String> _branchToHanja = {
    '자': '子', '축': '丑', '인': '寅', '묘': '卯', '진': '辰', '사': '巳',
    '오': '午', '미': '未', '신': '申', '유': '酉', '술': '戌', '해': '亥',
  };
}
