import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = WatchDataManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Daily Summary
            DailySummaryView()
                .tag(0)

            // Tab 2: Biorhythm
            BiorhythmView()
                .tag(1)

            // Tab 3: Lucky Items
            LuckyItemsView()
                .tag(2)

            // Tab 4: Time Slot Fortune
            TimeSlotFortuneView()
                .tag(3)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            dataManager.loadAllData()
        }
    }
}

#Preview {
    ContentView()
}
