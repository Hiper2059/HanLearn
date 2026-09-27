//
//  Theme.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Design System: Bảng màu & Phong cách Á Đông hiện đại (Modern Oriental & Apple HIG)
//

import SwiftUI

public struct HanTheme {
    // Màu sắc chủ đạo mang phong cách ngọc bích, son chu sa và nghiên mực
    public static let jadeGreen = Color(red: 0.11, green: 0.58, blue: 0.44)       // Ngọc Bích (Phát âm đúng, chủ đề, thành công)
    public static let vermilionRed = Color(red: 0.88, green: 0.28, blue: 0.24)    // Chu Sa (Nhấn mạnh, HSK badge, streak lửa)
    public static let silkGold = Color(red: 0.95, green: 0.68, blue: 0.18)        // Vàng Hoàng Kim (Điểm thưởng, XP, sao)
    public static let inkBlack = Color(red: 0.08, green: 0.09, blue: 0.11)        // Màu Mực Tàu (Text chính, Dark background)
    public static let ricePaper = Color(red: 0.98, green: 0.97, blue: 0.95)       // Giấy Tuyên Thành (Nền sáng dịu mắt)
    public static let softCardBg = Color(red: 0.14, green: 0.15, blue: 0.18)      // Thẻ bài học chế độ tối
    
    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.11, green: 0.65, blue: 0.50), Color(red: 0.06, green: 0.42, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let goldGradient = LinearGradient(
        colors: [Color(red: 0.98, green: 0.75, blue: 0.25), Color(red: 0.90, green: 0.55, blue: 0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let fireGradient = LinearGradient(
        colors: [Color(red: 0.95, green: 0.35, blue: 0.25), Color(red: 0.80, green: 0.15, blue: 0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

public extension Font {
    static func hanTitle(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func hanBody(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func hanPinyin(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}
