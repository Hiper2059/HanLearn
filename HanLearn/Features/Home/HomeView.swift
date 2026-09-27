//
//  HomeView.swift
//  HanLearn
//
//  The centerpiece "What do I do today?" screen.
//  Shows today's generated tasks, SRS due alert, streak, and quick actions.
//

import SwiftUI
import SwiftData

public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyTask.sortOrder) private var allTasks: [DailyTask]
    @Query private var userProgressList: [UserProgress]
    @Query private var allWords: [HSKWord]
    
    @State private var showingQuickAdd: Bool = false
    @State private var showingLessonBrowser: Bool = false
    @State private var todaysTasks: [DailyTask] = []
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    /// Tasks for today (anchored to device local day)
    private var tasksForToday: [DailyTask] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return allTasks.filter { $0.date >= startOfToday }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Number of SRS-due words right now
    private var srsReviewsDue: Int {
        let now = Date()
        return allWords.filter { word in
            guard let nextReview = word.nextReviewAt else { return false }
            return nextReview <= now
        }.count
    }
    
    private var completedCount: Int {
        tasksForToday.filter { $0.isCompleted }.count
    }
    
    private var totalMinutesEstimated: Int {
        tasksForToday.reduce(0) { $0 + $1.minutesEstimated }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // ── Greeting & Streak Header ──
                        headerSection
                        
                        // ── Catch-up Banner (if 3+ missed days) ──
                        if progress.needsCatchUp {
                            catchUpBanner
                        }
                        
                        // ── Today's Summary Card ──
                        todaySummaryCard
                        
                        // ── SRS Alert Card ──
                        if srsReviewsDue > 0 {
                            srsAlertCard
                        }
                        
                        // ── Task List ──
                        taskListSection
                        
                        // ── Quick Actions ──
                        quickActionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Hôm nay")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingQuickAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(HanTheme.jadeGreen)
                    }
                    .accessibilityLabel("Thêm từ vựng mới")
                }
            }
            .sheet(isPresented: $showingQuickAdd) {
                VocabQuickAddSheet()
            }
            .sheet(isPresented: $showingLessonBrowser) {
                HSKHubView()
            }
            .onAppear {
                generateTodaysTasks()
                progress.recordDailyActivity()
                NotificationService.shared.clearBadge()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.hanBody(size: 15))
                    .foregroundColor(.gray)
                
                Text(formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
            
            // Streak badge
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                Text("\(progress.currentStreak)")
                    .font(.hanTitle(size: 18))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(20)
            .accessibilityLabel("Chuỗi học \(progress.currentStreak) ngày liên tiếp")
        }
    }
    
    // MARK: - Catch-up Banner
    
    private var catchUpBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 28))
                .foregroundColor(HanTheme.silkGold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Chào mừng bạn trở lại! 💪")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("Chúng tôi đã giới hạn bài ôn để bạn không bị quá tải. Hãy học nhẹ nhàng nhé!")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [HanTheme.silkGold.opacity(0.12), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(14)
    }
    
    // MARK: - Today's Summary
    
    private var todaySummaryCard: some View {
        HStack(spacing: 0) {
            summaryItem(
                value: "\(completedCount)/\(tasksForToday.count)",
                label: "Bài tập",
                icon: "checkmark.circle",
                color: HanTheme.jadeGreen
            )
            
            Divider()
                .frame(height: 36)
                .background(Color.white.opacity(0.1))
            
            summaryItem(
                value: "\(totalMinutesEstimated)",
                label: "Phút",
                icon: "clock",
                color: HanTheme.silkGold
            )
            
            Divider()
                .frame(height: 36)
                .background(Color.white.opacity(0.1))
            
            summaryItem(
                value: "\(progress.totalWordsLearned)",
                label: "Từ vựng",
                icon: "character.book.closed",
                color: HanTheme.vermilionRed
            )
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
    
    private func summaryItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.hanTitle(size: 20))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - SRS Alert
    
    private var srsAlertCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(HanTheme.silkGold.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 20))
                    .foregroundColor(HanTheme.silkGold)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("\(srsReviewsDue) từ vựng cần ôn hôm nay")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("Nhấn để bắt đầu ôn tập ngay")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HanTheme.silkGold)
        }
        .padding(14)
        .background(HanTheme.silkGold.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HanTheme.silkGold.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Task List
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BÀI TẬP HÔM NAY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if !tasksForToday.isEmpty {
                    Text("\(completedCount)/\(tasksForToday.count) hoàn thành")
                        .font(.system(size: 12))
                        .foregroundColor(completedCount == tasksForToday.count ? HanTheme.jadeGreen : .gray)
                }
            }
            
            if tasksForToday.isEmpty {
                // Empty state
                VStack(spacing: 14) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(HanTheme.primaryGradient)
                    Text("Chưa có bài tập nào cho hôm nay")
                        .font(.hanBody(size: 15))
                        .foregroundColor(.gray)
                    Text("Thêm từ vựng mới hoặc duyệt bài học để bắt đầu!")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(tasksForToday) { task in
                    DailyTaskRow(task: task, onComplete: {
                        updateStudyDay()
                    })
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HÀNH ĐỘNG NHANH")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                quickActionButton(
                    icon: "plus.app.fill",
                    title: "Thêm từ",
                    color: HanTheme.jadeGreen,
                    action: { showingQuickAdd = true }
                )
                
                quickActionButton(
                    icon: "books.vertical.fill",
                    title: "Duyệt bài",
                    color: HanTheme.silkGold,
                    action: { showingLessonBrowser = true }
                )
            }
        }
    }
    
    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.buttonTapped()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helpers
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Chào buổi sáng! ☀️" }
        if hour < 18 { return "Buổi chiều tốt lành! 🌤️" }
        return "Buổi tối vui vẻ! 🌙"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func generateTodaysTasks() {
        let progress = userProgressList.first ?? UserProgress()
        _ = DailyTaskGenerator.generateTasks(
            context: modelContext,
            progress: progress
        )
    }
    
    private func updateStudyDay() {
        // Update or create StudyDay for today
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
        
        let todayTasks = tasksForToday
        studyDay.tasksCompleted = todayTasks.filter { $0.isCompleted }.count
        studyDay.tasksTotal = todayTasks.count
        
        try? modelContext.save()
    }
}
