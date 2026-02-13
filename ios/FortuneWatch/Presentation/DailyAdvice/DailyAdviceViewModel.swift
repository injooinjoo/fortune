import Foundation
import SwiftUI
import Combine

// MARK: - Daily Advice ViewModel

@MainActor
final class DailyAdviceViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var dailyAdvice: DailyAdviceData?
    @Published var isLoading = false

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
                self?.dailyAdvice = state.dailyAdvice
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var hasAdvice: Bool {
        dailyAdvice != nil
    }

    var doAdvice: String {
        dailyAdvice?.doAdvice ?? ""
    }

    var dontAdvice: String {
        dailyAdvice?.dontAdvice ?? ""
    }

    var focusArea: String {
        dailyAdvice?.focusArea ?? ""
    }

    var motivationalQuote: String {
        dailyAdvice?.motivationalQuote ?? ""
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}
