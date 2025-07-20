import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct FortuneActivityAttributes: ActivityAttributes {
    public typealias FortuneStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        // Fortune data
        var fortuneScore: Int
        var message: String
        var luckyColor: String
        var luckyNumber: Int
        
        // Activity metadata
        var lastUpdated: Date
        var activityType: ActivityType
        
        // Compatibility specific
        var partnerName: String?
        var compatibilityScore: Int?
        var compatibilityStatus: String?
        
        enum ActivityType: String, Codable {
            case dailyFortune = "daily"
            case compatibility = "compatibility"
            case fortuneReading = "reading"
        }
    }
    
    // Fixed attributes (don't change during activity)
    var userName: String
    var startTime: Date
}

// MARK: - Compatibility Activity
@available(iOS 16.2, *)
struct CompatibilityActivityAttributes: ActivityAttributes {
    public typealias CompatibilityStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var progress: Double // 0.0 to 1.0
        var status: String
        var message: String?
        var compatibilityScore: Int?
        var isComplete: Bool
    }
    
    // Fixed attributes
    var userName: String
    var partnerName: String
    var startTime: Date
}