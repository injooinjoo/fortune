import Foundation
import WatchKit

// MARK: - Haptic Manager

/// Manages haptic feedback for Watch app
final class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Private Properties

    private let device = WKInterfaceDevice.current()

    // MARK: - Init

    private init() {}

    // MARK: - Play Haptics

    /// Play a simple click haptic
    func click() {
        device.play(.click)
    }

    /// Play a success haptic
    func success() {
        device.play(.success)
    }

    /// Play a failure haptic
    func failure() {
        device.play(.failure)
    }

    /// Play a notification haptic
    func notification() {
        device.play(.notification)
    }

    /// Play direction up haptic (for scrolling)
    func directionUp() {
        device.play(.directionUp)
    }

    /// Play direction down haptic (for scrolling)
    func directionDown() {
        device.play(.directionDown)
    }

    /// Play start haptic
    func start() {
        device.play(.start)
    }

    /// Play stop haptic
    func stop() {
        device.play(.stop)
    }

    /// Play retry haptic
    func retry() {
        device.play(.retry)
    }

    // MARK: - Grade-based Haptics

    /// Play haptic based on fortune grade
    func playGradeHaptic(for grade: String) {
        switch grade {
        case "대길":
            // Double success for great fortune
            device.play(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.device.play(.success)
            }
        case "길":
            device.play(.success)
        case "평":
            device.play(.click)
        case "흉":
            device.play(.directionDown)
        case "대흉":
            device.play(.failure)
        default:
            device.play(.click)
        }
    }

    /// Play haptic based on score
    func playScoreHaptic(for score: Int) {
        switch score {
        case 80...100:
            device.play(.success)
        case 60..<80:
            device.play(.click)
        case 40..<60:
            device.play(.directionUp)
        default:
            device.play(.directionDown)
        }
    }
}

// MARK: - View Extension for Haptics

import SwiftUI

extension View {
    /// Add tap gesture with haptic feedback
    func onTapWithHaptic(
        _ hapticType: HapticType = .click,
        action: @escaping () -> Void
    ) -> some View {
        self.onTapGesture {
            hapticType.play()
            action()
        }
    }
}

// MARK: - Haptic Type

enum HapticType {
    case click
    case success
    case failure
    case notification
    case directionUp
    case directionDown
    case start
    case stop

    func play() {
        let manager = HapticManager.shared
        switch self {
        case .click: manager.click()
        case .success: manager.success()
        case .failure: manager.failure()
        case .notification: manager.notification()
        case .directionUp: manager.directionUp()
        case .directionDown: manager.directionDown()
        case .start: manager.start()
        case .stop: manager.stop()
        }
    }
}
