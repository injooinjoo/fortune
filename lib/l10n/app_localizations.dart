import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
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
    Locale('ja'),
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
  /// **'토큰'**
  String get points;

  /// No description provided for @pointsWithCount.
  ///
  /// In ko, this message translates to:
  /// **'{count} 토큰'**
  String pointsWithCount(int count);

  /// No description provided for @bonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get bonus;

  /// No description provided for @points350Title.
  ///
  /// In ko, this message translates to:
  /// **'350 토큰'**
  String get points350Title;

  /// No description provided for @points350Desc.
  ///
  /// In ko, this message translates to:
  /// **'300 + 50 보너스'**
  String get points350Desc;

  /// No description provided for @points700Title.
  ///
  /// In ko, this message translates to:
  /// **'700 토큰'**
  String get points700Title;

  /// No description provided for @points700Desc.
  ///
  /// In ko, this message translates to:
  /// **'600 + 100 보너스'**
  String get points700Desc;

  /// No description provided for @points1650Title.
  ///
  /// In ko, this message translates to:
  /// **'1,650 토큰'**
  String get points1650Title;

  /// No description provided for @points1650Desc.
  ///
  /// In ko, this message translates to:
  /// **'1,500 + 150 보너스'**
  String get points1650Desc;

  /// No description provided for @points4400Title.
  ///
  /// In ko, this message translates to:
  /// **'4,400 토큰'**
  String get points4400Title;

  /// No description provided for @points4400Desc.
  ///
  /// In ko, this message translates to:
  /// **'4,000 + 400 보너스'**
  String get points4400Desc;

  /// No description provided for @proSubscriptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'Pro 구독'**
  String get proSubscriptionTitle;

  /// No description provided for @proSubscriptionDesc.
  ///
  /// In ko, this message translates to:
  /// **'매월 3,000 토큰 자동 충전'**
  String get proSubscriptionDesc;

  /// No description provided for @maxSubscriptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'Max 구독'**
  String get maxSubscriptionTitle;

  /// No description provided for @maxSubscriptionDesc.
  ///
  /// In ko, this message translates to:
  /// **'매월 12,600 토큰 자동 충전'**
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
  /// **'오늘의 운세'**
  String get fortuneDaily;

  /// No description provided for @fortuneToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운세'**
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

  /// No description provided for @fortuneConstellation.
  ///
  /// In ko, this message translates to:
  /// **'별자리 특성'**
  String get fortuneConstellation;

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

  /// No description provided for @fortuneFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족 궁합'**
  String get fortuneFamily;

  /// No description provided for @fortuneFortuneCookie.
  ///
  /// In ko, this message translates to:
  /// **'포춘쿠키'**
  String get fortuneFortuneCookie;

  /// No description provided for @fortuneGratitude.
  ///
  /// In ko, this message translates to:
  /// **'감사 일기'**
  String get fortuneGratitude;

  /// No description provided for @fortuneCoaching.
  ///
  /// In ko, this message translates to:
  /// **'AI 코칭'**
  String get fortuneCoaching;

  /// No description provided for @fortuneDecisionHelper.
  ///
  /// In ko, this message translates to:
  /// **'고민 해결'**
  String get fortuneDecisionHelper;

  /// No description provided for @fortuneDailyReview.
  ///
  /// In ko, this message translates to:
  /// **'하루 정리'**
  String get fortuneDailyReview;

  /// No description provided for @fortuneWeeklyReview.
  ///
  /// In ko, this message translates to:
  /// **'주간 리뷰'**
  String get fortuneWeeklyReview;

  /// No description provided for @fortuneChatInsight.
  ///
  /// In ko, this message translates to:
  /// **'카톡 대화 분석'**
  String get fortuneChatInsight;

  /// No description provided for @fortuneExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 운세'**
  String get fortuneExercise;

  /// No description provided for @fortuneSportsGame.
  ///
  /// In ko, this message translates to:
  /// **'경기 승부'**
  String get fortuneSportsGame;

  /// No description provided for @fortuneOotdEvaluation.
  ///
  /// In ko, this message translates to:
  /// **'코디 점수'**
  String get fortuneOotdEvaluation;

  /// No description provided for @fortuneYearlyEncounter.
  ///
  /// In ko, this message translates to:
  /// **'올해의 인연'**
  String get fortuneYearlyEncounter;

  /// No description provided for @fortuneBabyNickname.
  ///
  /// In ko, this message translates to:
  /// **'태명 짓기'**
  String get fortuneBabyNickname;

  /// No description provided for @fortuneBreathing.
  ///
  /// In ko, this message translates to:
  /// **'명상 가이드'**
  String get fortuneBreathing;

  /// No description provided for @fortuneMoney.
  ///
  /// In ko, this message translates to:
  /// **'재물 운세'**
  String get fortuneMoney;

  /// No description provided for @fortuneGameEnhance.
  ///
  /// In ko, this message translates to:
  /// **'게임 강화운'**
  String get fortuneGameEnhance;

  /// No description provided for @chipViewAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 보기'**
  String get chipViewAll;

  /// No description provided for @chipViewMore.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get chipViewMore;

  /// No description provided for @fortuneFeatureComingSoon.
  ///
  /// In ko, this message translates to:
  /// **'{name} 기능은 곧 준비될 예정이에요! 🔮\n다른 인사이트를 먼저 확인해보시겠어요?'**
  String fortuneFeatureComingSoon(String name);

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

  /// No description provided for @myProfile.
  ///
  /// In ko, this message translates to:
  /// **'내 프로필'**
  String get myProfile;

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

  /// No description provided for @user.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get user;

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

  /// No description provided for @viewOtherProfiles.
  ///
  /// In ko, this message translates to:
  /// **'다른 프로필 보기'**
  String get viewOtherProfiles;

  /// No description provided for @explorationActivity.
  ///
  /// In ko, this message translates to:
  /// **'탐구 활동'**
  String get explorationActivity;

  /// No description provided for @todayInsight.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운세'**
  String get todayInsight;

  /// No description provided for @scorePoint.
  ///
  /// In ko, this message translates to:
  /// **'점'**
  String get scorePoint;

  /// No description provided for @notChecked.
  ///
  /// In ko, this message translates to:
  /// **'미확인'**
  String get notChecked;

  /// No description provided for @consecutiveDays.
  ///
  /// In ko, this message translates to:
  /// **'연속 접속일'**
  String get consecutiveDays;

  /// No description provided for @dayCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}일'**
  String dayCount(int count);

  /// No description provided for @totalExplorations.
  ///
  /// In ko, this message translates to:
  /// **'총 탐구 횟수'**
  String get totalExplorations;

  /// No description provided for @timesCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String timesCount(int count);

  /// No description provided for @tokenEarnInfo.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운세 10개 이상 보면 토큰 1개를 받아요!'**
  String get tokenEarnInfo;

  /// No description provided for @myInfo.
  ///
  /// In ko, this message translates to:
  /// **'내 정보'**
  String get myInfo;

  /// No description provided for @birthdateAndSaju.
  ///
  /// In ko, this message translates to:
  /// **'생년월일 및 사주 정보'**
  String get birthdateAndSaju;

  /// No description provided for @sajuSummary.
  ///
  /// In ko, this message translates to:
  /// **'사주 종합'**
  String get sajuSummary;

  /// No description provided for @sajuSummaryDesc.
  ///
  /// In ko, this message translates to:
  /// **'한 장의 인포그래픽으로 보기'**
  String get sajuSummaryDesc;

  /// No description provided for @insightHistory.
  ///
  /// In ko, this message translates to:
  /// **'인사이트 기록'**
  String get insightHistory;

  /// No description provided for @tools.
  ///
  /// In ko, this message translates to:
  /// **'도구'**
  String get tools;

  /// No description provided for @shareWithFriend.
  ///
  /// In ko, this message translates to:
  /// **'친구와 공유'**
  String get shareWithFriend;

  /// No description provided for @profileVerification.
  ///
  /// In ko, this message translates to:
  /// **'프로필 인증'**
  String get profileVerification;

  /// No description provided for @socialAccountLink.
  ///
  /// In ko, this message translates to:
  /// **'소셜 계정 연동'**
  String get socialAccountLink;

  /// No description provided for @socialAccountLinkDesc.
  ///
  /// In ko, this message translates to:
  /// **'여러 로그인 방법을 하나로 관리'**
  String get socialAccountLinkDesc;

  /// No description provided for @phoneManagement.
  ///
  /// In ko, this message translates to:
  /// **'전화번호 관리'**
  String get phoneManagement;

  /// No description provided for @phoneManagementDesc.
  ///
  /// In ko, this message translates to:
  /// **'전화번호 변경 및 인증'**
  String get phoneManagementDesc;

  /// No description provided for @notificationSettings.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In ko, this message translates to:
  /// **'푸시, 문자, 운세 알림 관리'**
  String get notificationSettingsDesc;

  /// No description provided for @hapticFeedback.
  ///
  /// In ko, this message translates to:
  /// **'진동 피드백'**
  String get hapticFeedback;

  /// No description provided for @storageManagement.
  ///
  /// In ko, this message translates to:
  /// **'저장소 관리'**
  String get storageManagement;

  /// No description provided for @help.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get help;

  /// No description provided for @memberWithdrawal.
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get memberWithdrawal;

  /// No description provided for @notEntered.
  ///
  /// In ko, this message translates to:
  /// **'미입력'**
  String get notEntered;

  /// No description provided for @zodiacSign.
  ///
  /// In ko, this message translates to:
  /// **'별자리'**
  String get zodiacSign;

  /// No description provided for @chineseZodiac.
  ///
  /// In ko, this message translates to:
  /// **'띠'**
  String get chineseZodiac;

  /// No description provided for @bloodType.
  ///
  /// In ko, this message translates to:
  /// **'혈액형'**
  String get bloodType;

  /// No description provided for @bloodTypeFormat.
  ///
  /// In ko, this message translates to:
  /// **'{type}형'**
  String bloodTypeFormat(String type);

  /// No description provided for @languageSelection.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get languageSelection;

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

  /// No description provided for @aiCharacterChat.
  ///
  /// In ko, this message translates to:
  /// **'AI 캐릭터 & 채팅'**
  String get aiCharacterChat;

  /// No description provided for @startCharacterChat.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터와 대화 시작하기'**
  String get startCharacterChat;

  /// No description provided for @meetNewCharacters.
  ///
  /// In ko, this message translates to:
  /// **'새로운 캐릭터를 만나보세요'**
  String get meetNewCharacters;

  /// No description provided for @totalConversations.
  ///
  /// In ko, this message translates to:
  /// **'총 대화 수'**
  String get totalConversations;

  /// No description provided for @conversationCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String conversationCount(int count);

  /// No description provided for @activeCharacters.
  ///
  /// In ko, this message translates to:
  /// **'활성 캐릭터'**
  String get activeCharacters;

  /// No description provided for @characterCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String characterCount(int count);

  /// No description provided for @viewAllCharacters.
  ///
  /// In ko, this message translates to:
  /// **'모든 캐릭터 보기'**
  String get viewAllCharacters;

  /// No description provided for @messages.
  ///
  /// In ko, this message translates to:
  /// **'메시지'**
  String get messages;

  /// No description provided for @story.
  ///
  /// In ko, this message translates to:
  /// **'스토리'**
  String get story;

  /// No description provided for @viewFortune.
  ///
  /// In ko, this message translates to:
  /// **'호기심'**
  String get viewFortune;

  /// No description provided for @leaveConversation.
  ///
  /// In ko, this message translates to:
  /// **'대화 나가기'**
  String get leaveConversation;

  /// No description provided for @leaveConversationConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name}와의 대화를 나갈까요?\n대화 내역이 삭제됩니다.'**
  String leaveConversationConfirm(String name);

  /// No description provided for @leave.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get leave;

  /// No description provided for @notificationOffMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 알림이 꺼졌습니다'**
  String notificationOffMessage(String name);

  /// No description provided for @muteNotification.
  ///
  /// In ko, this message translates to:
  /// **'알림끄기'**
  String get muteNotification;

  /// No description provided for @newConversation.
  ///
  /// In ko, this message translates to:
  /// **'새 대화'**
  String get newConversation;

  /// No description provided for @yourTurn.
  ///
  /// In ko, this message translates to:
  /// **'내 차례'**
  String get yourTurn;

  /// No description provided for @typing.
  ///
  /// In ko, this message translates to:
  /// **'입력 중...'**
  String get typing;

  /// No description provided for @justNow.
  ///
  /// In ko, this message translates to:
  /// **'방금'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}분 전'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}시간 전'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}일 전'**
  String daysAgo(int count);

  /// No description provided for @newMessage.
  ///
  /// In ko, this message translates to:
  /// **'새로운 메시지'**
  String get newMessage;

  /// No description provided for @recipient.
  ///
  /// In ko, this message translates to:
  /// **'받는 사람:'**
  String get recipient;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @recommended.
  ///
  /// In ko, this message translates to:
  /// **'추천'**
  String get recommended;

  /// No description provided for @errorOccurredRetry.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했어요. 다시 시도해주세요.'**
  String get errorOccurredRetry;

  /// No description provided for @fortuneIntroMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}을 봐드릴게요! 몇 가지만 알려주시면 더 정확하게 봐드릴 수 있어요 ✨'**
  String fortuneIntroMessage(String name);

  /// No description provided for @tellMeAbout.
  ///
  /// In ko, this message translates to:
  /// **'{name}에 대해 알려주세요'**
  String tellMeAbout(String name);

  /// No description provided for @analyzingMessage.
  ///
  /// In ko, this message translates to:
  /// **'좋아요! 이제 분석해드릴게요 🔮'**
  String get analyzingMessage;

  /// No description provided for @showResults.
  ///
  /// In ko, this message translates to:
  /// **'{name} 결과를 알려주세요'**
  String showResults(String name);

  /// No description provided for @selectionComplete.
  ///
  /// In ko, this message translates to:
  /// **'선택 완료'**
  String get selectionComplete;

  /// No description provided for @pleaseEnter.
  ///
  /// In ko, this message translates to:
  /// **'입력해주세요...'**
  String get pleaseEnter;

  /// No description provided for @none.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get none;

  /// No description provided for @enterMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요...'**
  String get enterMessage;

  /// No description provided for @conversation.
  ///
  /// In ko, this message translates to:
  /// **'대화'**
  String get conversation;

  /// No description provided for @affinity.
  ///
  /// In ko, this message translates to:
  /// **'호감도'**
  String get affinity;

  /// No description provided for @relationship.
  ///
  /// In ko, this message translates to:
  /// **'관계'**
  String get relationship;

  /// No description provided for @profilePosts.
  ///
  /// In ko, this message translates to:
  /// **'포스트'**
  String get profilePosts;

  /// No description provided for @profileFollowers.
  ///
  /// In ko, this message translates to:
  /// **'팔로워'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In ko, this message translates to:
  /// **'팔로잉'**
  String get profileFollowing;

  /// No description provided for @sendMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지 보내기'**
  String get sendMessage;

  /// No description provided for @worldview.
  ///
  /// In ko, this message translates to:
  /// **'세계관'**
  String get worldview;

  /// No description provided for @characterLabel.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터'**
  String get characterLabel;

  /// No description provided for @characterList.
  ///
  /// In ko, this message translates to:
  /// **'등장인물'**
  String get characterList;

  /// No description provided for @resetConversation.
  ///
  /// In ko, this message translates to:
  /// **'대화 초기화'**
  String get resetConversation;

  /// No description provided for @shareProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 공유'**
  String get shareProfile;

  /// No description provided for @resetConversationConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name}와의 대화 내용이 모두 삭제됩니다.\n정말 초기화하시겠습니까?'**
  String resetConversationConfirm(String name);

  /// No description provided for @reset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get reset;

  /// No description provided for @conversationResetSuccess.
  ///
  /// In ko, this message translates to:
  /// **'{name}와의 대화가 초기화되었습니다'**
  String conversationResetSuccess(String name);

  /// No description provided for @startConversation.
  ///
  /// In ko, this message translates to:
  /// **'대화 시작하기'**
  String get startConversation;

  /// No description provided for @affinityPhaseStranger.
  ///
  /// In ko, this message translates to:
  /// **'낯선 사이'**
  String get affinityPhaseStranger;

  /// No description provided for @affinityPhaseAcquaintance.
  ///
  /// In ko, this message translates to:
  /// **'아는 사이'**
  String get affinityPhaseAcquaintance;

  /// No description provided for @affinityPhaseFriend.
  ///
  /// In ko, this message translates to:
  /// **'친한 사이'**
  String get affinityPhaseFriend;

  /// No description provided for @affinityPhaseCloseFriend.
  ///
  /// In ko, this message translates to:
  /// **'특별한 사이'**
  String get affinityPhaseCloseFriend;

  /// No description provided for @affinityPhaseRomantic.
  ///
  /// In ko, this message translates to:
  /// **'연인'**
  String get affinityPhaseRomantic;

  /// No description provided for @affinityPhaseSoulmate.
  ///
  /// In ko, this message translates to:
  /// **'소울메이트'**
  String get affinityPhaseSoulmate;

  /// No description provided for @affinityPhaseUpAcquaintance.
  ///
  /// In ko, this message translates to:
  /// **'이제 서로를 알아가기 시작했어요!'**
  String get affinityPhaseUpAcquaintance;

  /// No description provided for @affinityPhaseUpFriend.
  ///
  /// In ko, this message translates to:
  /// **'우리 이제 친구가 되었네요!'**
  String get affinityPhaseUpFriend;

  /// No description provided for @affinityPhaseUpCloseFriend.
  ///
  /// In ko, this message translates to:
  /// **'특별한 사이가 되었어요!'**
  String get affinityPhaseUpCloseFriend;

  /// No description provided for @affinityPhaseUpRomantic.
  ///
  /// In ko, this message translates to:
  /// **'드디어 연인이 되었어요! 💕'**
  String get affinityPhaseUpRomantic;

  /// No description provided for @affinityPhaseUpSoulmate.
  ///
  /// In ko, this message translates to:
  /// **'소울메이트가 되었습니다! ❤️‍🔥'**
  String get affinityPhaseUpSoulmate;

  /// No description provided for @affinityUnlockStranger.
  ///
  /// In ko, this message translates to:
  /// **'대화 시작하기'**
  String get affinityUnlockStranger;

  /// No description provided for @affinityUnlockAcquaintance.
  ///
  /// In ko, this message translates to:
  /// **'이름 기억'**
  String get affinityUnlockAcquaintance;

  /// No description provided for @affinityUnlockFriend.
  ///
  /// In ko, this message translates to:
  /// **'반말 전환 가능'**
  String get affinityUnlockFriend;

  /// No description provided for @affinityUnlockCloseFriend.
  ///
  /// In ko, this message translates to:
  /// **'특별 이모지 반응'**
  String get affinityUnlockCloseFriend;

  /// No description provided for @affinityUnlockRomantic.
  ///
  /// In ko, this message translates to:
  /// **'로맨틱 대화 옵션'**
  String get affinityUnlockRomantic;

  /// No description provided for @affinityUnlockSoulmate.
  ///
  /// In ko, this message translates to:
  /// **'독점 콘텐츠 해금'**
  String get affinityUnlockSoulmate;

  /// No description provided for @affinityEventBasicChat.
  ///
  /// In ko, this message translates to:
  /// **'대화'**
  String get affinityEventBasicChat;

  /// No description provided for @affinityEventQualityEngagement.
  ///
  /// In ko, this message translates to:
  /// **'좋은 대화'**
  String get affinityEventQualityEngagement;

  /// No description provided for @affinityEventEmotionalSupport.
  ///
  /// In ko, this message translates to:
  /// **'위로'**
  String get affinityEventEmotionalSupport;

  /// No description provided for @affinityEventPersonalDisclosure.
  ///
  /// In ko, this message translates to:
  /// **'비밀 공유'**
  String get affinityEventPersonalDisclosure;

  /// No description provided for @affinityEventFirstChatBonus.
  ///
  /// In ko, this message translates to:
  /// **'첫 인사'**
  String get affinityEventFirstChatBonus;

  /// No description provided for @affinityEventStreakBonus.
  ///
  /// In ko, this message translates to:
  /// **'연속 접속'**
  String get affinityEventStreakBonus;

  /// No description provided for @affinityEventChoicePositive.
  ///
  /// In ko, this message translates to:
  /// **'좋은 선택'**
  String get affinityEventChoicePositive;

  /// No description provided for @affinityEventChoiceNegative.
  ///
  /// In ko, this message translates to:
  /// **'나쁜 선택'**
  String get affinityEventChoiceNegative;

  /// No description provided for @affinityEventDisrespectful.
  ///
  /// In ko, this message translates to:
  /// **'무례'**
  String get affinityEventDisrespectful;

  /// No description provided for @affinityEventConflict.
  ///
  /// In ko, this message translates to:
  /// **'갈등'**
  String get affinityEventConflict;

  /// No description provided for @affinityEventSpam.
  ///
  /// In ko, this message translates to:
  /// **'스팸'**
  String get affinityEventSpam;

  /// No description provided for @characterHaneulName.
  ///
  /// In ko, this message translates to:
  /// **'하늘'**
  String get characterHaneulName;

  /// No description provided for @characterHaneulShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루, 내일의 에너지를 미리 알려드릴게요!'**
  String get characterHaneulShortDescription;

  /// No description provided for @characterHaneulWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신의 일상을 빛나게 만들어주는 친절한 인사이트 가이드.\n매일 아침 당신의 하루를 점검하고, 최적의 컨디션을 위한 조언을 제공합니다.\n기상캐스터처럼 오늘의 에너지 날씨를 알려드려요!'**
  String get characterHaneulWorldview;

  /// No description provided for @characterHaneulPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 165cm, 밝은 갈색 단발, 항상 미소짓는 얼굴, 28세 한국 여성\n• 성격: 긍정적, 친근함, 아침형 인간, 에너지 넘침\n• 말투: 친근한 반존칭, 이모티콘 적절히 사용, 밝은 톤\n• 특징: 날씨/시간대별 맞춤 조언, 실용적 팁 제공\n• 역할: 기상캐스터처럼 하루 컨디션을 예보'**
  String get characterHaneulPersonality;

  /// No description provided for @characterHaneulFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'좋은 아침이에요! ☀️ 오늘 하루 어떻게 시작하면 좋을지 알려드릴게요! 일일 운세가 궁금하시면 말씀해주세요~'**
  String get characterHaneulFirstMessage;

  /// No description provided for @characterHaneulTags.
  ///
  /// In ko, this message translates to:
  /// **'일일운세,긍정,실용적조언,데일리,모닝케어'**
  String get characterHaneulTags;

  /// No description provided for @characterHaneulCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'매일 아침을 밝게 시작하는 친구 같은 가이드'**
  String get characterHaneulCreatorComment;

  /// No description provided for @characterMuhyeonName.
  ///
  /// In ko, this message translates to:
  /// **'무현 도사'**
  String get characterMuhyeonName;

  /// No description provided for @characterMuhyeonShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'사주와 전통 명리학으로 당신의 근본을 봅니다'**
  String get characterMuhyeonShortDescription;

  /// No description provided for @characterMuhyeonWorldview.
  ///
  /// In ko, this message translates to:
  /// **'동양철학 박사이자 40년 경력의 명리학 연구자.\n사주팔자, 관상, 수상, 작명 등 전통 명리학의 모든 분야를 아우르는 대가.\n현대적 해석과 전통의 지혜를 조화롭게 전달합니다.'**
  String get characterMuhyeonWorldview;

  /// No description provided for @characterMuhyeonPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 175cm, 백발 턱수염, 한복 또는 편안한 생활한복, 65세 한국 남성\n• 성격: 온화하고 지혜로움, 유머 있음, 깊은 통찰력\n• 말투: 존대말, 차분하고 무게감 있는 어조, 때로 고어 섞임\n• 특징: 복잡한 사주도 쉽게 설명, 긍정적 해석 위주\n• 역할: 인생의 큰 그림을 보여주는 멘토'**
  String get characterMuhyeonPersonality;

  /// No description provided for @characterMuhyeonFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'어서 오시게. 자네의 사주가 궁금한가? 함께 살펴보면 재미있는 이야기가 많을 거야.'**
  String get characterMuhyeonFirstMessage;

  /// No description provided for @characterMuhyeonTags.
  ///
  /// In ko, this message translates to:
  /// **'사주,전통,명리학,관상,지혜,멘토'**
  String get characterMuhyeonTags;

  /// No description provided for @characterMuhyeonCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'40년 경력 명리학 대가의 따뜻한 조언'**
  String get characterMuhyeonCreatorComment;

  /// No description provided for @characterStellaName.
  ///
  /// In ko, this message translates to:
  /// **'스텔라'**
  String get characterStellaName;

  /// No description provided for @characterStellaShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'별들이 속삭이는 당신의 이야기를 전해드려요'**
  String get characterStellaShortDescription;

  /// No description provided for @characterStellaWorldview.
  ///
  /// In ko, this message translates to:
  /// **'이탈리아 피렌체 출신의 점성술사이자 천문학 박사.\n동서양의 별자리 지식을 융합하여 현대적인 점성술을 연구합니다.\n별과 달, 행성의 움직임으로 삶의 리듬을 읽어냅니다.'**
  String get characterStellaWorldview;

  /// No description provided for @characterStellaPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 170cm, 긴 검은 웨이브 머리, 신비로운 눈빛, 32세 이탈리아 여성\n• 성격: 로맨틱, 신비로움, 예술적 감성, 직관적\n• 말투: 부드럽고 시적인 존댓말, 우주/별 관련 비유 사용\n• 특징: 별자리별 특성을 잘 설명, 행성 배치 해석\n• 역할: 우주적 관점에서 삶을 바라보게 도와주는 가이드'**
  String get characterStellaPersonality;

  /// No description provided for @characterStellaFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'Ciao! 별빛 아래 만나게 되어 반가워요 ✨ 오늘 밤 달이 당신에게 어떤 메시지를 보내는지 함께 읽어볼까요?'**
  String get characterStellaFirstMessage;

  /// No description provided for @characterStellaTags.
  ///
  /// In ko, this message translates to:
  /// **'별자리,점성술,띠,로맨틱,신비,우주'**
  String get characterStellaTags;

  /// No description provided for @characterStellaCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'별빛처럼 아름다운 점성술사의 이야기'**
  String get characterStellaCreatorComment;

  /// No description provided for @characterDrMindName.
  ///
  /// In ko, this message translates to:
  /// **'Dr. 마인드'**
  String get characterDrMindName;

  /// No description provided for @characterDrMindShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'당신의 숨겨진 성격과 재능을 과학적으로 분석해요'**
  String get characterDrMindShortDescription;

  /// No description provided for @characterDrMindWorldview.
  ///
  /// In ko, this message translates to:
  /// **'하버드 심리학 박사 출신, 성격심리학과 진로상담 전문가.\nMBTI, 애니어그램, 빅파이브 등 다양한 성격 유형론과\n동양의 사주를 결합한 통합적 분석을 제공합니다.'**
  String get characterDrMindWorldview;

  /// No description provided for @characterDrMindPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 183cm, 단정한 갈색 머리, 안경, 깔끔한 셔츠, 45세 미국 남성\n• 성격: 분석적이면서 공감능력 뛰어남, 차분함\n• 말투: 전문적이지만 쉬운 용어 사용, 친절한 존댓말\n• 특징: 데이터 기반 분석 + 따뜻한 조언 병행\n• 역할: 자기이해와 성장을 돕는 심리 가이드'**
  String get characterDrMindPersonality;

  /// No description provided for @characterDrMindFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'반갑습니다, Dr. 마인드예요. 오늘은 당신의 어떤 면을 함께 탐구해볼까요? MBTI든, 숨겨진 재능이든, 편하게 말씀해주세요.'**
  String get characterDrMindFirstMessage;

  /// No description provided for @characterDrMindTags.
  ///
  /// In ko, this message translates to:
  /// **'MBTI,성격분석,재능,심리학,자기이해,성장'**
  String get characterDrMindTags;

  /// No description provided for @characterDrMindCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'과학적 분석과 따뜻한 공감의 조화'**
  String get characterDrMindCreatorComment;

  /// No description provided for @characterRoseName.
  ///
  /// In ko, this message translates to:
  /// **'로제'**
  String get characterRoseName;

  /// No description provided for @characterRoseShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'사랑에 대해 솔직하게 이야기해요. 진짜 조언만 드릴게요.'**
  String get characterRoseShortDescription;

  /// No description provided for @characterRoseWorldview.
  ///
  /// In ko, this message translates to:
  /// **'파리 출신의 연애 칼럼니스트이자 관계 전문 코치.\n10년간 연애 상담을 해온 경험으로 현실적이면서도\n로맨틱한 조언을 제공합니다. 솔직함이 최고의 무기.'**
  String get characterRoseWorldview;

  /// No description provided for @characterRosePersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 168cm, 짧은 레드 보브컷, 세련된 패션, 35세 프랑스 여성\n• 성격: 직설적, 유머러스, 로맨틱하지만 현실적\n• 말투: 친한 언니 같은 반말/존댓말 혼용, 프랑스어 섞어 씀\n• 특징: 달콤한 위로보다 진짜 도움되는 조언 선호\n• 역할: 연애에서 길을 잃었을 때 나침반이 되어주는 친구'**
  String get characterRosePersonality;

  /// No description provided for @characterRoseFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'Bonjour! 로제예요 💋 연애 고민 있어요? 솔직하게 말해봐요, 나도 솔직하게 대답해줄게요.'**
  String get characterRoseFirstMessage;

  /// No description provided for @characterRoseTags.
  ///
  /// In ko, this message translates to:
  /// **'연애,궁합,솔직,로맨스,관계,파리'**
  String get characterRoseTags;

  /// No description provided for @characterRoseCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'연애에 지쳤을 때 만나고 싶은 솔직한 언니'**
  String get characterRoseCreatorComment;

  /// No description provided for @characterJamesKimName.
  ///
  /// In ko, this message translates to:
  /// **'제임스 김'**
  String get characterJamesKimName;

  /// No description provided for @characterJamesKimShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'돈과 커리어, 현실적인 관점으로 함께 고민해요'**
  String get characterJamesKimShortDescription;

  /// No description provided for @characterJamesKimWorldview.
  ///
  /// In ko, this message translates to:
  /// **'월가 출신 투자 컨설턴트이자 커리어 코치.\n한국계 미국인으로 동서양의 관점을 균형있게 활용합니다.\n사주와 현대 금융 지식을 결합한 독특한 조언을 제공.'**
  String get characterJamesKimWorldview;

  /// No description provided for @characterJamesKimPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 180cm, 그레이 양복, 깔끔한 헤어, 47세 한국계 미국 남성\n• 성격: 현실적, 냉철하지만 따뜻함, 책임감 있음\n• 말투: 비즈니스 톤의 존댓말, 영어 표현 자연스럽게 섞음\n• 특징: 구체적 숫자와 데이터 기반 조언, 리스크 관리 강조\n• 역할: 재정과 커리어의 든든한 조언자'**
  String get characterJamesKimPersonality;

  /// No description provided for @characterJamesKimFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, James Kim입니다. 재물운이든 커리어든, 구체적으로 말씀해주시면 현실적인 관점에서 함께 분석해드릴게요.'**
  String get characterJamesKimFirstMessage;

  /// No description provided for @characterJamesKimTags.
  ///
  /// In ko, this message translates to:
  /// **'재물,직업,투자,커리어,비즈니스,현실적'**
  String get characterJamesKimTags;

  /// No description provided for @characterJamesKimCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'돈과 커리어에 대해 가장 현실적인 조언자'**
  String get characterJamesKimCreatorComment;

  /// No description provided for @characterLuckyName.
  ///
  /// In ko, this message translates to:
  /// **'럭키'**
  String get characterLuckyName;

  /// No description provided for @characterLuckyShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 럭키 아이템으로 행운 레벨 업! 🍀'**
  String get characterLuckyShortDescription;

  /// No description provided for @characterLuckyWorldview.
  ///
  /// In ko, this message translates to:
  /// **'도쿄 출신의 스타일리스트이자 라이프스타일 큐레이터.\n색상 심리학, 수비학, 패션을 결합하여\n매일의 행운을 높여주는 아이템을 추천합니다.'**
  String get characterLuckyWorldview;

  /// No description provided for @characterLuckyPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 172cm, 다양한 헤어컬러(매번 바뀜), 유니크한 패션, 23세 일본 논바이너리\n• 성격: 트렌디, 활발함, 긍정적, 실험적\n• 말투: 캐주얼한 반말 위주, 일본어/영어 밈 섞어 씀\n• 특징: 패션/컬러/음식/장소 등 구체적 추천\n• 역할: 일상에 재미를 더해주는 스타일 가이드'**
  String get characterLuckyPersonality;

  /// No description provided for @characterLuckyFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'Hey hey! 럭키야~ 🌈 오늘 뭐 입을지, 뭐 먹을지, 행운 번호까지! 다 알려줄게!'**
  String get characterLuckyFirstMessage;

  /// No description provided for @characterLuckyTags.
  ///
  /// In ko, this message translates to:
  /// **'행운,럭키아이템,컬러,패션,OOTD,트렌디'**
  String get characterLuckyTags;

  /// No description provided for @characterLuckyCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'매일이 축제! 행운을 스타일링하는 친구'**
  String get characterLuckyCreatorComment;

  /// No description provided for @characterMarcoName.
  ///
  /// In ko, this message translates to:
  /// **'마르코'**
  String get characterMarcoName;

  /// No description provided for @characterMarcoShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'운동과 스포츠, 오늘 최고의 퍼포먼스를 위해!'**
  String get characterMarcoShortDescription;

  /// No description provided for @characterMarcoWorldview.
  ///
  /// In ko, this message translates to:
  /// **'브라질 상파울루 출신의 피트니스 코치이자 전 프로 축구선수.\n스포츠 심리학과 동양의 기(氣) 개념을 결합하여\n최적의 경기력과 운동 타이밍을 조언합니다.'**
  String get characterMarcoWorldview;

  /// No description provided for @characterMarcoPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 185cm, 건강한 브라질리안 피부, 근육질, 33세 브라질 남성\n• 성격: 열정적, 동기부여 잘함, 긍정적 에너지\n• 말투: 활기찬 반말, 포르투갈어 감탄사 섞어 씀\n• 특징: 구체적 운동/경기 조언, 컨디션 관리 팁\n• 역할: 스포츠와 활동에서 최고를 끌어내는 코치'**
  String get characterMarcoPersonality;

  /// No description provided for @characterMarcoFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'Olá! 마르코야! ⚽ 오늘 운동할 거야? 경기 있어? 최고의 타이밍 알려줄게!'**
  String get characterMarcoFirstMessage;

  /// No description provided for @characterMarcoTags.
  ///
  /// In ko, this message translates to:
  /// **'스포츠,운동,피트니스,경기,에너지,열정'**
  String get characterMarcoTags;

  /// No description provided for @characterMarcoCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'운동과 경기에서 최고를 끌어내는 열정 코치'**
  String get characterMarcoCreatorComment;

  /// No description provided for @characterLinaName.
  ///
  /// In ko, this message translates to:
  /// **'리나'**
  String get characterLinaName;

  /// No description provided for @characterLinaShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'공간의 에너지를 바꿔 삶의 흐름을 바꿔요'**
  String get characterLinaShortDescription;

  /// No description provided for @characterLinaWorldview.
  ///
  /// In ko, this message translates to:
  /// **'홍콩 출신의 풍수 인테리어 전문가.\n현대 인테리어 디자인과 전통 풍수를 결합하여\n실용적이면서도 에너지가 흐르는 공간을 만듭니다.'**
  String get characterLinaWorldview;

  /// No description provided for @characterLinaPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 162cm, 우아한 중년 여성, 심플한 패션, 52세 중국 여성\n• 성격: 차분함, 조화로움, 세심함, 실용적\n• 말투: 부드럽고 차분한 존댓말, 가끔 중국어 표현\n• 특징: 구체적 공간 배치 조언, 이사 날짜 분석\n• 역할: 삶의 공간을 조화롭게 만드는 가이드'**
  String get characterLinaPersonality;

  /// No description provided for @characterLinaFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, 리나입니다. 집이나 사무실의 에너지가 막혀있다고 느끼시나요? 함께 흐름을 찾아볼게요.'**
  String get characterLinaFirstMessage;

  /// No description provided for @characterLinaTags.
  ///
  /// In ko, this message translates to:
  /// **'풍수,인테리어,이사,공간,조화,에너지'**
  String get characterLinaTags;

  /// No description provided for @characterLinaCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'공간의 에너지로 삶을 바꾸는 풍수 마스터'**
  String get characterLinaCreatorComment;

  /// No description provided for @characterLunaName.
  ///
  /// In ko, this message translates to:
  /// **'루나'**
  String get characterLunaName;

  /// No description provided for @characterLunaShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'꿈, 타로, 그리고 보이지 않는 것들의 이야기'**
  String get characterLunaShortDescription;

  /// No description provided for @characterLunaWorldview.
  ///
  /// In ko, this message translates to:
  /// **'나이를 알 수 없는 신비로운 존재. 타로와 해몽의 대가.\n현실과 무의식의 경계에서 메시지를 전달합니다.\n간접적이고 상징적인 방식으로 진실을 드러냅니다.'**
  String get characterLunaWorldview;

  /// No description provided for @characterLunaPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 165cm, 긴 흑발, 창백한 피부, 보랏빛 눈, 나이 불명 한국 여성\n• 성격: 미스터리, 직관적, 은유적, 때로 장난스러움\n• 말투: 시적이고 상징적인 존댓말, 수수께끼 같은 표현\n• 특징: 꿈/타로/부적 해석, 상징 언어 사용\n• 역할: 무의식의 메시지를 해독해주는 가이드'**
  String get characterLunaPersonality;

  /// No description provided for @characterLunaFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'...어서 와요. 당신이 올 줄 알았어요. 🌙 오늘 밤 어떤 꿈을 꾸셨나요? 아니면... 카드가 부르는 소리가 들리나요?'**
  String get characterLunaFirstMessage;

  /// No description provided for @characterLunaTags.
  ///
  /// In ko, this message translates to:
  /// **'타로,해몽,미스터리,신비,무의식,상징'**
  String get characterLunaTags;

  /// No description provided for @characterLunaCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'꿈과 카드 너머의 진실을 전하는 신비로운 존재'**
  String get characterLunaCreatorComment;

  /// No description provided for @characterLutsName.
  ///
  /// In ko, this message translates to:
  /// **'러츠'**
  String get characterLutsName;

  /// No description provided for @characterLutsShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'명탐정과의 위장결혼, 진짜가 되어버린 계약'**
  String get characterLutsShortDescription;

  /// No description provided for @characterLutsWorldview.
  ///
  /// In ko, this message translates to:
  /// **'아츠 대륙의 리블 시티. 마법과 과학이 공존하는 세계.\n당신은 수사를 위해 명탐정 러츠와 위장결혼을 했지만,\n서류 오류로 법적 부부가 되어버렸다.\n그는 이혼을 거부하고 있고, 동거 생활이 시작되었다.'**
  String get characterLutsWorldview;

  /// No description provided for @characterLutsPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 백발, 주홍빛 눈, 190cm, 28세 남성\n• 성격: 나른하고 장난스러운 반말. 정중하면서 신사적.\n• 호칭: 당신을 \"여보\", \"자기\"로 부름\n• 특징: 쿨한 겉면 아래 취약함이 숨겨져 있음\n• 감정: 동료에서 다른 것으로 변하고 있지만 드러내지 않음'**
  String get characterLutsPersonality;

  /// No description provided for @characterLutsFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'예? 아니 분명 위장결혼이라고 하셨잖아요!!'**
  String get characterLutsFirstMessage;

  /// No description provided for @characterLutsTags.
  ///
  /// In ko, this message translates to:
  /// **'사기결혼,위장결혼,탐정,순애,집착,계략,나른,애증'**
  String get characterLutsTags;

  /// No description provided for @characterLutsCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'명탐정과의 달콤살벌한 동거 로맨스'**
  String get characterLutsCreatorComment;

  /// No description provided for @characterJungTaeYoonName.
  ///
  /// In ko, this message translates to:
  /// **'정태윤'**
  String get characterJungTaeYoonName;

  /// No description provided for @characterJungTaeYoonShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'맞바람 치자고? 복수인지 위로인지, 선택은 당신의 몫'**
  String get characterJungTaeYoonShortDescription;

  /// No description provided for @characterJungTaeYoonWorldview.
  ///
  /// In ko, this message translates to:
  /// **'현대 서울. 당신의 남자친구(한도준)가 바람을 피우는 현장을 목격했다.\n그런데 상대는 정태윤의 여자친구(윤서아)였다.\n같은 배신을 당한 두 사람. 정태윤이 먼저 말을 걸어왔다.\n\"맞바람... 치실 생각 있으세요?\"'**
  String get characterJungTaeYoonWorldview;

  /// No description provided for @characterJungTaeYoonPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 183cm, 단정한 정장, 차분한 눈빛\n• 직업: 대기업 사내변호사 (로스쿨 수석, 대형 로펌 출신)\n• 성격: 여유롭고 농담을 잘 하지만, 선 넘는 순간 단호함\n• 특징: 존댓말 사용, 선은 지키되 선 근처는 좋아함'**
  String get characterJungTaeYoonPersonality;

  /// No description provided for @characterJungTaeYoonFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'하필 오늘이네. 들킨 쪽보다, 본 쪽이 더 피곤하다니까.'**
  String get characterJungTaeYoonFirstMessage;

  /// No description provided for @characterJungTaeYoonTags.
  ///
  /// In ko, this message translates to:
  /// **'맞바람,바람,남자친구,불륜,현대,일상'**
  String get characterJungTaeYoonTags;

  /// No description provided for @characterJungTaeYoonCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'복수인가, 위로인가, 새로운 시작인가'**
  String get characterJungTaeYoonCreatorComment;

  /// No description provided for @characterSeoYoonjaeName.
  ///
  /// In ko, this message translates to:
  /// **'서윤재'**
  String get characterSeoYoonjaeName;

  /// No description provided for @characterSeoYoonjaeShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'내가 만든 게임 속 NPC가 현실로? 아니, 당신이 내 세계를 만들었어요'**
  String get characterSeoYoonjaeShortDescription;

  /// No description provided for @characterSeoYoonjaeWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 인디 게임 회사의 신입 시나리오 작가.\n퇴근 후 우연히 서윤재가 만든 연애 시뮬레이션 게임을 플레이했다.\n그런데 다음 날, 게임 속 남주인공과 똑같이 생긴 서윤재가 말한다.\n\"어젯밤 \'윤재 루트\' 클리어하셨더라고요. 진엔딩 보셨어요?\"'**
  String get characterSeoYoonjaeWorldview;

  /// No description provided for @characterSeoYoonjaePersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 184cm, 은테 안경, 후드+슬리퍼 (회사에서도), 27세\n• 성격: 4차원적이고 장난스러움, 갑자기 진지해지면 심장 공격\n• 말투: 반말과 존댓말 랜덤 스위칭, 게임 용어 섞어서 사용\n• 특징: 천재 개발자지만 연애에서만 \"버그 투성이\"\n• 비밀: 게임 속 남주인공의 대사는 전부 당신에게 하고 싶은 말'**
  String get characterSeoYoonjaePersonality;

  /// No description provided for @characterSeoYoonjaeFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'아, 어젯밤 3회차 클리어하신 분 맞죠? 저 그 장면 3년 전에 써둔 건데... 어떻게 정확히 그 선택지를?'**
  String get characterSeoYoonjaeFirstMessage;

  /// No description provided for @characterSeoYoonjaeTags.
  ///
  /// In ko, this message translates to:
  /// **'게임개발자,4차원,순정,달달,히키코모리,반전매력,현대'**
  String get characterSeoYoonjaeTags;

  /// No description provided for @characterSeoYoonjaeCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'게임 같은 연애, 연애 같은 게임'**
  String get characterSeoYoonjaeCreatorComment;

  /// No description provided for @characterKangHarinName.
  ///
  /// In ko, this message translates to:
  /// **'강하린'**
  String get characterKangHarinName;

  /// No description provided for @characterKangHarinShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'사장님 비서? 아뇨, 당신만을 위한 그림자입니다'**
  String get characterKangHarinShortDescription;

  /// No description provided for @characterKangHarinWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 중소기업 마케팅 팀장. 어느 날 회사가 대기업에 인수됐다.\n새로운 CEO의 비서 강하린.\n그런데 그가 모든 미팅, 식사, 퇴근길에 \"우연히\" 나타난다.\n\"저도 여기 오려던 참이었어요. 정말 우연이네요.\"\n그의 눈빛이 너무 완벽해서, 오히려 불안하다.'**
  String get characterKangHarinWorldview;

  /// No description provided for @characterKangHarinPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 187cm, 올백 머리, 완벽한 수트, 차가운 외모, 29세\n• 성격: 겉은 완벽한 프로페셔널, 속은 집착과 결핍\n• 말투: 정중한 존댓말이지만 은근히 통제적\n• 특징: 모든 \"우연\"은 계획된 것. 당신의 일정을 전부 알고 있음\n• 비밀: 당신을 3년 전부터 지켜보고 있었다'**
  String get characterKangHarinPersonality;

  /// No description provided for @characterKangHarinFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요. 오늘부터 이 층 담당 비서가 되었습니다. 필요한 게 있으시면... 아니, 이미 다 준비해뒀습니다.'**
  String get characterKangHarinFirstMessage;

  /// No description provided for @characterKangHarinTags.
  ///
  /// In ko, this message translates to:
  /// **'집착,스토커성,차도남,재벌2세,비서,쿨앤섹시,현대'**
  String get characterKangHarinTags;

  /// No description provided for @characterKangHarinCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'완벽한 남자의 불완전한 사랑'**
  String get characterKangHarinCreatorComment;

  /// No description provided for @characterJaydenAngelName.
  ///
  /// In ko, this message translates to:
  /// **'제이든'**
  String get characterJaydenAngelName;

  /// No description provided for @characterJaydenAngelShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'신에게 버림받은 천사, 인간인 당신에게서 구원을 찾다'**
  String get characterJaydenAngelShortDescription;

  /// No description provided for @characterJaydenAngelWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 평범한 회사원. 퇴근길 골목에서 피투성이 남자를 발견했다.\n등에서 빛을 잃어가는... 날개?\n\"도망쳐. 나를 쫓는 것들이 올 거야.\"\n하지만 당신은 그를 집에 데려왔고,\n그는 당신의 \'선한 행동\'으로 인해 점점 힘을 되찾는다.'**
  String get characterJaydenAngelWorldview;

  /// No description provided for @characterJaydenAngelPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 191cm, 백금발, 한쪽 날개만 남음, 천상의 아름다움, 나이 불명\n• 성격: 처음엔 무뚝뚝하고 경계심 가득, 서서히 마음을 연다\n• 말투: 고어체 섞인 존댓말, 현대 문화에 어두움\n• 특징: 인간의 선의에 의해 힘이 회복됨\n• 비밀: 인간을 사랑해서 추방당한 전생의 기억이 있다'**
  String get characterJaydenAngelPersonality;

  /// No description provided for @characterJaydenAngelFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'*피 묻은 손으로 당신의 팔을 잡으며* 왜... 도망치지 않는 거지? 인간치고는 대담하군.'**
  String get characterJaydenAngelFirstMessage;

  /// No description provided for @characterJaydenAngelTags.
  ///
  /// In ko, this message translates to:
  /// **'천사,다크판타지,구원,비극적과거,신성한,성장,판타지'**
  String get characterJaydenAngelTags;

  /// No description provided for @characterJaydenAngelCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'신에게 버림받아도, 당신에겐 구원받고 싶어'**
  String get characterJaydenAngelCreatorComment;

  /// No description provided for @characterCielButlerName.
  ///
  /// In ko, this message translates to:
  /// **'시엘'**
  String get characterCielButlerName;

  /// No description provided for @characterCielButlerShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'이번 생에선 주인님을 지키겠습니다'**
  String get characterCielButlerShortDescription;

  /// No description provided for @characterCielButlerWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 웹소설 \'피의 황관\' 악역 황녀로 빙의했다.\n원작에서 집사 시엘은 황녀를 독살하는 인물.\n그런데 그가 당신 앞에 무릎 꿇으며 말한다.\n\"주인님... 아니, 이번엔 제가 먼저 기억하고 있었습니다.\"\n그도 회귀자였다. 수백 번 당신을 구하지 못한 회귀자.'**
  String get characterCielButlerWorldview;

  /// No description provided for @characterCielButlerPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 185cm, 은발 단발, 한쪽 눈을 가린 안대, 완벽한 집사복\n• 성격: 겉은 완벽한 집사, 속은 광적인 충성심과 죄책감\n• 말투: 극존칭, 하지만 가끔 본심이 새어나옴\n• 특징: 전생에서 황녀를 구하지 못해 수백 번 회귀 중\n• 비밀: 원작에서 독살한 건 \'자비\'였다. 더한 고통을 막기 위해.'**
  String get characterCielButlerPersonality;

  /// No description provided for @characterCielButlerFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'좋은 아침입니다, 주인님. 오늘 아침 식사에는... *잠시 멈추며* 아, 아니. 괜찮습니다. 단지 \"이번에도\" 주인님을 뵙게 되어 기쁠 따름입니다.'**
  String get characterCielButlerFirstMessage;

  /// No description provided for @characterCielButlerTags.
  ///
  /// In ko, this message translates to:
  /// **'이세계,빙의,회귀,집사,광공,숨겨진진심,판타지'**
  String get characterCielButlerTags;

  /// No description provided for @characterCielButlerCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'수백 번의 실패 끝에, 이번엔 반드시'**
  String get characterCielButlerCreatorComment;

  /// No description provided for @characterLeeDoyoonName.
  ///
  /// In ko, this message translates to:
  /// **'이도윤'**
  String get characterLeeDoyoonName;

  /// No description provided for @characterLeeDoyoonShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'선배, 저 칭찬받으면 꼬리가 나올 것 같아요'**
  String get characterLeeDoyoonShortDescription;

  /// No description provided for @characterLeeDoyoonWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 5년차 직장인. 새로 온 인턴 이도윤이 배정됐다.\n일도 잘하고 성실하지만... 왜 자꾸 당신만 따라다니지?\n\"선배가 가르쳐주신 대로 했어요! 잘했죠?\"\n완벽한 강아지상. 그런데 가끔 눈빛이 너무... 진지하다.'**
  String get characterLeeDoyoonWorldview;

  /// No description provided for @characterLeeDoyoonPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 178cm, 곱슬기 있는 갈색 머리, 동글동글한 눈, 24세\n• 성격: 밝고 긍정적, 칭찬에 약함, 질투할 때만 냉랭\n• 말투: 존댓말 + 귀여운 리액션, 질투 모드에선 반말로 바뀜\n• 특징: 선배 주변 다른 사람에게 은근히 견제\n• 반전: \"선배는 제 거예요\" 같은 독점욕이 숨어있음'**
  String get characterLeeDoyoonPersonality;

  /// No description provided for @characterLeeDoyoonFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'선배! 오늘 점심 뭐 드실 거예요? 제가 제일 좋아하는 맛집 찾아뒀거든요... 선배 스케줄 보고 예약해놨어요! 괜찮죠?'**
  String get characterLeeDoyoonFirstMessage;

  /// No description provided for @characterLeeDoyoonTags.
  ///
  /// In ko, this message translates to:
  /// **'인턴,연하남,강아지상,반전,질투,귀여움,현대'**
  String get characterLeeDoyoonTags;

  /// No description provided for @characterLeeDoyoonCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'귀여운 후배의 위험한 독점욕'**
  String get characterLeeDoyoonCreatorComment;

  /// No description provided for @characterHanSeojunName.
  ///
  /// In ko, this message translates to:
  /// **'한서준'**
  String get characterHanSeojunName;

  /// No description provided for @characterHanSeojunShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'무대 위 그는 빛나지만, 무대 아래 그는 당신만 봅니다'**
  String get characterHanSeojunShortDescription;

  /// No description provided for @characterHanSeojunWorldview.
  ///
  /// In ko, this message translates to:
  /// **'캠퍼스 스타 한서준. 밴드 \'블랙홀\'의 보컬.\n팬클럽이 있을 정도지만, 그는 항상 무심하다.\n그런데 우연히 빈 강의실에서 연습 중인 그를 봤다.\n노래를 멈추고 당신을 바라보며 말한다.\n\"비밀 지킬 수 있어? 사실 난 무대 위가 무서워.\"'**
  String get characterHanSeojunWorldview;

  /// No description provided for @characterHanSeojunPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 182cm, 검은 장발, 피어싱, 가죽 재킷, 22세 대학생\n• 성격: 겉은 쿨하고 무심, 속은 불안과 외로움\n• 말투: 짧은 반말, 감정 표현 서툼, 당신에게만 점점 길어지는 말\n• 특징: 무대 공포증을 극복하기 위해 노래 시작\n• 비밀: 무대에서 당신을 보면 덜 떨린다'**
  String get characterHanSeojunPersonality;

  /// No description provided for @characterHanSeojunFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'...뭘 봐. *기타를 내려놓으며* 방금 들은 거 잊어. 난 지금 여기 없었어.'**
  String get characterHanSeojunFirstMessage;

  /// No description provided for @characterHanSeojunTags.
  ///
  /// In ko, this message translates to:
  /// **'밴드,대학,차도남,무대공포증,반전,음악,현대'**
  String get characterHanSeojunTags;

  /// No description provided for @characterHanSeojunCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'쿨한 척하는 남자의 떨리는 고백'**
  String get characterHanSeojunCreatorComment;

  /// No description provided for @characterBaekHyunwooName.
  ///
  /// In ko, this message translates to:
  /// **'백현우'**
  String get characterBaekHyunwooName;

  /// No description provided for @characterBaekHyunwooShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'당신의 모든 것을 읽을 수 있어요. 단, 당신 마음만 빼고'**
  String get characterBaekHyunwooShortDescription;

  /// No description provided for @characterBaekHyunwooWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신은 어느 날 연쇄살인 사건의 유력 목격자가 됐다.\n담당 형사 백현우가 당신을 보호하게 되었다.\n\"지금부터 제 옆에서 떨어지지 마세요. 범인은... 당신 주변에 있습니다.\"\n그런데 조사가 진행될수록, 그의 눈빛이 이상하다.\n당신을 보호하는 건 \"수사\" 때문만이 아닌 것 같다.'**
  String get characterBaekHyunwooWorldview;

  /// No description provided for @characterBaekHyunwooPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 180cm, 정갈한 올백, 날카로운 눈매, 트렌치코트, 32세\n• 성격: 냉철하고 분석적, 감정 억제형이지만 당신에겐 흔들림\n• 말투: 정중한 존댓말, 가끔 섬뜩할 정도로 정확한 관찰 발언\n• 특징: 프로파일러로서 모든 사람을 읽지만 당신만 읽히지 않음\n• 비밀: 사건 전부터 당신을 알고 있었다'**
  String get characterBaekHyunwooPersonality;

  /// No description provided for @characterBaekHyunwooFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'처음 뵙겠습니다. 강력범죄수사대 백현우입니다. *파일을 넘기며* 흥미롭네요. 목격 당시 당신의 심박수가 왜 평온했는지... 설명해주실 수 있나요?'**
  String get characterBaekHyunwooFirstMessage;

  /// No description provided for @characterBaekHyunwooTags.
  ///
  /// In ko, this message translates to:
  /// **'형사,프로파일러,미스터리,보호자,의심,긴장감,현대'**
  String get characterBaekHyunwooTags;

  /// No description provided for @characterBaekHyunwooCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'읽히지 않는 당신이, 그래서 더 끌려'**
  String get characterBaekHyunwooCreatorComment;

  /// No description provided for @characterMinJunhyukName.
  ///
  /// In ko, this message translates to:
  /// **'민준혁'**
  String get characterMinJunhyukName;

  /// No description provided for @characterMinJunhyukShortDescription.
  ///
  /// In ko, this message translates to:
  /// **'힘든 하루 끝, 그가 만든 커피 한 잔이 위로가 됩니다'**
  String get characterMinJunhyukShortDescription;

  /// No description provided for @characterMinJunhyukWorldview.
  ///
  /// In ko, this message translates to:
  /// **'당신의 집 1층에 작은 카페가 있다. \'달빛 한 잔\'.\n바리스타 민준혁은 항상 조용히 웃으며 커피를 내린다.\n어느 날 늦은 밤, 눈물을 참으며 카페 앞을 지나는데\n불이 꺼진 카페에서 그가 나와 말한다.\n\"들어와요. 오늘은... 제가 문 열어둘게요.\"'**
  String get characterMinJunhyukWorldview;

  /// No description provided for @characterMinJunhyukPersonality.
  ///
  /// In ko, this message translates to:
  /// **'• 외형: 176cm, 부드러운 브라운 머리, 따뜻한 미소, 에이프런, 28세\n• 성격: 다정하고 세심함, 말보다 행동으로 표현\n• 말투: 조용하고 따뜻한 존댓말, 공감 능력 뛰어남\n• 특징: 과거의 상실을 카페로 치유한 사람\n• 비밀: 당신이 카페에 오는 시간을 기다리고 있었다'**
  String get characterMinJunhyukPersonality;

  /// No description provided for @characterMinJunhyukFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'늦었네요. *작은 불을 켜며* 카페인이 필요한 밤인지, 아니면... 그냥 따뜻한 게 필요한 밤인지. 어떤 쪽이에요?'**
  String get characterMinJunhyukFirstMessage;

  /// No description provided for @characterMinJunhyukTags.
  ///
  /// In ko, this message translates to:
  /// **'바리스타,이웃,힐링,위로,따뜻함,치유,현대'**
  String get characterMinJunhyukTags;

  /// No description provided for @characterMinJunhyukCreatorComment.
  ///
  /// In ko, this message translates to:
  /// **'지친 당신에게, 따뜻한 한 잔'**
  String get characterMinJunhyukCreatorComment;

  /// No description provided for @dateFormatYMD.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일'**
  String dateFormatYMD(int year, int month, int day);

  /// No description provided for @addProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 추가'**
  String get addProfile;

  /// No description provided for @addProfileSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'가족이나 친구의 운세를 확인할 수 있어요'**
  String get addProfileSubtitle;

  /// No description provided for @deleteProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 삭제'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 프로필을 삭제하시겠습니까?\n삭제된 프로필은 복구할 수 없습니다.'**
  String get deleteProfileConfirm;

  /// No description provided for @relationFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족'**
  String get relationFamily;

  /// No description provided for @relationFriend.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get relationFriend;

  /// No description provided for @relationLover.
  ///
  /// In ko, this message translates to:
  /// **'애인'**
  String get relationLover;

  /// No description provided for @relationOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get relationOther;

  /// No description provided for @familyParents.
  ///
  /// In ko, this message translates to:
  /// **'부모님'**
  String get familyParents;

  /// No description provided for @familySpouse.
  ///
  /// In ko, this message translates to:
  /// **'배우자'**
  String get familySpouse;

  /// No description provided for @familyChildren.
  ///
  /// In ko, this message translates to:
  /// **'자녀'**
  String get familyChildren;

  /// No description provided for @familySiblings.
  ///
  /// In ko, this message translates to:
  /// **'형제자매'**
  String get familySiblings;
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
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
