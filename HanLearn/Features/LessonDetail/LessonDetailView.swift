//
//  LessonDetailView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Chi tiết bài học tương tác Pinyin, Từ vựng, Ngữ pháp & Tập viết nét
//

import SwiftUI

public struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    public let lesson: HSKLesson
    
    @State private var selectedWordForStroke: HSKWord?
    @State private var showingVoicePractice: Bool = false
    
    public init(lesson: HSKLesson) {
        self.lesson = lesson
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lesson.levelBadge)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(HanTheme.vermilionRed)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            Text(lesson.title)
                                .font(.hanTitle(size: 22))
                                .foregroundColor(.white)
                            
                            Text(lesson.summary)
                                .font(.hanBody(size: 14))
                                .foregroundColor(.gray)
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
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Luyện Nói Câu Thoại Này Với AI")
                            }
                            .font(.hanBody(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HanTheme.silkGold)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Nội dung bài học")
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
        }
    }
    
    private var dialogueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ĐOẠN HỘI THOẠI MẪU")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HanTheme.jadeGreen)
                Spacer()
                Button(action: {
                    SoundManager.shared.speakMandarin(lesson.dialogueChinese)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.3.fill")
                        Text("Nghe toàn bài")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HanTheme.jadeGreen)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(lesson.dialogueChinese)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineSpacing(6)
                
                Text(lesson.dialoguePinyin)
                    .font(.hanPinyin(size: 13))
                    .foregroundColor(HanTheme.silkGold.opacity(0.9))
                    .lineSpacing(4)
                
                Divider().background(Color.white.opacity(0.1))
                
                Text(lesson.dialogueVietnamese)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .cornerRadius(14)
        }
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TỪ VỰNG TRỌNG TÂM (\(lesson.vocabularyList.count))")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HanTheme.jadeGreen)
            
            ForEach(lesson.vocabularyList) { word in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.hanzi)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(word.pinyin)
                            .font(.hanPinyin(size: 13))
                            .foregroundColor(HanTheme.silkGold)
                    }
                    .frame(width: 80, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.vietnameseMeaning)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Âm Hán-Việt: \(word.sinoVietnamese)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Nút nghe phát âm
                    Button(action: {
                        SoundManager.shared.speakMandarin(word.hanzi)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(HanTheme.jadeGreen)
                            .frame(width: 36, height: 36)
                            .background(HanTheme.jadeGreen.opacity(0.15))
                            .cornerRadius(18)
                    }
                    
                    // Nút tập viết nét
                    Button(action: {
                        selectedWordForStroke = word
                    }) {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.system(size: 16))
                            .foregroundColor(HanTheme.silkGold)
                            .frame(width: 36, height: 36)
                            .background(HanTheme.silkGold.opacity(0.15))
                            .cornerRadius(18)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)
            }
        }
    }
    
    private var grammarSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ĐIỂM NGỮ PHÁP CỐT LÕI")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(HanTheme.jadeGreen)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.grammarExplanation)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(5)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .cornerRadius(14)
        }
    }
}
