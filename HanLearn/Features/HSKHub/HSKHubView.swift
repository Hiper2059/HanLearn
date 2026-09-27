//
//  HSKHubView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Màn hình chính HSK Hub - Lựa chọn cấp độ & Tự động sinh bài giảng mới nhất
//

import SwiftUI
import SwiftData

public struct HSKHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HSKLesson.createdAt, order: .reverse) private var lessons: [HSKLesson]
    @Query private var userProgressList: [UserProgress]
    
    @State private var selectedLevel: Int = 2
    @State private var topicSearchText: String = ""
    @State private var isGenerating: Bool = false
    @State private var activeLessonForDetail: HSKLesson?
    @State private var activeLessonForQuiz: HSKLesson?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header: Streak & XP
                        headerStatsView
                        
                        // HSK Level Selector (HSK 1 -> HSK 6)
                        levelSelectorSection
                        
                        // Generator Box (Nhập chủ đề & Bấm tự động tìm kiếm/sinh bài)
                        autoGeneratorSection
                        
                        // Danh sách bài học đã lưu trên máy
                        savedLessonsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("HanLearn HSK 3.0")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activeLessonForDetail) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .sheet(item: $activeLessonForQuiz) { lesson in
                TopicQuizView(lesson: lesson)
            }
        }
    }
    
    private var headerStatsView: some View {
        let progress = userProgressList.first ?? UserProgress()
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(progress.currentStreak) Ngày Streak")
                    .font(.hanBody(size: 14))
                    .bold()
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
                    .font(.hanBody(size: 14))
                    .bold()
                    .foregroundColor(HanTheme.silkGold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(HanTheme.silkGold.opacity(0.15))
            .cornerRadius(20)
        }
    }
    
    private var levelSelectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHỌN CẤP ĐỘ HSK MỤC TIÊU")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...6, id: \.self) { level in
                        Button(action: {
                            HapticManager.shared.buttonTapped()
                            selectedLevel = level
                        }) {
                            VStack(spacing: 4) {
                                Text("HSK \(level)")
                                    .font(.hanTitle(size: 16))
                                    .foregroundColor(selectedLevel == level ? .white : .gray)
                                Text(levelDescription(level))
                                    .font(.system(size: 10))
                                    .foregroundColor(selectedLevel == level ? .white.opacity(0.8) : .gray.opacity(0.8))
                            }
                            .frame(width: 80, height: 60)
                            .background(
                                selectedLevel == level
                                ? AnyShapeStyle(HanTheme.primaryGradient)
                                : AnyShapeStyle(Color.white.opacity(0.06))
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedLevel == level ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var autoGeneratorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.badge.automatic.fill")
                    .foregroundColor(HanTheme.silkGold)
                Text("TỰ ĐỘNG SINH BÀI GIẢNG MỚI NHẤT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack {
                TextField("Nhập chủ đề (vd: Mua sắm Taobao, Đi du lịch, IT...)", text: $topicSearchText)
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
    
    private var savedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("BÀI HỌC TRÊN THIẾT BỊ (\(lessons.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("Offline Ready")
                    .font(.system(size: 11))
                    .foregroundColor(HanTheme.jadeGreen)
            }
            
            if lessons.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Chưa có bài học nào được lưu.\nHãy nhập chủ đề ở trên và bấm tạo tự động!")
                        .font(.hanBody(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(lessons) { lesson in
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
                                .font(.hanBody(size: 16))
                                .bold()
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
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                activeLessonForDetail = lesson
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "book.fill")
                                    Text("Xem Bài Học")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(HanTheme.jadeGreen)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                activeLessonForQuiz = lesson
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                    Text("Luyện Tập Quiz")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(HanTheme.silkGold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(HanTheme.silkGold.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                }
            }
        }
    }
    
    private func levelDescription(_ level: Int) -> String {
        switch level {
        case 1: return "Cơ bản 500 từ"
        case 2: return "Sơ cấp 1272 từ"
        case 3: return "Giao tiếp 2245 từ"
        case 4: return "Trung cấp 4316 từ"
        case 5: return "Nâng cao 8300 từ"
        case 6: return "Thành thạo 11092 từ"
        default: return ""
        }
    }
    
    private func triggerAutoGenerate() {
        isGenerating = true
        HapticManager.shared.buttonTapped()
        
        Task {
            do {
                let package = try await HSKDiscoveryService.shared.generateHSKLesson(level: selectedLevel, topic: topicSearchText)
                
                await MainActor.run {
                    let newLesson = HSKLesson(
                        hskLevel: package.hskLevel,
                        title: package.title,
                        topic: package.topic,
                        summary: package.summary,
                        grammarExplanation: package.grammarExplanation,
                        dialogueChinese: package.dialogueChinese,
                        dialoguePinyin: package.dialoguePinyin,
                        dialogueVietnamese: package.dialogueVietnamese
                    )
                    
                    for w in package.vocabulary {
                        let word = HSKWord(
                            hanzi: w.hanzi,
                            pinyin: w.pinyin,
                            sinoVietnamese: w.sinoVietnamese,
                            vietnameseMeaning: w.vietnameseMeaning,
                            hskLevel: package.hskLevel,
                            partOfSpeech: w.partOfSpeech,
                            exampleSentenceHanzi: w.exampleSentence,
                            exampleSentencePinyin: w.examplePinyin,
                            exampleSentenceTranslation: w.exampleTranslation,
                            strokeCount: w.strokeCount
                        )
                        word.lesson = newLesson
                        newLesson.vocabularyList.append(word)
                    }
                    
                    for q in package.quizSeeds {
                        let quiz = HSKQuiz(
                            type: QuizType(rawValue: q.type) ?? .multipleChoice,
                            promptText: q.prompt,
                            targetHanzi: q.targetHanzi,
                            targetPinyin: q.targetPinyin,
                            optionsData: q.options,
                            correctAnswer: q.correctAnswer,
                            explanation: q.explanation
                        )
                        quiz.lesson = newLesson
                        newLesson.quizzes.append(quiz)
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
