//
//  FlashcardView.swift
//  HanLearn
//
//  Individual SRS flashcard with flip animation, drag gesture for grading,
//  and 3D rotation effect. Front shows Hanzi, back shows meaning + Pinyin.
//

import SwiftUI

public struct FlashcardView: View {
    public let word: HSKWord
    public let onGrade: (SRSGrade) -> Void
    
    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var dragDirection: SRSGrade? = nil
    
    private let dragThreshold: CGFloat = 100
    
    public var body: some View {
        ZStack {
            // Back face (meaning)
            cardBack
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
            
            // Front face (Hanzi)
            cardFront
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
        }
        .offset(x: dragOffset.width, y: dragOffset.height * 0.3)
        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    updateDragDirection()
                }
                .onEnded { value in
                    if abs(value.translation.width) > dragThreshold || value.translation.height < -dragThreshold {
                        commitGrade()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            dragDirection = nil
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
            HapticManager.shared.buttonTapped()
        }
        // Directional grade overlay
        .overlay(gradeOverlay)
        .accessibilityLabel(isFlipped
            ? "\(word.hanzi), \(word.pinyin), nghĩa: \(word.vietnameseMeaning)"
            : "\(word.hanzi), nhấn để lật thẻ"
        )
    }
    
    // MARK: - Card Front
    
    private var cardFront: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(word.hanzi)
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .accessibilityAddTraits(.isHeader)
            
            // TTS play button
            Button(action: {
                SoundManager.shared.speakMandarin(word.hanzi)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Nghe phát âm")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HanTheme.jadeGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(HanTheme.jadeGreen.opacity(0.15))
                .cornerRadius(20)
            }
            
            Spacer()
            
            Text("Nhấn để lật thẻ · Vuốt để chấm điểm")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.6))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(HanTheme.softCardBg)
                .shadow(color: Color.black.opacity(0.3), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Card Back
    
    private var cardBack: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Hanzi (smaller)
            Text(word.hanzi)
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            // Pinyin
            Text(word.pinyin)
                .font(.hanPinyin(size: 22))
                .foregroundColor(HanTheme.silkGold)
            
            // Sino-Vietnamese
            if !word.sinoVietnamese.isEmpty {
                Text("Hán-Việt: \(word.sinoVietnamese)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 30)
            
            // Vietnamese meaning
            Text(word.vietnameseMeaning)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Example sentence
            if !word.exampleSentenceHanzi.isEmpty {
                VStack(spacing: 6) {
                    Text(word.exampleSentenceHanzi)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(word.exampleSentencePinyin)
                        .font(.hanPinyin(size: 12))
                        .foregroundColor(HanTheme.silkGold.opacity(0.7))
                    
                    Text(word.exampleSentenceTranslation)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Grade buttons (visible on back)
            HStack(spacing: 12) {
                gradeButton(grade: .again, color: HanTheme.vermilionRed)
                gradeButton(grade: .hard, color: .orange)
                gradeButton(grade: .good, color: HanTheme.jadeGreen)
                gradeButton(grade: .easy, color: HanTheme.silkGold)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.10, green: 0.12, blue: 0.15))
                .shadow(color: Color.black.opacity(0.3), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func gradeButton(grade: SRSGrade, color: Color) -> some View {
        Button(action: {
            onGrade(grade)
            HapticManager.shared.buttonTapped()
        }) {
            VStack(spacing: 4) {
                Text(grade.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                
                Text(intervalPreview(for: grade))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .cornerRadius(10)
        }
        .accessibilityLabel(grade.accessibilityLabel)
    }
    
    // MARK: - Drag Direction
    
    @ViewBuilder
    private var gradeOverlay: some View {
        if let direction = dragDirection {
            VStack {
                Text(direction.displayName)
                    .font(.hanTitle(size: 28))
                    .foregroundColor(gradeColor(direction))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(gradeColor(direction).opacity(0.2))
                    .cornerRadius(12)
                    .opacity(min(1.0, abs(dragOffset.width) / dragThreshold))
            }
        }
    }
    
    private func updateDragDirection() {
        if dragOffset.width < -50 {
            dragDirection = .again
        } else if dragOffset.width > 50 {
            dragDirection = .good
        } else if dragOffset.height < -50 {
            dragDirection = .easy
        } else {
            dragDirection = nil
        }
    }
    
    private func commitGrade() {
        guard let grade = dragDirection else {
            withAnimation(.spring()) { dragOffset = .zero }
            return
        }
        
        // Animate card off screen
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(
                width: dragOffset.width * 3,
                height: dragOffset.height * 3
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onGrade(grade)
        }
    }
    
    private func gradeColor(_ grade: SRSGrade) -> Color {
        switch grade {
        case .again: return HanTheme.vermilionRed
        case .hard: return .orange
        case .good: return HanTheme.jadeGreen
        case .easy: return HanTheme.silkGold
        }
    }
    
    private func intervalPreview(for grade: SRSGrade) -> String {
        let result = SRSEngine.processReview(
            grade: grade,
            currentRepetitionCount: word.srsRepetitionCount,
            currentIntervalDays: word.srsIntervalDays,
            currentEaseFactor: word.srsEaseFactor,
            currentMastery: word.masteryPercentage
        )
        if result.newInterval == 1 { return "1 ngày" }
        return "\(result.newInterval) ngày"
    }
}
