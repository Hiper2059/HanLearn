//
//  OnboardingView.swift
//  HanLearn
//
//  2–3 step first-launch onboarding flow.
//  Collects: HSK level, daily time budget, learning goal.
//  Sets starting stage and navigates to main app.
//

import SwiftUI
import SwiftData

public struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    @State private var currentPage: Int = 0
    @State private var selectedLevel: Int = 1
    @State private var selectedMinutes: Int = 30
    @State private var selectedGoal: LearningGoal = .travel
    @State private var isAnimating: Bool = false
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.15, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index <= currentPage ? HanTheme.jadeGreen : Color.white.opacity(0.2))
                            .frame(width: index == currentPage ? 28 : 10, height: 6)
                            .animation(.spring(response: 0.4), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    levelSelectionPage.tag(0)
                    timeSelectionPage.tag(1)
                    goalSelectionPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Bottom button
                Button(action: {
                    HapticManager.shared.buttonTapped()
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage < 2 ? "Tiếp tục" : "Bắt đầu học! 🚀")
                            .font(.hanBody(size: 18))
                            .bold()
                        if currentPage < 2 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(HanTheme.primaryGradient)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Page 1: Level Selection
    
    private var levelSelectionPage: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(HanTheme.primaryGradient)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Bạn đang ở trình độ nào?")
                    .font(.hanTitle(size: 26))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Chúng tôi sẽ điều chỉnh lộ trình phù hợp")
                    .font(.hanBody(size: 15))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 12) {
                levelCard(level: 1, title: "HSK 1 · Bắt đầu từ đầu", subtitle: "Chưa biết gì, học Pinyin & 500 từ cơ bản", wordCount: "500 từ")
                levelCard(level: 2, title: "HSK 2 · Biết chút cơ bản", subtitle: "Đã biết Pinyin, biết vài từ đơn giản", wordCount: "1.272 từ")
                levelCard(level: 3, title: "HSK 3 · Giao tiếp đơn giản", subtitle: "Có thể nói câu ngắn, đọc chữ cơ bản", wordCount: "2.245 từ")
                levelCard(level: 4, title: "HSK 4 · Trung cấp", subtitle: "Nghe hiểu, đọc báo, nói được đoạn dài", wordCount: "4.316 từ")
            }
            .padding(.horizontal, 20)
        }
        .onAppear { isAnimating = true }
    }
    
    private func levelCard(level: Int, title: String, subtitle: String, wordCount: String) -> some View {
        Button(action: {
            selectedLevel = level
            HapticManager.shared.buttonTapped()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(selectedLevel == level ? HanTheme.jadeGreen : Color.white.opacity(0.08))
                        .frame(width: 44, height: 44)
                    
                    Text("\(level)")
                        .font(.hanTitle(size: 18))
                        .foregroundColor(selectedLevel == level ? .black : .white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(wordCount)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(6)
            }
            .padding(14)
            .background(selectedLevel == level ? HanTheme.jadeGreen.opacity(0.12) : Color.white.opacity(0.04))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selectedLevel == level ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Page 2: Time Budget
    
    private var timeSelectionPage: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(HanTheme.goldGradient)
                
                Text("Mỗi ngày bạn có bao lâu?")
                    .font(.hanTitle(size: 26))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Lộ trình gợi ý: sáng 20 phút + tối 30 phút")
                    .font(.hanBody(size: 15))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 14) {
                timeCard(minutes: 15, emoji: "🌱", label: "15 phút", description: "Nhẹ nhàng, mỗi ngày một chút")
                timeCard(minutes: 30, emoji: "📚", label: "30 phút", description: "Tốc độ vừa phải (khuyên dùng)")
                timeCard(minutes: 45, emoji: "🔥", label: "45 phút", description: "Nghiêm túc, tiến bộ nhanh")
                timeCard(minutes: 60, emoji: "🏆", label: "60 phút", description: "Siêu nghiêm túc, luyện chuyên sâu")
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func timeCard(minutes: Int, emoji: String, label: String, description: String) -> some View {
        Button(action: {
            selectedMinutes = minutes
            HapticManager.shared.buttonTapped()
        }) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 30))
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if selectedMinutes == minutes {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .padding(14)
            .background(selectedMinutes == minutes ? HanTheme.jadeGreen.opacity(0.12) : Color.white.opacity(0.04))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selectedMinutes == minutes ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Page 3: Goal Selection
    
    private var goalSelectionPage: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 56))
                    .foregroundStyle(HanTheme.fireGradient)
                
                Text("Mục tiêu của bạn là gì?")
                    .font(.hanTitle(size: 26))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Chúng tôi sẽ ưu tiên nội dung phù hợp")
                    .font(.hanBody(size: 15))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 14) {
                goalCard(goal: .travel, emoji: "🌏", title: "Du lịch", description: "Giao tiếp cơ bản khi đi Trung Quốc, Đài Loan")
                goalCard(goal: .exam, emoji: "📝", title: "Thi HSK", description: "Ôn thi HSK có hệ thống, đạt chứng chỉ")
                goalCard(goal: .work, emoji: "💼", title: "Công việc", description: "Giao tiếp chuyên nghiệp, email, họp")
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func goalCard(goal: LearningGoal, emoji: String, title: String, description: String) -> some View {
        Button(action: {
            selectedGoal = goal
            HapticManager.shared.buttonTapped()
        }) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 36))
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if selectedGoal == goal {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .padding(16)
            .background(selectedGoal == goal ? HanTheme.jadeGreen.opacity(0.12) : Color.white.opacity(0.04))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selectedGoal == goal ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Complete Onboarding
    
    private func completeOnboarding() {
        let progress = userProgressList.first ?? UserProgress()
        
        if userProgressList.isEmpty {
            modelContext.insert(progress)
        }
        
        progress.currentHSKTarget = selectedLevel
        progress.dailyTargetMinutes = selectedMinutes
        progress.learningGoal = selectedGoal
        progress.currentStage = UserProgress.startingStage(forLevel: selectedLevel)
        progress.hasCompletedOnboarding = true
        progress.lastActiveDate = Date()
        
        try? modelContext.save()
        
        HapticManager.shared.answerCorrect()
        
        // Request notification permission (non-blocking)
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                await MainActor.run {
                    progress.notificationsEnabled = true
                    NotificationService.shared.scheduleDailyReminder(
                        hour: progress.notificationHour,
                        minute: progress.notificationMinute,
                        streak: progress.currentStreak
                    )
                    try? modelContext.save()
                }
            }
        }
    }
}
