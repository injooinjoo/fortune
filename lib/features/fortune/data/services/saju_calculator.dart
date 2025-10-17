/// 사주팔자 계산 서비스
///
/// 생년월일시를 기반으로 사주팔자(四柱八字)를 계산하고
/// 오행(五行), 십성(十星), 대운(大運) 등을 분석합니다.
class SajuCalculator {
  /// 천간(天干) - 10개
  static const List<String> tianGan = [
    '갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'
  ];

  /// 지지(地支) - 12개
  static const List<String> diZhi = [
    '자', '축', '인', '묘', '진', '사', '오', '미', '申', '유', '술', '해'
  ];

  /// 오행(五行) 매핑
  static const Map<String, String> wuxingMap = {
    // 천간
    '갑': '목', '을': '목',
    '병': '화', '정': '화',
    '무': '토', '기': '토',
    '경': '금', '신': '금',
    '임': '수', '계': '수',
    // 지지
    '인': '목', '묘': '목',
    '사': '화', '오': '화',
    '진': '토', '축': '토', '미': '토', '술': '토',
    '申': '금', '유': '금',
    '해': '수', '자': '수',
  };

  /// 십성(十星) 정의
  static const List<String> sipseong = [
    '비견', '겁재', '식신', '상관', '편재', '정재', '편관', '정관', '편인', '정인'
  ];

  /// 일간(日干) 계산
  ///
  /// 생년월일을 기반으로 일간을 계산합니다.
  /// 일간은 사주팔자에서 가장 중요한 요소로, 본인의 기질을 나타냅니다.
  static String calculateIlgan(DateTime birthDate) {
    // 간단한 계산식 (실제로는 만세력 필요)
    // 이 코드는 교육용 간소화 버전입니다
    final baseDate = DateTime(1900, 1, 1);
    final daysDifference = birthDate.difference(baseDate).inDays;

    // 갑자일로부터의 날짜 차이를 60으로 나눈 나머지
    final ganIndex = (daysDifference + 36) % 10; // 36은 1900년 1월 1일의 천간 인덱스

    return tianGan[ganIndex];
  }

  /// 연주(年柱) 계산
  static Map<String, String> calculateYearPillar(DateTime birthDate) {
    final year = birthDate.year;

    // 천간 계산 (년도 - 3) % 10
    final ganIndex = (year - 3) % 10;

    // 지지 계산 (년도 - 3) % 12
    final zhiIndex = (year - 3) % 12;

    return {
      'gan': tianGan[ganIndex],
      'zhi': diZhi[zhiIndex],
      'combined': '${tianGan[ganIndex]}${diZhi[zhiIndex]}',
    };
  }

  /// 월주(月柱) 계산
  static Map<String, String> calculateMonthPillar(DateTime birthDate) {
    final month = birthDate.month;
    final year = birthDate.year;

    // 천간 계산 (연천간에 따라 달라짐)
    final yearGanIndex = (year - 3) % 10;
    // 월지 계산 (인월이 1월, 묘월이 2월...)
    final zhiIndex = (month + 1) % 12;

    // 간단한 계산식 (실제로는 더 복잡)
    final ganIndex = ((yearGanIndex * 2 + month) % 10);

    return {
      'gan': tianGan[ganIndex],
      'zhi': diZhi[zhiIndex],
      'combined': '${tianGan[ganIndex]}${diZhi[zhiIndex]}',
    };
  }

  /// 시주(時柱) 계산
  static Map<String, String> calculateHourPillar(
    DateTime birthDate,
    int birthHour,
  ) {
    // 지지 계산 (2시간 단위로 변경)
    final zhiIndex = (birthHour + 1) ~/ 2 % 12;

    // 천간 계산 (일천간에 따라 달라짐)
    final ilgan = calculateIlgan(birthDate);
    final ilganIndex = tianGan.indexOf(ilgan);
    final ganIndex = (ilganIndex * 2 + zhiIndex) % 10;

    return {
      'gan': tianGan[ganIndex],
      'zhi': diZhi[zhiIndex],
      'combined': '${tianGan[ganIndex]}${diZhi[zhiIndex]}',
    };
  }

  /// 완전한 사주팔자 계산
  static Map<String, dynamic> calculateSaju(
    DateTime birthDate,
    int birthHour,
    int birthMinute,
  ) {
    final ilgan = calculateIlgan(birthDate);
    final yearPillar = calculateYearPillar(birthDate);
    final monthPillar = calculateMonthPillar(birthDate);
    final hourPillar = calculateHourPillar(birthDate, birthHour);

    return {
      'ilgan': ilgan,
      'year': yearPillar,
      'month': monthPillar,
      'hour': hourPillar,
      'wuxing': calculateWuxing(ilgan, yearPillar, monthPillar, hourPillar),
    };
  }

