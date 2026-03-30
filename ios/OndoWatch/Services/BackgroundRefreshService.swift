import Foundation
import WatchKit
import WidgetKit

// MARK: - Background Refresh Service

/// Manages background refresh tasks for Watch app
final class BackgroundRefreshService {

    // MARK: - Singleton

    static let shared = BackgroundRefreshService()

    // MARK: - Constants

    private enum Constants {
        static let refreshInterval: TimeInterval = 6 * 60 * 60 // 6 hours
        static let backgroundTaskIdentifier = "com.beyond.fortune.watch.refresh"
    }

    // MARK: - Init

    private init() {}

    // MARK: - Schedule Background Refresh

    /// Schedule next background refresh
    func scheduleBackgroundRefresh() {
        let nextUpdate = calculateNextRefreshDate()

        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: nextUpdate,
            userInfo: nil
        ) { error in
            if let error = error {
                print("Failed to schedule background refresh: \(error)")
            } else {
                print("Background refresh scheduled for: \(nextUpdate)")
            }
        }
    }

    /// Calculate next refresh date based on time slots
    private func calculateNextRefreshDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)

        // Refresh at time slot boundaries: 6AM, 12PM, 6PM
        var nextHour: Int
        if hour < 6 {
            nextHour = 6
        } else if hour < 12 {
            nextHour = 12
        } else if hour < 18 {
            nextHour = 18
        } else {
            nextHour = 6 // Next day 6AM
        }

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = nextHour
        components.minute = 0
        components.second = 0

        var nextDate = calendar.date(from: components) ?? now

        // Handle next day case
        if nextHour == 6 && hour >= 18 {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }

        return nextDate
    }

    // MARK: - Handle Background Tasks

    /// Handle background refresh task
    func handleBackgroundTasks(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let refreshTask as WKApplicationRefreshBackgroundTask:
                handleApplicationRefresh(refreshTask)

            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                handleConnectivityRefresh(connectivityTask)

            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                handleSnapshotRefresh(snapshotTask)

            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    // MARK: - Task Handlers

    private func handleApplicationRefresh(_ task: WKApplicationRefreshBackgroundTask) {
        // Reload data from App Groups
        Task { @MainActor in
            let repository = Container.shared.fortuneRepository
            repository.loadAllData()

            // Refresh complications
            refreshComplications()

            // Schedule next refresh
            scheduleBackgroundRefresh()

            // Complete task
            task.setTaskCompletedWithSnapshot(true)
        }
    }

    private func handleConnectivityRefresh(_ task: WKWatchConnectivityRefreshBackgroundTask) {
        // Handle data received from iPhone
        Task { @MainActor in
            let repository = Container.shared.fortuneRepository
            repository.loadAllData()

            // Refresh complications
            refreshComplications()

            task.setTaskCompletedWithSnapshot(true)
        }
    }

    private func handleSnapshotRefresh(_ task: WKSnapshotRefreshBackgroundTask) {
        // Update UI snapshot
        Task { @MainActor in
            let repository = Container.shared.fortuneRepository
            repository.loadAllData()

            task.setTaskCompletedWithSnapshot(true)
        }
    }

    // MARK: - Complication Refresh

    /// Refresh all complications
    func refreshComplications() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Refresh specific complication
    func refreshComplication(kind: String) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }
}

// MARK: - Extension Delegate Support

/// Protocol for handling background tasks in ExtensionDelegate
protocol BackgroundTaskHandler {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>)
}

extension BackgroundRefreshService: BackgroundTaskHandler {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        handleBackgroundTasks(backgroundTasks)
    }
}
