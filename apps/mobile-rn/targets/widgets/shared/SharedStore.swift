//
//  SharedStore.swift
//  Ondo Widget Extension
//
//  App Group UserDefaults 얇은 래퍼. RN 쪽에서
//  react-native-shared-group-preferences 로 `widgetData` key에 JSON string
//  으로 써준 값을 읽어 Codable로 디코딩. suiteName 은 app.config.ts
//  entitlements 의 App Group ID와 동기화되어야 한다.
//

import Foundation

enum SharedStore {
    /// App Group identifier. 메인 앱 entitlements + 위젯 extension entitlements
    /// 양쪽에 동일하게 선언되어야 UserDefaults(suiteName:) 가 non-nil을 반환한다.
    static let suiteName = "group.com.beyond.fortune.widgets"

    static let defaults = UserDefaults(suiteName: suiteName)

    /// RN이 JSON string 으로 저장 → 위젯은 string 을 Data로 변환 후 decode.
    static func read<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        guard let defaults = defaults else { return nil }
        // react-native-shared-group-preferences 는 setItem 시 NSString 으로 저장.
        if let raw = defaults.string(forKey: key),
           let data = raw.data(using: .utf8) {
            return try? JSONDecoder().decode(type, from: data)
        }
        // 혹은 누군가 Data 로 저장한 경우 대비.
        if let data = defaults.data(forKey: key) {
            return try? JSONDecoder().decode(type, from: data)
        }
        return nil
    }

    static func readBundle() -> WidgetDataBundle? {
        return read("widgetData", as: WidgetDataBundle.self)
    }
}
