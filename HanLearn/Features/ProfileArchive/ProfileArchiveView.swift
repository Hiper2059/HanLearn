//
//  ProfileArchiveView.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Feature: Hồ sơ cá nhân, Thống kê độ phủ HSK & Lịch sử ghi âm lưu trên máy
//

import SwiftUI
import SwiftData

public struct ProfileArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceRecord.recordedAt, order: .reverse) private var voiceRecords: [VoiceRecord]
    @Query private var words: [HSKWord]
    @Query private var userProgressList: [UserProgress]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Thẻ tóm tắt năng lực HSK
                        hskCoverageSection
                        
                        // Sổ tay Spaced Repetition (SRS)
                        srsReviewSection
                        
                        // Lịch sử luyện phát âm đã lưu trên máy
                        voiceHistorySection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Hồ Sơ & Dữ Liệu Cục Bộ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var hskCoverageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(HanTheme.jadeGreen)
                Text("TIẾN ĐỘ BAO PHỦ HSK 3.0")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                hskProgressBar(level: "HSK 1", count: 420, total: 500, percent: 84)
                hskProgressBar(level: "HSK 2", count: 580, total: 1272, percent: 45)
                hskProgressBar(level: "HSK 3", count: 210, total: 2245, percent: 9)
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
        }
    }
    
    private func hskProgressBar(level: String, count: Int, total: Int, percent: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(level)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(count)/\(total) từ (\(percent)%)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(HanTheme.primaryGradient)
                        .frame(width: geo.size.width * CGFloat(percent) / 100.0, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var srsReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(HanTheme.silkGold)
                Text("SỔ TAY TỪ VỰNG CẦN ÔN TẬP (SRS)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(words.count) Từ vựng đã lưu trên máy")
                        .font(.hanBody(size: 16))
                        .bold()
                        .foregroundColor(.white)
                    Text("Thuật toán SM-2 tự động lên lịch nhắc nhở")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {}) {
                    Text("Ôn ngay")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(HanTheme.silkGold)
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
        }
    }
    
    private var voiceHistorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "waveform.badge.mic")
                    .foregroundColor(HanTheme.vermilionRed)
                Text("LỊCH SỬ CHẤM THOẠI TRÊN MÁY (\(voiceRecords.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("100% Private")
                    .font(.system(size: 11))
                    .foregroundColor(HanTheme.jadeGreen)
            }
            
            if voiceRecords.isEmpty {
                Text("Chưa có lượt ghi âm nào được lưu.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
            } else {
                ForEach(voiceRecords.prefix(10)) { record in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.targetHanzi)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Nhận diện: \"\(record.recognizedTranscript)\"")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(record.overallScore) đ")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(record.overallScore >= 80 ? HanTheme.jadeGreen : .orange)
                            Text("Thanh điệu: \(record.toneScore)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(10)
                }
            }
        }
    }
}
