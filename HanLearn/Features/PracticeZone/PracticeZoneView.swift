//
//  PracticeZoneView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 3: Hệ Thống "Máy Tự Check" (Rule-based Practice Zone) 🚀 Core Feature
//  - Auto-Dictation: Nghe chép chính tả (1.0x, 1.25x) + Levenshtein Distance tự động bôi đỏ chữ sai/thiếu
//  - Sentence Builder: Khối từ kéo-thả / chạm ghép câu đối chiếu mảng đáp án
//  - Reading & Tap-to-Translate: Bôi đậm ngữ pháp & chạm tra từ siêu tốc
//

import SwiftUI
import SwiftData

public struct PracticeZoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    @State private var selectedMode: PracticeMode = .dictation
    
    public enum PracticeMode: String, CaseIterable {
        case dictation = "Nghe Chép"
        case sentenceBuilder = "Ghép Câu"
        case speaking = "Luyện Nói AI"
        case reading = "Bài Đọc"
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Nền đen than mờ ảo Á Đông
                Color(red: 0.05, green: 0.06, blue: 0.09)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Thanh chọn chế độ 4 nút
                    modeSelectorBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedMode {
                            case .dictation:
                                AutoDictationModule()
                            case .sentenceBuilder:
                                SentenceBuilderModule()
                            case .speaking:
                                VoiceSpeakingCheckModule()
                            case .reading:
                                ReadingTranslateModule()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Máy Tự Check")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var modeSelectorBar: some View {
        HStack(spacing: 6) {
            ForEach(PracticeMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                    HapticManager.shared.buttonTapped()
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: selectedMode == mode ? .bold : .medium))
                        .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedMode == mode {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(HanTheme.jadeGreen)
                                        .shadow(color: HanTheme.jadeGreen.opacity(0.4), radius: 8, y: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.06))
                                }
                            }
                        )
                }
            }
        }
    }
}

// MARK: - 1. AUTO-DICTATION (Nghe - Chép chính tả với Levenshtein Distance)

