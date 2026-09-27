//
//  DailyTaskRow.swift
//  HanLearn
//
//  Reusable row component for a single daily task item.
//  Supports swipe-to-complete gesture with haptic feedback.
//

import SwiftUI

public struct DailyTaskRow: View {
    @Bindable public var task: DailyTask
    public var onComplete: (() -> Void)?
    public var onTap: (() -> Void)?
    
    @State private var completionScale: CGFloat = 1.0
    
    public var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 14) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: task.category.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(accentColor)
                }
                
                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(task.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(task.isCompleted ? .gray : .white)
                            .strikethrough(task.isCompleted, color: .gray)
                            .lineLimit(2)
                        
                        if task.isCarryOver {
                            Text("từ hôm qua")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    if let subtitle = task.subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Duration badge
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(task.minutesEstimated)p")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.06))
                .cornerRadius(6)
                
                // Completion indicator
                Button(action: {
                    toggleCompletion()
                }) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? HanTheme.jadeGreen : Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 28, height: 28)
                        
                        if task.isCompleted {
                            Circle()
                                .fill(HanTheme.jadeGreen)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .scaleEffect(completionScale)
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(
                task.isCompleted
                    ? Color.white.opacity(0.02)
                    : Color.white.opacity(0.05)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(task.isCarryOver ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                toggleCompletion()
            } label: {
                Label(task.isCompleted ? "Chưa xong" : "Hoàn thành", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark")
            }
            .tint(task.isCompleted ? .orange : HanTheme.jadeGreen)
        }
        .accessibilityLabel("\(task.title), \(task.isCompleted ? "đã hoàn thành" : "chưa hoàn thành"), \(task.minutesEstimated) phút")
        .accessibilityHint(task.isCompleted ? "Nhấn đúp để bỏ đánh dấu" : "Nhấn đúp để đánh dấu hoàn thành")
    }
    
    private var accentColor: Color {
        switch task.category.accentColor {
        case "jadeGreen": return HanTheme.jadeGreen
        case "vermilionRed": return HanTheme.vermilionRed
        case "silkGold": return HanTheme.silkGold
        default: return HanTheme.jadeGreen
        }
    }
    
    private func toggleCompletion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            completionScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                completionScale = 1.0
            }
        }
        
        if task.isCompleted {
            task.markIncomplete()
        } else {
            task.markCompleted()
            HapticManager.shared.answerCorrect()
            onComplete?()
        }
    }
}
