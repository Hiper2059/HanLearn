//
//  VocabQuickAddService.swift
//  HanLearn
//
//  Handles quick-add vocab with duplicate detection, daily cap enforcement,
//  and immediate SRS scheduling. Used by VocabQuickAddSheet and Share Sheet extension.
//

import Foundation
import SwiftData

public enum QuickAddResult {
    case success(HSKWord)
    case duplicateFound(HSKWord)          // Existing word returned for edit/merge
    case overDailyCapWarning(HSKWord)     // Word added but user warned about cap
}

public final class VocabQuickAddService {
    
    /// Check if a word with the same Hanzi already exists
    @MainActor
    public static func findExisting(hanzi: String, context: ModelContext) -> HSKWord? {
        let trimmed = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<HSKWord>(
            predicate: #Predicate<HSKWord> { word in
                word.hanzi == trimmed
            }
        )
        return try? context.fetch(descriptor).first
    }
    
    /// Add a new vocab word with full validation.
    ///
    /// - Returns: `.duplicateFound` if Hanzi already exists,
    ///            `.overDailyCapWarning` if user exceeded 15 words today (word still added),
    ///            `.success` otherwise.
    @MainActor
    public static func addWord(
        hanzi: String,
        pinyin: String,
        vietnameseMeaning: String,
        sinoVietnamese: String = "",
        hskLevel: Int = 1,
        exampleSentenceHanzi: String = "",
        exampleSentencePinyin: String = "",
        exampleSentenceTranslation: String = "",
        photoLocalPath: String? = nil,
        context: ModelContext,
        progress: UserProgress
    ) -> QuickAddResult {
        let trimmedHanzi = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Duplicate check
        if let existing = findExisting(hanzi: trimmedHanzi, context: context) {
            return .duplicateFound(existing)
        }
        
        // 2. Create new word
        let word = HSKWord(
            hanzi: trimmedHanzi,
            pinyin: pinyin.trimmingCharacters(in: .whitespacesAndNewlines),
            sinoVietnamese: sinoVietnamese,
            vietnameseMeaning: vietnameseMeaning.trimmingCharacters(in: .whitespacesAndNewlines),
            hskLevel: hskLevel,
            exampleSentenceHanzi: exampleSentenceHanzi,
            exampleSentencePinyin: exampleSentencePinyin,
            exampleSentenceTranslation: exampleSentenceTranslation,
            photoLocalPath: photoLocalPath,
            isUserAdded: true,
            addedAt: Date()
        )
        
        // nextReviewAt is set to Date() in HSKWord.init — immediately due for review
        
        context.insert(word)
        
        // 3. Update daily counter
        progress.resetDailyCountersIfNeeded()
        progress.newVocabAddedToday += 1
        progress.totalWordsLearned += 1
        
        try? context.save()
        
        // 4. Check daily cap
        if progress.newVocabAddedToday > SRSEngine.maxNewWordsPerDay {
            return .overDailyCapWarning(word)
        }
        
        return .success(word)
    }
}
