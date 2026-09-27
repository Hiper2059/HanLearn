//
//  HSKWord.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Clean Architecture - SwiftData Model with Spaced Repetition (SRS)
//

import Foundation
import SwiftData

@Model
public final class HSKWord {
    @Attribute(.unique) public var id: UUID
    public var hanzi: String               // e.g., "苹果"
    public var pinyin: String              // e.g., "píngguǒ"
    public var sinoVietnamese: String      // Âm Hán Việt: "Bình quả"
    public var vietnameseMeaning: String   // Nghĩa tiếng Việt: "Quả táo"
    public var hskLevel: Int               // 1 -> 9
    public var partOfSpeech: String        // "Danh từ", "Động từ", etc.
    public var exampleSentenceHanzi: String
    public var exampleSentencePinyin: String
    public var exampleSentenceTranslation: String
    public var strokeCount: Int
    
    // Quick-add & visual mnemonic support
    public var photoLocalPath: String?         // Local file path for visual mnemonic image
    public var isUserAdded: Bool               // true = user added via quick-add, false = from lesson
    public var addedAt: Date                   // Timestamp when word was added
    
    // Thuật toán Spaced Repetition (FSRS / SM-2)
    public var srsRepetitionCount: Int
    public var srsIntervalDays: Int
    public var srsEaseFactor: Double
    public var lastReviewedAt: Date?
    public var nextReviewAt: Date?
    public var masteryPercentage: Int      // 0 -> 100%
    
    public var lesson: HSKLesson?
    
    public init(
        id: UUID = UUID(),
        hanzi: String,
        pinyin: String,
        sinoVietnamese: String,
        vietnameseMeaning: String,
        hskLevel: Int,
        partOfSpeech: String = "Từ",
        exampleSentenceHanzi: String = "",
        exampleSentencePinyin: String = "",
        exampleSentenceTranslation: String = "",
        strokeCount: Int = 0,
        photoLocalPath: String? = nil,
        isUserAdded: Bool = false,
        addedAt: Date = Date(),
        srsRepetitionCount: Int = 0,
        srsIntervalDays: Int = 1,
        srsEaseFactor: Double = 2.5,
        masteryPercentage: Int = 0
    ) {
        self.id = id
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.sinoVietnamese = sinoVietnamese
        self.vietnameseMeaning = vietnameseMeaning
        self.hskLevel = hskLevel
        self.partOfSpeech = partOfSpeech
        self.exampleSentenceHanzi = exampleSentenceHanzi
        self.exampleSentencePinyin = exampleSentencePinyin
        self.exampleSentenceTranslation = exampleSentenceTranslation
        self.strokeCount = strokeCount
        self.photoLocalPath = photoLocalPath
        self.isUserAdded = isUserAdded
        self.addedAt = addedAt
        self.srsRepetitionCount = srsRepetitionCount
        self.srsIntervalDays = srsIntervalDays
        self.srsEaseFactor = srsEaseFactor
        self.masteryPercentage = masteryPercentage
        self.nextReviewAt = Date()
    }
    
    // Cập nhật SRS sau khi người dùng ôn tập
    public func updateSRS(quality: Int) { // quality: 0 (quên), 3 (khá), 5 (thuộc làu)
        lastReviewedAt = Date()
        
        if quality >= 3 {
            if srsRepetitionCount == 0 {
                srsIntervalDays = 1
            } else if srsRepetitionCount == 1 {
                srsIntervalDays = 3
            } else {
                srsIntervalDays = Int(Double(srsIntervalDays) * srsEaseFactor)
            }
            srsRepetitionCount += 1
            masteryPercentage = min(100, masteryPercentage + 20)
        } else {
            srsRepetitionCount = 0
            srsIntervalDays = 1
            masteryPercentage = max(0, masteryPercentage - 15)
        }
        
        // SM-2 Ease Factor formula
        srsEaseFactor = max(1.3, srsEaseFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02)))
        
        // Tính ngày ôn tập tiếp theo
        let secondsInDay: TimeInterval = 86400
        nextReviewAt = Date().addingTimeInterval(Double(srsIntervalDays) * secondsInDay)
    }
}
