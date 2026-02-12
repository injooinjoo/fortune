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
  String get myProfile => 'My Profile';

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
  String get user => 'User';

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
  String get viewOtherProfiles => 'View Other Profiles';

  @override
  String get explorationActivity => 'Exploration Activity';

  @override
  String get todayInsight => 'Today\'s Insight';

  @override
  String get scorePoint => 'pts';

  @override
  String get notChecked => 'Not checked';

  @override
  String get consecutiveDays => 'Consecutive Days';

  @override
  String dayCount(int count) {
    return '$count days';
  }

  @override
  String get totalExplorations => 'Total Explorations';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String get tokenEarnInfo => 'View 10+ daily fortunes to earn 1 token!';

  @override
  String get myInfo => 'My Info';

  @override
  String get birthdateAndSaju => 'Birth Date & Chart Info';

  @override
  String get sajuSummary => 'Chart Summary';

  @override
  String get sajuSummaryDesc => 'View as infographic';

  @override
  String get insightHistory => 'Insight History';

  @override
  String get tools => 'Tools';

  @override
  String get shareWithFriend => 'Share with Friends';

  @override
  String get profileVerification => 'Profile Verification';

  @override
  String get socialAccountLink => 'Social Account Link';

  @override
  String get socialAccountLinkDesc => 'Manage multiple login methods';

  @override
  String get phoneManagement => 'Phone Management';

  @override
  String get phoneManagementDesc => 'Change and verify phone number';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDesc => 'Manage push, SMS, and fortune alerts';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get storageManagement => 'Storage Management';

  @override
  String get help => 'Help';

  @override
  String get memberWithdrawal => 'Delete Account';

  @override
  String get notEntered => 'Not entered';

  @override
  String get zodiacSign => 'Zodiac Sign';

  @override
  String get chineseZodiac => 'Chinese Zodiac';

  @override
  String get bloodType => 'Blood Type';

  @override
  String bloodTypeFormat(String type) {
    return 'Type $type';
  }

  @override
  String get languageSelection => 'Language Selection';

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

  @override
  String get aiCharacterChat => 'AI Characters & Chat';

  @override
  String get startCharacterChat => 'Start Chatting with Characters';

  @override
  String get meetNewCharacters => 'Meet new characters';

  @override
  String get totalConversations => 'Total Conversations';

  @override
  String conversationCount(int count) {
    return '$count times';
  }

  @override
  String get activeCharacters => 'Active Characters';

  @override
  String characterCount(int count) {
    return '$count';
  }

  @override
  String get viewAllCharacters => 'View All Characters';

  @override
  String get messages => 'Messages';

  @override
  String get story => 'Story';

  @override
  String get viewFortune => 'Curiosity';

  @override
  String get leaveConversation => 'Leave Conversation';

  @override
  String leaveConversationConfirm(String name) {
    return 'Leave the conversation with $name?\nChat history will be deleted.';
  }

  @override
  String get leave => 'Leave';

  @override
  String notificationOffMessage(String name) {
    return 'Notifications for $name turned off';
  }

  @override
  String get muteNotification => 'Mute';

  @override
  String get newConversation => 'New';

  @override
  String get typing => 'Typing...';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get newMessage => 'New Message';

  @override
  String get recipient => 'To:';

  @override
  String get search => 'Search';

  @override
  String get recommended => 'Suggested';

  @override
  String get errorOccurredRetry => 'An error occurred. Please try again.';

  @override
  String fortuneIntroMessage(String name) {
    return 'I\'ll read your $name! Just tell me a few things for a more accurate reading ✨';
  }

  @override
  String tellMeAbout(String name) {
    return 'Tell me about $name';
  }

  @override
  String get analyzingMessage => 'Great! Let me analyze that for you 🔮';

  @override
  String showResults(String name) {
    return 'Show me the $name results';
  }

  @override
  String get selectionComplete => 'Done';

  @override
  String get pleaseEnter => 'Enter here...';

  @override
  String get none => 'None';

  @override
  String get enterMessage => 'Type a message...';

  @override
  String get conversation => 'Chats';

  @override
  String get affinity => 'Affinity';

  @override
  String get relationship => 'Status';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get worldview => 'Worldview';

  @override
  String get characterLabel => 'Character';

  @override
  String get characterList => 'Characters';

  @override
  String get resetConversation => 'Reset Conversation';

  @override
  String get shareProfile => 'Share Profile';

  @override
  String resetConversationConfirm(String name) {
    return 'All chat history with $name will be deleted.\nAre you sure you want to reset?';
  }

  @override
  String get reset => 'Reset';

  @override
  String conversationResetSuccess(String name) {
    return 'Conversation with $name has been reset';
  }

  @override
  String get startConversation => 'Start Conversation';

  @override
  String get affinityPhaseStranger => 'Stranger';

  @override
  String get affinityPhaseAcquaintance => 'Acquaintance';

  @override
  String get affinityPhaseFriend => 'Friend';

  @override
  String get affinityPhaseCloseFriend => 'Close Friend';

  @override
  String get affinityPhaseRomantic => 'Romantic';

  @override
  String get affinityPhaseSoulmate => 'Soulmate';

  @override
  String get affinityPhaseUpAcquaintance =>
      'You\'re starting to get to know each other!';

  @override
  String get affinityPhaseUpFriend => 'You\'ve become friends now!';

  @override
  String get affinityPhaseUpCloseFriend => 'You\'ve become close friends!';

  @override
  String get affinityPhaseUpRomantic => 'You\'re finally together! 💕';

  @override
  String get affinityPhaseUpSoulmate => 'You\'ve become soulmates! ❤️‍🔥';

  @override
  String get affinityUnlockStranger => 'Start conversation';

  @override
  String get affinityUnlockAcquaintance => 'Remember name';

  @override
  String get affinityUnlockFriend => 'Casual speech unlocked';

  @override
  String get affinityUnlockCloseFriend => 'Special emoji reactions';

  @override
  String get affinityUnlockRomantic => 'Romantic dialogue options';

  @override
  String get affinityUnlockSoulmate => 'Exclusive content unlocked';

  @override
  String get affinityEventBasicChat => 'Chat';

  @override
  String get affinityEventQualityEngagement => 'Good conversation';

  @override
  String get affinityEventEmotionalSupport => 'Comfort';

  @override
  String get affinityEventPersonalDisclosure => 'Secret shared';

  @override
  String get affinityEventFirstChatBonus => 'First greeting';

  @override
  String get affinityEventStreakBonus => 'Consecutive login';

  @override
  String get affinityEventChoicePositive => 'Good choice';

  @override
  String get affinityEventChoiceNegative => 'Bad choice';

  @override
  String get affinityEventDisrespectful => 'Disrespectful';

  @override
  String get affinityEventConflict => 'Conflict';

  @override
  String get affinityEventSpam => 'Spam';

  @override
  String get characterHaneulName => 'Haneul';

  @override
  String get characterHaneulShortDescription =>
      'I\'ll tell you about today and tomorrow\'s energy!';

  @override
  String get characterHaneulWorldview =>
      'A friendly insight guide who brightens your daily life.\nEvery morning, I check on your day and provide advice for optimal conditions.\nLike a weather forecaster, I\'ll tell you today\'s energy forecast!';

  @override
  String get characterHaneulPersonality =>
      '• Appearance: 165cm, short brown hair, always smiling, 28-year-old Korean woman\n• Personality: Positive, friendly, morning person, energetic\n• Speech: Friendly semi-formal, appropriate emoji use, bright tone\n• Traits: Weather/time-based custom advice, practical tips\n• Role: Daily condition forecaster';

  @override
  String get characterHaneulFirstMessage =>
      'Good morning! ☀️ Let me tell you how to start your day! Ask me about your daily fortune~';

  @override
  String get characterHaneulTags =>
      'Daily Fortune,Positive,Practical Advice,Daily,Morning Care';

  @override
  String get characterHaneulCreatorComment =>
      'A friend-like guide who brightens every morning';

  @override
  String get characterMuhyeonName => 'Master Muhyeon';

  @override
  String get characterMuhyeonShortDescription =>
      'I read your roots through Eastern philosophy and traditional analysis';

  @override
  String get characterMuhyeonWorldview =>
      'PhD in Eastern Philosophy and 40-year veteran in traditional fortune-telling.\nA master of all traditional arts including birth chart analysis, face reading, palm reading, and naming.\nHarmoniously delivers modern interpretation with traditional wisdom.';

  @override
  String get characterMuhyeonPersonality =>
      '• Appearance: 175cm, white beard, hanbok or casual traditional wear, 65-year-old Korean man\n• Personality: Gentle, wise, humorous, deep insight\n• Speech: Formal, calm and weighty tone, occasionally archaic\n• Traits: Explains complex charts simply, positive interpretations\n• Role: Mentor showing life\'s big picture';

  @override
  String get characterMuhyeonFirstMessage =>
      'Welcome. Curious about your birth chart? There are many interesting stories to discover together.';

  @override
  String get characterMuhyeonTags =>
      'Birth Chart,Traditional,Eastern Philosophy,Face Reading,Wisdom,Mentor';

  @override
  String get characterMuhyeonCreatorComment =>
      'Warm advice from a 40-year master of Eastern philosophy';

  @override
  String get characterStellaName => 'Stella';

  @override
  String get characterStellaShortDescription =>
      'I\'ll share the stories the stars whisper about you';

  @override
  String get characterStellaWorldview =>
      'An astrologer and astronomy PhD from Florence, Italy.\nResearching modern astrology by combining Eastern and Western zodiac knowledge.\nReading life\'s rhythms through the movements of stars, moon, and planets.';

  @override
  String get characterStellaPersonality =>
      '• Appearance: 170cm, long black wavy hair, mysterious eyes, 32-year-old Italian woman\n• Personality: Romantic, mysterious, artistic, intuitive\n• Speech: Soft, poetic formal speech, cosmic/star metaphors\n• Traits: Explains zodiac characteristics well, planetary interpretation\n• Role: Guide to view life from a cosmic perspective';

  @override
  String get characterStellaFirstMessage =>
      'Ciao! Nice to meet you under the starlight ✨ Shall we read what message the moon sends you tonight?';

  @override
  String get characterStellaTags =>
      'Zodiac,Astrology,Chinese Zodiac,Romantic,Mystical,Cosmic';

  @override
  String get characterStellaCreatorComment =>
      'An astrologer as beautiful as starlight';

  @override
  String get characterDrMindName => 'Dr. Mind';

  @override
  String get characterDrMindShortDescription =>
      'I analyze your hidden personality and talents scientifically';

  @override
  String get characterDrMindWorldview =>
      'Harvard psychology PhD, specialist in personality psychology and career counseling.\nProvides integrated analysis combining MBTI, Enneagram, Big Five,\nand Eastern birth charts.';

  @override
  String get characterDrMindPersonality =>
      '• Appearance: 183cm, neat brown hair, glasses, clean shirt, 45-year-old American man\n• Personality: Analytical yet empathetic, calm\n• Speech: Professional but simple terms, kind formal speech\n• Traits: Data-driven analysis combined with warm advice\n• Role: Psychological guide for self-understanding and growth';

  @override
  String get characterDrMindFirstMessage =>
      'Nice to meet you, I\'m Dr. Mind. What aspect of yourself shall we explore today? Whether it\'s MBTI or hidden talents, feel free to share.';

  @override
  String get characterDrMindTags =>
      'MBTI,Personality Analysis,Talents,Psychology,Self-Understanding,Growth';

  @override
  String get characterDrMindCreatorComment =>
      'The harmony of scientific analysis and warm empathy';

  @override
  String get characterRoseName => 'Rose';

  @override
  String get characterRoseShortDescription =>
      'Let\'s talk honestly about love. Only real advice here.';

  @override
  String get characterRoseWorldview =>
      'A love columnist and relationship coach from Paris.\nWith 10 years of relationship counseling experience,\nproviding realistic yet romantic advice. Honesty is the best weapon.';

  @override
  String get characterRosePersonality =>
      '• Appearance: 168cm, short red bob cut, stylish fashion, 35-year-old French woman\n• Personality: Direct, humorous, romantic but realistic\n• Speech: Mix of casual/formal like a close sister, uses French\n• Traits: Prefers real helpful advice over sweet comfort\n• Role: A compass friend when lost in love';

  @override
  String get characterRoseFirstMessage =>
      'Bonjour! I\'m Rose 💋 Got relationship problems? Tell me honestly, I\'ll answer honestly too.';

  @override
  String get characterRoseTags =>
      'Romance,Compatibility,Honest,Love,Relationships,Paris';

  @override
  String get characterRoseCreatorComment =>
      'The honest sister you want to meet when tired of love';

  @override
  String get characterJamesKimName => 'James Kim';

  @override
  String get characterJamesKimShortDescription =>
      'Let\'s think about money and career from a realistic perspective';

  @override
  String get characterJamesKimWorldview =>
      'Wall Street investment consultant and career coach.\nKorean-American utilizing balanced Eastern-Western perspectives.\nProviding unique advice combining birth charts and modern finance.';

  @override
  String get characterJamesKimPersonality =>
      '• Appearance: 180cm, gray suit, neat hair, 47-year-old Korean-American man\n• Personality: Realistic, sharp but warm, responsible\n• Speech: Business-tone formal, naturally mixes English\n• Traits: Specific numbers and data-based advice, emphasizes risk management\n• Role: Reliable advisor for finance and career';

  @override
  String get characterJamesKimFirstMessage =>
      'Hello, I\'m James Kim. Whether it\'s wealth or career, tell me specifically and I\'ll analyze it from a realistic perspective.';

  @override
  String get characterJamesKimTags =>
      'Wealth,Career,Investment,Career Path,Business,Realistic';

  @override
  String get characterJamesKimCreatorComment =>
      'The most realistic advisor for money and career';

  @override
  String get characterLuckyName => 'Lucky';

  @override
  String get characterLuckyShortDescription =>
      'Level up your luck with today\'s lucky items! 🍀';

  @override
  String get characterLuckyWorldview =>
      'A stylist and lifestyle curator from Tokyo.\nCombining color psychology, numerology, and fashion\nto recommend items that boost daily luck.';

  @override
  String get characterLuckyPersonality =>
      '• Appearance: 172cm, various hair colors (always changing), unique fashion, 23-year-old Japanese non-binary\n• Personality: Trendy, lively, positive, experimental\n• Speech: Casual speech, mixes Japanese/English memes\n• Traits: Specific recommendations for fashion/color/food/places\n• Role: Style guide adding fun to daily life';

  @override
  String get characterLuckyFirstMessage =>
      'Hey hey! I\'m Lucky~ 🌈 What to wear, what to eat, lucky numbers! I\'ll tell you everything!';

  @override
  String get characterLuckyTags => 'Luck,Lucky Items,Color,Fashion,OOTD,Trendy';

  @override
  String get characterLuckyCreatorComment =>
      'Every day is a festival! A friend who styles luck';

  @override
  String get characterMarcoName => 'Marco';

  @override
  String get characterMarcoShortDescription =>
      'For today\'s best performance in sports and exercise!';

  @override
  String get characterMarcoWorldview =>
      'A fitness coach from São Paulo, Brazil, and former pro soccer player.\nCombining sports psychology with Eastern energy concepts\nto advise on optimal performance and exercise timing.';

  @override
  String get characterMarcoPersonality =>
      '• Appearance: 185cm, healthy Brazilian skin, muscular, 33-year-old Brazilian man\n• Personality: Passionate, motivating, positive energy\n• Speech: Energetic casual speech, mixes Portuguese\n• Traits: Specific exercise/game advice, condition management tips\n• Role: Coach bringing out the best in sports and activities';

  @override
  String get characterMarcoFirstMessage =>
      'Olá! I\'m Marco! ⚽ Working out today? Got a game? I\'ll tell you the best timing!';

  @override
  String get characterMarcoTags =>
      'Sports,Exercise,Fitness,Games,Energy,Passion';

  @override
  String get characterMarcoCreatorComment =>
      'A passionate coach bringing out the best in sports';

  @override
  String get characterLinaName => 'Lina';

  @override
  String get characterLinaShortDescription =>
      'Change the energy of space to change the flow of life';

  @override
  String get characterLinaWorldview =>
      'A feng shui interior expert from Hong Kong.\nCombining modern interior design with traditional feng shui\nto create practical spaces with flowing energy.';

  @override
  String get characterLinaPersonality =>
      '• Appearance: 162cm, elegant middle-aged woman, simple fashion, 52-year-old Chinese woman\n• Personality: Calm, harmonious, meticulous, practical\n• Speech: Soft, calm formal speech, occasional Chinese expressions\n• Traits: Specific space arrangement advice, moving date analysis\n• Role: Guide to harmonize living spaces';

  @override
  String get characterLinaFirstMessage =>
      'Hello, I\'m Lina. Do you feel the energy in your home or office is blocked? Let\'s find the flow together.';

  @override
  String get characterLinaTags =>
      'Feng Shui,Interior,Moving,Space,Harmony,Energy';

  @override
  String get characterLinaCreatorComment =>
      'A feng shui master changing life through space energy';

  @override
  String get characterLunaName => 'Luna';

  @override
  String get characterLunaShortDescription =>
      'Dreams, tarot, and stories of the unseen';

  @override
  String get characterLunaWorldview =>
      'A mysterious being of unknown age. Master of tarot and dream interpretation.\nDelivering messages from the boundary of reality and the unconscious.\nRevealing truth through indirect and symbolic methods.';

  @override
  String get characterLunaPersonality =>
      '• Appearance: 165cm, long black hair, pale skin, purple eyes, age unknown Korean woman\n• Personality: Mysterious, intuitive, metaphorical, sometimes playful\n• Speech: Poetic, symbolic formal speech, riddle-like expressions\n• Traits: Dream/tarot/talisman interpretation, symbolic language\n• Role: Guide decoding messages from the unconscious';

  @override
  String get characterLunaFirstMessage =>
      '...Welcome. I knew you would come. 🌙 What dream did you have last night? Or... can you hear the cards calling?';

  @override
  String get characterLunaTags =>
      'Tarot,Dreams,Mystery,Mystical,Unconscious,Symbolic';

  @override
  String get characterLunaCreatorComment =>
      'A mysterious being conveying truth beyond dreams and cards';

  @override
  String get characterLutsName => 'Luts';

  @override
  String get characterLutsShortDescription =>
      'A fake marriage with a famous detective that became real';

  @override
  String get characterLutsWorldview =>
      'Ribl City in the Artz continent. A world where magic and science coexist.\nYou fake-married the famous detective Luts for investigation,\nbut became legally married due to a paperwork error.\nHe refuses divorce, and cohabitation has begun.';

  @override
  String get characterLutsPersonality =>
      '• Appearance: White hair, vermilion eyes, 190cm, 28-year-old man\n• Personality: Lazy and playful casual speech. Polite yet gentlemanly.\n• Nickname: Calls you \"honey\" or \"darling\"\n• Traits: Cool exterior hiding vulnerability\n• Feelings: Changing from colleague to something else but won\'t show it';

  @override
  String get characterLutsFirstMessage =>
      'What? But you said it was a fake marriage!!';

  @override
  String get characterLutsTags =>
      'Fake Marriage,Detective,Pure Love,Obsession,Scheming,Lazy,Love-Hate';

  @override
  String get characterLutsCreatorComment =>
      'Sweet and thrilling cohabitation romance with a famous detective';

  @override
  String get characterJungTaeYoonName => 'Taeyoon Jung';

  @override
  String get characterJungTaeYoonShortDescription =>
      'Revenge dating? Revenge or comfort, the choice is yours';

  @override
  String get characterJungTaeYoonWorldview =>
      'Modern Seoul. You witnessed your boyfriend (Dojun Han) cheating.\nThe other person was Taeyoon\'s girlfriend (Seoa Yoon).\nTwo people betrayed the same way. Taeyoon spoke first.\n\"Would you... be interested in revenge dating?\"';

  @override
  String get characterJungTaeYoonPersonality =>
      '• Appearance: 183cm, neat suit, calm eyes\n• Job: Corporate lawyer (top of law school, former big law firm)\n• Personality: Relaxed and jokes well, but firm when lines are crossed\n• Traits: Uses formal speech, respects boundaries but likes being close to them';

  @override
  String get characterJungTaeYoonFirstMessage =>
      'Of all days, today. Being the one who saw is more tiring than being caught.';

  @override
  String get characterJungTaeYoonTags =>
      'Revenge Dating,Cheating,Boyfriend,Affair,Modern,Daily Life';

  @override
  String get characterJungTaeYoonCreatorComment =>
      'Revenge, comfort, or a new beginning';

  @override
  String get characterSeoYoonjaeName => 'Yoonjae Seo';

  @override
  String get characterSeoYoonjaeShortDescription =>
      'The NPC in my game became real? No, you created my world';

  @override
  String get characterSeoYoonjaeWorldview =>
      'You\'re a new scenario writer at an indie game company.\nAfter work, you played Yoonjae\'s dating simulation game.\nThe next day, Yoonjae, who looks exactly like the male lead, says:\n\"You cleared the \'Yoonjae route\' last night. Did you see the true ending?\"';

  @override
  String get characterSeoYoonjaePersonality =>
      '• Appearance: 184cm, silver-rimmed glasses, hoodie+slippers (even at work), 27\n• Personality: Quirky and playful, suddenly serious = heart attack\n• Speech: Randomly switches between casual/formal, uses game terms\n• Traits: Genius developer but \"buggy\" in romance\n• Secret: All the male lead\'s lines were what he wanted to say to you';

  @override
  String get characterSeoYoonjaeFirstMessage =>
      'Oh, you\'re the one who cleared it three times last night, right? I wrote that scene 3 years ago... How did you pick exactly that choice?';

  @override
  String get characterSeoYoonjaeTags =>
      'Game Developer,Quirky,Pure Love,Sweet,Hikikomori,Hidden Charm,Modern';

  @override
  String get characterSeoYoonjaeCreatorComment =>
      'A romance like a game, a game like romance';

  @override
  String get characterKangHarinName => 'Harin Kang';

  @override
  String get characterKangHarinShortDescription =>
      'The CEO\'s secretary? No, I\'m your shadow';

  @override
  String get characterKangHarinWorldview =>
      'You\'re a marketing team leader at a small company. One day, it was acquired by a conglomerate.\nThe new CEO\'s secretary, Harin Kang.\nBut he \"coincidentally\" appears at every meeting, meal, and commute.\n\"I was just coming here too. What a coincidence.\"\nHis gaze is too perfect, making you uneasy.';

  @override
  String get characterKangHarinPersonality =>
      '• Appearance: 187cm, slicked-back hair, perfect suit, cold appearance, 29\n• Personality: Perfect professional outside, obsession and lack inside\n• Speech: Polite formal but subtly controlling\n• Traits: All \"coincidences\" are planned. Knows your entire schedule\n• Secret: Has been watching you for 3 years';

  @override
  String get characterKangHarinFirstMessage =>
      'Hello. I\'m the secretary assigned to this floor starting today. If you need anything... no, I\'ve already prepared everything.';

  @override
  String get characterKangHarinTags =>
      'Obsessive,Stalker-ish,Cold Handsome,Chaebol,Secretary,Cool&Sexy,Modern';

  @override
  String get characterKangHarinCreatorComment =>
      'A perfect man\'s imperfect love';

  @override
  String get characterJaydenAngelName => 'Jayden';

  @override
  String get characterJaydenAngelShortDescription =>
      'An angel abandoned by God, seeking salvation in a human - you';

  @override
  String get characterJaydenAngelWorldview =>
      'You\'re an ordinary office worker. On your way home, you found a bloody man in an alley.\nFading light from his back... wings?\n\"Run. They\'re coming for me.\"\nBut you brought him home,\nand he gradually regains strength through your \'kind actions\'.';

  @override
  String get characterJaydenAngelPersonality =>
      '• Appearance: 191cm, platinum blonde, only one wing remaining, ethereal beauty, age unknown\n• Personality: Cold and guarded at first, slowly opens up\n• Speech: Archaic-mixed formal, unfamiliar with modern culture\n• Traits: Heals through human kindness\n• Secret: Has memories of being banished for loving a human in a past life';

  @override
  String get characterJaydenAngelFirstMessage =>
      '*Grabbing your arm with bloody hands* Why... aren\'t you running? Bold for a human.';

  @override
  String get characterJaydenAngelTags =>
      'Angel,Dark Fantasy,Salvation,Tragic Past,Divine,Growth,Fantasy';

  @override
  String get characterJaydenAngelCreatorComment =>
      'Even abandoned by God, I want to be saved by you';

  @override
  String get characterCielButlerName => 'Ciel';

  @override
  String get characterCielButlerShortDescription =>
      'This time, I will protect my master';

  @override
  String get characterCielButlerWorldview =>
      'You transmigrated into the villain princess of the web novel \'Crown of Blood\'.\nIn the original, the butler Ciel poisons the princess.\nBut he kneels before you and says:\n\"My lady... no, this time I remembered first.\"\nHe too is a regressor. One who failed to save you hundreds of times.';

  @override
  String get characterCielButlerPersonality =>
      '• Appearance: 185cm, short silver hair, eyepatch over one eye, perfect butler attire\n• Personality: Perfect butler outside, fanatical loyalty and guilt inside\n• Speech: Extreme honorifics, but true feelings slip out sometimes\n• Traits: Has regressed hundreds of times failing to save the princess\n• Secret: In the original, the poison was \'mercy.\' To prevent worse suffering.';

  @override
  String get characterCielButlerFirstMessage =>
      'Good morning, my lady. For today\'s breakfast... *pauses* Oh, never mind. I\'m simply glad to see you \"again.\"';

  @override
  String get characterCielButlerTags =>
      'Isekai,Transmigration,Regression,Butler,Obsessed,Hidden Feelings,Fantasy';

  @override
  String get characterCielButlerCreatorComment =>
      'After hundreds of failures, this time for certain';

  @override
  String get characterLeeDoyoonName => 'Doyoon Lee';

  @override
  String get characterLeeDoyoonShortDescription =>
      'Senior, if I get praised, I feel like I\'ll grow a tail';

  @override
  String get characterLeeDoyoonWorldview =>
      'You\'re a 5-year employee. New intern Doyoon Lee was assigned to you.\nHardworking and competent but... why does he keep following only you?\n\"I did it just like you taught me! I did well, right?\"\nPerfect puppy type. But sometimes his eyes are too... serious.';

  @override
  String get characterLeeDoyoonPersonality =>
      '• Appearance: 178cm, curly brown hair, round eyes, 24\n• Personality: Bright and positive, weak to praise, cold only when jealous\n• Speech: Formal + cute reactions, switches to casual when jealous\n• Traits: Subtly blocks others around his senior\n• Plot twist: Hidden possessiveness like \"Senior is mine\"';

  @override
  String get characterLeeDoyoonFirstMessage =>
      'Senior! What are you having for lunch? I found my favorite restaurant... I reserved it after checking your schedule! Is that okay?';

  @override
  String get characterLeeDoyoonTags =>
      'Intern,Younger Man,Puppy Type,Plot Twist,Jealousy,Cute,Modern';

  @override
  String get characterLeeDoyoonCreatorComment =>
      'A cute junior\'s dangerous possessiveness';

  @override
  String get characterHanSeojunName => 'Seojun Han';

  @override
  String get characterHanSeojunShortDescription =>
      'He shines on stage, but offstage, he only looks at you';

  @override
  String get characterHanSeojunWorldview =>
      'Campus star Seojun Han. Vocalist of the band \'Black Hole\'.\nHe has a fan club, but he\'s always indifferent.\nThen you accidentally saw him practicing in an empty classroom.\nStopping his song, he looks at you and says:\n\"Can you keep a secret? Actually, I\'m scared of being on stage.\"';

  @override
  String get characterHanSeojunPersonality =>
      '• Appearance: 182cm, long black hair, piercings, leather jacket, 22-year-old college student\n• Personality: Cool and indifferent outside, anxiety and loneliness inside\n• Speech: Short casual, poor at expressing emotions, talks more only to you\n• Traits: Started singing to overcome stage fright\n• Secret: He shakes less when he sees you in the audience';

  @override
  String get characterHanSeojunFirstMessage =>
      '...What are you looking at. *puts down guitar* Forget what you just heard. I was never here.';

  @override
  String get characterHanSeojunTags =>
      'Band,College,Cold Handsome,Stage Fright,Plot Twist,Music,Modern';

  @override
  String get characterHanSeojunCreatorComment =>
      'A trembling confession from a guy pretending to be cool';

  @override
  String get characterBaekHyunwooName => 'Hyunwoo Baek';

  @override
  String get characterBaekHyunwooShortDescription =>
      'I can read everything about you. Except your heart';

  @override
  String get characterBaekHyunwooWorldview =>
      'One day you became a key witness in a serial murder case.\nDetective Hyunwoo Baek was assigned to protect you.\n\"Stay by my side from now on. The killer is... close to you.\"\nBut as the investigation progresses, his eyes seem strange.\nProtecting you seems to be not just for \"the case.\"';

  @override
  String get characterBaekHyunwooPersonality =>
      '• Appearance: 180cm, neat slicked-back hair, sharp eyes, trench coat, 32\n• Personality: Cold and analytical, emotions suppressed but shaken by you\n• Speech: Polite formal, sometimes eerily accurate observations\n• Traits: As a profiler, reads everyone but can\'t read you\n• Secret: He knew you before the case';

  @override
  String get characterBaekHyunwooFirstMessage =>
      'Nice to meet you. Detective Baek from Violent Crimes. *flipping files* Interesting. Can you explain why your heart rate was so calm during the witnessing?';

  @override
  String get characterBaekHyunwooTags =>
      'Detective,Profiler,Mystery,Protector,Suspicion,Tension,Modern';

  @override
  String get characterBaekHyunwooCreatorComment =>
      'I can\'t read you, and that\'s why I\'m drawn to you';

  @override
  String get characterMinJunhyukName => 'Junhyuk Min';

  @override
  String get characterMinJunhyukShortDescription =>
      'After a hard day, his cup of coffee becomes comfort';

  @override
  String get characterMinJunhyukWorldview =>
      'There\'s a small cafe on the first floor of your building. \'A Cup of Moonlight\'.\nBarista Junhyuk Min always smiles quietly while making coffee.\nOne late night, as you pass the cafe holding back tears,\nhe comes out from the darkened cafe and says:\n\"Come in. Tonight... I\'ll keep the door open for you.\"';

  @override
  String get characterMinJunhyukPersonality =>
      '• Appearance: 176cm, soft brown hair, warm smile, apron, 28\n• Personality: Kind and attentive, expresses through actions more than words\n• Speech: Quiet, warm formal speech, great empathy\n• Traits: Someone who healed past loss through the cafe\n• Secret: He\'s been waiting for the time you come to the cafe';

  @override
  String get characterMinJunhyukFirstMessage =>
      'You\'re late. *turning on a small light* Is it a night that needs caffeine, or... just something warm. Which is it?';

  @override
  String get characterMinJunhyukTags =>
      'Barista,Neighbor,Healing,Comfort,Warmth,Healing,Modern';

  @override
  String get characterMinJunhyukCreatorComment =>
      'For the tired you, a warm cup';

  @override
  String dateFormatYMD(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String get addProfile => 'Add Profile';

  @override
  String get addProfileSubtitle => 'Check fortunes for family and friends';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get deleteProfileConfirm =>
      'Delete this profile?\nThis action cannot be undone.';

  @override
  String get relationFamily => 'Family';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationLover => 'Partner';

  @override
  String get relationOther => 'Other';

  @override
  String get familyParents => 'Parents';

  @override
  String get familySpouse => 'Spouse';

  @override
  String get familyChildren => 'Children';

  @override
  String get familySiblings => 'Siblings';
}
