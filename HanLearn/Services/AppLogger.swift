//
//  AppLogger.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  In-App Real-time Diagnostic Logger & Error Tracker
//  Ghi lại toàn bộ log hệ thống: Micro, AudioSession, Quyền, Database, UI để người dùng kiểm tra trực tiếp
//

import Foundation
import SwiftUI

public enum LogLevel: String, CaseIterable {
    case info = "INFO"
    case success = "SUCCESS"
    case warning = "WARN"
    case error = "ERROR"
    
    public var icon: String {
        switch self {
        case .info: return "ℹ️"
        case .success: return "✅"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    public var color: Color {
        switch self {
        case .info: return .blue
        case .success: return HanTheme.jadeGreen
        case .warning: return HanTheme.silkGold
        case .error: return HanTheme.vermilionRed
        }
    }
}

public struct LogEntry: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let level: LogLevel
    public let tag: String
    public let message: String
    
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}

@MainActor
public final class AppLogger: ObservableObject {
    public static let shared = AppLogger()
    
    @Published public private(set) var entries: [LogEntry] = []
    
    private init() {
        log(.info, tag: "System", message: "HanLearn khởi động. Hệ thống chẩn đoán sẵn sàng.")
    }
    
    public func log(_ level: LogLevel, tag: String, message: String) {
        let entry = LogEntry(timestamp: Date(), level: level, tag: tag, message: message)
        entries.insert(entry, at: 0)
        if entries.count > 300 {
            entries.removeLast()
        }
        print("[\(entry.formattedTime)] [\(entry.level.rawValue)] [\(entry.tag)] \(entry.message)")
    }
    
    public func info(tag: String, message: String) {
        log(.info, tag: tag, message: message)
    }
    
    public func success(tag: String, message: String) {
        log(.success, tag: tag, message: message)
    }
    
    public func warning(tag: String, message: String) {
        log(.warning, tag: tag, message: message)
    }
    
    public func error(tag: String, message: String) {
        log(.error, tag: tag, message: message)
    }
    
    public func clear() {
        entries.removeAll()
        log(.info, tag: "System", message: "Đã làm trống nhật ký.")
    }
    
    public func exportLogsAsText() -> String {
        return entries.reversed().map {
            "[\($0.formattedTime)] [\($0.level.rawValue)] [\($0.tag)] \($0.message)"
        }.joined(separator: "\n")
    }
}
