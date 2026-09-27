//
//  DailyTaskGenerator.swift
//  HanLearn
//
//  Generates the daily task list for the Home tab from three sources:
//  1. Weekly 6-day study template (mapped to current weekday)
//  2. SRS due words (vocab with nextReviewAt <= today)
//  3. Carry-over incomplete tasks from yesterday
//

import Foundation
import SwiftData

public final class DailyTaskGenerator {
    
    // ── Weekly Study Template ──
    // Based on the roadmap's 6-day cycle:
    // Mon–Fri structured study, Sat review day
    // Morning 20 min / Evening 30 min
    
    public struct TemplateSlot {
        public let title: String
        public let category: TaskCategory
        public let minutes: Int
        public let subtitle: String?
    }
    
    /// Returns the template tasks for a given weekday (1=Sunday...7=Saturday in Foundation)
    private static func templateSlots(for weekday: Int, stage: Int) -> [TemplateSlot] {
        // Stages 1–3: sequential (pinyin → characters → vocab only)
        // Stages 4–6: parallel (vocab + grammar + speaking simultaneously)
        
        let isParallelStage = stage >= 4
        
        switch weekday {
        case 2: // Monday
            var slots: [TemplateSlot] = [
                TemplateSlot(title: "Học 10–15 từ vựng mới", category: .vocabulary, minutes: 20, subtitle: "Buổi sáng · Từ vựng mới"),
            ]
            if isParallelStage {
                slots.append(TemplateSlot(title: "Luyện ngữ pháp + Nghe", category: .grammar, minutes: 15, subtitle: "Buổi tối · Ngữ pháp"))
                slots.append(TemplateSlot(title: "Luyện nghe đoạn hội thoại", category: .listening, minutes: 15, subtitle: "Buổi tối · Nghe"))
            } else if stage <= 2 {
                slots.append(TemplateSlot(title: "Luyện Pinyin & 4 thanh điệu", category: .pinyin, minutes: 30, subtitle: "Buổi tối · Pinyin"))
            } else {
                slots.append(TemplateSlot(title: "Tập viết chữ Hán", category: .characters, minutes: 30, subtitle: "Buổi tối · Nét viết"))
            }
            return slots
            
        case 3: // Tuesday
            var slots: [TemplateSlot] = [
                TemplateSlot(title: "Ôn tập từ vựng (SRS)", category: .review, minutes: 20, subtitle: "Buổi sáng · Ôn tập"),
            ]
            if isParallelStage {
                slots.append(TemplateSlot(title: "Luyện nói câu mẫu", category: .speaking, minutes: 30, subtitle: "Buổi tối · Luyện nói"))
            } else {
                slots.append(TemplateSlot(title: "Nghe và lặp lại", category: .listening, minutes: 30, subtitle: "Buổi tối · Nghe"))
            }
            return slots
            
        case 4: // Wednesday
            var slots: [TemplateSlot] = [
                TemplateSlot(title: "Học từ vựng mới + Tập viết", category: .vocabulary, minutes: 20, subtitle: "Buổi sáng · Từ vựng + Nét viết"),
            ]
            if isParallelStage {
                slots.append(TemplateSlot(title: "Ngữ pháp + Đọc hiểu", category: .grammar, minutes: 15, subtitle: "Buổi tối · Ngữ pháp"))
                slots.append(TemplateSlot(title: "Đọc đoạn văn ngắn", category: .characters, minutes: 15, subtitle: "Buổi tối · Đọc"))
            } else {
                slots.append(TemplateSlot(title: "Ôn Pinyin hoặc Nét viết", category: stage <= 2 ? .pinyin : .characters, minutes: 30, subtitle: "Buổi tối · Ôn tập"))
            }
            return slots
            
        case 5: // Thursday
            var slots: [TemplateSlot] = [
                TemplateSlot(title: "Ôn tập từ vựng (SRS)", category: .review, minutes: 20, subtitle: "Buổi sáng · Ôn tập"),
            ]
            if isParallelStage {
                slots.append(TemplateSlot(title: "Luyện nói + Tự nói chuyện", category: .speaking, minutes: 20, subtitle: "Buổi tối · Luyện nói"))
                slots.append(TemplateSlot(title: "Viết nhật ký tiếng Trung", category: .journal, minutes: 10, subtitle: "Buổi tối · Nhật ký"))
            } else {
                slots.append(TemplateSlot(title: "Luyện nghe cơ bản", category: .listening, minutes: 30, subtitle: "Buổi tối · Nghe"))
            }
            return slots
            
        case 6: // Friday
            var slots: [TemplateSlot] = [
                TemplateSlot(title: "Học từ vựng mới + Nghe", category: .vocabulary, minutes: 20, subtitle: "Buổi sáng · Từ vựng mới"),
            ]
            if isParallelStage {
                slots.append(TemplateSlot(title: "Ôn ngữ pháp + Làm quiz", category: .grammar, minutes: 15, subtitle: "Buổi tối · Quiz"))
                slots.append(TemplateSlot(title: "Nghe và lặp lại", category: .listening, minutes: 15, subtitle: "Buổi tối · Nghe"))
            } else {
                slots.append(TemplateSlot(title: "Tổng ôn tập", category: .review, minutes: 30, subtitle: "Buổi tối · Ôn tập"))
            }
            return slots
            
        case 7: // Saturday
            return [
                TemplateSlot(title: "Tổng ôn tập + Từ yếu", category: .review, minutes: 25, subtitle: "Ngày ôn tập · Review toàn bộ"),
                TemplateSlot(title: "Luyện tập tự do / Nhật ký", category: .journal, minutes: 25, subtitle: "Ngày ôn tập · Tự do")
            ]
            
        case 1: // Sunday — Rest / light review
            return [
                TemplateSlot(title: "Nghỉ ngơi hoặc ôn nhẹ", category: .review, minutes: 15, subtitle: "Chủ nhật · Nhẹ nhàng")
            ]
            
        default:
            return []
        }
    }
    
