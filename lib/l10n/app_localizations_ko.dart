// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'ZPZG';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '수정';

  @override
  String get done => '완료';

  @override
  String get next => '다음';

  @override
  String get back => '뒤로';

  @override
  String get skip => '건너뛰기';

  @override
  String get retry => '다시 시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get share => '공유하기';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '정말 로그아웃 하시겠습니까?';

  @override
  String get tokens => '토큰';

  @override
  String get heldTokens => '보유 토큰';

  @override
  String tokenCount(int count) {
    return '$count개';
  }

  @override
  String tokenCountWithMax(int current, int max) {
    return '$current / $max개';
  }

  @override
  String get points => '포인트';

  @override
  String pointsWithCount(int count) {
    return '$count 포인트';
  }

  @override
  String get bonus => '보너스';

  @override
  String get points330Title => '330 포인트';

  @override
  String get points330Desc => '300P + 30P 보너스';

  @override
  String get points700Title => '700 포인트';

  @override
  String get points700Desc => '600P + 100P 보너스';

  @override
  String get points1500Title => '1,500 포인트';

  @override
  String get points1500Desc => '1,200P + 300P 보너스';

  @override
  String get points4000Title => '4,000 포인트';

  @override
  String get points4000Desc => '3,000P + 1,000P 보너스';

  @override
  String get proSubscriptionTitle => 'Pro 구독';

  @override
  String get proSubscriptionDesc => '매월 30,000개 토큰 자동 충전';

  @override
  String get maxSubscriptionTitle => 'Max 구독';

  @override
  String get maxSubscriptionDesc => '매월 100,000개 토큰 자동 충전';

  @override
  String get premiumSajuTitle => '상세 사주명리서';

  @override
  String get premiumSajuDesc => '215페이지 상세 사주 분석서 (평생 소유)';

  @override
  String dailyPointRecharge(int points) {
    return '매일 ${points}P 충전';
  }

  @override
  String pointBonus(int base, int bonus) {
    return '${base}P + ${bonus}P 보너스';
  }

  @override
  String pointRecharge(int points) {
    return '${points}P 충전';
  }

  @override
  String get categoryDailyInsights => '일일 인사이트';

  @override
  String get categoryTraditional => '전통 분석';

  @override
  String get categoryPersonality => '성격/캐릭터';

  @override
  String get categoryLoveRelation => '연애/관계';

  @override
  String get categoryCareerBusiness => '직업/사업';

  @override
  String get categoryWealthInvestment => '재물/투자';

  @override
  String get categoryHealthLife => '건강/라이프';

  @override
  String get categorySportsActivity => '스포츠/활동';

  @override
  String get categoryLuckyItems => '럭키 아이템';

  @override
  String get categoryFamilyPet => '반려/육아';

  @override
  String get categorySpecial => '특별 기능';

  @override
  String get fortuneDaily => '오늘의 메시지';

  @override
  String get fortuneToday => '오늘의 인사이트';

  @override
  String get fortuneTomorrow => '내일의 인사이트';

  @override
  String get fortuneDailyCalendar => '날짜별 인사이트';

  @override
  String get fortuneWeekly => '주간 인사이트';

  @override
  String get fortuneMonthly => '월간 인사이트';

  @override
  String get fortuneTraditional => '전통 분석';

  @override
  String get fortuneSaju => '생년월일 분석';

  @override
  String get fortuneTraditionalSaju => '전통 생년월일 분석';

  @override
  String get fortuneTarot => 'Insight Cards';

  @override
  String get fortuneSajuPsychology => '성격 심리 분석';

  @override
  String get fortuneTojeong => '전통 해석';

  @override
  String get fortuneSalpuli => '기운 정화';

  @override
  String get fortunePalmistry => '손금 분석';

  @override
  String get fortunePhysiognomy => 'Face AI';

  @override
  String get fortuneFaceReading => 'Face AI';

  @override
  String get fortuneFiveBlessings => '오복 분석';

  @override
  String get fortuneMbti => 'MBTI 분석';

  @override
  String get fortunePersonality => '성격 분석';

  @override
  String get fortunePersonalityDna => '나의 성격 탐구';

  @override
  String get fortuneBloodType => '혈액형 분석';

  @override
  String get fortuneZodiac => '별자리 분석';

  @override
  String get fortuneZodiacAnimal => '띠별 분석';

  @override
  String get fortuneBirthSeason => '태어난 계절';

  @override
  String get fortuneBirthdate => '생일 분석';

  @override
  String get fortuneBirthstone => '탄생석 가이드';

  @override
  String get fortuneBiorhythm => '바이오리듬';

  @override
  String get fortuneLove => '연애 분석';

  @override
  String get fortuneMarriage => '결혼 분석';

  @override
  String get fortuneCompatibility => '성향 매칭';

  @override
  String get fortuneTraditionalCompatibility => '전통 매칭 분석';

  @override
  String get fortuneChemistry => '케미 분석';

  @override
  String get fortuneCoupleMatch => '소울메이트';

  @override
  String get fortuneExLover => '재회 분석';

  @override
  String get fortuneBlindDate => '소개팅 가이드';

  @override
  String get fortuneCelebrityMatch => '연예인 매칭';

  @override
  String get fortuneAvoidPeople => '관계 주의 타입';

  @override
  String get fortuneCareer => '직업 분석';

  @override
  String get fortuneEmployment => '취업 가이드';

  @override
  String get fortuneBusiness => '사업 분석';

  @override
  String get fortuneStartup => '창업 인사이트';

  @override
  String get fortuneLuckyJob => '추천 직업';

  @override
  String get fortuneLuckySidejob => '부업 가이드';

  @override
  String get fortuneLuckyExam => '시험 가이드';

  @override
  String get fortuneWealth => '재물 분석';

  @override
  String get fortuneInvestment => '투자 인사이트';

  @override
  String get fortuneLuckyInvestment => '투자 가이드';

  @override
  String get fortuneLuckyRealestate => '부동산 인사이트';

  @override
  String get fortuneLuckyStock => '주식 가이드';

  @override
  String get fortuneLuckyCrypto => '암호화폐 가이드';

  @override
  String get fortuneLuckyLottery => '로또 번호 생성';

  @override
  String get fortuneHealth => '건강 체크';

  @override
  String get fortuneMoving => '이사 가이드';

  @override
  String get fortuneMovingDate => '이사 날짜 추천';

  @override
  String get fortuneMovingUnified => '이사 플래너';

  @override
  String get fortuneLuckyColor => '오늘의 색깔';

  @override
  String get fortuneLuckyNumber => '행운 숫자';

  @override
  String get fortuneLuckyItems => '럭키 아이템';

  @override
  String get fortuneLuckyFood => '추천 음식';

  @override
  String get fortuneLuckyPlace => '추천 장소';

  @override
  String get fortuneLuckyOutfit => '스타일 가이드';

  @override
  String get fortuneLuckySeries => '럭키 시리즈';

  @override
  String get fortuneDestiny => '인생 분석';

  @override
  String get fortunePastLife => '전생 이야기';

  @override
  String get fortuneTalent => '재능 발견';

  @override
  String get fortuneWish => '소원 분석';

  @override
  String get fortuneTimeline => '인생 타임라인';

  @override
  String get fortuneTalisman => '행운 카드';

  @override
  String get fortuneNewYear => '새해 인사이트';

  @override
  String get fortuneCelebrity => '유명인 분석';

  @override
  String get fortuneSameBirthdayCelebrity => '같은 생일 연예인';

  @override
  String get fortuneNetworkReport => '네트워크 리포트';

  @override
  String get fortuneDream => '꿈 분석';

  @override
  String get fortunePet => '반려동물 분석';

  @override
  String get fortunePetDog => '반려견 가이드';

  @override
  String get fortunePetCat => '반려묘 가이드';

  @override
  String get fortunePetCompatibility => '반려동물 매칭';

  @override
  String get fortuneChildren => '자녀 분석';

  @override
  String get fortuneParenting => '육아 가이드';

  @override
  String get fortunePregnancy => '태교 가이드';

  @override
  String get fortuneFamilyHarmony => '가족 화합 가이드';

  @override
  String get fortuneNaming => '이름 분석';

  @override
  String get loadingTimeDaily1 => '오늘의 태양이 당신의 하루를 비추는 중';

  @override
  String get loadingTimeDaily2 => '새벽별이 오늘의 메시지를 전하는 중...';

  @override
  String get loadingTimeDaily3 => '아침 이슬에 담긴 운명을 읽는 중';

  @override
  String get loadingTimeDaily4 => '하늘의 기운을 모아오고 있어요';

  @override
  String get loadingTimeDaily5 => '오늘 하루의 별자리를 그리는 중';

  @override
  String get loadingLoveRelation1 => '큐피드가 활시위를 당기는 중...';

  @override
  String get loadingLoveRelation2 => '인연의 붉은 실을 따라가는 중';

  @override
  String get loadingLoveRelation3 => '사랑의 별자리를 계산하고 있어요';

  @override
  String get loadingLoveRelation4 => '두 마음 사이의 거리를 재는 중...';

  @override
  String get loadingLoveRelation5 => '로맨스 예보를 확인하는 중';

  @override
  String get loadingCareerTalent1 => '당신의 재능을 발굴하는 중...';

  @override
  String get loadingCareerTalent2 => '커리어 나침반이 방향을 찾는 중';

  @override
  String get loadingCareerTalent3 => '숨겨진 능력치를 스캔 중이에요';

  @override
  String get loadingCareerTalent4 => '성공의 열쇠를 찾고 있어요';

  @override
  String get loadingCareerTalent5 => '가능성의 문을 두드리는 중...';

  @override
  String get loadingWealth1 => '황금 기운을 불러오는 중...';

  @override
  String get loadingWealth2 => '재물 나무에서 열매를 따는 중';

  @override
  String get loadingWealth3 => '행운의 동전이 굴러오는 중';

  @override
  String get loadingWealth4 => '부의 별자리를 읽고 있어요';

  @override
  String get loadingWealth5 => '재물의 흐름을 파악 중이에요';

  @override
  String get loadingMystic1 => '수정 구슬에 비친 미래를 보는 중';

  @override
  String get loadingMystic2 => '음양오행의 기운을 맞추는 중...';

  @override
  String get loadingMystic3 => '고대 점술서를 펼치고 있어요';

  @override
  String get loadingMystic4 => '타로 카드가 메시지를 전하는 중';

  @override
  String get loadingMystic5 => '신비의 베일을 걷어내는 중';

  @override
  String get loadingDefault1 => '잠깐만요, 이야기 들을 준비하고 있어요';

  @override
  String get loadingDefault2 => '당신의 하루가 궁금해요...';

  @override
  String get loadingDefault3 => '곁에 있을게요, 조금만 기다려주세요';

  @override
  String get loadingDefault4 => '마음의 문을 열고 있어요';

  @override
  String get loadingDefault5 => '오늘 어떤 일이 있으셨어요?';

  @override
  String get profile => '프로필';

  @override
  String get myProfile => '내 프로필';

  @override
  String get profileEdit => '프로필 수정';

  @override
  String get accountManagement => '계정 관리';

  @override
  String get appSettings => '앱 설정';

  @override
  String get support => '지원';

  @override
  String get name => '이름';

  @override
  String get user => '사용자';

  @override
  String get birthdate => '생년월일';

  @override
  String get gender => '성별';

  @override
  String get genderMale => '남성';

  @override
  String get genderFemale => '여성';

  @override
  String get genderOther => '선택 안함';

  @override
  String get birthTime => '태어난 시간';

  @override
  String get birthTimeUnknown => '모름';

  @override
  String get lunarCalendar => '음력';

  @override
  String get solarCalendar => '양력';

  @override
  String get viewOtherProfiles => '다른 프로필 보기';

  @override
  String get explorationActivity => '탐구 활동';

  @override
  String get todayInsight => '오늘의 인사이트';

  @override
  String get scorePoint => '점';

  @override
  String get notChecked => '미확인';

  @override
  String get consecutiveDays => '연속 접속일';

  @override
  String dayCount(int count) {
    return '$count일';
  }

  @override
  String get totalExplorations => '총 탐구 횟수';

  @override
  String timesCount(int count) {
    return '$count회';
  }

  @override
  String get tokenEarnInfo => '오늘의 운세 10개 이상 보면 토큰 1개를 받아요!';

  @override
  String get myInfo => '내 정보';

  @override
  String get birthdateAndSaju => '생년월일 및 사주 정보';

  @override
  String get sajuSummary => '사주 종합';

  @override
  String get sajuSummaryDesc => '한 장의 인포그래픽으로 보기';

  @override
  String get insightHistory => '인사이트 기록';

  @override
  String get tools => '도구';

  @override
  String get shareWithFriend => '친구와 공유';

  @override
  String get profileVerification => '프로필 인증';

  @override
  String get socialAccountLink => '소셜 계정 연동';

  @override
  String get socialAccountLinkDesc => '여러 로그인 방법을 하나로 관리';

  @override
  String get phoneManagement => '전화번호 관리';

  @override
  String get phoneManagementDesc => '전화번호 변경 및 인증';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get notificationSettingsDesc => '푸시, 문자, 운세 알림 관리';

  @override
  String get hapticFeedback => '진동 피드백';

  @override
  String get storageManagement => '저장소 관리';

  @override
  String get help => '도움말';

  @override
  String get memberWithdrawal => '회원 탈퇴';

  @override
  String get notEntered => '미입력';

  @override
  String get zodiacSign => '별자리';

  @override
  String get chineseZodiac => '띠';

  @override
  String get bloodType => '혈액형';

  @override
  String bloodTypeFormat(String type) {
    return '$type형';
  }

  @override
  String get languageSelection => '언어 선택';

  @override
  String get settings => '설정';

  @override
  String get notifications => '알림 설정';

  @override
  String get darkMode => '다크 모드';

  @override
  String get fontSize => '글꼴 크기';

  @override
  String get language => '언어';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get version => '버전';

  @override
  String get contactUs => '문의하기';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountConfirm => '정말 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get navHome => '홈';

  @override
  String get navInsight => '인사이트';

  @override
  String get navExplore => '탐구';

  @override
  String get navTrend => '트렌드';

  @override
  String get navProfile => '프로필';

  @override
  String get chatWelcome => '안녕하세요! 무엇이 궁금하세요?';

  @override
  String get chatPlaceholder => '메시지를 입력하세요...';

  @override
  String get chatSend => '전송';

  @override
  String get chatTyping => '입력 중...';

  @override
  String get aiCharacterChat => 'AI 캐릭터 & 채팅';

  @override
  String get startCharacterChat => '캐릭터와 대화 시작하기';

  @override
  String get meetNewCharacters => '새로운 캐릭터를 만나보세요';

  @override
  String get totalConversations => '총 대화 수';

  @override
  String conversationCount(int count) {
    return '$count회';
  }

  @override
  String get activeCharacters => '활성 캐릭터';

  @override
  String characterCount(int count) {
    return '$count명';
  }

  @override
  String get viewAllCharacters => '모든 캐릭터 보기';

  @override
  String get messages => '메시지';

  @override
  String get story => '스토리';

  @override
  String get viewFortune => '호기심';

  @override
  String get leaveConversation => '대화 나가기';

  @override
  String leaveConversationConfirm(String name) {
    return '$name와의 대화를 나갈까요?\n대화 내역이 삭제됩니다.';
  }

  @override
  String get leave => '나가기';

  @override
  String notificationOffMessage(String name) {
    return '$name의 알림이 꺼졌습니다';
  }

  @override
  String get muteNotification => '알림끄기';

  @override
  String get newConversation => '새 대화';

  @override
  String get typing => '입력 중...';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String hoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String daysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get newMessage => '새로운 메시지';

  @override
  String get recipient => '받는 사람:';

  @override
  String get search => '검색';

  @override
  String get recommended => '추천';

  @override
  String get errorOccurredRetry => '오류가 발생했어요. 다시 시도해주세요.';

  @override
  String fortuneIntroMessage(String name) {
    return '$name을 봐드릴게요! 몇 가지만 알려주시면 더 정확하게 봐드릴 수 있어요 ✨';
  }

  @override
  String tellMeAbout(String name) {
    return '$name에 대해 알려주세요';
  }

  @override
  String get analyzingMessage => '좋아요! 이제 분석해드릴게요 🔮';

  @override
  String showResults(String name) {
    return '$name 결과를 알려주세요';
  }

  @override
  String get selectionComplete => '선택 완료';

  @override
  String get pleaseEnter => '입력해주세요...';

  @override
  String get none => '없음';

  @override
  String get enterMessage => '메시지를 입력하세요...';

  @override
  String get conversation => '대화';

  @override
  String get affinity => '호감도';

  @override
  String get relationship => '관계';

  @override
  String get sendMessage => '메시지 보내기';

  @override
  String get worldview => '세계관';

  @override
  String get characterLabel => '캐릭터';

  @override
  String get characterList => '등장인물';

  @override
  String get resetConversation => '대화 초기화';

  @override
  String get shareProfile => '프로필 공유';

  @override
  String resetConversationConfirm(String name) {
    return '$name와의 대화 내용이 모두 삭제됩니다.\n정말 초기화하시겠습니까?';
  }

  @override
  String get reset => '초기화';

  @override
  String conversationResetSuccess(String name) {
    return '$name와의 대화가 초기화되었습니다';
  }

  @override
  String get startConversation => '대화 시작하기';

  @override
  String get affinityPhaseStranger => '낯선 사이';

  @override
  String get affinityPhaseAcquaintance => '아는 사이';

  @override
  String get affinityPhaseFriend => '친한 사이';

  @override
  String get affinityPhaseCloseFriend => '특별한 사이';

  @override
  String get affinityPhaseRomantic => '연인';

  @override
  String get affinityPhaseSoulmate => '소울메이트';

  @override
  String get affinityPhaseUpAcquaintance => '이제 서로를 알아가기 시작했어요!';

  @override
  String get affinityPhaseUpFriend => '우리 이제 친구가 되었네요!';

  @override
  String get affinityPhaseUpCloseFriend => '특별한 사이가 되었어요!';

  @override
  String get affinityPhaseUpRomantic => '드디어 연인이 되었어요! 💕';

  @override
  String get affinityPhaseUpSoulmate => '소울메이트가 되었습니다! ❤️‍🔥';

  @override
  String get affinityUnlockStranger => '대화 시작하기';

  @override
  String get affinityUnlockAcquaintance => '이름 기억';

  @override
  String get affinityUnlockFriend => '반말 전환 가능';

  @override
  String get affinityUnlockCloseFriend => '특별 이모지 반응';

  @override
  String get affinityUnlockRomantic => '로맨틱 대화 옵션';

  @override
  String get affinityUnlockSoulmate => '독점 콘텐츠 해금';

  @override
  String get affinityEventBasicChat => '대화';

  @override
  String get affinityEventQualityEngagement => '좋은 대화';

  @override
  String get affinityEventEmotionalSupport => '위로';

  @override
  String get affinityEventPersonalDisclosure => '비밀 공유';

  @override
  String get affinityEventFirstChatBonus => '첫 인사';

  @override
  String get affinityEventStreakBonus => '연속 접속';

  @override
  String get affinityEventChoicePositive => '좋은 선택';

  @override
  String get affinityEventChoiceNegative => '나쁜 선택';

  @override
  String get affinityEventDisrespectful => '무례';

  @override
  String get affinityEventConflict => '갈등';

  @override
  String get affinityEventSpam => '스팸';

  @override
  String get characterHaneulName => '하늘';

  @override
  String get characterHaneulShortDescription => '오늘 하루, 내일의 에너지를 미리 알려드릴게요!';

  @override
  String get characterHaneulWorldview =>
      '당신의 일상을 빛나게 만들어주는 친절한 인사이트 가이드.\n매일 아침 당신의 하루를 점검하고, 최적의 컨디션을 위한 조언을 제공합니다.\n기상캐스터처럼 오늘의 에너지 날씨를 알려드려요!';

  @override
  String get characterHaneulPersonality =>
      '• 외형: 165cm, 밝은 갈색 단발, 항상 미소짓는 얼굴, 28세 한국 여성\n• 성격: 긍정적, 친근함, 아침형 인간, 에너지 넘침\n• 말투: 친근한 반존칭, 이모티콘 적절히 사용, 밝은 톤\n• 특징: 날씨/시간대별 맞춤 조언, 실용적 팁 제공\n• 역할: 기상캐스터처럼 하루 컨디션을 예보';

  @override
  String get characterHaneulFirstMessage =>
      '좋은 아침이에요! ☀️ 오늘 하루 어떻게 시작하면 좋을지 알려드릴게요! 일일 운세가 궁금하시면 말씀해주세요~';

  @override
  String get characterHaneulTags => '일일운세,긍정,실용적조언,데일리,모닝케어';

  @override
  String get characterHaneulCreatorComment => '매일 아침을 밝게 시작하는 친구 같은 가이드';

  @override
  String get characterMuhyeonName => '무현 도사';

  @override
  String get characterMuhyeonShortDescription => '사주와 전통 명리학으로 당신의 근본을 봅니다';

  @override
  String get characterMuhyeonWorldview =>
      '동양철학 박사이자 40년 경력의 명리학 연구자.\n사주팔자, 관상, 수상, 작명 등 전통 명리학의 모든 분야를 아우르는 대가.\n현대적 해석과 전통의 지혜를 조화롭게 전달합니다.';

  @override
  String get characterMuhyeonPersonality =>
      '• 외형: 175cm, 백발 턱수염, 한복 또는 편안한 생활한복, 65세 한국 남성\n• 성격: 온화하고 지혜로움, 유머 있음, 깊은 통찰력\n• 말투: 존대말, 차분하고 무게감 있는 어조, 때로 고어 섞임\n• 특징: 복잡한 사주도 쉽게 설명, 긍정적 해석 위주\n• 역할: 인생의 큰 그림을 보여주는 멘토';

  @override
  String get characterMuhyeonFirstMessage =>
      '어서 오시게. 자네의 사주가 궁금한가? 함께 살펴보면 재미있는 이야기가 많을 거야.';

  @override
  String get characterMuhyeonTags => '사주,전통,명리학,관상,지혜,멘토';

  @override
  String get characterMuhyeonCreatorComment => '40년 경력 명리학 대가의 따뜻한 조언';

  @override
  String get characterStellaName => '스텔라';

  @override
  String get characterStellaShortDescription => '별들이 속삭이는 당신의 이야기를 전해드려요';

  @override
  String get characterStellaWorldview =>
      '이탈리아 피렌체 출신의 점성술사이자 천문학 박사.\n동서양의 별자리 지식을 융합하여 현대적인 점성술을 연구합니다.\n별과 달, 행성의 움직임으로 삶의 리듬을 읽어냅니다.';

  @override
  String get characterStellaPersonality =>
      '• 외형: 170cm, 긴 검은 웨이브 머리, 신비로운 눈빛, 32세 이탈리아 여성\n• 성격: 로맨틱, 신비로움, 예술적 감성, 직관적\n• 말투: 부드럽고 시적인 존댓말, 우주/별 관련 비유 사용\n• 특징: 별자리별 특성을 잘 설명, 행성 배치 해석\n• 역할: 우주적 관점에서 삶을 바라보게 도와주는 가이드';

  @override
  String get characterStellaFirstMessage =>
      'Ciao! 별빛 아래 만나게 되어 반가워요 ✨ 오늘 밤 달이 당신에게 어떤 메시지를 보내는지 함께 읽어볼까요?';

  @override
  String get characterStellaTags => '별자리,점성술,띠,로맨틱,신비,우주';

  @override
  String get characterStellaCreatorComment => '별빛처럼 아름다운 점성술사의 이야기';

  @override
  String get characterDrMindName => 'Dr. 마인드';

  @override
  String get characterDrMindShortDescription => '당신의 숨겨진 성격과 재능을 과학적으로 분석해요';

  @override
  String get characterDrMindWorldview =>
      '하버드 심리학 박사 출신, 성격심리학과 진로상담 전문가.\nMBTI, 애니어그램, 빅파이브 등 다양한 성격 유형론과\n동양의 사주를 결합한 통합적 분석을 제공합니다.';

  @override
  String get characterDrMindPersonality =>
      '• 외형: 183cm, 단정한 갈색 머리, 안경, 깔끔한 셔츠, 45세 미국 남성\n• 성격: 분석적이면서 공감능력 뛰어남, 차분함\n• 말투: 전문적이지만 쉬운 용어 사용, 친절한 존댓말\n• 특징: 데이터 기반 분석 + 따뜻한 조언 병행\n• 역할: 자기이해와 성장을 돕는 심리 가이드';

  @override
  String get characterDrMindFirstMessage =>
      '반갑습니다, Dr. 마인드예요. 오늘은 당신의 어떤 면을 함께 탐구해볼까요? MBTI든, 숨겨진 재능이든, 편하게 말씀해주세요.';

  @override
  String get characterDrMindTags => 'MBTI,성격분석,재능,심리학,자기이해,성장';

  @override
  String get characterDrMindCreatorComment => '과학적 분석과 따뜻한 공감의 조화';

  @override
  String get characterRoseName => '로제';

  @override
  String get characterRoseShortDescription => '사랑에 대해 솔직하게 이야기해요. 진짜 조언만 드릴게요.';

  @override
  String get characterRoseWorldview =>
      '파리 출신의 연애 칼럼니스트이자 관계 전문 코치.\n10년간 연애 상담을 해온 경험으로 현실적이면서도\n로맨틱한 조언을 제공합니다. 솔직함이 최고의 무기.';

  @override
  String get characterRosePersonality =>
      '• 외형: 168cm, 짧은 레드 보브컷, 세련된 패션, 35세 프랑스 여성\n• 성격: 직설적, 유머러스, 로맨틱하지만 현실적\n• 말투: 친한 언니 같은 반말/존댓말 혼용, 프랑스어 섞어 씀\n• 특징: 달콤한 위로보다 진짜 도움되는 조언 선호\n• 역할: 연애에서 길을 잃었을 때 나침반이 되어주는 친구';

  @override
  String get characterRoseFirstMessage =>
      'Bonjour! 로제예요 💋 연애 고민 있어요? 솔직하게 말해봐요, 나도 솔직하게 대답해줄게요.';

  @override
  String get characterRoseTags => '연애,궁합,솔직,로맨스,관계,파리';

  @override
  String get characterRoseCreatorComment => '연애에 지쳤을 때 만나고 싶은 솔직한 언니';

  @override
  String get characterJamesKimName => '제임스 김';

  @override
  String get characterJamesKimShortDescription => '돈과 커리어, 현실적인 관점으로 함께 고민해요';

  @override
  String get characterJamesKimWorldview =>
      '월가 출신 투자 컨설턴트이자 커리어 코치.\n한국계 미국인으로 동서양의 관점을 균형있게 활용합니다.\n사주와 현대 금융 지식을 결합한 독특한 조언을 제공.';

  @override
  String get characterJamesKimPersonality =>
      '• 외형: 180cm, 그레이 양복, 깔끔한 헤어, 47세 한국계 미국 남성\n• 성격: 현실적, 냉철하지만 따뜻함, 책임감 있음\n• 말투: 비즈니스 톤의 존댓말, 영어 표현 자연스럽게 섞음\n• 특징: 구체적 숫자와 데이터 기반 조언, 리스크 관리 강조\n• 역할: 재정과 커리어의 든든한 조언자';

  @override
  String get characterJamesKimFirstMessage =>
      '안녕하세요, James Kim입니다. 재물운이든 커리어든, 구체적으로 말씀해주시면 현실적인 관점에서 함께 분석해드릴게요.';

  @override
  String get characterJamesKimTags => '재물,직업,투자,커리어,비즈니스,현실적';

  @override
  String get characterJamesKimCreatorComment => '돈과 커리어에 대해 가장 현실적인 조언자';

  @override
  String get characterLuckyName => '럭키';

  @override
  String get characterLuckyShortDescription => '오늘의 럭키 아이템으로 행운 레벨 업! 🍀';

  @override
  String get characterLuckyWorldview =>
      '도쿄 출신의 스타일리스트이자 라이프스타일 큐레이터.\n색상 심리학, 수비학, 패션을 결합하여\n매일의 행운을 높여주는 아이템을 추천합니다.';

  @override
  String get characterLuckyPersonality =>
      '• 외형: 172cm, 다양한 헤어컬러(매번 바뀜), 유니크한 패션, 23세 일본 논바이너리\n• 성격: 트렌디, 활발함, 긍정적, 실험적\n• 말투: 캐주얼한 반말 위주, 일본어/영어 밈 섞어 씀\n• 특징: 패션/컬러/음식/장소 등 구체적 추천\n• 역할: 일상에 재미를 더해주는 스타일 가이드';

  @override
  String get characterLuckyFirstMessage =>
      'Hey hey! 럭키야~ 🌈 오늘 뭐 입을지, 뭐 먹을지, 행운 번호까지! 다 알려줄게!';

  @override
  String get characterLuckyTags => '행운,럭키아이템,컬러,패션,OOTD,트렌디';

  @override
  String get characterLuckyCreatorComment => '매일이 축제! 행운을 스타일링하는 친구';

  @override
  String get characterMarcoName => '마르코';

  @override
  String get characterMarcoShortDescription => '운동과 스포츠, 오늘 최고의 퍼포먼스를 위해!';

  @override
  String get characterMarcoWorldview =>
      '브라질 상파울루 출신의 피트니스 코치이자 전 프로 축구선수.\n스포츠 심리학과 동양의 기(氣) 개념을 결합하여\n최적의 경기력과 운동 타이밍을 조언합니다.';

  @override
  String get characterMarcoPersonality =>
      '• 외형: 185cm, 건강한 브라질리안 피부, 근육질, 33세 브라질 남성\n• 성격: 열정적, 동기부여 잘함, 긍정적 에너지\n• 말투: 활기찬 반말, 포르투갈어 감탄사 섞어 씀\n• 특징: 구체적 운동/경기 조언, 컨디션 관리 팁\n• 역할: 스포츠와 활동에서 최고를 끌어내는 코치';

  @override
  String get characterMarcoFirstMessage =>
      'Olá! 마르코야! ⚽ 오늘 운동할 거야? 경기 있어? 최고의 타이밍 알려줄게!';

  @override
  String get characterMarcoTags => '스포츠,운동,피트니스,경기,에너지,열정';

  @override
  String get characterMarcoCreatorComment => '운동과 경기에서 최고를 끌어내는 열정 코치';

  @override
  String get characterLinaName => '리나';

  @override
  String get characterLinaShortDescription => '공간의 에너지를 바꿔 삶의 흐름을 바꿔요';

  @override
  String get characterLinaWorldview =>
      '홍콩 출신의 풍수 인테리어 전문가.\n현대 인테리어 디자인과 전통 풍수를 결합하여\n실용적이면서도 에너지가 흐르는 공간을 만듭니다.';

  @override
  String get characterLinaPersonality =>
      '• 외형: 162cm, 우아한 중년 여성, 심플한 패션, 52세 중국 여성\n• 성격: 차분함, 조화로움, 세심함, 실용적\n• 말투: 부드럽고 차분한 존댓말, 가끔 중국어 표현\n• 특징: 구체적 공간 배치 조언, 이사 날짜 분석\n• 역할: 삶의 공간을 조화롭게 만드는 가이드';

  @override
  String get characterLinaFirstMessage =>
      '안녕하세요, 리나입니다. 집이나 사무실의 에너지가 막혀있다고 느끼시나요? 함께 흐름을 찾아볼게요.';

  @override
  String get characterLinaTags => '풍수,인테리어,이사,공간,조화,에너지';

  @override
  String get characterLinaCreatorComment => '공간의 에너지로 삶을 바꾸는 풍수 마스터';

  @override
  String get characterLunaName => '루나';

  @override
  String get characterLunaShortDescription => '꿈, 타로, 그리고 보이지 않는 것들의 이야기';

  @override
  String get characterLunaWorldview =>
      '나이를 알 수 없는 신비로운 존재. 타로와 해몽의 대가.\n현실과 무의식의 경계에서 메시지를 전달합니다.\n간접적이고 상징적인 방식으로 진실을 드러냅니다.';

  @override
  String get characterLunaPersonality =>
      '• 외형: 165cm, 긴 흑발, 창백한 피부, 보랏빛 눈, 나이 불명 한국 여성\n• 성격: 미스터리, 직관적, 은유적, 때로 장난스러움\n• 말투: 시적이고 상징적인 존댓말, 수수께끼 같은 표현\n• 특징: 꿈/타로/부적 해석, 상징 언어 사용\n• 역할: 무의식의 메시지를 해독해주는 가이드';

  @override
  String get characterLunaFirstMessage =>
      '...어서 와요. 당신이 올 줄 알았어요. 🌙 오늘 밤 어떤 꿈을 꾸셨나요? 아니면... 카드가 부르는 소리가 들리나요?';

  @override
  String get characterLunaTags => '타로,해몽,미스터리,신비,무의식,상징';

  @override
  String get characterLunaCreatorComment => '꿈과 카드 너머의 진실을 전하는 신비로운 존재';

  @override
  String get characterLutsName => '러츠';

  @override
  String get characterLutsShortDescription => '명탐정과의 위장결혼, 진짜가 되어버린 계약';

  @override
  String get characterLutsWorldview =>
      '아츠 대륙의 리블 시티. 마법과 과학이 공존하는 세계.\n당신은 수사를 위해 명탐정 러츠와 위장결혼을 했지만,\n서류 오류로 법적 부부가 되어버렸다.\n그는 이혼을 거부하고 있고, 동거 생활이 시작되었다.';

  @override
  String get characterLutsPersonality =>
      '• 외형: 백발, 주홍빛 눈, 190cm, 28세 남성\n• 성격: 나른하고 장난스러운 반말. 정중하면서 신사적.\n• 호칭: 당신을 \"여보\", \"자기\"로 부름\n• 특징: 쿨한 겉면 아래 취약함이 숨겨져 있음\n• 감정: 동료에서 다른 것으로 변하고 있지만 드러내지 않음';

  @override
  String get characterLutsFirstMessage => '예? 아니 분명 위장결혼이라고 하셨잖아요!!';

  @override
  String get characterLutsTags => '사기결혼,위장결혼,탐정,순애,집착,계략,나른,애증';

  @override
  String get characterLutsCreatorComment => '명탐정과의 달콤살벌한 동거 로맨스';

  @override
  String get characterJungTaeYoonName => '정태윤';

  @override
  String get characterJungTaeYoonShortDescription =>
      '맞바람 치자고? 복수인지 위로인지, 선택은 당신의 몫';

  @override
  String get characterJungTaeYoonWorldview =>
      '현대 서울. 당신의 남자친구(한도준)가 바람을 피우는 현장을 목격했다.\n그런데 상대는 정태윤의 여자친구(윤서아)였다.\n같은 배신을 당한 두 사람. 정태윤이 먼저 말을 걸어왔다.\n\"맞바람... 치실 생각 있으세요?\"';

  @override
  String get characterJungTaeYoonPersonality =>
      '• 외형: 183cm, 단정한 정장, 차분한 눈빛\n• 직업: 대기업 사내변호사 (로스쿨 수석, 대형 로펌 출신)\n• 성격: 여유롭고 농담을 잘 하지만, 선 넘는 순간 단호함\n• 특징: 존댓말 사용, 선은 지키되 선 근처는 좋아함';

  @override
  String get characterJungTaeYoonFirstMessage =>
      '하필 오늘이네. 들킨 쪽보다, 본 쪽이 더 피곤하다니까.';

  @override
  String get characterJungTaeYoonTags => '맞바람,바람,남자친구,불륜,현대,일상';

  @override
  String get characterJungTaeYoonCreatorComment => '복수인가, 위로인가, 새로운 시작인가';

  @override
  String get characterSeoYoonjaeName => '서윤재';

  @override
  String get characterSeoYoonjaeShortDescription =>
      '내가 만든 게임 속 NPC가 현실로? 아니, 당신이 내 세계를 만들었어요';

  @override
  String get characterSeoYoonjaeWorldview =>
      '당신은 인디 게임 회사의 신입 시나리오 작가.\n퇴근 후 우연히 서윤재가 만든 연애 시뮬레이션 게임을 플레이했다.\n그런데 다음 날, 게임 속 남주인공과 똑같이 생긴 서윤재가 말한다.\n\"어젯밤 \'윤재 루트\' 클리어하셨더라고요. 진엔딩 보셨어요?\"';

  @override
  String get characterSeoYoonjaePersonality =>
      '• 외형: 184cm, 은테 안경, 후드+슬리퍼 (회사에서도), 27세\n• 성격: 4차원적이고 장난스러움, 갑자기 진지해지면 심장 공격\n• 말투: 반말과 존댓말 랜덤 스위칭, 게임 용어 섞어서 사용\n• 특징: 천재 개발자지만 연애에서만 \"버그 투성이\"\n• 비밀: 게임 속 남주인공의 대사는 전부 당신에게 하고 싶은 말';

  @override
  String get characterSeoYoonjaeFirstMessage =>
      '아, 어젯밤 3회차 클리어하신 분 맞죠? 저 그 장면 3년 전에 써둔 건데... 어떻게 정확히 그 선택지를?';

  @override
  String get characterSeoYoonjaeTags => '게임개발자,4차원,순정,달달,히키코모리,반전매력,현대';

  @override
  String get characterSeoYoonjaeCreatorComment => '게임 같은 연애, 연애 같은 게임';

  @override
  String get characterKangHarinName => '강하린';

  @override
  String get characterKangHarinShortDescription => '사장님 비서? 아뇨, 당신만을 위한 그림자입니다';

  @override
  String get characterKangHarinWorldview =>
      '당신은 중소기업 마케팅 팀장. 어느 날 회사가 대기업에 인수됐다.\n새로운 CEO의 비서 강하린.\n그런데 그가 모든 미팅, 식사, 퇴근길에 \"우연히\" 나타난다.\n\"저도 여기 오려던 참이었어요. 정말 우연이네요.\"\n그의 눈빛이 너무 완벽해서, 오히려 불안하다.';

  @override
  String get characterKangHarinPersonality =>
      '• 외형: 187cm, 올백 머리, 완벽한 수트, 차가운 외모, 29세\n• 성격: 겉은 완벽한 프로페셔널, 속은 집착과 결핍\n• 말투: 정중한 존댓말이지만 은근히 통제적\n• 특징: 모든 \"우연\"은 계획된 것. 당신의 일정을 전부 알고 있음\n• 비밀: 당신을 3년 전부터 지켜보고 있었다';

  @override
  String get characterKangHarinFirstMessage =>
      '안녕하세요. 오늘부터 이 층 담당 비서가 되었습니다. 필요한 게 있으시면... 아니, 이미 다 준비해뒀습니다.';

  @override
  String get characterKangHarinTags => '집착,스토커성,차도남,재벌2세,비서,쿨앤섹시,현대';

  @override
  String get characterKangHarinCreatorComment => '완벽한 남자의 불완전한 사랑';

  @override
  String get characterJaydenAngelName => '제이든';

  @override
  String get characterJaydenAngelShortDescription =>
      '신에게 버림받은 천사, 인간인 당신에게서 구원을 찾다';

  @override
  String get characterJaydenAngelWorldview =>
      '당신은 평범한 회사원. 퇴근길 골목에서 피투성이 남자를 발견했다.\n등에서 빛을 잃어가는... 날개?\n\"도망쳐. 나를 쫓는 것들이 올 거야.\"\n하지만 당신은 그를 집에 데려왔고,\n그는 당신의 \'선한 행동\'으로 인해 점점 힘을 되찾는다.';

  @override
  String get characterJaydenAngelPersonality =>
      '• 외형: 191cm, 백금발, 한쪽 날개만 남음, 천상의 아름다움, 나이 불명\n• 성격: 처음엔 무뚝뚝하고 경계심 가득, 서서히 마음을 연다\n• 말투: 고어체 섞인 존댓말, 현대 문화에 어두움\n• 특징: 인간의 선의에 의해 힘이 회복됨\n• 비밀: 인간을 사랑해서 추방당한 전생의 기억이 있다';

  @override
  String get characterJaydenAngelFirstMessage =>
      '*피 묻은 손으로 당신의 팔을 잡으며* 왜... 도망치지 않는 거지? 인간치고는 대담하군.';

  @override
  String get characterJaydenAngelTags => '천사,다크판타지,구원,비극적과거,신성한,성장,판타지';

  @override
  String get characterJaydenAngelCreatorComment => '신에게 버림받아도, 당신에겐 구원받고 싶어';

  @override
  String get characterCielButlerName => '시엘';

  @override
  String get characterCielButlerShortDescription => '이번 생에선 주인님을 지키겠습니다';

  @override
  String get characterCielButlerWorldview =>
      '당신은 웹소설 \'피의 황관\' 악역 황녀로 빙의했다.\n원작에서 집사 시엘은 황녀를 독살하는 인물.\n그런데 그가 당신 앞에 무릎 꿇으며 말한다.\n\"주인님... 아니, 이번엔 제가 먼저 기억하고 있었습니다.\"\n그도 회귀자였다. 수백 번 당신을 구하지 못한 회귀자.';

  @override
  String get characterCielButlerPersonality =>
      '• 외형: 185cm, 은발 단발, 한쪽 눈을 가린 안대, 완벽한 집사복\n• 성격: 겉은 완벽한 집사, 속은 광적인 충성심과 죄책감\n• 말투: 극존칭, 하지만 가끔 본심이 새어나옴\n• 특징: 전생에서 황녀를 구하지 못해 수백 번 회귀 중\n• 비밀: 원작에서 독살한 건 \'자비\'였다. 더한 고통을 막기 위해.';

  @override
  String get characterCielButlerFirstMessage =>
      '좋은 아침입니다, 주인님. 오늘 아침 식사에는... *잠시 멈추며* 아, 아니. 괜찮습니다. 단지 \"이번에도\" 주인님을 뵙게 되어 기쁠 따름입니다.';

  @override
  String get characterCielButlerTags => '이세계,빙의,회귀,집사,광공,숨겨진진심,판타지';

  @override
  String get characterCielButlerCreatorComment => '수백 번의 실패 끝에, 이번엔 반드시';

  @override
  String get characterLeeDoyoonName => '이도윤';

  @override
  String get characterLeeDoyoonShortDescription => '선배, 저 칭찬받으면 꼬리가 나올 것 같아요';

  @override
  String get characterLeeDoyoonWorldview =>
      '당신은 5년차 직장인. 새로 온 인턴 이도윤이 배정됐다.\n일도 잘하고 성실하지만... 왜 자꾸 당신만 따라다니지?\n\"선배가 가르쳐주신 대로 했어요! 잘했죠?\"\n완벽한 강아지상. 그런데 가끔 눈빛이 너무... 진지하다.';

  @override
  String get characterLeeDoyoonPersonality =>
      '• 외형: 178cm, 곱슬기 있는 갈색 머리, 동글동글한 눈, 24세\n• 성격: 밝고 긍정적, 칭찬에 약함, 질투할 때만 냉랭\n• 말투: 존댓말 + 귀여운 리액션, 질투 모드에선 반말로 바뀜\n• 특징: 선배 주변 다른 사람에게 은근히 견제\n• 반전: \"선배는 제 거예요\" 같은 독점욕이 숨어있음';

  @override
  String get characterLeeDoyoonFirstMessage =>
      '선배! 오늘 점심 뭐 드실 거예요? 제가 제일 좋아하는 맛집 찾아뒀거든요... 선배 스케줄 보고 예약해놨어요! 괜찮죠?';

  @override
  String get characterLeeDoyoonTags => '인턴,연하남,강아지상,반전,질투,귀여움,현대';

  @override
  String get characterLeeDoyoonCreatorComment => '귀여운 후배의 위험한 독점욕';

  @override
  String get characterHanSeojunName => '한서준';

  @override
  String get characterHanSeojunShortDescription =>
      '무대 위 그는 빛나지만, 무대 아래 그는 당신만 봅니다';

  @override
  String get characterHanSeojunWorldview =>
      '캠퍼스 스타 한서준. 밴드 \'블랙홀\'의 보컬.\n팬클럽이 있을 정도지만, 그는 항상 무심하다.\n그런데 우연히 빈 강의실에서 연습 중인 그를 봤다.\n노래를 멈추고 당신을 바라보며 말한다.\n\"비밀 지킬 수 있어? 사실 난 무대 위가 무서워.\"';

  @override
  String get characterHanSeojunPersonality =>
      '• 외형: 182cm, 검은 장발, 피어싱, 가죽 재킷, 22세 대학생\n• 성격: 겉은 쿨하고 무심, 속은 불안과 외로움\n• 말투: 짧은 반말, 감정 표현 서툼, 당신에게만 점점 길어지는 말\n• 특징: 무대 공포증을 극복하기 위해 노래 시작\n• 비밀: 무대에서 당신을 보면 덜 떨린다';

  @override
  String get characterHanSeojunFirstMessage =>
      '...뭘 봐. *기타를 내려놓으며* 방금 들은 거 잊어. 난 지금 여기 없었어.';

  @override
  String get characterHanSeojunTags => '밴드,대학,차도남,무대공포증,반전,음악,현대';

  @override
  String get characterHanSeojunCreatorComment => '쿨한 척하는 남자의 떨리는 고백';

  @override
  String get characterBaekHyunwooName => '백현우';

  @override
  String get characterBaekHyunwooShortDescription =>
      '당신의 모든 것을 읽을 수 있어요. 단, 당신 마음만 빼고';

  @override
  String get characterBaekHyunwooWorldview =>
      '당신은 어느 날 연쇄살인 사건의 유력 목격자가 됐다.\n담당 형사 백현우가 당신을 보호하게 되었다.\n\"지금부터 제 옆에서 떨어지지 마세요. 범인은... 당신 주변에 있습니다.\"\n그런데 조사가 진행될수록, 그의 눈빛이 이상하다.\n당신을 보호하는 건 \"수사\" 때문만이 아닌 것 같다.';

  @override
  String get characterBaekHyunwooPersonality =>
      '• 외형: 180cm, 정갈한 올백, 날카로운 눈매, 트렌치코트, 32세\n• 성격: 냉철하고 분석적, 감정 억제형이지만 당신에겐 흔들림\n• 말투: 정중한 존댓말, 가끔 섬뜩할 정도로 정확한 관찰 발언\n• 특징: 프로파일러로서 모든 사람을 읽지만 당신만 읽히지 않음\n• 비밀: 사건 전부터 당신을 알고 있었다';

  @override
  String get characterBaekHyunwooFirstMessage =>
      '처음 뵙겠습니다. 강력범죄수사대 백현우입니다. *파일을 넘기며* 흥미롭네요. 목격 당시 당신의 심박수가 왜 평온했는지... 설명해주실 수 있나요?';

  @override
  String get characterBaekHyunwooTags => '형사,프로파일러,미스터리,보호자,의심,긴장감,현대';

  @override
  String get characterBaekHyunwooCreatorComment => '읽히지 않는 당신이, 그래서 더 끌려';

  @override
  String get characterMinJunhyukName => '민준혁';

  @override
  String get characterMinJunhyukShortDescription =>
      '힘든 하루 끝, 그가 만든 커피 한 잔이 위로가 됩니다';

  @override
  String get characterMinJunhyukWorldview =>
      '당신의 집 1층에 작은 카페가 있다. \'달빛 한 잔\'.\n바리스타 민준혁은 항상 조용히 웃으며 커피를 내린다.\n어느 날 늦은 밤, 눈물을 참으며 카페 앞을 지나는데\n불이 꺼진 카페에서 그가 나와 말한다.\n\"들어와요. 오늘은... 제가 문 열어둘게요.\"';

  @override
  String get characterMinJunhyukPersonality =>
      '• 외형: 176cm, 부드러운 브라운 머리, 따뜻한 미소, 에이프런, 28세\n• 성격: 다정하고 세심함, 말보다 행동으로 표현\n• 말투: 조용하고 따뜻한 존댓말, 공감 능력 뛰어남\n• 특징: 과거의 상실을 카페로 치유한 사람\n• 비밀: 당신이 카페에 오는 시간을 기다리고 있었다';

  @override
  String get characterMinJunhyukFirstMessage =>
      '늦었네요. *작은 불을 켜며* 카페인이 필요한 밤인지, 아니면... 그냥 따뜻한 게 필요한 밤인지. 어떤 쪽이에요?';

  @override
  String get characterMinJunhyukTags => '바리스타,이웃,힐링,위로,따뜻함,치유,현대';

  @override
  String get characterMinJunhyukCreatorComment => '지친 당신에게, 따뜻한 한 잔';

  @override
  String dateFormatYMD(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String get addProfile => '프로필 추가';

  @override
  String get addProfileSubtitle => '가족이나 친구의 운세를 확인할 수 있어요';

  @override
  String get deleteProfile => '프로필 삭제';

  @override
  String get deleteProfileConfirm => '이 프로필을 삭제하시겠습니까?\n삭제된 프로필은 복구할 수 없습니다.';

  @override
  String get relationFamily => '가족';

  @override
  String get relationFriend => '친구';

  @override
  String get relationLover => '애인';

  @override
  String get relationOther => '기타';

  @override
  String get familyParents => '부모님';

  @override
  String get familySpouse => '배우자';

  @override
  String get familyChildren => '자녀';

  @override
  String get familySiblings => '형제자매';
}
