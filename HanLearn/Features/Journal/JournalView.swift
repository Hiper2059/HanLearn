//
//  JournalView.swift
//  HanLearn
//
//  Lightweight daily self-talk journal tab.
//  Goal: 5 Chinese sentences per day to build the thinking-in-Chinese habit.
//  Supports voice-to-text input via Speech framework for hands-free journaling.
//

import SwiftUI
import SwiftData
import Speech

public struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    
    @State private var todayText: String = ""
    @State private var isRecording: Bool = false
    @State private var showingPastEntries: Bool = false
    
    // Speech recognition
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var speechPermissionGranted: Bool = false
    
    /// Today's existing entry (if any)
    private var todaysEntry: JournalEntry? {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: startOfToday) }
    }
    
    private var sentenceCount: Int {
        let delimiters = CharacterSet(charactersIn: "。！？.!?\n")
        return todayText.components(separatedBy: delimiters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .count
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // ── Today's Entry ──
                        todaySection
                        
                        // ── Past Entries ──
                        pastEntriesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Nhật ký")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTodaysEntry()
                checkSpeechPermission()
            }
            .onDisappear {
                saveTodaysEntry()
                stopRecording()
            }
        }
    }
    
    // MARK: - Today's Section
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HÔM NAY")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(HanTheme.jadeGreen)
                    Text(formattedToday)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Sentence counter
                HStack(spacing: 4) {
                    Text("\(sentenceCount)/5")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(sentenceCount >= 5 ? HanTheme.jadeGreen : .white)
                    Text("câu")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(sentenceCount >= 5 ? HanTheme.jadeGreen.opacity(0.15) : Color.white.opacity(0.06))
                .cornerRadius(8)
            }
            
            // Prompt/hint
            if todayText.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 36))
                        .foregroundStyle(HanTheme.primaryGradient)
                    Text("Viết 5 câu tiếng Trung mỗi ngày\nđể luyện tư duy bằng tiếng Trung! ✍️")
                        .font(.hanBody(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            
            // Text editor
            ZStack(alignment: .topLeading) {
                if todayText.isEmpty {
                    Text("今天我学了新的词语...\n(Hôm nay tôi đã học từ mới...)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $todayText)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            
            // Action buttons
            HStack(spacing: 12) {
                // Voice input button
                Button(action: toggleVoiceInput) {
                    HStack(spacing: 6) {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        Text(isRecording ? "Dừng" : "Nói tiếng Trung")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isRecording ? HanTheme.vermilionRed : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isRecording ? HanTheme.vermilionRed.opacity(0.15) : Color.white.opacity(0.08))
                    .cornerRadius(10)
                }
                .disabled(!speechPermissionGranted && !isRecording)
                
                Spacer()
                
                // Save button
                Button(action: saveTodaysEntry) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Lưu")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(HanTheme.jadeGreen)
                    .cornerRadius(10)
                }
                .disabled(todayText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    // MARK: - Past Entries
    
    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("NHẬT KÝ TRƯỚC ĐÓ (\(pastEntries.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            if pastEntries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("Chưa có nhật ký nào trước đó")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(pastEntries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formatDate(entry.date))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(HanTheme.silkGold)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("\(entry.sentenceCount) câu")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                
                                if entry.isVoiceInput {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(HanTheme.jadeGreen)
                                }
                            }
                        }
                        
                        Text(entry.content)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(3)
                            .lineSpacing(4)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    /// Past entries (excluding today)
    private var pastEntries: [JournalEntry] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return entries.filter { $0.date < startOfToday }
    }
    
    // MARK: - Helpers
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func loadTodaysEntry() {
        if let existing = todaysEntry {
            todayText = existing.content
        }
    }
    
    private func saveTodaysEntry() {
        let trimmed = todayText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let existing = todaysEntry {
            existing.content = trimmed
            existing.updateSentenceCount()
        } else {
            let entry = JournalEntry(
                content: trimmed,
                isVoiceInput: false
            )
            entry.updateSentenceCount()
            modelContext.insert(entry)
        }
        
        try? modelContext.save()
        HapticManager.shared.buttonTapped()
    }
    
    // MARK: - Voice Input
    
    private func checkSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                speechPermissionGranted = (status == .authorized)
            }
        }
    }
    
    private func toggleVoiceInput() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            recognitionRequest = request
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            
            recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let result = result {
                    let newText = result.bestTranscription.formattedString
                    DispatchQueue.main.async {
                        // Append transcribed text
                        if !todayText.isEmpty && !todayText.hasSuffix("\n") {
                            todayText += "\n"
                        }
                        // Replace only the current transcription segment
                        todayText = todayText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !todayText.isEmpty {
                            todayText += "\n"
                        }
                        todayText += newText
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    DispatchQueue.main.async {
                        stopRecording()
                    }
                }
            }
            
            HapticManager.shared.buttonTapped()
        } catch {
            print("[JournalView] Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
