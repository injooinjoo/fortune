import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupIdentifier = "group.com.fortune.fortune"
    private let fortuneDataKey = "widget_fortune_daily"
    private let loveFortuneDataKey = "widget_fortune_love"
    private let lastUpdateKey = "widget_last_update"
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - Fortune Data
    func saveFortuneData(_ data: FortuneWidgetData) {
        guard let sharedDefaults = sharedDefaults else { return }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            sharedDefaults.set(encoded, forKey: fortuneDataKey)
            sharedDefaults.set(Date(), forKey: lastUpdateKey)
            
            // Reload widgets
            WidgetCenter.shared.reloadTimelines(ofKind: "FortuneWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "LockScreenFortuneWidget")
        } catch {
            print("Failed to save fortune data: \(error)")
        }
    }
    
    func loadFortuneData() -> FortuneWidgetData? {
        guard let sharedDefaults = sharedDefaults,
              let data = sharedDefaults.data(forKey: fortuneDataKey) else { return nil }
        
        do {
            return try JSONDecoder().decode(FortuneWidgetData.self, from: data)
        } catch {
            print("Failed to load fortune data: \(error)")
            return nil
        }
    }
    
    // MARK: - Love Fortune Data
    func saveLoveFortuneData(_ data: LoveFortuneWidgetData) {
        guard let sharedDefaults = sharedDefaults else { return }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            sharedDefaults.set(encoded, forKey: loveFortuneDataKey)
            
            // Reload love fortune widget
            WidgetCenter.shared.reloadTimelines(ofKind: "LoveFortuneWidget")
        } catch {
            print("Failed to save love fortune data: \(error)")
        }
    }
    
    func loadLoveFortuneData() -> LoveFortuneWidgetData? {
        guard let sharedDefaults = sharedDefaults,
              let data = sharedDefaults.data(forKey: loveFortuneDataKey) else { return nil }
        
        do {
            return try JSONDecoder().decode(LoveFortuneWidgetData.self, from: data)
        } catch {
            print("Failed to load love fortune data: \(error)")
            return nil
        }
    }
    
    // MARK: - Update Check
    func shouldUpdateWidget() -> Bool {
        guard let sharedDefaults = sharedDefaults,
              let lastUpdate = sharedDefaults.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        
        // Update if more than 1 hour has passed
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdate) / 3600
        return hoursSinceUpdate >= 1
    }
    
    // MARK: - Clear Data
    func clearAllData() {
        guard let sharedDefaults = sharedDefaults else { return }
        
        sharedDefaults.removeObject(forKey: fortuneDataKey)
        sharedDefaults.removeObject(forKey: loveFortuneDataKey)
        sharedDefaults.removeObject(forKey: lastUpdateKey)
        
        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
}