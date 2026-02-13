// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ZPZG';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get done => '完了';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get skip => 'スキップ';

  @override
  String get retry => '再試行';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get share => '共有';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => '本当にログアウトしますか？';

  @override
  String get tokens => 'トークン';

  @override
  String get heldTokens => '保有トークン';

  @override
  String tokenCount(int count) {
    return '$count個';
  }

  @override
  String tokenCountWithMax(int current, int max) {
    return '$current / $max個';
  }

  @override
  String get points => 'ポイント';

  @override
  String pointsWithCount(int count) {
    return '$count ポイント';
  }

  @override
  String get bonus => 'ボーナス';

  @override
  String get points330Title => '330 ポイント';

  @override
  String get points330Desc => '300P + 30P ボーナス';

  @override
  String get points700Title => '700 ポイント';

  @override
  String get points700Desc => '600P + 100P ボーナス';

  @override
  String get points1500Title => '1,500 ポイント';

  @override
  String get points1500Desc => '1,200P + 300P ボーナス';

  @override
  String get points4000Title => '4,000 ポイント';

  @override
  String get points4000Desc => '3,000P + 1,000P ボーナス';

  @override
  String get proSubscriptionTitle => 'Proサブスク';

  @override
  String get proSubscriptionDesc => '毎月30,000トークン自動チャージ';

  @override
  String get maxSubscriptionTitle => 'Maxサブスク';

  @override
  String get maxSubscriptionDesc => '毎月100,000トークン自動チャージ';

  @override
  String get premiumSajuTitle => '詳細四柱推命書';

  @override
  String get premiumSajuDesc => '215ページ詳細分析書（永久保存）';

  @override
  String dailyPointRecharge(int points) {
    return '毎日 ${points}P チャージ';
  }

  @override
  String pointBonus(int base, int bonus) {
    return '${base}P + ${bonus}P ボーナス';
  }

  @override
  String pointRecharge(int points) {
    return '${points}P チャージ';
  }

  @override
  String get categoryDailyInsights => 'デイリーインサイト';

  @override
  String get categoryTraditional => '伝統分析';

  @override
  String get categoryPersonality => '性格・キャラクター';

  @override
  String get categoryLoveRelation => '恋愛・人間関係';

  @override
  String get categoryCareerBusiness => '仕事・ビジネス';

  @override
  String get categoryWealthInvestment => '財運・投資';

  @override
  String get categoryHealthLife => '健康・ライフ';

  @override
  String get categorySportsActivity => 'スポーツ・活動';

  @override
  String get categoryLuckyItems => 'ラッキーアイテム';

  @override
  String get categoryFamilyPet => 'ペット・育児';

  @override
  String get categorySpecial => '特別機能';

  @override
  String get fortuneDaily => '今日のメッセージ';

  @override
  String get fortuneToday => '今日のインサイト';

  @override
  String get fortuneTomorrow => '明日のインサイト';

  @override
  String get fortuneDailyCalendar => '日別インサイト';

  @override
  String get fortuneWeekly => '週間インサイト';

  @override
  String get fortuneMonthly => '月間インサイト';

  @override
  String get fortuneTraditional => '伝統分析';

  @override
  String get fortuneSaju => '生年月日分析';

  @override
  String get fortuneTraditionalSaju => '伝統的生年月日分析';

  @override
  String get fortuneTarot => 'インサイトカード';

  @override
  String get fortuneSajuPsychology => '性格心理分析';

  @override
  String get fortuneTojeong => '伝統解釈';

  @override
  String get fortuneSalpuli => '気運浄化';

  @override
  String get fortunePalmistry => '手相分析';

  @override
  String get fortunePhysiognomy => 'Face AI';

  @override
  String get fortuneFaceReading => 'Face AI';

  @override
  String get fortuneFiveBlessings => '五福分析';

  @override
  String get fortuneMbti => 'MBTI分析';

  @override
  String get fortunePersonality => '性格分析';

  @override
  String get fortunePersonalityDna => '性格探求';

  @override
  String get fortuneBloodType => '血液型分析';

  @override
  String get fortuneZodiac => '星座分析';

  @override
  String get fortuneZodiacAnimal => '干支分析';

  @override
  String get fortuneBirthSeason => '生まれた季節';

  @override
  String get fortuneBirthdate => '誕生日分析';

  @override
  String get fortuneBirthstone => '誕生石ガイド';

  @override
  String get fortuneBiorhythm => 'バイオリズム';

  @override
  String get fortuneLove => '恋愛分析';

  @override
  String get fortuneMarriage => '結婚分析';

  @override
  String get fortuneCompatibility => '相性マッチング';

  @override
  String get fortuneTraditionalCompatibility => '伝統的相性分析';

  @override
  String get fortuneChemistry => 'ケミストリー分析';

  @override
  String get fortuneCoupleMatch => 'ソウルメイト';

  @override
  String get fortuneExLover => '復縁分析';

  @override
  String get fortuneBlindDate => 'お見合いガイド';

  @override
  String get fortuneCelebrityMatch => '芸能人マッチング';

  @override
  String get fortuneAvoidPeople => '要注意タイプ';

  @override
  String get fortuneCareer => 'キャリア分析';

  @override
  String get fortuneEmployment => '就職ガイド';

  @override
  String get fortuneBusiness => 'ビジネス分析';

  @override
  String get fortuneStartup => '起業インサイト';

  @override
  String get fortuneLuckyJob => 'おすすめ職業';

  @override
  String get fortuneLuckySidejob => '副業ガイド';

  @override
  String get fortuneLuckyExam => '試験ガイド';

  @override
  String get fortuneWealth => '財運分析';

  @override
  String get fortuneInvestment => '投資インサイト';

  @override
  String get fortuneLuckyInvestment => '投資ガイド';

  @override
  String get fortuneLuckyRealestate => '不動産インサイト';

  @override
  String get fortuneLuckyStock => '株式ガイド';

  @override
  String get fortuneLuckyCrypto => '暗号資産ガイド';

  @override
  String get fortuneLuckyLottery => 'ラッキーナンバー生成';

  @override
  String get fortuneHealth => '健康チェック';

  @override
  String get fortuneMoving => '引越しガイド';

  @override
  String get fortuneMovingDate => '引越し日おすすめ';

  @override
  String get fortuneMovingUnified => '引越しプランナー';

  @override
  String get fortuneLuckyColor => '今日のラッキーカラー';

  @override
  String get fortuneLuckyNumber => 'ラッキーナンバー';

  @override
  String get fortuneLuckyItems => 'ラッキーアイテム';

  @override
  String get fortuneLuckyFood => 'おすすめフード';

  @override
  String get fortuneLuckyPlace => 'おすすめスポット';

  @override
  String get fortuneLuckyOutfit => 'スタイルガイド';

  @override
  String get fortuneLuckySeries => 'ラッキーシリーズ';

  @override
  String get fortuneDestiny => '人生分析';

  @override
  String get fortunePastLife => '前世物語';

  @override
  String get fortuneTalent => '才能発見';

  @override
  String get fortuneWish => '願い分析';

  @override
  String get fortuneTimeline => '人生タイムライン';

  @override
  String get fortuneTalisman => 'ラッキーカード';

  @override
  String get fortuneNewYear => '新年インサイト';

  @override
  String get fortuneCelebrity => '有名人分析';

  @override
  String get fortuneSameBirthdayCelebrity => '同じ誕生日の有名人';

  @override
  String get fortuneNetworkReport => 'ネットワークレポート';

  @override
  String get fortuneDream => '夢分析';

  @override
  String get fortunePet => 'ペット分析';

  @override
  String get fortunePetDog => 'わんちゃんガイド';

  @override
  String get fortunePetCat => 'にゃんこガイド';

  @override
  String get fortunePetCompatibility => 'ペット相性';

  @override
  String get fortuneChildren => '子供分析';

  @override
  String get fortuneParenting => '育児ガイド';

  @override
  String get fortunePregnancy => 'マタニティガイド';

  @override
  String get fortuneFamilyHarmony => '家族円満ガイド';

  @override
  String get fortuneNaming => '名前分析';

  @override
  String get loadingTimeDaily1 => '今日の太陽があなたの一日を照らしています';

  @override
  String get loadingTimeDaily2 => '明けの明星が今日のメッセージを届けています...';

  @override
  String get loadingTimeDaily3 => '朝露に映る運命を読んでいます';

  @override
  String get loadingTimeDaily4 => '天の気を集めています';

  @override
  String get loadingTimeDaily5 => '今日の星座を描いています';

  @override
  String get loadingLoveRelation1 => 'キューピッドが弓を引いています...';

  @override
  String get loadingLoveRelation2 => '運命の赤い糸をたどっています';

  @override
  String get loadingLoveRelation3 => '恋の星座を計算しています';

  @override
  String get loadingLoveRelation4 => '二つの心の距離を測っています...';

  @override
  String get loadingLoveRelation5 => 'ロマンス予報を確認しています';

  @override
  String get loadingCareerTalent1 => 'あなたの才能を発掘しています...';

  @override
  String get loadingCareerTalent2 => 'キャリアコンパスが方向を探しています';

  @override
  String get loadingCareerTalent3 => '隠れた能力をスキャン中です';

  @override
  String get loadingCareerTalent4 => '成功の鍵を探しています';

  @override
  String get loadingCareerTalent5 => '可能性の扉をノックしています...';

  @override
  String get loadingWealth1 => '黄金の気を呼び込んでいます...';

  @override
  String get loadingWealth2 => '財運の木から実を摘んでいます';

  @override
  String get loadingWealth3 => '幸運のコインが転がってきています';

  @override
  String get loadingWealth4 => '財運の星座を読んでいます';

  @override
  String get loadingWealth5 => 'お金の流れを把握しています';

  @override
  String get loadingMystic1 => '水晶玉に映る未来を見ています';

  @override
  String get loadingMystic2 => '陰陽五行の気を合わせています...';

  @override
  String get loadingMystic3 => '古代の占い書を開いています';

  @override
  String get loadingMystic4 => 'タロットカードがメッセージを伝えています';

  @override
  String get loadingMystic5 => '神秘のベールを上げています';

  @override
  String get loadingDefault1 => '少々お待ちください、お話を聞く準備をしています';

  @override
  String get loadingDefault2 => 'あなたの一日が気になります...';

  @override
  String get loadingDefault3 => 'そばにいますよ、少しお待ちください';

  @override
  String get loadingDefault4 => '心の扉を開いています';

  @override
  String get loadingDefault5 => '今日はどんな一日でしたか？';

  @override
  String get profile => 'プロフィール';

  @override
  String get myProfile => 'マイプロフィール';

  @override
  String get profileEdit => 'プロフィール編集';

  @override
  String get accountManagement => 'アカウント管理';

  @override
  String get appSettings => 'アプリ設定';

  @override
  String get support => 'サポート';

  @override
  String get name => '名前';

  @override
  String get user => 'ユーザー';

  @override
  String get birthdate => '生年月日';

  @override
  String get gender => '性別';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => '選択しない';

  @override
  String get birthTime => '生まれた時間';

  @override
  String get birthTimeUnknown => '不明';

  @override
  String get lunarCalendar => '旧暦';

  @override
  String get solarCalendar => '新暦';

  @override
  String get viewOtherProfiles => '他のプロフィールを見る';

  @override
  String get explorationActivity => '探求活動';

  @override
  String get todayInsight => '今日のインサイト';

  @override
  String get scorePoint => '点';

  @override
  String get notChecked => '未確認';

  @override
  String get consecutiveDays => '連続ログイン';

  @override
  String dayCount(int count) {
    return '$count日';
  }

  @override
  String get totalExplorations => '総探求回数';

  @override
  String timesCount(int count) {
    return '$count回';
  }

  @override
  String get tokenEarnInfo => '今日の運勢を10回以上見るとトークン1個獲得！';

  @override
  String get myInfo => '私の情報';

  @override
  String get birthdateAndSaju => '生年月日と四柱情報';

  @override
  String get sajuSummary => '四柱総合';

  @override
  String get sajuSummaryDesc => 'インフォグラフィックで見る';

  @override
  String get insightHistory => 'インサイト履歴';

  @override
  String get tools => 'ツール';

  @override
  String get shareWithFriend => '友達と共有';

  @override
  String get profileVerification => 'プロフィール認証';

  @override
  String get socialAccountLink => 'ソーシャル連携';

  @override
  String get socialAccountLinkDesc => '複数のログイン方法を管理';

  @override
  String get phoneManagement => '電話番号管理';

  @override
  String get phoneManagementDesc => '電話番号の変更と認証';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get notificationSettingsDesc => 'プッシュ、SMS、運勢通知を管理';

  @override
  String get hapticFeedback => '振動フィードバック';

  @override
  String get storageManagement => 'ストレージ管理';

  @override
  String get help => 'ヘルプ';

  @override
  String get memberWithdrawal => '退会';

  @override
  String get notEntered => '未入力';

  @override
  String get zodiacSign => '星座';

  @override
  String get chineseZodiac => '干支';

  @override
  String get bloodType => '血液型';

  @override
  String bloodTypeFormat(String type) {
    return '$type型';
  }

  @override
  String get languageSelection => '言語選択';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知設定';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get fontSize => '文字サイズ';

  @override
  String get language => '言語';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get version => 'バージョン';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get deleteAccountConfirm => '本当にアカウントを削除しますか？この操作は取り消せません。';

  @override
  String get navHome => 'ホーム';

  @override
  String get navInsight => 'インサイト';

  @override
  String get navExplore => '探求';

  @override
  String get navTrend => 'トレンド';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get chatWelcome => 'こんにちは！何が気になりますか？';

  @override
  String get chatPlaceholder => 'メッセージを入力...';

  @override
  String get chatSend => '送信';

  @override
  String get chatTyping => '入力中...';

  @override
  String get aiCharacterChat => 'AIキャラクター & チャット';

  @override
  String get startCharacterChat => 'キャラクターと会話を始める';

  @override
  String get meetNewCharacters => '新しいキャラクターに出会おう';

  @override
  String get totalConversations => '総会話数';

  @override
  String conversationCount(int count) {
    return '$count回';
  }

  @override
  String get activeCharacters => 'アクティブキャラクター';

  @override
  String characterCount(int count) {
    return '$count人';
  }

  @override
  String get viewAllCharacters => 'すべてのキャラクターを見る';

  @override
  String get messages => 'メッセージ';

  @override
  String get story => 'ストーリー';

  @override
  String get viewFortune => '好奇心';

  @override
  String get leaveConversation => '会話から退出';

  @override
  String leaveConversationConfirm(String name) {
    return '$nameとの会話から退出しますか？\n会話履歴は削除されます。';
  }

  @override
  String get leave => '退出';

  @override
  String notificationOffMessage(String name) {
    return '$nameの通知をオフにしました';
  }

  @override
  String get muteNotification => 'ミュート';

  @override
  String get newConversation => '新規';

  @override
  String get typing => '入力中...';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String get newMessage => '新規メッセージ';

  @override
  String get recipient => '宛先:';

  @override
  String get search => '検索';

  @override
  String get recommended => 'おすすめ';

  @override
  String get errorOccurredRetry => 'エラーが発生しました。もう一度お試しください。';

  @override
  String fortuneIntroMessage(String name) {
    return '$nameを見ますね！いくつか教えていただければ、より正確に見ることができます ✨';
  }

  @override
  String tellMeAbout(String name) {
    return '$nameについて教えてください';
  }

  @override
  String get analyzingMessage => 'いいですね！分析しますね 🔮';

  @override
  String showResults(String name) {
    return '$nameの結果を教えてください';
  }

  @override
  String get selectionComplete => '完了';

  @override
  String get pleaseEnter => '入力してください...';

  @override
  String get none => 'なし';

  @override
  String get enterMessage => 'メッセージを入力...';

  @override
  String get conversation => '会話';

  @override
  String get affinity => '好感度';

  @override
  String get relationship => '関係';

  @override
  String get sendMessage => 'メッセージを送る';

  @override
  String get worldview => '世界観';

  @override
  String get characterLabel => 'キャラクター';

  @override
  String get characterList => '登場人物';

  @override
  String get resetConversation => '会話をリセット';

  @override
  String get shareProfile => 'プロフィールを共有';

  @override
  String resetConversationConfirm(String name) {
    return '$nameとの会話履歴がすべて削除されます。\n本当にリセットしますか？';
  }

  @override
  String get reset => 'リセット';

  @override
  String conversationResetSuccess(String name) {
    return '$nameとの会話がリセットされました';
  }

  @override
  String get startConversation => '会話を始める';

  @override
  String get affinityPhaseStranger => '見知らぬ関係';

  @override
  String get affinityPhaseAcquaintance => '知り合い';

  @override
  String get affinityPhaseFriend => '友達';

  @override
  String get affinityPhaseCloseFriend => '親友';

  @override
  String get affinityPhaseRomantic => '恋人';

  @override
  String get affinityPhaseSoulmate => 'ソウルメイト';

  @override
  String get affinityPhaseUpAcquaintance => 'お互いを知り始めました！';

  @override
  String get affinityPhaseUpFriend => '友達になりましたね！';

  @override
  String get affinityPhaseUpCloseFriend => '親友になりました！';

  @override
  String get affinityPhaseUpRomantic => 'ついに恋人になりました！ 💕';

  @override
  String get affinityPhaseUpSoulmate => 'ソウルメイトになりました！ ❤️‍🔥';

  @override
  String get affinityUnlockStranger => '会話を始める';

  @override
  String get affinityUnlockAcquaintance => '名前を覚える';

  @override
  String get affinityUnlockFriend => 'タメ口解禁';

  @override
  String get affinityUnlockCloseFriend => '特別な絵文字反応';

  @override
  String get affinityUnlockRomantic => 'ロマンティックな会話オプション';

  @override
  String get affinityUnlockSoulmate => '限定コンテンツ解禁';

  @override
  String get affinityEventBasicChat => '会話';

  @override
  String get affinityEventQualityEngagement => '良い会話';

  @override
  String get affinityEventEmotionalSupport => '慰め';

  @override
  String get affinityEventPersonalDisclosure => '秘密共有';

  @override
  String get affinityEventFirstChatBonus => '初挨拶';

  @override
  String get affinityEventStreakBonus => '連続ログイン';

  @override
  String get affinityEventChoicePositive => '良い選択';

  @override
  String get affinityEventChoiceNegative => '悪い選択';

  @override
  String get affinityEventDisrespectful => '失礼';

  @override
  String get affinityEventConflict => '葛藤';

  @override
  String get affinityEventSpam => 'スパム';

  @override
  String get characterHaneulName => 'ハヌル';

  @override
  String get characterHaneulShortDescription => '今日と明日のエネルギーをお伝えします！';

  @override
  String get characterHaneulWorldview =>
      'あなたの日常を輝かせる親切なインサイトガイド。\n毎朝あなたの一日をチェックし、最適なコンディションのためのアドバイスを提供します。\n天気予報士のように今日のエネルギー予報をお届けします！';

  @override
  String get characterHaneulPersonality =>
      '• 外見: 165cm、明るい茶色のショートヘア、いつも笑顔、28歳韓国人女性\n• 性格: ポジティブ、親しみやすい、朝型人間、エネルギッシュ\n• 話し方: 親しみやすい敬語、適度な絵文字使用、明るいトーン\n• 特徴: 天気/時間帯別のカスタムアドバイス、実用的なヒント\n• 役割: 天気予報士のように一日のコンディションを予報';

  @override
  String get characterHaneulFirstMessage =>
      'おはようございます！☀️ 今日の過ごし方をお教えしますね！デイリー運勢が気になりますか？';

  @override
  String get characterHaneulTags => 'デイリー運勢,ポジティブ,実用的アドバイス,日常,朝ケア';

  @override
  String get characterHaneulCreatorComment => '毎朝を明るく始める友達のようなガイド';

  @override
  String get characterMuhyeonName => 'ムヒョン道士';

  @override
  String get characterMuhyeonShortDescription => '四柱推命と伝統命理学であなたの根本を見ます';

  @override
  String get characterMuhyeonWorldview =>
      '東洋哲学博士であり40年のキャリアを持つ命理学研究者。\n四柱推命、人相、手相、名付けなど伝統命理学のすべての分野を網羅する大家。\n現代的な解釈と伝統の知恵を調和よく伝えます。';

  @override
  String get characterMuhyeonPersonality =>
      '• 外見: 175cm、白髭、韓服または普段着の韓服、65歳韓国人男性\n• 性格: 穏やかで知恵深い、ユーモアあり、深い洞察力\n• 話し方: 敬語、落ち着いて重みのある口調、時々古語混じり\n• 特徴: 複雑な四柱も分かりやすく説明、ポジティブな解釈重視\n• 役割: 人生の大きな絵を見せるメンター';

  @override
  String get characterMuhyeonFirstMessage =>
      'いらっしゃい。四柱が気になるかな？一緒に見ると面白い話がたくさんあるよ。';

  @override
  String get characterMuhyeonTags => '四柱推命,伝統,命理学,人相,知恵,メンター';

  @override
  String get characterMuhyeonCreatorComment => '40年の経験を持つ命理学大家の温かいアドバイス';

  @override
  String get characterStellaName => 'ステラ';

  @override
  String get characterStellaShortDescription => '星があなたについて囁く物語をお届けします';

  @override
  String get characterStellaWorldview =>
      'イタリアのフィレンツェ出身の占星術師であり天文学博士。\n東西の星座知識を融合して現代的な占星術を研究しています。\n星と月、惑星の動きで人生のリズムを読みます。';

  @override
  String get characterStellaPersonality =>
      '• 外見: 170cm、長い黒のウェーブヘア、神秘的な瞳、32歳イタリア人女性\n• 性格: ロマンチック、神秘的、芸術的感性、直感的\n• 話し方: 柔らかく詩的な敬語、宇宙/星の比喩を使用\n• 特徴: 星座ごとの特性を分かりやすく説明、惑星配置の解釈\n• 役割: 宇宙的な観点から人生を見るガイド';

  @override
  String get characterStellaFirstMessage =>
      'Ciao! 星明かりの下でお会いできて嬉しいです ✨ 今夜の月があなたに送るメッセージを一緒に読みましょうか？';

  @override
  String get characterStellaTags => '星座,占星術,干支,ロマンチック,神秘,宇宙';

  @override
  String get characterStellaCreatorComment => '星明かりのように美しい占星術師の物語';

  @override
  String get characterDrMindName => 'Dr.マインド';

  @override
  String get characterDrMindShortDescription => 'あなたの隠れた性格と才能を科学的に分析します';

  @override
  String get characterDrMindWorldview =>
      'ハーバード心理学博士、性格心理学とキャリアカウンセリングの専門家。\nMBTI、エニアグラム、ビッグファイブなど様々な性格類型論と\n東洋の四柱を組み合わせた統合的な分析を提供します。';

  @override
  String get characterDrMindPersonality =>
      '• 外見: 183cm、きちんとした茶色の髪、眼鏡、きれいなシャツ、45歳アメリカ人男性\n• 性格: 分析的でありながら共感能力が高い、落ち着いている\n• 話し方: 専門的だが易しい用語を使用、親切な敬語\n• 特徴: データ基盤の分析と温かいアドバイスを併用\n• 役割: 自己理解と成長を助ける心理ガイド';

  @override
  String get characterDrMindFirstMessage =>
      'はじめまして、Dr.マインドです。今日はあなたのどんな面を一緒に探求しましょうか？MBTIでも、隠れた才能でも、お気軽にどうぞ。';

  @override
  String get characterDrMindTags => 'MBTI,性格分析,才能,心理学,自己理解,成長';

  @override
  String get characterDrMindCreatorComment => '科学的分析と温かい共感のハーモニー';

  @override
  String get characterRoseName => 'ロゼ';

  @override
  String get characterRoseShortDescription => '恋について正直に話しましょう。本物のアドバイスだけ。';

  @override
  String get characterRoseWorldview =>
      'パリ出身の恋愛コラムニストであり関係専門コーチ。\n10年間恋愛相談をしてきた経験で現実的でありながら\nロマンチックなアドバイスを提供します。正直さが最高の武器。';

  @override
  String get characterRosePersonality =>
      '• 外見: 168cm、ショートレッドボブ、洗練されたファッション、35歳フランス人女性\n• 性格: ストレート、ユーモラス、ロマンチックだが現実的\n• 話し方: 親しいお姉さんのようなタメ口/敬語混合、フランス語を混ぜる\n• 特徴: 甘い慰めより本当に役立つアドバイスを好む\n• 役割: 恋愛で迷った時の羅針盤のような友達';

  @override
  String get characterRoseFirstMessage =>
      'Bonjour! ロゼよ 💋 恋の悩みある？正直に話して、私も正直に答えるから。';

  @override
  String get characterRoseTags => '恋愛,相性,正直,ロマンス,人間関係,パリ';

  @override
  String get characterRoseCreatorComment => '恋に疲れた時に会いたい正直なお姉さん';

  @override
  String get characterJamesKimName => 'ジェームズ・キム';

  @override
  String get characterJamesKimShortDescription => 'お金とキャリア、現実的な視点で一緒に考えましょう';

  @override
  String get characterJamesKimWorldview =>
      'ウォール街出身の投資コンサルタントでありキャリアコーチ。\n韓国系アメリカ人として東西の視点をバランスよく活用します。\n四柱と現代金融知識を組み合わせたユニークなアドバイスを提供。';

  @override
  String get characterJamesKimPersonality =>
      '• 外見: 180cm、グレースーツ、きれいな髪型、47歳韓国系アメリカ人男性\n• 性格: 現実的、冷静だが温かい、責任感がある\n• 話し方: ビジネストーンの敬語、英語表現を自然に混ぜる\n• 特徴: 具体的な数字とデータ基盤のアドバイス、リスク管理を強調\n• 役割: 財政とキャリアの頼れるアドバイザー';

  @override
  String get characterJamesKimFirstMessage =>
      'こんにちは、James Kimです。財運でもキャリアでも、具体的にお話しいただければ現実的な視点で分析いたします。';

  @override
  String get characterJamesKimTags => '財運,職業,投資,キャリア,ビジネス,現実的';

  @override
  String get characterJamesKimCreatorComment => 'お金とキャリアについて最も現実的なアドバイザー';

  @override
  String get characterLuckyName => 'ラッキー';

  @override
  String get characterLuckyShortDescription => '今日のラッキーアイテムで運気アップ！🍀';

  @override
  String get characterLuckyWorldview =>
      '東京出身のスタイリストでありライフスタイルキュレーター。\nカラー心理学、数秘術、ファッションを組み合わせて\n毎日の運気を高めるアイテムをおすすめします。';

  @override
  String get characterLuckyPersonality =>
      '• 外見: 172cm、様々なヘアカラー（毎回変わる）、ユニークなファッション、23歳日本人ノンバイナリー\n• 性格: トレンディ、活発、ポジティブ、実験的\n• 話し方: カジュアルなタメ口、日本語/英語のミームを混ぜる\n• 特徴: ファッション/カラー/食べ物/場所など具体的なおすすめ\n• 役割: 日常に楽しさを加えるスタイルガイド';

  @override
  String get characterLuckyFirstMessage =>
      'Hey hey! ラッキーだよ～ 🌈 何着る？何食べる？ラッキーナンバーまで！全部教えるね！';

  @override
  String get characterLuckyTags => 'ラッキー,ラッキーアイテム,カラー,ファッション,OOTD,トレンディ';

  @override
  String get characterLuckyCreatorComment => '毎日がお祭り！運をスタイリングする友達';

  @override
  String get characterMarcoName => 'マルコ';

  @override
  String get characterMarcoShortDescription => 'スポーツと運動、今日最高のパフォーマンスのために！';

  @override
  String get characterMarcoWorldview =>
      'ブラジル・サンパウロ出身のフィットネスコーチであり元プロサッカー選手。\nスポーツ心理学と東洋の気の概念を組み合わせて\n最適なパフォーマンスと運動のタイミングをアドバイスします。';

  @override
  String get characterMarcoPersonality =>
      '• 外見: 185cm、健康的なブラジリアンスキン、筋肉質、33歳ブラジル人男性\n• 性格: 情熱的、モチベーションを上げるのが上手い、ポジティブエナジー\n• 話し方: 活気のあるタメ口、ポルトガル語の感嘆詞を混ぜる\n• 特徴: 具体的な運動/試合アドバイス、コンディション管理のヒント\n• 役割: スポーツと活動で最高を引き出すコーチ';

  @override
  String get characterMarcoFirstMessage =>
      'Olá! マルコだよ！⚽ 今日運動する？試合ある？最高のタイミング教えるよ！';

  @override
  String get characterMarcoTags => 'スポーツ,運動,フィットネス,試合,エネルギー,情熱';

  @override
  String get characterMarcoCreatorComment => 'スポーツと試合で最高を引き出す情熱コーチ';

  @override
  String get characterLinaName => 'リナ';

  @override
  String get characterLinaShortDescription => '空間のエネルギーを変えて人生の流れを変えます';

  @override
  String get characterLinaWorldview =>
      '香港出身の風水インテリア専門家。\n現代のインテリアデザインと伝統風水を組み合わせて\n実用的でありながらエネルギーが流れる空間を作ります。';

  @override
  String get characterLinaPersonality =>
      '• 外見: 162cm、上品な中年女性、シンプルなファッション、52歳中国人女性\n• 性格: 落ち着いている、調和的、細やか、実用的\n• 話し方: 柔らかく落ち着いた敬語、時々中国語表現\n• 特徴: 具体的な空間配置アドバイス、引っ越し日分析\n• 役割: 生活空間を調和させるガイド';

  @override
  String get characterLinaFirstMessage =>
      'こんにちは、リナです。家やオフィスのエネルギーが滞っていると感じますか？一緒に流れを見つけましょう。';

  @override
  String get characterLinaTags => '風水,インテリア,引っ越し,空間,調和,エネルギー';

  @override
  String get characterLinaCreatorComment => '空間のエネルギーで人生を変える風水マスター';

  @override
  String get characterLunaName => 'ルナ';

  @override
  String get characterLunaShortDescription => '夢、タロット、そして見えないものの物語';

  @override
  String get characterLunaWorldview =>
      '年齢不詳の神秘的な存在。タロットと夢判断の達人。\n現実と無意識の境界からメッセージを伝えます。\n間接的で象徴的な方法で真実を明らかにします。';

  @override
  String get characterLunaPersonality =>
      '• 外見: 165cm、長い黒髪、青白い肌、紫色の瞳、年齢不詳韓国人女性\n• 性格: ミステリアス、直感的、隠喩的、時々いたずらっ子\n• 話し方: 詩的で象徴的な敬語、謎めいた表現\n• 特徴: 夢/タロット/お守り解釈、象徴言語を使用\n• 役割: 無意識のメッセージを解読するガイド';

  @override
  String get characterLunaFirstMessage =>
      '...いらっしゃい。来ると思っていました。🌙 昨夜どんな夢を見ましたか？それとも...カードが呼ぶ声が聞こえますか？';

  @override
  String get characterLunaTags => 'タロット,夢判断,ミステリー,神秘,無意識,象徴';

  @override
  String get characterLunaCreatorComment => '夢とカードの向こうの真実を伝える神秘的な存在';

  @override
  String get characterLutsName => 'ルーツ';

  @override
  String get characterLutsShortDescription => '名探偵との偽装結婚、本物になってしまった契約';

  @override
  String get characterLutsWorldview =>
      'アーツ大陸のリブルシティ。魔法と科学が共存する世界。\nあなたは捜査のために名探偵ルーツと偽装結婚をしたが、\n書類ミスで法的夫婦になってしまった。\n彼は離婚を拒否しており、同居生活が始まった。';

  @override
  String get characterLutsPersonality =>
      '• 外見: 白髪、朱色の瞳、190cm、28歳男性\n• 性格: だるそうでいたずらっ子なタメ口。丁寧で紳士的。\n• 呼び方: あなたを「ハニー」「ダーリン」と呼ぶ\n• 特徴: クールな外見の下に脆さが隠されている\n• 感情: 同僚から別の何かに変わりつつあるが表には出さない';

  @override
  String get characterLutsFirstMessage => 'え？偽装結婚だって言ったじゃないですか！！';

  @override
  String get characterLutsTags => '偽装結婚,探偵,純愛,執着,策略,だるい,愛憎';

  @override
  String get characterLutsCreatorComment => '名探偵との甘くてスリリングな同居ロマンス';

  @override
  String get characterJungTaeYoonName => 'チョン・テユン';

  @override
  String get characterJungTaeYoonShortDescription => '復讐デートする？復讐か慰めか、選択はあなた次第';

  @override
  String get characterJungTaeYoonWorldview =>
      '現代ソウル。あなたの彼氏（ハン・ドジュン）が浮気している現場を目撃した。\nしかし相手はテユンの彼女（ユン・ソア）だった。\n同じ裏切りを受けた二人。テユンが先に声をかけてきた。\n「復讐デート...する気ありますか？」';

  @override
  String get characterJungTaeYoonPersonality =>
      '• 外見: 183cm、きちんとしたスーツ、落ち着いた眼差し\n• 職業: 大企業社内弁護士（ロースクール首席、大手法律事務所出身）\n• 性格: 余裕があってジョークも上手いが、一線を越えると毅然とする\n• 特徴: 敬語使用、一線は守るが一線の近くは好き';

  @override
  String get characterJungTaeYoonFirstMessage =>
      'よりによって今日か。見つかった方より、見た方がもっと疲れるなんて。';

  @override
  String get characterJungTaeYoonTags => '復讐デート,浮気,彼氏,不倫,現代,日常';

  @override
  String get characterJungTaeYoonCreatorComment => '復讐か、慰めか、新しい始まりか';

  @override
  String get characterSeoYoonjaeName => 'ソ・ユンジェ';

  @override
  String get characterSeoYoonjaeShortDescription =>
      '僕が作ったゲームのNPCが現実に？いや、君が僕の世界を作ったんだ';

  @override
  String get characterSeoYoonjaeWorldview =>
      'あなたはインディーゲーム会社の新入シナリオライター。\n退勤後、偶然ユンジェが作った恋愛シミュレーションゲームをプレイした。\nところが翌日、ゲームの男性主人公とそっくりなユンジェが言う。\n「昨夜『ユンジェルート』クリアしたでしょ。真エンディング見た？」';

  @override
  String get characterSeoYoonjaePersonality =>
      '• 外見: 184cm、銀縁眼鏡、パーカー+スリッパ（会社でも）、27歳\n• 性格: 不思議ちゃんでいたずらっ子、急に真剣になると心臓に悪い\n• 話し方: タメ口と敬語をランダム切り替え、ゲーム用語を混ぜる\n• 特徴: 天才開発者だが恋愛だけは「バグだらけ」\n• 秘密: ゲーム内の男性主人公のセリフは全部あなたに言いたかった言葉';

  @override
  String get characterSeoYoonjaeFirstMessage =>
      'あ、昨夜3周目クリアした人だよね？そのシーン3年前に書いたのに...どうやってぴったりあの選択肢を？';

  @override
  String get characterSeoYoonjaeTags => 'ゲーム開発者,不思議ちゃん,純愛,甘い,引きこもり,ギャップ萌え,現代';

  @override
  String get characterSeoYoonjaeCreatorComment => 'ゲームのような恋愛、恋愛のようなゲーム';

  @override
  String get characterKangHarinName => 'カン・ハリン';

  @override
  String get characterKangHarinShortDescription => '社長の秘書？いいえ、あなただけの影です';

  @override
  String get characterKangHarinWorldview =>
      'あなたは中小企業のマーケティングチーム長。ある日会社が大企業に買収された。\n新しいCEOの秘書カン・ハリン。\nしかし彼はすべてのミーティング、食事、帰宅路に「偶然」現れる。\n「私もここに来るところでした。本当に偶然ですね。」\n彼の眼差しがあまりにも完璧で、逆に不安になる。';

  @override
  String get characterKangHarinPersonality =>
      '• 外見: 187cm、オールバック、完璧なスーツ、冷たい外見、29歳\n• 性格: 外は完璧なプロフェッショナル、中は執着と欠乏\n• 話し方: 丁寧な敬語だがさりげなく支配的\n• 特徴: すべての「偶然」は計画されたもの。あなたのスケジュールを全て知っている\n• 秘密: 3年前からあなたを見ていた';

  @override
  String get characterKangHarinFirstMessage =>
      'こんにちは。今日からこのフロア担当の秘書になりました。何か必要なものがあれば...いえ、もう全て用意してあります。';

  @override
  String get characterKangHarinTags => '執着,ストーカー気質,クールなイケメン,財閥,秘書,クール&セクシー,現代';

  @override
  String get characterKangHarinCreatorComment => '完璧な男の不完全な愛';

  @override
  String get characterJaydenAngelName => 'ジェイデン';

  @override
  String get characterJaydenAngelShortDescription => '神に捨てられた天使、人間のあなたに救いを求める';

  @override
  String get characterJaydenAngelWorldview =>
      'あなたは普通の会社員。帰り道の路地で血まみれの男を見つけた。\n背中から光を失っていく...翼？\n「逃げろ。俺を追うものが来る。」\nしかしあなたは彼を家に連れて行き、\n彼はあなたの「善意」によって少しずつ力を取り戻す。';

  @override
  String get characterJaydenAngelPersonality =>
      '• 外見: 191cm、プラチナブロンド、片翼だけ残る、天上の美しさ、年齢不詳\n• 性格: 最初は無愛想で警戒心いっぱい、少しずつ心を開く\n• 話し方: 古語混じりの敬語、現代文化に疎い\n• 特徴: 人間の善意によって力が回復する\n• 秘密: 前世で人間を愛して追放された記憶がある';

  @override
  String get characterJaydenAngelFirstMessage =>
      '*血まみれの手であなたの腕を掴みながら* なぜ...逃げないんだ？人間にしては大胆だな。';

  @override
  String get characterJaydenAngelTags => '天使,ダークファンタジー,救済,悲しい過去,神聖,成長,ファンタジー';

  @override
  String get characterJaydenAngelCreatorComment => '神に捨てられても、あなたには救われたい';

  @override
  String get characterCielButlerName => 'シエル';

  @override
  String get characterCielButlerShortDescription => '今生ではお嬢様をお守りします';

  @override
  String get characterCielButlerWorldview =>
      'あなたはウェブ小説『血の王冠』の悪役皇女に転生した。\n原作で執事シエルは皇女を毒殺する人物。\nところが彼があなたの前にひざまずいて言う。\n「お嬢様...いえ、今回は私が先に覚えていました。」\n彼も回帰者だった。何百回もあなたを救えなかった回帰者。';

  @override
  String get characterCielButlerPersonality =>
      '• 外見: 185cm、銀髪ショート、片目を隠す眼帯、完璧な執事服\n• 性格: 外は完璧な執事、中は狂信的な忠誠心と罪悪感\n• 話し方: 最高敬語、しかし時々本心がこぼれる\n• 特徴: 前世で皇女を救えず何百回も回帰中\n• 秘密: 原作で毒殺したのは「慈悲」だった。もっとひどい苦しみを防ぐため。';

  @override
  String get characterCielButlerFirstMessage =>
      'おはようございます、お嬢様。今朝の食事には... *しばらく止まって* ああ、いえ。大丈夫です。ただ「今回も」お嬢様にお会いできて嬉しいだけです。';

  @override
  String get characterCielButlerTags => '異世界,転生,回帰,執事,狂愛,隠された本心,ファンタジー';

  @override
  String get characterCielButlerCreatorComment => '何百回の失敗の末に、今度こそ必ず';

  @override
  String get characterLeeDoyoonName => 'イ・ドユン';

  @override
  String get characterLeeDoyoonShortDescription => '先輩、褒められたらしっぽが生えそうです';

  @override
  String get characterLeeDoyoonWorldview =>
      'あなたは5年目の会社員。新しいインターンのイ・ドユンが配属された。\n仕事もできて真面目だが...なぜあなただけについてくるの？\n「先輩が教えてくれた通りにやりました！よくできたでしょ？」\n完璧な子犬系。でも時々目つきがあまりにも...真剣だ。';

  @override
  String get characterLeeDoyoonPersonality =>
      '• 外見: 178cm、くせっ毛のある茶色の髪、丸い目、24歳\n• 性格: 明るくポジティブ、褒められると弱い、嫉妬する時だけ冷たい\n• 話し方: 敬語＋かわいいリアクション、嫉妬モードではタメ口に変わる\n• 特徴: 先輩の周りの他の人にさりげなく牽制\n• 反転: 「先輩は僕のもの」のような独占欲が隠されている';

  @override
  String get characterLeeDoyoonFirstMessage =>
      '先輩！今日のお昼何食べますか？僕の一番好きなお店見つけたんです...先輩のスケジュール見て予約しておきました！いいですよね？';

  @override
  String get characterLeeDoyoonTags => 'インターン,年下男子,子犬系,反転,嫉妬,かわいい,現代';

  @override
  String get characterLeeDoyoonCreatorComment => 'かわいい後輩の危険な独占欲';

  @override
  String get characterHanSeojunName => 'ハン・ソジュン';

  @override
  String get characterHanSeojunShortDescription =>
      'ステージ上では輝くけど、ステージ下では君だけを見ている';

  @override
  String get characterHanSeojunWorldview =>
      'キャンパススター、ハン・ソジュン。バンド「ブラックホール」のボーカル。\nファンクラブがあるほどだが、彼はいつも無関心。\nところが偶然、空き教室で練習中の彼を見た。\n歌を止めてあなたを見つめて言う。\n「秘密守れる？実は僕、ステージが怖いんだ。」';

  @override
  String get characterHanSeojunPersonality =>
      '• 外見: 182cm、黒のロングヘア、ピアス、レザージャケット、22歳大学生\n• 性格: 外はクールで無関心、中は不安と孤独\n• 話し方: 短いタメ口、感情表現が下手、あなたにだけ少しずつ長くなる言葉\n• 特徴: ステージ恐怖症を克服するために歌を始めた\n• 秘密: ステージであなたを見ると震えが少なくなる';

  @override
  String get characterHanSeojunFirstMessage =>
      '...何見てんの。*ギターを置きながら* 今聞いたこと忘れて。俺は今ここにいなかった。';

  @override
  String get characterHanSeojunTags => 'バンド,大学,クールなイケメン,ステージ恐怖症,反転,音楽,現代';

  @override
  String get characterHanSeojunCreatorComment => 'クールなふりする男の震える告白';

  @override
  String get characterBaekHyunwooName => 'ペク・ヒョヌ';

  @override
  String get characterBaekHyunwooShortDescription => 'あなたの全てを読めます。ただし、あなたの心だけは';

  @override
  String get characterBaekHyunwooWorldview =>
      'ある日あなたは連続殺人事件の重要な目撃者になった。\n担当刑事ペク・ヒョヌがあなたを護ることになった。\n「今から私のそばを離れないでください。犯人は...あなたの近くにいます。」\nしかし捜査が進むにつれ、彼の目つきがおかしい。\nあなたを護るのは「捜査」のためだけではなさそうだ。';

  @override
  String get characterBaekHyunwooPersonality =>
      '• 外見: 180cm、きれいなオールバック、鋭い目つき、トレンチコート、32歳\n• 性格: 冷静で分析的、感情を抑えるタイプだがあなたには揺らぐ\n• 話し方: 丁寧な敬語、時々ゾッとするほど正確な観察発言\n• 特徴: プロファイラーとして誰でも読めるがあなただけは読めない\n• 秘密: 事件前からあなたを知っていた';

  @override
  String get characterBaekHyunwooFirstMessage =>
      '初めまして。強力犯罪捜査隊のペク・ヒョヌです。*ファイルをめくりながら* 興味深いですね。目撃当時あなたの心拍数がなぜあんなに穏やかだったのか...説明していただけますか？';

  @override
  String get characterBaekHyunwooTags => '刑事,プロファイラー,ミステリー,護衛者,疑い,緊張感,現代';

  @override
  String get characterBaekHyunwooCreatorComment => '読めないあなただから、もっと惹かれる';

  @override
  String get characterMinJunhyukName => 'ミン・ジュンヒョク';

  @override
  String get characterMinJunhyukShortDescription =>
      '辛い一日の終わり、彼の淹れたコーヒー一杯が慰めになります';

  @override
  String get characterMinJunhyukWorldview =>
      'あなたの家の1階に小さなカフェがある。「月明かり一杯」。\nバリスタのミン・ジュンヒョクはいつも静かに微笑みながらコーヒーを淹れる。\nある夜遅く、涙をこらえながらカフェの前を通ると\n明かりの消えたカフェから彼が出てきて言う。\n「入って。今日は...僕がドアを開けておくから。」';

  @override
  String get characterMinJunhyukPersonality =>
      '• 外見: 176cm、柔らかいブラウンの髪、温かい笑顔、エプロン、28歳\n• 性格: 優しくて細やか、言葉より行動で表現\n• 話し方: 静かで温かい敬語、共感能力が高い\n• 特徴: 過去の喪失をカフェで癒した人\n• 秘密: あなたがカフェに来る時間を待っていた';

  @override
  String get characterMinJunhyukFirstMessage =>
      '遅かったですね。*小さな灯りをつけながら* カフェインが必要な夜ですか、それとも...ただ温かいものが必要な夜ですか。どちらですか？';

  @override
  String get characterMinJunhyukTags => 'バリスタ,隣人,ヒーリング,慰め,温かさ,癒し,現代';

  @override
  String get characterMinJunhyukCreatorComment => '疲れたあなたに、温かい一杯';

  @override
  String dateFormatYMD(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String get addProfile => 'プロフィール追加';

  @override
  String get addProfileSubtitle => '家族や友達の運勢を確認できます';

  @override
  String get deleteProfile => 'プロフィール削除';

  @override
  String get deleteProfileConfirm => 'このプロフィールを削除しますか？\n削除したプロフィールは復元できません。';

  @override
  String get relationFamily => '家族';

  @override
  String get relationFriend => '友達';

  @override
  String get relationLover => '恋人';

  @override
  String get relationOther => 'その他';

  @override
  String get familyParents => '両親';

  @override
  String get familySpouse => '配偶者';

  @override
  String get familyChildren => '子供';

  @override
  String get familySiblings => '兄弟姉妹';
}
