//
//  VoiceDialogueView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Luyện nói câu thoại với AI & Chấm điểm phát âm 4 thanh điệu
//  100% Zero-Crash & Chẩn đoán trực quan (Full permission checks & safe SwiftData saving)
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
    @State private var errorMessage: String? = nil
    
    public init(targetHanzi: String, targetPinyin: String) {
        self.targetHanzi = targetHanzi.isEmpty ? "你好！" : targetHanzi
        self.targetPinyin = targetPinyin.isEmpty ? "Nǐ hǎo!" : targetPinyin
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Câu thoại mẫu
                        VStack(spacing: 12) {
                            Text("CÂU THOẠI MẪU CẦN ĐỌC")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(HanTheme.silkGold)
                            
                            Text(targetHanzi)
                                .font(.hanTitle(size: 24))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 16)
                            
                            Text(targetPinyin)
                                .font(.hanPinyin(size: 16))
                                .foregroundColor(HanTheme.jadeGreen)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            
                            Button(action: {
                                SoundManager.shared.speakMandarin(targetHanzi)
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "speaker.wave.3.fill")
                                    Text("Nghe Giọng Chuẩn Bắc Kinh")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(24)
                            }
                        }
                        .padding(.top, 16)
                        
                        // 2. Khu vực Microphone thu âm
                        VStack(spacing: 14) {
                            // Cảnh báo nếu quyền Micro bị tắt
                            if voiceEvaluator.isPermissionDenied {
                                VStack(spacing: 10) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "mic.slash.fill")
                                            .foregroundColor(HanTheme.vermilionRed)
                                            .font(.system(size: 20))
                                        Text("Quyền Micro đang bị tắt trên iPhone")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Để thu âm giọng nói thật và chấm điểm thanh điệu, bạn cần cho phép HanLearn truy cập Micro.")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.75))
                                        .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            voiceEvaluator.openSettings()
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "gearshape.fill")
                                                Text("Mở Cài Đặt iPhone")
                                            }
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(HanTheme.silkGold)
                                            .cornerRadius(10)
                                        }
                                        
                                        Button(action: runSimulatedCheck) {
                                            Text("Chấm Thử Mô Phỏng")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.white.opacity(0.12))
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(HanTheme.vermilionRed.opacity(0.4), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                            
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
                                        .frame(width: 90, height: 90)
                                        .background(voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen)
                                        .clipShape(Circle())
                                        .shadow(color: (voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen).opacity(0.4), radius: 14)
                                }
                            }
                            
                            Text(voiceEvaluator.isRecording ? "Đang lắng nghe... (Nhấn nút để DỪNG & CHẤM ĐIỂM)" : "Chạm vào Micro để bắt đầu nói")
                                .font(.hanBody(size: 14))
                                .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : .gray)
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(HanTheme.vermilionRed)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Nút nghe lại giọng học viên
                            if voiceEvaluator.hasRecordedAudio {
                                Button(action: {
                                    voiceEvaluator.playRecordedVoice()
                                    HapticManager.shared.buttonTapped()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: voiceEvaluator.isPlayingBack ? "pause.circle.fill" : "play.circle.fill")
                                        Text(voiceEvaluator.isPlayingBack ? "Đang phát..." : "Nghe lại giọng vừa đọc của bạn")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(HanTheme.silkGold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(HanTheme.silkGold.opacity(0.12))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        // 3. Bảng kết quả chấm điểm
                        if let res = evaluationResult {
                            VStack(spacing: 14) {
                                HStack(spacing: 14) {
                                    scoreBadge(title: "Tổng quan", score: res.overallScore, color: HanTheme.silkGold)
                                    scoreBadge(title: "Thanh điệu", score: res.toneScore, color: HanTheme.jadeGreen)
                                    scoreBadge(title: "Lưu loát", score: res.fluencyScore, color: .orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ĐÁNH GIÁ CHI TIẾT:")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(HanTheme.silkGold)
                                    Text(res.feedbackMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 40)
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
            .onAppear {
                voiceEvaluator.updatePermissionStatus()
                AppLogger.shared.info(tag: "UI", message: "Mở AI Voice Coach: \(targetHanzi)")
            }
            .onDisappear {
                voiceEvaluator.stopRecording()
                voiceEvaluator.stopPlayback()
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
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
    
    private func runSimulatedCheck() {
        errorMessage = nil
        let res = voiceEvaluator.evaluateWithSimulatedVoice(targetHanzi: targetHanzi, targetPinyin: targetPinyin)
        evaluationResult = res
        saveVoiceRecordSafely(res: res)
        HapticManager.shared.answerCorrect()
    }
    
    private func toggleRecording() {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: targetHanzi, targetPinyin: targetPinyin)
            evaluationResult = res
            
            // Lưu VoiceRecord an toàn tuyệt đối
            saveVoiceRecordSafely(res: res)
            
            if res.overallScore >= 80 {
                HapticManager.shared.answerCorrect()
            } else {
                HapticManager.shared.answerWrong()
            }
        } else {
            errorMessage = nil
            evaluationResult = nil
            Task {
                let granted = await voiceEvaluator.requestPermissions()
                if granted {
                    do {
                        try voiceEvaluator.startRecording(targetHanzi: targetHanzi)
                        HapticManager.shared.buttonTapped()
                    } catch {
                        errorMessage = "Không thể khởi động bộ thu âm: \(error.localizedDescription)"
                        AppLogger.shared.error(tag: "VoiceCoach", message: errorMessage ?? "")
                    }
                } else {
                    errorMessage = "Chưa cấp quyền Micro. Vui lòng nhấn nút 'Mở Cài Đặt iPhone' ở trên để bật."
                    AppLogger.shared.warning(tag: "VoiceCoach", message: "Bị từ chối quyền Micro.")
                }
            }
        }
    }
    
    private func saveVoiceRecordSafely(res: VoiceEvaluationResult) {
        do {
            let record = VoiceRecord(
                targetHanzi: targetHanzi,
                targetPinyin: targetPinyin,
                recognizedTranscript: res.recognizedText,
                audioLocalFilePath: voiceEvaluator.currentAudioFileURL?.path,
                overallScore: res.overallScore,
                toneScore: res.toneScore,
                fluencyScore: res.fluencyScore,
                feedbackMessage: res.feedbackMessage
            )
            modelContext.insert(record)
            try modelContext.save()
            AppLogger.shared.success(tag: "SwiftData", message: "Đã lưu bản ghi âm vào cơ sở dữ liệu.")
        } catch {
            AppLogger.shared.warning(tag: "SwiftData", message: "Lỗi lưu VoiceRecord (không ảnh hưởng UI): \(error.localizedDescription)")
        }
    }
}
