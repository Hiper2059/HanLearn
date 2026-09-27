//
//  DebugLogView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  In-App Diagnostic Console & Hardware Test Tool
//  Cho phép người dùng và tester kiểm tra trực tiếp Micro, Âm thanh, Màn hình tràn viền và Logs thời gian thực
//

import SwiftUI
import AVFoundation

public struct DebugLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var logger = AppLogger.shared
    @ObservedObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    
    @State private var filterLevel: LogLevel? = nil
    @State private var isTestingMic = false
    @State private var micTestResult: String? = nil
    @State private var copiedNotice = false
    
    public init() {}
    
    private var filteredEntries: [LogEntry] {
        if let level = filterLevel {
            return logger.entries.filter { $0.level == level }
        }
        return logger.entries
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.09).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Hardware & System Diagnostics Card
                    diagnosticsCard
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    // 2. Micro Self-Test Bar
                    micTestBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    // 3. Filter Buttons
                    filterBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    
                    // 4. Log Entries List
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            if filteredEntries.isEmpty {
                                Text("Chưa có log nào")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredEntries) { entry in
                                    logEntryRow(entry)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Bảng Chẩn Đoán & Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Xóa logs") {
                        logger.clear()
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .onAppear {
                voiceEvaluator.updatePermissionStatus()
                logSystemMetrics()
            }
        }
    }
    
    private var diagnosticsCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("THÔNG SỐ THIẾT BỊ & HỆ THỐNG")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                Spacer()
                Text("iOS \(UIDevice.current.systemVersion)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                diagnosticItem(
                    title: "Màn hình tràn viền",
                    value: "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height)) @\(Int(UIScreen.main.scale))x",
                    icon: "iphone",
                    color: HanTheme.jadeGreen
                )
                
                diagnosticItem(
                    title: "Quyền Micro",
                    value: voiceEvaluator.permissionStatus,
                    icon: "mic.fill",
                    color: voiceEvaluator.permissionStatus.contains("Granted") ? HanTheme.jadeGreen : HanTheme.vermilionRed
                )
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
    }
    
    private func diagnosticItem(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
    
    private var micTestBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: runQuickMicTest) {
                    HStack(spacing: 6) {
                        Image(systemName: isTestingMic ? "waveform" : "mic.badge.plus")
                        Text(isTestingMic ? "Đang thử Micro (3s)..." : "⚡ Kiểm tra Micro ngay")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(isTestingMic ? HanTheme.vermilionRed : HanTheme.jadeGreen)
                    .cornerRadius(8)
                }
                .disabled(isTestingMic)
                
                Spacer()
                
                Button(action: reseedCurriculum) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Nạp Giáo Trình")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(8)
                }
                
                Button(action: copyLogsToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: copiedNotice ? "checkmark" : "doc.on.doc")
                        Text(copiedNotice ? "Đã chép!" : "Chép Logs")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                }
            }
            
            if let result = micTestResult {
                Text(result)
                    .font(.system(size: 12))
                    .foregroundColor(result.contains("thành công") ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
    }
    
    private var filterBar: some View {
        HStack(spacing: 6) {
            filterButton(title: "Tất cả (\(logger.entries.count))", level: nil)
            ForEach(LogLevel.allCases, id: \.self) { lvl in
                let count = logger.entries.filter { $0.level == lvl }.count
                filterButton(title: "\(lvl.icon) \(count)", level: lvl)
            }
        }
    }
    
    private func filterButton(title: String, level: LogLevel?) -> some View {
        Button(action: {
            filterLevel = level
        }) {
            Text(title)
                .font(.system(size: 11, weight: filterLevel == level ? .bold : .medium))
                .foregroundColor(filterLevel == level ? .white : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(filterLevel == level ? Color.white.opacity(0.2) : Color.white.opacity(0.05))
                .cornerRadius(6)
        }
    }
    
    private func logEntryRow(_ entry: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(entry.formattedTime)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 68, alignment: .leading)
            
            Text(entry.tag)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(entry.level.color)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(entry.level.color.opacity(0.15))
                .cornerRadius(4)
                .frame(width: 75, alignment: .leading)
            
            Text(entry.message)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.02))
        .cornerRadius(4)
    }
    
    private func logSystemMetrics() {
        let bounds = UIScreen.main.bounds
        AppLogger.shared.info(tag: "Screen", message: "Độ phân giải hiển thị: \(bounds.width) x \(bounds.height) @\(UIScreen.main.scale)x (Tràn viền 100%)")
        let session = AVAudioSession.sharedInstance()
        AppLogger.shared.info(tag: "Audio", message: "AudioSession category: \(session.category.rawValue), mode: \(session.mode.rawValue)")
    }
    
    private func runQuickMicTest() {
        isTestingMic = true
        micTestResult = "Đang xin quyền và thu âm thử trong 3 giây..."
        
        Task {
            let granted = await voiceEvaluator.requestPermissions()
            guard granted else {
                isTestingMic = false
                micTestResult = "❌ Thất bại: Quyền Micro chưa được cấp. Hãy vào Cài đặt iPhone."
                return
            }
            
            do {
                try voiceEvaluator.startRecording(targetHanzi: "测试 (Test)")
                try await Task.sleep(nanoseconds: 3_000_000_000)
                let eval = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: "测试", targetPinyin: "cèshì")
                isTestingMic = false
                micTestResult = "✅ Micro hoạt động hoàn hảo! Đã thu âm và chấm điểm: \(eval.overallScore)/100"
                // Thử phát lại âm thanh
                voiceEvaluator.playRecordedVoice()
            } catch {
                isTestingMic = false
                micTestResult = "❌ Lỗi thu âm: \(error.localizedDescription)"
            }
        }
    }
    
    private func copyLogsToClipboard() {
        UIPasteboard.general.string = logger.exportLogsAsText()
        copiedNotice = true
        HapticManager.shared.buttonTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedNotice = false
        }
    }
    
    private func reseedCurriculum() {
        let fetchDescriptor = FetchDescriptor<HSKLesson>()
        let existingLessons = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let existingTitles = Set(existingLessons.map { $0.title })
        var addedCount = 0
        
        for course in SHZCurriculumDatabase.allCourses {
            for lessonData in course.lessons {
                guard !existingTitles.contains(lessonData.title) else { continue }
                
                let lesson = HSKLesson(
                    hskLevel: course.level,
                    title: lessonData.title,
                    topic: lessonData.topic,
                    summary: lessonData.summary,
                    grammarExplanation: lessonData.grammarExplanation,
                    dialogueChinese: lessonData.dialogueChinese,
                    dialoguePinyin: lessonData.dialoguePinyin,
                    dialogueVietnamese: lessonData.dialogueVietnamese
                )
                
                for w in lessonData.vocabulary {
                    let word = HSKWord(
                        hanzi: w.hanzi,
                        pinyin: w.pinyin,
                        sinoVietnamese: w.sinoVietnamese,
                        vietnameseMeaning: w.vietnameseMeaning,
                        hskLevel: course.level,
                        exampleSentenceHanzi: w.exampleHanzi,
                        exampleSentencePinyin: w.examplePinyin,
                        exampleSentenceTranslation: w.exampleTranslation,
                        strokeCount: w.strokeCount
                    )
                    word.nextReviewAt = Date()
                    word.lesson = lesson
                    lesson.vocabularyList.append(word)
                }
                
                modelContext.insert(lesson)
                addedCount += 1
            }
        }
        
        try? modelContext.save()
        let total = (try? modelContext.fetchCount(FetchDescriptor<HSKLesson>())) ?? 0
        AppLogger.shared.success(tag: "SwiftData", message: "Đã nạp thêm \(addedCount) bài học mới. Tổng cộng hiện có: \(total) bài học HSK 1-5.")
        micTestResult = "✅ Đã nạp thành công! Hiện có \(total) bài học HSK 1-5."
    }
}
