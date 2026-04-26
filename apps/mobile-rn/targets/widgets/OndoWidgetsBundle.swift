//
//  OndoWidgetsBundle.swift
//  Ondo Widget Extension
//
//  @main WidgetBundle 엔트리. Sprint W1 파일럿 3종 + W2 15종 = 총 18 Widget.
//
//  @WidgetBundleBuilder 는 내부적으로 tuple limit(Swift TupleView 한계)이 있어
//  10+ 등록 시 서브 빌더로 그룹 분할 필요. fortune / story / lock / 파일럿
//  4그룹으로 나눠 등록한다.
//

import WidgetKit
import SwiftUI

@main
struct OndoWidgetsBundle: WidgetBundle {
    var body: some Widget {
        pilotWidgets
        fortuneWidgets
        storyWidgets
        lockWidgets
    }

    // MARK: W1 pilots

    @WidgetBundleBuilder
    var pilotWidgets: some Widget {
        DailyFortuneWidget()
        TarotCardWidget()
        LoveFortuneWidget()
    }

    // MARK: W2 fortune (6)

    @WidgetBundleBuilder
    var fortuneWidgets: some Widget {
        ConstellationWidget()
        LuckyItemWidget()
        WeeklyWidget()
        WealthWidget()
        HealthWidget()
        DreamWidget()
    }

    // MARK: W2 story (4)

    @WidgetBundleBuilder
    var storyWidgets: some Widget {
        StoryPreviewWidget()
        UnreadWidget()
        RecommendationWidget()
        TarotDrawWidget()
    }

    // MARK: W2 lock (5)

    @WidgetBundleBuilder
    var lockWidgets: some Widget {
        LockScoreCircleWidget()
        LockConstellationCircleWidget()
        LockUnreadCircleWidget()
        LockFortuneRectWidget()
        LockTarotRectWidget()
    }
}
