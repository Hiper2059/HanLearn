//
//  StrokeCanvasView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Tập viết chữ Hán trên ô Mễ Tự Cách (Tianzi Ge) kèm Haptic Feedback
//

import SwiftUI

public struct StrokeCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    public let word: HSKWord
    
    @State private var currentLines: [Line] = []
    @State private var currentStrokeIndex: Int = 0
    @State private var showGhost: Bool = true
    
    public init(word: HSKWord) {
        self.word = word
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header thông tin chữ
                    VStack(spacing: 6) {
                        Text(word.pinyin)
                            .font(.hanPinyin(size: 20))
                            .foregroundColor(HanTheme.silkGold)
                        Text(word.vietnameseMeaning)
                            .font(.hanBody(size: 15))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                    
                    // Ô Mễ Tự Cách (Tianzi Ge Canvas)
                    ZStack {
                        // 1. Grid ô chữ Mễ Tự Cách
                        TianziGridShape()
                            .stroke(Color.red.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                        
                        // 2. Chữ Hán mờ (Ghost character) làm mẫu
                        if showGhost {
                            Text(String(word.hanzi.prefix(1)))
                                .font(.system(size: 220, weight: .light, design: .serif))
                                .foregroundColor(Color.white.opacity(0.12))
                        }
                        
                        // 3. Đường nét người dùng vẽ
                        Canvas { context, size in
                            for line in currentLines {
                                var path = Path()
                                path.addLines(line.points)
                                context.stroke(path, with: .color(HanTheme.silkGold), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    let newPoint = value.location
                                    if currentLines.isEmpty || currentLines.last?.isFinished == true {
                                        currentLines.append(Line(points: [newPoint], lineWidth: 10, isFinished: false))
                                    } else {
                                        currentLines[currentLines.count - 1].points.append(newPoint)
                                    }
                                }
                                .onEnded { _ in
                                    if !currentLines.isEmpty {
                                        currentLines[currentLines.count - 1].isFinished = true
                                        HapticManager.shared.strokeCompleted()
                                    }
                                }
                        )
                    }
                    .frame(width: 300, height: 300)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.6), lineWidth: 2)
                    )
                    
                    // Nút điều khiển
                    HStack(spacing: 16) {
                        Button(action: {
                            showGhost.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showGhost ? "eye.fill" : "eye.slash.fill")
                                Text(showGhost ? "Ẩn nét mờ" : "Hiện nét mờ")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            currentLines.removeAll()
                            HapticManager.shared.buttonTapped()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Xóa viết lại")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            SoundManager.shared.speakMandarin(word.hanzi)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16))
                                .foregroundColor(HanTheme.jadeGreen)
                                .frame(width: 44, height: 44)
                                .background(HanTheme.jadeGreen.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Tập viết nét: \(word.hanzi)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") { dismiss() }
                        .foregroundColor(HanTheme.jadeGreen)
                }
            }
        }
    }
}

// Cấu trúc lưu nét vẽ
struct Line {
    var points: [CGPoint]
    var lineWidth: CGFloat = 10
    var isFinished: Bool = false
}

// Khung ô vuông Mễ Tự Cách (米字格)
struct TianziGridShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Khung ngoài
        path.addRect(rect)
        // Đường ngang giữa
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        // Đường dọc giữa
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // Hai đường chéo tạo thành chữ Mễ (米)
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        return path
    }
}
