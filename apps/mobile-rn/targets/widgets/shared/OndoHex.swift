//
//  OndoHex.swift
//  Ondo Widget Extension
//
//  SwiftUI Color를 hex 문자열("#RRGGBB")로부터 안전하게 생성하는 헬퍼.
//  유효하지 않은 입력은 violet fallback.
//

import SwiftUI

extension Color {
    /// "#RRGGBB" or "RRGGBB" → Color. 실패 시 violet fallback.
    static func ondoHex(_ hex: String?) -> Color {
        guard var cleaned = hex?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return OndoPalette.violet
        }
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let v = UInt32(cleaned, radix: 16) else {
            return OndoPalette.violet
        }
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}
