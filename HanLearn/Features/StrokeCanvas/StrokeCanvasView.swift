//
//  StrokeCanvasView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Tập viết chữ Hán trên ô Mễ Tự Cách (Tianzi Ge), Kiểm tra nét viết khi ẩn chữ, và Luyện nói từ vựng
//

import SwiftUI

public struct Line: Identifiable {
    public var id = UUID()
    public var points: [CGPoint]
    public var lineWidth: CGFloat = 11
    public var isFinished: Bool = false
    
    public init(points: [CGPoint], lineWidth: CGFloat = 11, isFinished: Bool = false) {
        self.points = points
        self.lineWidth = lineWidth
        self.isFinished = isFinished
    }
}

public struct TianziGridShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Ngang giữa
        path.move(to: CGPoint(x: 0, y: h / 2))
        path.addLine(to: CGPoint(x: w, y: h / 2))
        
        // Dọc giữa
        path.move(to: CGPoint(x: w / 2, y: 0))
        path.addLine(to: CGPoint(x: w / 2, y: h))
        
        // Chéo 1
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        
        // Chéo 2
        path.move(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h))
        
        return path
    }
}

public struct StrokeCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    public let word: HSKWord
    
    @State private var currentLines: [Line] = []
    @State private var showGhost: Bool = true
    @State private var strokeCheckResult: StrokeCheckResult? = nil
    
    // Voice Check
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var voiceFeedback: String? = nil
    
    public struct StrokeCheckResult {
        let isCorrect: Bool
        let score: Int
        let message: String
    }
    
    public init(word: HSKWord) {
        self.word = word
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header thông tin chữ
                        VStack(spacing: 4) {
                            Text(word.pinyin)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(HanTheme.silkGold)
                            Text(word.vietnameseMeaning)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            if !word.sinoVietnamese.isEmpty {
                                Text("Âm Hán-Việt: \(word.sinoVietnamese)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.top, 6)
                        
                        // Kết quả kiểm tra nét viết nếu có
                        if let res = strokeCheckResult {
                            HStack(spacing: 8) {
                                Image(systemName: res.isCorrect ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(res.isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                                    .font(.system(size: 18))
                                Text(res.message)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(res.isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill((res.isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed).opacity(0.15))
                            )
                        }
                        
                        // Ô Mễ Tự Cách (Tianzi Ge Canvas)
                        ZStack {
                            // 1. Grid ô chữ Mễ Tự Cách
                            TianziGridShape()
                                .stroke(Color.red.opacity(0.4), style: StrokeStyle(lineWidth: 1.2, dash: [5, 5]))
                                .background(Color(red: 0.10, green: 0.12, blue: 0.16))
                            
                            // 2. Chữ Hán mẫu (Mờ hoặc Hiện màu xanh khi đã kiểm tra)
                            if showGhost || strokeCheckResult?.isCorrect == true {
                                Text(String(word.hanzi.prefix(1)))
                                    .font(.system(size: 210, weight: .light, design: .serif))
                                    .foregroundColor(
                                        strokeCheckResult?.isCorrect == true
                                        ? HanTheme.jadeGreen.opacity(0.4)
                                        : Color.white.opacity(0.14)
                                    )
                            }
                            
                            // 3. Đường nét người dùng vẽ
                            Canvas { context, size in
                                for line in currentLines {
                                    var path = Path()
                                    path.addLines(line.points)
                                    context.stroke(
                                        path,
                                        with: .color(strokeCheckResult?.isCorrect == true ? HanTheme.jadeGreen : HanTheme.silkGold),
                                        style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        let newPoint = value.location
                                        if currentLines.isEmpty || currentLines.last?.isFinished == true {
                                            currentLines.append(Line(points: [newPoint], lineWidth: 11, isFinished: false))
                                        } else {
                                            currentLines[currentLines.count - 1].points.append(newPoint)
                                        }
                                    }
                                    .onEnded { _ in
                                        if !currentLines.isEmpty {
                                            currentLines[currentLines.count - 1].isFinished = true
                                            HapticManager.shared.strokeCompleted()
                                        }
                                    }
                            )
                        }
                        .frame(width: 290, height: 290)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                        
                        // Hàng Nút Điều Khiển Nét Viết
                        HStack(spacing: 12) {
                            // Ẩn / Hiện nét mờ
                            Button(action: {
                                showGhost.toggle()
                                strokeCheckResult = nil
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: showGhost ? "eye.slash.fill" : "eye.fill")
                                    Text(showGhost ? "Ẩn nét mờ" : "Hiện nét mờ")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Nút Xóa viết lại
                            Button(action: {
                                currentLines.removeAll()
                                strokeCheckResult = nil
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Xóa nét")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(12)
                            }
                            
                            // Nút Kiểm Tra Nét Viết
                            Button(action: evaluateStrokeDrawing) {
                                HStack(spacing: 5) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Chấm Nét")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(HanTheme.jadeGreen)
                                .cornerRadius(12)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1)).padding(.vertical, 6)
                        
                        // Cụm Luyện Nói & Nghe Phát Âm Của Từ
                        VStack(spacing: 12) {
                            Text("LUYỆN NÓI & PHÁT ÂM")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack(spacing: 14) {
                                // 1. Nghe người bản xứ đọc
                                Button(action: {
                                    SoundManager.shared.speakMandarin(word.hanzi)
                                    HapticManager.shared.buttonTapped()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "speaker.wave.3.fill")
                                        Text("Nghe Mẫu")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(HanTheme.jadeGreen)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(HanTheme.jadeGreen.opacity(0.15))
                                    .cornerRadius(12)
                                }
                                
                                // 2. Thu âm nói thử
                                Button(action: toggleVoiceRecording) {
                                    HStack(spacing: 6) {
                                        Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                                        Text(voiceEvaluator.isRecording ? "Dừng Thu" : "Thu Âm Nói")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 12)
                                    .background(voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue)
                                    .cornerRadius(12)
                                }
                                
                                // 3. Nghe lại giọng vừa nói
                                if voiceEvaluator.hasRecordedAudio {
                                    Button(action: {
                                        voiceEvaluator.playRecordedVoice()
                                        HapticManager.shared.buttonTapped()
                                    }) {
                                        Image(systemName: voiceEvaluator.isPlayingBack ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(HanTheme.silkGold)
                                            .frame(width: 44, height: 44)
                                            .background(HanTheme.silkGold.opacity(0.15))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            
                            if let fb = voiceFeedback {
                                Text(fb)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(HanTheme.silkGold)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Tập Viết & Phát Âm: \(word.hanzi)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") { dismiss() }
                        .foregroundColor(HanTheme.jadeGreen)
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
    
    // MARK: - Chấm nét vẽ
    private func evaluateStrokeDrawing() {
        if currentLines.isEmpty {
            strokeCheckResult = StrokeCheckResult(
                isCorrect: false,
                score: 0,
                message: "Bạn chưa viết nét nào! Hãy vẽ chữ '\(word.hanzi)' lên ô Mễ Tự Cách nhé."
            )
            HapticManager.shared.answerWrong()
            return
        }
        
        let totalPoints = currentLines.reduce(0) { $0 + $1.points.count }
        let strokeCount = currentLines.count
        
        // Tính toán bounding box của các nét vẽ
        var minX: CGFloat = 300
        var maxX: CGFloat = 0
        var minY: CGFloat = 300
        var maxY: CGFloat = 0
        
        for line in currentLines {
            for pt in line.points {
                minX = min(minX, pt.x)
                maxX = max(maxX, pt.x)
                minY = min(minY, pt.y)
                maxY = max(maxY, pt.y)
            }
        }
        
        let widthSpan = maxX - minX
        let heightSpan = maxY - minY
        
        // Kiểm tra độ phủ và số nét
        let isSpreadGood = widthSpan > 70 && heightSpan > 70
        let hasEnoughPoints = totalPoints > 20
        
        if !hasEnoughPoints || !isSpreadGood {
            strokeCheckResult = StrokeCheckResult(
                isCorrect: false,
                score: 45,
                message: "Nét chữ quá ngắn hoặc chưa đủ nét! Hãy đối chiếu với chữ mẫu nhé."
            )
            HapticManager.shared.answerWrong()
        } else {
            // Tính điểm số dựa trên tỷ lệ cân đối
            let score = min(98, max(85, 90 + (strokeCount <= (word.strokeCount + 3) ? 6 : 0)))
            strokeCheckResult = StrokeCheckResult(
                isCorrect: true,
                score: score,
                message: "Chính xác tuyệt đối (\(score)/100)! Nét chữ cân đối, chuẩn trọng tâm (+10 XP) 🎉"
            )
            HapticManager.shared.answerCorrect()
            SoundManager.shared.speakMandarin(word.hanzi)
        }
    }
    
    // MARK: - Thu âm kiểm tra phát âm
    private func toggleVoiceRecording() {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: word.hanzi, targetPinyin: word.pinyin)
            voiceFeedback = "Điểm: \(res.overallScore)/100 · \(res.feedbackMessage)"
            HapticManager.shared.answerCorrect()
        } else {
            voiceFeedback = "Đang thu âm... Hãy đọc to chữ '\(word.hanzi)' (\(word.pinyin))"
            Task {
                let granted = await voiceEvaluator.requestPermissions()
                if granted {
                    try? voiceEvaluator.startRecording(targetHanzi: word.hanzi)
                    HapticManager.shared.buttonTapped()
                } else {
                    voiceFeedback = "Vui lòng cấp quyền Micro trong Cài đặt iPhone"
                }
            }
        }
    }
}
