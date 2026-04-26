//
//  OndoPalette.swift
//  Ondo Widget Extension
//
//  Ondo 브랜드 토큰을 SwiftUI Color로 매핑. fortuneTheme.colors.* 와
//  1:1 대응. hex 값이 변경되면 여기도 동기 수정 (향후 코드젠 고려).
//

import SwiftUI

enum OndoPalette {
    /// Ink night — 기본 배경 #0B0B10
    static let bg = Color(red: 0x0B / 255, green: 0x0B / 255, blue: 0x10 / 255)
    /// Snow — 기본 전경 #F5F6FB
    static let fg = Color(red: 0xF5 / 255, green: 0xF6 / 255, blue: 0xFB / 255)
    /// Fog — 보조 전경 #9198AA
    static let fgMuted = Color(red: 0x91 / 255, green: 0x98 / 255, blue: 0xAA / 255)
    /// Violet — 브랜드 primary #8B7BE8
    static let violet = Color(red: 0x8B / 255, green: 0x7B / 255, blue: 0xE8 / 255)
    /// Amber — 운세/타로 #E0A76B
    static let amber = Color(red: 0xE0 / 255, green: 0xA7 / 255, blue: 0x6B / 255)
    /// Rose — 연애 #FFB8C8
    static let rose = Color(red: 0xFF / 255, green: 0xB8 / 255, blue: 0xC8 / 255)
    /// Jade — 건강 #68B593
    static let jade = Color(red: 0x68 / 255, green: 0xB5 / 255, blue: 0x93 / 255)
    /// Sky — 업무 #8FB8FF
    static let sky = Color(red: 0x8F / 255, green: 0xB8 / 255, blue: 0xFF / 255)
    /// Wine — 장식 #5C1F2B
    static let wine = Color(red: 0x5C / 255, green: 0x1F / 255, blue: 0x2B / 255)
}