    /// Generate today's task list.
    ///
    /// - Parameters:
    ///   - context: SwiftData model context
    ///   - progress: Current user progress (for stage, level info)
    ///   - today: The current date (injectable for testing)
    /// - Returns: Array of newly created DailyTask objects (already inserted into context)
    @MainActor
    public static func generateTasks(
        context: ModelContext,
        progress: UserProgress,
        today: Date = Date()
    ) -> [DailyTask] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        
        // Check if tasks already exist for today
        let existingDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date >= startOfToday
            }
        )
        if let existingCount = try? context.fetchCount(existingDescriptor), existingCount > 0 {
            // Tasks already generated for today — return existing
            if let existing = try? context.fetch(existingDescriptor) {
                return existing
            }
            return []
        }
        
        var tasks: [DailyTask] = []
        var sortOrder = 0
        
        // ── 1. Carry-over incomplete tasks from yesterday ──
        let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) ?? startOfToday
        let carryOverDescriptor = FetchDescriptor<DailyTask>(
            predicate: #Predicate<DailyTask> { task in
                task.date >= yesterday && task.date < startOfToday && task.isCompleted == false
            }
        )
        
        if let unfinished = try? context.fetch(carryOverDescriptor) {
            for old in unfinished {
                let carried = DailyTask(
                    date: startOfToday,
                    title: old.title,
                    subtitle: "Bài tập chưa hoàn thành từ hôm qua",
                    category: old.category,
                    minutesEstimated: old.minutesEstimated,
                    isCarryOver: true,
                    sortOrder: sortOrder
                )
                context.insert(carried)
                tasks.append(carried)
                sortOrder += 1
            }
        }
        
        // ── 2. SRS review task ──
        let now = Date()
        let srsDescriptor = FetchDescriptor<HSKWord>(
            predicate: #Predicate<HSKWord> { word in
                word.nextReviewAt != nil && word.nextReviewAt! <= now
            }
        )
        
        let dueCount: Int
        if progress.needsCatchUp {
            // Cap at 30–40 for catch-up mode
            dueCount = min(SRSEngine.catchUpQueueCap, (try? context.fetchCount(srsDescriptor)) ?? 0)
        } else {
            dueCount = (try? context.fetchCount(srsDescriptor)) ?? 0
        }
        
        if dueCount > 0 {
            let reviewMinutes = max(5, min(30, dueCount * 1)) // ~1 min per card, 5–30 range
            let reviewTask = DailyTask(
                date: startOfToday,
                title: "Ôn tập \(dueCount) từ vựng đến hạn",
                subtitle: "Spaced Repetition · \(reviewMinutes) phút",
                category: .review,
                minutesEstimated: reviewMinutes,
                sortOrder: sortOrder
            )
            context.insert(reviewTask)
            tasks.append(reviewTask)
            sortOrder += 1
        }
        
        // ── 3. Weekly template tasks ──
        let weekday = calendar.component(.weekday, from: today)
        let templateSlots = templateSlots(for: weekday, stage: progress.currentStage)
        
        for slot in templateSlots {
            // Skip review template if we already added an SRS task
            if slot.category == .review && dueCount > 0 { continue }
            
            let task = DailyTask(
                date: startOfToday,
                title: slot.title,
                subtitle: slot.subtitle,
                category: slot.category,
                minutesEstimated: slot.minutes,
                sortOrder: sortOrder
            )
            context.insert(task)
            tasks.append(task)
            sortOrder += 1
        }
        
        try? context.save()
        return tasks
    }
}
