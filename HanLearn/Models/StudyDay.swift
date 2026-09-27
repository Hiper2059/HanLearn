//
//  StudyDay.swift
//  HanLearn
//
//  Aggregated daily study metrics for the Progress tab's Charts.
//  One record per calendar day, created/updated as the user studies.
//

import Foundation
import SwiftData

@Model
public final class StudyDay {
    @Attribute(.unique) public var id: UUID
    public var date: Date                      // Calendar day (start of day)
    public var minutesStudied: Int
    public var wordsReviewed: Int              // Words reviewed via SRS
    public var wordsLearned: Int               // New words added
    public var tasksCompleted: Int
    public var tasksTotal: Int
    public var journalWritten: Bool
    public var listeningMinutes: Int           // For the 70/30 split tracking
    public var speakingMinutes: Int
    public var readingMinutes: Int
    public var writingMinutes: Int
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        minutesStudied: Int = 0,
        wordsReviewed: Int = 0,
        wordsLearned: Int = 0,
        tasksCompleted: Int = 0,
        tasksTotal: Int = 0,
        journalWritten: Bool = false,
        listeningMinutes: Int = 0,
        speakingMinutes: Int = 0,
        readingMinutes: Int = 0,
        writingMinutes: Int = 0
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.minutesStudied = minutesStudied
        self.wordsReviewed = wordsReviewed
        self.wordsLearned = wordsLearned
        self.tasksCompleted = tasksCompleted
        self.tasksTotal = tasksTotal
        self.journalWritten = journalWritten
        self.listeningMinutes = listeningMinutes
        self.speakingMinutes = speakingMinutes
        self.readingMinutes = readingMinutes
        self.writingMinutes = writingMinutes
    }
    
    /// Total listening + speaking minutes (target: 70% of study time)
    public var oralMinutes: Int {
        listeningMinutes + speakingMinutes
    }
    
    /// Total reading + writing minutes (target: 30% of study time)
    public var literacyMinutes: Int {
        readingMinutes + writingMinutes
    }
    
    /// Completion percentage for the day's tasks
    public var completionRate: Double {
        guard tasksTotal > 0 else { return 0 }
        return Double(tasksCompleted) / Double(tasksTotal)
    }
}
