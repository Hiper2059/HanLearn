//
//  HanLearnApp.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  App Entry Point: SwiftData ModelContainer, Onboarding Gate & 5-Tab Architecture
//

import SwiftUI
import SwiftData

@main
struct HanLearnApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HSKLesson.self,
            HSKWord.self,
            HSKQuiz.self,
            VoiceRecord.self,
            UserProgress.self,
            DailyTask.self,
            JournalEntry.self,
            StudyDay.self,
            UserMistake.self
        ])
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isTesting)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            if let fallbackContainer = try? ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]) {
                return fallbackContainer
            }
            fatalError("Không thể khởi tạo SwiftData ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .onAppear {
                    seedInitialDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private func seedInitialDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        
        // Seed UserProgress if none exists
        let progressDescriptor = FetchDescriptor<UserProgress>()
        if let count = try? context.fetchCount(progressDescriptor), count == 0 {
            context.insert(UserProgress())
        }
        
        // Seed SHZ HSK 3.0 Curriculum (tự động bổ sung các bài học và từ vựng mới)
        let fetchDescriptor = FetchDescriptor<HSKLesson>()
        let existingLessons = (try? context.fetch(fetchDescriptor)) ?? []
        let existingTitles = Set(existingLessons.map { $0.title })
        
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
                
                // Tạo bài tập trắc nghiệm nối từ
                if let firstWord = lessonData.vocabulary.first {
                    let quiz = HSKQuiz(
                        type: .multipleChoice,
                        promptText: "Từ '\(firstWord.hanzi)' (\(firstWord.pinyin)) có nghĩa là gì?",
                        targetHanzi: firstWord.hanzi,
                        targetPinyin: firstWord.pinyin,
                        optionsData: [firstWord.vietnameseMeaning, "Trường học", "Ngày mai", "Bác sĩ"],
                        correctAnswer: firstWord.vietnameseMeaning,
                        explanation: "\(firstWord.hanzi) mang nghĩa là \(firstWord.vietnameseMeaning)."
                    )
                    quiz.lesson = lesson
                    lesson.quizzes.append(quiz)
                }
                
                context.insert(lesson)
            }
        }
        
        // Seed sample mistake if none exists (để người dùng thấy tính năng Sổ tay lỗi sai ngay)
        let mistakeDescriptor = FetchDescriptor<UserMistake>()
        if let count = try? context.fetchCount(mistakeDescriptor), count == 0 {
            let sampleMistake = UserMistake(
                questionType: "dictation",
                hskLevel: 1,
                promptText: "Nghe và chép chính tả: '我想买一个苹果。'",
                targetAnswer: "我想买一个苹果",
                userAnswer: "我想买一哥苹果",
                explanation: "Lưu ý lượng từ '个' (gè), không dùng '哥' (gē)."
            )
            context.insert(sampleMistake)
        }
        
        try? context.save()
    }
}

// MARK: - Root View (Onboarding Gate)
struct RootView: View {
    @Query private var userProgressList: [UserProgress]
    
    private var hasCompletedOnboarding: Bool {
        userProgressList.first?.hasCompletedOnboarding ?? false
    }
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

// MARK: - Main 5-Tab Navigation (Golden Senior iOS Architecture)
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Hôm nay", systemImage: "house.fill")
                }
            
            PracticeZoneView()
                .tabItem {
                    Label("Tự Check", systemImage: "checkmark.seal.fill")
                }
            
            ReviewQueueView()
                .tabItem {
                    Label("Ôn tập", systemImage: "rectangle.stack.fill")
                }
            
            ExamAndMistakeView()
                .tabItem {
                    Label("Sổ Lỗi & Thi", systemImage: "bookmark.fill")
                }
            
            ProgressAndBackupView()
                .tabItem {
                    Label("Tiến độ", systemImage: "chart.bar.fill")
                }
        }
        .tint(HanTheme.jadeGreen)
    }
}
