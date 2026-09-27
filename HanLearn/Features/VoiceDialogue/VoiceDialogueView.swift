//
//  VoiceDialogueView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Luyện nói câu thoại với AI & Chấm điểm phát âm 4 thanh điệu
//

import SwiftUI
import SwiftData

public struct VoiceDialogueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let targetHanzi: String
    public let targetPinyin: String
    
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var evaluationResult: VoiceEvaluationResult?
    @State private var isAnalyzing: Bool = false
    
    public init(targetHanzi: String, targetPinyin: String) {
        self.targetHanzi = targetHanzi
        self.targetPinyin = targetPinyin
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Câu mẫu cần đọc
                    VStack(spacing: 10) {
                        Text("CÂU THOẠI MẪU")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(HanTheme.silkGold)
                        
                        Text(targetHanzi)
                            .font(.hanTitle(size: 24))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                        
                        Text(targetPinyin)
                            .font(.hanPinyin(size: 15))
                            .foregroundColor(HanTheme.jadeGreen)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            SoundManager.shared.speakMandarin(targetHanzi)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.3.fill")
                                Text("Nghe mẫu chuẩn")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Nút Microphone thu âm lớn
                    VStack(spacing: 12) {
                        ZStack {
                            if voiceEvaluator.isRecording {
                                Circle()
                                    .fill(HanTheme.vermilionRed.opacity(0.2))
                                    .frame(width: 140, height: 140)
                                    .scaleEffect(1.0 + CGFloat(voiceEvaluator.audioLevel) * 0.5)
                                    .animation(.easeInOut(duration: 0.1), value: voiceEvaluator.audioLevel)
                            }
                            
                            Button(action: toggleRecording) {
                                Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 88, height: 88)
                                    .background(voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen)
                                    .clipShape(Circle())
                                    .shadow(color: (voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen).opacity(0.4), radius: 12)
                            }
                        }
                        
                        Text(voiceEvaluator.isRecording ? "Đang lắng nghe giọng bạn... (Nhấn để dừng)" : "Chạm để bắt đầu nói")
                            .font(.hanBody(size: 14))
                            .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : .gray)
                        
                        if !voiceEvaluator.liveTranscript.isEmpty {
                            Text("Nhận diện: \"\(voiceEvaluator.liveTranscript)\"")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    // Bảng kết quả chấm điểm (Score Card)
                    if let res = evaluationResult {
                        VStack(spacing: 14) {
                            HStack(spacing: 20) {
                                scoreBadge(title: "Tổng quan", score: res.overallScore, color: HanTheme.silkGold)
                                scoreBadge(title: "Thanh điệu", score: res.toneScore, color: HanTheme.jadeGreen)
                                scoreBadge(title: "Lưu loát", score: res.fluencyScore, color: .orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Nhận xét của AI:")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                                Text(res.feedbackMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("AI Voice Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
        }
    }
    
    private func scoreBadge(title: String, score: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.hanTitle(size: 26))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
    
    private func toggleRecording() {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: targetHanzi, targetPinyin: targetPinyin)
            evaluationResult = res
            
            // Tự động lưu bản ghi âm và kết quả vào SwiftData cục bộ trên máy
            let record = VoiceRecord(
                targetHanzi: targetHanzi,
                targetPinyin: targetPinyin,
                recognizedTranscript: res.recognizedText,
                overallScore: res.overallScore,
                toneScore: res.toneScore,
                fluencyScore: res.fluencyScore,
                feedbackMessage: res.feedbackMessage
            )
            modelContext.insert(record)
            try? modelContext.save()
            
            if res.overallScore >= 80 {
                HapticManager.shared.answerCorrect()
            } else {
                HapticManager.shared.answerWrong()
            }
        } else {
            evaluationResult = nil
            do {
                try voiceEvaluator.startRecording(targetHanzi: targetHanzi)
                HapticManager.shared.buttonTapped()
            } catch {
                print("Lỗi khởi động thu âm: \(error)")
            }
        }
    }
}
