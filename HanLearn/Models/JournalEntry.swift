//
//  JournalEntry.swift
//  HanLearn
//
//  Lightweight daily self-talk journal entry.
//  Goal: 5 Chinese sentences per day to build the thinking-in-Chinese habit.
//

import Foundation
import SwiftData

@Model
public final class JournalEntry {
    @Attribute(.unique) public var id: UUID
    public var date: Date                      // Calendar day for grouping
    public var content: String                 // User's self-talk text
    public var sentenceCount: Int              // Number of sentences (computed on save)
    public var isVoiceInput: Bool              // Created via Speech framework dictation
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        content: String = "",
        sentenceCount: Int = 0,
        isVoiceInput: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.content = content
        self.sentenceCount = sentenceCount
        self.isVoiceInput = isVoiceInput
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Recount sentences based on Chinese/general punctuation delimiters
    public func updateSentenceCount() {
        let delimiters = CharacterSet(charactersIn: "。！？.!?\n")
        let sentences = content.components(separatedBy: delimiters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        sentenceCount = sentences.count
        updatedAt = Date()
    }
}
