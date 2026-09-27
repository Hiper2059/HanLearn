//
//  UserProgress.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Clean Architecture - SwiftData Model for User Progress, Streak, Onboarding & Study Tracking
//

import Foundation
import SwiftData

/// Learning goals for onboarding
public enum LearningGoal: String, Codable, CaseIterable {
    case travel = "travel"
    case exam = "exam"
    case work = "work"
    
    public var displayName: String {
        switch self {
        case .travel: return "Du lịch 🌏"
        case .exam: return "Thi HSK 📝"
        case .work: return "Công việc 💼"
        }
    }
}

@Model
public final class UserProgress {
    @Attribute(.unique) public var id: UUID
    
    // ── Streak & XP ──
    public var currentStreak: Int             // Số ngày học liên tiếp
    public var bestStreak: Int
    public var totalXP: Int
    public var lastActiveDate: Date
    public var completedLessonsCount: Int
    public var totalWordsLearned: Int
    public var totalSpeechPracticed: Int
    
    // ── Onboarding ──
    public var hasCompletedOnboarding: Bool
    public var currentHSKTarget: Int          // HSK 1–4 (user's target level)
    public var dailyTargetMinutes: Int        // 15, 30, 45, or 60
    public var learningGoalRaw: String        // Raw value of LearningGoal
    public var currentStage: Int              // 1–6 roadmap stage
    
    // ── Daily Study Tracking ──
    public var minutesStudiedToday: Int
    public var minutesStudiedThisWeek: Int
    public var newVocabAddedToday: Int        // For 10–15/day cap warning
    public var lastVocabResetDate: Date       // Reset newVocabAddedToday when day changes
    
    // ── Notifications ──
    public var notificationsEnabled: Bool
    public var notificationHour: Int          // 0–23
    public var notificationMinute: Int        // 0–59
    
    public var learningGoal: LearningGoal {
        get { LearningGoal(rawValue: learningGoalRaw) ?? .travel }
        set { learningGoalRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        currentStreak: Int = 1,
        bestStreak: Int = 1,
        totalXP: Int = 50,
        lastActiveDate: Date = Date(),
        completedLessonsCount: Int = 0,
        totalWordsLearned: Int = 0,
        totalSpeechPracticed: Int = 0,
        hasCompletedOnboarding: Bool = false,
        currentHSKTarget: Int = 1,
        dailyTargetMinutes: Int = 30,
        learningGoal: LearningGoal = .travel,
        currentStage: Int = 1,
        minutesStudiedToday: Int = 0,
        minutesStudiedThisWeek: Int = 0,
        newVocabAddedToday: Int = 0,
        notificationsEnabled: Bool = false,
        notificationHour: Int = 8,
        notificationMinute: Int = 0
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.totalXP = totalXP
        self.lastActiveDate = lastActiveDate
        self.completedLessonsCount = completedLessonsCount
        self.totalWordsLearned = totalWordsLearned
        self.totalSpeechPracticed = totalSpeechPracticed
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.currentHSKTarget = currentHSKTarget
        self.dailyTargetMinutes = dailyTargetMinutes
        self.learningGoalRaw = learningGoal.rawValue
        self.currentStage = currentStage
        self.minutesStudiedToday = minutesStudiedToday
        self.minutesStudiedThisWeek = minutesStudiedThisWeek
        self.newVocabAddedToday = newVocabAddedToday
        self.lastVocabResetDate = Date()
        self.notificationsEnabled = notificationsEnabled
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
    }
    
    // Cập nhật streak hàng ngày
    public func recordDailyActivity() {
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActiveDate) {
            // Đã học hôm nay rồi
            return
        } else if calendar.isDateInYesterday(lastActiveDate) {
            // Liên tiếp ngày hôm qua
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else {
            // Đứt chuỗi streak
            currentStreak = 1
        }
        lastActiveDate = Date()
        
        // Reset daily counters
        resetDailyCountersIfNeeded()
    }
    
    /// Reset daily vocab counter when the day changes
    public func resetDailyCountersIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastVocabResetDate) {
            newVocabAddedToday = 0
            minutesStudiedToday = 0
            lastVocabResetDate = Date()
        }
    }
    
    /// Number of days since last activity (for catch-up detection)
    public var daysSinceLastActivity: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastActiveDate, to: Date())
        return max(0, components.day ?? 0)
    }
    
    /// Whether the user needs catch-up mode (3+ missed days)
    public var needsCatchUp: Bool {
        daysSinceLastActivity >= 3
    }
    
    /// Starting stage based on HSK level (for onboarding)
    public static func startingStage(forLevel level: Int) -> Int {
        switch level {
        case 1: return 1     // Start from Pinyin/Tones
        case 2: return 3     // Start from Characters
        default: return 4    // HSK 3+ → parallel vocab/grammar/speaking
        }
    }
}
