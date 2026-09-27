//
//  VocabQuickAddSheet.swift
//  HanLearn
//
//  Modal sheet for quick-adding a new vocabulary word.
//  Features: duplicate detection, daily cap warning, immediate SRS scheduling.
//

import SwiftUI
import SwiftData

public struct VocabQuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    @State private var hanzi: String = ""
    @State private var pinyin: String = ""
    @State private var meaning: String = ""
    @State private var sinoVietnamese: String = ""
    @State private var exampleSentence: String = ""
    @State private var examplePinyin: String = ""
    @State private var exampleTranslation: String = ""
    @State private var selectedLevel: Int = 1
    
    @State private var showDuplicateAlert: Bool = false
    @State private var duplicateWord: HSKWord? = nil
    @State private var showCapWarning: Bool = false
    @State private var showSuccessToast: Bool = false
    @State private var isSaving: Bool = false
    
    private var progress: UserProgress {
        userProgressList.first ?? UserProgress()
    }
    
    private var isFormValid: Bool {
        !hanzi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !pinyin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Thêm từ vựng mới")
                                .font(.hanTitle(size: 22))
                                .foregroundColor(.white)
                            Text("Từ mới sẽ được tự động đưa vào hàng đợi ôn tập SRS")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        // Daily counter
                        if progress.newVocabAddedToday > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: progress.newVocabAddedToday > SRSEngine.maxNewWordsPerDay
                                      ? "exclamationmark.triangle.fill"
                                      : "info.circle.fill")
                                    .foregroundColor(progress.newVocabAddedToday > SRSEngine.maxNewWordsPerDay ? .orange : .gray)
                                Text("Đã thêm \(progress.newVocabAddedToday)/\(SRSEngine.recommendedNewWordsPerDay) từ hôm nay")
                                    .font(.system(size: 12))
                                    .foregroundColor(progress.newVocabAddedToday > SRSEngine.maxNewWordsPerDay ? .orange : .gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(8)
                        }
                        
                        // Required fields
                        VStack(spacing: 14) {
                            inputField(title: "Chữ Hán *", placeholder: "苹果", text: $hanzi, icon: "character")
                                .onChange(of: hanzi) { _, newValue in
                                    checkForDuplicate(newValue)
                                }
                            inputField(title: "Pinyin *", placeholder: "píngguǒ", text: $pinyin, icon: "textformat.abc")
                            inputField(title: "Nghĩa tiếng Việt *", placeholder: "Quả táo", text: $meaning, icon: "globe.asia.australia")
                        }
                        
                        // Optional fields
                        VStack(alignment: .leading, spacing: 14) {
                            Text("THÔNG TIN BỔ SUNG (Tùy chọn)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            inputField(title: "Âm Hán-Việt", placeholder: "Bình quả", text: $sinoVietnamese, icon: "character.book.closed")
                            inputField(title: "Câu ví dụ (Hán)", placeholder: "我想买苹果。", text: $exampleSentence, icon: "text.quote")
                            inputField(title: "Câu ví dụ (Pinyin)", placeholder: "Wǒ xiǎng mǎi píngguǒ.", text: $examplePinyin, icon: "textformat")
                            inputField(title: "Câu ví dụ (Việt)", placeholder: "Tôi muốn mua táo.", text: $exampleTranslation, icon: "globe")
                        }
                        
                        // HSK Level selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CẤP ĐỘ HSK")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 10) {
                                ForEach(1...4, id: \.self) { level in
                                    Button(action: { selectedLevel = level }) {
                                        Text("HSK \(level)")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(selectedLevel == level ? .black : .gray)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedLevel == level ? HanTheme.jadeGreen : Color.white.opacity(0.06))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Save button
                        Button(action: saveWord) {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Thêm vào bộ từ vựng")
                                }
                            }
                            .font(.hanBody(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isFormValid ? HanTheme.jadeGreen : Color.gray.opacity(0.3))
                            .cornerRadius(14)
                        }
                        .disabled(!isFormValid || isSaving)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .alert("Từ này đã tồn tại", isPresented: $showDuplicateAlert) {
                Button("Chỉnh sửa từ có sẵn") {
                    // Could navigate to edit — for now just dismiss
                    dismiss()
                }
                Button("Thêm mới dù vậy", role: .destructive) {
                    forceAdd()
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                if let word = duplicateWord {
                    Text("Từ '\(word.hanzi)' (\(word.pinyin)) — \(word.vietnameseMeaning) đã có trong bộ từ vựng. Bạn muốn chỉnh sửa từ có sẵn?")
                }
            }
            .alert("Cảnh báo quá tải", isPresented: $showCapWarning) {
                Button("Hiểu rồi", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Bạn đã thêm \(progress.newVocabAddedToday) từ hôm nay. Lộ trình khuyên bạn chỉ nên học 10–15 từ/ngày để nhớ lâu. Từ mới đã được lưu.")
            }
            .overlay {
                if showSuccessToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                            Text("Đã thêm thành công!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.15, green: 0.2, blue: 0.18))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Components
    
    private func inputField(title: String, placeholder: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(placeholder, text: text)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
            }
            .padding(12)
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Actions
    
    private func checkForDuplicate(_ hanzi: String) {
        let trimmed = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        duplicateWord = VocabQuickAddService.findExisting(hanzi: trimmed, context: modelContext)
    }
    
    private func saveWord() {
        isSaving = true
        
        // Check for duplicate before saving
        if let existing = duplicateWord {
            _ = existing // Used in alert
            showDuplicateAlert = true
            isSaving = false
            return
        }
        
        performAdd()
    }
    
    private func forceAdd() {
        // Create word directly, bypassing duplicate check
        let word = HSKWord(
            hanzi: hanzi.trimmingCharacters(in: .whitespacesAndNewlines),
            pinyin: pinyin.trimmingCharacters(in: .whitespacesAndNewlines),
            sinoVietnamese: sinoVietnamese,
            vietnameseMeaning: meaning.trimmingCharacters(in: .whitespacesAndNewlines),
            hskLevel: selectedLevel,
            exampleSentenceHanzi: exampleSentence,
            exampleSentencePinyin: examplePinyin,
            exampleSentenceTranslation: exampleTranslation,
            isUserAdded: true,
            addedAt: Date()
        )
        modelContext.insert(word)
        progress.newVocabAddedToday += 1
        progress.totalWordsLearned += 1
        try? modelContext.save()
        
        HapticManager.shared.answerCorrect()
        dismiss()
    }
    
    private func performAdd() {
        let result = VocabQuickAddService.addWord(
            hanzi: hanzi,
            pinyin: pinyin,
            vietnameseMeaning: meaning,
            sinoVietnamese: sinoVietnamese,
            hskLevel: selectedLevel,
            exampleSentenceHanzi: exampleSentence,
            exampleSentencePinyin: examplePinyin,
            exampleSentenceTranslation: exampleTranslation,
            context: modelContext,
            progress: progress
        )
        
        isSaving = false
        
        switch result {
        case .success:
            HapticManager.shared.answerCorrect()
            showSuccessToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                dismiss()
            }
            
        case .duplicateFound(let word):
            duplicateWord = word
            showDuplicateAlert = true
            
        case .overDailyCapWarning:
            HapticManager.shared.answerCorrect()
            showCapWarning = true
        }
    }
}
