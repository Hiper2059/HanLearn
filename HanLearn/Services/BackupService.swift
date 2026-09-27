//
//  BackupService.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Xuất & Nhập file Backup (.json) ra bộ nhớ máy - 100% Offline (Zero-Friction)
//

import Foundation
import SwiftData

public struct BackupDataPayload: Codable {
    public struct WordDTO: Codable {
        public let hanzi: String
        public let pinyin: String
        public let sinoVietnamese: String
        public let vietnameseMeaning: String
        public let hskLevel: Int
        public let masteryPercentage: Int
        public let srsRepetitionCount: Int
        public let srsIntervalDays: Int
    }
    
    public struct MistakeDTO: Codable {
        public let questionType: String
        public let promptText: String
        public let targetAnswer: String
        public let userAnswer: String
        public let attemptCount: Int
        public let correctCount: Int
        public let isResolved: Bool
    }
    
    public let version: String
    public let exportedAt: Date
    public let totalXP: Int
    public let currentStreak: Int
    public let vocabulary: [WordDTO]
    public let mistakes: [MistakeDTO]
}

public struct BackupService {
    
    /// Xuất toàn bộ tiến độ, từ vựng và lịch sử lỗi sai ra JSON String
    @MainActor
    public static func exportToJSON(modelContext: ModelContext) -> String? {
        let words = (try? modelContext.fetch(FetchDescriptor<HSKWord>())) ?? []
        let mistakes = (try? modelContext.fetch(FetchDescriptor<UserMistake>())) ?? []
        let progress = (try? modelContext.fetch(FetchDescriptor<UserProgress>()))?.first
        
        let wordDTOs = words.map {
            BackupDataPayload.WordDTO(
                hanzi: $0.hanzi,
                pinyin: $0.pinyin,
                sinoVietnamese: $0.sinoVietnamese,
                vietnameseMeaning: $0.vietnameseMeaning,
                hskLevel: $0.hskLevel,
                masteryPercentage: $0.masteryPercentage,
                srsRepetitionCount: $0.srsRepetitionCount,
                srsIntervalDays: $0.srsIntervalDays
            )
        }
        
        let mistakeDTOs = mistakes.map {
            BackupDataPayload.MistakeDTO(
                questionType: $0.questionType,
                promptText: $0.promptText,
                targetAnswer: $0.targetAnswer,
                userAnswer: $0.userAnswer,
                attemptCount: $0.attemptCount,
                correctCount: $0.correctCount,
                isResolved: $0.isResolved
            )
        }
        
        let payload = BackupDataPayload(
            version: "1.0",
            exportedAt: Date(),
            totalXP: progress?.totalXP ?? 0,
            currentStreak: progress?.currentStreak ?? 1,
            vocabulary: wordDTOs,
            mistakes: mistakeDTOs
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(payload) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Nhập dữ liệu sao lưu từ chuỗi JSON và khôi phục vào SwiftData ModelContext
    @MainActor
    public static func importFromJSON(_ jsonString: String, modelContext: ModelContext) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let payload = try? decoder.decode(BackupDataPayload.self, from: data) else { return false }
        
        // Khôi phục UserProgress
        let progress = (try? modelContext.fetch(FetchDescriptor<UserProgress>()))?.first ?? UserProgress()
        progress.totalXP = max(progress.totalXP, payload.totalXP)
        progress.currentStreak = max(progress.currentStreak, payload.currentStreak)
        
        // Khôi phục từ vựng đã học
        let existingWords = (try? modelContext.fetch(FetchDescriptor<HSKWord>())) ?? []
        let existingHanziMap = Set(existingWords.map { $0.hanzi })
        
        for w in payload.vocabulary {
            if !existingHanziMap.contains(w.hanzi) {
                let newWord = HSKWord(
                    hanzi: w.hanzi,
                    pinyin: w.pinyin,
                    sinoVietnamese: w.sinoVietnamese,
                    vietnameseMeaning: w.vietnameseMeaning,
                    hskLevel: w.hskLevel,
                    srsRepetitionCount: w.srsRepetitionCount,
                    srsIntervalDays: w.srsIntervalDays,
                    masteryPercentage: w.masteryPercentage
                )
                modelContext.insert(newWord)
            }
        }
        
        // Khôi phục lỗi sai
        for m in payload.mistakes {
            let mistake = UserMistake(
                questionType: m.questionType,
                promptText: m.promptText,
                targetAnswer: m.targetAnswer,
                userAnswer: m.userAnswer
            )
            mistake.attemptCount = m.attemptCount
            mistake.correctCount = m.correctCount
            mistake.isResolved = m.isResolved
            modelContext.insert(mistake)
        }
        
        try? modelContext.save()
        return true
    }
}

