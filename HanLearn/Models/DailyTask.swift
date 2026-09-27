//
//  DailyTask.swift
//  HanLearn
//
//  Daily task items generated for the Home tab "What do I do today?" view.
//  Tasks come from: weekly template, SRS review queue, and carry-over from yesterday.
//

import Foundation
import SwiftData

/// Categories that map to the 6-stage roadmap
public enum TaskCategory: String, Codable, CaseIterable {
    case pinyin = "pinyin"
    case characters = "characters"
    case vocabulary = "vocabulary"
    case grammar = "grammar"
    case speaking = "speaking"
    case listening = "listening"
    case review = "review"
    case journal = "journal"
    
    public var displayName: String {
        switch self {
        case .pinyin: return "Pinyin & Thanh điệu"
        case .characters: return "Chữ Hán & Nét viết"
        case .vocabulary: return "Từ vựng mới"
        case .grammar: return "Ngữ pháp"
        case .speaking: return "Luyện nói"
        case .listening: return "Luyện nghe"
        case .review: return "Ôn tập SRS"
        case .journal: return "Nhật ký tự nói"
        }
    }
    
    public var iconName: String {
        switch self {
        case .pinyin: return "textformat.abc"
        case .characters: return "pencil.tip.crop.circle"
        case .vocabulary: return "character.book.closed.fill"
        case .grammar: return "text.book.closed.fill"
        case .speaking: return "mic.fill"
        case .listening: return "headphones"
        case .review: return "arrow.triangle.2.circlepath"
        case .journal: return "note.text"
        }
    }
    
    public var accentColor: String {
        switch self {
        case .pinyin: return "silkGold"
        case .characters: return "vermilionRed"
        case .vocabulary: return "jadeGreen"
        case .grammar: return "silkGold"
        case .speaking: return "vermilionRed"
        case .listening: return "jadeGreen"
        case .review: return "silkGold"
        case .journal: return "jadeGreen"
        }
    }
}

/// Represents a single task item on the Home screen's daily checklist.
@Model
public final class DailyTask {
    @Attribute(.unique) public var id: UUID
    public var date: Date                      // Calendar day this task belongs to
    public var title: String                   // e.g., "Ôn 15 từ vựng đến hạn"
    public var subtitle: String?               // e.g., "SRS Review Queue"
    public var categoryRaw: String             // Raw value of TaskCategory
    public var isCompleted: Bool
    public var completedAt: Date?
    public var minutesEstimated: Int            // 5, 10, 15, 20, 30
    public var isCarryOver: Bool               // Carried from yesterday
    public var linkedWordIdsData: [String]?    // UUID strings for SRS-review tasks
    public var sortOrder: Int                  // Display order within the day
    
    public var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRaw) ?? .vocabulary }
        set { categoryRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String,
        subtitle: String? = nil,
        category: TaskCategory,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        minutesEstimated: Int = 10,
        isCarryOver: Bool = false,
        linkedWordIds: [UUID]? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.subtitle = subtitle
        self.categoryRaw = category.rawValue
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.minutesEstimated = minutesEstimated
        self.isCarryOver = isCarryOver
        self.linkedWordIdsData = linkedWordIds?.map { $0.uuidString }
        self.sortOrder = sortOrder
    }
    
    /// Mark task as completed with timestamp
    public func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }
    
    /// Unmark task completion
    public func markIncomplete() {
        isCompleted = false
        completedAt = nil
    }
}
