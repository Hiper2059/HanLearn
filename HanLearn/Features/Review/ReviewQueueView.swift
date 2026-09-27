//
//  ReviewQueueView.swift
//  HanLearn
//
//  Full-screen SRS flashcard review queue.
//  Shows cards due for review, tracks session progress, and shows summary.
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
                Color.black.ignoresSafeArea()
                
                if reviewQueue.isEmpty && !isSessionComplete {
                    emptyStateView
                } else if isSessionComplete {
                    sessionSummaryView
                } else {
                    reviewSessionView
                }
            }
            .navigationTitle("Ôn tập")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingQuickAdd = true }) {
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
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 56))
                .foregroundStyle(HanTheme.primaryGradient)
            
            Text("Chưa có từ vựng nào cần ôn!")
                .font(.hanTitle(size: 22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Thêm từ mới để bắt đầu luyện tập\nhoặc quay lại khi có từ đến hạn ôn 📚")
                .font(.hanBody(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { showingQuickAdd = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Thêm từ vựng đầu tiên")
                }
                .font(.hanBody(size: 16))
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: 260)
                .padding(.vertical, 14)
                .background(HanTheme.jadeGreen)
                .cornerRadius(14)
            }
            .padding(.top, 10)
        }
        .padding(30)
    }
    
    // MARK: - Review Session
    
    private var reviewSessionView: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 6) {
                ProgressView(value: Double(currentIndex), total: Double(reviewQueue.count))
                    .tint(HanTheme.jadeGreen)
                
                HStack {
                    Text("Thẻ \(currentIndex + 1) / \(reviewQueue.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Label("\(sessionStats.correct)", systemImage: "checkmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HanTheme.jadeGreen)
                        Label("\(sessionStats.again)", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HanTheme.vermilionRed)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Flashcard
            if currentIndex < reviewQueue.count {
                FlashcardView(word: reviewQueue[currentIndex]) { grade in
                    processGrade(grade)
                }
                .padding(.horizontal, 16)
                .id(currentIndex) // Force recreation on index change
            }
        }
    }
    
    // MARK: - Session Summary
    
    private var sessionSummaryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 64))
                .foregroundColor(HanTheme.silkGold)
            
            Text("Ôn tập hoàn thành! 🎉")
                .font(.hanTitle(size: 24))
                .foregroundColor(.white)
            
            // Stats grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    statCard(value: "\(sessionStats.total)", label: "Tổng thẻ", color: .white)
                    statCard(value: "\(sessionStats.correct)", label: "Nhớ tốt", color: HanTheme.jadeGreen)
                }
                HStack(spacing: 16) {
                    statCard(value: "\(sessionStats.again)", label: "Cần ôn lại", color: HanTheme.vermilionRed)
                    statCard(value: "\(sessionStats.mastered)", label: "Thuộc lòng", color: HanTheme.silkGold)
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                // Reset and check for newly due cards
                isSessionComplete = false
                currentIndex = 0
                sessionStats = SessionStats()
                loadReviewQueue()
            }) {
                Text("Xong")
                    .font(.hanBody(size: 16))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 40)
        }
        .padding(20)
    }
    
    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.hanTitle(size: 28))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
    
    // MARK: - Logic
    
    private func loadReviewQueue() {
        let now = Date()
        var dueWords = allWords.filter { word in
            guard let nextReview = word.nextReviewAt else { return false }
            return nextReview <= now
        }
        
        // Cap for catch-up mode
        if progress.needsCatchUp && dueWords.count > SRSEngine.catchUpQueueCap {
            // Prioritize by oldest due date
            dueWords.sort { ($0.nextReviewAt ?? .distantPast) < ($1.nextReviewAt ?? .distantPast) }
            dueWords = Array(dueWords.prefix(SRSEngine.catchUpQueueCap))
        }
        
        // Shuffle for variety
        reviewQueue = dueWords.shuffled()
        currentIndex = 0
        isSessionComplete = false
    }
    
    private func processGrade(_ grade: SRSGrade) {
        guard currentIndex < reviewQueue.count else { return }
        
        let word = reviewQueue[currentIndex]
        
        // Apply SRS algorithm
        let result = SRSEngine.processReview(
            grade: grade,
            currentRepetitionCount: word.srsRepetitionCount,
            currentIntervalDays: word.srsIntervalDays,
            currentEaseFactor: word.srsEaseFactor,
            currentMastery: word.masteryPercentage
        )
        
        SRSEngine.applyResult(result, to: word)
        
        // Update session stats
        sessionStats.total += 1
        switch grade {
        case .again:
            sessionStats.again += 1
        case .hard:
            sessionStats.correct += 1
        case .good:
            sessionStats.correct += 1
        case .easy:
            sessionStats.correct += 1
            if result.newMastery >= 90 {
                sessionStats.mastered += 1
            }
        }
        
        try? modelContext.save()
        
        // Advance to next card or complete
        withAnimation(.easeInOut(duration: 0.3)) {
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

// MARK: - Session Stats

private struct SessionStats {
    var total: Int = 0
    var correct: Int = 0
    var again: Int = 0
    var mastered: Int = 0
}
