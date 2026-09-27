//
//  StrokeOrderEngine.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Engine: Giải mã & Mô phỏng nét viết chữ Hán (Hanzi Stroke Order Engine)
//

import Foundation
import CoreGraphics

public enum HanziBasicStroke: String, CaseIterable {
    case heng = "Nét Hoành (横 - Nét ngang từ trái sang phải)"
    case shu = "Nét Sổ (竖 - Nét thẳng từ trên xuống)"
    case pie = "Nét Phẩy (撇 - Nét cong từ trên xuống trái)"
    case na = "Nét Mác (捺 - Nét thẳng từ trên xuống phải)"
    case dian = "Nét Chấm (点 - Dấu chấm từ trên xuống)"
    case ti = "Nét Hất (提 - Nét xiên từ dưới lên phải)"
    case zhe = "Nét Gập (折 - Nét bẻ góc chuyển hướng)"
    case gou = "Nét Móc (钩 - Móc nhọn ở cuối nét)"
}

public struct HanziStrokeData {
    public let hanzi: String
    public let totalStrokes: Int
    public let strokeNames: [String]
    public let strokePathDefinitions: [String] // SVG Path format for rendering
}

public final class StrokeOrderEngine {
    public static let shared = StrokeOrderEngine()
    
    private init() {}
    
    /// Tra cứu dữ liệu nét viết cho chữ Hán
    public func getStrokeData(for hanzi: String) -> HanziStrokeData {
        // Dữ liệu mẫu chuẩn của các chữ thông dụng trong HSK 1-3:
        switch hanzi {
        case "你":
            return HanziStrokeData(
                hanzi: "你",
                totalStrokes: 7,
                strokeNames: ["Nét Phẩy", "Nét Sổ", "Nét Phẩy", "Nét Hoành Câu", "Nét Sổ", "Nét Hoành", "Nét Móc"],
                strokePathDefinitions: ["M 30,20 L 15,60", "M 22,45 L 22,90", "M 55,20 L 35,50", "M 35,50 L 75,50 L 70,60", "M 55,50 L 55,90", "M 45,70 L 65,70", "M 70,50 L 70,85 L 60,80"]
            )
        case "好":
            return HanziStrokeData(
                hanzi: "好",
                totalStrokes: 6,
                strokeNames: ["Khửu Phẩy", "Nét Phẩy", "Nét Hoành", "Nét Hoành Phẩy", "Nét Cong Móc", "Nét Hoành"],
                strokePathDefinitions: ["M 35,25 L 25,60 L 45,60", "M 38,40 L 20,85", "M 15,55 L 45,55", "M 55,30 L 80,30 L 65,55", "M 65,55 L 75,70 L 65,85 L 55,80", "M 50,60 L 85,60"]
            )
        case "学":
            return HanziStrokeData(
                hanzi: "学",
                totalStrokes: 8,
                strokeNames: ["Nét Chấm", "Nét Chấm", "Nét Phẩy", "Nét Chấm", "Nét Hoành Câu", "Nét Hoành Phẩy", "Nét Cong Móc", "Nét Hoành"],
                strokePathDefinitions: ["M 35,15 L 38,28", "M 50,15 L 50,28", "M 65,15 L 60,28", "M 25,35 L 22,45", "M 25,40 L 75,40 L 70,50", "M 45,50 L 60,50 L 45,70", "M 45,70 L 60,85 L 50,80", "M 30,70 L 75,70"]
            )
        default:
            return HanziStrokeData(
                hanzi: hanzi,
                totalStrokes: 4,
                strokeNames: ["Nét Hoành", "Nét Sổ", "Nét Phẩy", "Nét Mác"],
                strokePathDefinitions: ["M 20,40 L 80,40", "M 50,20 L 50,80", "M 50,40 L 25,75", "M 50,40 L 75,75"]
            )
        }
    }
}
