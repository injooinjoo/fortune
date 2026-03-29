import SwiftUI

// MARK: - Main View

/// Root view with tab navigation
struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var selectedTab: FortuneTab = .daily

    init(viewModel: MainViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeMainViewModel())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Daily Fortune
            DailyFortuneView()
                .tag(FortuneTab.daily)

            // Biorhythm
            BiorhythmView()
                .tag(FortuneTab.biorhythm)

            // Lucky Items
            LuckyItemsView()
                .tag(FortuneTab.luckyItems)

            // Time Slot
            TimeSlotView()
                .tag(FortuneTab.timeSlot)

            // Tarot (NEW)
            TarotView()
                .tag(FortuneTab.tarot)

            // Compatibility (NEW)
            CompatibilityView()
                .tag(FortuneTab.compatibility)

            // Daily Advice (NEW)
            DailyAdviceView()
                .tag(FortuneTab.advice)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - Alternative List-Based Navigation (watchOS 10+)

/// List-based navigation for watchOS 10+
struct MainListView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var selectedTab: FortuneTab?

    init(viewModel: MainViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? Container.shared.makeMainViewModel())
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(viewModel.availableTabs) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
            }
            .navigationTitle("운세")
        } detail: {
            if let tab = selectedTab {
                detailView(for: tab)
            } else {
                Text("탭을 선택하세요")
                    .font(FortuneTypography.body)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            viewModel.onAppear()
            if selectedTab == nil {
                selectedTab = .daily
            }
        }
    }

    @ViewBuilder
    private func detailView(for tab: FortuneTab) -> some View {
        switch tab {
        case .daily:
            DailyFortuneView()
        case .biorhythm:
            BiorhythmView()
        case .luckyItems:
            LuckyItemsView()
        case .timeSlot:
            TimeSlotView()
        case .tarot:
            TarotView()
        case .compatibility:
            CompatibilityView()
        case .advice:
            DailyAdviceView()
        }
    }
}

// MARK: - Preview

#Preview("Tab Style") {
    MainView()
}

#Preview("List Style") {
    MainListView()
}
