//
//  VocabQuickAddSheet.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Tính năng Thêm từ vựng thông minh:
//  - Nhập tiếng Việt -> Tự động tìm kiếm Chữ Hán (Cách ghi), Pinyin (Cách nói), Ô Mễ Tự Cách (Cách viết)
//  - Thu âm đọc lại để kiểm tra xem mình phát âm đúng không trước khi lưu
//

import SwiftUI
import SwiftData

public struct VocabQuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgressList: [UserProgress]
    
    // Tìm kiếm bằng tiếng Việt
    @State private var vietnameseSearchText: String = ""
    
    // Dữ liệu từ vựng
    @State private var hanzi: String = ""
    @State private var pinyin: String = ""
    @State private var meaning: String = ""
    @State private var sinoVietnamese: String = ""
    @State private var exampleSentence: String = ""
    @State private var examplePinyin: String = ""
    @State private var exampleTranslation: String = ""
    @State private var selectedLevel: Int = 1
    
    // Kiểm tra phát âm
    @StateObject private var voiceEvaluator = AudioVoiceEvaluatorService.shared
    @State private var voiceFeedback: String? = nil
    
    @State private var showSuccessToast: Bool = false
    
    // Từ điển offline mẫu hỗ trợ tìm kiếm siêu tốc
    public struct PresetVocab: Identifiable {
        public var id: String { hanzi }
        public let vietnamese: String
        public let hanzi: String
        public let pinyin: String
        public let sino: String
        public let level: Int
        public let example: String
        public let examplePy: String
        public let exampleVi: String
    }
    
    private let commonDictionary: [PresetVocab] = [
        // Chào hỏi & Giao tiếp
        PresetVocab(vietnamese: "xin chào", hanzi: "你好", pinyin: "nǐ hǎo", sino: "Nhĩ hảo", level: 1, example: "你好，很高兴认识你！", examplePy: "Nǐ hǎo, hěn gāoxìng rènshi nǐ!", exampleVi: "Xin chào, rất vui được làm quen với bạn!"),
        PresetVocab(vietnamese: "cảm ơn", hanzi: "谢谢", pinyin: "xièxie", sino: "Tạ tạ", level: 1, example: "谢谢你的帮助。", examplePy: "Xièxie nǐ de bāngzhù.", exampleVi: "Cảm ơn sự giúp đỡ của bạn."),
        PresetVocab(vietnamese: "tạm biệt", hanzi: "再见", pinyin: "zàijiàn", sino: "Tái kiến", level: 1, example: "明天再见！", examplePy: "Míngtiān zàijiàn!", exampleVi: "Ngày mai gặp lại!"),
        PresetVocab(vietnamese: "xin lỗi", hanzi: "对不起", pinyin: "duìbuqǐ", sino: "Đối bất khởi", level: 1, example: "对不起，我迟到了。", examplePy: "Duìbuqǐ, wǒ chídào le.", exampleVi: "Xin lỗi, tôi đến muộn rồi."),
        PresetVocab(vietnamese: "không có gì", hanzi: "不客气", pinyin: "bú kèqi", sino: "Bất khách khí", level: 1, example: "不用谢，不客气。", examplePy: "Bú yòng xiè, bú kèqi.", exampleVi: "Không cần cảm ơn, đừng khách sáo."),
        PresetVocab(vietnamese: "không sao", hanzi: "没关系", pinyin: "méi guānxi", sino: "Một quan hệ", level: 1, example: "没关系，别担心。", examplePy: "Méi guānxi, bié dānxīn.", exampleVi: "Không sao đâu, đừng lo lắng."),
        PresetVocab(vietnamese: "xin hỏi", hanzi: "请问", pinyin: "qǐngwèn", sino: "Thỉnh vấn", level: 1, example: "请问，洗手间在哪儿？", examplePy: "Qǐngwèn, xǐshǒujiān zài nǎr?", exampleVi: "Xin hỏi, nhà vệ sinh ở đâu?"),
        
        // Ăn uống
        PresetVocab(vietnamese: "quả táo", hanzi: "苹果", pinyin: "píngguǒ", sino: "Bình quả", level: 1, example: "我想买苹果。", examplePy: "Wǒ xiǎng mǎi píngguǒ.", exampleVi: "Tôi muốn mua táo."),
        PresetVocab(vietnamese: "ăn cơm", hanzi: "吃饭", pinyin: "chī fàn", sino: "Ngật phạn", level: 1, example: "我们去吃饭吧。", examplePy: "Wǒmen qù chī fàn ba.", exampleVi: "Chúng ta đi ăn cơm nhé."),
        PresetVocab(vietnamese: "uống nước", hanzi: "喝水", pinyin: "hē shuǐ", sino: "Hát thủy", level: 1, example: "请喝水。", examplePy: "Qǐng hē shuǐ.", exampleVi: "Xin mời uống nước."),
        PresetVocab(vietnamese: "uống trà", hanzi: "喝茶", pinyin: "hē chá", sino: "Hát trà", level: 1, example: "中国人喜欢喝茶。", examplePy: "Zhōngguó rén xǐhuan hē chá.", exampleVi: "Người Trung Quốc thích uống trà."),
        PresetVocab(vietnamese: "cà phê", hanzi: "咖啡", pinyin: "kāfēi", sino: "Cà phê", level: 1, example: "一杯热咖啡。", examplePy: "Yì bēi rè kāfēi.", exampleVi: "Một ly cà phê nóng."),
        PresetVocab(vietnamese: "mì", hanzi: "面条", pinyin: "miàntiáo", sino: "Diện điều", level: 1, example: "我想吃面条。", examplePy: "Wǒ xiǎng chī miàntiáo.", exampleVi: "Tôi muốn ăn mì."),
        PresetVocab(vietnamese: "bánh bao", hanzi: "包子", pinyin: "bāozi", sino: "Bao tử", level: 2, example: "这个包子很好吃。", examplePy: "Zhège bāozi hěn hǎochī.", exampleVi: "Bánh bao này rất ngon."),
        PresetVocab(vietnamese: "hoa quả", hanzi: "水果", pinyin: "shuǐguǒ", sino: "Thủy quả", level: 1, example: "多吃新鲜水果。", examplePy: "Duō chī xīnxiān shuǐguǒ.", exampleVi: "Ăn nhiều hoa quả tươi."),
        
        // Mua sắm & Tiền bạc
        PresetVocab(vietnamese: "bao nhiêu tiền", hanzi: "多少钱", pinyin: "duōshao qián", sino: "Đa thiểu tiền", level: 1, example: "这个多少钱？", examplePy: "Zhège duōshao qián?", exampleVi: "Cái này bao nhiêu tiền?"),
        PresetVocab(vietnamese: "đắt", hanzi: "贵", pinyin: "guì", sino: "Quý", level: 2, example: "太贵了，便宜一点吧。", examplePy: "Tài guì le, piányi yìdiǎn ba.", exampleVi: "Đắt quá, rẻ một chút đi."),
        PresetVocab(vietnamese: "rẻ", hanzi: "便宜", pinyin: "piányi", sino: "Tiện nghi", level: 2, example: "这件衣服很便宜。", examplePy: "Zhè jiàn yīfu hěn piányi.", exampleVi: "Chiếc áo này rất rẻ."),
        PresetVocab(vietnamese: "quần áo", hanzi: "衣服", pinyin: "yīfu", sino: "Y phục", level: 1, example: "新衣服很漂亮。", examplePy: "Xīn yīfu hěn piàoliang.", exampleVi: "Quần áo mới rất đẹp."),
        PresetVocab(vietnamese: "tiền", hanzi: "钱", pinyin: "qián", sino: "Tiền", level: 1, example: "我给你钱。", examplePy: "Wǒ gěi nǐ qián.", exampleVi: "Tôi đưa tiền cho bạn."),
        PresetVocab(vietnamese: "mua", hanzi: "买", pinyin: "mǎi", sino: "Mãi", level: 1, example: "你想买什么？", examplePy: "Nǐ xiǎng mǎi shénme?", exampleVi: "Bạn muốn mua gì?"),
        
        // Con người & Gia đình
        PresetVocab(vietnamese: "bạn bè", hanzi: "朋友", pinyin: "péngyou", sino: "Bằng hữu", level: 1, example: "他是我的好朋友。", examplePy: "Tā shì wǒ de hǎo péngyou.", exampleVi: "Anh ấy là bạn thân của tôi."),
        PresetVocab(vietnamese: "thầy giáo", hanzi: "老师", pinyin: "lǎoshī", sino: "Lão sư", level: 1, example: "李老师很好。", examplePy: "Lǐ lǎoshī hěn hǎo.", exampleVi: "Thầy Lý rất tốt."),
        PresetVocab(vietnamese: "học sinh", hanzi: "学生", pinyin: "xuésheng", sino: "Học sinh", level: 1, example: "他是中国学生。", examplePy: "Tā shì Zhōngguó xuésheng.", exampleVi: "Anh ấy là học sinh Trung Quốc."),
        PresetVocab(vietnamese: "bác sĩ", hanzi: "医生", pinyin: "yīshēng", sino: "Y sinh", level: 1, example: "我爸爸是医生。", examplePy: "Wǒ bàba shì yīshēng.", exampleVi: "Bố tôi là bác sĩ."),
        PresetVocab(vietnamese: "bố", hanzi: "爸爸", pinyin: "bàba", sino: "Ba ba", level: 1, example: "我爱我爸爸。", examplePy: "Wǒ ài wǒ bàba.", exampleVi: "Tôi yêu bố tôi."),
        PresetVocab(vietnamese: "mẹ", hanzi: "妈妈", pinyin: "māma", sino: "Ma ma", level: 1, example: "妈妈在做饭。", examplePy: "Māma zài zuò fàn.", exampleVi: "Mẹ đang nấu cơm."),
        PresetVocab(vietnamese: "chị gái", hanzi: "姐姐", pinyin: "jiějie", sino: "Tỷ tỷ", level: 1, example: "姐姐比我大两岁。", examplePy: "Jiějie bǐ wǒ dà liǎng suì.", exampleVi: "Chị gái hơn tôi 2 tuổi."),
        PresetVocab(vietnamese: "anh trai", hanzi: "哥哥", pinyin: "gēge", sino: "Ca ca", level: 1, example: "哥哥在上大学。", examplePy: "Gēge zài shàng dàxué.", exampleVi: "Anh trai đang học đại học."),
        PresetVocab(vietnamese: "em gái", hanzi: "妹妹", pinyin: "mèimei", sino: "Muội muội", level: 1, example: "妹妹很可爱。", examplePy: "Mèimei hěn kě'ài.", exampleVi: "Em gái rất đáng yêu."),
        PresetVocab(vietnamese: "em trai", hanzi: "弟弟", pinyin: "dìdi", sino: "Đệ đệ", level: 1, example: "弟弟在看书。", examplePy: "Dìdi zài kànshū.", exampleVi: "Em trai đang đọc sách."),
        
        // Địa điểm & Di chuyển
        PresetVocab(vietnamese: "trường học", hanzi: "学校", pinyin: "xuéxiào", sino: "Học hiệu", level: 1, example: "我在学校看书。", examplePy: "Wǒ zài xuéxiào kànshū.", exampleVi: "Tôi đọc sách ở trường."),
        PresetVocab(vietnamese: "bệnh viện", hanzi: "医院", pinyin: "yīyuàn", sino: "Y viện", level: 1, example: "去医院看病。", examplePy: "Qù yīyuàn kànbìng.", exampleVi: "Đi bệnh viện khám bệnh."),
        PresetVocab(vietnamese: "sân bay", hanzi: "机场", pinyin: "jīchǎng", sino: "Cơ trường", level: 2, example: "在机场接朋友。", examplePy: "Zài jīchǎng jiē péngyou.", exampleVi: "Đón bạn ở sân bay."),
        PresetVocab(vietnamese: "máy bay", hanzi: "飞机", pinyin: "fēijī", sino: "Phi cơ", level: 2, example: "坐飞机去上海。", examplePy: "Zuò fēijī qù Shànghǎi.", exampleVi: "Đi máy bay đến Thượng Hải."),
        PresetVocab(vietnamese: "xe taxi", hanzi: "出租车", pinyin: "chūzūchē", sino: "Xuất tô xa", level: 1, example: "坐出租车去火车站。", examplePy: "Zuò chūzūchē qù huǒchēzhàn.", exampleVi: "Đi taxi đến ga tàu hỏa."),
        PresetVocab(vietnamese: "du lịch", hanzi: "旅游", pinyin: "lǚyóu", sino: "Lữ du", level: 2, example: "我想去北京旅游。", examplePy: "Wǒ xiǎng qù Běijīng lǚyóu.", exampleVi: "Tôi muốn đi du lịch Bắc Kinh."),
        PresetVocab(vietnamese: "nhà", hanzi: "家", pinyin: "jiā", sino: "Gia", level: 1, example: "我家在河内。", examplePy: "Wǒ jiā zài Hénèi.", exampleVi: "Nhà tôi ở Hà Nội."),
        
        // Thời gian & Thời tiết
        PresetVocab(vietnamese: "thời tiết", hanzi: "天气", pinyin: "tiānqì", sino: "Thiên khí", level: 2, example: "今天天气很好。", examplePy: "Jīntiān tiānqì hěn hǎo.", exampleVi: "Thời tiết hôm nay rất đẹp."),
        PresetVocab(vietnamese: "hôm nay", hanzi: "今天", pinyin: "jīntiān", sino: "Kim thiên", level: 1, example: "今天星期天。", examplePy: "Jīntiān xīngqītiān.", exampleVi: "Hôm nay là chủ nhật."),
        PresetVocab(vietnamese: "ngày mai", hanzi: "明天", pinyin: "míngtiān", sino: "Minh thiên", level: 1, example: "明天有考试。", examplePy: "Míngtiān yǒu kǎoshì.", exampleVi: "Ngày mai có bài thi."),
        PresetVocab(vietnamese: "hôm qua", hanzi: "昨天", pinyin: "zuótiān", sino: "Tạc thiên", level: 1, example: "昨天我去了超市。", examplePy: "Zuótiān wǒ qù le chāoshì.", exampleVi: "Hôm qua tôi đã đến siêu thị."),
        PresetVocab(vietnamese: "bây giờ", hanzi: "现在", pinyin: "xiànzài", sino: "Hiện tại", level: 1, example: "现在几点了？", examplePy: "Xiànzài jǐ diǎn le?", exampleVi: "Bây giờ mấy giờ rồi?"),
        PresetVocab(vietnamese: "buổi tối", hanzi: "晚上", pinyin: "wǎnshang", sino: "Vãn thượng", level: 1, example: "晚上好！", examplePy: "Wǎnshang hǎo!", exampleVi: "Chào buổi tối!"),
        PresetVocab(vietnamese: "buổi sáng", hanzi: "早上", pinyin: "zǎoshang", sino: "Tảo thượng", level: 1, example: "早上好！", examplePy: "Zǎoshang hǎo!", exampleVi: "Chào buổi sáng!")
    ]
    
    private var isFormValid: Bool {
        !hanzi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !pinyin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // 1. Ô TÌM KIẾM BẰNG TIẾNG VIỆT
                        vietnameseSearchSection
                        
                        // 2. KẾT QUẢ TÌM THẤY & PREVIEW CÁCH GHI, CÁCH VIẾT, CÁCH NÓI
                        if !hanzi.isEmpty {
                            foundWordCard
                        }
                        
                        // 3. CHI TIẾT TỪ VỰNG CÓ THỂ ĐIỀU CHỈNH
                        manualFormSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Thêm Từ Vựng Mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Lưu Từ") {
                        saveWord()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isFormValid ? HanTheme.jadeGreen : .gray)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    @Query private var allExistingWords: [HSKWord]
    @State private var searchResults: [PresetVocab] = []
    @State private var showingStrokeTest: Bool = false
    
    // MARK: - 1. Ô Tìm Kiếm Bằng Tiếng Việt
    private var vietnameseSearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NHẬP TIẾNG VIỆT ĐỂ TỰ ĐỘNG TÌM KIẾM CÁCH GHI, VIẾT & NÓI:")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(HanTheme.silkGold)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Nhập: quả táo, xin chào, bạn bè, ăn cơm, uống nước...", text: $vietnameseSearchText)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .onChange(of: vietnameseSearchText) { _, query in
                        searchFromVietnamese(query)
                    }
                
                if !vietnameseSearchText.isEmpty {
                    Button(action: {
                        vietnameseSearchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.08))
            .cornerRadius(14)
            
            // Danh sách gợi ý tìm thấy (Results pills)
            if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Từ gợi ý phù hợp:")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(searchResults) { item in
                                Button(action: {
                                    selectVocab(item)
                                }) {
                                    HStack(spacing: 4) {
                                        Text(item.hanzi)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(hanzi == item.hanzi ? .black : HanTheme.jadeGreen)
                                        Text("(\(item.vietnamese))")
                                            .font(.system(size: 11))
                                            .foregroundColor(hanzi == item.hanzi ? .black.opacity(0.8) : .white.opacity(0.6))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(hanzi == item.hanzi ? HanTheme.jadeGreen : Color.white.opacity(0.08))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 2)
            } else {
                // Gợi ý từ khóa nhanh
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Quả táo", "Xin chào", "Cảm ơn", "Ăn cơm", "Uống nước", "Bao nhiêu tiền", "Học sinh", "Bác sĩ", "Trường học"], id: \.self) { item in
                            Button(action: {
                                vietnameseSearchText = item
                                searchFromVietnamese(item)
                            }) {
                                Text(item)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - 2. Thẻ hiển thị từ vựng tìm thấy (Cách ghi, cách viết, cách nói & Check đọc)
    private var foundWordCard: some View {
        VStack(spacing: 14) {
            // Header: Cách ghi, Cách nói & Cách viết
            HStack(spacing: 14) {
                // Ô Mễ Tự Cách (Cách viết)
                VStack(spacing: 4) {
                    TianziGeView(
                        character: hanzi,
                        size: 90,
                        showGrid: true,
                        gridColor: Color.red.opacity(0.4),
                        textColor: .white
                    )
                    Text("Cách viết")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cách ghi:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            Text(hanzi)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cách nói:")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(HanTheme.silkGold)
                            Text(pinyin)
                                .font(.system(size: 17, weight: .bold, design: .monospaced))
                                .foregroundColor(HanTheme.silkGold)
                        }
                        
                        // Nút Nghe mẫu chuẩn
                        Button(action: {
                            SoundManager.shared.speakMandarin(hanzi)
                            HapticManager.shared.buttonTapped()
                        }) {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(HanTheme.jadeGreen)
                                .font(.system(size: 18))
                                .padding(10)
                                .background(HanTheme.jadeGreen.opacity(0.18))
                                .clipShape(Circle())
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.vertical, 2)
                    
                    Text("Nghĩa tiếng Việt: \(meaning)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HanTheme.jadeGreen)
                    
                    if !sinoVietnamese.isEmpty {
                        Text("Âm Hán-Việt: \(sinoVietnamese)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // CỤM LUYỆN ĐỌC & CHECK PHÁT ÂM
            VStack(spacing: 10) {
                HStack {
                    Text("ĐỌC THỬ ĐỂ CHECK PHÁT ÂM CỦA BẠN:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    if voiceEvaluator.isRecording {
                        HStack(spacing: 3) {
                            ForEach(0..<4, id: \.self) { idx in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(HanTheme.vermilionRed)
                                    .frame(width: 4, height: 12 + CGFloat(voiceEvaluator.audioLevel * 18 * Float(idx + 1) / 3))
                            }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    // Nút thu âm nói
                    Button(action: toggleVoiceCheck) {
                        HStack(spacing: 6) {
                            Image(systemName: voiceEvaluator.isRecording ? "stop.fill" : "mic.fill")
                            Text(voiceEvaluator.isRecording ? "Dừng Thu & Chấm Điểm" : "Đọc Thử Để Check")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(voiceEvaluator.isRecording ? HanTheme.vermilionRed : Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Nút nghe lại giọng vừa nói
                    if voiceEvaluator.hasRecordedAudio {
                        Button(action: {
                            voiceEvaluator.playRecordedVoice()
                            HapticManager.shared.buttonTapped()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: voiceEvaluator.isPlayingBack ? "pause.circle.fill" : "play.circle.fill")
                                Text(voiceEvaluator.isPlayingBack ? "Đang phát..." : "Nghe Lại Giọng Tôi")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(HanTheme.silkGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(HanTheme.silkGold.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                }
                
                if let fb = voiceFeedback {
                    Text(fb)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(HanTheme.silkGold)
                        .padding(.top, 2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.11, green: 0.13, blue: 0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(HanTheme.jadeGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 3. Biểu Mẫu Chi Tiết
    private var manualFormSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CHI TIẾT TỪ VỰNG")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            inputRow(label: "Chữ Hán (Cách ghi):", text: $hanzi, placeholder: "苹果")
            inputRow(label: "Pinyin (Cách nói):", text: $pinyin, placeholder: "píngguǒ")
            inputRow(label: "Nghĩa tiếng Việt:", text: $meaning, placeholder: "Quả táo")
            inputRow(label: "Âm Hán-Việt:", text: $sinoVietnamese, placeholder: "Bình quả")
            inputRow(label: "Câu ví dụ:", text: $exampleSentence, placeholder: "我想买苹果。")
            inputRow(label: "Dịch ví dụ:", text: $exampleTranslation, placeholder: "Tôi muốn mua táo.")
            
            // Chọn cấp độ HSK
            HStack {
                Text("Cấp độ:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Picker("HSK", selection: $selectedLevel) {
                    ForEach(1...6, id: \.self) { lvl in
                        Text("HSK \(lvl)").tag(lvl)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
    
    private func inputRow(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
        }
    }
    
    // MARK: - LOGIC TÌM KIẾM & XỬ LÝ
    private func stripDiacritics(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
    
    private func searchFromVietnamese(_ query: String) {
        let cleanQuery = stripDiacritics(query.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !cleanQuery.isEmpty else {
            searchResults = []
            return
        }
        
        var matches: [PresetVocab] = []
        
        // 1. Tìm trong từ điển Preset phong phú
        for item in commonDictionary {
            let stripped = stripDiacritics(item.vietnamese)
            if stripped.contains(cleanQuery) || cleanQuery.contains(stripped) {
                matches.append(item)
            }
        }
        
        // 2. Tìm trong SHZCurriculumDatabase
        for w in SHZCurriculumDatabase.allWordsList {
            let stripped = stripDiacritics(w.vietnameseMeaning)
            if stripped.contains(cleanQuery) || cleanQuery.contains(stripped) {
                if !matches.contains(where: { $0.hanzi == w.hanzi }) {
                    matches.append(PresetVocab(
                        vietnamese: w.vietnameseMeaning,
                        hanzi: w.hanzi,
                        pinyin: w.pinyin,
                        sino: w.sinoVietnamese,
                        level: 1,
                        example: w.exampleHanzi,
                        examplePy: w.examplePinyin,
                        exampleVi: w.exampleTranslation
                    ))
                }
            }
        }
        
        // 3. Tìm trong SwiftData
        for w in allExistingWords {
            let stripped = stripDiacritics(w.vietnameseMeaning)
            if stripped.contains(cleanQuery) || cleanQuery.contains(stripped) {
                if !matches.contains(where: { $0.hanzi == w.hanzi }) {
                    matches.append(PresetVocab(
                        vietnamese: w.vietnameseMeaning,
                        hanzi: w.hanzi,
                        pinyin: w.pinyin,
                        sino: w.sinoVietnamese,
                        level: w.hskLevel,
                        example: w.exampleSentenceHanzi,
                        examplePy: w.exampleSentencePinyin,
                        exampleVi: w.exampleSentenceTranslation
                    ))
                }
            }
        }
        
        searchResults = matches
        if let first = matches.first {
            selectVocab(first)
        }
    }
    
    private func selectVocab(_ item: PresetVocab) {
        hanzi = item.hanzi
        pinyin = item.pinyin
        meaning = item.vietnamese
        sinoVietnamese = item.sino
        selectedLevel = item.level
        exampleSentence = item.example
        examplePinyin = item.examplePy
        exampleTranslation = item.exampleVi
        voiceFeedback = nil
        HapticManager.shared.answerCorrect()
    }
    
    private func toggleVoiceCheck() {
        guard !hanzi.isEmpty else { return }
        if voiceEvaluator.isRecording {
            let res = voiceEvaluator.stopRecordingAndEvaluate(targetHanzi: hanzi, targetPinyin: pinyin)
            voiceFeedback = "Điểm: \(res.overallScore)/100 · \(res.feedbackMessage)"
            HapticManager.shared.answerCorrect()
        } else {
            voiceFeedback = "Đang lắng nghe... Hãy phát âm to rõ: \(hanzi) (\(pinyin))"
            Task {
                let granted = await voiceEvaluator.requestPermissions()
                if granted {
                    try? voiceEvaluator.startRecording(targetHanzi: hanzi)
                    HapticManager.shared.buttonTapped()
                } else {
                    voiceFeedback = "Vui lòng cấp quyền Micro trong Cài đặt iPhone"
                }
            }
        }
    }
    
    private func saveWord() {
        let cleanHanzi = hanzi.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanHanzi.isEmpty else { return }
        
        let newWord = HSKWord(
            hanzi: cleanHanzi,
            pinyin: pinyin.trimmingCharacters(in: .whitespacesAndNewlines),
            sinoVietnamese: sinoVietnamese.trimmingCharacters(in: .whitespacesAndNewlines),
            vietnameseMeaning: meaning.trimmingCharacters(in: .whitespacesAndNewlines),
            hskLevel: selectedLevel,
            exampleSentenceHanzi: exampleSentence,
            exampleSentencePinyin: examplePinyin,
            exampleSentenceTranslation: exampleTranslation,
            isUserAdded: true
        )
        
        // Đưa ngay vào chu kỳ ôn tập hôm nay
        newWord.nextReviewAt = Date()
        modelContext.insert(newWord)
        
        if let prog = userProgressList.first {
            prog.totalWordsLearned += 1
            prog.newVocabAddedToday += 1
            prog.totalXP += 10
            prog.recordDailyActivity()
        }
        
        try? modelContext.save()
        HapticManager.shared.answerCorrect()
        dismiss()
    }
}
