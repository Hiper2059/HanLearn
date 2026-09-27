//
//  HSKQuiz.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Clean Architecture - SwiftData Model
//

import Foundation
import SwiftData

public enum QuizType: String, Codable {
    case multipleChoice = "MULTIPLE_CHOICE"
    case sentenceReorder = "SENTENCE_REORDER"
    case clozeTest = "CLOZE_TEST"
    case speechShadowing = "SPEECH_SHADOWING"
}

@Model
public final class HSKQuiz {
    @Attribute(.unique) public var id: UUID
    public var typeRaw: String              // Lưu raw value của QuizType
    public var promptText: String           // Đề bài (vd: "Chọn Pinyin đúng cho từ 苹果")
    public var targetHanzi: String          // Chữ Hán mục tiêu
    public var targetPinyin: String         // Pinyin mục tiêu
    public var audioHintText: String        // Nội dung để phát audio phát âm
    public var optionsData: [String]        // Các lựa chọn trả lời (JSON/String array)
    public var correctAnswer: String        // Đáp án đúng
    public var explanation: String          // Giải thích vì sao đúng/sai
    public var isAnswered: Bool
    public var isCorrect: Bool
    public var userAnswer: String?
    
    public var lesson: HSKLesson?
    
    public var type: QuizType {
        get { QuizType(rawValue: typeRaw) ?? .multipleChoice }
        set { typeRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        type: QuizType,
        promptText: String,
        targetHanzi: String = "",
        targetPinyin: String = "",
        audioHintText: String = "",
        optionsData: [String] = [],
        correctAnswer: String,
        explanation: String = "",
        isAnswered: Bool = false,
        isCorrect: Bool = false,
        userAnswer: String? = nil
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.promptText = promptText
        self.targetHanzi = targetHanzi
        self.targetPinyin = targetPinyin
        self.audioHintText = audioHintText
        self.optionsData = optionsData
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.isAnswered = isAnswered
        self.isCorrect = isCorrect
        self.userAnswer = userAnswer
    }
}
