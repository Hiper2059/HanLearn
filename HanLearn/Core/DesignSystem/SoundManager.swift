//
//  SoundManager.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Design System: Phát âm tiếng Trung chuẩn bản xứ (AVSpeechSynthesizer)
//

import Foundation
import AVFoundation

public final class SoundManager {
    public static let shared = SoundManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
    /// Phát âm chữ Hán hoặc câu thoại bằng giọng Bắc Kinh chuẩn
    public func speakMandarin(_ text: String, slowSpeed: Bool = false) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = slowSpeed ? 0.35 : 0.48 // Tốc độ chuẩn cho người học tiếng Trung
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
