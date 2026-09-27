//
//  HSKLesson.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Clean Architecture - SwiftData Model
//

import Foundation
import SwiftData

@Model
public final class HSKLesson {
    @Attribute(.unique) public var id: UUID
    public var hskLevel: Int          // 1 -> 9 (HSK 3.0 Standard)
    public var title: String          // e.g., "Đi siêu thị mua sắm (超市购物)"
    public var topic: String          // e.g., "Shopping & Daily Life"
    public var levelBadge: String     // "HSK 1", "HSK 2", etc.
    public var summary: String        // Tóm tắt mục tiêu bài học
    public var grammarExplanation: String // Giải thích cấu trúc ngữ pháp trọng tâm
    public var dialogueChinese: String    // Đoạn hội thoại chữ Hán
    public var dialoguePinyin: String     // Phiên âm Pinyin toàn bài
    public var dialogueVietnamese: String // Dịch nghĩa tiếng Việt
    public var createdAt: Date
    public var isCompleted: Bool
    public var score: Int
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \HSKWord.lesson)
    public var vocabularyList: [HSKWord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \HSKQuiz.lesson)
    public var quizzes: [HSKQuiz] = []
    
    public init(
        id: UUID = UUID(),
        hskLevel: Int,
        title: String,
        topic: String,
        summary: String,
        grammarExplanation: String,
        dialogueChinese: String,
        dialoguePinyin: String,
        dialogueVietnamese: String,
        createdAt: Date = Date(),
        isCompleted: Bool = false,
        score: Int = 0
    ) {
        self.id = id
        self.hskLevel = hskLevel
        self.title = title
        self.topic = topic
        self.levelBadge = "HSK \(hskLevel)"
        self.summary = summary
        self.grammarExplanation = grammarExplanation
        self.dialogueChinese = dialogueChinese
        self.dialoguePinyin = dialoguePinyin
        self.dialogueVietnamese = dialogueVietnamese
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.score = score
    }
}
