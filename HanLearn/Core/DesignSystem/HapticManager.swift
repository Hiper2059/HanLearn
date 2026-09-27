//
//  HapticManager.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Design System: Phản hồi xúc giác Haptic Feedback tối ưu trải nghiệm vẽ nét & học tập
//

import UIKit

public final class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    public func strokeCompleted() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func answerCorrect() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    public func answerWrong() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    public func buttonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
