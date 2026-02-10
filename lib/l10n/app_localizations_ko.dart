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
}
