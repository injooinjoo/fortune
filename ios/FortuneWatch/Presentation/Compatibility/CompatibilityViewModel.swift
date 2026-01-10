import Foundation
import SwiftUI
import Combine

// MARK: - Compatibility ViewModel

@MainActor
final class CompatibilityViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var compatibility: CompatibilityData?
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
                self?.compatibility = state.compatibility
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var hasData: Bool {
        compatibility != nil
    }

    var partnerName: String {
        compatibility?.partnerName ?? ""
    }

    var score: Int {
        compatibility?.compatibilityScore ?? 0
    }

    var summary: String {
        compatibility?.summary ?? ""
    }

    var strengths: [String] {
        compatibility?.strengths ?? []
    }

    var challenges: [String] {
        compatibility?.challenges ?? []
    }

    var scoreColor: Color {
        FortuneColors.scoreColor(for: score)
    }

    var scoreEmoji: String {
        switch score {
        case 90...100: return "💕"
        case 70..<90: return "💗"
        case 50..<70: return "💛"
        case 30..<50: return "🤔"
        default: return "💔"
        }
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}
