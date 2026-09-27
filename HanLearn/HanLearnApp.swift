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
        
        // Seed sample lesson if none exists
        let fetchDescriptor = FetchDescriptor<HSKLesson>()
        if let count = try? context.fetchCount(fetchDescriptor), count == 0 {
            let sampleLesson = HSKLesson(
                hskLevel: 2,
                title: "Đi siêu thị mua sắm (超市购物)",
                topic: "Mua sắm & Đời sống",
                summary: "Học các từ vựng mua sắm, hỏi giá, giảm giá và cấu trúc hỏi giá trong tiếng Trung.",
                grammarExplanation: "Cấu trúc hỏi giá: '这件 / 这个 + Danh từ + 多少钱？'\nVí dụ: 这个苹果多少钱？(Quả táo này bao nhiêu tiền?).",
                dialogueChinese: "你好，请问这个苹果多少钱一斤？\n五块钱一斤，很甜的。\n太贵了，可以便宜一点吗？\n给你打九折吧。",
                dialoguePinyin: "Nǐ hǎo, qǐngwèn zhège píngguǒ duōshao qián yì jīn?\nWǔ kuài qián yì jīn, hěn tián de.\nTài guì le, kěyǐ piányi yìdiǎn ma?\nGěi nǐ dǎ jiǔ zhé ba.",
                dialogueVietnamese: "Xin chào, cho hỏi táo này bao nhiêu tiền một cân?\n5 tệ một cân, ngọt lắm ạ.\nĐắt quá, có thể rẻ hơn một chút không?\nGiảm giá cho bạn 10% (đánh 9折) nhé."
            )
            
            let word1 = HSKWord(
                hanzi: "苹果",
                pinyin: "píngguǒ",
                sinoVietnamese: "Bình quả",
                vietnameseMeaning: "Quả táo",
                hskLevel: 1,
                exampleSentenceHanzi: "我想买苹果。",
                exampleSentencePinyin: "Wǒ xiǎng mǎi píngguǒ.",
                exampleSentenceTranslation: "Tôi muốn mua táo.",
                strokeCount: 8
            )
            word1.lesson = sampleLesson
            sampleLesson.vocabularyList.append(word1)
            
            let word2 = HSKWord(
                hanzi: "便宜",
                pinyin: "piányi",
                sinoVietnamese: "Tiện nghi",
                vietnameseMeaning: "Rẻ, giá cả phải chăng",
                hskLevel: 2,
                exampleSentenceHanzi: "这件衣服很便宜。",
                exampleSentencePinyin: "Zhè jiàn yīfu hěn piányi.",
                exampleSentenceTranslation: "Bộ đồ này rất rẻ.",
                strokeCount: 11
            )
            word2.lesson = sampleLesson
            sampleLesson.vocabularyList.append(word2)
            
            let quiz1 = HSKQuiz(
                type: .multipleChoice,
                promptText: "Từ '苹果' (píngguǒ) có nghĩa là gì?",
                targetHanzi: "苹果",
                targetPinyin: "píngguǒ",
                optionsData: ["Quả táo", "Quả chuối", "Quả cam", "Quả dưa hấu"],
                correctAnswer: "Quả táo",
                explanation: "苹果 (píngguǒ) là quả táo, từ vựng cơ bản HSK 1."
            )
            quiz1.lesson = sampleLesson
            sampleLesson.quizzes.append(quiz1)
            
            context.insert(sampleLesson)
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
