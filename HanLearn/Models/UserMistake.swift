//
//  UserMistake.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Model: Sổ tay lỗi sai (Mistake Book) - Tự động gom lỗi sai từ Dictation, Sentence Builder & Quiz
//

import Foundation
import SwiftData

@Model
public final class UserMistake {
    public var id: UUID = UUID()
    public var questionType: String = "dictation" // "dictation", "sentence_builder", "mock_test", "quiz"
    public var hskLevel: Int = 1
    public var promptText: String = ""
    public var audioText: String? = nil
    public var targetAnswer: String = ""
    public var userAnswer: String = ""
    public var explanation: String = ""
    public var attemptCount: Int = 1
    public var correctCount: Int = 0
    public var isResolved: Bool = false // Đạt >= 80% đúng
    public var createdAt: Date = Date()
    public var lastAttemptAt: Date = Date()
    
    public init(
        questionType: String,
        hskLevel: Int = 1,
        promptText: String,
        audioText: String? = nil,
        targetAnswer: String,
        userAnswer: String,
        explanation: String = ""
    ) {
        self.id = UUID()
        self.questionType = questionType
        self.hskLevel = hskLevel
        self.promptText = promptText
        self.audioText = audioText
        self.targetAnswer = targetAnswer
        self.userAnswer = userAnswer
        self.explanation = explanation
        self.attemptCount = 1
        self.correctCount = 0
        self.isResolved = false
        self.createdAt = Date()
        self.lastAttemptAt = Date()
    }
    
    public var accuracyPercentage: Int {
        guard attemptCount > 0 else { return 0 }
        return Int((Double(correctCount) / Double(attemptCount)) * 100)
    }
    
    public func recordAttempt(isCorrect: Bool) {
        attemptCount += 1
        lastAttemptAt = Date()
        if isCorrect {
            correctCount += 1
            if accuracyPercentage >= 80 || correctCount >= 2 {
                isResolved = true
            }
        }
    }
}
