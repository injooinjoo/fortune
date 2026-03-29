import Foundation
import SwiftUI

// MARK: - Dependency Container

/// Dependency injection container for Fortune Watch app
@MainActor
final class Container: ObservableObject {

    // MARK: - Shared Instance

    static let shared = Container()

    // MARK: - Services

    lazy var watchConnectivityService: WatchConnectivityService = {
        WatchConnectivityService()
    }()

    // MARK: - Data Sources

    lazy var appGroupsDataSource: AppGroupsDataSource = {
        AppGroupsDataSource()
    }()

    // MARK: - Repositories

    lazy var fortuneRepository: FortuneRepository = {
        FortuneRepository(
            appGroupsDataSource: appGroupsDataSource,
            connectivityService: watchConnectivityService
        )
    }()

    // MARK: - Init

    private init() {}

    // MARK: - Factory Methods

    /// Create MainViewModel
    func makeMainViewModel() -> MainViewModel {
        MainViewModel(repository: fortuneRepository)
    }

    /// Create DailyFortuneViewModel
    func makeDailyFortuneViewModel() -> DailyFortuneViewModel {
        DailyFortuneViewModel(repository: fortuneRepository)
    }

    /// Create BiorhythmViewModel
    func makeBiorhythmViewModel() -> BiorhythmViewModel {
        BiorhythmViewModel(repository: fortuneRepository)
    }

    /// Create LuckyItemsViewModel
    func makeLuckyItemsViewModel() -> LuckyItemsViewModel {
        LuckyItemsViewModel(repository: fortuneRepository)
    }

    /// Create TimeSlotViewModel
    func makeTimeSlotViewModel() -> TimeSlotViewModel {
        TimeSlotViewModel(repository: fortuneRepository)
    }

    /// Create TarotViewModel
    func makeTarotViewModel() -> TarotViewModel {
        TarotViewModel(repository: fortuneRepository)
    }

    /// Create CompatibilityViewModel
    func makeCompatibilityViewModel() -> CompatibilityViewModel {
        CompatibilityViewModel(repository: fortuneRepository)
    }

    /// Create DailyAdviceViewModel
    func makeDailyAdviceViewModel() -> DailyAdviceViewModel {
        DailyAdviceViewModel(repository: fortuneRepository)
    }
}

// MARK: - Environment Key

private struct ContainerKey: EnvironmentKey {
    @MainActor
    static let defaultValue = Container.shared
}

extension EnvironmentValues {
    var container: Container {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withContainer(_ container: Container) -> some View {
        environment(\.container, container)
    }
}
