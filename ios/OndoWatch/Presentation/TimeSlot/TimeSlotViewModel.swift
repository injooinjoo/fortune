import Foundation
import SwiftUI
import Combine

// MARK: - Time Slot ViewModel

@MainActor
final class TimeSlotViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var timeSlots: [TimeSlotData] = []
    @Published var currentTimeSlot: TimeSlotData?
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
                self?.timeSlots = state.timeSlots
                self?.currentTimeSlot = state.currentTimeSlot
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var currentSlotName: String {
        currentTimeSlot?.name ?? ""
    }

    var currentSlotScore: Int {
        currentTimeSlot?.score ?? 0
    }

    var currentSlotMessage: String {
        currentTimeSlot?.message ?? ""
    }

    var currentSlotIcon: String {
        currentTimeSlot?.icon ?? "clock.fill"
    }

    var currentSlotColor: Color {
        guard let slot = currentTimeSlot else { return .secondary }
        return FortuneColors.timeSlotColor(for: slot.name)
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}