struct AutoDictationModule: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    struct DictationItem {
        let audioText: String
        let pinyin: String
        let vietnameseMeaning: String
        let hskLevel: Int
    }
    
    private let sampleItems: [DictationItem] = [
        DictationItem(audioText: "你好，很高兴认识你！", pinyin: "Nǐ hǎo, hěn gāoxìng rènshi nǐ!", vietnameseMeaning: "Xin chào, rất vui được làm quen với bạn!", hskLevel: 1),
        DictationItem(audioText: "我想买一个苹果。", pinyin: "Wǒ xiǎng mǎi yí gè píngguǒ.", vietnameseMeaning: "Tôi muốn mua một quả táo.", hskLevel: 1),
        DictationItem(audioText: "这个衣服多少钱一件？", pinyin: "Zhège yīfu duōshao qián yí jiàn?", vietnameseMeaning: "Bộ quần áo này bao nhiêu tiền một chiếc?", hskLevel: 2),
        DictationItem(audioText: "明天我们一起去图书馆吧。", pinyin: "Míngtiān wǒmen yìqǐ qù túshūguǎn ba.", vietnameseMeaning: "Ngày mai chúng ta cùng nhau đi thư viện nhé.", hskLevel: 2),
        DictationItem(audioText: "虽然学习很难，但我会坚持。", pinyin: "Suīrán xuéxí hěn nán, dàn wǒ huì jiānchí.", vietnameseMeaning: "Tuy học tập rất khó, nhưng tôi sẽ kiên trì.", hskLevel: 3)
    ]
    
    @State private var currentIndex: Int = 0
    @State private var userInput: String = ""
    @State private var isChecked: Bool = false
    @State private var result: LevenshteinResult? = nil
    @State private var correctStreak: Int = 0
    @State private var showCelebration: Bool = false
    
    private var currentItem: DictationItem {
        sampleItems[currentIndex % sampleItems.count]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header bài tập
            HStack {
                Text("HSK \(currentItem.hskLevel) · Câu \(currentIndex + 1)/\(sampleItems.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                if correctStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(correctStreak) đúng liên tiếp")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Cụm Nghe Audio (1.0x & 1.25x)
            VStack(spacing: 14) {
                Text("BẤM NGHE VÀ GÕ LẠI CHÍNH TẢ")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 16) {
                    // Nút phát 1.0x
                    Button(action: {
                        SoundManager.shared.speakMandarin(currentItem.audioText, slowSpeed: false)
                        HapticManager.shared.buttonTapped()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.3.fill")
                            Text("Tốc độ chuẩn (1.0x)")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(HanTheme.jadeGreen)
                        .cornerRadius(14)
                    }
                    
                    // Nút phát chậm 1.25x / 0.75x
                    Button(action: {
                        SoundManager.shared.speakMandarin(currentItem.audioText, slowSpeed: true)
                        HapticManager.shared.buttonTapped()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "tortoise.fill")
                            Text("Chậm (0.75x)")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 13))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(HanTheme.silkGold.opacity(0.15))
                        .cornerRadius(14)
                    }
                }
                
                Text("Nghĩa: \(currentItem.vietnameseMeaning)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(cardBackground)
            
            // Ô Gõ Văn Bản
            VStack(alignment: .leading, spacing: 10) {
                Text("GÕ CHỮ HÁN HOẶC PINYIN:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Nhập nội dung bạn nghe được vào đây...", text: $userInput)
                    .font(.system(size: 18))
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(14)
                    .foregroundColor(.white)
                    .disabled(isChecked)
            }
            .padding(16)
            .background(cardBackground)
            
            // KẾT QUẢ "MÁY TỰ CHECK" BẰNG LEVENSHTEIN
            if isChecked, let res = result {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: res.isExactMatch ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(res.isExactMatch ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                            .font(.system(size: 22))
                        
                        Text(res.isExactMatch ? "Chính xác tuyệt đối! (+20 XP)" : "Có ký tự chưa chính xác (\(res.accuracyPercentage)%)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(res.isExactMatch ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                        
                        Spacer()
                    }
                    
                    // So khớp ký tự trực quan (Bôi đỏ chữ sai/thiếu)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ĐỐI CHIẾU CHI TIẾT (MÁY TỰ CHẤM):")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        
                        HStack(spacing: 4) {
                            ForEach(res.tokens) { token in
                                switch token.type {
                                case .correct:
                                    Text(token.displayChar)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(HanTheme.jadeGreen)
                                        .padding(4)
                                        .background(HanTheme.jadeGreen.opacity(0.2))
                                        .cornerRadius(6)
                                case .wrong(let expected):
                                    VStack(spacing: 2) {
                                        Text(token.displayChar)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(HanTheme.vermilionRed)
                                        Text("(\(expected))")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(4)
                                    .background(HanTheme.vermilionRed.opacity(0.2))
                                    .cornerRadius(6)
                                case .missing(let expected):
                                    VStack(spacing: 2) {
                                        Text("＿")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(HanTheme.vermilionRed)
                                        Text("(\(expected))")
                                            .font(.system(size: 11))
                                            .foregroundColor(HanTheme.vermilionRed)
                                    }
                                    .padding(4)
                                    .background(HanTheme.vermilionRed.opacity(0.15))
                                    .cornerRadius(6)
                                case .extra(let actual):
                                    Text(actual)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.orange)
                                        .strikethrough()
                                        .padding(4)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    // Đáp án gốc
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ĐÁP ÁN CHUẨN:")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Text(currentItem.audioText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text(currentItem.pinyin)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(HanTheme.silkGold)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(res.isExactMatch ? HanTheme.jadeGreen.opacity(0.1) : HanTheme.vermilionRed.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(res.isExactMatch ? HanTheme.jadeGreen.opacity(0.3) : HanTheme.vermilionRed.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Nút Thao Tác (Chấm điểm / Câu tiếp theo)
            if !isChecked {
                Button(action: checkAnswer) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Máy Tự Check (Chấm điểm)")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.white)
                    .background(userInput.isEmpty ? Color.gray.opacity(0.4) : HanTheme.jadeGreen)
                    .cornerRadius(16)
                }
                .disabled(userInput.isEmpty)
            } else {
                Button(action: nextQuestion) {
                    HStack {
                        Text("Câu Tiếp Theo")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.white)
                    .background(HanTheme.primaryGradient)
                    .cornerRadius(16)
                }
            }
        }
        .onAppear {
            SoundManager.shared.speakMandarin(currentItem.audioText)
        }
    }
    
    private func checkAnswer() {
        let res = LevenshteinEngine.evaluate(input: userInput, target: currentItem.audioText)
        result = res
        isChecked = true
        
        if res.isExactMatch {
            HapticManager.shared.answerCorrect()
            correctStreak += 1
            if let prog = userProgressList.first {
                prog.recordDailyActivity()
                prog.totalXP += 20
            }
            if correctStreak % 5 == 0 {
                showCelebration = true
            }
        } else {
            HapticManager.shared.answerWrong()
            correctStreak = 0
            // Tự động gom lỗi sai vào Sổ tay lỗi sai (Mistake Book)
            let mistake = UserMistake(
                questionType: "dictation",
                hskLevel: currentItem.hskLevel,
                promptText: currentItem.vietnameseMeaning,
                audioText: currentItem.audioText,
                targetAnswer: currentItem.audioText,
                userAnswer: userInput,
                explanation: "Đáp án đúng: \(currentItem.audioText) (\(currentItem.pinyin))"
            )
            modelContext.insert(mistake)
        }
    }
    
    private func nextQuestion() {
        currentIndex = (currentIndex + 1) % sampleItems.count
        userInput = ""
        isChecked = false
        result = nil
        SoundManager.shared.speakMandarin(currentItem.audioText)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(red: 0.10, green: 0.13, blue: 0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

// MARK: - 2. SENTENCE BUILDER (Sắp xếp câu với mảng nhiều đáp án đúng)

struct SentenceBuilderModule: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    private let exercises = SentenceBuilderEngine.getSampleExercises(level: 1)
    @State private var currentIndex: Int = 0
    @State private var assembledWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var isChecked: Bool = false
    @State private var isCorrect: Bool = false
    
    private var currentExercise: SentenceExercise {
        exercises[currentIndex % exercises.count]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Đề bài
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SẮP XẾP CÂU HOÀN CHỈNH · HSK \(currentExercise.hskLevel)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                    Spacer()
                }
                
                Text(currentExercise.vietnameseMeaning)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            
            // Vùng Ghép Câu (Drop Zone)
            VStack(alignment: .leading, spacing: 10) {
                Text("CÂU CỦA BẠN (CHẠM ĐỂ HOÀN TÁC):")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                if assembledWords.isEmpty {
                    Text("Chạm vào các khối từ bên dưới để ghép câu...")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
                } else {
                    HStack(spacing: 8) {
                        ForEach(Array(assembledWords.enumerated()), id: \.offset) { index, word in
                            Button(action: {
                                if !isChecked {
                                    assembledWords.remove(at: index)
                                    availableWords.append(word)
                                    HapticManager.shared.buttonTapped()
                                }
                            }) {
                                Text(word)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(HanTheme.jadeGreen)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.08, green: 0.10, blue: 0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(assembledWords.isEmpty ? Color.white.opacity(0.1) : HanTheme.jadeGreen.opacity(0.5), lineWidth: 1.5)
                    )
            )
            
            // Khối Từ Ban Đầu (Word Blocks)
            VStack(alignment: .leading, spacing: 10) {
                Text("KHỐI TỪ VỰNG:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 10) {
                    ForEach(Array(availableWords.enumerated()), id: \.offset) { index, word in
                        Button(action: {
                            if !isChecked {
                                availableWords.remove(at: index)
                                assembledWords.append(word)
                                HapticManager.shared.buttonTapped()
                            }
                        }) {
                            Text(word)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(cardBackground)
            
            // Kết quả chấm điểm
            if isChecked {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                            .font(.system(size: 22))
                        Text(isCorrect ? "Chính xác tuyệt đối! (+15 XP)" : "Chưa chính xác!")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                    }
                    
                    Text("Giải thích ngữ pháp:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    Text(currentExercise.grammarPoint)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isCorrect ? HanTheme.jadeGreen.opacity(0.12) : HanTheme.vermilionRed.opacity(0.12))
                .cornerRadius(18)
            }
            
            // Nút kiểm tra
            if !isChecked {
                Button(action: checkSentence) {
                    HStack {
                        Image(systemName: "arrow.triangle.merge")
                        Text("Máy Tự Check Cấu Trúc")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.white)
                    .background(assembledWords.isEmpty ? Color.gray.opacity(0.4) : HanTheme.jadeGreen)
                    .cornerRadius(16)
                }
                .disabled(assembledWords.isEmpty)
            } else {
                Button(action: nextSentence) {
                    Text("Câu Tiếp Theo")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .background(HanTheme.primaryGradient)
                        .cornerRadius(16)
                }
            }
        }
        .onAppear {
            loadExercise()
        }
    }
    
    private func loadExercise() {
        assembledWords = []
        availableWords = currentExercise.words.shuffled()
        isChecked = false
        isCorrect = false
    }
    
    private func checkSentence() {
        isCorrect = SentenceBuilderEngine.evaluate(userBlocks: assembledWords, validStructures: currentExercise.validStructures)
        isChecked = true
        
        if isCorrect {
            HapticManager.shared.answerCorrect()
            if let prog = userProgressList.first {
                prog.recordDailyActivity()
                prog.totalXP += 15
            }
        } else {
            HapticManager.shared.answerWrong()
            let mistake = UserMistake(
                questionType: "sentence_builder",
                hskLevel: currentExercise.hskLevel,
                promptText: currentExercise.vietnameseMeaning,
                targetAnswer: currentExercise.validStructures.first?.joined() ?? "",
                userAnswer: assembledWords.joined(),
                explanation: currentExercise.grammarPoint
            )
            modelContext.insert(mistake)
        }
    }
    
    private func nextSentence() {
        currentIndex = (currentIndex + 1) % exercises.count
        loadExercise()
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(red: 0.10, green: 0.13, blue: 0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

// MARK: - 3. READING & TAP-TO-TRANSLATE (Đọc hiểu & Chạm tra từ)

struct ReadingTranslateModule: View {
    @State private var selectedWordPopup: String? = nil
    
    private let readingText = "我 每天 早上 七点 起床，然后 去 学校 学习 汉语。老师 很 热情，同学们 也 互相 帮助。"
    
    private let dictionary: [String: (pinyin: String, sino: String, meaning: String)] = [
        "我": ("wǒ", "Ngã", "Tôi, mình"),
        "每天": ("měitiān", "Mỗi thiên", "Mỗi ngày, hàng ngày"),
        "早上": ("zǎoshang", "Tảo thượng", "Buổi sáng"),
        "七点": ("qī diǎn", "Thất điểm", "7 giờ"),
        "起床": ("qǐchuáng", "Khởi sàng", "Thức dậy, rời giường"),
        "然后": ("ránhòu", "Nhiên hậu", "Sau đó, tiếp theo"),
        "去": ("qù", "Khứ", "Đi đến"),
        "学校": ("xuéxiào", "Học hiệu", "Trường học"),
        "学习": ("xuéxí", "Học tập", "Học, nghiên cứu"),
        "汉语": ("Hànyǔ", "Hán ngữ", "Tiếng Trung Quốc"),
        "老师": ("lǎoshī", "Lão sư", "Thầy cô giáo"),
        "很": ("hěn", "Hẩn", "Rất"),
        "热情": ("rèqíng", "Nhiệt tình", "Nhiệt tình, chu đáo"),
        "同学们": ("tóngxuémen", "Đồng học môn", "Các bạn học sinh"),
        "也": ("yě", "Dã", "Cũng"),
        "互相": ("hùxiāng", "Hỗ tương", "Lẫn nhau, qua lại"),
        "帮助": ("bāngzhù", "Bang trợ", "Giúp đỡ")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("BÀI ĐỌC HSK 2 · CHẠM VÀO TỪ ĐỂ TRA NGHĨA")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(HanTheme.jadeGreen)
                Spacer()
            }
            
            // Khung văn bản tương tác
            FlowLayout(spacing: 8) {
                ForEach(readingText.components(separatedBy: " "), id: \.self) { word in
                    Button(action: {
                        selectedWordPopup = word
                        SoundManager.shared.speakMandarin(word)
                        HapticManager.shared.buttonTapped()
                    }) {
                        Text(word)
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                selectedWordPopup == word
                                    ? HanTheme.jadeGreen.opacity(0.3)
                                    : Color.white.opacity(0.08)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(cardBackground)
            
            // Popup Tra Từ Siêu Tốc (Offline FTS)
            if let word = selectedWordPopup, let dict = dictionary[word] {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(word)
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(dict.pinyin)
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .foregroundColor(HanTheme.silkGold)
                        
                        Spacer()
                        
                        Button(action: {
                            SoundManager.shared.speakMandarin(word)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                                .font(.system(size: 18))
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                    
                    HStack {
                        Text("Hán Việt: \(dict.sino)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    
                    Text("Nghĩa: \(dict.meaning)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(HanTheme.jadeGreen)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.12, green: 0.15, blue: 0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(HanTheme.jadeGreen.opacity(0.4), lineWidth: 1.2)
                        )
                )
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(red: 0.10, green: 0.13, blue: 0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

// MARK: - 4. VOICE SPEAKING CHECK MODULE (Luyện Nói AI & Chấm Điểm 4 Thanh Điệu)

struct VoiceSpeakingCheckModule: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    
    struct SpeakingItem: Identifiable {
        var id: String { hanzi }
        let hanzi: String
        let pinyin: String
        let meaning: String
        let hskLevel: Int
    }
    
    private let speakingItems: [SpeakingItem] = [
        SpeakingItem(hanzi: "你好，很高兴认识你！", pinyin: "Nǐ hǎo, hěn gāoxìng rènshi nǐ!", meaning: "Xin chào, rất vui được làm quen với bạn!", hskLevel: 1),
        SpeakingItem(hanzi: "我想买一个苹果。", pinyin: "Wǒ xiǎng mǎi yí gè píngguǒ.", meaning: "Tôi muốn mua một quả táo.", hskLevel: 1),
        SpeakingItem(hanzi: "今天的天气非常晴朗。", pinyin: "Jīntiān de tiānqì fēicháng qínglǎng.", meaning: "Thời tiết hôm nay vô cùng trong lành.", hskLevel: 1),
        SpeakingItem(hanzi: "这个衣服多少钱一件？", pinyin: "Zhège yīfu duōshao qián yí jiàn?", meaning: "Bộ quần áo này bao nhiêu tiền một chiếc?", hskLevel: 2),
        SpeakingItem(hanzi: "明天我们一起去图书馆吧。", pinyin: "Míngtiān wǒmen yìqǐ qù túshūguǎn ba.", meaning: "Ngày mai chúng ta cùng nhau đi thư viện nhé.", hskLevel: 2),
        SpeakingItem(hanzi: "虽然汉语很难，但我会坚持学习。", pinyin: "Suīrán hànyǔ hěn nán, dàn wǒ huì jiānchí xuéxí.", meaning: "Tuy tiếng Trung rất khó, nhưng tôi sẽ kiên trì học tập.", hskLevel: 3),
        SpeakingItem(hanzi: "祝你生日快乐，工作顺利！", pinyin: "Zhù nǐ shēngrì kuàilè, gōngzuò shùnlì!", meaning: "Chúc bạn sinh nhật vui vẻ, công việc thuận lợi!", hskLevel: 3),
        SpeakingItem(hanzi: "实践是检验真理的唯一标准。", pinyin: "Shíjiàn shì jiǎnyàn zhēnlǐ de wéiyī biāozhǔn.", meaning: "Thực tiễn là tiêu chuẩn duy nhất kiểm nghiệm chân lý.", hskLevel: 4),
        SpeakingItem(hanzi: "环境保护对于人类未来的发展至关重要。", pinyin: "Huánjìng bǎohù duìyú rénlèi wèilái de fāzhǎn zhìguān zhòngyào.", meaning: "Bảo vệ môi trường có ý nghĩa vô cùng quan trọng đối với sự phát triển của nhân loại.", hskLevel: 5)
    ]
    
    @State private var selectedLevel: Int = 1
    @State private var currentIndex: Int = 0
    @State private var evaluationResult: VoiceEvaluationResult? = nil
    @State private var errorMessage: String? = nil
    @State private var hasPassedCurrent: Bool = false
    
    private var filteredItems: [SpeakingItem] {
        let items = speakingItems.filter { $0.hskLevel == selectedLevel }
        return items.isEmpty ? speakingItems : items
    }
    
    private var currentItem: SpeakingItem {
        let items = filteredItems
        if currentIndex >= items.count {
            return items.first ?? speakingItems[0]
        }
        return items[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Level Selector HSK 1 - 5
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { lvl in
                        Button(action: {
                            selectedLevel = lvl
                            currentIndex = 0
                            evaluationResult = nil
                            hasPassedCurrent = false
                            HapticManager.shared.buttonTapped()
                        }) {
                            Text("HSK \(lvl)")
                                .font(.system(size: 13, weight: selectedLevel == lvl ? .bold : .medium))
                                .foregroundColor(selectedLevel == lvl ? .black : .white.opacity(0.8))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(selectedLevel == lvl ? HanTheme.jadeGreen : Color.white.opacity(0.08))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            // Cảnh báo nếu quyền Micro bị tắt
            if voiceEvaluator.isPermissionDenied {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "mic.slash.fill")
                            .foregroundColor(HanTheme.vermilionRed)
                        Text("Microphone Chưa Được Cấp Quyền")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Vui lòng mở Cài đặt iPhone để bật công tắc Micro cho HanLearn, hoặc chọn Chấm Thử Mô Phỏng.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 10) {
                        Button(action: { voiceEvaluator.openSettings() }) {
                            Text("Mở Cài Đặt iPhone")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(HanTheme.silkGold)
                                .cornerRadius(8)
                        }
                        
                        Button(action: runSimulation) {
                            Text("Chấm Thử Mô Phỏng")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.15))
                .cornerRadius(12)
            }
            
            // Thẻ câu nói cần luyện
            VStack(spacing: 14) {
                HStack {
                    Text("CÂU CẦN ĐỌC (CÂU \(currentIndex + 1)/\(filteredItems.count))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                    Spacer()
                    Text("HSK \(currentItem.hskLevel)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(HanTheme.jadeGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(HanTheme.jadeGreen.opacity(0.15))
                        .cornerRadius(6)
                }
                
                Text(currentItem.hanzi)
                    .font(.hanTitle(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 10)
                
                Text(currentItem.pinyin)
                    .font(.hanPinyin(size: 16))
                    .foregroundColor(HanTheme.jadeGreen)
                    .multilineTextAlignment(.center)
                
                Text(currentItem.meaning)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                
                // Nút nghe phát âm mẫu
                Button(action: {
                    SoundManager.shared.speakMandarin(currentItem.hanzi)
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Nghe Giọng Chuẩn Bắc Kinh")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(20)
                }
                .padding(.top, 4)
            }
            .padding(18)
            .background(cardBackground)
            
            // Nút Micro lớn thu âm
            VStack(spacing: 12) {
                ZStack {
                    if voiceEvaluator.isRecording {
                        Circle()
                            .fill(HanTheme.vermilionRed.opacity(0.2))
                            .frame(width: 130, height: 130)
                            .scaleEffect(1.0 + CGFloat(voiceEvaluator.audioLevel) * 0.5)
                            .animation(.easeInOut(duration: 0.1), value: voiceEvaluator.audioLevel)
                    }
                    
                    Button(action: toggleRecording) {
                        Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 84, height: 84)
                            .background(voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen)
                            .clipShape(Circle())
                            .shadow(color: (voiceEvaluator.isRecording ? HanTheme.vermilionRed : HanTheme.jadeGreen).opacity(0.4), radius: 12)
                    }
                }
                
                Text(voiceEvaluator.isRecording ? "Đang lắng nghe... (Nhấn nút đỏ để DỪNG & CHẤM ĐIỂM)" : "Chạm Micro để bắt đầu nói")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : .gray)
                
                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 12))
                        .foregroundColor(HanTheme.vermilionRed)
                        .multilineTextAlignment(.center)
                }
                
                // Nghe lại giọng vừa đọc
                if voiceEvaluator.hasRecordedAudio {
                    Button(action: {
                        voiceEvaluator.playRecordedVoice()
                        HapticManager.shared.buttonTapped()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: voiceEvaluator.isPlayingBack ? "pause.circle.fill" : "play.circle.fill")
                            Text(voiceEvaluator.isPlayingBack ? "Đang phát lại..." : "Nghe lại giọng của bạn")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(HanTheme.silkGold.opacity(0.12))
                        .cornerRadius(18)
                    }
                }
            }
            
            // Bảng kết quả chấm điểm
            if let eval = evaluationResult {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        scoreBadge(title: "Tổng quan", score: eval.overallScore, color: HanTheme.silkGold)
                        scoreBadge(title: "Thanh điệu", score: eval.toneScore, color: HanTheme.jadeGreen)
                        scoreBadge(title: "Lưu loát", score: eval.fluencyScore, color: .orange)
                    }
                    
                    Text(eval.feedbackMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                    
                    // Nút chuyển câu tiếp theo
                    Button(action: nextQuestion) {
                        HStack(spacing: 6) {
                            Text("Chuyển Câu Tiếp Theo")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HanTheme.jadeGreen)
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(cardBackground)
            }
        }
    }
    
    private func scoreBadge(title: String, score: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func runSimulation() {
        errorMessage = nil
        let res = voiceEvaluator.evaluateWithSimulatedVoice(targetHanzi: currentItem.hanzi, targetPinyin: currentItem.pinyin)
        evaluationResult = res
        hasPassedCurrent = true
        awardXP()
        HapticManager.shared.answerCorrect()
    }
    
    private func toggleRecording() {
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: currentItem.hanzi, targetPinyin: currentItem.pinyin)
            evaluationResult = res
            if res.overallScore >= 80 {
                hasPassedCurrent = true
                awardXP()
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
                        try voiceEvaluator.startRecording(targetHanzi: currentItem.hanzi)
                        HapticManager.shared.buttonTapped()
                    } catch {
                        errorMessage = "Không thể bật micro: \(error.localizedDescription)"
                    }
                } else {
                    errorMessage = "Chưa có quyền Micro. Hãy nhấn 'Mở Cài Đặt iPhone' hoặc 'Chấm Thử Mô Phỏng'."
                    runSimulation()
                }
            }
        }
    }
    
    private func nextQuestion() {
        let items = filteredItems
        if currentIndex + 1 < items.count {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        evaluationResult = nil
        hasPassedCurrent = false
        HapticManager.shared.buttonTapped()
    }
    
    private func awardXP() {
        if let prog = userProgressList.first {
            prog.totalXP += 15
            prog.recordDailyActivity()
            try? modelContext.save()
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color(red: 0.10, green: 0.13, blue: 0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

