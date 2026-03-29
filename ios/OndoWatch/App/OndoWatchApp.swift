import SwiftUI

// MARK: - Fortune Watch App

@main
struct OndoWatchApp: App {
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
