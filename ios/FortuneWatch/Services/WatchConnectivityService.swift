import Foundation
import WatchConnectivity
import Combine

// MARK: - Watch Connectivity Service

/// Manages real-time communication between Watch and iPhone via WatchConnectivity
final class WatchConnectivityService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var isReachable = false
    @Published var latestFortuneData: FortuneData?
    @Published var connectionState: ConnectionState = .disconnected

    // MARK: - Types

    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case reachable
    }

    // MARK: - Private Properties

    private var session: WCSession?
    private var pendingRequests: [String: CheckedContinuation<Void, Error>] = [:]

    // MARK: - Message Keys

    private enum MessageKey {
        static let request = "request"
        static let fortuneUpdate = "fortune_update"
        static let response = "response"

        // Response data keys
        static let overallScore = "overall_score"
        static let overallGrade = "overall_grade"
        static let overallMessage = "overall_message"
        static let validDate = "valid_date"
        static let lastUpdated = "last_updated"
    }

    // MARK: - Init

    override init() {
        super.init()
        setupSession()
    }

    // MARK: - Setup

    private func setupSession() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity not supported")
            return
        }

        session = WCSession.default
        session?.delegate = self
        session?.activate()
        connectionState = .connecting
    }

    // MARK: - Public Methods

    /// Request fortune data update from iPhone
    @MainActor
    func requestFortuneUpdate() async throws {
        guard let session = session, session.isReachable else {
            throw WatchConnectivityError.notReachable
        }

        let requestId = UUID().uuidString

        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[requestId] = continuation

            session.sendMessage(
                [MessageKey.request: MessageKey.fortuneUpdate, "requestId": requestId],
                replyHandler: { [weak self] response in
                    self?.handleFortuneResponse(response, requestId: requestId)
                },
                errorHandler: { [weak self] error in
                    self?.pendingRequests[requestId]?.resume(throwing: error)
                    self?.pendingRequests.removeValue(forKey: requestId)
                }
            )

            // Timeout after 10 seconds
            Task {
                try await Task.sleep(nanoseconds: 10_000_000_000)
                if let continuation = self.pendingRequests.removeValue(forKey: requestId) {
                    continuation.resume(throwing: WatchConnectivityError.timeout)
                }
            }
        }
    }

    /// Send application context (background transfer)
    func sendApplicationContext(_ context: [String: Any]) {
        guard let session = session else { return }

        do {
            try session.updateApplicationContext(context)
        } catch {
            print("Failed to update application context: \(error)")
        }
    }

    // MARK: - Response Handling

    private func handleFortuneResponse(_ response: [String: Any], requestId: String) {
        let fortuneData = FortuneData(
            overallScore: response[MessageKey.overallScore] as? Int ?? 0,
            overallGrade: response[MessageKey.overallGrade] as? String ?? "",
            overallMessage: response[MessageKey.overallMessage] as? String ?? "",
            validDate: response[MessageKey.validDate] as? String ?? "",
            lastUpdated: response[MessageKey.lastUpdated] as? String ?? ""
        )

        DispatchQueue.main.async {
            self.latestFortuneData = fortuneData
        }

        pendingRequests[requestId]?.resume()
        pendingRequests.removeValue(forKey: requestId)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            switch activationState {
            case .activated:
                self.connectionState = session.isReachable ? .reachable : .connected
            case .inactive, .notActivated:
                self.connectionState = .disconnected
            @unknown default:
                self.connectionState = .disconnected
            }
        }

        if let error = error {
            print("WCSession activation failed: \(error)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            self.connectionState = session.isReachable ? .reachable : .connected
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        handleIncomingMessage(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        handleIncomingMessage(message)
        replyHandler(["status": "received"])
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        // Handle background context update from iPhone
        handleIncomingMessage(applicationContext)
    }

    private func handleIncomingMessage(_ message: [String: Any]) {
        // If iPhone pushes fortune data, update our state
        if let score = message[MessageKey.overallScore] as? Int {
            let fortuneData = FortuneData(
                overallScore: score,
                overallGrade: message[MessageKey.overallGrade] as? String ?? "",
                overallMessage: message[MessageKey.overallMessage] as? String ?? "",
                validDate: message[MessageKey.validDate] as? String ?? "",
                lastUpdated: message[MessageKey.lastUpdated] as? String ?? ""
            )

            DispatchQueue.main.async {
                self.latestFortuneData = fortuneData
            }
        }
    }
}

// MARK: - Errors

enum WatchConnectivityError: Error, LocalizedError {
    case notReachable
    case timeout
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notReachable:
            return "iPhone is not reachable"
        case .timeout:
            return "Request timed out"
        case .invalidResponse:
            return "Invalid response from iPhone"
        }
    }
}