  /// 오행(五行) 분석
  ///
  /// 사주팔자의 오행 분포를 계산합니다.
  static Map<String, int> calculateWuxing(
    String ilgan,
    Map<String, String> yearPillar,
    Map<String, String> monthPillar,
    Map<String, String> hourPillar,
  ) {
    final wuxingCount = <String, int>{
      '목': 0,
      '화': 0,
      '토': 0,
      '금': 0,
      '수': 0,
    };

    // 일간
    wuxingCount[wuxingMap[ilgan]!] = wuxingCount[wuxingMap[ilgan]!]! + 2; // 일간은 가중치 2배

    // 연주
    wuxingCount[wuxingMap[yearPillar['gan']!]!] = wuxingCount[wuxingMap[yearPillar['gan']!]!]! + 1;
    wuxingCount[wuxingMap[yearPillar['zhi']!]!] = wuxingCount[wuxingMap[yearPillar['zhi']!]!]! + 1;

    // 월주 (가중치 1.5배)
    wuxingCount[wuxingMap[monthPillar['gan']!]!] = wuxingCount[wuxingMap[monthPillar['gan']!]!]! + 1;
    wuxingCount[wuxingMap[monthPillar['zhi']!]!] = wuxingCount[wuxingMap[monthPillar['zhi']!]!]! + 2; // 월지는 가중치 더 높음

    // 시주
    wuxingCount[wuxingMap[hourPillar['gan']!]!] = wuxingCount[wuxingMap[hourPillar['gan']!]!]! + 1;
    wuxingCount[wuxingMap[hourPillar['zhi']!]!] = wuxingCount[wuxingMap[hourPillar['zhi']!]!]! + 1;

    return wuxingCount;
  }

  /// 십성(十星) 계산
  ///
  /// 일간을 기준으로 다른 천간들과의 관계를 십성으로 분석합니다.
  static Map<String, List<String>> calculateSipseong(String ilgan) {
    final ilganIndex = tianGan.indexOf(ilgan);
    final ilganWuxing = wuxingMap[ilgan]!;

    final sipseongMap = <String, List<String>>{
      '비견': [], // 같은 오행, 같은 음양
      '겁재': [], // 같은 오행, 다른 음양
      '식신': [], // 나를 생하는 오행, 같은 음양
      '상관': [], // 나를 생하는 오행, 다른 음양
      '편재': [], // 내가 극하는 오행, 같은 음양
      '정재': [], // 내가 극하는 오행, 다른 음양
      '편관': [], // 나를 극하는 오행, 같은 음양
      '정관': [], // 나를 극하는 오행, 다른 음양
      '편인': [], // 나를 생해주는 오행, 같은 음양
      '정인': [], // 나를 생해주는 오행, 다른 음양
    };

    // 오행 상생상극 관계
    const Map<String, Map<String, String>> wuxingRelations = {
      '목': {'생': '화', '극': '토', '생받음': '수', '극받음': '금'},
      '화': {'생': '토', '극': '금', '생받음': '목', '극받음': '수'},
      '토': {'생': '금', '극': '수', '생받음': '화', '극받음': '목'},
      '금': {'생': '수', '극': '목', '생받음': '토', '극받음': '화'},
      '수': {'생': '목', '극': '화', '생받음': '금', '극받음': '토'},
    };

    // 각 천간에 대해 십성 분류
    for (int i = 0; i < tianGan.length; i++) {
      final gan = tianGan[i];
      final ganWuxing = wuxingMap[gan]!;
      final isYang = i % 2 == 0; // 짝수 인덱스는 양, 홀수는 음
      final ilganYang = ilganIndex % 2 == 0;
      final sameYinYang = isYang == ilganYang;

      if (ganWuxing == ilganWuxing) {
        // 비견/겁재
        if (i == ilganIndex) continue; // 자기 자신은 제외
        if (sameYinYang) {
          sipseongMap['비견']!.add(gan);
        } else {
          sipseongMap['겁재']!.add(gan);
        }
      } else if (ganWuxing == wuxingRelations[ilganWuxing]!['생']) {
        // 식신/상관
        if (sameYinYang) {
          sipseongMap['식신']!.add(gan);
        } else {
          sipseongMap['상관']!.add(gan);
        }
      } else if (ganWuxing == wuxingRelations[ilganWuxing]!['극']) {
        // 편재/정재
        if (sameYinYang) {
          sipseongMap['편재']!.add(gan);
        } else {
          sipseongMap['정재']!.add(gan);
        }
      } else if (ganWuxing == wuxingRelations[ilganWuxing]!['극받음']) {
        // 편관/정관
        if (sameYinYang) {
          sipseongMap['편관']!.add(gan);
        } else {
          sipseongMap['정관']!.add(gan);
        }
      } else if (ganWuxing == wuxingRelations[ilganWuxing]!['생받음']) {
        // 편인/정인
        if (sameYinYang) {
          sipseongMap['편인']!.add(gan);
        } else {
          sipseongMap['정인']!.add(gan);
        }
      }
    }

    return sipseongMap;
  }

