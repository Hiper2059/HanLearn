//
//  SentenceBuilderEngine.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Core Algorithm: Kiểm tra sắp xếp câu (Sentence Builder) bằng so khớp mảng (Array Matching)
//  Hỗ trợ nhiều biến thể ngữ pháp tương đương (Alternative Valid Structures)
//

import Foundation

public struct SentenceExercise: Identifiable {
    public let id: String
    public let hskLevel: Int
    public let vietnameseMeaning: String
    public let words: [String]                    // Các khối từ xáo trộn ban đầu
    public let validStructures: [[String]]        // Mảng các đáp án đúng được chấp nhận
    public let pinyinComplete: String
    public let grammarPoint: String
    
    public init(
        id: String = UUID().uuidString,
        hskLevel: Int,
        vietnameseMeaning: String,
        words: [String],
        validStructures: [[String]],
        pinyinComplete: String,
        grammarPoint: String
    ) {
        self.id = id
        self.hskLevel = hskLevel
        self.vietnameseMeaning = vietnameseMeaning
        self.words = words
        self.validStructures = validStructures
        self.pinyinComplete = pinyinComplete
        self.grammarPoint = grammarPoint
    }
}

public struct SentenceBuilderEngine {
    
    /// Kiểm tra xem mảng từ học viên xếp có khớp với bất kỳ đáp án đúng nào không
    public static func evaluate(userBlocks: [String], validStructures: [[String]]) -> Bool {
        for valid in validStructures {
            if userBlocks == valid {
                return true
            }
        }
        return false
    }
    
    /// Ngữ liệu mẫu chuẩn HSK 1 - HSK 5
    public static func getSampleExercises(level: Int = 1) -> [SentenceExercise] {
        switch level {
        case 1:
            return [
                SentenceExercise(
                    id: "s1",
                    hskLevel: 1,
                    vietnameseMeaning: "Tôi là giáo viên tiếng Trung.",
                    words: ["我是", "老师", "汉语"],
                    validStructures: [
                        ["我是", "汉语", "老师"]
                    ],
                    pinyinComplete: "Wǒ shì Hànyǔ lǎoshī.",
                    grammarPoint: "Cấu trúc Định ngữ + Danh từ: 汉语 + 老师 (Giáo viên tiếng Trung)"
                ),
                SentenceExercise(
                    id: "s2",
                    hskLevel: 1,
                    vietnameseMeaning: "Hôm nay tôi muốn uống trà.",
                    words: ["喝茶", "我想", "今天"],
                    validStructures: [
                        ["今天", "我想", "喝茶"],
                        ["我想", "今天", "喝茶"]
                    ],
                    pinyinComplete: "Jīntiān wǒ xiǎng hē chá.",
                    grammarPoint: "Trạng từ chỉ thời gian (今天) có thể đứng đầu câu hoặc sau chủ ngữ."
                ),
                SentenceExercise(
                    id: "s3",
                    hskLevel: 1,
                    vietnameseMeaning: "Cô ấy không ở trường học.",
                    words: ["在", "学校", "她", "不"],
                    validStructures: [
                        ["她", "不", "在", "学校"]
                    ],
                    pinyinComplete: "Tā bù zài xuéxiào.",
                    grammarPoint: "Phủ định 不 đứng trước giới từ 在."
                )
            ]
        case 2:
            return [
                SentenceExercise(
                    id: "s4",
                    hskLevel: 2,
                    vietnameseMeaning: "Tôi đến từ 8 giờ sáng.",
                    words: ["到了", "八点", "我", "早上"],
                    validStructures: [
                        ["我", "早上", "八点", "到了"],
                        ["早上", "八点", "我", "到了"]
                    ],
                    pinyinComplete: "Wǒ zǎoshang bā diǎn dào le.",
                    grammarPoint: "Thời gian đứng trước động từ: 早上八点 + 到了."
                ),
                SentenceExercise(
                    id: "s5",
                    hskLevel: 2,
                    vietnameseMeaning: "Bạn chạy bộ nhanh hơn tôi.",
                    words: ["比我", "跑得快", "你"],
                    validStructures: [
                        ["你", "比我", "跑得快"]
                    ],
                    pinyinComplete: "Nǐ bǐ wǒ pǎo de kuài.",
                    grammarPoint: "Câu chữ 比 kết hợp bổ ngữ trình độ: A 比 B + Động từ + 得 + Tính từ."
                )
            ]
        default:
            return [
                SentenceExercise(
                    id: "s6",
                    hskLevel: 3,
                    vietnameseMeaning: "Tôi đã để sách lên bàn rồi.",
                    words: ["放在", "桌子上", "我把书", "了"],
                    validStructures: [
                        ["我把书", "放在", "桌子上", "了"]
                    ],
                    pinyinComplete: "Wǒ bǎ shū fàng zài zhuōzi shang le.",
                    grammarPoint: "Câu chữ 把: Chủ ngữ + 把 + Tân ngữ + Động từ + 在/到/给."
                )
            ]
        }
    }
}
