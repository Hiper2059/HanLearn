//
//  VoiceRecord.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Clean Architecture - SwiftData Model for Voice Evaluation & Local Audio Storage
//

import Foundation
import SwiftData

@Model
public final class VoiceRecord {
    @Attribute(.unique) public var id: UUID
    public var targetHanzi: String            // Câu tiếng Trung mục tiêu
    public var targetPinyin: String           // Pinyin mục tiêu
    public var recognizedTranscript: String   // Văn bản Speech-to-Text nhận diện được
    public var audioLocalFilePath: String?    // Đường dẫn file .m4a / .wav lưu trong Application Documents
    public var overallScore: Int              // Điểm tổng thể 0 -> 100
    public var toneScore: Int                 // Điểm độ chuẩn 4 thanh điệu 0 -> 100
    public var fluencyScore: Int              // Điểm độ lưu loát 0 -> 100
    public var feedbackMessage: String        // Nhận xét chi tiết (vd: "Thanh 4 phát âm chưa đủ dứt khoát")
    public var recordedAt: Date
    
    public init(
        id: UUID = UUID(),
        targetHanzi: String,
        targetPinyin: String,
        recognizedTranscript: String,
        audioLocalFilePath: String? = nil,
        overallScore: Int,
        toneScore: Int,
        fluencyScore: Int,
        feedbackMessage: String,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.targetHanzi = targetHanzi
        self.targetPinyin = targetPinyin
        self.recognizedTranscript = recognizedTranscript
        self.audioLocalFilePath = audioLocalFilePath
        self.overallScore = overallScore
        self.toneScore = toneScore
        self.fluencyScore = fluencyScore
        self.feedbackMessage = feedbackMessage
        self.recordedAt = recordedAt
    }
}