  /// 사주팔자에서 십성 분포 계산
  static Map<String, int> analyzeSipseongInSaju(Map<String, dynamic> saju) {
    final ilgan = saju['ilgan'] as String;
    final sipseongMap = calculateSipseong(ilgan);

    // 연월시의 천간들을 모아서 십성 개수 세기
    final gans = <String>[
      saju['year']['gan'],
      saju['month']['gan'],
      saju['hour']['gan'],
    ];

    final sipseongCount = <String, int>{};
    for (var ss in sipseong) {
      sipseongCount[ss] = 0;
    }

    for (var gan in gans) {
      for (var entry in sipseongMap.entries) {
        if (entry.value.contains(gan)) {
          sipseongCount[entry.key] = sipseongCount[entry.key]! + 1;
        }
      }
    }

    return sipseongCount;
  }

  /// 대운(大運) 계산
  ///
  /// 10년 주기로 변화하는 운의 흐름을 계산합니다.
  static List<Map<String, dynamic>> calculateDaeun(
    DateTime birthDate,
    String gender,
    int currentAge,
  ) {
    final yearPillar = calculateYearPillar(birthDate);
    final yearGan = yearPillar['gan']!;
    final yearGanIndex = tianGan.indexOf(yearGan);

    // 양년생 남자, 음년생 여자는 순행
    // 음년생 남자, 양년생 여자는 역행
    final isYangYear = yearGanIndex % 2 == 0;
    final isForward = (gender == '남성' && isYangYear) || (gender == '여성' && !isYangYear);

    final daeunList = <Map<String, dynamic>>[];

    // 대운의 시작 주는 월주의 다음/이전 주
    final monthPillar = calculateMonthPillar(birthDate);
    int currentGanIndex = tianGan.indexOf(monthPillar['gan']!);
    int currentZhiIndex = diZhi.indexOf(monthPillar['zhi']!);

    // 보통 8세부터 대운이 시작 (간소화)
    for (int age = 8; age <= 80; age += 10) {
      if (isForward) {
        currentGanIndex = (currentGanIndex + 1) % 10;
        currentZhiIndex = (currentZhiIndex + 1) % 12;
      } else {
        currentGanIndex = (currentGanIndex - 1 + 10) % 10;
        currentZhiIndex = (currentZhiIndex - 1 + 12) % 12;
      }

      final daeunGan = tianGan[currentGanIndex];
      final daeunZhi = diZhi[currentZhiIndex];
      final wuxing = wuxingMap[daeunGan]!;

      daeunList.add({
        'age': age,
        'gan': daeunGan,
        'zhi': daeunZhi,
        'combined': '$daeunGan$daeunZhi',
        'wuxing': wuxing,
        'isActive': age <= currentAge && currentAge < age + 10,
      });
    }

    return daeunList;
  }

  /// 일간별 특성 설명
  static Map<String, String> getIlganDescription(String ilgan) {
    const descriptions = {
      '갑': '큰 나무처럼 곧고 정직하며, 성장과 발전을 추구합니다. 리더십이 강하고 새로운 일을 개척하는 것을 좋아합니다.',
      '을': '풀과 같이 유연하고 적응력이 뛰어나며, 사람들과의 조화를 중시합니다. 섬세하고 예술적 감각이 뛰어납니다.',
      '병': '태양처럼 밝고 열정적이며, 주변을 밝게 비춥니다. 카리스마가 있고 사람들을 이끄는 힘이 있습니다.',
      '정': '촛불이나 난로의 불처럼 따뜻하고 세심합니다. 예술적 재능이 있고 사람들을 돌보는 것을 좋아합니다.',
      '무': '높은 산처럼 든든하고 안정적입니다. 책임감이 강하고 신뢰할 수 있으며, 중재자 역할을 잘합니다.',
      '기': '밭과 같이 포용력이 있고 실용적입니다. 꾸준하고 성실하며, 실질적인 결과를 중시합니다.',
      '경': '쇠와 같이 단단하고 결단력이 있습니다. 원칙을 중시하고 정의로우며, 분석력이 뛰어납니다.',
      '신': '보석처럼 섬세하고 예민합니다. 미적 감각이 뛰어나고 완벽주의적 성향이 있습니다.',
      '임': '큰 바다와 같이 포용력이 크고 지혜롭습니다. 깊은 사고를 하며, 전략적이고 통찰력이 있습니다.',
      '계': '이슬이나 빗물처럼 순수하고 섬세합니다. 직감력이 뛰어나고 예술적 감각이 있으며, 변화에 민감합니다.',
    };

    return {
      'character': descriptions[ilgan] ?? '',
      'element': wuxingMap[ilgan] ?? '',
    };
  }
}
