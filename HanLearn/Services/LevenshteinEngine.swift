//
//  LevenshteinEngine.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Core Algorithm: So khớp chuỗi Levenshtein Distance & Character Diffing cho Auto-Dictation
//  100% Cục bộ (Offline), hiệu năng cực cao O(M*N)
//

import Foundation

public struct DiffCharToken: Identifiable {
    public let id = UUID()
    public enum DiffType {
        case correct
        case wrong(expected: String)
        case missing(expected: String)
        case extra(actual: String)
    }
    public let displayChar: String
    public let type: DiffType
}

public struct LevenshteinResult {
    public let distance: Int
    public let accuracyPercentage: Int      // 0 - 100%
    public let isExactMatch: Bool
    public let tokens: [DiffCharToken]
    public let normalizedInput: String
    public let normalizedTarget: String
}

public struct LevenshteinEngine {
    
    /// Làm sạch chuỗi (loại bỏ dấu câu thừa, khoảng trắng trùng lặp, chuyển chữ hoa/thường)
    public static func normalizeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "，", with: "")
            .replacingOccurrences(of: "。", with: "")
            .replacingOccurrences(of: "！", with: "")
            .replacingOccurrences(of: "？", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "?", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Tính khoảng cách Levenshtein và sinh danh sách ký tự bôi màu
    public static func evaluate(input: String, target: String) -> LevenshteinResult {
        let normInput = normalizeText(input)
        let normTarget = normalizeText(target)
        
        let inputChars = Array(normInput)
        let targetChars = Array(normTarget)
        let m = inputChars.count
        let n = targetChars.count
        
        if m == 0 && n == 0 {
            return LevenshteinResult(
                distance: 0,
                accuracyPercentage: 100,
                isExactMatch: true,
                tokens: [],
                normalizedInput: normInput,
                normalizedTarget: normTarget
            )
        }
        
        if m == 0 {
            let tokens = targetChars.map { DiffCharToken(displayChar: String($0), type: .missing(expected: String($0))) }
            return LevenshteinResult(
                distance: n,
                accuracyPercentage: 0,
                isExactMatch: false,
                tokens: tokens,
                normalizedInput: normInput,
                normalizedTarget: normTarget
            )
        }
        
        if n == 0 {
            let tokens = inputChars.map { DiffCharToken(displayChar: String($0), type: .extra(actual: String($0))) }
            return LevenshteinResult(
                distance: m,
                accuracyPercentage: 0,
                isExactMatch: false,
                tokens: tokens,
                normalizedInput: normInput,
                normalizedTarget: normTarget
            )
        }
        
        // DP Matrix
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                if inputChars[i - 1] == targetChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(
                        dp[i - 1][j] + 1,       // Xóa
                        dp[i][j - 1] + 1,       // Thêm
                        dp[i - 1][j - 1] + 1     // Thay thế
                    )
                }
            }
        }
        
        let distance = dp[m][n]
        let maxLen = max(m, n)
        let accuracy = max(0, Int((Double(maxLen - distance) / Double(maxLen)) * 100))
        let isExact = distance == 0
        
        // Backtracking để sinh danh sách diff tokens
        var tokens: [DiffCharToken] = []
        var i = m
        var j = n
        
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && inputChars[i - 1] == targetChars[j - 1] {
                tokens.append(DiffCharToken(displayChar: String(inputChars[i - 1]), type: .correct))
                i -= 1
                j -= 1
            } else if i > 0 && j > 0 && dp[i][j] == dp[i - 1][j - 1] + 1 {
                tokens.append(DiffCharToken(
                    displayChar: String(inputChars[i - 1]),
                    type: .wrong(expected: String(targetChars[j - 1]))
                ))
                i -= 1
                j -= 1
            } else if j > 0 && dp[i][j] == dp[i][j - 1] + 1 {
                tokens.append(DiffCharToken(
                    displayChar: String(targetChars[j - 1]),
                    type: .missing(expected: String(targetChars[j - 1]))
                ))
                j -= 1
            } else {
                tokens.append(DiffCharToken(
                    displayChar: String(inputChars[i - 1]),
                    type: .extra(actual: String(inputChars[i - 1]))
                ))
                i -= 1
            }
        }
        
        tokens.reverse()
        
        return LevenshteinResult(
            distance: distance,
            accuracyPercentage: accuracy,
            isExactMatch: isExact,
            tokens: tokens,
            normalizedInput: normInput,
            normalizedTarget: normTarget
        )
    }
}
