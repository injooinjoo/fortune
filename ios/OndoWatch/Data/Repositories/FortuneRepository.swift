import Foundation
import Combine

// MARK: - Fortune Repository

/// Central repository for fortune data, combining App Groups and WatchConnectivity sources
@MainActor
final class FortuneRepository: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state = WatchFortuneState.initial

    // MARK: - Dependencies

    private let appGroupsDataSource: AppGroupsDataSource
    private let connectivityService: WatchConnectivityService?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        appGroupsDataSource: AppGroupsDataSource = AppGroupsDataSource(),
        connectivityService: WatchConnectivityService? = nil
    ) {
        self.appGroupsDataSource = appGroupsDataSource
        self.connectivityService = connectivityService
        setupConnectivityObserving()
    }

    // MARK: - Setup

    private func setupConnectivityObserving() {
        connectivityService?.$latestFortuneData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fortuneData in
                self?.state.fortune = fortuneData
            }
            .store(in: &cancellables)

        connectivityService?.$isReachable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReachable in
                if isReachable {
                    self?.requestRemoteUpdate()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Load All Data

    /// Load all fortune data from App Groups
    func loadAllData() {
        state.isLoading = true
        state.error = nil

        // Load from App Groups (synchronous)
        state.fortune = appGroupsDataSource.loadFortuneData()
        state.biorhythm = appGroupsDataSource.loadBiorhythmData()
        state.luckyItems = appGroupsDataSource.loadLuckyItemsData()
        state.timeSlots = appGroupsDataSource.loadTimeSlots()
        state.currentTimeSlot = appGroupsDataSource.getCurrentTimeSlot()
        state.tarotCard = appGroupsDataSource.loadTarotData()
        state.compatibility = appGroupsDataSource.loadCompatibilityData()
        state.dailyAdvice = appGroupsDataSource.loadDailyAdviceData()

        state.isLoading = false
    }

    // MARK: - Refresh

    /// Refresh data - tries WatchConnectivity first, falls back to App Groups
    func refresh() async {
        state.isLoading = true
        state.error = nil

        // Try to get fresh data from iPhone via WatchConnectivity
        if let service = connectivityService, service.isReachable {
            do {
                try await service.requestFortuneUpdate()
                // Wait briefly for response
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            } catch {
                // Fall back to App Groups
                print("WatchConnectivity failed, falling back to App Groups: \(error)")
            }
        }

        // Always reload from App Groups (may have been updated by connectivity)
        loadAllData()
    }

    /// Request update from iPhone if reachable
    func requestRemoteUpdate() {
        guard let service = connectivityService, service.isReachable else { return }
        Task {
            try? await service.requestFortuneUpdate()
        }
    }

    // MARK: - Individual Data Access

    var fortune: FortuneData {
        state.fortune
    }

    var biorhythm: BiorhythmData {
        state.biorhythm
    }

    var luckyItems: LuckyItemsData {
        state.luckyItems
    }

    var timeSlots: [TimeSlotData] {
        state.timeSlots
    }

    var currentTimeSlot: TimeSlotData? {
        state.currentTimeSlot
    }

    var tarotCard: TarotCardData? {
        state.tarotCard
    }

    var compatibility: CompatibilityData? {
        state.compatibility
    }

    var dailyAdvice: DailyAdviceData? {
        state.dailyAdvice
    }

    var isDataValid: Bool {
        state.fortune.isValid
    }

    var isLoading: Bool {
        state.isLoading
    }
}
