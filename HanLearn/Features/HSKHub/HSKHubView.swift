//
//  HSKHubView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Giáo trình HSK 3.0 Chuẩn SHZ & Sơ đồ con đường bài học (Duolingo & HelloChinese Learning Path)
//  Hỗ trợ 3 chế độ:
//  1. "🛤️ Lộ Trình" (Con đường bài học zíc-zắc dạng node uốn lượn kèm bài kiểm tra vượt cấp)
//  2. "🎯 Trạm Pinyin" (Luyện 4 thanh điệu chuẩn mực HelloChinese & Mini-game đoán âm)
//  3. "📋 Danh Sách" (Duyệt bài học truyền thống & Bộ sinh bài học tự động)
//

import SwiftUI
import SwiftData

public struct HSKHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HSKLesson.createdAt, order: .reverse) private var lessons: [HSKLesson]
    @Query private var userProgressList: [UserProgress]
    
    public enum HubDisplayMode: String, CaseIterable {
        case path = "🛤️ Lộ Trình"
        case pinyin = "🎯 Trạm Pinyin"
        case list = "📋 Danh Sách"
    }
    
    @State private var hubMode: HubDisplayMode = .path
    @State private var selectedLevel: Int = 1
    @State private var topicSearchText: String = ""
    @State private var isGenerating: Bool = false
    @State private var activeLessonForDetail: HSKLesson?
    @State private var activeLessonForQuiz: HSKLesson?
    @State private var activeLessonForStudy: HSKLesson?
    
    // Pinyin Game State
    @State private var currentPinyinQuizIndex: Int = 0
    @State private var pinyinQuizFeedback: String? = nil
    @State private var pinyinQuizScore: Int = 0
    
    private struct PinyinQuizItem {
        let text: String
        let pinyin: String
        let tone: Int
        let meaning: String
    }
    
    private let pinyinQuizItems: [PinyinQuizItem] = [
        PinyinQuizItem(text: "妈", pinyin: "mā", tone: 1, meaning: "Mẹ"),
        PinyinQuizItem(text: "麻", pinyin: "má", tone: 2, meaning: "Cây gai"),
        PinyinQuizItem(text: "马", pinyin: "mǎ", tone: 3, meaning: "Con ngựa"),
        PinyinQuizItem(text: "骂", pinyin: "mà", tone: 4, meaning: "Mắng"),
        PinyinQuizItem(text: "八", pinyin: "bā", tone: 1, meaning: "Số 8"),
        PinyinQuizItem(text: "拔", pinyin: "bá", tone: 2, meaning: "Nhổ"),
        PinyinQuizItem(text: "把", pinyin: "bǎ", tone: 3, meaning: "Cầm/Lượng từ"),
        PinyinQuizItem(text: "爸", pinyin: "bà", tone: 4, meaning: "Bố"),
        PinyinQuizItem(text: "他", pinyin: "tā", tone: 1, meaning: "Anh ấy"),
        PinyinQuizItem(text: "大", pinyin: "dà", tone: 4, meaning: "To lớn")
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. Header: Streak & XP
                        headerStatsView
                        
                        // 2. Chuyển đổi 3 chế độ: Lộ trình / Trạm Pinyin / Danh sách
                        hubModePicker
                        
                        // 3. Chọn cấp độ HSK (1 -> 6)
                        if hubMode != .pinyin {
                            levelSelectorSection
                        }
                        
                        // 4. Nội dung theo chế độ
                        switch hubMode {
                        case .path:
                            learningPathSection
                        case .pinyin:
                            pinyinTrainerSection
                        case .list:
                            autoGeneratorSection
                            savedLessonsSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("Giáo Trình HSK 3.0")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activeLessonForDetail) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .sheet(item: $activeLessonForQuiz) { lesson in
                TopicQuizView(lesson: lesson)
            }
            .fullScreenCover(item: $activeLessonForStudy) { lesson in
                InteractiveLessonStudyView(lesson: lesson)
            }
        }
    }
    
    // MARK: - 1. HEADER STATS
    private var headerStatsView: some View {
        let progress = userProgressList.first ?? UserProgress()
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(progress.currentStreak) Ngày Streak")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(20)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(HanTheme.silkGold)
                Text("\(progress.totalXP) XP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(HanTheme.silkGold.opacity(0.15))
            .cornerRadius(20)
        }
    }
    
    // MARK: - 2. HUB MODE PICKER
    private var hubModePicker: some View {
        HStack(spacing: 6) {
            ForEach(HubDisplayMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        hubMode = mode
                    }
                    HapticManager.shared.buttonTapped()
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: hubMode == mode ? .bold : .medium))
                        .foregroundColor(hubMode == mode ? .black : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if hubMode == mode {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(HanTheme.silkGold)
                                        .shadow(color: HanTheme.silkGold.opacity(0.4), radius: 6, y: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.08))
                                }
                            }
                        )
                }
            }
        }
    }
    
    // MARK: - 3. HSK LEVEL SELECTOR
    private var levelSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CẤP ĐỘ MỤC TIÊU:")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: {
                            selectedLevel = level
                            HapticManager.shared.buttonTapped()
                        }) {
                            Text("HSK \(level)")
                                .font(.system(size: 13, weight: selectedLevel == level ? .bold : .medium))
                                .foregroundColor(selectedLevel == level ? .black : .white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedLevel == level ? HanTheme.jadeGreen : Color.white.opacity(0.08))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 4. LEARNING PATH SECTION (Duolingo & HelloChinese Winding Nodes)
    private var filteredLessons: [HSKLesson] {
        let list = lessons.filter { $0.hskLevel == selectedLevel }
        return list.sorted { $0.title < $1.title }
    }
    
    private var learningPathSection: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CON ĐƯỜNG CHINH PHỤC HSK \(selectedLevel)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                    Text("Hoàn thành từng chặng để mở khóa bài tiếp theo")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Text("\(filteredLessons.count) Chặng")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(HanTheme.jadeGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(HanTheme.jadeGreen.opacity(0.15))
                    .cornerRadius(8)
            }
            
            if filteredLessons.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Chưa có bài học nào cho cấp độ HSK \(selectedLevel).")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 30)
            } else {
                // Winding Node Path
                VStack(spacing: 0) {
                    ForEach(Array(filteredLessons.enumerated()), id: \.element.id) { index, lesson in
                        let offsetPattern: CGFloat = (index % 3 == 0) ? 0 : ((index % 3 == 1) ? -45 : 45)
                        
                        VStack(spacing: 0) {
                            // Nút Node Tròn
                            HStack {
                                Spacer()
                                Button(action: {
                                    activeLessonForStudy = lesson
                                    HapticManager.shared.buttonTapped()
                                }) {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [HanTheme.jadeGreen, Color(red: 0.10, green: 0.55, blue: 0.40)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 76, height: 76)
                                                .shadow(color: HanTheme.jadeGreen.opacity(0.5), radius: 10, y: 4)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                                )
                                            
                                            Image(systemName: iconForLessonIndex(index))
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        // Badge sao
                                        HStack(spacing: 2) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(HanTheme.silkGold)
                                            }
                                        }
                                        
                                        Text(lesson.topic)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .frame(maxWidth: 130)
                                    }
                                }
                                .offset(x: offsetPattern)
                                Spacer()
                            }
                            
                            // Đường kẻ kết nối zíc-zắc nét đứt
                            if index + 1 < filteredLessons.count {
                                VStack(spacing: 4) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        Circle()
                                            .fill(HanTheme.jadeGreen.opacity(0.4))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .frame(height: 36)
                            }
                        }
                    }
                    
                    // BOSS CHECKPOINT TEST NODE (Bài thi vượt cấp)
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { _ in
                                Circle()
                                    .fill(HanTheme.silkGold.opacity(0.6))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 30)
                        
                        Button(action: {
                            if let first = filteredLessons.first {
                                activeLessonForQuiz = first
                                HapticManager.shared.buttonTapped()
                            }
                        }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [HanTheme.silkGold, Color.orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 86, height: 86)
                                        .shadow(color: HanTheme.silkGold.opacity(0.6), radius: 14, y: 6)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 3.5)
                                        )
                                    
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Text("THI VƯỢT CẤP HSK \(selectedLevel)")
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(HanTheme.silkGold)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 14)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.10, blue: 0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private func iconForLessonIndex(_ index: Int) -> String {
        let icons = [
            "hand.wave.fill",
            "person.3.fill",
            "clock.fill",
            "cart.fill",
            "location.fill",
            "fork.knife",
            "figure.run",
            "airplane",
            "sun.max.fill"
        ]
        return icons[index % icons.count]
    }
    
    // MARK: - 5. PINYIN TRAINER SECTION (HelloChinese Masterclass)
    private var pinyinTrainerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("TRẠM NHẬP MÔN: 4 THANH ĐIỆU CỐT LÕI")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                Text("Nắm chắc 4 thanh điệu là chìa khóa để người bản xứ hiểu bạn 100%.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // 4 Thẻ Thanh Điệu Trực Quan
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                toneCard(
                    number: 1,
                    symbol: "—",
                    pinyin: "mā",
                    hanzi: "妈 (Mẹ)",
                    desc: "Âm cao & ngang đều (55)",
                    color: Color.blue
                )
                toneCard(
                    number: 2,
                    symbol: "／",
                    pinyin: "má",
                    hanzi: "麻 (Cây gai)",
                    desc: "Vuốt nhanh lên cao (35)",
                    color: HanTheme.jadeGreen
                )
                toneCard(
                    number: 3,
                    symbol: "∨",
                    pinyin: "mǎ",
                    hanzi: "马 (Con ngựa)",
                    desc: "Hạ thấp rồi vút lên (214)",
                    color: HanTheme.silkGold
                )
                toneCard(
                    number: 4,
                    symbol: "＼",
                    pinyin: "mà",
                    hanzi: "骂 (Mắng)",
                    desc: "Rơi dứt khoát từ cao (51)",
                    color: HanTheme.vermilionRed
                )
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // MINI GAME: NGHE & ĐOÁN THANH ĐIỆU (EAR TRAINER)
            let quiz = pinyinQuizItems[currentPinyinQuizIndex % pinyinQuizItems.count]
            VStack(spacing: 14) {
                HStack {
                    Text("MINI GAME: ĐOÁN THANH ĐIỆU")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(HanTheme.jadeGreen)
                    Spacer()
                    Text("Điểm: \(pinyinQuizScore) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                }
                
                // Nút bấm phát âm
                Button(action: {
                    SoundManager.shared.speakMandarin(quiz.text)
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 20))
                        Text("Bấm Để Nghe Âm Này")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(14)
                }
                
                Text("Âm thanh vừa nghe thuộc thanh điệu nào?")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                
                // 4 Nút Lựa Chọn Thanh Điệu
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { tone in
                        Button(action: {
                            evaluatePinyinGuess(selectedTone: tone, expectedTone: quiz.tone, word: quiz)
                        }) {
                            VStack(spacing: 4) {
                                Text("Thanh \(tone)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Text(tone == 1 ? "—" : (tone == 2 ? "／" : (tone == 3 ? "∨" : "＼")))
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(HanTheme.silkGold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                }
                
                if let fb = pinyinQuizFeedback {
                    Text(fb)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(fb.contains("Chính xác") ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.10, blue: 0.14))
        )
    }
    
    private func toneCard(number: Int, symbol: String, pinyin: String, hanzi: String, desc: String, color: Color) -> some View {
        Button(action: {
            SoundManager.shared.speakMandarin(pinyin)
            HapticManager.shared.buttonTapped()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Thanh \(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                    Spacer()
                    Text(symbol)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(color)
                }
                
                HStack {
                    Text(pinyin)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(color)
                }
                
                Text(hanzi)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                
                Text(desc)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(12)
            .background(color.opacity(0.12))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func evaluatePinyinGuess(selectedTone: Int, expectedTone: Int, word: PinyinQuizItem) {
        if selectedTone == expectedTone {
            pinyinQuizFeedback = "Chính xác! '\(word.text)' (\(word.pinyin) - \(word.meaning)) là Thanh \(expectedTone) 🎉 (+10 XP)"
            pinyinQuizScore += 10
            HapticManager.shared.answerCorrect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                currentPinyinQuizIndex += 1
                pinyinQuizFeedback = nil
                let next = pinyinQuizItems[currentPinyinQuizIndex % pinyinQuizItems.count]
                SoundManager.shared.speakMandarin(next.text)
            }
        } else {
            pinyinQuizFeedback = "Chưa đúng rồi! Đây là Thanh \(expectedTone) (\(word.pinyin)). Hãy nghe lại nhé!"
            HapticManager.shared.answerWrong()
            SoundManager.shared.speakMandarin(word.text)
        }
    }
    
    // MARK: - 6. AUTO GENERATOR BOX
    private var autoGeneratorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TỰ ĐỘNG SINH BÀI GIẢNG THEO CHỦ ĐỀ")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HanTheme.silkGold)
            
            HStack {
                TextField("Nhập chủ đề: Đi du lịch, Gọi món, Phỏng vấn...", text: $topicSearchText)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                Button(action: triggerAutoGenerate) {
                    if isGenerating {
                        ProgressView()
                            .tint(.black)
                            .frame(width: 46, height: 46)
                            .background(HanTheme.silkGold)
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 46, height: 46)
                            .background(HanTheme.silkGold)
                            .cornerRadius(10)
                    }
                }
                .disabled(isGenerating)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - 7. SAVED LESSONS SECTION
    private var savedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("BÀI HỌC TRÊN THIẾT BỊ (\(filteredLessons.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("Offline Ready")
                    .font(.system(size: 11))
                    .foregroundColor(HanTheme.jadeGreen)
            }
            
            if filteredLessons.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Chưa có bài học nào cho HSK \(selectedLevel).\nHãy tạo bài học mới hoặc chọn cấp độ khác!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(filteredLessons) { lesson in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(lesson.levelBadge)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(HanTheme.vermilionRed)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            Text(lesson.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                SoundManager.shared.speakMandarin(lesson.dialogueChinese)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(HanTheme.jadeGreen)
                            }
                        }
                        
                        Text(lesson.summary)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                activeLessonForStudy = lesson
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                    Text("Học 3 Bước")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(HanTheme.jadeGreen)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                activeLessonForDetail = lesson
                            }) {
                                Text("Xem Chi Tiết")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                activeLessonForQuiz = lesson
                            }) {
                                Text("Nối Từ & Thi")
                                    .font(.system(size: 12))
                                    .foregroundColor(HanTheme.silkGold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(HanTheme.silkGold.opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(14)
                }
            }
        }
    }
    
    private func triggerAutoGenerate() {
        let topic = topicSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !topic.isEmpty else { return }
        isGenerating = true
        HapticManager.shared.buttonTapped()
        
        Task {
            do {
                let pkg = try await HSKDiscoveryService.shared.generateHSKLesson(
                    level: selectedLevel,
                    topic: topic
                )
                
                await MainActor.run {
                    let newLesson = HSKLesson(
                        hskLevel: pkg.hskLevel,
                        title: pkg.title,
                        topic: pkg.topic,
                        summary: pkg.summary,
                        grammarExplanation: pkg.grammarExplanation,
                        dialogueChinese: pkg.dialogueChinese,
                        dialoguePinyin: pkg.dialoguePinyin,
                        dialogueVietnamese: pkg.dialogueVietnamese
                    )
                    
                    for w in pkg.vocabulary {
                        let word = HSKWord(
                            hanzi: w.hanzi,
                            pinyin: w.pinyin,
                            sinoVietnamese: w.sinoVietnamese,
                            vietnameseMeaning: w.vietnameseMeaning,
                            hskLevel: pkg.hskLevel,
                            exampleSentenceHanzi: w.exampleSentence,
                            exampleSentencePinyin: w.examplePinyin,
                            exampleSentenceTranslation: w.exampleTranslation,
                            strokeCount: w.strokeCount
                        )
                        word.nextReviewAt = Date()
                        word.lesson = newLesson
                        newLesson.vocabularyList.append(word)
                    }
                    
                    modelContext.insert(newLesson)
                    try? modelContext.save()
                    isGenerating = false
                    topicSearchText = ""
                    HapticManager.shared.answerCorrect()
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                }
            }
        }
    }
}
