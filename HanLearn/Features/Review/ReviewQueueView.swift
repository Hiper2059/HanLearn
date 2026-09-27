//
//  ReviewQueueView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 2: Ôn Tập Từ Vựng SRS (SuperMemo-2) & Rich Flashcard
//  Clean Native iOS UX: Không tràn thanh TabBar, thanh tiến độ mềm mại, chấm điểm tức thì
//

import SwiftUI
import SwiftData

public struct ReviewQueueView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allWords: [HSKWord]
    @Query private var userProgressList: [UserProgress]
    
    @State private var reviewQueue: [HSKWord] = []
    @State private var currentIndex: Int = 0
    @State private var sessionStats: SessionStats = SessionStats()
    @State private var showingQuickAdd: Bool = false
    @State private var isSessionComplete: Bool = false
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea()
                
                if reviewQueue.isEmpty && !isSessionComplete {
                    emptyStateView
                } else if isSessionComplete {
                    sessionSummaryView
                } else {
                    reviewSessionView
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
            .onAppear {
                loadReviewQueue()
            }
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
            
            Text("Tuyệt vời! Bạn đã hoàn thành tất cả các thẻ ôn tập hôm nay.\nThêm từ mới hoặc thư giãn nhé! ✨")
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
    
    // MARK: - REVIEW SESSION
    private var reviewSessionView: some View {
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
            
            // Thẻ Flashcard chính
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
        .padding(.bottom, 8)
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
                Text("Xong & Về Trang Chủ")
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
        
        // Nếu không có từ nào đến hạn, lấy tối đa 5 từ bất kỳ để người dùng luôn có thể luyện tập
        if dueWords.isEmpty && !allWords.isEmpty {
            dueWords = Array(allWords.prefix(5))
        }
        
        if progress.needsCatchUp && dueWords.count > SRSEngine.catchUpQueueCap {
            dueWords.sort { ($0.nextReviewAt ?? .distantPast) < ($1.nextReviewAt ?? .distantPast) }
            dueWords = Array(dueWords.prefix(SRSEngine.catchUpQueueCap))
        }
        
        reviewQueue = dueWords.shuffled()
        currentIndex = 0
        isSessionComplete = false
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
