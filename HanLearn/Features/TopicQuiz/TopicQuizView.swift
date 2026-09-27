//
//  TopicQuizView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Luyện tập câu hỏi tự động sinh theo Topic (Trắc nghiệm, Sắp xếp câu, Đối thoại)
//

import SwiftUI
import SwiftData

public struct TopicQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let lesson: HSKLesson
    @State private var currentIndex: Int = 0
    @State private var selectedOption: String? = nil
    @State private var hasSubmitted: Bool = false
    @State private var isAnswerCorrect: Bool = false
    @State private var reorderedTokens: [String] = []
    
    public init(lesson: HSKLesson) {
        self.lesson = lesson
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if lesson.quizzes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.folder")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Chưa có câu hỏi nào cho bài học này.")
                            .foregroundColor(.gray)
                    }
                } else if currentIndex >= lesson.quizzes.count {
                    // Màn hình hoàn thành
                    quizCompletedView
                } else {
                    let currentQuiz = lesson.quizzes[currentIndex]
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Progress Bar
                        ProgressView(value: Double(currentIndex + 1), total: Double(lesson.quizzes.count))
                            .tint(HanTheme.jadeGreen)
                            .padding(.top, 10)
                        
                        // Đề bài
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CÂU \(currentIndex + 1)/\(lesson.quizzes.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(HanTheme.silkGold)
                            
                            Text(currentQuiz.promptText)
                                .font(.hanTitle(size: 20))
                                .foregroundColor(.white)
                            
                            if !currentQuiz.targetHanzi.isEmpty {
                                HStack {
                                    Text(currentQuiz.targetHanzi)
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(HanTheme.jadeGreen)
                                    
                                    Button(action: {
                                        SoundManager.shared.speakMandarin(currentQuiz.targetHanzi)
                                    }) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Nội dung tương tác tùy theo loại câu hỏi
                        if currentQuiz.type == .sentenceReorder {
                            sentenceReorderSection(currentQuiz)
                        } else {
                            multipleChoiceSection(currentQuiz)
                        }
                        
                        Spacer()
                        
                        // Giải thích & Nút Tiếp tục
                        bottomActionSection(currentQuiz)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Luyện tập Quiz HSK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Thoát") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                setupCurrentQuizTokens()
            }
        }
    }
    
    private func multipleChoiceSection(_ quiz: HSKQuiz) -> some View {
        VStack(spacing: 12) {
            ForEach(quiz.optionsData, id: \.self) { option in
                Button(action: {
                    if !hasSubmitted {
                        selectedOption = option
                        HapticManager.shared.buttonTapped()
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.hanBody(size: 16))
                            .foregroundColor(textColor(for: option, quiz: quiz))
                        Spacer()
                        if hasSubmitted && option == quiz.correctAnswer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                        } else if hasSubmitted && selectedOption == option && option != quiz.correctAnswer {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(16)
                    .background(bgColor(for: option, quiz: quiz))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor(for: option, quiz: quiz), lineWidth: 1.5)
                    )
                }
                .disabled(hasSubmitted)
            }
        }
    }
    
    private func sentenceReorderSection(_ quiz: HSKQuiz) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nhấn vào các từ để ghép thành câu:")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // Khay chứa câu đã ghép
            HStack(spacing: 8) {
                if reorderedTokens.isEmpty {
                    Text("Chạm các từ bên dưới...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.6))
                } else {
                    ForEach(reorderedTokens, id: \.self) { token in
                        Text(token)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(HanTheme.silkGold)
                            .cornerRadius(8)
                            .onTapGesture {
                                if !hasSubmitted {
                                    reorderedTokens.removeAll { $0 == token }
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .padding(12)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
            
            // Danh sách các từ có sẵn để chọn
            FlowLayout(spacing: 8) {
                ForEach(quiz.optionsData, id: \.self) { token in
                    let isChosen = reorderedTokens.contains(token)
                    Button(action: {
                        if !hasSubmitted {
                            if isChosen {
                                reorderedTokens.removeAll { $0 == token }
                            } else {
                                reorderedTokens.append(token)
                            }
                            HapticManager.shared.buttonTapped()
                        }
                    }) {
                        Text(token)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isChosen ? .gray.opacity(0.4) : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isChosen ? Color.white.opacity(0.02) : Color.white.opacity(0.12))
                            .cornerRadius(8)
                    }
                    .disabled(isChosen || hasSubmitted)
                }
            }
        }
    }
    
    private func bottomActionSection(_ quiz: HSKQuiz) -> some View {
        VStack(spacing: 12) {
            if hasSubmitted {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(isAnswerCorrect ? HanTheme.jadeGreen : .orange)
                        Text(isAnswerCorrect ? "Chính xác!" : "Chưa chính xác")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isAnswerCorrect ? HanTheme.jadeGreen : .orange)
                    }
                    Text(quiz.explanation)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isAnswerCorrect ? HanTheme.jadeGreen.opacity(0.15) : Color.orange.opacity(0.15))
                .cornerRadius(12)
            }
            
            Button(action: {
                if !hasSubmitted {
                    submitAnswer(quiz)
                } else {
                    nextQuestion()
                }
            }) {
                Text(!hasSubmitted ? "Kiểm tra đáp án" : (currentIndex + 1 < lesson.quizzes.count ? "Câu tiếp theo" : "Xem kết quả"))
                    .font(.hanBody(size: 16))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(!hasSubmitted && selectedOption == nil && reorderedTokens.isEmpty ? Color.gray : HanTheme.jadeGreen)
                    .cornerRadius(12)
            }
            .disabled(!hasSubmitted && selectedOption == nil && reorderedTokens.isEmpty)
        }
    }
    
    private var quizCompletedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 64))
                .foregroundColor(HanTheme.silkGold)
            
            Text("Chúc mừng bạn đã hoàn thành!")
                .font(.hanTitle(size: 22))
                .foregroundColor(.white)
            
            Text("Toàn bộ tiến độ và điểm số đã được tự động lưu vào máy.")
                .font(.hanBody(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { dismiss() }) {
                Text("Quay về bài học")
                    .font(.hanBody(size: 16))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(30)
    }
    
    private func setupCurrentQuizTokens() {
        selectedOption = nil
        hasSubmitted = false
        reorderedTokens.removeAll()
    }
    
    private func submitAnswer(_ quiz: HSKQuiz) {
        hasSubmitted = true
        if quiz.type == .sentenceReorder {
            let assembled = reorderedTokens.joined(separator: " ")
            isAnswerCorrect = assembled == quiz.correctAnswer
        } else {
            isAnswerCorrect = selectedOption == quiz.correctAnswer
        }
        
        if isAnswerCorrect {
            HapticManager.shared.answerCorrect()
        } else {
            HapticManager.shared.answerWrong()
        }
    }
    
    private func nextQuestion() {
        currentIndex += 1
        setupCurrentQuizTokens()
    }
    
    private func textColor(for option: String, quiz: HSKQuiz) -> Color {
        if hasSubmitted {
            if option == quiz.correctAnswer { return HanTheme.jadeGreen }
            if selectedOption == option { return .red }
        }
        return .white
    }
    
    private func bgColor(for option: String, quiz: HSKQuiz) -> Color {
        if hasSubmitted {
            if option == quiz.correctAnswer { return HanTheme.jadeGreen.opacity(0.15) }
            if selectedOption == option { return Color.red.opacity(0.15) }
        }
        return selectedOption == option ? Color.white.opacity(0.15) : Color.white.opacity(0.05)
    }
    
    private func borderColor(for option: String, quiz: HSKQuiz) -> Color {
        if hasSubmitted {
            if option == quiz.correctAnswer { return HanTheme.jadeGreen }
            if selectedOption == option { return .red }
        }
        return selectedOption == option ? HanTheme.jadeGreen : Color.clear
    }
}

// Layout hỗ trợ wrap các thẻ từ vựng
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return CGSize(width: proposal.width ?? 300, height: 120)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += size.height + spacing
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
        }
    }
}
