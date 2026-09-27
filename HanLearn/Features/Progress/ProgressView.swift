//
//  ProgressView.swift
//  HanLearn
//
//  Progress tab with weekly streak chart (Charts framework), HSK milestone rings,
//  study time split, and this week's summary.
//

import SwiftUI
import SwiftData
import Charts

public struct HanProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudyDay.date, order: .reverse) private var studyDays: [StudyDay]
    @Query private var allWords: [HSKWord]
    @Query private var userProgressList: [UserProgress]
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    /// Last 7 days of study data for the chart
    private var last7Days: [StudyDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekAgo) ?? today
            let startOfDay = calendar.startOfDay(for: date)
            
            if let existing = studyDays.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
                return existing
            }
            return StudyDay(date: date, minutesStudied: 0)
        }
    }
    
    /// HSK milestones
    private struct HSKMilestone {
        let level: Int
        let target: Int
        let color: Color
    }
    
    private let milestones: [HSKMilestone] = [
        HSKMilestone(level: 1, target: 500, color: Color(red: 0.11, green: 0.58, blue: 0.44)),
        HSKMilestone(level: 2, target: 1272, color: Color(red: 0.95, green: 0.68, blue: 0.18)),
        HSKMilestone(level: 3, target: 2245, color: Color(red: 0.88, green: 0.28, blue: 0.24)),
        HSKMilestone(level: 4, target: 4316, color: Color(red: 0.6, green: 0.4, blue: 0.9))
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // ── Streak Header ──
                        streakSection
                        
                        // ── Weekly Chart ──
                        weeklyChartSection
                        
                        // ── HSK Milestones ──
                        milestoneSection
                        
                        // ── Study Split ──
                        studySplitSection
                        
                        // ── This Week Summary ──
                        weekSummarySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Tiến độ")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Streak
    
    private var streakSection: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                    Text("\(progress.currentStreak)")
                        .font(.hanTitle(size: 36))
                        .foregroundColor(.orange)
                }
                Text("Ngày streak hiện tại")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.orange.opacity(0.08))
            .cornerRadius(16)
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundColor(HanTheme.silkGold)
                    Text("\(progress.bestStreak)")
                        .font(.hanTitle(size: 36))
                        .foregroundColor(HanTheme.silkGold)
                }
                Text("Kỷ lục streak")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(HanTheme.silkGold.opacity(0.08))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHÚT HỌC TRONG TUẦN")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            Chart(last7Days, id: \.date) { day in
                BarMark(
                    x: .value("Ngày", day.date, unit: .day),
                    y: .value("Phút", day.minutesStudied)
                )
                .foregroundStyle(
                    day.minutesStudied >= progress.dailyTargetMinutes
                    ? HanTheme.jadeGreen
                    : Color.white.opacity(0.3)
                )
                .cornerRadius(6)
                
                // Target line
                RuleMark(y: .value("Mục tiêu", progress.dailyTargetMinutes))
                    .foregroundStyle(HanTheme.silkGold.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .annotation(position: .trailing, alignment: .trailing) {
                        Text("Mục tiêu")
                            .font(.system(size: 9))
                            .foregroundColor(HanTheme.silkGold.opacity(0.7))
                    }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(dayAbbrev(date))
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let mins = value.as(Int.self) {
                            Text("\(mins)p")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.05))
                }
            }
            .frame(height: 180)
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
        }
    }
    
    // MARK: - HSK Milestones
    
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MỤC TIÊU TỪ VỰNG HSK")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(milestones, id: \.level) { milestone in
                    let count = wordsForLevel(milestone.level)
                    let percent = milestone.target > 0
                        ? min(100, Int(Double(count) / Double(milestone.target) * 100))
                        : 0
                    
                    milestoneRow(
                        level: "HSK \(milestone.level)",
                        count: count,
                        total: milestone.target,
                        percent: percent,
                        color: milestone.color,
                        isTarget: milestone.level == progress.currentHSKTarget
                    )
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
        }
    }
    
    private func milestoneRow(level: String, count: Int, total: Int, percent: Int, color: Color, isTarget: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Text(level)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    if isTarget {
                        Text("Mục tiêu")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Text("\(count)/\(total) từ (\(percent)%)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * CGFloat(percent) / 100.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Study Split
    
    private var studySplitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHÂN BỔ THỜI GIAN HỌC")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            let weekOral = last7Days.reduce(0) { $0 + $1.oralMinutes }
            let weekLiteracy = last7Days.reduce(0) { $0 + $1.literacyMinutes }
            let total = max(1, weekOral + weekLiteracy)
            let oralPercent = Int(Double(weekOral) / Double(total) * 100)
            let literacyPercent = 100 - oralPercent
            
            HStack(spacing: 16) {
                splitCard(
                    icon: "ear.and.waveform",
                    title: "Nghe & Nói",
                    value: "\(oralPercent)%",
                    target: "Mục tiêu: 70%",
                    color: HanTheme.jadeGreen,
                    isOnTarget: oralPercent >= 60
                )
                
                splitCard(
                    icon: "text.book.closed",
                    title: "Đọc & Viết",
                    value: "\(literacyPercent)%",
                    target: "Mục tiêu: 30%",
                    color: HanTheme.silkGold,
                    isOnTarget: literacyPercent <= 40
                )
            }
        }
    }
    
    private func splitCard(icon: String, title: String, value: String, target: String, color: Color, isOnTarget: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.hanTitle(size: 28))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(target)
                .font(.system(size: 10))
                .foregroundColor(isOnTarget ? HanTheme.jadeGreen : .orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
    
    // MARK: - Week Summary
    
    private var weekSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TÓM TẮT TUẦN NÀY")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            let weekMinutes = last7Days.reduce(0) { $0 + $1.minutesStudied }
            let weekReviewed = last7Days.reduce(0) { $0 + $1.wordsReviewed }
            let weekLearned = last7Days.reduce(0) { $0 + $1.wordsLearned }
            let weekTasks = last7Days.reduce(0) { $0 + $1.tasksCompleted }
            
            HStack(spacing: 0) {
                summaryItem(value: "\(weekMinutes)", label: "Phút", icon: "clock.fill", color: HanTheme.jadeGreen)
                summaryItem(value: "\(weekReviewed)", label: "Ôn tập", icon: "arrow.triangle.2.circlepath", color: HanTheme.silkGold)
                summaryItem(value: "\(weekLearned)", label: "Từ mới", icon: "plus.circle.fill", color: HanTheme.vermilionRed)
                summaryItem(value: "\(weekTasks)", label: "Bài tập", icon: "checkmark.circle.fill", color: .white)
            }
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
        }
    }
    
    private func summaryItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.hanTitle(size: 20))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helpers
    
    private func wordsForLevel(_ level: Int) -> Int {
        allWords.filter { $0.hskLevel <= level && $0.masteryPercentage > 0 }.count
    }
    
    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
