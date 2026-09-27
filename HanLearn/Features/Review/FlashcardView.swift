//
//  FlashcardView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 2: Rich Flashcard - Mễ Tự Cách TianziGe + Phát âm bản xứ + Tập viết nét + Thu âm luyện nói + SM-2
//

import SwiftUI

public struct FlashcardView: View {
    public let word: HSKWord
    public let cardIndex: Int
    public let totalCards: Int
    public let onGrade: (SRSGrade) -> Void
    
    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var showingStrokeCanvas: Bool = false
    
    // Voice check
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var voiceFeedback: String? = nil
    
    public init(
        word: HSKWord,
        cardIndex: Int = 1,
        totalCards: Int = 1,
        onGrade: @escaping (SRSGrade) -> Void
    ) {
        self.word = word
        self.cardIndex = cardIndex
        self.totalCards = totalCards
        self.onGrade = onGrade
    }
    
    public var body: some View {
        ZStack {
            // Mặt sau (Nghĩa, Pinyin, Hán Việt, Ví dụ, 4 nút SRS)
            cardBack
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            // Mặt trước (Ô Mễ Tự Cách, Badge HSK, Nút Audio, Tập viết, Thu âm)
            cardFront
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(maxWidth: 420)
        .frame(height: 500)
        .offset(x: dragOffset.width * 0.4)
        .rotationEffect(.degrees(Double(dragOffset.width / 28)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if value.translation.width > 80 {
                        HapticManager.shared.answerCorrect()
                        onGrade(.good)
                    } else if value.translation.width < -80 {
                        HapticManager.shared.answerWrong()
                        onGrade(.again)
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
        )
        .sheet(isPresented: $showingStrokeCanvas) {
            StrokeCanvasView(word: word)
        }
    }
    
    // MARK: - MẶT TRƯỚC (FRONT)
    private var cardFront: some View {
        VStack(spacing: 0) {
            // Thanh trạng thái trên đỉnh thẻ
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(HanTheme.vermilionRed)
                        .frame(width: 8, height: 8)
                    Text("HSK \(word.hskLevel)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            
            Spacer()
            
            // Ô Mễ Tự Cách (Tianzi Ge) truyền thống
            TianziGeView(
                character: word.hanzi,
                size: 180,
                showGrid: true,
                gridColor: Color(red: 0.88, green: 0.35, blue: 0.30).opacity(0.45),
                textColor: .white
            )
            .shadow(color: Color.black.opacity(0.5), radius: 16, y: 8)
            
            if let feedback = voiceFeedback {
                Text(feedback)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            // 3 Nút Hành Động: Phát âm, Tập viết, Thu âm
            HStack(spacing: 10) {
                // 1. Nút phát âm
                Button(action: {
                    SoundManager.shared.speakMandarin(word.hanzi)
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Phát âm")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HanTheme.jadeGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(HanTheme.jadeGreen.opacity(0.15))
                    .cornerRadius(12)
                }
                
                // 2. Nút Tập viết
                Button(action: {
                    showingStrokeCanvas = true
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.tip.crop.circle")
                        Text("Tập viết")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(12)
                }
                
                // 3. Nút Thu âm nói thử
                Button(action: {
                    handleVoiceCheck()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                        Text(voiceEvaluator.isRecording ? "Dừng" : "Nói thử")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background((voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue).opacity(0.15))
                    .cornerRadius(12)
                }
            }
            
            // Gợi ý chạm để lật
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Nhấn để lật thẻ · Vuốt để chấm điểm")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.55))
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackgroundView)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
            HapticManager.shared.buttonTapped()
        }
    }
    
    // MARK: - MẶT SAU (BACK)
    private var cardBack: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Header mặt sau: Hán tự & Loa
                    HStack {
                        Text(word.hanzi)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            SoundManager.shared.speakMandarin(word.hanzi)
                            HapticManager.shared.buttonTapped()
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                                .font(.system(size: 18))
                                .padding(9)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    
                    // Pinyin & Hán Việt
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("PINYIN")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(HanTheme.silkGold.opacity(0.8))
                            Text(word.pinyin)
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(HanTheme.silkGold)
                        }
                        
                        if !word.sinoVietnamese.isEmpty {
                            Divider()
                                .frame(height: 26)
                                .background(Color.white.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("HÁN VIỆT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(word.sinoVietnamese)
                                    .font(.system(size: 18, weight: .semibold, design: .serif))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 20)
                    
                    // Nghĩa tiếng Việt
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ý NGHĨA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(HanTheme.jadeGreen)
                        Text(word.vietnameseMeaning)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Câu ví dụ
                    if !word.exampleSentenceHanzi.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("VÍ DỤ NGỮ CẢNH")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(word.exampleSentenceHanzi)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(word.exampleSentencePinyin)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(HanTheme.silkGold.opacity(0.85))
                            
                            Text(word.exampleSentenceTranslation)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                        .padding(.horizontal, 18)
                    }
                }
            }
            
            // 4 Nút đánh giá SuperMemo-2 (SM-2)
            VStack(spacing: 6) {
                Text("ĐÁNH GIÁ ĐỘ NHỚ (SM-2)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 8) {
                    srsGradeButton(title: "Quên", subtitle: "0 ngày", grade: .again, color: HanTheme.vermilionRed)
                    srsGradeButton(title: "Khó", subtitle: "1 ngày", grade: .hard, color: .orange)
                    srsGradeButton(title: "Tốt", subtitle: "3 ngày", grade: .good, color: HanTheme.jadeGreen)
                    srsGradeButton(title: "Dễ", subtitle: "7 ngày", grade: .easy, color: HanTheme.silkGold)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 16)
            .padding(.top, 8)
            .background(Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackgroundView)
    }
    
    private func srsGradeButton(title: String, subtitle: String, grade: SRSGrade, color: Color) -> some View {
        Button(action: {
            onGrade(grade)
            if grade == .again {
                HapticManager.shared.answerWrong()
            } else {
                HapticManager.shared.answerCorrect()
            }
        }) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
        }
    }
    
    private var cardBackgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.11, green: 0.13, blue: 0.19),
                            Color(red: 0.07, green: 0.09, blue: 0.13)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        }
        .shadow(color: Color.black.opacity(0.6), radius: 20, y: 10)
    }
    
    private func handleVoiceCheck() {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: word.hanzi, targetPinyin: word.pinyin)
            voiceFeedback = "Điểm: \(res.overallScore)/100 · \(res.isExactMatch ? "Chuẩn xác 🎉" : "Khá tốt 👍")"
            HapticManager.shared.answerCorrect()
        } else {
            voiceFeedback = "Đang lắng nghe..."
            Task {
                let granted = await voiceEvaluator.requestPermissions()
                if granted {
                    try? voiceEvaluator.startRecording(targetHanzi: word.hanzi)
                    HapticManager.shared.buttonTapped()
                } else {
                    voiceFeedback = "Vui lòng cấp quyền Micro trong Cài đặt"
                }
            }
        }
    }
}
