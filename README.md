# HanLearn iOS (HSK 3.0 Engine) - Kiến Trúc & Hướng Dẫn Vận Hành

Dự án ứng dụng iOS Native học tiếng Trung theo tiêu chuẩn **HSK 3.0 (Cấp 1 - 6)** được xây dựng theo tiêu chuẩn của Senior iOS Architect (10 năm kinh nghiệm):
- **Clean Architecture + MVVM + SwiftData (Local-First)**
- **AI Voice Coach & Tone Pitch Evaluator (AVFoundation + Speech)**
- **Dynamic HSK 3.0 Lesson & Topic Quiz Synthesizer**
- **Tianzi Ge Stroke Order Canvas (Mễ Tự Cách)**
- **Bộ giả lập iOS 18 Simulator chạy trực tiếp trên Windows**

---

## 1. Cấu Trúc Thư Mục Dự Án

```
applearn/
├── HanLearn/                               # Mã nguồn chuẩn iOS Native (Swift 5.9+ / SwiftData)
│   ├── HanLearnApp.swift                   # Entry point, ModelContainer & Seed Data
│   ├── Models/                             # Mô hình dữ liệu SwiftData (@Model)
│   │   ├── HSKLesson.swift                 # Cấu trúc bài học, cấp độ HSK, đoạn hội thoại
│   │   ├── HSKWord.swift                   # Từ vựng, Pinyin, Hán Việt, thuật toán SRS (SM-2)
│   │   ├── HSKQuiz.swift                   # Trắc nghiệm, sắp xếp câu, điền từ, luyện nói
│   │   ├── VoiceRecord.swift               # Lưu điểm phát âm, thanh điệu & file audio cục bộ
│   │   └── UserProgress.swift              # Quản lý chuỗi ngày học Streak & XP
│   ├── Services/                           # Tầng xử lý logic & kết nối
│   │   ├── HSKDiscoveryService.swift       # Tìm kiếm ngữ cảnh & tự động sinh bài giảng HSK 3.0
│   │   ├── AudioVoiceEvaluatorService.swift# Chấm điểm 4 thanh điệu qua AVFoundation & SpeechKit
│   │   └── StrokeOrderEngine.swift         # Giải mã nét viết và thứ tự nét chữ Hán
│   ├── Features/                           # Giao diện SwiftUI theo từng tính năng
│   │   ├── HSKHub/HSKHubView.swift         # Màn hình chính, chọn cấp độ HSK & sinh bài học
│   │   ├── LessonDetail/LessonDetailView.swift # Chi tiết bài học tương tác Pinyin & Từ vựng
│   │   ├── StrokeCanvas/StrokeCanvasView.swift # Tập viết chữ Hán trên ô Mễ Tự Cách (Tianzi Ge)
│   │   ├── TopicQuiz/TopicQuizView.swift   # Làm trắc nghiệm và sắp xếp câu theo topic
│   │   ├── VoiceDialogue/VoiceDialogueView.swift # Luyện nói với AI & chấm phát âm
│   │   └── ProfileArchive/ProfileArchiveView.swift # Thống kê độ phủ HSK & bộ nhớ offline
│   └── Core/DesignSystem/                  # Bảng màu Á Đông hiện đại & Haptic Feedback
│       ├── Theme.swift                     # Bảng màu Jade Green, Vermilion, Silk Gold
│       ├── SoundManager.swift              # Text-to-Speech tiếng Trung chuẩn Bắc Kinh
│       └── HapticManager.swift             # Rung phản hồi khi viết nét & trả lời đúng
│
├── HanLearn/                               # Mã nguồn chuẩn iOS Native (Swift 5.9+ / SwiftData)
│   ├── HanLearnApp.swift                   # Entry point, ModelContainer & Seed Data
│   ├── Info.plist                          # Quyền truy cập mic & nhận diện giọng nói
│   ├── Models/                             # Mô hình dữ liệu SwiftData (@Model)
│   │   ├── HSKLesson.swift                 # Cấu trúc bài học, cấp độ HSK, đoạn hội thoại
│   │   ├── HSKWord.swift                   # Từ vựng, Pinyin, Hán Việt, thuật toán SRS (SM-2)
│   │   ├── HSKQuiz.swift                   # Trắc nghiệm, sắp xếp câu, điền từ, luyện nói
│   │   ├── VoiceRecord.swift               # Lưu điểm phát âm, thanh điệu & file audio cục bộ
│   │   └── UserProgress.swift              # Quản lý chuỗi ngày học Streak & XP
│   ├── Services/                           # Tầng xử lý logic & kết nối
│   │   ├── HSKDiscoveryService.swift       # Tìm kiếm ngữ cảnh & tự động sinh bài giảng HSK 3.0
│   │   ├── AudioVoiceEvaluatorService.swift# Chấm điểm 4 thanh điệu qua AVFoundation & SpeechKit
│   │   ├── DailyTaskGenerator.swift        # Sinh nhiệm vụ học tập hàng ngày
│   │   ├── SRSEngine.swift                 # Thuật toán lặp lại ngắt quãng SM-2
│   │   └── StrokeOrderEngine.swift         # Giải mã nét viết và thứ tự nét chữ Hán
│   ├── Features/                           # Giao diện SwiftUI theo từng tính năng
│   │   ├── HSKHub/HSKHubView.swift         # Màn hình chính, chọn cấp độ HSK & sinh bài học
│   │   ├── LessonDetail/LessonDetailView.swift # Chi tiết bài học tương tác Pinyin & Từ vựng
│   │   ├── StrokeCanvas/StrokeCanvasView.swift # Tập viết chữ Hán trên ô Mễ Tự Cách (Tianzi Ge)
│   │   ├── TopicQuiz/TopicQuizView.swift   # Làm trắc nghiệm và sắp xếp câu theo topic
│   │   ├── VoiceDialogue/VoiceDialogueView.swift # Luyện nói với AI & chấm phát âm
│   │   └── ProfileArchive/ProfileArchiveView.swift # Thống kê độ phủ HSK & bộ nhớ offline
│   └── Core/DesignSystem/                  # Bảng màu Á Đông hiện đại & Sound/Haptic
│
├── HanLearnTests/                          # Bộ Unit Tests chuẩn XCTest
│   ├── SRSEngineTests.swift                # Kiểm thử thuật toán SuperMemo-2 / SRS
│   └── StrokeOrderEngineTests.swift        # Kiểm thử dữ liệu nét viết Hán tự
│
├── .github/workflows/                      # Tự động hóa CI/CD trên GitHub
│   └── ios-test.yml                        # Chạy Swift build & test trên macOS runner của GitHub
├── project.yml                             # Cấu hình tự động sinh Xcode Project (XcodeGen)
└── README.md
```

