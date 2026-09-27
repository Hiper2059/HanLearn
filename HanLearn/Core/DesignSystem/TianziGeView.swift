//
//  TianziGeView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Design Component: Ô Mễ Tự Cách (Tianzi Ge / 米字格) chuẩn truyền thống kết hợp Apple Glassmorphism
//

import SwiftUI

public struct TianziGeView: View {
    public let character: String
    public let size: CGFloat
    public let showGrid: Bool
    public let gridColor: Color
    public let textColor: Color
    
    public init(
        character: String,
        size: CGFloat = 200,
        showGrid: Bool = true,
        gridColor: Color = Color.red.opacity(0.35),
        textColor: Color = .white
    ) {
        self.character = character
        self.size = size
        self.showGrid = showGrid
        self.gridColor = gridColor
        self.textColor = textColor
    }
    
    public var body: some View {
        ZStack {
            // Nền Ô Mễ Tự Cách
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.10, green: 0.12, blue: 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(gridColor, lineWidth: 2)
                )
            
            if showGrid {
                // Đường kẻ Mễ Tự Cách (Ngang, Dọc, 2 Đường Chéo nét đứt)
                GeometryReader { geo in
                    Path { path in
                        let w = geo.size.width
                        let h = geo.size.height
                        
                        // Đường ngang giữa
                        path.move(to: CGPoint(x: 0, y: h / 2))
                        path.addLine(to: CGPoint(x: w, y: h / 2))
                        
                        // Đường dọc giữa
                        path.move(to: CGPoint(x: w / 2, y: 0))
                        path.addLine(to: CGPoint(x: w / 2, y: h))
                        
                        // Đường chéo 1: góc trên trái -> góc dưới phải
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: w, y: h))
                        
                        // Đường chéo 2: góc trên phải -> góc dưới trái
                        path.move(to: CGPoint(x: w, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: h))
                    }
                    .stroke(
                        gridColor,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                }
            }
            
            // 4 Góc triện thư pháp cổ truyền
            cornerAccents
            
            // Chữ Hán Thư Pháp ở trung tâm
            Text(character)
                .font(.system(size: size * 0.58, weight: .bold, design: .serif))
                .foregroundColor(textColor)
                .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
                .minimumScaleFactor(0.3)
        }
        .frame(width: size, height: size)
    }
    
    private var cornerAccents: some View {
        ZStack {
            // Góc trên trái
            VStack {
                HStack {
                    CornerBracket()
                        .stroke(gridColor.opacity(0.8), lineWidth: 2)
                        .frame(width: 14, height: 14)
                    Spacer()
                    CornerBracket()
                        .stroke(gridColor.opacity(0.8), lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    CornerBracket()
                        .stroke(gridColor.opacity(0.8), lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(-90))
                    Spacer()
                    CornerBracket()
                        .stroke(gridColor.opacity(0.8), lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(180))
                }
            }
            .padding(6)
        }
    }
}

private struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
