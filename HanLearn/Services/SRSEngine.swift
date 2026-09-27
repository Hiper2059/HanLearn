//
//  SRSEngine.swift
//  HanLearn
//
//  Pure-value-type SRS algorithm, decoupled from UI and SwiftData.
//  Implements SM-2-lite with fixed interval steps: 1 → 3 → 7 → 14 → 30 days.
//  Designed to be unit-testable in isolation.
//

import Foundation

/// Self-grading quality levels for flashcard review
public enum SRSGrade: Int, CaseIterable {
    case again = 0    // Completely forgot — reset
    case hard = 3     // Recalled with significant difficulty
    case good = 4     // Recalled with some effort (default)
    case easy = 5     // Recalled instantly, effortless
    
    public var displayName: String {
        switch self {
        case .again: return "Lại"
        case .hard: return "Khó"
        case .good: return "Tốt"
        case .easy: return "Dễ"
        }
    }
    
    public var accessibilityLabel: String {
        switch self {
        case .again: return "Chưa nhớ, ôn lại"
        case .hard: return "Nhớ nhưng khó"
        case .good: return "Nhớ tốt"
        case .easy: return "Nhớ rất dễ"
        }
    }
}

/// Result of processing a single review through the SRS algorithm
public struct SRSResult {
    public let newInterval: Int          // Days until next review
    public let newRepetitionCount: Int
    public let newEaseFactor: Double
    public let newMastery: Int           // 0–100
    public let nextReviewDate: Date
}

/// Stateless SRS engine — all inputs in, all outputs out, no side effects.
public struct SRSEngine {
    
    /// Fixed interval steps for v1 (matches the roadmap's 1/3/7/14/30 schedule)
    public static let intervalSteps: [Int] = [1, 3, 7, 14, 30]
    
    /// Maximum number of overdue cards to show in a single catch-up session
    public static let catchUpQueueCap: Int = 35
    
    /// Recommended max new words per day
    public static let maxNewWordsPerDay: Int = 15
    public static let recommendedNewWordsPerDay: Int = 10
    
    /// Process a single review and return the updated SRS state.
    ///
    /// - Parameters:
    ///   - grade: User's self-assessment (Again/Hard/Good/Easy)
    ///   - currentRepetitionCount: How many times the word has been successfully recalled in a row
    ///   - currentIntervalDays: Current interval between reviews
    ///   - currentEaseFactor: SM-2 ease factor (starts at 2.5)
    ///   - currentMastery: 0–100 mastery percentage
    /// - Returns: Updated SRS state
    public static func processReview(
        grade: SRSGrade,
        currentRepetitionCount: Int,
        currentIntervalDays: Int,
        currentEaseFactor: Double,
        currentMastery: Int
    ) -> SRSResult {
        let quality = grade.rawValue
        var newRep = currentRepetitionCount
        var newInterval = currentIntervalDays
        var newEase = currentEaseFactor
        var newMastery = currentMastery
        
        if quality >= 3 {
            // Successful recall — advance through interval steps
            if newRep < intervalSteps.count {
                newInterval = intervalSteps[newRep]
            } else {
                // Beyond fixed steps: multiply by ease factor, capped at 30 days for v1
                newInterval = min(30, Int(Double(currentIntervalDays) * newEase))
            }
            newRep += 1
            
            // Mastery increases based on grade quality
            let masteryBoost: Int
            switch grade {
            case .hard: masteryBoost = 10
            case .good: masteryBoost = 15
            case .easy: masteryBoost = 25
            default: masteryBoost = 0
            }
            newMastery = min(100, newMastery + masteryBoost)
        } else {
            // Failed recall — reset to beginning
            newRep = 0
            newInterval = intervalSteps[0] // 1 day
            newMastery = max(0, newMastery - 15)
        }
        
        // SM-2 Ease Factor update formula
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        let qDiff = Double(5 - quality)
        newEase = max(1.3, newEase + (0.1 - qDiff * (0.08 + qDiff * 0.02)))
        
        // Calculate next review date
        let secondsInDay: TimeInterval = 86400
        let nextDate = Date().addingTimeInterval(Double(newInterval) * secondsInDay)
        
        return SRSResult(
            newInterval: newInterval,
            newRepetitionCount: newRep,
            newEaseFactor: newEase,
            newMastery: newMastery,
            nextReviewDate: nextDate
        )
    }
    
    /// Apply an SRS result to an HSKWord model object
    public static func applyResult(_ result: SRSResult, to word: HSKWord) {
        word.srsRepetitionCount = result.newRepetitionCount
        word.srsIntervalDays = result.newInterval
        word.srsEaseFactor = result.newEaseFactor
        word.masteryPercentage = result.newMastery
        word.nextReviewAt = result.nextReviewDate
        word.lastReviewedAt = Date()
    }
}
