import Intents
import SwiftUI

// MARK: - Check Daily Fortune Intent
class CheckDailyFortuneIntent: INIntent {
    @NSManaged var userName: String?
}

// MARK: - Check Compatibility Intent
class CheckCompatibilityIntent: INIntent {
    @NSManaged var userName: String?
    @NSManaged var partnerName: String?
}

// MARK: - Check Lucky Numbers Intent
class CheckLuckyNumbersIntent: INIntent {
    @NSManaged var userName: String?
    @NSManaged var date: Date?
}

// MARK: - Intent Handler Protocol
protocol FortuneIntentHandling: CheckDailyFortuneIntentHandling, CheckCompatibilityIntentHandling, CheckLuckyNumbersIntentHandling {}

// MARK: - Check Daily Fortune Intent Handling
protocol CheckDailyFortuneIntentHandling {
    func handle(intent: CheckDailyFortuneIntent, completion: @escaping (CheckDailyFortuneIntentResponse) -> Void)
    func resolveUserName(for intent: CheckDailyFortuneIntent, with completion: @escaping (INStringResolutionResult) -> Void)
}

// MARK: - Check Compatibility Intent Handling
protocol CheckCompatibilityIntentHandling {
    func handle(intent: CheckCompatibilityIntent, completion: @escaping (CheckCompatibilityIntentResponse) -> Void)
    func resolveUserName(for intent: CheckCompatibilityIntent, with completion: @escaping (INStringResolutionResult) -> Void)
    func resolvePartnerName(for intent: CheckCompatibilityIntent, with completion: @escaping (INStringResolutionResult) -> Void)
}

// MARK: - Check Lucky Numbers Intent Handling
protocol CheckLuckyNumbersIntentHandling {
    func handle(intent: CheckLuckyNumbersIntent, completion: @escaping (CheckLuckyNumbersIntentResponse) -> Void)
    func resolveUserName(for intent: CheckLuckyNumbersIntent, with completion: @escaping (INStringResolutionResult) -> Void)
    func resolveDate(for intent: CheckLuckyNumbersIntent, with completion: @escaping (INDateComponentsRangeResolutionResult) -> Void)
}

// MARK: - Intent Responses
class CheckDailyFortuneIntentResponse: INIntentResponse {
    @NSManaged var fortuneScore: NSNumber?
    @NSManaged var fortuneMessage: String?
    @NSManaged var luckyColor: String?
    @NSManaged var luckyNumber: NSNumber?
    
    var code: CheckDailyFortuneIntentResponseCode = .success
}

enum CheckDailyFortuneIntentResponseCode: Int {
    case unspecified = 0
    case ready
    case continueInApp
    case inProgress
    case success
    case failure
    case failureRequiringAppLaunch
}

class CheckCompatibilityIntentResponse: INIntentResponse {
    @NSManaged var compatibilityScore: NSNumber?
    @NSManaged var message: String?
    @NSManaged var advice: String?
    
    var code: CheckCompatibilityIntentResponseCode = .success
}

enum CheckCompatibilityIntentResponseCode: Int {
    case unspecified = 0
    case ready
    case continueInApp
    case inProgress
    case success
    case failure
    case failureRequiringAppLaunch
}

class CheckLuckyNumbersIntentResponse: INIntentResponse {
    @NSManaged var luckyNumbers: [NSNumber]?
    @NSManaged var message: String?
    
    var code: CheckLuckyNumbersIntentResponseCode = .success
}

enum CheckLuckyNumbersIntentResponseCode: Int {
    case unspecified = 0
    case ready
    case continueInApp
    case inProgress
    case success
    case failure
    case failureRequiringAppLaunch
}