---

## 2. Cách Test Mã Nguồn Swift Thông Qua GitHub Actions (Không Cần Máy Mac)

Dự án đã được tích hợp sẵn bộ kiểm thử **XCTest** và workflow **GitHub Actions** chạy trên máy chủ ảo macOS (`macos-14`, Apple Silicon M1, Xcode 15+):

1. **Đưa mã nguồn lên GitHub:**
   - Tạo repo mới trên GitHub và tải toàn bộ thư mục dự án lên nhánh `main`.
2. **Tự động kích hoạt Test:**
   - Mỗi khi bạn push code lên GitHub, GitHub Actions trong file `.github/workflows/ios-test.yml` sẽ tự động:
     + Khởi động máy ảo macOS 14 có cài sẵn Xcode.
     + Biên dịch toàn bộ các file Swift trong thư mục `HanLearn/`.
     + Chạy các bài Unit Test trong `HanLearnTests/` (kiểm tra thuật toán SRS, Stroke Engine, ...).
3. **Xem kết quả trên GitHub:**
   - Vào tab **Actions** trên GitHub repository của bạn.
   - Bạn sẽ thấy trạng thái chạy của workflow:
     + 🟢 **Passed:** Tất cả file Swift đều chuẩn cú pháp, biên dịch thành công và vượt qua toàn bộ bài test.
     + 🔴 **Failed:** Nếu có file Swift bị lỗi cú pháp hoặc logic, GitHub sẽ chỉ rõ chính xác file và dòng code bị lỗi trong phần logs.

---

## 3. Cách Mở Dự Án Bằng Xcode (Nếu Có Máy Mac)

Nếu bạn hoặc đồng đội có máy Mac:
1. Cài đặt `xcodegen` (nếu chưa có): `brew install xcodegen`.
2. Tại thư mục dự án, chạy lệnh:
   ```bash
   xcodegen generate
   ```
   Lệnh này sẽ tự động tạo file `HanLearn.xcodeproj` hoàn chỉnh từ file `project.yml`.
3. Mở file `HanLearn.xcodeproj` bằng Xcode, chọn máy ảo iPhone (hoặc iPhone thật) và bấm **Cmd + U** để chạy Unit Test hoặc **Cmd + R** để chạy ứng dụng.

