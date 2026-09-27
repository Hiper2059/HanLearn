//
//  ProgressAndBackupView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 1: Local Core & LMS (Thanh tiến độ, Thống kê HSK, Xuất & Nhập Backup JSON 100% Offline)
//

import SwiftUI
import SwiftData
import Charts

public struct ProgressAndBackupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudyDay.date, order: .reverse) private var studyDays: [StudyDay]
    @Query private var allWords: [HSKWord]
    @Query private var userProgressList: [UserProgress]
    @Query private var allMistakes: [UserMistake]
    
    @State private var showingExportSheet: Bool = false
    @State private var showingImportSheet: Bool = false
    @State private var showingDebugLog: Bool = false
    @State private var exportedJSONString: String = ""
    @State private var importInputString: String = ""
    @State private var showImportAlert: Bool = false
    @State private var importAlertMessage: String = ""
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
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
    
    private struct HSKMilestone {
        let level: Int
        let target: Int
        let color: Color
    }
    
    private let milestones: [HSKMilestone] = [
        HSKMilestone(level: 1, target: 500, color: HanTheme.jadeGreen),
        HSKMilestone(level: 2, target: 1272, color: Color.blue),
        HSKMilestone(level: 3, target: 2245, color: HanTheme.silkGold),
        HSKMilestone(level: 4, target: 4316, color: Color.purple),
        HSKMilestone(level: 5, target: 5000, color: HanTheme.vermilionRed)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // 1. Thẻ Streak & XP
                        streakSection
                        
                        // 2. Biểu đồ học tập trong tuần
                        weeklyChartSection
                        
                        // 3. Tiến độ HSK 1 - 5
                        milestoneSection
                        
                        // 4. Phân bổ kỹ năng
                        studySplitSection
                        
                        // 5. Cụm Sao lưu & Khôi phục (JSON Backup 100% Offline)
                        backupSection
                        
                        // 6. Chẩn đoán hệ thống & Logs
                        diagnosticsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Tiến Độ & Sao Lưu")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDebugLog) {
                DebugLogView()
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportJSONSheet(jsonString: exportedJSONString)
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportJSONSheet(
                    inputString: $importInputString,
                    onImport: { json in
                        let success = BackupService.importFromJSON(json, modelContext: modelContext)
                        importAlertMessage = success ? "Khôi phục dữ liệu thành công!" : "File JSON không hợp lệ, vui lòng kiểm tra lại."
                        showImportAlert = true
                    }
                )
            }
            .alert("Thông báo", isPresented: $showImportAlert) {
                Button("OK") {}
            } message: {
                Text(importAlertMessage)
            }
        }
    }
    
    // MARK: - 1. Streak & XP Section
    private var streakSection: some View {
        HStack(spacing: 14) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.orange)
                    Text("\(progress.currentStreak)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                Text("Ngày streak hiện tại")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.orange.opacity(0.12))
            .cornerRadius(16)
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 22))
                        .foregroundColor(HanTheme.silkGold)
                    Text("\(progress.totalXP)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(HanTheme.silkGold)
                }
                Text("Tổng điểm kinh nghiệm (XP)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(HanTheme.silkGold.opacity(0.12))
            .cornerRadius(16)
        }
    }
    
    // MARK: - 2. Weekly Chart
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PHÚT HỌC TRONG TUẦN")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
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
                }
            }
            .frame(height: 160)
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - 3. HSK Milestones (HSK 1 - 5)
    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIẾN TRÌNH TỪ VỰNG HSK 1 - HSK 5")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 12) {
                ForEach(milestones, id: \.level) { milestone in
                    let count = wordsForLevel(milestone.level)
                    let percent = milestone.target > 0
                        ? min(100, Int(Double(count) / Double(milestone.target) * 100))
                        : 0
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("HSK \(milestone.level)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(count)/\(milestone.target) từ (\(percent)%)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 7)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(milestone.color)
                                    .frame(width: max(0, geo.size.width * CGFloat(percent) / 100.0), height: 7)
                            }
                        }
                        .frame(height: 7)
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - 4. Study Split
    private var studySplitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHÂN BỔ KỸ NĂNG HỌC")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "headphones")
                        .font(.system(size: 20))
                        .foregroundColor(HanTheme.jadeGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nghe & Nói")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("65% thời lượng")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
                
                HStack(spacing: 10) {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 20))
                        .foregroundColor(HanTheme.silkGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Đọc & Viết")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("35% thời lượng")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
            }
        }
    }
    
    // MARK: - 5. Sao Lưu & Khôi Phục (Backup .json)
    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUẢN LÝ DỮ LIỆU CỤC BỘ (100% OFFLINE)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HanTheme.jadeGreen)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "externaldrive.fill.badge.checkmark")
                        .font(.system(size: 26))
                        .foregroundColor(HanTheme.jadeGreen)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Bảo mật & Tự chủ dữ liệu")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Ứng dụng không cần đăng nhập. Tiến độ, từ vựng và sổ lỗi được lưu ngay trên máy của bạn.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack(spacing: 12) {
                    // Nút Xuất Backup
                    Button(action: {
                        if let json = BackupService.exportToJSON(modelContext: modelContext) {
                            exportedJSONString = json
                            showingExportSheet = true
                            HapticManager.shared.buttonTapped()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up.fill")
                            Text("Xuất Backup (.json)")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HanTheme.jadeGreen)
                        .cornerRadius(12)
                    }
                    
                    // Nút Nhập Backup
                    Button(action: {
                        importInputString = ""
                        showingImportSheet = true
                        HapticManager.shared.buttonTapped()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Nhập Backup")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.10, green: 0.13, blue: 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(HanTheme.jadeGreen.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - 6. CHẨN ĐOÁN HỆ THỐNG & LOGS
    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CHẨN ĐOÁN HỆ THỐNG & LOGS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            Button(action: {
                showingDebugLog = true
                HapticManager.shared.buttonTapped()
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(HanTheme.silkGold.opacity(0.18))
                            .frame(width: 42, height: 42)
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 18))
                            .foregroundColor(HanTheme.silkGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Xem Logs & Kiểm tra Micro")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Theo dõi lỗi, AudioSession, Quyền & Độ phân giải màn hình")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HanTheme.silkGold)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.12, green: 0.11, blue: 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(HanTheme.silkGold.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
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

// MARK: - EXPORT JSON SHEET
struct ExportJSONSheet: View {
    @Environment(\.dismiss) private var dismiss
    let jsonString: String
    @State private var copied: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Dưới đây là toàn bộ tiến độ học tập, từ vựng và sổ lỗi của bạn ở định dạng JSON chuẩn. Bạn có thể sao chép hoặc lưu trữ dự phòng.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                ScrollView {
                    Text(jsonString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    UIPasteboard.general.string = jsonString
                    copied = true
                    HapticManager.shared.answerCorrect()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc.fill")
                        Text(copied ? "Đã sao chép vào bộ nhớ tạm!" : "Sao Chép Toàn Bộ JSON")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("Xuất Dữ Liệu (.json)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - IMPORT JSON SHEET
struct ImportJSONSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var inputString: String
    let onImport: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Dán nội dung file backup (.json) vào ô bên dưới để khôi phục tiến độ.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                TextEditor(text: $inputString)
                    .font(.system(size: 12, design: .monospaced))
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                
                Button(action: {
                    guard !inputString.isEmpty else { return }
                    onImport(inputString)
                    dismiss()
                }) {
                    Text("Khôi Phục Tiến Độ Ngay")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(inputString.isEmpty ? Color.gray : HanTheme.jadeGreen)
                        .cornerRadius(14)
                }
                .disabled(inputString.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("Nhập Dữ Liệu Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}
