import Foundation
import SwiftUI
import Combine

// MARK: - Biorhythm ViewModel

@MainActor
final class BiorhythmViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var biorhythm: BiorhythmData = .empty
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
                self?.biorhythm = state.biorhythm
                self?.isLoading = state.isLoading
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var physicalScore: Int {
        biorhythm.physicalScore
    }

    var emotionalScore: Int {
        biorhythm.emotionalScore
    }

    var intellectualScore: Int {
        biorhythm.intellectualScore
    }

    var overallScore: Int {
        biorhythm.overallScore
    }

    var statusMessage: String {
        biorhythm.statusMessage
    }

    var physicalStatus: String {
        biorhythm.physicalStatus
    }

    var emotionalStatus: String {
        biorhythm.emotionalStatus
    }

    var intellectualStatus: String {
        biorhythm.intellectualStatus
    }

    // MARK: - Actions

    func refresh() async {
        await repository.refresh()
    }
}
