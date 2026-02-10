import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'ZPZG'**
  String get appTitle;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ko, this message translates to:
  /// **'성공'**
  String get success;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get share;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @tokens.
  ///
  /// In ko, this message translates to:
  /// **'토큰'**
  String get tokens;

  /// No description provided for @heldTokens.
  ///
  /// In ko, this message translates to:
  /// **'보유 토큰'**
  String get heldTokens;

  /// No description provided for @tokenCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String tokenCount(int count);

  /// No description provided for @tokenCountWithMax.
  ///
  /// In ko, this message translates to:
  /// **'{current} / {max}개'**
  String tokenCountWithMax(int current, int max);

  /// No description provided for @points.
  ///
  /// In ko, this message translates to:
  /// **'포인트'**
  String get points;

  /// No description provided for @pointsWithCount.
  ///
  /// In ko, this message translates to:
  /// **'{count} 포인트'**
  String pointsWithCount(int count);

  /// No description provided for @bonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get bonus;

  /// No description provided for @points330Title.
  ///
  /// In ko, this message translates to:
  /// **'330 포인트'**
  String get points330Title;

  /// No description provided for @points330Desc.
  ///
  /// In ko, this message translates to:
  /// **'300P + 30P 보너스'**
  String get points330Desc;

  /// No description provided for @points700Title.
  ///
  /// In ko, this message translates to:
  /// **'700 포인트'**
  String get points700Title;

  /// No description provided for @points700Desc.
  ///
  /// In ko, this message translates to:
  /// **'600P + 100P 보너스'**
  String get points700Desc;

  /// No description provided for @points1500Title.
  ///
  /// In ko, this message translates to:
  /// **'1,500 포인트'**
  String get points1500Title;

  /// No description provided for @points1500Desc.
  ///
  /// In ko, this message translates to:
  /// **'1,200P + 300P 보너스'**
  String get points1500Desc;

  /// No description provided for @points4000Title.
  ///
  /// In ko, this message translates to:
  /// **'4,000 포인트'**
  String get points4000Title;

  /// No description provided for @points4000Desc.
  ///
  /// In ko, this message translates to:
  /// **'3,000P + 1,000P 보너스'**
  String get points4000Desc;

  /// No description provided for @proSubscriptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'Pro 구독'**
  String get proSubscriptionTitle;

  /// No description provided for @proSubscriptionDesc.
  ///
  /// In ko, this message translates to:
  /// **'매월 30,000개 토큰 자동 충전'**
  String get proSubscriptionDesc;

  /// No description provided for @maxSubscriptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'Max 구독'**
  String get maxSubscriptionTitle;

  /// No description provided for @maxSubscriptionDesc.
  ///
  /// In ko, this message translates to:
  /// **'매월 100,000개 토큰 자동 충전'**
  String get maxSubscriptionDesc;

  /// No description provided for @premiumSajuTitle.
  ///
  /// In ko, this message translates to:
  /// **'상세 사주명리서'**
  String get premiumSajuTitle;

  /// No description provided for @premiumSajuDesc.
  ///
  /// In ko, this message translates to:
  /// **'215페이지 상세 사주 분석서 (평생 소유)'**
  String get premiumSajuDesc;

  /// No description provided for @dailyPointRecharge.
  ///
  /// In ko, this message translates to:
  /// **'매일 {points}P 충전'**
  String dailyPointRecharge(int points);

  /// No description provided for @pointBonus.
  ///
  /// In ko, this message translates to:
  /// **'{base}P + {bonus}P 보너스'**
  String pointBonus(int base, int bonus);

  /// No description provided for @pointRecharge.
  ///
  /// In ko, this message translates to:
  /// **'{points}P 충전'**
  String pointRecharge(int points);

  /// No description provided for @categoryDailyInsights.
  ///
  /// In ko, this message translates to:
  /// **'일일 인사이트'**
  String get categoryDailyInsights;

  /// No description provided for @categoryTraditional.
  ///
  /// In ko, this message translates to:
  /// **'전통 분석'**
  String get categoryTraditional;

  /// No description provided for @categoryPersonality.
  ///
  /// In ko, this message translates to:
  /// **'성격/캐릭터'**
  String get categoryPersonality;

  /// No description provided for @categoryLoveRelation.
  ///
  /// In ko, this message translates to:
  /// **'연애/관계'**
  String get categoryLoveRelation;

  /// No description provided for @categoryCareerBusiness.
  ///
  /// In ko, this message translates to:
  /// **'직업/사업'**
  String get categoryCareerBusiness;

  /// No description provided for @categoryWealthInvestment.
  ///
  /// In ko, this message translates to:
  /// **'재물/투자'**
  String get categoryWealthInvestment;

  /// No description provided for @categoryHealthLife.
  ///
  /// In ko, this message translates to:
  /// **'건강/라이프'**
  String get categoryHealthLife;

  /// No description provided for @categorySportsActivity.
  ///
  /// In ko, this message translates to:
  /// **'스포츠/활동'**
  String get categorySportsActivity;

  /// No description provided for @categoryLuckyItems.
  ///
  /// In ko, this message translates to:
  /// **'럭키 아이템'**
  String get categoryLuckyItems;

  /// No description provided for @categoryFamilyPet.
  ///
  /// In ko, this message translates to:
  /// **'반려/육아'**
  String get categoryFamilyPet;

  /// No description provided for @categorySpecial.
  ///
  /// In ko, this message translates to:
  /// **'특별 기능'**
  String get categorySpecial;

  /// No description provided for @fortuneDaily.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 메시지'**
  String get fortuneDaily;

  /// No description provided for @fortuneToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 인사이트'**
  String get fortuneToday;

  /// No description provided for @fortuneTomorrow.
  ///
  /// In ko, this message translates to:
  /// **'내일의 인사이트'**
  String get fortuneTomorrow;

  /// No description provided for @fortuneDailyCalendar.
  ///
  /// In ko, this message translates to:
  /// **'날짜별 인사이트'**
  String get fortuneDailyCalendar;

  /// No description provided for @fortuneWeekly.
  ///
  /// In ko, this message translates to:
  /// **'주간 인사이트'**
  String get fortuneWeekly;

  /// No description provided for @fortuneMonthly.
  ///
  /// In ko, this message translates to:
  /// **'월간 인사이트'**
  String get fortuneMonthly;

  /// No description provided for @fortuneTraditional.
  ///
  /// In ko, this message translates to:
  /// **'전통 분석'**
  String get fortuneTraditional;

  /// No description provided for @fortuneSaju.
  ///
  /// In ko, this message translates to:
  /// **'생년월일 분석'**
  String get fortuneSaju;

  /// No description provided for @fortuneTraditionalSaju.
  ///
  /// In ko, this message translates to:
  /// **'전통 생년월일 분석'**
  String get fortuneTraditionalSaju;

  /// No description provided for @fortuneTarot.
  ///
  /// In ko, this message translates to:
  /// **'Insight Cards'**
  String get fortuneTarot;

  /// No description provided for @fortuneSajuPsychology.
  ///
  /// In ko, this message translates to:
  /// **'성격 심리 분석'**
  String get fortuneSajuPsychology;

  /// No description provided for @fortuneTojeong.
  ///
  /// In ko, this message translates to:
  /// **'전통 해석'**
  String get fortuneTojeong;

  /// No description provided for @fortuneSalpuli.
  ///
  /// In ko, this message translates to:
  /// **'기운 정화'**
  String get fortuneSalpuli;

  /// No description provided for @fortunePalmistry.
  ///
  /// In ko, this message translates to:
  /// **'손금 분석'**
  String get fortunePalmistry;

  /// No description provided for @fortunePhysiognomy.
  ///
  /// In ko, this message translates to:
  /// **'Face AI'**
  String get fortunePhysiognomy;

  /// No description provided for @fortuneFaceReading.
  ///
  /// In ko, this message translates to:
  /// **'Face AI'**
  String get fortuneFaceReading;

  /// No description provided for @fortuneFiveBlessings.
  ///
  /// In ko, this message translates to:
  /// **'오복 분석'**
  String get fortuneFiveBlessings;

  /// No description provided for @fortuneMbti.
  ///
  /// In ko, this message translates to:
  /// **'MBTI 분석'**
  String get fortuneMbti;

  /// No description provided for @fortunePersonality.
  ///
  /// In ko, this message translates to:
  /// **'성격 분석'**
  String get fortunePersonality;

  /// No description provided for @fortunePersonalityDna.
  ///
  /// In ko, this message translates to:
  /// **'나의 성격 탐구'**
  String get fortunePersonalityDna;

  /// No description provided for @fortuneBloodType.
  ///
  /// In ko, this message translates to:
  /// **'혈액형 분석'**
  String get fortuneBloodType;

  /// No description provided for @fortuneZodiac.
  ///
  /// In ko, this message translates to:
  /// **'별자리 분석'**
  String get fortuneZodiac;

  /// No description provided for @fortuneZodiacAnimal.
  ///
  /// In ko, this message translates to:
  /// **'띠별 분석'**
  String get fortuneZodiacAnimal;

  /// No description provided for @fortuneBirthSeason.
  ///
  /// In ko, this message translates to:
  /// **'태어난 계절'**
  String get fortuneBirthSeason;

  /// No description provided for @fortuneBirthdate.
  ///
  /// In ko, this message translates to:
  /// **'생일 분석'**
  String get fortuneBirthdate;

  /// No description provided for @fortuneBirthstone.
  ///
  /// In ko, this message translates to:
  /// **'탄생석 가이드'**
  String get fortuneBirthstone;

  /// No description provided for @fortuneBiorhythm.
  ///
  /// In ko, this message translates to:
  /// **'바이오리듬'**
  String get fortuneBiorhythm;

  /// No description provided for @fortuneLove.
  ///
  /// In ko, this message translates to:
  /// **'연애 분석'**
  String get fortuneLove;

  /// No description provided for @fortuneMarriage.
  ///
  /// In ko, this message translates to:
  /// **'결혼 분석'**
  String get fortuneMarriage;

  /// No description provided for @fortuneCompatibility.
  ///
  /// In ko, this message translates to:
  /// **'성향 매칭'**
  String get fortuneCompatibility;

  /// No description provided for @fortuneTraditionalCompatibility.
  ///
  /// In ko, this message translates to:
  /// **'전통 매칭 분석'**
  String get fortuneTraditionalCompatibility;

  /// No description provided for @fortuneChemistry.
  ///
  /// In ko, this message translates to:
  /// **'케미 분석'**
  String get fortuneChemistry;

  /// No description provided for @fortuneCoupleMatch.
  ///
  /// In ko, this message translates to:
  /// **'소울메이트'**
  String get fortuneCoupleMatch;

  /// No description provided for @fortuneExLover.
  ///
  /// In ko, this message translates to:
  /// **'재회 분석'**
  String get fortuneExLover;

  /// No description provided for @fortuneBlindDate.
  ///
  /// In ko, this message translates to:
  /// **'소개팅 가이드'**
  String get fortuneBlindDate;

  /// No description provided for @fortuneCelebrityMatch.
  ///
  /// In ko, this message translates to:
  /// **'연예인 매칭'**
  String get fortuneCelebrityMatch;

  /// No description provided for @fortuneAvoidPeople.
  ///
  /// In ko, this message translates to:
  /// **'관계 주의 타입'**
  String get fortuneAvoidPeople;

  /// No description provided for @fortuneCareer.
  ///
  /// In ko, this message translates to:
  /// **'직업 분석'**
  String get fortuneCareer;

  /// No description provided for @fortuneEmployment.
  ///
  /// In ko, this message translates to:
  /// **'취업 가이드'**
  String get fortuneEmployment;

  /// No description provided for @fortuneBusiness.
  ///
  /// In ko, this message translates to:
  /// **'사업 분석'**
  String get fortuneBusiness;

  /// No description provided for @fortuneStartup.
  ///
  /// In ko, this message translates to:
  /// **'창업 인사이트'**
  String get fortuneStartup;

  /// No description provided for @fortuneLuckyJob.
  ///
  /// In ko, this message translates to:
  /// **'추천 직업'**
  String get fortuneLuckyJob;

  /// No description provided for @fortuneLuckySidejob.
  ///
  /// In ko, this message translates to:
  /// **'부업 가이드'**
  String get fortuneLuckySidejob;

  /// No description provided for @fortuneLuckyExam.
  ///
  /// In ko, this message translates to:
  /// **'시험 가이드'**
  String get fortuneLuckyExam;

  /// No description provided for @fortuneWealth.
  ///
  /// In ko, this message translates to:
  /// **'재물 분석'**
  String get fortuneWealth;

  /// No description provided for @fortuneInvestment.
  ///
  /// In ko, this message translates to:
  /// **'투자 인사이트'**
  String get fortuneInvestment;

  /// No description provided for @fortuneLuckyInvestment.
  ///
  /// In ko, this message translates to:
  /// **'투자 가이드'**
  String get fortuneLuckyInvestment;

  /// No description provided for @fortuneLuckyRealestate.
  ///
  /// In ko, this message translates to:
  /// **'부동산 인사이트'**
  String get fortuneLuckyRealestate;

  /// No description provided for @fortuneLuckyStock.
  ///
  /// In ko, this message translates to:
  /// **'주식 가이드'**
  String get fortuneLuckyStock;

  /// No description provided for @fortuneLuckyCrypto.
  ///
  /// In ko, this message translates to:
  /// **'암호화폐 가이드'**
  String get fortuneLuckyCrypto;

  /// No description provided for @fortuneLuckyLottery.
  ///
  /// In ko, this message translates to:
  /// **'로또 번호 생성'**
  String get fortuneLuckyLottery;

  /// No description provided for @fortuneHealth.
  ///
  /// In ko, this message translates to:
  /// **'건강 체크'**
  String get fortuneHealth;

  /// No description provided for @fortuneMoving.
  ///
  /// In ko, this message translates to:
  /// **'이사 가이드'**
  String get fortuneMoving;

  /// No description provided for @fortuneMovingDate.
  ///
  /// In ko, this message translates to:
  /// **'이사 날짜 추천'**
  String get fortuneMovingDate;

  /// No description provided for @fortuneMovingUnified.
  ///
  /// In ko, this message translates to:
  /// **'이사 플래너'**
  String get fortuneMovingUnified;

  /// No description provided for @fortuneLuckyColor.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 색깔'**
  String get fortuneLuckyColor;

  /// No description provided for @fortuneLuckyNumber.
  ///
  /// In ko, this message translates to:
  /// **'행운 숫자'**
  String get fortuneLuckyNumber;

  /// No description provided for @fortuneLuckyItems.
  ///
  /// In ko, this message translates to:
  /// **'럭키 아이템'**
  String get fortuneLuckyItems;

  /// No description provided for @fortuneLuckyFood.
  ///
  /// In ko, this message translates to:
  /// **'추천 음식'**
  String get fortuneLuckyFood;

  /// No description provided for @fortuneLuckyPlace.
  ///
  /// In ko, this message translates to:
  /// **'추천 장소'**
  String get fortuneLuckyPlace;

  /// No description provided for @fortuneLuckyOutfit.
  ///
  /// In ko, this message translates to:
  /// **'스타일 가이드'**
  String get fortuneLuckyOutfit;

  /// No description provided for @fortuneLuckySeries.
  ///
  /// In ko, this message translates to:
  /// **'럭키 시리즈'**
  String get fortuneLuckySeries;

  /// No description provided for @fortuneDestiny.
  ///
  /// In ko, this message translates to:
  /// **'인생 분석'**
  String get fortuneDestiny;

  /// No description provided for @fortunePastLife.
  ///
  /// In ko, this message translates to:
  /// **'전생 이야기'**
  String get fortunePastLife;

  /// No description provided for @fortuneTalent.
  ///
  /// In ko, this message translates to:
  /// **'재능 발견'**
  String get fortuneTalent;

  /// No description provided for @fortuneWish.
  ///
  /// In ko, this message translates to:
  /// **'소원 분석'**
  String get fortuneWish;

  /// No description provided for @fortuneTimeline.
  ///
  /// In ko, this message translates to:
  /// **'인생 타임라인'**
  String get fortuneTimeline;

  /// No description provided for @fortuneTalisman.
  ///
  /// In ko, this message translates to:
  /// **'행운 카드'**
  String get fortuneTalisman;

  /// No description provided for @fortuneNewYear.
  ///
  /// In ko, this message translates to:
  /// **'새해 인사이트'**
  String get fortuneNewYear;

  /// No description provided for @fortuneCelebrity.
  ///
  /// In ko, this message translates to:
  /// **'유명인 분석'**
  String get fortuneCelebrity;

  /// No description provided for @fortuneSameBirthdayCelebrity.
  ///
  /// In ko, this message translates to:
  /// **'같은 생일 연예인'**
  String get fortuneSameBirthdayCelebrity;

  /// No description provided for @fortuneNetworkReport.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 리포트'**
  String get fortuneNetworkReport;

  /// No description provided for @fortuneDream.
  ///
  /// In ko, this message translates to:
  /// **'꿈 분석'**
  String get fortuneDream;

  /// No description provided for @fortunePet.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 분석'**
  String get fortunePet;

  /// No description provided for @fortunePetDog.
  ///
  /// In ko, this message translates to:
  /// **'반려견 가이드'**
  String get fortunePetDog;

  /// No description provided for @fortunePetCat.
  ///
  /// In ko, this message translates to:
  /// **'반려묘 가이드'**
  String get fortunePetCat;

  /// No description provided for @fortunePetCompatibility.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 매칭'**
  String get fortunePetCompatibility;

  /// No description provided for @fortuneChildren.
  ///
  /// In ko, this message translates to:
  /// **'자녀 분석'**
  String get fortuneChildren;

  /// No description provided for @fortuneParenting.
  ///
  /// In ko, this message translates to:
  /// **'육아 가이드'**
  String get fortuneParenting;

  /// No description provided for @fortunePregnancy.
  ///
  /// In ko, this message translates to:
  /// **'태교 가이드'**
  String get fortunePregnancy;

  /// No description provided for @fortuneFamilyHarmony.
  ///
  /// In ko, this message translates to:
  /// **'가족 화합 가이드'**
  String get fortuneFamilyHarmony;

  /// No description provided for @fortuneNaming.
  ///
  /// In ko, this message translates to:
  /// **'이름 분석'**
  String get fortuneNaming;

  /// No description provided for @loadingTimeDaily1.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 태양이 당신의 하루를 비추는 중'**
  String get loadingTimeDaily1;

  /// No description provided for @loadingTimeDaily2.
  ///
  /// In ko, this message translates to:
  /// **'새벽별이 오늘의 메시지를 전하는 중...'**
  String get loadingTimeDaily2;

  /// No description provided for @loadingTimeDaily3.
  ///
  /// In ko, this message translates to:
  /// **'아침 이슬에 담긴 운명을 읽는 중'**
  String get loadingTimeDaily3;

  /// No description provided for @loadingTimeDaily4.
  ///
  /// In ko, this message translates to:
  /// **'하늘의 기운을 모아오고 있어요'**
  String get loadingTimeDaily4;

  /// No description provided for @loadingTimeDaily5.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루의 별자리를 그리는 중'**
  String get loadingTimeDaily5;

  /// No description provided for @loadingLoveRelation1.
  ///
  /// In ko, this message translates to:
  /// **'큐피드가 활시위를 당기는 중...'**
  String get loadingLoveRelation1;

  /// No description provided for @loadingLoveRelation2.
  ///
  /// In ko, this message translates to:
  /// **'인연의 붉은 실을 따라가는 중'**
  String get loadingLoveRelation2;

  /// No description provided for @loadingLoveRelation3.
  ///
  /// In ko, this message translates to:
  /// **'사랑의 별자리를 계산하고 있어요'**
  String get loadingLoveRelation3;

  /// No description provided for @loadingLoveRelation4.
  ///
  /// In ko, this message translates to:
  /// **'두 마음 사이의 거리를 재는 중...'**
  String get loadingLoveRelation4;

  /// No description provided for @loadingLoveRelation5.
  ///
  /// In ko, this message translates to:
  /// **'로맨스 예보를 확인하는 중'**
  String get loadingLoveRelation5;

  /// No description provided for @loadingCareerTalent1.
  ///
  /// In ko, this message translates to:
  /// **'당신의 재능을 발굴하는 중...'**
  String get loadingCareerTalent1;

  /// No description provided for @loadingCareerTalent2.
  ///
  /// In ko, this message translates to:
  /// **'커리어 나침반이 방향을 찾는 중'**
  String get loadingCareerTalent2;

  /// No description provided for @loadingCareerTalent3.
  ///
  /// In ko, this message translates to:
  /// **'숨겨진 능력치를 스캔 중이에요'**
  String get loadingCareerTalent3;

  /// No description provided for @loadingCareerTalent4.
  ///
  /// In ko, this message translates to:
  /// **'성공의 열쇠를 찾고 있어요'**
  String get loadingCareerTalent4;

  /// No description provided for @loadingCareerTalent5.
  ///
  /// In ko, this message translates to:
  /// **'가능성의 문을 두드리는 중...'**
  String get loadingCareerTalent5;

  /// No description provided for @loadingWealth1.
  ///
  /// In ko, this message translates to:
  /// **'황금 기운을 불러오는 중...'**
  String get loadingWealth1;

  /// No description provided for @loadingWealth2.
  ///
  /// In ko, this message translates to:
  /// **'재물 나무에서 열매를 따는 중'**
  String get loadingWealth2;

  /// No description provided for @loadingWealth3.
  ///
  /// In ko, this message translates to:
  /// **'행운의 동전이 굴러오는 중'**
  String get loadingWealth3;

  /// No description provided for @loadingWealth4.
  ///
  /// In ko, this message translates to:
  /// **'부의 별자리를 읽고 있어요'**
  String get loadingWealth4;

  /// No description provided for @loadingWealth5.
  ///
  /// In ko, this message translates to:
  /// **'재물의 흐름을 파악 중이에요'**
  String get loadingWealth5;

  /// No description provided for @loadingMystic1.
  ///
  /// In ko, this message translates to:
  /// **'수정 구슬에 비친 미래를 보는 중'**
  String get loadingMystic1;

  /// No description provided for @loadingMystic2.
  ///
  /// In ko, this message translates to:
  /// **'음양오행의 기운을 맞추는 중...'**
  String get loadingMystic2;

  /// No description provided for @loadingMystic3.
  ///
  /// In ko, this message translates to:
  /// **'고대 점술서를 펼치고 있어요'**
  String get loadingMystic3;

  /// No description provided for @loadingMystic4.
  ///
  /// In ko, this message translates to:
  /// **'타로 카드가 메시지를 전하는 중'**
  String get loadingMystic4;

  /// No description provided for @loadingMystic5.
  ///
  /// In ko, this message translates to:
  /// **'신비의 베일을 걷어내는 중'**
  String get loadingMystic5;

  /// No description provided for @loadingDefault1.
  ///
  /// In ko, this message translates to:
  /// **'잠깐만요, 이야기 들을 준비하고 있어요'**
  String get loadingDefault1;

  /// No description provided for @loadingDefault2.
  ///
  /// In ko, this message translates to:
  /// **'당신의 하루가 궁금해요...'**
  String get loadingDefault2;

  /// No description provided for @loadingDefault3.
  ///
  /// In ko, this message translates to:
  /// **'곁에 있을게요, 조금만 기다려주세요'**
  String get loadingDefault3;

  /// No description provided for @loadingDefault4.
  ///
  /// In ko, this message translates to:
  /// **'마음의 문을 열고 있어요'**
  String get loadingDefault4;

  /// No description provided for @loadingDefault5.
  ///
  /// In ko, this message translates to:
  /// **'오늘 어떤 일이 있으셨어요?'**
  String get loadingDefault5;

  /// No description provided for @profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// No description provided for @profileEdit.
  ///
  /// In ko, this message translates to:
  /// **'프로필 수정'**
  String get profileEdit;

  /// No description provided for @accountManagement.
  ///
  /// In ko, this message translates to:
  /// **'계정 관리'**
  String get accountManagement;

  /// No description provided for @appSettings.
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get appSettings;

  /// No description provided for @support.
  ///
  /// In ko, this message translates to:
  /// **'지원'**
  String get support;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @birthdate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일'**
  String get birthdate;

  /// No description provided for @gender.
  ///
  /// In ko, this message translates to:
  /// **'성별'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In ko, this message translates to:
  /// **'남성'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In ko, this message translates to:
  /// **'여성'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In ko, this message translates to:
  /// **'선택 안함'**
  String get genderOther;

  /// No description provided for @birthTime.
  ///
  /// In ko, this message translates to:
  /// **'태어난 시간'**
  String get birthTime;

  /// No description provided for @birthTimeUnknown.
  ///
  /// In ko, this message translates to:
  /// **'모름'**
  String get birthTimeUnknown;

  /// No description provided for @lunarCalendar.
  ///
  /// In ko, this message translates to:
  /// **'음력'**
  String get lunarCalendar;

  /// No description provided for @solarCalendar.
  ///
  /// In ko, this message translates to:
  /// **'양력'**
  String get solarCalendar;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get darkMode;

  /// No description provided for @fontSize.
  ///
  /// In ko, this message translates to:
  /// **'글꼴 크기'**
  String get fontSize;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @contactUs.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get contactUs;

  /// No description provided for @deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'**
  String get deleteAccountConfirm;

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navInsight.
  ///
  /// In ko, this message translates to:
  /// **'인사이트'**
  String get navInsight;

  /// No description provided for @navExplore.
  ///
  /// In ko, this message translates to:
  /// **'탐구'**
  String get navExplore;

  /// No description provided for @navTrend.
  ///
  /// In ko, this message translates to:
  /// **'트렌드'**
  String get navTrend;

  /// No description provided for @navProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get navProfile;

  /// No description provided for @chatWelcome.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요! 무엇이 궁금하세요?'**
  String get chatWelcome;

  /// No description provided for @chatPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요...'**
  String get chatPlaceholder;

  /// No description provided for @chatSend.
  ///
  /// In ko, this message translates to:
  /// **'전송'**
  String get chatSend;

  /// No description provided for @chatTyping.
  ///
  /// In ko, this message translates to:
  /// **'입력 중...'**
  String get chatTyping;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
