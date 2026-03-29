import Foundation
import SwiftUI
import Combine

// MARK: - Main ViewModel

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedTab: FortuneTab = .daily
    @Published var isLoading = false
    @Published var error: String?
    @Published var isDataValid = false

    // MARK: - Dependencies

    private let repository: FortuneRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(repository: FortuneRepository) {
        self.repository = repository
        setupObserving()
    }

    // MARK: - Setup

    private func setupObserving() {
        repository.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isLoading = state.isLoading
                self?.error = state.error
                self?.isDataValid = state.fortune.isValid
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func onAppear() {
        repository.loadAllData()
    }

    func refresh() async {
        await repository.refresh()
    }

    // MARK: - Tab Helpers

    /// Available tabs based on data availability
    var availableTabs: [FortuneTab] {
        var tabs: [FortuneTab] = [.daily, .biorhythm, .luckyItems, .timeSlot]

        // Add new features if data available
        if repository.tarotCard != nil {
            tabs.append(.tarot)
        }
        if repository.compatibility != nil {
            tabs.append(.compatibility)
        }
        if repository.dailyAdvice != nil {
            tabs.append(.advice)
        }

        return tabs
    }
}
