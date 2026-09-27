//
//  ReviewQueueView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 2: Ôn Tập Từ Vựng SRS & Tự Học Toàn Diện
//  Hỗ trợ 3 chế độ:
//  1. "Học Đầy Đủ" (Hiển thị đầy đủ chữ Hán, Pinyin, Hán Việt, Nghĩa, Tập viết nét, Luyện nói trực tiếp)
//  2. "Lật Thẻ SRS" (Kiểm tra trí nhớ SuperMemo-2 3D Flip Card)
//  3. "Kho Từ Vựng" (Tra cứu toàn bộ kho từ vựng HSK 1 - 3 với tìm kiếm tiếng Việt / Pinyin / Hán tự)
//

import SwiftUI
import SwiftData

public struct ReviewQueueView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allWords: [HSKWord]
    @Query private var userProgressList: [UserProgress]
    
    public enum StudyMode: String, CaseIterable {
        case fullDetail = "Học Đầy Đủ"
        case flashcard = "Lật Thẻ SRS"
        case allWords = "Kho Từ Vựng"
    }
    
    @State private var selectedStudyMode: StudyMode = .fullDetail
    @State private var reviewQueue: [HSKWord] = []
    @State private var currentIndex: Int = 0
    @State private var sessionStats: SessionStats = SessionStats()
    @State private var showingQuickAdd: Bool = false
    @State private var isSessionComplete: Bool = false
    @State private var showingStrokeCanvas: Bool = false
    
    // Voice check inline
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var voiceFeedback: String? = nil
    
    // Tra cứu
    @State private var searchQuery: String = ""
    @State private var selectedHSKFilter: Int = 0 // 0 = Tất cả
    @State private var selectedDetailWord: HSKWord? = nil
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Mode Selector
                    studyModeSelector
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    if selectedStudyMode == .allWords {
                        allWordsDirectoryView
                    } else if reviewQueue.isEmpty && !isSessionComplete {
                        emptyStateView
                    } else if isSessionComplete {
                        sessionSummaryView
                    } else if selectedStudyMode == .fullDetail {
                        fullDetailStudyView
                    } else {
                        flashcardReviewView
                    }
                }
            }
            .navigationTitle("Ôn Tập Từ Vựng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingQuickAdd = true
                        HapticManager.shared.buttonTapped()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(HanTheme.jadeGreen)
                    }
                    .accessibilityLabel("Thêm từ vựng mới")
                }
            }
            .sheet(isPresented: $showingQuickAdd) {
                VocabQuickAddSheet()
            }
            .sheet(isPresented: $showingStrokeCanvas) {
                if currentIndex < reviewQueue.count {
                    StrokeCanvasView(word: reviewQueue[currentIndex])
                }
            }
            .sheet(item: $selectedDetailWord) { word in
                StrokeCanvasView(word: word)
            }
            .onAppear {
                loadReviewQueue()
            }
        }
    }
    
    // MARK: - STUDY MODE SELECTOR BAR
    private var studyModeSelector: some View {
        HStack(spacing: 6) {
            ForEach(StudyMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedStudyMode = mode
                    }
                    HapticManager.shared.buttonTapped()
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: selectedStudyMode == mode ? .bold : .medium))
                        .foregroundColor(selectedStudyMode == mode ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedStudyMode == mode {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(HanTheme.jadeGreen)
                                        .shadow(color: HanTheme.jadeGreen.opacity(0.3), radius: 6, y: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.06))
                                }
                            }
                        )
                }
            }
        }
    }
    
    // MARK: - 1. FULL DETAIL STUDY VIEW (Hiển thị đầy đủ chữ để học)
    private var fullDetailStudyView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header tiến độ
                HStack {
                    Text("Từ \(currentIndex + 1) / \(reviewQueue.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(HanTheme.silkGold.opacity(0.15))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    if currentIndex < reviewQueue.count {
                        let word = reviewQueue[currentIndex]
                        HStack(spacing: 6) {
                            Circle()
                                .fill(HanTheme.vermilionRed)
                                .frame(width: 8, height: 8)
                            Text("HSK \(word.hskLevel) · \(word.strokeCount) nét")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                
                if currentIndex < reviewQueue.count {
                    let word = reviewQueue[currentIndex]
                    
                    // Card hiển thị thông tin học tập chi tiết
                    VStack(spacing: 14) {
                        // 1. Ô Mễ Tự Cách to rõ
                        TianziGeView(
                            character: word.hanzi,
                            size: 140,
                            showGrid: true,
                            gridColor: Color.red.opacity(0.4),
                            textColor: .white
                        )
                        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 6)
                        
                        // 2. Pinyin & Hán Việt
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PINYIN")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(HanTheme.silkGold.opacity(0.8))
                                Text(word.pinyin)
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(HanTheme.silkGold)
                            }
                            
                            if !word.sinoVietnamese.isEmpty {
                                Divider()
                                    .frame(height: 30)
                                    .background(Color.white.opacity(0.2))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("HÁN VIỆT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(word.sinoVietnamese)
                                        .font(.system(size: 20, weight: .semibold, design: .serif))
                                        .foregroundColor(.white.opacity(0.95))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 16)
                        
                        // 3. Nghĩa tiếng Việt
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ý NGHĨA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(HanTheme.jadeGreen)
                            Text(word.vietnameseMeaning)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        
                        // 4. Câu ví dụ ngữ cảnh
                        if !word.exampleSentenceHanzi.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("VÍ DỤ NGỮ CẢNH:")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text(word.exampleSentenceHanzi)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(word.exampleSentencePinyin)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(HanTheme.silkGold.opacity(0.9))
                                
                                Text(word.exampleSentenceTranslation)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.10, green: 0.12, blue: 0.17))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    
                    // CỤM 3 NÚT: PHÁT ÂM - TẬP VIẾT - LUYỆN NÓI
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            // Nút Phát âm chuẩn
                            Button(action: {
                                SoundManager.shared.speakMandarin(word.hanzi)
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "speaker.wave.3.fill")
                                    Text("Phát âm")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(HanTheme.jadeGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(HanTheme.jadeGreen.opacity(0.15))
                                .cornerRadius(12)
                            }
                            
                            // Nút Tập viết
                            Button(action: {
                                showingStrokeCanvas = true
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.tip.crop.circle")
                                    Text("Tập viết")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(HanTheme.silkGold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(HanTheme.silkGold.opacity(0.15))
                                .cornerRadius(12)
                            }
                            
                            // Nút Luyện nói
                            Button(action: handleVoiceCheck) {
                                HStack(spacing: 6) {
                                    Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                                    Text(voiceEvaluator.isRecording ? "Dừng" : "Nói thử")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background((voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue).opacity(0.15))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Nút nghe lại giọng nếu vừa thu âm
                        if voiceEvaluator.hasRecordedAudio {
                            HStack {
                                Button(action: {
                                    voiceEvaluator.playRecordedVoice()
                                    HapticManager.shared.buttonTapped()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: voiceEvaluator.isPlayingBack ? "pause.circle.fill" : "play.circle.fill")
                                        Text("Nghe lại giọng vừa nói của bạn")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(HanTheme.silkGold)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(HanTheme.silkGold.opacity(0.15))
                                    .cornerRadius(10)
                                }
                                Spacer()
                            }
                        }
                        
                        if let feedback = voiceFeedback {
                            Text(feedback)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(HanTheme.silkGold)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // ĐIỀU HƯỚNG: TỪ TRƯỚC - ĐÃ THUỘC - TỪ KẾ TIẾP
                    HStack(spacing: 12) {
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                voiceFeedback = nil
                                HapticManager.shared.buttonTapped()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Từ trước")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(currentIndex > 0 ? 0.9 : 0.3))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                        }
                        .disabled(currentIndex == 0)
                        
                        Spacer()
                        
                        Button(action: {
                            processGrade(.good)
                            voiceFeedback = nil
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Đã Thuộc")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(HanTheme.jadeGreen)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            if currentIndex + 1 < reviewQueue.count {
                                currentIndex += 1
                                voiceFeedback = nil
                                HapticManager.shared.buttonTapped()
                            } else {
                                isSessionComplete = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Tiếp theo")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - 2. FLASHCARD SRS VIEW
    private var flashcardReviewView: some View {
        VStack(spacing: 12) {
            // Thanh tiến độ phiên học
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 5)
                        
                        let progressVal = reviewQueue.isEmpty ? 0 : CGFloat(currentIndex) / CGFloat(reviewQueue.count)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(HanTheme.jadeGreen)
                            .frame(width: geo.size.width * progressVal, height: 5)
                    }
                }
                .frame(height: 5)
                
                HStack {
                    Text("Thẻ \(currentIndex + 1) / \(reviewQueue.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                            Text("\(sessionStats.correct)")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 12, weight: .bold))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(HanTheme.vermilionRed)
                            Text("\(sessionStats.again)")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 12, weight: .bold))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer(minLength: 6)
            
            if currentIndex < reviewQueue.count {
                FlashcardView(
                    word: reviewQueue[currentIndex],
                    cardIndex: currentIndex + 1,
                    totalCards: reviewQueue.count
                ) { grade in
                    processGrade(grade)
                }
                .padding(.horizontal, 16)
                .id(currentIndex)
            }
            
            Spacer(minLength: 12)
        }
        .padding(.bottom, 80)
    }
    
    // MARK: - 3. ALL WORDS DIRECTORY VIEW (Tra cứu toàn bộ từ)
    private var filteredWords: [HSKWord] {
        allWords.filter { word in
            let matchesFilter = selectedHSKFilter == 0 || word.hskLevel == selectedHSKFilter
            guard matchesFilter else { return false }
            
            let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if query.isEmpty { return true }
            
            return word.vietnameseMeaning.lowercased().contains(query) ||
                   word.hanzi.contains(query) ||
                   word.pinyin.lowercased().contains(query) ||
                   word.sinoVietnamese.lowercased().contains(query)
        }
    }
    
    private var allWordsDirectoryView: some View {
        VStack(spacing: 12) {
            // Thanh tìm kiếm
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Tìm kiếm nghĩa tiếng Việt, pinyin, chữ Hán...", text: $searchQuery)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            
            // Bộ lọc HSK
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterBadge(title: "Tất cả", level: 0)
                    ForEach(1...5, id: \.self) { lvl in
                        filterBadge(title: "HSK \(lvl)", level: lvl)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Danh sách từ vựng
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredWords) { word in
                        Button(action: {
                            selectedDetailWord = word
                            SoundManager.shared.speakMandarin(word.hanzi)
                            HapticManager.shared.buttonTapped()
                        }) {
                            HStack(spacing: 14) {
                                Text(word.hanzi)
                                    .font(.system(size: 26, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                    .frame(width: 60, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(word.pinyin)
                                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                                            .foregroundColor(HanTheme.silkGold)
                                        Spacer()
                                        Text("HSK \(word.hskLevel)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(HanTheme.jadeGreen)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(HanTheme.jadeGreen.opacity(0.15))
                                            .cornerRadius(6)
                                    }
                                    
                                    Text(word.vietnameseMeaning)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    if !word.sinoVietnamese.isEmpty {
                                        Text("Hán-Việt: \(word.sinoVietnamese)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "pencil.and.outline")
                                    .font(.system(size: 16))
                                    .foregroundColor(HanTheme.silkGold)
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
        .padding(.top, 6)
    }
    
    private func filterBadge(title: String, level: Int) -> some View {
        Button(action: {
            selectedHSKFilter = level
            HapticManager.shared.buttonTapped()
        }) {
            Text(title)
                .font(.system(size: 12, weight: selectedHSKFilter == level ? .bold : .medium))
                .foregroundColor(selectedHSKFilter == level ? .black : .white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedHSKFilter == level ? HanTheme.silkGold : Color.white.opacity(0.08))
                .cornerRadius(12)
        }
    }
    
    // MARK: - EMPTY STATE
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.badge.questionmark.fill")
                .font(.system(size: 58))
                .foregroundColor(HanTheme.jadeGreen)
            
            Text("Không có từ vựng cần ôn!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tuyệt vời! Bạn đã hoàn thành tất cả các thẻ ôn tập hôm nay.\nThêm từ mới hoặc chọn 'Kho Từ Vựng' để rèn luyện nhé! ✨")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button(action: {
                showingQuickAdd = true
                HapticManager.shared.buttonTapped()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Thêm Từ Vựng Mới")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(HanTheme.jadeGreen)
                .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .padding(30)
    }
    
    // MARK: - SESSION SUMMARY
    private var sessionSummaryView: some View {
        VStack(spacing: 22) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(HanTheme.silkGold)
            
            Text("Hoàn Thành Ôn Tập! 🎉")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    statCard(value: "\(sessionStats.total)", label: "Tổng số thẻ", color: .white)
                    statCard(value: "\(sessionStats.correct)", label: "Nhớ tốt", color: HanTheme.jadeGreen)
                }
                HStack(spacing: 12) {
                    statCard(value: "\(sessionStats.again)", label: "Cần ôn lại", color: HanTheme.vermilionRed)
                    statCard(value: "\(sessionStats.mastered)", label: "Thuộc lòng", color: HanTheme.silkGold)
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                isSessionComplete = false
                currentIndex = 0
                sessionStats = SessionStats()
                loadReviewQueue()
            }) {
                Text("Xong & Tiếp Tục Học")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
        .padding(20)
    }
    
    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
    
    // MARK: - LOGIC
    private func loadReviewQueue() {
        let now = Date()
        var dueWords = allWords.filter { word in
            guard let nextReview = word.nextReviewAt else { return false }
            return nextReview <= now
        }
        
        // Nếu không có từ nào đến hạn, lấy tối đa 10 từ bất kỳ để người dùng luôn có bài học
        if dueWords.isEmpty && !allWords.isEmpty {
            dueWords = Array(allWords.prefix(10))
        }
        
        if progress.needsCatchUp && dueWords.count > SRSEngine.catchUpQueueCap {
            dueWords.sort { ($0.nextReviewAt ?? .distantPast) < ($1.nextReviewAt ?? .distantPast) }
            dueWords = Array(dueWords.prefix(SRSEngine.catchUpQueueCap))
        }
        
        reviewQueue = dueWords.shuffled()
        currentIndex = 0
        isSessionComplete = false
    }
    
    private func handleVoiceCheck() {
        guard currentIndex < reviewQueue.count else { return }
        let word = reviewQueue[currentIndex]
        
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: word.hanzi, targetPinyin: word.pinyin)
            voiceFeedback = "Điểm: \(res.overallScore)/100 · \(res.isExactMatch ? "Chuẩn xác 🎉" : "Khá tốt 👍")"
            HapticManager.shared.answerCorrect()
        } else {
            voiceFeedback = "Đang lắng nghe... Hãy phát âm: \(word.hanzi)"
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
    
    private func processGrade(_ grade: SRSGrade) {
        guard currentIndex < reviewQueue.count else { return }
        let word = reviewQueue[currentIndex]
        
        let result = SRSEngine.processReview(
            grade: grade,
            currentRepetitionCount: word.srsRepetitionCount,
            currentIntervalDays: word.srsIntervalDays,
            currentEaseFactor: word.srsEaseFactor,
            currentMastery: word.masteryPercentage
        )
        
        SRSEngine.applyResult(result, to: word)
        
        sessionStats.total += 1
        switch grade {
        case .again:
            sessionStats.again += 1
        case .hard, .good:
            sessionStats.correct += 1
        case .easy:
            sessionStats.correct += 1
            if result.newMastery >= 90 {
                sessionStats.mastered += 1
            }
        }
        
        try? modelContext.save()
        
        withAnimation(.easeInOut(duration: 0.25)) {
            if currentIndex + 1 >= reviewQueue.count {
                isSessionComplete = true
                updateStudyDayAfterReview()
            } else {
                currentIndex += 1
            }
        }
    }
    
    private func updateStudyDayAfterReview() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<StudyDay>(
            predicate: #Predicate<StudyDay> { day in
                day.date >= startOfToday
            }
        )
        
        let studyDay: StudyDay
        if let existing = try? modelContext.fetch(descriptor).first {
            studyDay = existing
        } else {
            studyDay = StudyDay(date: Date())
            modelContext.insert(studyDay)
        }
        
        studyDay.wordsReviewed += sessionStats.total
        try? modelContext.save()
    }
}

private struct SessionStats {
    var total: Int = 0
    var correct: Int = 0
    var again: Int = 0
    var mastered: Int = 0
}
