import SwiftUI

// MARK: - Fortune Watch App

@main
struct FortuneWatchApp: App {
    @StateObject private var container = Container.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .withContainer(container)
                .onAppear {
                    // Initialize WatchConnectivity
                    _ = container.watchConnectivityService
                }
        }
    }
}
