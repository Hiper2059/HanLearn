//
//  HomeView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 1 & 4: Màn hình trung tâm "Hôm nay" - Zero-Friction (Không cần đăng nhập, 100% Offline)
//  Tích hợp Lộ trình HSK 1 - 5, Thống kê 3 chỉ số, Cảnh báo SRS, Phím tắt 4 Core Epics và Bài tập hôm nay
//

import SwiftUI
import SwiftData

public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyTask.sortOrder) private var allTasks: [DailyTask]
    @Query private var userProgressList: [UserProgress]
    @Query private var allWords: [HSKWord]
    @Query private var allMistakes: [UserMistake]
    
    @State private var showingQuickAdd: Bool = false
    @State private var showingLessonBrowser: Bool = false
    @State private var showingPracticeZone: Bool = false
    @State private var showingExamAndMistakes: Bool = false
    @State private var showingDebugLog: Bool = false
    @State private var showingVoicePractice: Bool = false
    @State private var showingReview: Bool = false
    @State private var selectedWordForStroke: HSKWord?
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    private var tasksForToday: [DailyTask] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return allTasks.filter { $0.date >= startOfToday }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private var srsReviewsDue: Int {
        let now = Date()
        return allWords.filter { word in
            guard let nextReview = word.nextReviewAt else { return false }
            return nextReview <= now
        }.count
    }
    
    private var unresolvedMistakesCount: Int {
        allMistakes.filter { !$0.isResolved }.count
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
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Greeting & Streak Header
                        headerSection
                        
                        // 2. Today's Summary (3 Cột: Bài tập / Phút / Từ vựng)
                        todaySummaryCard
                        
                        // 3. SRS Alert Banner (Nếu có từ đến hạn)
                        if srsReviewsDue > 0 {
                            NavigationLink(destination: ReviewQueueView()) {
                                srsAlertCard
                            }
                        }
                        
                        // 4. Quick Action Hub (4 Cụm Tính Năng Core)
                        quickFeaturesSection
                        
                        // 5. Bài Tập Hôm Nay
                        taskListSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Hôm nay")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingDebugLog = true
                        HapticManager.shared.buttonTapped()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "terminal.fill")
                            Text("Logs")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(HanTheme.silkGold.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Mở bảng Log chẩn đoán")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingQuickAdd = true
                        HapticManager.shared.buttonTapped()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(HanTheme.jadeGreen)
                    }
                    .accessibilityLabel("Thêm từ vựng mới")
                }
            }
            .sheet(isPresented: $showingDebugLog) {
                DebugLogView()
            }
            .sheet(isPresented: $showingQuickAdd) {
                VocabQuickAddSheet()
            }
            .sheet(isPresented: $showingLessonBrowser) {
                HSKHubView()
            }
            .sheet(isPresented: $showingPracticeZone) {
                PracticeZoneView()
            }
            .sheet(isPresented: $showingExamAndMistakes) {
                ExamAndMistakeView()
            }
            .sheet(isPresented: $showingVoicePractice) {
                VoiceDialogueView(
                    targetHanzi: allWords.first?.exampleSentenceHanzi.isEmpty == false ? allWords.first!.exampleSentenceHanzi : "你好，很高兴认识你！",
                    targetPinyin: allWords.first?.exampleSentencePinyin.isEmpty == false ? allWords.first!.exampleSentencePinyin : "Nǐ hǎo, hěn gāoxìng rènshi nǐ!"
                )
            }
            .sheet(item: $selectedWordForStroke) { word in
                StrokeCanvasView(word: word)
            }
            .sheet(isPresented: $showingReview) {
                ReviewQueueView()
            }
            .onAppear {
                generateTodaysTasks()
                progress.recordDailyActivity()
                NotificationService.shared.clearBadge()
            }
        }
    }
    
    // MARK: - 1. HEADER SECTION
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                
                Text(formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
            }
            
            Spacer()
            
            // Streak badge
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                Text("\(progress.currentStreak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.14))
            .cornerRadius(20)
        }
    }
    
    // MARK: - 2. TODAY'S SUMMARY (3 CỘT)
    private var todaySummaryCard: some View {
        HStack(spacing: 0) {
            summaryItem(
                value: "\(completedCount)/\(max(1, tasksForToday.count))",
                label: "Bài tập",
                icon: "checkmark.circle",
                color: HanTheme.jadeGreen
            )
            
            Divider()
                .frame(height: 38)
                .background(Color.white.opacity(0.12))
            
            summaryItem(
                value: "\(max(15, totalMinutesEstimated))",
                label: "Phút",
                icon: "clock",
                color: HanTheme.silkGold
            )
            
            Divider()
                .frame(height: 38)
                .background(Color.white.opacity(0.12))
            
            summaryItem(
                value: "\(allWords.count)",
                label: "Từ vựng",
                icon: "character.book.closed",
                color: HanTheme.vermilionRed
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.11, green: 0.12, blue: 0.15))
        )
    }
    
    private func summaryItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 3. SRS ALERT BANNER
    private var srsAlertCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(HanTheme.silkGold.opacity(0.18))
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
                    .foregroundColor(.white.opacity(0.65))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HanTheme.silkGold)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.15, green: 0.12, blue: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(HanTheme.silkGold.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 4. QUICK FEATURES SECTION (4 CORE EPICS)
    private var quickFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRUNG TÂM LUYỆN TẬP")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.55))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Feature 1: Máy Tự Check
                Button(action: {
                    showingPracticeZone = true
                    HapticManager.shared.buttonTapped()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                                .font(.system(size: 22))
                            Spacer()
                            Text("CORE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(HanTheme.jadeGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(HanTheme.jadeGreen.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Text("Máy Tự Check")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Nghe chép, Xếp câu, Đọc")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(red: 0.10, green: 0.13, blue: 0.16))
                    .cornerRadius(14)
                }
                
                // Feature 2: Sổ Tay Lỗi Sai
                Button(action: {
                    showingExamAndMistakes = true
                    HapticManager.shared.buttonTapped()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(HanTheme.vermilionRed)
                                .font(.system(size: 22))
                            Spacer()
                            if unresolvedMistakesCount > 0 {
                                Text("\(unresolvedMistakesCount)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(HanTheme.vermilionRed)
                                    .cornerRadius(10)
                            }
                        }
                        Text("Sổ Tay Lỗi Sai")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Luyện lại đạt >= 80%")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(red: 0.14, green: 0.10, blue: 0.12))
                    .cornerRadius(14)
                }
                
                // Feature 3: Thi Thử HSK 1 - 5
                Button(action: {
                    showingExamAndMistakes = true
                    HapticManager.shared.buttonTapped()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "graduationcap.fill")
                            .foregroundColor(HanTheme.silkGold)
                            .font(.system(size: 22))
                        Text("Thi Thử HSK")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Đề chuẩn HSK 1 - 5")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(red: 0.14, green: 0.13, blue: 0.10))
                    .cornerRadius(14)
                }
                
                // Feature 4: Giáo Trình 72 Tiết
                Button(action: {
                    showingLessonBrowser = true
                    HapticManager.shared.buttonTapped()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "books.vertical.fill")
                            .foregroundColor(Color.blue)
                            .font(.system(size: 22))
                        Text("Giáo Trình")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("72 Tiết học tích hợp")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(red: 0.10, green: 0.12, blue: 0.18))
                    .cornerRadius(14)
                }
            }
        }
    }
    
    // MARK: - 5. TASK LIST SECTION
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("BÀI TẬP HÔM NAY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.55))
                
                Spacer()
                
                if !tasksForToday.isEmpty {
                    Text("\(completedCount)/\(tasksForToday.count) hoàn thành")
                        .font(.system(size: 12))
                        .foregroundColor(completedCount == tasksForToday.count ? HanTheme.jadeGreen : .white.opacity(0.6))
                }
            }
            
            if tasksForToday.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundColor(HanTheme.silkGold)
                    Text("Chưa có bài tập nào cho hôm nay")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Nhấn vào 'Máy Tự Check' hoặc duyệt bài học để rèn luyện!")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.white.opacity(0.04))
                .cornerRadius(14)
            } else {
                ForEach(tasksForToday) { task in
                    DailyTaskRow(task: task, onComplete: {
                        updateStudyDay()
                    }, onTap: {
                        handleTaskTap(task)
                    })
                }
            }
        }
    }
    
    private func handleTaskTap(_ task: DailyTask) {
        HapticManager.shared.buttonTapped()
        switch task.category {
        case .speaking, .listening:
            showingVoicePractice = true
        case .characters, .pinyin:
            if let first = allWords.first {
                selectedWordForStroke = first
            } else {
                showingPracticeZone = true
            }
        case .review:
            showingReview = true
        case .vocabulary, .grammar, .journal:
            showingPracticeZone = true
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
