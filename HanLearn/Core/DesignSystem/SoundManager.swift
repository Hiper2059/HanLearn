//
//  SoundManager.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Design System: Phát âm tiếng Trung chuẩn bản xứ (AVSpeechSynthesizer)
//  Hỗ trợ phát âm kể cả khi gạt công tắc im lặng (Silent/Mute Mode) qua AVAudioSession .playback
//

import Foundation
import AVFoundation

public final class SoundManager {
    public static let shared = SoundManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Không thể cấu hình AVAudioSession .playAndRecord: \(error)")
        }
    }
    
    /// Phát âm chữ Hán hoặc câu thoại bằng giọng Bắc Kinh chuẩn
    public func speakMandarin(_ text: String, slowSpeed: Bool = false) {
        // Luôn kích hoạt audio session trước khi phát âm
        configureAudioSession()
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        // Tìm giọng tiếng Trung phổ thông zh-CN hoặc zh-TW
        if let voice = AVSpeechSynthesisVoice(language: "zh-CN") {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "zh-TW") {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "zh-HK") {
            utterance.voice = voice
        }
        
        utterance.rate = slowSpeed ? 0.35 : 0.48 // Tốc độ chuẩn cho người học
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
