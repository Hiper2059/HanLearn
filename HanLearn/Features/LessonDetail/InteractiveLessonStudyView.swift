//
//  InteractiveLessonStudyView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Phương pháp sư phạm 3 giai đoạn:
//  1. Dạy học từng từ (Nghe audio, Tập viết nét TianziGe, Thu âm chấm điểm)
//  2. Luyện tập Nối từ (Match Hanzi <-> Nghĩa tiếng Việt)
//  3. Củng cố trắc nghiệm & Hoàn thành bài học
//

import SwiftUI
import SwiftData

public struct InteractiveLessonStudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    public let lesson: HSKLesson
    
    @State private var studyStage: StudyStage = .learningWords
    @State private var currentWordIndex: Int = 0
    
    // Thu âm kiểm tra phát âm
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var evaluationResult: VoiceEvaluationResult?
    @State private var isShowingVoiceResult: Bool = false
    @State private var selectedWordForStroke: HSKWord?
    
    // Nối từ (Stage 2)
    @State private var selectedHanzi: String? = nil
    @State private var selectedMeaning: String? = nil
    @State private var matchedPairs: Set<String> = []
    @State private var scrambledMeanings: [String] = []
    
    public enum StudyStage {
        case learningWords
        case matchingWords
        case completed
    }
    
    private var words: [HSKWord] {
        lesson.vocabularyList
    }
    
    private var currentWord: HSKWord? {
        guard !words.isEmpty, currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }
    
    public init(lesson: HSKLesson) {
        self.lesson = lesson
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header tiến độ 3 giai đoạn
                    stageProgressBar
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                    
                    switch studyStage {
                    case .learningWords:
                        wordTeachingStage
                    case .matchingWords:
                        wordMatchingStage
                    case .completed:
                        completionStage
                    }
                }
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Thoát") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .sheet(item: $selectedWordForStroke) { word in
                StrokeCanvasView(word: word)
            }
            .onAppear {
                prepareMatchingStage()
            }
        }
    }
    
    // MARK: - STAGE PROGRESS BAR
    private var stageProgressBar: some View {
        HStack(spacing: 8) {
            stagePill(title: "1. Học từ vựng", isActive: studyStage == .learningWords, isDone: studyStage == .matchingWords || studyStage == .completed)
            stagePill(title: "2. Nối từ", isActive: studyStage == .matchingWords, isDone: studyStage == .completed)
            stagePill(title: "3. Hoàn thành", isActive: studyStage == .completed, isDone: studyStage == .completed)
        }
    }
    
    private func stagePill(title: String, isActive: Bool, isDone: Bool) -> some View {
        Text(title)
            .font(.system(size: 11, weight: isActive ? .bold : .medium))
            .foregroundColor(isActive ? .black : (isDone ? HanTheme.jadeGreen : .white.opacity(0.5)))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? HanTheme.jadeGreen : (isDone ? HanTheme.jadeGreen.opacity(0.15) : Color.white.opacity(0.06)))
            )
    }
    
    // MARK: - GIAI ĐOẠN 1: DẠY HỌC TỪNG TỪ (WORD-BY-WORD TEACHING)
    private var wordTeachingStage: some View {
        VStack(spacing: 14) {
            if let word = currentWord {
                // Chỉ số từ
                HStack {
                    Text("Từ \(currentWordIndex + 1) / \(words.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                    Spacer()
                    Text("HSK \(word.hskLevel)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(HanTheme.vermilionRed.opacity(0.2))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Thẻ từ vựng Mễ Tự Cách trung tâm
                        VStack(spacing: 12) {
                            TianziGeView(
                                character: word.hanzi,
                                size: 160,
                                showGrid: true,
                                gridColor: Color.red.opacity(0.4),
                                textColor: .white
                            )
                            
                            VStack(spacing: 4) {
                                Text(word.pinyin)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(HanTheme.silkGold)
                                
                                if !word.sinoVietnamese.isEmpty {
                                    Text("Hán-Việt: \(word.sinoVietnamese)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Text(word.vietnameseMeaning)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(HanTheme.jadeGreen)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.11, green: 0.13, blue: 0.18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)
                        
                        // 3 Nút Tương tác cốt lõi: Nghe, Viết, Thu âm
                        HStack(spacing: 12) {
                            // 1. Nghe phát âm
                            Button(action: {
                                SoundManager.shared.speakMandarin(word.hanzi)
                                HapticManager.shared.buttonTapped()
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 18))
                                    Text("Nghe phát âm")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(HanTheme.jadeGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(HanTheme.jadeGreen.opacity(0.14))
                                .cornerRadius(14)
                            }
                            
                            // 2. Tập viết nét
                            Button(action: {
                                selectedWordForStroke = word
                                HapticManager.shared.buttonTapped()
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "pencil.tip.crop.circle")
                                        .font(.system(size: 18))
                                    Text("Tập viết nét")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(HanTheme.silkGold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(HanTheme.silkGold.opacity(0.14))
                                .cornerRadius(14)
                            }
                            
                            // 3. Thu âm kiểm tra
                            Button(action: {
                                toggleVoiceCheck(for: word)
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 18))
                                    Text(voiceEvaluator.isRecording ? "Đang thu..." : "Luyện nói")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background((voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue).opacity(0.14))
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Kết quả chấm phát âm (Nếu vừa thu âm)
                        if isShowingVoiceResult, let res = evaluationResult {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: res.overallScore >= 80 ? "checkmark.seal.fill" : "waveform.badge.exclamationmark")
                                        .foregroundColor(res.overallScore >= 80 ? HanTheme.jadeGreen : HanTheme.silkGold)
                                    Text("Điểm phát âm: \(res.overallScore)/100")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(res.overallScore >= 80 ? HanTheme.jadeGreen : HanTheme.silkGold)
                                    Spacer()
                                    Button("Đóng") {
                                        isShowingVoiceResult = false
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Text(res.feedbackMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(14)
                            .background(Color(red: 0.13, green: 0.15, blue: 0.20))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                        
                        // Ví dụ câu ngữ cảnh
                        if !word.exampleSentenceHanzi.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("VÍ DỤ NGỮ CẢNH:")
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
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                            .padding(.horizontal, 16)
                        }
                    }
                }
                
                Spacer(minLength: 8)
                
                // Nút Điều hướng từ vựng
                HStack(spacing: 12) {
                    if currentWordIndex > 0 {
                        Button(action: {
                            currentWordIndex -= 1
                            isShowingVoiceResult = false
                            HapticManager.shared.buttonTapped()
                        }) {
                            Text("Từ Trước")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(14)
                        }
                    }
                    
                    Button(action: advanceWordOrFinish) {
                        Text(currentWordIndex + 1 < words.count ? "Từ Tiếp Theo →" : "Đã Thuộc Hết → Nối Từ")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.jadeGreen)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                Text("Bài học này chưa có từ vựng.")
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - GIAI ĐOẠN 2: LUYỆN TẬP NỐI TỪ (WORD PAIR MATCHING)
    private var wordMatchingStage: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("BÀI TẬP NỐI TỪ ĐÃ HỌC")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                Text("Chạm một chữ Hán, sau đó chạm nghĩa tiếng Việt tương ứng")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 8)
            
            // Thanh tiến độ ghép từ
            HStack {
                Text("Đã ghép đúng: \(matchedPairs.count) / \(words.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(HanTheme.jadeGreen)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // 2 Cột nối từ: Cột Hán tự vs Cột Nghĩa tiếng Việt
            ScrollView {
                HStack(alignment: .top, spacing: 14) {
                    // Cột 1: Chữ Hán
                    VStack(spacing: 10) {
                        ForEach(words) { word in
                            let isMatched = matchedPairs.contains(word.hanzi)
                            let isSelected = selectedHanzi == word.hanzi
                            
                            Button(action: {
                                guard !isMatched else { return }
                                selectedHanzi = word.hanzi
                                checkMatch()
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack {
                                    Text(word.hanzi)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(isMatched ? .gray : .white)
                                    Spacer()
                                    if isMatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(HanTheme.jadeGreen)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isMatched ? Color.white.opacity(0.04) : (isSelected ? HanTheme.jadeGreen.opacity(0.2) : Color.white.opacity(0.08)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
                                        )
                                )
                            }
                            .disabled(isMatched)
                        }
                    }
                    
                    // Cột 2: Nghĩa tiếng Việt (Đã xáo trộn)
                    VStack(spacing: 10) {
                        ForEach(scrambledMeanings, id: \.self) { meaning in
                            let matchingWord = words.first { $0.vietnameseMeaning == meaning }
                            let isMatched = matchingWord != nil && matchedPairs.contains(matchingWord!.hanzi)
                            let isSelected = selectedMeaning == meaning
                            
                            Button(action: {
                                guard !isMatched else { return }
                                selectedMeaning = meaning
                                checkMatch()
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack {
                                    Text(meaning)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(isMatched ? .gray : .white)
                                        .lineLimit(2)
                                    Spacer()
                                    if isMatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(HanTheme.jadeGreen)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isMatched ? Color.white.opacity(0.04) : (isSelected ? HanTheme.silkGold.opacity(0.2) : Color.white.opacity(0.08)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? HanTheme.silkGold : Color.clear, lineWidth: 1.5)
                                        )
                                )
                            }
                            .disabled(isMatched)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Nút hoàn thành khi ghép xong hết
            if matchedPairs.count == words.count && !words.isEmpty {
                Button(action: {
                    withAnimation {
                        studyStage = .completed
                        awardXP()
                    }
                }) {
                    Text("Hoàn Thành Nối Từ & Nhận Thưởng 🎉")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HanTheme.jadeGreen)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - GIAI ĐOẠN 3: HOÀN THÀNH BÀI HỌC (COMPLETION)
    private var completionStage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundColor(HanTheme.silkGold)
            
            Text("Xuất Sắc! Bạn Đã Làm Chủ Bài Học")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 10) {
                Text("+50 Điểm Kinh Nghiệm (XP)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(HanTheme.jadeGreen)
                
                Text("Đã nạp \(words.count) từ vựng mới vào vòng lặp ôn tập ngắt quãng (SM-2).")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.06))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Xong & Quay Lại")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - LOGIC
    private func advanceWordOrFinish() {
        if currentWordIndex + 1 < words.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentWordIndex += 1
                isShowingVoiceResult = false
            }
            HapticManager.shared.buttonTapped()
        } else {
            // Chuyển sang giai đoạn nối từ
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                studyStage = .matchingWords
            }
            HapticManager.shared.answerCorrect()
        }
    }
    
    private func prepareMatchingStage() {
        scrambledMeanings = words.map { $0.vietnameseMeaning }.shuffled()
    }
    
    private func checkMatch() {
        guard let hanzi = selectedHanzi, let meaning = selectedMeaning else { return }
        
        if let targetWord = words.first(where: { $0.hanzi == hanzi }), targetWord.vietnameseMeaning == meaning {
            // Khớp đúng
            matchedPairs.insert(hanzi)
            selectedHanzi = nil
            selectedMeaning = nil
            HapticManager.shared.answerCorrect()
            SoundManager.shared.speakMandarin(hanzi)
        } else {
            // Ghép sai
            HapticManager.shared.answerWrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                selectedHanzi = nil
                selectedMeaning = nil
            }
        }
    }
    
    private func toggleVoiceCheck(for word: HSKWord) {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: word.hanzi, targetPinyin: word.pinyin)
            evaluationResult = res
            isShowingVoiceResult = true
            HapticManager.shared.answerCorrect()
        } else {
            Task {
                let granted = await voiceEvaluator.requestPermissions()
                if granted {
                    try? voiceEvaluator.startRecording(targetHanzi: word.hanzi)
                    HapticManager.shared.buttonTapped()
                }
            }
        }
    }
    
    private func awardXP() {
        if let progress = userProgressList.first {
            progress.totalXP += 50
            progress.completedLessonsCount += 1
            progress.recordDailyActivity()
            try? modelContext.save()
        }
    }
}
