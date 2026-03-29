import Foundation
import SwiftUI
import Combine

// MARK: - Lucky Items ViewModel

@MainActor
final class LuckyItemsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var luckyItems: LuckyItemsData = .empty
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
                self?.luckyItems = state.luckyItems
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var color: String {
        luckyItems.color
    }

    var number: String {
        luckyItems.number
    }

    var direction: String {
        luckyItems.direction
    }

    var time: String {
        luckyItems.time
    }

    var item: String {
        luckyItems.item
    }

    var colorValue: Color {
        FortuneColors.luckyColor(from: luckyItems.color)
    }

    /// All lucky items as array for list display
    var items: [LuckyItemDisplay] {
        [
            LuckyItemDisplay(icon: "paintpalette.fill", label: "행운의 색상", value: color, color: colorValue),
            LuckyItemDisplay(icon: "number", label: "행운의 숫자", value: number, color: .purple),
            LuckyItemDisplay(icon: "location.north.fill", label: "행운의 방향", value: direction, color: .blue),
            LuckyItemDisplay(icon: "clock.fill", label: "행운의 시간", value: time, color: .orange),
            LuckyItemDisplay(icon: "gift.fill", label: "행운의 아이템", value: item, color: .pink)
        ].filter { !$0.value.isEmpty }
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}

// MARK: - Display Model

struct LuckyItemDisplay: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
    let color: Color
}
