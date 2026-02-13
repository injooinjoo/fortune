import Foundation
import SwiftUI
import Combine

// MARK: - Daily Fortune ViewModel

@MainActor
final class DailyFortuneViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var fortune: FortuneData = .empty
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
                self?.fortune = state.fortune
                self?.timeSlots = state.timeSlots
                self?.currentTimeSlot = state.currentTimeSlot
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var score: Int {
        fortune.overallScore
    }

    var grade: String {
        fortune.overallGrade
    }

    var gradeEmoji: String {
        fortune.gradeEmoji
    }

    var message: String {
        fortune.overallMessage
    }

    var isValid: Bool {
        fortune.isValid
    }

    var scoreColor: Color {
        FortuneColors.scoreColor(for: fortune.overallScore)
    }

    var gradeColor: Color {
        FortuneColors.gradeColor(for: fortune.overallGrade)
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}
