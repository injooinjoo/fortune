import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 포춘 쿠키 운세 생성기
///
/// 로컬 데이터 소스로 포춘 쿠키 메시지를 생성합니다.
/// - 5가지 쿠키 타입: love, wealth, health, wisdom, luck
/// - 100개 메시지 풀 (각 타입 20개) - 비유적/신비로운 스타일
/// - 일일 저장: 하루에 한 번 뽑은 메시지를 저장하여 재사용
/// - 새 필드: lucky_time, lucky_direction, lucky_color_hex, action_mission
class FortuneCookieGenerator {
  static final Random _random = Random();
  static const String _storageKey = 'fortune_cookie_daily';

  /// 쿠키 데이터 버전 (새 필드 추가 시 증가)
  /// v2: lucky_time, lucky_direction, lucky_color_hex, action_mission 추가
  /// v3: lucky_item, lucky_place 추가
  static const int _dataVersion = 3;

  /// 오늘의 포춘쿠키 가져오기 (일일 저장 적용)
  ///
  /// - 오늘 이미 뽑은 쿠키가 있고 버전이 일치하면 저장된 결과 반환
  /// - 없거나 구버전이면 새로 생성 후 저장
  static Future<FortuneResult> getTodayFortuneCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // yyyy-MM-dd

    // 오늘 저장된 쿠키 확인
    final savedData = prefs.getString(_storageKey);
    if (savedData != null) {
      try {
        final json = jsonDecode(savedData) as Map<String, dynamic>;
        final savedVersion = json['version'] as int? ?? 1;

        // 날짜와 버전 모두 일치해야 저장된 쿠키 반환
        if (json['date'] == today && json['result'] != null && savedVersion >= _dataVersion) {
          Logger.info('[FortuneCookieGenerator] 🍪 오늘 저장된 쿠키 반환 (v$savedVersion)');
          return FortuneResult.fromJson(json['result'] as Map<String, dynamic>);
        } else if (savedVersion < _dataVersion) {
          Logger.info('[FortuneCookieGenerator] 🔄 구버전 쿠키 감지 (v$savedVersion → v$_dataVersion), 새로 생성');
        }
      } catch (e) {
        Logger.warning('[FortuneCookieGenerator] 저장된 데이터 파싱 실패: $e');
      }
    }

    // 새로 생성 (랜덤 타입)
    final types = ['love', 'wealth', 'health', 'wisdom', 'luck'];
    final randomType = types[_random.nextInt(types.length)];
    final result = await generate({'cookie_type': randomType});

    // 저장 (버전 포함)
    await prefs.setString(_storageKey, jsonEncode({
      'date': today,
      'version': _dataVersion,
      'result': result.toJson(),
    }));

