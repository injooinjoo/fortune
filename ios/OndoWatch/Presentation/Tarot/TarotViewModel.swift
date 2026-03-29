import Foundation
import SwiftUI
import Combine

// MARK: - Tarot ViewModel

@MainActor
final class TarotViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var tarotCard: TarotCardData?
    @Published var isFlipped = false
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
                self?.tarotCard = state.tarotCard
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var hasCard: Bool {
        tarotCard != nil
    }

    var cardName: String {
        tarotCard?.cardName ?? ""
    }

    var interpretation: String {
        tarotCard?.interpretation ?? ""
    }

    var advice: String {
        tarotCard?.advice ?? ""
    }

    var isReversed: Bool {
        tarotCard?.isReversed ?? false
    }

    var cardStatusText: String {
        guard let card = tarotCard else { return "" }
        return card.isReversed ? "역방향" : "정방향"
    }

    // MARK: - Actions

    func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isFlipped.toggle()
        }
    }

    func drawNewCard() {
        // Request new tarot card from iPhone
        Task {
            await repository.refresh()
            isFlipped = false
        }
    }

    func refresh() async {
        await repository.refresh()
    }
}
