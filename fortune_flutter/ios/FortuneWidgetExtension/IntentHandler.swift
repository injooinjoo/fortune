import Intents
import Foundation

class IntentHandler: INExtension, FortuneIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // Return self for all fortune-related intents
        if intent is CheckDailyFortuneIntent ||
           intent is CheckCompatibilityIntent ||
           intent is CheckLuckyNumbersIntent {
            return self
        }
        
        return self
    }
    
    // MARK: - Check Daily Fortune Intent
    func handle(intent: CheckDailyFortuneIntent, completion: @escaping (CheckDailyFortuneIntentResponse) -> Void) {
        let response = CheckDailyFortuneIntentResponse()
        
        // Load fortune data from shared storage
        if let fortuneData = WidgetDataManager.shared.loadFortuneData() {
            response.code = .success
            response.fortuneScore = NSNumber(value: fortuneData.score)
            response.fortuneMessage = fortuneData.message
            response.luckyColor = fortuneData.luckyColor
            response.luckyNumber = NSNumber(value: fortuneData.luckyNumber)
        } else {
            // Return sample data if no stored data
            response.code = .success
            response.fortuneScore = NSNumber(value: 75)
            response.fortuneMessage = "오늘은 새로운 기회가 찾아올 예정입니다."
            response.luckyColor = "파란색"
            response.luckyNumber = NSNumber(value: 7)
        }
        
        completion(response)
    }
    
    func resolveUserName(for intent: CheckDailyFortuneIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let userName = intent.userName, !userName.isEmpty {
            completion(.success(with: userName))
        } else {
            completion(.needsValue())
        }
    }
    
    // MARK: - Check Compatibility Intent
    func handle(intent: CheckCompatibilityIntent, completion: @escaping (CheckCompatibilityIntentResponse) -> Void) {
        let response = CheckCompatibilityIntentResponse()
        
        // Load love fortune data from shared storage
        if let loveData = WidgetDataManager.shared.loadLoveFortuneData() {
            response.code = .success
            response.compatibilityScore = NSNumber(value: loveData.compatibilityScore)
            response.message = loveData.message
            response.advice = loveData.advice
        } else {
            // Calculate sample compatibility
            let score = calculateSampleCompatibility(
                userName: intent.userName ?? "사용자",
                partnerName: intent.partnerName ?? "상대방"
            )
            
            response.code = .success
            response.compatibilityScore = NSNumber(value: score)
            response.message = getCompatibilityMessage(for: score)
            response.advice = getCompatibilityAdvice(for: score)
        }
        
        completion(response)
    }
    
    func resolveUserName(for intent: CheckCompatibilityIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let userName = intent.userName, !userName.isEmpty {
            completion(.success(with: userName))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolvePartnerName(for intent: CheckCompatibilityIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let partnerName = intent.partnerName, !partnerName.isEmpty {
            completion(.success(with: partnerName))
        } else {
            completion(.needsValue())
        }
    }
    
    // MARK: - Check Lucky Numbers Intent
    func handle(intent: CheckLuckyNumbersIntent, completion: @escaping (CheckLuckyNumbersIntentResponse) -> Void) {
        let response = CheckLuckyNumbersIntentResponse()
        
        // Generate lucky numbers based on date
        let date = intent.date ?? Date()
        let luckyNumbers = generateLuckyNumbers(for: date)
        
        response.code = .success
        response.luckyNumbers = luckyNumbers.map { NSNumber(value: $0) }
        response.message = "오늘의 행운의 숫자는 \(luckyNumbers.map { String($0) }.joined(separator: ", "))입니다."
        
        completion(response)
    }
    
    func resolveUserName(for intent: CheckLuckyNumbersIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let userName = intent.userName, !userName.isEmpty {
            completion(.success(with: userName))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolveDate(for intent: CheckLuckyNumbersIntent, with completion: @escaping (INDateComponentsRangeResolutionResult) -> Void) {
        if let date = intent.date {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let dateComponentsRange = INDateComponentsRange(start: dateComponents, end: dateComponents)
            completion(.success(with: dateComponentsRange))
        } else {
            // Default to today
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let dateComponentsRange = INDateComponentsRange(start: dateComponents, end: dateComponents)
            completion(.success(with: dateComponentsRange))
        }
    }
    
    // MARK: - Helper Methods
    private func calculateSampleCompatibility(userName: String, partnerName: String) -> Int {
        // Simple sample calculation based on name lengths
        let combinedLength = userName.count + partnerName.count
        let baseScore = 50 + (combinedLength * 3) % 50
        return min(max(baseScore, 0), 100)
    }
    
    private func getCompatibilityMessage(for score: Int) -> String {
        switch score {
        case 80...100:
            return "두 분은 천생연분입니다! 서로를 위한 완벽한 파트너예요."
        case 60..<80:
            return "좋은 궁합을 가지고 있습니다. 노력하면 더 좋은 관계가 될 수 있어요."
        case 40..<60:
            return "평범한 궁합입니다. 서로를 이해하려는 노력이 필요해요."
        case 20..<40:
            return "도전적인 관계입니다. 많은 대화와 이해가 필요합니다."
        default:
            return "어려운 궁합이지만, 사랑은 모든 것을 극복할 수 있습니다."
        }
    }
    
    private func getCompatibilityAdvice(for score: Int) -> String {
        switch score {
        case 80...100:
            return "서로의 장점을 계속 인정하고 감사하는 마음을 유지하세요."
        case 60..<80:
            return "공통의 관심사를 찾고 함께 시간을 보내는 것이 중요합니다."
        case 40..<60:
            return "서로의 차이점을 인정하고 존중하는 것부터 시작하세요."
        case 20..<40:
            return "대화를 자주 나누고 서로의 감정을 솔직하게 표현하세요."
        default:
            return "전문가의 조언을 구하거나 관계 개선을 위한 노력이 필요합니다."
        }
    }
    
    private func generateLuckyNumbers(for date: Date) -> [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Generate based on date components
        var numbers: [Int] = []
        
        if let day = components.day {
            numbers.append((day * 3) % 45 + 1)
        }
        
        if let month = components.month {
            numbers.append((month * 7) % 45 + 1)
        }
        
        if let year = components.year {
            numbers.append((year % 100) % 45 + 1)
        }
        
        // Add some random elements
        let seed = date.timeIntervalSince1970
        numbers.append(Int(seed.truncatingRemainder(dividingBy: 45)) + 1)
        numbers.append((numbers.reduce(0, +) * 2) % 45 + 1)
        
        // Ensure unique numbers
        let uniqueNumbers = Array(Set(numbers)).prefix(5)
        return Array(uniqueNumbers).sorted()
    }
}