    Logger.info('[FortuneCookieGenerator] 🍪 새 쿠키 생성 및 저장 완료 (v$_dataVersion)');
    return result;
  }

  /// 포춘 쿠키 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "cookie_type": "love"  // love, wealth, health, wisdom, luck
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
  ) async {
    final cookieType = inputConditions['cookie_type'] as String? ?? 'luck';

    // 📤 로컬 생성 시작
    Logger.info('[FortuneCookieGenerator] 🍪 포춘쿠키 생성 시작');
    Logger.info('[FortuneCookieGenerator]   🎲 cookie_type: $cookieType');

    // 쿠키 타입별 메시지 풀
    final messages = _getMessagesByType(cookieType);
    Logger.info('[FortuneCookieGenerator]   📚 메시지 풀 크기: ${messages.length}개');

    final message = _generateMessage(cookieType);
    final luckyNumber = _generateLuckyNumber();
    final luckyColorData = _generateLuckyColorWithHex();
    final luckyTime = _generateLuckyTime();
    final luckyDirection = _generateLuckyDirection();
    final luckyItemData = _generateLuckyItem();
    final luckyPlace = _generateLuckyPlace();
    final actionMission = _generateActionMission(cookieType);
    final score = _random.nextInt(30) + 70;

    Logger.info('[FortuneCookieGenerator] ✅ 포춘쿠키 생성 완료');
    Logger.info('[FortuneCookieGenerator]   💬 메시지: $message');
    Logger.info('[FortuneCookieGenerator]   🎯 행운의 숫자: $luckyNumber');
    Logger.info('[FortuneCookieGenerator]   🎨 행운의 색상: ${luckyColorData.$1}');
    Logger.info('[FortuneCookieGenerator]   ⏰ 행운의 시간: $luckyTime');
    Logger.info('[FortuneCookieGenerator]   🧭 행운의 방위: $luckyDirection');
    Logger.info('[FortuneCookieGenerator]   🎁 럭키 아이템: ${luckyItemData.$1} (${luckyItemData.$2})');
    Logger.info('[FortuneCookieGenerator]   📍 행운 장소: $luckyPlace');
    Logger.info('[FortuneCookieGenerator]   💡 행동 미션: $actionMission');
    Logger.info('[FortuneCookieGenerator]   ⭐ 점수: $score');

    return FortuneResult(
      type: 'fortune_cookie',
      title: '포춘 쿠키',
      summary: {
        'message': message,
        'cookie_type': cookieType,
        'lucky_number': luckyNumber,
        'lucky_color': luckyColorData.$1,
        'lucky_color_hex': luckyColorData.$2,
        'lucky_time': luckyTime,
        'lucky_direction': luckyDirection,
        'lucky_item': luckyItemData.$1,
        'lucky_item_color': luckyItemData.$2,
        'lucky_place': luckyPlace,
        'action_mission': actionMission,
      },
      data: {
        'message': message,
        'cookie_type': cookieType,
        'lucky_number': luckyNumber,
        'lucky_color': luckyColorData.$1,
        'lucky_color_hex': luckyColorData.$2,
        'lucky_time': luckyTime,
        'lucky_direction': luckyDirection,
        'lucky_item': luckyItemData.$1,
        'lucky_item_color': luckyItemData.$2,
        'lucky_place': luckyPlace,
        'action_mission': actionMission,
        'emoji': _getCookieEmoji(cookieType),
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }

  /// 쿠키 타입별 메시지 생성
  static String _generateMessage(String cookieType) {
    final messages = _getMessagesByType(cookieType);
    return messages[_random.nextInt(messages.length)];
  }

  /// 쿠키 타입별 메시지 풀 (각 타입 20개, 총 100개) - 비유적/신비로운 스타일
  static List<String> _getMessagesByType(String cookieType) {
    switch (cookieType) {
      case 'love':
        return _loveMessages;
      case 'wealth':
        return _wealthMessages;
      case 'health':
        return _healthMessages;
      case 'wisdom':
        return _wisdomMessages;
      case 'luck':
      default:
        return _luckMessages;
    }
  }

  // ============================================================
  // 사랑 메시지 (20개) - 비유적/신비로운 스타일
  // ============================================================
  static const _loveMessages = [
    '닫혀 있던 문이 바람에 흔들리고 있습니다. 살짝만 밀어도 열릴 것입니다.',
    '두 개의 별이 서로를 향해 궤도를 바꾸고 있습니다. 곧 만나게 될 거예요.',
    '당신의 마음속 정원에 새로운 꽃씨가 심어졌습니다. 물을 주세요.',
    '오래된 다리 위에서 익숙한 발자국 소리가 들려옵니다.',
    '연이 바람을 기다리듯, 인연도 때를 기다립니다. 그 때가 가까워지고 있어요.',
    '잠든 나비가 날개를 펴려 합니다. 따뜻한 햇살이 필요할 뿐이에요.',
    '붉은 실이 천천히 감기고 있습니다. 그 끝에 누군가 있어요.',
    '달빛 아래 피어나는 꽃처럼, 당신의 마음도 곧 활짝 열릴 거예요.',
    '메아리가 되어 돌아오는 그 목소리, 점점 가까워지고 있습니다.',
    '거울 속에 비친 또 다른 미소가 당신을 기다리고 있어요.',
    '오래된 편지함에 새 편지가 도착할 조짐이 보입니다.',
    '두 강물이 만나는 곳처럼, 인연의 물줄기가 합류하고 있습니다.',
    '밤하늘의 별똥별이 당신의 소원을 듣고 있어요.',
    '꿈에서 본 그 풍경이 현실에서 펼쳐질 준비를 하고 있습니다.',
    '서로 다른 계절에서 온 두 사람이 같은 꽃을 바라보게 될 거예요.',
    '얼음이 녹아 흐르는 시냇물처럼, 굳었던 마음도 풀리고 있습니다.',
    '새가 둥지를 떠나듯, 새로운 사랑이 당신에게 날아오고 있어요.',
    '거미줄에 맺힌 이슬처럼 영롱한 인연이 다가오고 있습니다.',
    '오래 걸어온 길 끝에 따스한 불빛이 보이기 시작합니다.',
    '봄바람이 겨울잠을 깨우듯, 당신의 마음에도 설렘이 찾아올 거예요.',
  ];

  // ============================================================
  // 재물 메시지 (20개) - 비유적/신비로운 스타일
  // ============================================================
  static const _wealthMessages = [
    '뿌린 씨앗이 땅 밑에서 이미 싹을 틔웠습니다. 곧 초록빛을 보게 되겠네요.',
    '물레방아가 다시 돌기 시작합니다. 곡식 창고가 채워질 조짐이에요.',
    '광산 속 금맥이 한 줄기 빛을 내고 있습니다. 조금만 더 파보세요.',
    '마른 우물에 샘물이 솟아오르기 시작했습니다.',
    '떨어진 나뭇잎이 새 움을 예고하듯, 변화가 풍요를 가져올 거예요.',
    '길을 잃은 줄 알았던 곳에서 보물 지도를 발견하게 될 것입니다.',
    '강물이 바다로 흘러가듯, 재물도 당신에게 모여들고 있어요.',
    '별이 정렬되어 황금빛 길을 비추고 있습니다. 그 길을 따라가세요.',
    '동전 하나가 백 개가 되는 마법이 곧 시작될 거예요.',
    '겨울을 버틴 나무에 달콤한 열매가 맺힐 때가 왔습니다.',
    '닫혔던 금고의 자물쇠가 저절로 열리는 소리가 들립니다.',
    '물고기가 그물로 헤엄쳐 오듯, 기회가 당신을 향해 오고 있어요.',
    '오래된 항아리 속에서 빛나는 것이 발견될 조짐이 보입니다.',
    '새벽안개가 걷히면 황금빛 들판이 드러날 거예요.',
    '거북이 등에 새겨진 문양처럼, 부의 비밀이 곧 해독될 것입니다.',
    '마을 어귀의 복숭아나무가 유난히 많은 꽃을 피웠습니다.',
    '봉황이 나는 곳에 보물이 있다 했습니다. 그곳이 가까워지고 있어요.',
    '조약돌이 모여 성을 이루듯, 작은 것들이 큰 부를 만들고 있습니다.',
    '산 너머에서 북소리가 들립니다. 경사스러운 소식이 올 거예요.',
    '잉어가 용문을 넘듯, 당신의 재물운도 도약할 준비를 하고 있습니다.',
  ];

  // ============================================================
  // 건강 메시지 (20개) - 비유적/신비로운 스타일
  // ============================================================
  static const _healthMessages = [
    '몸 안의 작은 시냇물이 맑게 흐르기 시작했습니다. 생기가 돌고 있어요.',
    '오래된 나무가 새 가지를 뻗듯, 당신의 몸도 회복되고 있습니다.',
    '아침 이슬이 온몸을 적시듯, 새로운 활력이 스며들고 있어요.',
    '겨울잠에서 깨어난 곰처럼, 에너지가 충전되고 있습니다.',
    '깊은 산속 약초가 당신을 위해 자라고 있어요.',
    '막혔던 샘이 뚫리듯, 몸의 기운이 순환하기 시작했습니다.',
    '봄비가 대지를 적시듯, 치유의 에너지가 당신을 감싸고 있어요.',
    '무거웠던 갑옷을 벗어던지듯, 몸이 가벼워지고 있습니다.',
    '산 정상에서 부는 맑은 바람이 당신의 폐를 채우고 있어요.',
    '연꽃이 진흙에서 피어나듯, 건강이 회복되고 있습니다.',
    '등불이 어둠을 밝히듯, 생명력이 온몸에 퍼지고 있어요.',
    '오랜 가뭄 끝에 단비가 내리듯, 활력이 찾아오고 있습니다.',
    '나비가 고치를 뚫고 나오듯, 새로운 기운이 솟아나고 있어요.',
    '깊은 숲속의 맑은 공기가 당신의 몸을 정화하고 있습니다.',
    '달이 차오르듯, 당신의 기력도 점점 충만해지고 있어요.',
    '따스한 온천수가 피로를 씻어내듯, 휴식이 필요한 때입니다.',
    '새싹이 돌틈을 뚫고 나오듯, 강인한 생명력이 움트고 있어요.',
    '학이 하늘을 나듯, 당신의 몸도 자유로워지고 있습니다.',
    '아침 해가 산을 넘듯, 건강한 기운이 솟아오르고 있어요.',
    '맑은 샘물처럼, 당신의 몸도 정화되고 있습니다.',
  ];

  // ============================================================
  // 지혜 메시지 (20개) - 비유적/신비로운 스타일
  // ============================================================
  static const _wisdomMessages = [
    '안개가 걷히면 숨어있던 길이 보일 것입니다. 조금만 기다리세요.',
    '오래된 책장에서 먼지 낀 책 한 권이 당신을 부르고 있어요.',
    '산 정상에서 보는 풍경은 아래에서 본 것과 다릅니다. 올라가 보세요.',
    '거울은 있는 그대로를 비춥니다. 진실을 마주할 준비가 되었어요.',
    '바람은 보이지 않아도 나뭇잎을 움직입니다. 보이지 않는 것을 느껴보세요.',
    '달은 차고 기우는 것을 두려워하지 않습니다. 변화를 받아들이세요.',
    '물은 낮은 곳으로 흐르며 결국 바다에 이릅니다. 겸손이 답이에요.',
    '천 년 묵은 바위도 물방울에 구멍이 뚫립니다. 꾸준함을 믿으세요.',
    '어둠 속의 반딧불이처럼, 작은 깨달음이 빛나기 시작했습니다.',
    '미로의 출구는 반드시 있습니다. 벽에서 손을 떼지 마세요.',
    '오래된 우물의 물은 더 깊고 차갑습니다. 깊이 생각해보세요.',
    '철새는 어디로 가야 하는지 알고 있습니다. 당신의 본능을 믿으세요.',
    '눈 덮인 산도 봄이 오면 꽃을 피웁니다. 때를 기다리는 지혜가 필요해요.',
    '나침반이 북쪽을 가리키듯, 답은 이미 당신 안에 있습니다.',
    '부엉이는 밤에 더 잘 봅니다. 다른 시각으로 바라보세요.',
    '강물은 돌을 피해 흐르다 결국 바다에 닿습니다. 유연하게 가세요.',
    '대나무는 비어있기에 하늘까지 자랍니다. 비움의 지혜를 배우세요.',
    '호수가 고요해야 하늘을 비출 수 있습니다. 마음을 가라앉히세요.',
    '실타래의 끝을 찾으면 매듭이 풀리기 시작합니다. 핵심을 찾으세요.',
    '등대는 폭풍 속에서도 빛을 잃지 않습니다. 중심을 지키세요.',
  ];

  // ============================================================
  // 행운 메시지 (20개) - 비유적/신비로운 스타일
  // ============================================================
  static const _luckMessages = [
    '당신의 작은 친절이 예상치 못한 커다란 행운의 부메랑이 되어 돌아옵니다.',
    '무지개 끝에 황금 항아리가 있다면, 그곳이 가까워지고 있어요.',
    '네잎클로버가 당신의 발걸음이 닿는 곳마다 피어나고 있습니다.',
    '별똥별이 당신의 소원을 듣고 하늘에서 내려오고 있어요.',
    '행운의 여신이 당신의 창문을 두드리고 있습니다. 문을 열어주세요.',
    '주사위가 당신에게 유리한 면을 보이려 합니다.',
    '바람이 행운의 씨앗을 당신의 정원으로 불어오고 있어요.',
    '길을 건너는 검은 고양이가 사실은 행운을 가져오는 중입니다.',
    '오래된 동전이 빛을 발하기 시작했습니다. 행운이 깃들었어요.',
    '첫 번째 눈송이가 당신의 손바닥에 떨어질 것입니다. 소원을 빌어보세요.',
    '쏟아진 소금 대신 설탕이 쏟아지는 날이 다가오고 있습니다.',
    '13층 엘리베이터 버튼이 당신에게만 14로 변할 거예요.',
    '어제 잃어버린 것이 오늘 두 배로 돌아올 조짐이 보입니다.',
    '밤하늘에 당신만을 위한 별자리가 새로 그려지고 있어요.',
    '행운의 말발굽이 당신의 문 앞에 놓여질 것입니다.',
    '도토리를 심은 곳에서 참나무가 자라듯, 작은 행운이 큰 복이 될 거예요.',
    '매미가 우는 여름날, 시원한 바람이 당신에게만 불어올 것입니다.',
    '복권 번호가 아니라, 복권보다 큰 행운이 다가오고 있어요.',
    '일곱 번째 물결이 당신에게 진주를 가져다줄 것입니다.',
    '구름 사이로 비치는 햇살처럼, 행운이 당신을 비추고 있습니다.',
  ];

  // ============================================================
  // 행운의 시간 (12개)
  // ============================================================
  static const _luckyTimes = [
    '06:00 ~ 08:00',
    '08:00 ~ 10:00',
    '10:00 ~ 12:00',
    '12:00 ~ 14:00',
    '14:00 ~ 16:00',
    '16:00 ~ 18:00',
    '18:00 ~ 20:00',
    '20:00 ~ 22:00',
    '22:00 ~ 24:00',
    '09:00 ~ 11:00',
    '13:00 ~ 15:00',
    '17:00 ~ 19:00',
  ];

  // ============================================================
  // 행운의 방위 (8개)
  // ============================================================
  static const _luckyDirections = [
    '동쪽',
    '서쪽',
    '남쪽',
    '북쪽',
    '동북쪽',
    '동남쪽',
    '서북쪽',
    '서남쪽',
  ];

  // ============================================================
  // 행운의 색상 (이름, HEX 코드) (12개)
  // ============================================================
  static const _luckyColorsWithHex = [
    ('선셋오렌지', '#FF6B35'),
    ('로즈핑크', '#FF6B8A'),
    ('오션블루', '#3498DB'),
    ('포레스트그린', '#27AE60'),
    ('골든옐로우', '#F1C40F'),
    ('라벤더', '#9B59B6'),
    ('코랄레드', '#E74C3C'),
    ('스카이블루', '#87CEEB'),
    ('민트그린', '#98D8C8'),
    ('피치', '#FFAB91'),
    ('아메시스트', '#8E44AD'),
    ('터콰이즈', '#1ABC9C'),
  ];

  // ============================================================
  // 럭키 아이템 (아이템명, 색상) (24개)
  // ============================================================
  static const _luckyItems = [
    ('손수건', '노란색'),
    ('열쇠고리', '은색'),
    ('머리핀', '진주색'),
    ('팔찌', '금색'),
    ('스카프', '하늘색'),
    ('머그컵', '흰색'),
    ('에코백', '베이지색'),
    ('양말', '줄무늬'),
    ('볼펜', '파란색'),
    ('책갈피', '나무색'),
    ('동전지갑', '갈색'),
    ('손거울', '분홍색'),
    ('향수', '투명병'),
    ('귀걸이', '오팔색'),
    ('시계', '로즈골드'),
    ('반지', '실버'),
    ('목걸이', '터콰이즈'),
    ('모자', '베이지'),
    ('선글라스', '브라운'),
    ('우산', '민트색'),
    ('부채', '전통문양'),
    ('북마크', '가죽'),
    ('키홀더', '클로버'),
    ('립밤', '코랄'),
  ];

  // ============================================================
  // 행운 장소 (24개) - 구체적이고 신비로운 장소
  // ============================================================
  static const _luckyPlaces = [
    '통창이 있는 카페',
    '물소리가 들리는 곳',
    '오래된 서점',
    '나무 아래 벤치',
    '옥상 정원',
    '강이 보이는 산책로',
    '햇살이 드는 창가',
    '조용한 미술관',
    '돌계단이 있는 골목',
    '분수대 근처',
    '고즈넉한 사찰',
    '해질녘 공원',
    '노란 가로등 아래',
    '작은 꽃집 앞',
    '빈티지 가구점',
    '따뜻한 베이커리',
    '녹음이 우거진 길',
    '구름이 보이는 언덕',
    '오래된 다리 위',
    '별이 잘 보이는 곳',
    '이끼 낀 담벼락',
    '풍경 소리가 나는 처마',
    '고양이가 있는 골목',
    '새소리가 들리는 숲',
  ];

  // ============================================================
  // 행동 지침 - 타입별 15개씩 (총 75개)
  // ============================================================
  static const _loveActionMissions = [
    '오래된 사진첩을 펼쳐보세요. 잊었던 인연의 실마리가 보일 거예요.',
    '연락처 목록을 천천히 내려보다 멈추는 사람에게 안부를 물어보세요.',
    '좋아하는 노래를 소중한 사람에게 공유해보세요.',
    '오늘 처음 만나는 사람에게 먼저 미소를 지어보세요.',
    '사랑하는 사람의 커피 취향을 기억해서 선물해보세요.',
    '오래된 연인에게 "처음 만났을 때"를 이야기해보세요.',
    '분홍색 계열의 옷이나 소품을 착용해보세요.',
    '좋아하는 향수나 핸드크림을 정성껏 발라보세요.',
    '창가 자리에서 지나가는 사람들을 구경해보세요.',
    '어린 시절 좋아했던 장소를 떠올려 보세요.',
    '사랑에 관한 시 한 편을 읽어보세요.',
    '소중한 사람에게 고마움을 담은 짧은 메시지를 보내보세요.',
    '거울을 보며 자신에게 "사랑해"라고 말해보세요.',
    '오늘 하루는 비판 대신 칭찬을 세 번 해보세요.',
    '마음에 담아둔 말이 있다면 용기 내어 전해보세요.',
  ];

  static const _wealthActionMissions = [
    '오늘은 지갑을 정리해보세요. 정돈된 공간에 복이 깃듭니다.',
    '작은 금액이라도 저금통에 동전을 넣어보세요.',
    '가계부나 지출 내역을 한 번 확인해보세요.',
    '오래된 영수증을 정리하며 불필요한 것들을 비워내세요.',
    '북쪽이나 서쪽을 향해 잠시 서서 깊은 숨을 쉬어보세요.',
    '금색이나 노란색 계열의 소품을 지니고 다녀보세요.',
    '카페에서 음료를 기다리는 동안 새해 재정 목표를 떠올려보세요.',
    '누군가에게 작은 것이라도 베풀어보세요. 나눔이 복을 부릅니다.',
    '오늘 만난 사람과 긍정적인 이야기를 나눠보세요.',
    '씀씀이보다 버는 것에 감사하는 시간을 가져보세요.',
    '오래된 물건 중 쓰지 않는 것을 정리하거나 나눠보세요.',
    '내일 할 일 목록을 미리 작성해보세요.',
    '감사일기에 오늘의 작은 풍요를 적어보세요.',
    '식물에 물을 주며 성장하는 마음을 가져보세요.',
    '새벽에 일어나 아침 해를 맞이해보세요.',
  ];

  static const _healthActionMissions = [
    '창문을 열고 3분간 깊은 호흡을 해보세요.',
    '가까운 거리는 걸어서 이동해보세요.',
    '오늘 하루 물을 평소보다 한 잔 더 마셔보세요.',
    '스트레칭으로 굳은 어깨와 목을 풀어보세요.',
    '초록색 음식을 한 가지 이상 먹어보세요.',
    '잠자리에 들기 전 따뜻한 물로 발을 담가보세요.',
    '오늘 만큼은 엘리베이터 대신 계단을 이용해보세요.',
    '좋아하는 음악을 들으며 5분간 산책해보세요.',
    '점심시간에 잠깐이라도 햇볕을 쬐어보세요.',
    '카페인 대신 허브차 한 잔을 마셔보세요.',
    '자기 전 스마트폰을 30분 일찍 내려놓아보세요.',
    '좋아하는 과일을 하나 먹으며 천천히 씹어보세요.',
    '거울 보며 어깨를 펴고 바른 자세를 만들어보세요.',
    '따뜻한 물 한 컵으로 하루를 시작해보세요.',
    '오늘은 조금 일찍 잠자리에 들어보세요.',
  ];

  static const _wisdomActionMissions = [
    '서점에 들러 눈에 띄는 책 한 권을 펼쳐보세요.',
    '오래된 일기장이나 노트를 다시 읽어보세요.',
    '새로운 분야의 짧은 영상이나 글을 접해보세요.',
    '오늘 하루 "왜?"라는 질문을 세 번 던져보세요.',
    '어린 시절 좋아했던 동화책을 떠올려보세요.',
    '익숙한 길 대신 새로운 길로 돌아가보세요.',
    '조용한 곳에서 10분간 명상해보세요.',
    '오늘 배운 것을 누군가에게 설명해보세요.',
    '하늘을 올려다보며 구름의 모양을 관찰해보세요.',
    '어제의 실수를 교훈으로 적어보세요.',
    '평소 안 읽던 장르의 뉴스를 읽어보세요.',
    '조용히 앉아 새소리나 바람 소리에 귀 기울여보세요.',
    '메모장에 오늘의 깨달음을 한 줄로 적어보세요.',
    '거울 속 자신에게 "괜찮아"라고 말해보세요.',
    '잠들기 전 감사한 것 세 가지를 생각해보세요.',
  ];

  static const _luckActionMissions = [
    '카페에서 따뜻한 음료를 주문해보세요. 운의 흐름이 부드러워집니다.',
    '오늘 처음 보는 사람에게 먼저 인사해보세요.',
    '동전을 세 개 골라 주머니에 넣어 다녀보세요.',
    '행운의 숫자를 마음속으로 외우며 하루를 시작해보세요.',
    '오늘 하루 "될 거야"라고 세 번 말해보세요.',
    '초록색 무언가를 만지거나 바라보세요.',
    '복권을 사지 않아도 됩니다. 대신 작은 소원을 빌어보세요.',
    '오래된 행운의 부적이나 물건을 다시 꺼내어 보세요.',
    '네잎클로버 이미지를 찾아 배경화면으로 설정해보세요.',
    '나가기 전 거울에 비친 자신에게 화이팅을 외쳐보세요.',
    '오늘 만나는 첫 번째 동물에게 인사해보세요.',
    '자판기에서 랜덤 버튼을 눌러보세요.',
    '평소 안 가던 가게에 들러보세요.',
    '하늘을 올려다보며 별똥별을 상상해보세요.',
    '오늘 하루는 왼손잡이처럼 행동해보세요.',
  ];

  /// 행운의 숫자 생성
  static int _generateLuckyNumber() {
    return _random.nextInt(100) + 1;
  }

  /// 행운의 색상 생성 (이름과 HEX 코드 함께 반환)
  static (String, String) _generateLuckyColorWithHex() {
    return _luckyColorsWithHex[_random.nextInt(_luckyColorsWithHex.length)];
  }

  /// 행운의 시간 생성
  static String _generateLuckyTime() {
    return _luckyTimes[_random.nextInt(_luckyTimes.length)];
  }

  /// 행운의 방위 생성
  static String _generateLuckyDirection() {
    return _luckyDirections[_random.nextInt(_luckyDirections.length)];
  }

  /// 럭키 아이템 생성 (아이템명, 색상 함께 반환)
  static (String, String) _generateLuckyItem() {
    return _luckyItems[_random.nextInt(_luckyItems.length)];
  }

  /// 행운 장소 생성
  static String _generateLuckyPlace() {
    return _luckyPlaces[_random.nextInt(_luckyPlaces.length)];
  }

  /// 행동 지침 생성 (쿠키 타입별)
  static String _generateActionMission(String cookieType) {
    final missions = _getActionMissionsByType(cookieType);
    return missions[_random.nextInt(missions.length)];
  }

  /// 쿠키 타입별 행동 지침 풀
  static List<String> _getActionMissionsByType(String cookieType) {
    switch (cookieType) {
      case 'love':
        return _loveActionMissions;
      case 'wealth':
        return _wealthActionMissions;
      case 'health':
        return _healthActionMissions;
      case 'wisdom':
        return _wisdomActionMissions;
      case 'luck':
      default:
        return _luckActionMissions;
    }
  }

  /// 쿠키 타입별 이모지
  static String _getCookieEmoji(String cookieType) {
    switch (cookieType) {
      case 'love':
        return '💕';
      case 'wealth':
        return '💰';
      case 'health':
        return '🌿';
      case 'wisdom':
        return '🔮';
      case 'luck':
      default:
        return '🍀';
    }
  }
}
