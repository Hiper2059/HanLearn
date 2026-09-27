//
//  LessonDetailView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Chi tiết bài học: Học tương tác 3 bước (Học từ -> Nối từ -> Luyện tập), Hội thoại, Từ vựng & Tập viết nét
//

import SwiftUI

public struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    public let lesson: HSKLesson
    
    @State private var selectedWordForStroke: HSKWord?
    @State private var showingVoicePractice: Bool = false
    @State private var showingInteractiveStudy: Bool = false
    
    public init(lesson: HSKLesson) {
        self.lesson = lesson
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header thông tin
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lesson.levelBadge)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(HanTheme.vermilionRed)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            Text(lesson.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(lesson.summary)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // NÚT BẮT ĐẦU HỌC BÀI TƯƠNG TÁC (Dạy từ -> Nối từ)
                        Button(action: {
                            showingInteractiveStudy = true
                            HapticManager.shared.buttonTapped()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                Text("Bắt Đầu Học (Học từ vựng → Nối từ → Nhận thưởng)")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.jadeGreen)
                            .cornerRadius(14)
                            .shadow(color: HanTheme.jadeGreen.opacity(0.4), radius: 8, y: 3)
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // 1. Đoạn hội thoại mẫu
                        dialogueSection
                        
                        // 2. Từ vựng cốt lõi & Tập viết nét
                        vocabularySection
                        
                        // 3. Giải thích ngữ pháp
                        grammarSection
                        
                        // Nút chuyển sang luyện nói câu thoại
                        Button(action: {
                            showingVoicePractice = true
                            HapticManager.shared.buttonTapped()
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Luyện Nói Cả Đoạn Thoại Với AI")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.silkGold)
                            .cornerRadius(14)
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Chi Tiết Bài Học")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
            .sheet(item: $selectedWordForStroke) { word in
                StrokeCanvasView(word: word)
            }
            .sheet(isPresented: $showingVoicePractice) {
                VoiceDialogueView(targetHanzi: lesson.dialogueChinese, targetPinyin: lesson.dialoguePinyin)
            }
            .fullScreenCover(isPresented: $showingInteractiveStudy) {
                InteractiveLessonStudyView(lesson: lesson)
            }
        }
    }
    
    private var dialogueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ĐOẠN HỘI THOẠI MẪU")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(HanTheme.silkGold)
                
                Spacer()
                
                Button(action: {
                    SoundManager.shared.speakMandarin(lesson.dialogueChinese)
                    HapticManager.shared.buttonTapped()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Phát âm")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(HanTheme.silkGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(HanTheme.silkGold.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.dialogueChinese)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                
                Text(lesson.dialoguePinyin)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(HanTheme.silkGold.opacity(0.9))
                    .lineSpacing(4)
                
                Divider().background(Color.white.opacity(0.1))
                
                Text(lesson.dialogueVietnamese)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
        }
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TỪ VỰNG TRỌNG TÂM (\(lesson.vocabularyList.count))")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(HanTheme.jadeGreen)
            
            ForEach(lesson.vocabularyList) { word in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.hanzi)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text(word.pinyin)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(HanTheme.silkGold)
                    }
                    .frame(width: 75, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.vietnameseMeaning)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        if !word.sinoVietnamese.isEmpty {
                            Text("Hán-Việt: \(word.sinoVietnamese)")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Nút phát âm
                    Button(action: {
                        SoundManager.shared.speakMandarin(word.hanzi)
                        HapticManager.shared.buttonTapped()
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 15))
                            .foregroundColor(HanTheme.jadeGreen)
                            .frame(width: 34, height: 34)
                            .background(HanTheme.jadeGreen.opacity(0.15))
                            .cornerRadius(17)
                    }
                    
                    // Nút tập viết nét
                    Button(action: {
                        selectedWordForStroke = word
                        HapticManager.shared.buttonTapped()
                    }) {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.system(size: 15))
                            .foregroundColor(HanTheme.silkGold)
                            .frame(width: 34, height: 34)
                            .background(HanTheme.silkGold.opacity(0.15))
                            .cornerRadius(17)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)
            }
        }
    }
    
    private var grammarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NGỮ PHÁP TRỌNG TÂM")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(HanTheme.vermilionRed)
            
            Text(lesson.grammarExplanation)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .cornerRadius(14)
        }
    }
}
