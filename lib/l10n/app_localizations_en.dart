// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZPZG';

  @override
  String get confirm => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get share => 'Share';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get tokens => 'Tokens';

  @override
  String get heldTokens => 'Available Tokens';

  @override
  String tokenCount(int count) {
    return '$count';
  }

  @override
  String tokenCountWithMax(int current, int max) {
    return '$current / $max';
  }

  @override
  String get points => 'Points';

  @override
  String pointsWithCount(int count) {
    return '$count Points';
  }

  @override
  String get bonus => 'Bonus';

  @override
  String get points330Title => '330 Points';

  @override
  String get points330Desc => '300P + 30P Bonus';

  @override
  String get points700Title => '700 Points';

  @override
  String get points700Desc => '600P + 100P Bonus';

  @override
  String get points1500Title => '1,500 Points';

  @override
  String get points1500Desc => '1,200P + 300P Bonus';

  @override
  String get points4000Title => '4,000 Points';

  @override
  String get points4000Desc => '3,000P + 1,000P Bonus';

  @override
  String get proSubscriptionTitle => 'Pro Subscription';

  @override
  String get proSubscriptionDesc => '30,000 tokens auto-recharged monthly';

  @override
  String get maxSubscriptionTitle => 'Max Subscription';

  @override
  String get maxSubscriptionDesc => '100,000 tokens auto-recharged monthly';

  @override
  String get premiumSajuTitle => 'Premium Birth Chart Analysis';

  @override
  String get premiumSajuDesc => '215-page detailed analysis (Lifetime access)';

  @override
  String dailyPointRecharge(int points) {
    return '${points}P daily recharge';
  }

  @override
  String pointBonus(int base, int bonus) {
    return '${base}P + ${bonus}P Bonus';
  }

  @override
  String pointRecharge(int points) {
    return '${points}P recharge';
  }

  @override
  String get categoryDailyInsights => 'Daily Insights';

  @override
  String get categoryTraditional => 'Traditional Analysis';

  @override
  String get categoryPersonality => 'Personality';

  @override
  String get categoryLoveRelation => 'Love & Relationships';

  @override
  String get categoryCareerBusiness => 'Career & Business';

  @override
  String get categoryWealthInvestment => 'Wealth & Investment';

  @override
  String get categoryHealthLife => 'Health & Lifestyle';

  @override
  String get categorySportsActivity => 'Sports & Activities';

  @override
  String get categoryLuckyItems => 'Lucky Items';

  @override
  String get categoryFamilyPet => 'Family & Pets';

  @override
  String get categorySpecial => 'Special Features';

  @override
  String get fortuneDaily => 'Today\'s Message';

  @override
  String get fortuneToday => 'Today\'s Insight';

  @override
  String get fortuneTomorrow => 'Tomorrow\'s Insight';

  @override
  String get fortuneDailyCalendar => 'Daily Calendar';

  @override
  String get fortuneWeekly => 'Weekly Insight';

  @override
  String get fortuneMonthly => 'Monthly Insight';

  @override
  String get fortuneTraditional => 'Traditional Analysis';

  @override
  String get fortuneSaju => 'Birth Chart Analysis';

  @override
  String get fortuneTraditionalSaju => 'Traditional Birth Chart';

  @override
  String get fortuneTarot => 'Insight Cards';

  @override
  String get fortuneSajuPsychology => 'Personality Psychology';

  @override
  String get fortuneTojeong => 'Traditional Interpretation';

  @override
  String get fortuneSalpuli => 'Energy Cleansing';

  @override
  String get fortunePalmistry => 'Palm Reading';

  @override
  String get fortunePhysiognomy => 'Face AI';

  @override
  String get fortuneFaceReading => 'Face AI';

  @override
  String get fortuneFiveBlessings => 'Five Blessings';

  @override
  String get fortuneMbti => 'MBTI Analysis';

  @override
  String get fortunePersonality => 'Personality Analysis';

  @override
  String get fortunePersonalityDna => 'Personality Explorer';

  @override
  String get fortuneBloodType => 'Blood Type Analysis';

  @override
  String get fortuneZodiac => 'Zodiac Analysis';

  @override
  String get fortuneZodiacAnimal => 'Chinese Zodiac';

  @override
  String get fortuneBirthSeason => 'Birth Season';

  @override
  String get fortuneBirthdate => 'Birthday Analysis';

  @override
  String get fortuneBirthstone => 'Birthstone Guide';

  @override
  String get fortuneBiorhythm => 'Biorhythm';

  @override
  String get fortuneLove => 'Love Analysis';

  @override
  String get fortuneMarriage => 'Marriage Analysis';

  @override
  String get fortuneCompatibility => 'Compatibility Match';

  @override
  String get fortuneTraditionalCompatibility => 'Traditional Compatibility';

  @override
  String get fortuneChemistry => 'Chemistry Analysis';

  @override
  String get fortuneCoupleMatch => 'Soulmate Finder';

  @override
  String get fortuneExLover => 'Reunion Analysis';

  @override
  String get fortuneBlindDate => 'Blind Date Guide';

  @override
  String get fortuneCelebrityMatch => 'Celebrity Match';

  @override
  String get fortuneAvoidPeople => 'Relationship Warnings';

  @override
  String get fortuneCareer => 'Career Analysis';

  @override
  String get fortuneEmployment => 'Job Hunting Guide';

  @override
  String get fortuneBusiness => 'Business Analysis';

  @override
  String get fortuneStartup => 'Startup Insights';

  @override
  String get fortuneLuckyJob => 'Career Recommendations';

  @override
  String get fortuneLuckySidejob => 'Side Hustle Guide';

  @override
  String get fortuneLuckyExam => 'Exam Guide';

  @override
  String get fortuneWealth => 'Wealth Analysis';

  @override
  String get fortuneInvestment => 'Investment Insights';

  @override
  String get fortuneLuckyInvestment => 'Investment Guide';

  @override
  String get fortuneLuckyRealestate => 'Real Estate Insights';

  @override
  String get fortuneLuckyStock => 'Stock Guide';

  @override
  String get fortuneLuckyCrypto => 'Crypto Guide';

  @override
  String get fortuneLuckyLottery => 'Lucky Numbers';

  @override
  String get fortuneHealth => 'Health Check';

  @override
  String get fortuneMoving => 'Moving Guide';

  @override
  String get fortuneMovingDate => 'Moving Date Finder';

  @override
  String get fortuneMovingUnified => 'Moving Planner';

  @override
  String get fortuneLuckyColor => 'Lucky Color';

  @override
  String get fortuneLuckyNumber => 'Lucky Number';

  @override
  String get fortuneLuckyItems => 'Lucky Items';

  @override
  String get fortuneLuckyFood => 'Lucky Food';

  @override
  String get fortuneLuckyPlace => 'Lucky Place';

  @override
  String get fortuneLuckyOutfit => 'Style Guide';

  @override
  String get fortuneLuckySeries => 'Lucky Series';

  @override
  String get fortuneDestiny => 'Life Analysis';

  @override
  String get fortunePastLife => 'Past Life Story';

  @override
  String get fortuneTalent => 'Talent Discovery';

  @override
  String get fortuneWish => 'Wish Analysis';

  @override
  String get fortuneTimeline => 'Life Timeline';

  @override
  String get fortuneTalisman => 'Lucky Card';

  @override
  String get fortuneNewYear => 'New Year Insights';

  @override
  String get fortuneCelebrity => 'Celebrity Analysis';

  @override
  String get fortuneSameBirthdayCelebrity => 'Same Birthday Celebrity';

  @override
  String get fortuneNetworkReport => 'Network Report';

  @override
  String get fortuneDream => 'Dream Analysis';

  @override
  String get fortunePet => 'Pet Analysis';

  @override
  String get fortunePetDog => 'Dog Guide';

  @override
  String get fortunePetCat => 'Cat Guide';

  @override
  String get fortunePetCompatibility => 'Pet Compatibility';

  @override
  String get fortuneChildren => 'Children Analysis';

  @override
  String get fortuneParenting => 'Parenting Guide';

  @override
  String get fortunePregnancy => 'Pregnancy Guide';

  @override
  String get fortuneFamilyHarmony => 'Family Harmony Guide';

  @override
  String get fortuneNaming => 'Name Analysis';

  @override
  String get loadingTimeDaily1 => 'The sun is illuminating your day';

  @override
  String get loadingTimeDaily2 =>
      'Morning stars are delivering today\'s message...';

  @override
  String get loadingTimeDaily3 => 'Reading destiny in the morning dew';

  @override
  String get loadingTimeDaily4 => 'Gathering celestial energy for you';

  @override
  String get loadingTimeDaily5 => 'Drawing today\'s constellation';

  @override
  String get loadingLoveRelation1 => 'Cupid is drawing his bow...';

  @override
  String get loadingLoveRelation2 => 'Following the red thread of fate';

  @override
  String get loadingLoveRelation3 => 'Calculating love\'s constellation';

  @override
  String get loadingLoveRelation4 =>
      'Measuring the distance between two hearts...';

  @override
  String get loadingLoveRelation5 => 'Checking the romance forecast';

  @override
  String get loadingCareerTalent1 => 'Discovering your talents...';

  @override
  String get loadingCareerTalent2 => 'Career compass finding direction';

  @override
  String get loadingCareerTalent3 => 'Scanning your hidden abilities';

  @override
  String get loadingCareerTalent4 => 'Searching for the key to success';

  @override
  String get loadingCareerTalent5 => 'Knocking on the door of possibilities...';

  @override
  String get loadingWealth1 => 'Summoning golden energy...';

  @override
  String get loadingWealth2 => 'Picking fruits from the wealth tree';

  @override
  String get loadingWealth3 => 'Lucky coins rolling your way';

  @override
  String get loadingWealth4 => 'Reading the wealth constellation';

  @override
  String get loadingWealth5 => 'Tracking the flow of fortune';

  @override
  String get loadingMystic1 => 'Gazing into the crystal ball';

  @override
  String get loadingMystic2 => 'Aligning the five elements...';

  @override
  String get loadingMystic3 => 'Opening ancient divination texts';

  @override
  String get loadingMystic4 => 'Tarot cards delivering their message';

  @override
  String get loadingMystic5 => 'Lifting the veil of mystery';

  @override
  String get loadingDefault1 => 'Just a moment, getting ready to listen';

  @override
  String get loadingDefault2 => 'Curious about your day...';

  @override
  String get loadingDefault3 => 'I\'m here, just a moment please';

  @override
  String get loadingDefault4 => 'Opening the door to your heart';

  @override
  String get loadingDefault5 => 'How was your day?';

  @override
  String get profile => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get accountManagement => 'Account';

  @override
  String get appSettings => 'App Settings';

  @override
  String get support => 'Support';

  @override
  String get name => 'Name';

  @override
  String get birthdate => 'Birth Date';

  @override
  String get gender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Prefer not to say';

  @override
  String get birthTime => 'Birth Time';

  @override
  String get birthTimeUnknown => 'Unknown';

  @override
  String get lunarCalendar => 'Lunar';

  @override
  String get solarCalendar => 'Solar';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get fontSize => 'Font Size';

  @override
  String get language => 'Language';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get version => 'Version';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get navHome => 'Home';

  @override
  String get navInsight => 'Insight';

  @override
  String get navExplore => 'Explore';

  @override
  String get navTrend => 'Trend';

  @override
  String get navProfile => 'Profile';

  @override
  String get chatWelcome => 'Hello! What would you like to know?';

  @override
  String get chatPlaceholder => 'Type a message...';

  @override
  String get chatSend => 'Send';

  @override
  String get chatTyping => 'Typing...';
}
