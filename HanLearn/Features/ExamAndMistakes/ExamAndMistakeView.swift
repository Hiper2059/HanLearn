//
//  ExamAndMistakeView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Epic 4: Luyện Thi Thực Chiến (Mock Tests & Analytics) & Sổ Tay Lỗi Sai (Mistake Book)
//  - Thư viện đề thi chuẩn HSK 1 - HSK 5 có Auto-Grader cục bộ
//  - Sổ tay lỗi sai: Tự động gom câu sai, ép luyện lại đến khi đạt >= 80% đúng
//

import SwiftUI
import SwiftData

public struct ExamAndMistakeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserMistake.createdAt, order: .reverse) private var allMistakes: [UserMistake]
    @Query private var userProgressList: [UserProgress]
    
    @State private var selectedSegment: ViewSegment = .mistakeBook
    @State private var activeExam: MockExamDefinition? = nil
    @State private var isRePracticing: Bool = false
    
    public enum ViewSegment: String, CaseIterable {
        case mistakeBook = "Sổ Tay Lỗi Sai"
        case mockExams = "Thi Thử HSK"
    }
    
    private var unresolvedMistakes: [UserMistake] {
        allMistakes.filter { !$0.isResolved }
    }
    
    private var resolvedMistakes: [UserMistake] {
        allMistakes.filter { $0.isResolved }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control Apple Glassmorphism
                    segmentSelectorBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    if selectedSegment == .mistakeBook {
                        mistakeBookView
                    } else {
                        mockExamsView
                    }
                }
            }
            .navigationTitle("Khảo Thí & Sổ Lỗi")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $activeExam) { exam in
                MockExamSessionView(exam: exam)
            }
            .sheet(isPresented: $isRePracticing) {
                MistakeRePracticeSheet(mistakes: unresolvedMistakes)
            }
        }
    }
    
    // MARK: - Segment Control
    private var segmentSelectorBar: some View {
        HStack(spacing: 6) {
            ForEach(ViewSegment.allCases, id: \.self) { segment in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedSegment = segment
                    }
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: segment == .mistakeBook ? "bookmark.fill" : "graduationcap.fill")
                            .font(.system(size: 14))
                        Text(segment.rawValue)
                            .font(.system(size: 14, weight: selectedSegment == segment ? .bold : .medium))
                    }
                    .foregroundColor(selectedSegment == segment ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if selectedSegment == segment {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(segment == .mistakeBook ? HanTheme.vermilionRed : HanTheme.jadeGreen)
                                    .shadow(color: (segment == .mistakeBook ? HanTheme.vermilionRed : HanTheme.jadeGreen).opacity(0.4), radius: 8, y: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.06))
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - SỔ TAY LỖI SAI (MISTAKE BOOK)
    private var mistakeBookView: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Thẻ tổng quan lỗi sai
                VStack(spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SỔ TAY KHOANH VÙNG ĐIỂM YẾU")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(HanTheme.vermilionRed)
                            Text("\(unresolvedMistakes.count) câu cần khắc phục")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Nút Luyện lại ngay
                        if !unresolvedMistakes.isEmpty {
                            Button(action: {
                                isRePracticing = true
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Luyện Lại")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(HanTheme.vermilionRed)
                                .cornerRadius(20)
                                .shadow(color: HanTheme.vermilionRed.opacity(0.5), radius: 6, y: 2)
                            }
                        }
                    }
                    
                    // Thanh tỷ lệ khắc phục
                    let total = max(1, allMistakes.count)
                    let resolvedPercent = Int(Double(resolvedMistakes.count) / Double(total) * 100)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Đã khắc phục: \(resolvedMistakes.count)/\(allMistakes.count)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("\(resolvedPercent)% mục tiêu 80%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(resolvedPercent >= 80 ? HanTheme.jadeGreen : HanTheme.silkGold)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(HanTheme.jadeGreen)
                                    .frame(width: geo.size.width * CGFloat(resolvedPercent) / 100.0, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.12, green: 0.14, blue: 0.19))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(HanTheme.vermilionRed.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Danh sách các lỗi sai
                if allMistakes.isEmpty {
                    emptyMistakesPlaceholder
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(allMistakes) { mistake in
                            MistakeRowView(mistake: mistake)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
    }
    
    private var emptyMistakesPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 56))
                .foregroundColor(HanTheme.jadeGreen)
                .padding(.top, 40)
            
            Text("Không có lỗi sai nào!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Khi bạn làm bài tập ở 'Máy Tự Check' hoặc 'Thi Thử HSK',\nmọi câu trả lời sai sẽ tự động được gom về đây\nđể giúp bạn ôn tập đến khi thành thạo.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - THƯ VIỆN ĐỀ THI TĨNH HSK 1 - HSK 5
    private var mockExamsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header giới thiệu
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("THƯ VIỆN ĐỀ THI CHUẨN QUỐC TẾ")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(HanTheme.silkGold)
                        Text("Mô phỏng đề thi thật HSK 1 - 5")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "timer")
                        .font(.system(size: 24))
                        .foregroundColor(HanTheme.silkGold)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                )
                
                // Danh sách đề thi từ HSK 1 đến HSK 5
                ForEach(MockExamDefinition.sampleExams) { exam in
                    MockExamCardView(exam: exam) {
                        activeExam = exam
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - MISTAKE ROW COMPONENT
struct MistakeRowView: View {
    @Environment(\.modelContext) private var modelContext
    let mistake: UserMistake
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Tag loại bài
                Text(tagForType(mistake.questionType))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(6)
                
                Text("HSK \(mistake.hskLevel)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                // Trạng thái đạt 80%
                if mistake.isResolved {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Đã khắc phục")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HanTheme.jadeGreen)
                } else {
                    Text("Đúng: \(mistake.correctCount)/\(mistake.attemptCount) (\(mistake.accuracyPercentage)%)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(mistake.accuracyPercentage >= 50 ? .orange : HanTheme.vermilionRed)
                }
            }
            
            // Câu hỏi
            Text(mistake.promptText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            // Đáp án bạn đã nhập vs Đáp án chuẩn
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Đã nhập:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(HanTheme.vermilionRed.opacity(0.9))
                    Text(mistake.userAnswer.isEmpty ? "(Chưa trả lời)" : mistake.userAnswer)
                        .font(.system(size: 13))
                        .foregroundColor(HanTheme.vermilionRed)
                }
                
                HStack(spacing: 6) {
                    Text("Đáp án đúng:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(HanTheme.jadeGreen)
                    Text(mistake.targetAnswer)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
            
            if !mistake.explanation.isEmpty {
                Text("Giải thích: \(mistake.explanation)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.10, green: 0.12, blue: 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(mistake.isResolved ? HanTheme.jadeGreen.opacity(0.3) : HanTheme.vermilionRed.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func tagForType(_ type: String) -> String {
        switch type {
        case "dictation": return "Nghe chép"
        case "sentence_builder": return "Xếp câu"
        case "mock_test": return "Thi thử"
        default: return "Trắc nghiệm"
        }
    }
}

// MARK: - MOCK EXAM CARD
struct MockExamCardView: View {
    let exam: MockExamDefinition
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(exam.levelColor)
                        .frame(width: 10, height: 10)
                    Text("HSK \(exam.hskLevel)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(exam.levelColor.opacity(0.2))
                .cornerRadius(10)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(exam.durationMinutes) Phút")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            }
            
            Text(exam.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            
            Text(exam.descriptionText)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
            
            // Các phần thi
            HStack(spacing: 8) {
                ForEach(exam.sections, id: \.self) { section in
                    Text(section)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(HanTheme.jadeGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HanTheme.jadeGreen.opacity(0.12))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.buttonTapped()
                    onStart()
                }) {
                    HStack(spacing: 6) {
                        Text("Vào Thi")
                        Image(systemName: "play.fill")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.10, green: 0.12, blue: 0.17))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - MOCK EXAM DEFINITION & DATA
public struct MockExamDefinition: Identifiable {
    public let id: String
    public let hskLevel: Int
    public let title: String
    public let durationMinutes: Int
    public let descriptionText: String
    public let sections: [String]
    public let questions: [ExamQuestion]
    
    public var levelColor: Color {
        switch hskLevel {
        case 1: return HanTheme.jadeGreen
        case 2: return Color.blue
        case 3: return HanTheme.silkGold
        case 4: return Color.purple
        default: return HanTheme.vermilionRed
        }
    }
    
    public static let sampleExams: [MockExamDefinition] = [
        MockExamDefinition(
            id: "hsk1_01",
            hskLevel: 1,
            title: "Đề Thi Thử Chuẩn HSK 1 - Mã H10123",
            durationMinutes: 35,
            descriptionText: "Đề thi chuẩn hóa gồm Phần Nghe hiểu và Phần Đọc hiểu, có Pinyin đi kèm.",
            sections: ["Nghe 20 câu", "Đọc 20 câu"],
            questions: [
                ExamQuestion(
                    type: .multipleChoice,
                    section: "Đọc hiểu",
                    prompt: "Chọn từ đúng với nghĩa 'Quả táo':",
                    options: ["苹果 (píngguǒ)", "飞机 (fēijī)", "学校 (xuéxiào)", "老师 (lǎoshī)"],
                    correctAnswer: "苹果 (píngguǒ)",
                    explanation: "苹果 có nghĩa là quả táo."
                ),
                ExamQuestion(
                    type: .multipleChoice,
                    section: "Đọc hiểu",
                    prompt: "'他去学校' nghĩa là gì?",
                    options: ["Anh ấy đi trường học", "Anh ấy đi bệnh viện", "Anh ấy đi mua sắm", "Anh ấy về nhà"],
                    correctAnswer: "Anh ấy đi trường học",
                    explanation: "他 (Anh ấy) 去 (đi) 学校 (trường học)."
                ),
                ExamQuestion(
                    type: .fillBlank,
                    section: "Đọc hiểu",
                    prompt: "Điền từ thích hợp: 我想 ____ 水。(Tôi muốn uống nước)",
                    options: ["喝", "吃", "买", "看"],
                    correctAnswer: "喝",
                    explanation: "喝水 nghĩa là uống nước."
                )
            ]
        ),
        MockExamDefinition(
            id: "hsk2_01",
            hskLevel: 2,
            title: "Đề Thi Thử Chuẩn HSK 2 - Mã H20245",
            durationMinutes: 50,
            descriptionText: "Mở rộng 300 từ vựng cơ bản, mẫu câu so sánh, câu hỏi nguyên nhân.",
            sections: ["Nghe 35 câu", "Đọc 25 câu"],
            questions: [
                ExamQuestion(
                    type: .multipleChoice,
                    section: "Đọc hiểu",
                    prompt: "Chọn từ đồng nghĩa với 'Giá cả phải chăng, rẻ':",
                    options: ["便宜 (piányi)", "贵 (guì)", "大 (dà)", "远 (yuǎn)"],
                    correctAnswer: "便宜 (piányi)",
                    explanation: "便宜 là rẻ, ngược lại với 贵 (đắt)."
                ),
                ExamQuestion(
                    type: .fillBlank,
                    section: "Đọc hiểu",
                    prompt: "Điền liên từ: ____ 外面下雨，____ 我们不去了。(Vì trời mưa nên chúng tôi không đi nữa)",
                    options: ["因为...所以...", "虽然...但是...", "不仅...而且...", "如果...就..."],
                    correctAnswer: "因为...所以...",
                    explanation: "Cấu trúc chỉ nguyên nhân - kết quả: 因为... 所以..."
                )
            ]
        ),
        MockExamDefinition(
            id: "hsk3_01",
            hskLevel: 3,
            title: "Đề Thi Thử Chuẩn HSK 3 - Mã H30312",
            durationMinutes: 85,
            descriptionText: "Bước vào giai đoạn không còn Pinyin, kiểm tra năng lực viết chữ Hán và xếp câu.",
            sections: ["Nghe 40 câu", "Đọc 30 câu", "Viết 10 câu"],
            questions: [
                ExamQuestion(
                    type: .sentenceCorrection,
                    section: "Viết",
                    prompt: "Tìm vị trí sai trong câu: '他 (A) 已经 (B) 去 (C) 了 北京 (D)。'",
                    options: ["A", "B", "C", "Câu không sai"],
                    correctAnswer: "Câu không sai",
                    explanation: "Cấu trúc 已经...了 đã hoàn thành chính xác."
                ),
                ExamQuestion(
                    type: .fillBlank,
                    section: "Viết",
                    prompt: "Điền chữ Hán vào chỗ trống: 明天我们要参加汉语 ____ 试 (shì)。",
                    options: ["考", "可", "好", "口"],
                    correctAnswer: "考",
                    explanation: "考试 (kǎoshì) nghĩa là kỳ thi."
                )
            ]
        ),
        MockExamDefinition(
            id: "hsk4_01",
            hskLevel: 4,
            title: "Đề Thi Thử Chuẩn HSK 4 - Mã H40401",
            durationMinutes: 100,
            descriptionText: "Đánh giá khả năng thảo luận trôi chảy các chủ đề đời sống, công sở và ngữ pháp câu chữ 把, 被.",
            sections: ["Nghe 45 câu", "Đọc 40 câu", "Viết 15 câu"],
            questions: [
                ExamQuestion(
                    type: .multipleChoice,
                    section: "Đọc hiểu",
                    prompt: "Điền vào chỗ trống câu chữ 把: 请你把门 ____。",
                    options: ["关上", "关", "在关", "正在关"],
                    correctAnswer: "关上",
                    explanation: "Sau câu chữ 把 động từ cần mang thành phần bổ ngữ chỉ kết quả như 上."
                )
            ]
        ),
        MockExamDefinition(
            id: "hsk5_01",
            hskLevel: 5,
            title: "Đề Thi Thử Chuẩn HSK 5 - Mã H50599 (Auto-Grader)",
            durationMinutes: 120,
            descriptionText: "Phần Viết thiết kế đặc biệt thành dạng Điền từ khóa & Sửa câu để Máy Tự Chấm điểm chính xác 100%!",
            sections: ["Nghe 45 câu", "Đọc 45 câu", "Viết Tự Check 10 câu"],
            questions: [
                ExamQuestion(
                    type: .fillBlank,
                    section: "Viết Tự Check",
                    prompt: "Điền thành ngữ thích hợp: 他做事情总是 ____，非常认真。(Làm việc tận tâm, có trách nhiệm)",
                    options: ["一丝不苟", "马马虎虎", "七上八下", "乱七八糟"],
                    correctAnswer: "一丝不苟",
                    explanation: "一丝不苟 miêu tả sự tỉ mỉ, cẩn thận tuyệt đối."
                ),
                ExamQuestion(
                    type: .sentenceCorrection,
                    section: "Viết Tự Check",
                    prompt: "Sửa lỗi dùng từ: 经过大家的努力，终于 (A) 取得了 (B) 很大 (C) 的 胜利 (D)。",
                    options: ["A", "B", "C", "D (Câu chuẩn ngữ pháp)"],
                    correctAnswer: "D (Câu chuẩn ngữ pháp)",
                    explanation: "Câu diễn đạt hoàn toàn tự nhiên và chuẩn văn phong học thuật."
                )
            ]
        )
    ]
}

public struct ExamQuestion: Identifiable {
    public let id: UUID = UUID()
    public let type: QuestionType
    public let section: String
    public let prompt: String
    public let options: [String]
    public let correctAnswer: String
    public let explanation: String
    
    public enum QuestionType {
        case multipleChoice
        case fillBlank
        case sentenceCorrection
    }
}

// MARK: - MOCK EXAM SESSION (ACTIVE TEST RUNNER)
struct MockExamSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let exam: MockExamDefinition
    
    @State private var timeRemaining: Int
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedAnswers: [Int: String] = [:]
    @State private var isFinished: Bool = false
    @State private var timerActive: Bool = true
    
    init(exam: MockExamDefinition) {
        self.exam = exam
        _timeRemaining = State(initialValue: exam.durationMinutes * 60)
    }
    
    private var currentQuestion: ExamQuestion {
        exam.questions[min(currentQuestionIndex, exam.questions.count - 1)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                if isFinished {
                    examResultView
                } else {
                    activeExamBody
                }
            }
            .navigationTitle(exam.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Thoát") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text(formatTimer(timeRemaining))
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(timeRemaining < 300 ? HanTheme.vermilionRed : HanTheme.silkGold)
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard timerActive && !isFinished else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    finishExam()
                }
            }
        }
    }
    
    private var activeExamBody: some View {
        VStack(spacing: 16) {
            // Thanh tiến độ câu hỏi
            VStack(spacing: 6) {
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(exam.questions.count))
                    .tint(HanTheme.jadeGreen)
                
                HStack {
                    Text("Câu \(currentQuestionIndex + 1) / \(exam.questions.count) · Phần: \(currentQuestion.section)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("Đã làm: \(selectedAnswers.count)/\(exam.questions.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .padding(.horizontal, 16)
            
            // Nội dung câu hỏi
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(currentQuestion.prompt)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                        .cornerRadius(16)
                    
                    // Danh sách các lựa chọn
                    VStack(spacing: 10) {
                        ForEach(currentQuestion.options, id: \.self) { option in
                            Button(action: {
                                selectedAnswers[currentQuestionIndex] = option
                                HapticManager.shared.buttonTapped()
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    if selectedAnswers[currentQuestionIndex] == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(HanTheme.jadeGreen)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedAnswers[currentQuestionIndex] == option ? HanTheme.jadeGreen.opacity(0.15) : Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedAnswers[currentQuestionIndex] == option ? HanTheme.jadeGreen : Color.clear, lineWidth: 1.5)
                                        )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Nút Điều hướng
            HStack(spacing: 12) {
                if currentQuestionIndex > 0 {
                    Button(action: {
                        currentQuestionIndex -= 1
                    }) {
                        Text("Câu Trước")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                    }
                }
                
                if currentQuestionIndex < exam.questions.count - 1 {
                    Button(action: {
                        currentQuestionIndex += 1
                    }) {
                        Text("Câu Tiếp")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.jadeGreen)
                            .cornerRadius(14)
                    }
                } else {
                    Button(action: {
                        finishExam()
                    }) {
                        Text("Nộp Bài & Chấm Điểm")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.vermilionRed)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // Báo cáo kết quả chấm điểm Auto-Grader
    private var examResultView: some View {
        let score = calculateScore()
        let isPassed = score.correctCount >= Int(Double(exam.questions.count) * 0.6)
        
        return ScrollView {
            VStack(spacing: 20) {
                Image(systemName: isPassed ? "trophy.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(isPassed ? HanTheme.silkGold : HanTheme.vermilionRed)
                    .padding(.top, 20)
                
                Text(isPassed ? "CHÚC MỪNG BẠN ĐÃ ĐỖ!" : "CẦN CỐ GẮNG THÊM")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                // Điểm số
                VStack(spacing: 8) {
                    Text("\(score.totalPoints) / 300 Điểm")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(isPassed ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                    
                    Text("Đúng \(score.correctCount) / \(exam.questions.count) câu (\(score.percent)%)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.12, green: 0.14, blue: 0.19))
                .cornerRadius(18)
                .padding(.horizontal, 16)
                
                Text("Tất cả các câu trả lời sai đã tự động được lưu vào Sổ tay lỗi sai để bạn luyện tập lại.")
                    .font(.system(size: 13))
                    .foregroundColor(HanTheme.silkGold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Hoàn Thành")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HanTheme.jadeGreen)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
        }
    }
    
    private func finishExam() {
        timerActive = false
        isFinished = true
        
        // Auto-save mistakes into UserMistake
        for (index, question) in exam.questions.enumerated() {
            let userAns = selectedAnswers[index] ?? ""
            if userAns != question.correctAnswer {
                let mistake = UserMistake(
                    questionType: "mock_test",
                    hskLevel: exam.hskLevel,
                    promptText: question.prompt,
                    targetAnswer: question.correctAnswer,
                    userAnswer: userAns,
                    explanation: question.explanation
                )
                modelContext.insert(mistake)
            }
        }
        try? modelContext.save()
    }
    
    private func calculateScore() -> (correctCount: Int, totalPoints: Int, percent: Int) {
        var correct = 0
        for (index, question) in exam.questions.enumerated() {
            if selectedAnswers[index] == question.correctAnswer {
                correct += 1
            }
        }
        let percent = exam.questions.isEmpty ? 0 : Int((Double(correct) / Double(exam.questions.count)) * 100)
        let points = Int((Double(correct) / Double(max(1, exam.questions.count))) * 300)
        return (correct, points, percent)
    }
    
    private func formatTimer(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - MISTAKE RE-PRACTICE SHEET
struct MistakeRePracticeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let mistakes: [UserMistake]
    
    @State private var currentIndex: Int = 0
    @State private var answerInput: String = ""
    @State private var isChecked: Bool = false
    @State private var isCorrect: Bool = false
    
    private var currentMistake: UserMistake? {
        guard currentIndex < mistakes.count else { return nil }
        return mistakes[currentIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.08, blue: 0.11).ignoresSafeArea()
                
                if let mistake = currentMistake {
                    VStack(spacing: 20) {
                        Text("CÂU HỎI LỖI SAI (\(currentIndex + 1)/\(mistakes.count))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(HanTheme.vermilionRed)
                        
                        Text(mistake.promptText)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        
                        TextField("Nhập đáp án chuẩn xác...", text: $answerInput)
                            .font(.system(size: 17))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .disabled(isChecked)
                        
                        if isChecked {
                            VStack(spacing: 8) {
                                Text(isCorrect ? "Chính xác! Đã tích lũy độ nhớ." : "Chưa chính xác.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isCorrect ? HanTheme.jadeGreen : HanTheme.vermilionRed)
                                Text("Đáp án đúng: \(mistake.targetAnswer)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(isCorrect ? HanTheme.jadeGreen.opacity(0.12) : HanTheme.vermilionRed.opacity(0.12))
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        if !isChecked {
                            Button(action: {
                                checkAnswer()
                            }) {
                                Text("Kiểm Tra")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(HanTheme.jadeGreen)
                                    .cornerRadius(14)
                            }
                        } else {
                            Button(action: {
                                advanceNext()
                            }) {
                                Text(currentIndex + 1 < mistakes.count ? "Câu Tiếp Theo" : "Hoàn Thành Ôn Lỗi")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(HanTheme.silkGold)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding(20)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(HanTheme.jadeGreen)
                        Text("Đã ôn tập xong toàn bộ lỗi sai!")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Button("Đóng") {
                            dismiss()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(HanTheme.jadeGreen)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("Luyện Lại Sổ Lỗi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    private func checkAnswer() {
        guard let mistake = currentMistake else { return }
        let cleanInput = answerInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanTarget = mistake.targetAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        isCorrect = (cleanInput == cleanTarget)
        mistake.recordAttempt(isCorrect: isCorrect)
        isChecked = true
        
        if isCorrect {
            HapticManager.shared.answerCorrect()
        } else {
            HapticManager.shared.answerWrong()
        }
    }
    
    private func advanceNext() {
        if currentIndex + 1 < mistakes.count {
            currentIndex += 1
            answerInput = ""
            isChecked = false
            isCorrect = false
        } else {
            dismiss()
        }
    }
}
