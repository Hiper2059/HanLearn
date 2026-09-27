//
//  SHZCurriculumDatabase.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Lộ trình học HSK 3.0 chuẩn SHZ: Hội Thông Hán Ngữ (会通汉语) & Phát Triển Hán Ngữ (发展汉语)
//  72 tiết/khóa chuẩn quốc tế - HSK 1 đến HSK 5 Đầy Đủ
//

import Foundation

public struct SHZCourseData {
    public let level: Int
    public let courseName: String
    public let textbook: String
    public let totalLessons: String
    public let vocabTarget: String
    public let grammarPointsCount: Int
    public let lessons: [SHZLessonData]
}

public struct SHZLessonData: Identifiable {
    public let id: String
    public let lessonNumber: Int
    public let title: String
    public let topic: String
    public let summary: String
    public let grammarExplanation: String
    public let dialogueChinese: String
    public let dialoguePinyin: String
    public let dialogueVietnamese: String
    public let vocabulary: [SHZWordData]
}

public struct SHZWordData: Identifiable {
    public var id: String { hanzi }
    public let hanzi: String
    public let pinyin: String
    public let sinoVietnamese: String
    public let vietnameseMeaning: String
    public let exampleHanzi: String
    public let examplePinyin: String
    public let exampleTranslation: String
    public let strokeCount: Int
}

public struct SHZCurriculumDatabase {
    
    public static let allCourses: [SHZCourseData] = [
        // MARK: - HSK 1: 会通汉语 · 应用汉语 1 (Bài 1 -> Bài 6)
        SHZCourseData(
            level: 1,
            courseName: "Khóa học HSK 1",
            textbook: "会通汉语 · 应用汉语 1",
            totalLessons: "Bài 1 → Bài 6 · 72 tiết",
            vocabTarget: "Khoảng 300 từ vựng nền tảng",
            grammarPointsCount: 128,
            lessons: [
                SHZLessonData(
                    id: "hsk1_b1",
                    lessonNumber: 1,
                    title: "Bài 1: 他叫什么名字？ (Anh ấy tên là gì?)",
                    topic: "Chào hỏi, Tên, Quốc tịch & Giới thiệu",
                    summary: "Làm quen với cách chào hỏi chuẩn mực, hỏi tên tuổi, quốc tịch và đại từ nhân xưng cơ bản.",
                    grammarExplanation: "1. Câu phán đoán chữ 是: 'Chủ ngữ + 是 + Tân ngữ'. Ví dụ: 我是学生 (Tôi là học sinh).\n2. Đại từ nghi vấn 什么 (Cái gì): Đặt sau động từ. Ví dụ: 你叫什么名字？(Bạn tên là gì?).\n3. Trợ từ nghi vấn 吗: Đặt ở cuối câu để tạo câu hỏi Có... không. Ví dụ: 你是中国人吗？",
                    dialogueChinese: "你好！我叫李明。请问你叫什么名字？\n你好，李明！我叫王芳。\n你是哪国人？\n我是越南人，我在学习汉语。你是老师吗？\n不是，我也是学生。认识你很高兴！\n认识你我也很高兴！",
                    dialoguePinyin: "Nǐ hǎo! Wǒ jiào Lǐ Míng. Qǐngwèn nǐ jiào shénme míngzi?\nNǐ hǎo, Lǐ Míng! Wǒ jiào Wáng Fāng.\nNǐ shì nǎ guó rén?\nWǒ shì Yuènán rén, wǒ zài xuéxí Hànyǔ. Nǐ shì lǎoshī ma?\nBú shì, wǒ yě shì xuésheng. Rènshi nǐ hěn gāoxìng!\nRènshi nǐ wǒ yě hěn gāoxìng!",
                    dialogueVietnamese: "Xin chào! Tôi tên là Lý Minh. Xin hỏi bạn tên là gì?\nChào Lý Minh! Tôi tên là Vương Phương.\nBạn là người nước nào?\nTôi là người Việt Nam, tôi đang học tiếng Trung. Bạn là giáo viên à?\nKhông phải, tôi cũng là học sinh. Rất vui được quen biết bạn!\nQuen biết bạn tôi cũng rất vui!",
                    vocabulary: [
                        SHZWordData(hanzi: "你", pinyin: "nǐ", sinoVietnamese: "Nhĩ", vietnameseMeaning: "Bạn, anh, chị (ngôi thứ 2)", exampleHanzi: "你好！", examplePinyin: "Nǐ hǎo!", exampleTranslation: "Chào bạn!", strokeCount: 7),
                        SHZWordData(hanzi: "好", pinyin: "hǎo", sinoVietnamese: "Hảo", vietnameseMeaning: "Tốt, đẹp, khỏe", exampleHanzi: "他很好。", examplePinyin: "Tā hěn hǎo.", exampleTranslation: "Anh ấy rất tốt.", strokeCount: 6),
                        SHZWordData(hanzi: "叫", pinyin: "jiào", sinoVietnamese: "Khiếu", vietnameseMeaning: "Tên là, gọi là", exampleHanzi: "我叫李明。", examplePinyin: "Wǒ jiào Lǐ Míng.", exampleTranslation: "Tôi tên là Lý Minh.", strokeCount: 5),
                        SHZWordData(hanzi: "什么", pinyin: "shénme", sinoVietnamese: "Thập ma", vietnameseMeaning: "Cái gì, gì", exampleHanzi: "这是什么？", examplePinyin: "Zhè shì shénme?", exampleTranslation: "Đây là cái gì?", strokeCount: 7),
                        SHZWordData(hanzi: "名字", pinyin: "míngzi", sinoVietnamese: "Danh tự", vietnameseMeaning: "Tên, danh tính", exampleHanzi: "你的名字很好听。", examplePinyin: "Nǐ de míngzi hěn hǎotīng.", exampleTranslation: "Tên của bạn rất hay.", strokeCount: 12),
                        SHZWordData(hanzi: "是", pinyin: "shì", sinoVietnamese: "Thị", vietnameseMeaning: "Là, đúng, phải", exampleHanzi: "我是学生。", examplePinyin: "Wǒ shì xuésheng.", exampleTranslation: "Tôi là học sinh.", strokeCount: 9),
                        SHZWordData(hanzi: "人", pinyin: "rén", sinoVietnamese: "Nhân", vietnameseMeaning: "Người", exampleHanzi: "他是中国人。", examplePinyin: "Tā shì Zhōngguó rén.", exampleTranslation: "Anh ấy là người Trung Quốc.", strokeCount: 2),
                        SHZWordData(hanzi: "我", pinyin: "wǒ", sinoVietnamese: "Ngã", vietnameseMeaning: "Tôi, ta (ngôi thứ nhất)", exampleHanzi: "我爱你。", examplePinyin: "Wǒ ài nǐ.", exampleTranslation: "Tôi yêu bạn.", strokeCount: 7),
                        SHZWordData(hanzi: "老师", pinyin: "lǎoshī", sinoVietnamese: "Lão sư", vietnameseMeaning: "Thầy giáo, cô giáo", exampleHanzi: "李老师在学校。", examplePinyin: "Lǐ lǎoshī zài xuéxiào.", exampleTranslation: "Thầy Lý ở trường học.", strokeCount: 16),
                        SHZWordData(hanzi: "学生", pinyin: "xuésheng", sinoVietnamese: "Học sinh", vietnameseMeaning: "Học sinh, sinh viên", exampleHanzi: "我们都是学生。", examplePinyin: "Wǒmen dōu shì xuésheng.", exampleTranslation: "Chúng tôi đều là học sinh.", strokeCount: 13),
                        SHZWordData(hanzi: "汉语", pinyin: "Hànyǔ", sinoVietnamese: "Hán ngữ", vietnameseMeaning: "Tiếng Trung, tiếng Hán", exampleHanzi: "汉语很有趣。", examplePinyin: "Hànyǔ hěn yǒuqù.", exampleTranslation: "Tiếng Trung rất thú vị.", strokeCount: 14),
                        SHZWordData(hanzi: "高兴", pinyin: "gāoxìng", sinoVietnamese: "Cao hưng", vietnameseMeaning: "Vui vẻ, hân hoan", exampleHanzi: "今天我很高兴。", examplePinyin: "Jīntiān wǒ hěn gāoxìng.", exampleTranslation: "Hôm nay tôi rất vui.", strokeCount: 16)
                    ]
                ),
                SHZLessonData(
                    id: "hsk1_b2",
                    lessonNumber: 2,
                    title: "Bài 2: 我和我的家人 (Tôi và gia đình tôi)",
                    topic: "Gia đình, Số đếm & Nghề nghiệp",
                    summary: "Học cách giới thiệu các thành viên trong gia đình, nghề nghiệp, số người và số tuổi.",
                    grammarExplanation: "1. Động từ 有 biểu thị sở hữu: 'Chủ ngữ + 有 + Tân ngữ'. Dạng phủ định là 没有 (không dùng 不有).\n2. Lượng từ 口: Chuyên dùng để đếm nhân khẩu trong gia đình: '我家有五口人'.\n3. Trợ từ sở hữu 的: 'Danh từ 1 + 的 + Danh từ 2' (của).",
                    dialogueChinese: "你家有几口人？\n我家有四口人：爸爸、妈妈、一个姐姐和我。\n你爸爸做什么工作？\n他是医生，在医院工作。你妈妈呢？\n我妈妈是老师，她在大学教英语。\n你姐姐多大了？\n她今年二十四岁，她喜欢看书和听音乐。",
                    dialoguePinyin: "Nǐ jiā yǒu jǐ kǒu rén?\nWǒ jiā yǒu sì kǒu rén: bàba, māma, yí gè jiějie hé wǒ.\nNǐ bàba zuò shénme gōngzuò?\nTā shì yīshēng, zài yīyuàn gōngzuò. Nǐ māma ne?\nWǒ māma shì lǎoshī, tā zài dàxué jiāo Yīngyǔ.\nNǐ jiějie duō dà le?\nTā jīnnián èrshísì suì, tā xǐhuan kànshū hé tīng yīnyuè.",
                    dialogueVietnamese: "Nhà bạn có mấy người?\nNhà tôi có bốn người: bố, mẹ, một chị gái và tôi.\nBố bạn làm nghề gì?\nBố tôi là bác sĩ, làm việc ở bệnh viện. Còn mẹ bạn thì sao?\nMẹ tôi là giáo viên, mẹ dạy tiếng Anh ở trường đại học.\nChị gái bạn bao nhiêu tuổi rồi?\nChị ấy năm nay 24 tuổi, chị ấy thích đọc sách và nghe nhạc.",
                    vocabulary: [
                        SHZWordData(hanzi: "家", pinyin: "jiā", sinoVietnamese: "Gia", vietnameseMeaning: "Nhà, gia đình", exampleHanzi: "我家在北京。", examplePinyin: "Wǒ jiā zài Běijīng.", exampleTranslation: "Nhà tôi ở Bắc Kinh.", strokeCount: 10),
                        SHZWordData(hanzi: "有", pinyin: "yǒu", sinoVietnamese: "Hữu", vietnameseMeaning: "Có", exampleHanzi: "我有三个朋友。", examplePinyin: "Wǒ yǒu sān gè péngyou.", exampleTranslation: "Tôi có ba người bạn.", strokeCount: 6),
                        SHZWordData(hanzi: "爸爸", pinyin: "bàba", sinoVietnamese: "Ba ba", vietnameseMeaning: "Bố, cha", exampleHanzi: "我爸爸很忙。", examplePinyin: "Wǒ bàba hěn máng.", exampleTranslation: "Bố tôi rất bận.", strokeCount: 16),
                        SHZWordData(hanzi: "妈妈", pinyin: "māma", sinoVietnamese: "Ma ma", vietnameseMeaning: "Mẹ, má", exampleHanzi: "妈妈在做饭。", examplePinyin: "Māma zài zuò fàn.", exampleTranslation: "Mẹ đang nấu cơm.", strokeCount: 12),
                        SHZWordData(hanzi: "姐姐", pinyin: "jiějie", sinoVietnamese: "Tỷ tỷ", vietnameseMeaning: "Chị gái", exampleHanzi: "姐姐二十岁。", examplePinyin: "Jiějie èrshí suì.", exampleTranslation: "Chị gái 20 tuổi.", strokeCount: 16),
                        SHZWordData(hanzi: "工作", pinyin: "gōngzuò", sinoVietnamese: "Công tác", vietnameseMeaning: "Làm việc, công việc", exampleHanzi: "你喜欢你的工作吗？", examplePinyin: "Nǐ xǐhuan nǐ de gōngzuò ma?", exampleTranslation: "Bạn thích công việc của bạn không?", strokeCount: 10),
                        SHZWordData(hanzi: "医生", pinyin: "yīshēng", sinoVietnamese: "Y sinh", vietnameseMeaning: "Bác sĩ", exampleHanzi: "他是好医生。", examplePinyin: "Tā shì hǎo yīshēng.", exampleTranslation: "Ông ấy là bác sĩ giỏi.", strokeCount: 12),
                        SHZWordData(hanzi: "喜欢", pinyin: "xǐhuan", sinoVietnamese: "Hỉ hoan", vietnameseMeaning: "Thích, yêu thích", exampleHanzi: "我喜欢中国菜。", examplePinyin: "Wǒ xǐhuan Zhōngguó cài.", exampleTranslation: "Tôi thích món ăn Trung Quốc.", strokeCount: 18)
                    ]
                ),
                SHZLessonData(
                    id: "hsk1_b3",
                    lessonNumber: 3,
                    title: "Bài 3: 你每天几点起床？ (Mỗi ngày bạn mấy giờ thức dậy?)",
                    topic: "Thời gian, Giờ giấc & Lịch trình",
                    summary: "Nắm vững cách diễn đạt mốc thời gian, giờ, phút và thói quen sinh hoạt hàng ngày.",
                    grammarExplanation: "1. Trạng ngữ chỉ thời gian: Đặt trước hoặc sau chủ ngữ. Ví dụ: 我早上七点起床.\n2. Cách nói giờ: Số + 点 (giờ) + Số + 分 (phút). Ví dụ: 八点三十分.",
                    dialogueChinese: "现在几点？\n现在差十分八点。你几点去上课？\n我八点半去上学。\n你每天几点睡觉？\n我晚上十一点睡觉。",
                    dialoguePinyin: "Xiànzài jǐ diǎn?\nXiànzài chà shí fēn bā diǎn. Nǐ jǐ diǎn qù shàngkè?\nWǒ bā diǎn bàn qù shàngxué.\nNǐ měitiān jǐ diǎn shuìjiào?\nWǒ wǎnshang shíyī diǎn shuìjiào.",
                    dialogueVietnamese: "Bây giờ là mấy giờ?\nBây giờ là 8 giờ kém 10. Mấy giờ bạn đi học?\nTôi 8 rưỡi đi học.\nMỗi ngày bạn mấy giờ đi ngủ?\nBuổi tối tôi 11 giờ đi ngủ.",
                    vocabulary: [
                        SHZWordData(hanzi: "现在", pinyin: "xiànzài", sinoVietnamese: "Hiện tại", vietnameseMeaning: "Bây giờ, hiện nay", exampleHanzi: "现在几点？", examplePinyin: "Xiànzài jǐ diǎn?", exampleTranslation: "Bây giờ mấy giờ?", strokeCount: 14),
                        SHZWordData(hanzi: "点", pinyin: "diǎn", sinoVietnamese: "Điểm", vietnameseMeaning: "Giờ (thời gian), chút", exampleHanzi: "三点见。", examplePinyin: "Sān diǎn jiàn.", exampleTranslation: "3 giờ gặp nhé.", strokeCount: 9),
                        SHZWordData(hanzi: "分", pinyin: "fēn", sinoVietnamese: "Phân", vietnameseMeaning: "Phút, chia", exampleHanzi: "五分。", examplePinyin: "Wǔ fēn.", exampleTranslation: "5 phút.", strokeCount: 4),
                        SHZWordData(hanzi: "起床", pinyin: "qǐchuáng", sinoVietnamese: "Khởi sàng", vietnameseMeaning: "Thức dậy, ngủ dậy", exampleHanzi: "早点起床。", examplePinyin: "Zǎo diǎn qǐchuáng.", exampleTranslation: "Dậy sớm một chút.", strokeCount: 17),
                        SHZWordData(hanzi: "睡觉", pinyin: "shuìjiào", sinoVietnamese: "Thụy giác", vietnameseMeaning: "Đi ngủ, ngủ", exampleHanzi: "快去睡觉吧。", examplePinyin: "Kuài qù shuìjiào ba.", exampleTranslation: "Mau đi ngủ đi nào.", strokeCount: 20)
                    ]
                ),
                SHZLessonData(
                    id: "hsk1_b4",
                    lessonNumber: 4,
                    title: "Bài 4: 这个苹果多少钱一斤？ (Táo này bao nhiêu một cân?)",
                    topic: "Mua sắm, Tiền tệ & Giá cả",
                    summary: "Luyện cách hỏi giá cả, đơn vị tiền tệ (đồng/tệ/hào) và mặc cả cơ bản.",
                    grammarExplanation: "1. Đại từ 多少: Hỏi số lượng trên 10 hoặc giá cả: '多少钱' (Bao nhiêu tiền).\n2. Đơn vị tiền tệ: 块 (kuài - tệ/đồng), 毛 (máo - hào), 分 (fēn - xu).",
                    dialogueChinese: "老板，这个苹果多少钱一斤？\n五块钱一斤。你想买多少？\n太贵了！四块钱可以吗？\n好吧，买三斤算你十块钱。\n太好了，给我来三斤！",
                    dialoguePinyin: "Lǎobǎn, zhège píngguǒ duōshao qián yì jīn?\nWǔ kuài qián yì jīn. Nǐ xiǎng mǎi duōshao?\nTài guì le! Sì kuài qián kěyǐ ma?\nHǎo ba, mǎi sān jīn suàn nǐ shí kuài qián.\nTài hǎo le, gěi wǒ lái sān jīn!",
                    dialogueVietnamese: "Ông chủ ơi, táo này bao nhiêu một cân?\n5 tệ một cân. Bạn muốn mua bao nhiêu?\nĐắt quá! 4 tệ được không ạ?\nThôi được rồi, mua 3 cân tính bạn 10 tệ nhé.\nTuyệt quá, cho tôi 3 cân đi!",
                    vocabulary: [
                        SHZWordData(hanzi: "钱", pinyin: "qián", sinoVietnamese: "Tiền", vietnameseMeaning: "Tiền bạc", exampleHanzi: "我有钱。", examplePinyin: "Wǒ yǒu qián.", exampleTranslation: "Tôi có tiền.", strokeCount: 10),
                        SHZWordData(hanzi: "块", pinyin: "kuài", sinoVietnamese: "Khối", vietnameseMeaning: "Đồng, tệ, miếng", exampleHanzi: "十块钱。", examplePinyin: "Shí kuài qián.", exampleTranslation: "Mười đồng.", strokeCount: 7),
                        SHZWordData(hanzi: "苹果", pinyin: "píngguǒ", sinoVietnamese: "Bình quả", vietnameseMeaning: "Quả táo", exampleHanzi: "吃苹果。", examplePinyin: "Chī píngguǒ.", exampleTranslation: "Ăn táo.", strokeCount: 16),
                        SHZWordData(hanzi: "多少", pinyin: "duōshao", sinoVietnamese: "Đa thiểu", vietnameseMeaning: "Bao nhiêu", exampleHanzi: "多少人？", examplePinyin: "Duōshao rén?", exampleTranslation: "Bao nhiêu người?", strokeCount: 10),
                        SHZWordData(hanzi: "买", pinyin: "mǎi", sinoVietnamese: "Mãi", vietnameseMeaning: "Mua", exampleHanzi: "买东西。", examplePinyin: "Mǎi dōngxi.", exampleTranslation: "Mua đồ.", strokeCount: 6)
                    ]
                )
            ]
        ),
        
        // MARK: - HSK 2: 会通汉语 · 应用汉语 2 (Bài 5 -> Bài 8)
        SHZCourseData(
            level: 2,
            courseName: "Khóa học HSK 2",
            textbook: "会通汉语 · 应用汉语 2",
            totalLessons: "Bài 5 → Bài 8 · 72 tiết",
            vocabTarget: "Khoảng 550 từ vựng lũy kế",
            grammarPointsCount: 62,
            lessons: [
                SHZLessonData(
                    id: "hsk2_b5",
                    lessonNumber: 5,
                    title: "Bài 5: 周末你打算做什么？ (Cuối tuần bạn dự định làm gì?)",
                    topic: "Sở thích, Thể thao & Hoạt động cuối tuần",
                    summary: "Diễn tả mục đích hành động, câu liên động, các môn thể thao và giải trí.",
                    grammarExplanation: "1. Câu liên động biểu thị mục đích: 'Chủ ngữ + 去 / 来 + Nơi chốn + Làm gì'. Ví dụ: 我去图书馆借书 (Tôi đi thư viện mượn sách).\n2. Cấu trúc 跟...一起: 'Chủ ngữ + 跟 + Ai đó + 一起 + Động từ'.",
                    dialogueChinese: "周末你打算做什么？\n我想去体育馆踢足球。你去那儿干什么？\n我去图书馆借书。你跟谁一起去？\n我跟大卫一起去。踢完球我们去看电影，你想来吗？\n好啊，我也很想看那部新电影！",
                    dialoguePinyin: "Zhōumò nǐ dǎsuàn zuò shénme?\nWǒ xiǎng qù tǐyùguǎn tī zúqiú. Nǐ qù nàr gàn shénme?\nWǒ qù túshūguǎn jiè shū. Nǐ gēn shéi yìqǐ qù?\nWǒ gēn Dàwèi yìqǐ qù. Tī wán qiú wǒmen qù kàn diànyǐng, nǐ xiǎng lái ma?\nHǎo a, wǒ yě hěn xiǎng kàn nà bù xīn diànyǐng!",
                    dialogueVietnamese: "Cuối tuần bạn dự định làm gì?\nTôi muốn đến nhà thi đấu đá bóng. Bạn đến đó làm gì?\nTôi đến thư viện mượn sách. Bạn đi cùng ai thế?\nTôi đi cùng David. Đá bóng xong chúng tôi đi xem phim, bạn muốn đi cùng không?\nĐược chứ, tôi cũng rất muốn xem bộ phim mới đó!",
                    vocabulary: [
                        SHZWordData(hanzi: "打算", pinyin: "dǎsuàn", sinoVietnamese: "Đả toán", vietnameseMeaning: "Dự định, kế hoạch", exampleHanzi: "你有什么打算？", examplePinyin: "Nǐ yǒu shénme dǎsuàn?", exampleTranslation: "Bạn có dự định gì?", strokeCount: 12),
                        SHZWordData(hanzi: "踢足球", pinyin: "tī zúqiú", sinoVietnamese: "Thích túc cầu", vietnameseMeaning: "Đá bóng", exampleHanzi: "我们一起踢足球吧。", examplePinyin: "Wǒmen yìqǐ tī zúqiú ba.", exampleTranslation: "Chúng ta cùng nhau đá bóng nhé.", strokeCount: 29),
                        SHZWordData(hanzi: "电影", pinyin: "diànyǐng", sinoVietnamese: "Điện ảnh", vietnameseMeaning: "Phim, điện ảnh", exampleHanzi: "这部电影很好看。", examplePinyin: "Zhè bù diànyǐng hěn hǎokàn.", exampleTranslation: "Bộ phim này rất hay.", strokeCount: 14),
                        SHZWordData(hanzi: "运动", pinyin: "yùndòng", sinoVietnamese: "Vận động", vietnameseMeaning: "Thể thao, vận động", exampleHanzi: "每天运动身体好。", examplePinyin: "Měitiān yùndòng shēntǐ hǎo.", exampleTranslation: "Vận động mỗi ngày tốt cho sức khỏe.", strokeCount: 16),
                        SHZWordData(hanzi: "跑步", pinyin: "pǎobù", sinoVietnamese: "Bào bộ", vietnameseMeaning: "Chạy bộ", exampleHanzi: "我每天早上跑步。", examplePinyin: "Wǒ měitiān zǎoshang pǎobù.", exampleTranslation: "Mỗi sáng tôi đều chạy bộ.", strokeCount: 19),
                        SHZWordData(hanzi: "游泳", pinyin: "yóuyǒng", sinoVietnamese: "Du vịnh", vietnameseMeaning: "Bơi lội", exampleHanzi: "夏天去游泳。", examplePinyin: "Xiàtiān qù yóuyǒng.", exampleTranslation: "Mùa hè đi bơi lội.", strokeCount: 21)
                    ]
                ),
                SHZLessonData(
                    id: "hsk2_b6",
                    lessonNumber: 6,
                    title: "Bài 6: 怎么去机场？ (Làm thế nào để đến sân bay?)",
                    topic: "Phương tiện giao thông, Khoảng cách & Vị trí",
                    summary: "Sử dụng các loại phương tiện (xe bus, tàu điện ngầm, taxi) và diễn đạt xa gần bằng giới từ 离.",
                    grammarExplanation: "1. Giới từ 离: 'Địa điểm A + 离 + Địa điểm B + 很远/很近'.\n2. Cấu trúc 坐 / 开: 坐出租车 (Đi taxi), 坐飞机 (Đi máy bay).\n3. 往 + Phương hướng + Động từ: 往前走 (Đi về phía trước).",
                    dialogueChinese: "请问，这里离机场远吗？\n不太远，大概二十公里。\n怎么去最方便？\n坐地铁或者坐出租车都很方便。\n坐出租车要多长时间？\n大概半个小时就能到。",
                    dialoguePinyin: "Qǐngwèn, zhèlǐ lí jīchǎng yuǎn ma?\nBú tài yuǎn, dàgài èrshí gōnglǐ.\nZěnme qù zuì fāngbiàn?\nZuò dìtiě huòzhě zuò chūzūchē dōu hěn fāngbiàn.\nZuò chūzūchē yào duō cháng shíjiān?\nDàgài bàn gè xiǎoshí jiù néng dào.",
                    dialogueVietnamese: "Xin hỏi, ở đây cách sân bay có xa không?\nKhông xa lắm, khoảng 20 cây số.\nĐi thế nào thuận tiện nhất?\nĐi tàu điện ngầm hoặc đi taxi đều rất thuận tiện.\nĐi taxi mất bao lâu?\nKhoảng nửa tiếng là có thể đến nơi.",
                    vocabulary: [
                        SHZWordData(hanzi: "机场", pinyin: "jīchǎng", sinoVietnamese: "Cơ trường", vietnameseMeaning: "Sân bay, phi trường", exampleHanzi: "我在机场等你。", examplePinyin: "Wǒ zài jīchǎng děng nǐ.", exampleTranslation: "Tôi đợi bạn ở sân bay.", strokeCount: 12),
                        SHZWordData(hanzi: "飞机", pinyin: "fēijī", sinoVietnamese: "Phi cơ", vietnameseMeaning: "Máy bay", exampleHanzi: "坐飞机去上海。", examplePinyin: "Zuò fēijī qù Shànghǎi.", exampleTranslation: "Đi máy bay đến Thượng Hải.", strokeCount: 9),
                        SHZWordData(hanzi: "出租车", pinyin: "chūzūchē", sinoVietnamese: "Xuất tô xa", vietnameseMeaning: "Xe taxi", exampleHanzi: "我们叫出租车吧。", examplePinyin: "Wǒmen jiào chūzūchē ba.", exampleTranslation: "Chúng ta gọi taxi nhé.", strokeCount: 19),
                        SHZWordData(hanzi: "地铁", pinyin: "dìtiě", sinoVietnamese: "Địa thiết", vietnameseMeaning: "Tàu điện ngầm", exampleHanzi: "坐地铁很快。", examplePinyin: "Zuò dìtiě hěn kuài.", exampleTranslation: "Đi tàu điện ngầm rất nhanh.", strokeCount: 16),
                        SHZWordData(hanzi: "远", pinyin: "yuǎn", sinoVietnamese: "Viễn", vietnameseMeaning: "Xa", exampleHanzi: "学校离家很远。", examplePinyin: "Xuéxiào lí jiā hěn yuǎn.", exampleTranslation: "Trường học cách nhà rất xa.", strokeCount: 7),
                        SHZWordData(hanzi: "近", pinyin: "jìn", sinoVietnamese: "Cận", vietnameseMeaning: "Gần", exampleHanzi: "我家离公司很近。", examplePinyin: "Wǒ jiā lí gōngsī hěn jìn.", exampleTranslation: "Nhà tôi cách công ty rất gần.", strokeCount: 7)
                    ]
                ),
                SHZLessonData(
                    id: "hsk2_b7",
                    lessonNumber: 7,
                    title: "Bài 7: 这件衣服多少钱？ (Chiếc áo này bao nhiêu tiền?)",
                    topic: "Mua sắm quần áo, Màu sắc & Thử đồ",
                    summary: "Học các lượng từ đồ vật (件, 条, 双), màu sắc và cấu trúc thử quần áo.",
                    grammarExplanation: "1. Lượng từ 件: Dùng cho áo, sự việc (一件衣服, 一件事).\n2. Trợ từ động thái 过: 'Động từ + 过' biểu thị từng trải qua việc gì.",
                    dialogueChinese: "小姐，我想看看那件白色的衬衫。\n这件衬衫很好看，你可以试一试。\n有大一点儿的吗？这件有点儿小。\n有，给您这件大号的。\n挺合适的，多少钱？\n打完折两百块。",
                    dialoguePinyin: "Xiǎojiě, wǒ xiǎng kànkan nà jiàn báisè de chènshān.\nZhè jiàn chènshān hěn hǎokàn, nǐ kěyǐ shì yí shì.\nYǒu dà yìdiǎnr de ma? Zhè jiàn yǒudiǎnr xiǎo.\nYǒu, gěi nín zhè jiàn dàhào de.\nTǐng héshì de, duōshao qián?\nDǎ wán zhé liǎng bǎi kuài.",
                    dialogueVietnamese: "Cô ơi, tôi muốn xem chiếc áo sơ mi màu trắng đằng kia.\nChiếc áo này rất đẹp, bạn có thể thử một chút.\nCó chiếc lớn hơn một chút không? Chiếc này hơi nhỏ.\nCó chứ, gửi bạn chiếc cỡ lớn này.\nRất vừa vặn, bao nhiêu tiền vậy?\nGiảm giá xong là 200 tệ.",
                    vocabulary: [
                        SHZWordData(hanzi: "件", pinyin: "jiàn", sinoVietnamese: "Kiện", vietnameseMeaning: "Chiếc, cái (áo, sự việc)", exampleHanzi: "一件衣服。", examplePinyin: "Yí jiàn yīfu.", exampleTranslation: "Một chiếc áo.", strokeCount: 6),
                        SHZWordData(hanzi: "衣服", pinyin: "yīfu", sinoVietnamese: "Y phục", vietnameseMeaning: "Quần áo", exampleHanzi: "买新衣服。", examplePinyin: "Mǎi xīn yīfu.", exampleTranslation: "Mua quần áo mới.", strokeCount: 14),
                        SHZWordData(hanzi: "白色", pinyin: "báisè", sinoVietnamese: "Bạch sắc", vietnameseMeaning: "Màu trắng", exampleHanzi: "白色的鞋。", examplePinyin: "Báisè de xié.", exampleTranslation: "Đôi giày màu trắng.", strokeCount: 11),
                        SHZWordData(hanzi: "试", pinyin: "shì", sinoVietnamese: "Thí", vietnameseMeaning: "Thử", exampleHanzi: "试一下。", examplePinyin: "Shì yíxià.", exampleTranslation: "Thử một chút.", strokeCount: 8),
                        SHZWordData(hanzi: "合适", pinyin: "héshì", sinoVietnamese: "Hợp thích", vietnameseMeaning: "Vừa vặn, thích hợp", exampleHanzi: "大小合适。", examplePinyin: "Dàxiǎo héshì.", exampleTranslation: "Kích cỡ vừa vặn.", strokeCount: 12)
                    ]
                ),
                SHZLessonData(
                    id: "hsk2_b8",
                    lessonNumber: 8,
                    title: "Bài 8: 今天比昨天冷多了 (Hôm nay lạnh hơn hôm qua nhiều)",
                    topic: "Thời tiết, Khí hậu & Câu so sánh chữ 比",
                    summary: "Làm chủ cấu trúc câu so sánh chữ 比 và các từ vựng thời tiết 4 mùa.",
                    grammarExplanation: "1. Câu so sánh chữ 比: 'A + 比 + B + Tính từ + (Mức độ)'. Ví dụ: 今天比昨天冷.\n2. Biểu thị chênh lệch lớn: Thêm 多了 hoặc 得多 sau tính từ.",
                    dialogueChinese: "今天天气怎么样？\n今天比昨天冷多了，外面还在下雨。\n你要出门吗？\n我要去超市买点东西。\n外面冷，多穿点衣服，别感冒了！\n好的，谢谢你！",
                    dialoguePinyin: "Jīntiān tiānqì zěnmeyàng?\nJīntiān bǐ zuótiān lěng duō le, wàimiàn hái zài xiàyǔ.\nNǐ yào chūmén ma?\nWǒ yào qù chāoshì mǎi diǎn dōngxi.\nWàimiàn lěng, duō chuān diǎn yīfu, bié gǎnmào le!\nHǎo de, xièxie nǐ!",
                    dialogueVietnamese: "Hôm nay thời tiết thế nào?\nHôm nay lạnh hơn hôm qua nhiều, bên ngoài vẫn đang mưa.\nBạn có ra ngoài không?\nTôi phải đến siêu thị mua chút đồ.\nBên ngoài lạnh, mặc thêm quần áo vào, đừng để bị cảm nhé!\nĐược rồi, cảm ơn bạn nhé!",
                    vocabulary: [
                        SHZWordData(hanzi: "比", pinyin: "bǐ", sinoVietnamese: "Tỷ", vietnameseMeaning: "So với, hơn (so sánh)", exampleHanzi: "他比我大。", examplePinyin: "Tā bǐ wǒ dà.", exampleTranslation: "Anh ấy lớn hơn tôi.", strokeCount: 4),
                        SHZWordData(hanzi: "天气", pinyin: "tiānqì", sinoVietnamese: "Thiên khí", vietnameseMeaning: "Thời tiết", exampleHanzi: "天气真好！", examplePinyin: "Tiānqì zhēn hǎo!", exampleTranslation: "Thời tiết thật đẹp!", strokeCount: 10),
                        SHZWordData(hanzi: "冷", pinyin: "lěng", sinoVietnamese: "Lãnh", vietnameseMeaning: "Lạnh", exampleHanzi: "冬天很冷。", examplePinyin: "Dōngtiān hěn lěng.", exampleTranslation: "Mùa đông rất lạnh.", strokeCount: 7),
                        SHZWordData(hanzi: "下雨", pinyin: "xiàyǔ", sinoVietnamese: "Hạ vũ", vietnameseMeaning: "Mưa, trời mưa", exampleHanzi: "外面下雨了。", examplePinyin: "Wàimiàn xiàyǔ le.", exampleTranslation: "Bên ngoài trời mưa rồi.", strokeCount: 11),
                        SHZWordData(hanzi: "晴天", pinyin: "qíngtiān", sinoVietnamese: "Tình thiên", vietnameseMeaning: "Trời nắng, trời quang", exampleHanzi: "明天是晴天。", examplePinyin: "Míngtiān shì qíngtiān.", exampleTranslation: "Ngày mai trời nắng đẹp.", strokeCount: 16)
                    ]
                )
            ]
        ),
        
        // MARK: - HSK 3: 发展汉语 · 初级综合 (Bài 1 -> Bài 4)
        SHZCourseData(
            level: 3,
            courseName: "Khóa học HSK 3",
            textbook: "发展汉语 · 初级综合",
            totalLessons: "Bài 1 → Bài 4 · 72 tiết",
            vocabTarget: "Khoảng 1.000 từ vựng tích lũy",
            grammarPointsCount: 78,
            lessons: [
                SHZLessonData(
                    id: "hsk3_b1",
                    lessonNumber: 1,
                    title: "Bài 1: 我的旅行计划 (Kế hoạch du lịch của tôi)",
                    topic: "Du lịch, Chuẩn bị hành lý & Đặt phòng khách sạn",
                    summary: "Trình bày kế hoạch du lịch chi tiết, dùng liên từ 虽然...但是 và cấu trúc 把.",
                    grammarExplanation: "1. Liên từ 虽然...但是: Tuy... nhưng... Ví dụ: 虽然很累，但是很开心.\n2. Cấu trúc câu chữ 把: Biểu thị sự tác động làm biến đổi tân ngữ.",
                    dialogueChinese: "放假了，你打算去哪儿旅游？\n我打算去云南旅游。我已经把机票和宾馆都预订好了。\n你一个人去吗？\n我和两个同事一起去，虽然路途很远，但是风景特别美。\n祝你旅途愉快！\n谢谢！",
                    dialoguePinyin: "Fàngjià le, nǐ dǎsuàn qù nǎr lǚyóu?\nWǒ dǎsuàn qù Yúnnán lǚyóu. Wǒ yǐjīng bǎ jīpiào hé bīnguǎn dōu yùdìng hǎo le.\nNǐ yí gè rén qù ma?\nWǒ hé liǎng gè tóngshì yìqǐ qù, suīrán lùtú hěn yuǎn, dànshì fēngjǐng tèbié měi.\nZhù nǐ lǚtú yúkuài!\nXièxie!",
                    dialogueVietnamese: "Nghỉ lễ rồi, bạn định đi đâu du lịch?\nTôi dự định đi du lịch Vân Nam. Tôi đã đặt xong vé máy bay và khách sạn rồi.\nBạn đi một mình à?\nTôi đi cùng hai đồng nghiệp, tuy đường xá xa xôi nhưng phong cảnh đặc biệt đẹp.\nChúc bạn chuyến đi vui vẻ nhé!\nCảm ơn bạn!",
                    vocabulary: [
                        SHZWordData(hanzi: "旅游", pinyin: "lǚyóu", sinoVietnamese: "Lữ du", vietnameseMeaning: "Du lịch", exampleHanzi: "我想去中国旅游。", examplePinyin: "Wǒ xiǎng qù Zhōngguó lǚyóu.", exampleTranslation: "Tôi muốn đi du lịch Trung Quốc.", strokeCount: 20),
                        SHZWordData(hanzi: "宾馆", pinyin: "bīnguǎn", sinoVietnamese: "Tân quán", vietnameseMeaning: "Khách sạn", exampleHanzi: "预订宾馆。", examplePinyin: "Yùdìng bīnguǎn.", exampleTranslation: "Đặt phòng khách sạn.", strokeCount: 18),
                        SHZWordData(hanzi: "虽然", pinyin: "suīrán", sinoVietnamese: "Tuy nhiên", vietnameseMeaning: "Tuy rằng, mặc dù", exampleHanzi: "虽然很难。", examplePinyin: "Suīrán hěn nán.", exampleTranslation: "Tuy rằng rất khó.", strokeCount: 16),
                        SHZWordData(hanzi: "但是", pinyin: "dànshì", sinoVietnamese: "Đãn thị", vietnameseMeaning: "Nhưng, nhưng mà", exampleHanzi: "但是很有趣。", examplePinyin: "Dànshì hěn yǒuqù.", exampleTranslation: "Nhưng rất thú vị.", strokeCount: 14),
                        SHZWordData(hanzi: "护照", pinyin: "hùzhào", sinoVietnamese: "Hộ chiếu", vietnameseMeaning: "Hộ chiếu", exampleHanzi: "带上护照。", examplePinyin: "Dài shàng hùzhào.", exampleTranslation: "Mang theo hộ chiếu.", strokeCount: 22)
                    ]
                ),
                SHZLessonData(
                    id: "hsk3_b2",
                    lessonNumber: 2,
                    title: "Bài 2: 你最近身体怎么样？ (Dạo này sức khỏe bạn thế nào?)",
                    topic: "Sức khỏe, Khám bệnh & Lời khuyên",
                    summary: "Mô tả triệu chứng bệnh tật, đơn thuốc và cấu trúc 越来越...",
                    grammarExplanation: "1. Cấu trúc 越来越...: Càng ngày càng... Ví dụ: 天气越来越热 (Thời tiết ngày càng nóng).\n2. Câu chữ 把 với động từ hai âm tiết: 把药吃了 (Uống thuốc đi).",
                    dialogueChinese: "你看上去脸色不太好，怎么了？\n我最近感冒了，头疼，还一直发烧。\n你看医生了吗？\n昨天去医院看过了，医生让我多休息，按时吃药。\n身体是第一位的，工作别太累，快把药喝了吧！",
                    dialoguePinyin: "Nǐ kàn shàngqù liǎnsè bú tài hǎo, zěnme le?\nWǒ zuìjìn gǎnmào le, tóu téng, hái yìzhí fāshāo.\nNǐ kàn yīshēng le ma?\nZuótiān qù yīyuàn kàn guò le, yīshēng ràng wǒ duō xiūxi, ànshí chī yào.\nShēntǐ shì dì-yī wèi de, gōngzuò bié tài lèi, kuài bǎ yào hē le ba!",
                    dialogueVietnamese: "Trông sắc mặt bạn không được tốt lắm, sao thế?\nDạo này tôi bị cảm rồi, đau đầu, lại còn sốt suốt.\nBạn đã đi khám bác sĩ chưa?\nHôm qua đi bệnh viện khám rồi, bác sĩ bảo tôi nghỉ ngơi nhiều, uống thuốc đúng giờ.\nSức khỏe là quan trọng nhất, công việc đừng quá sức, mau uống thuốc đi nhé!",
                    vocabulary: [
                        SHZWordData(hanzi: "感冒", pinyin: "gǎnmào", sinoVietnamese: "Cảm mạo", vietnameseMeaning: "Cảm cúm, bị cảm", exampleHanzi: "我不小心感冒了。", examplePinyin: "Wǒ bù xiǎoxīn gǎnmào le.", exampleTranslation: "Tôi sơ ý bị cảm rồi.", strokeCount: 25),
                        SHZWordData(hanzi: "发烧", pinyin: "fāshāo", sinoVietnamese: "Phát thiêu", vietnameseMeaning: "Phát sốt, sốt", exampleHanzi: "孩子发烧了。", examplePinyin: "Háizi fāshāo le.", exampleTranslation: "Đứa bé bị sốt rồi.", strokeCount: 15),
                        SHZWordData(hanzi: "疼", pinyin: "téng", sinoVietnamese: "Đông", vietnameseMeaning: "Đau, đau nhức", exampleHanzi: "我的肚子很疼。", examplePinyin: "Wǒ de dùzi hěn téng.", exampleTranslation: "Bụng tôi rất đau.", strokeCount: 10),
                        SHZWordData(hanzi: "药", pinyin: "yào", sinoVietnamese: "Dược", vietnameseMeaning: "Thuốc", exampleHanzi: "按时吃药。", examplePinyin: "Ànshí chī yào.", exampleTranslation: "Uống thuốc đúng giờ.", strokeCount: 9),
                        SHZWordData(hanzi: "身体", pinyin: "shēntǐ", sinoVietnamese: "Thân thể", vietnameseMeaning: "Sức khỏe, cơ thể", exampleHanzi: "祝你身体健康！", examplePinyin: "Zhù nǐ shēntǐ jiànkāng!", exampleTranslation: "Chúc bạn sức khỏe dồi dào!", strokeCount: 14)
                    ]
                ),
                SHZLessonData(
                    id: "hsk3_b3",
                    lessonNumber: 3,
                    title: "Bài 3: 面试与工作机会 (Phỏng vấn và cơ hội việc làm)",
                    topic: "Nghề nghiệp, Phỏng vấn & Kinh nghiệm làm việc",
                    summary: "Trình bày hồ sơ xin việc, trả lời câu hỏi phỏng vấn và thảo luận chế độ đãi ngộ.",
                    grammarExplanation: "1. Giới từ 对: 'Đối với...'. Ví dụ: 我对这个职位很感兴趣 (Tôi rất hứng thú với vị trí này).\n2. Trợ động từ 应该 (Nên, cần phải).",
                    dialogueChinese: "您好，我是来参加今天下午面试的。\n你好，请坐。请先做个简短的自我介绍。\n我毕业于北京语言大学，有两年的外贸工作经验，汉语和英语都比较流利。\n非常好，我们公司正需要像你这样有跨国交流经验的人才！",
                    dialoguePinyin: "Nín hǎo, wǒ shì lái cānjiā jīntiān xiàwǔ miànshì de.\nNǐ hǎo, qǐng zuò. Qǐng xiān zuò gè jiǎnduǎn de zìwǒ jièshào.\nWǒ bìyè yú Běijīng Yǔyán Dàxué, yǒu liǎng nián de wàimào gōngzuò jīngyàn, Hànyǔ hé Yīngyǔ dōu bǐjiào liúlì.\nFēicháng hǎo, wǒmen gōngsī zhèng xūyào xiàng nǐ zhèyàng yǒu kuàguó jiāoliú jīngyàn de réncái!",
                    dialogueVietnamese: "Chào ngài, tôi đến tham gia buổi phỏng vấn chiều nay.\nChào bạn, mời ngồi. Xin mời tự giới thiệu ngắn gọn về bản thân.\nTôi tốt nghiệp Đại học Ngôn ngữ Bắc Kinh, có 2 năm kinh nghiệm làm ngoại thương, tiếng Trung và tiếng Anh đều khá lưu loát.\nRất tốt, công ty chúng tôi đang cần nhân tài có kinh nghiệm giao tiếp quốc tế như bạn!",
                    vocabulary: [
                        SHZWordData(hanzi: "面试", pinyin: "miànshì", sinoVietnamese: "Diện thí", vietnameseMeaning: "Phỏng vấn", exampleHanzi: "准备面试。", examplePinyin: "Zhǔnbèi miànshì.", exampleTranslation: "Chuẩn bị phỏng vấn.", strokeCount: 16),
                        SHZWordData(hanzi: "经验", pinyin: "jīngyàn", sinoVietnamese: "Kinh nghiệm", vietnameseMeaning: "Kinh nghiệm", exampleHanzi: "丰富的工作经验。", examplePinyin: "Fēngfù de gōngzuò jīngyàn.", exampleTranslation: "Kinh nghiệm làm việc phong phú.", strokeCount: 18),
                        SHZWordData(hanzi: "流利", pinyin: "liúlì", sinoVietnamese: "Lưu lợi", vietnameseMeaning: "Lưu loát, trôi chảy", exampleHanzi: "汉语说得很流利。", examplePinyin: "Hànyǔ shuō de hěn liúlì.", exampleTranslation: "Nói tiếng Trung rất lưu loát.", strokeCount: 15),
                        SHZWordData(hanzi: "公司", pinyin: "gōngsī", sinoVietnamese: "Công ty", vietnameseMeaning: "Công ty, doanh nghiệp", exampleHanzi: "我们在跨国公司工作。", examplePinyin: "Wǒmen zài kuàguó gōngsī gōngzuò.", exampleTranslation: "Chúng tôi làm việc ở công ty đa quốc gia.", strokeCount: 8)
                    ]
                ),
                SHZLessonData(
                    id: "hsk3_b4",
                    lessonNumber: 4,
                    title: "Bài 4: 网上购物与现代生活 (Mua sắm online và đời sống hiện đại)",
                    topic: "Thương mại điện tử & Tiện ích Internet",
                    summary: "Giao dịch thanh toán di động, đánh giá chất lượng sản phẩm và liên từ 又...又...",
                    grammarExplanation: "1. Cấu trúc 又...又...: Vừa... lại vừa... Ví dụ: 这双鞋又便宜又舒服.\n2. Phó từ 一边...一边...: Biểu thị hai hành động xảy ra đồng thời.",
                    dialogueChinese: "你手里的包裹是什么？\n我昨天在网上买的运动鞋，今天上午就送到了，真快！\n质量怎么样？\n质量特别好，又轻又舒服，价格还比商场便宜一半呢！\n现在网上买东西真方便，我也想买一双。",
                    dialoguePinyin: "Nǐ shǒu lǐ de bāoguǒ shì shénme?\nWǒ zuótiān zài wǎngshang mǎi de yùndòngxié, jīntiān shàngwǔ jiù sòng dào le, zhēn kuài!\nZhìliàng zěnmeyàng?\nZhìliàng tèbié hǎo, yòu qīng yòu shūfu, jiàgé hái bǐ shāngchǎng piányi yíbàn ne!\nXiànzài wǎngshang mǎi dōngxi zhēn fāngbiàn, wǒ yě xiǎng mǎi yì shuāng.",
                    dialogueVietnamese: "Bưu kiện trên tay bạn là cái gì thế?\nĐôi giày thể thao tôi mua trên mạng hôm qua đấy, sáng nay đã giao đến rồi, nhanh thật!\nChất lượng thế nào?\nChất lượng cực kỳ tốt, vừa nhẹ vừa êm, giá lại rẻ hơn trung tâm thương mại một nửa!\nBây giờ mua đồ trên mạng tiện thật, tôi cũng muốn mua một đôi.",
                    vocabulary: [
                        SHZWordData(hanzi: "上网", pinyin: "shàngwǎng", sinoVietnamese: "Thượng võng", vietnameseMeaning: "Lên mạng, vào internet", exampleHanzi: "每天上网。", examplePinyin: "Měitiān shàngwǎng.", exampleTranslation: "Lên mạng mỗi ngày.", strokeCount: 9),
                        SHZWordData(hanzi: "方便", pinyin: "fāngbiàn", sinoVietnamese: "Phương tiện", vietnameseMeaning: "Thuận tiện, tiện lợi", exampleHanzi: "交通很方便。", examplePinyin: "Jiāotōng hěn fāngbiàn.", exampleTranslation: "Giao thông rất thuận tiện.", strokeCount: 13),
                        SHZWordData(hanzi: "便宜", pinyin: "piányi", sinoVietnamese: "Tiện nghi", vietnameseMeaning: "Rẻ, giá rẻ", exampleHanzi: "太便宜了！", examplePinyin: "Tài piányi le!", exampleTranslation: "Rẻ quá đi!", strokeCount: 16),
                        SHZWordData(hanzi: "质量", pinyin: "zhìliàng", sinoVietnamese: "Chất lượng", vietnameseMeaning: "Chất lượng sản phẩm", exampleHanzi: "保证质量。", examplePinyin: "Bǎozhèng zhìliàng.", exampleTranslation: "Đảm bảo chất lượng.", strokeCount: 18)
                    ]
                )
            ]
        ),
        
        // MARK: - HSK 4: 发展汉语 · 中级综合 (Bài 1 -> Bài 4)
        SHZCourseData(
            level: 4,
            courseName: "Khóa học HSK 4",
            textbook: "发展汉语 · 中级综合",
            totalLessons: "Bài 1 → Bài 4 · 72 tiết",
            vocabTarget: "Khoảng 2.000 từ vựng",
            grammarPointsCount: 105,
            lessons: [
                SHZLessonData(
                    id: "hsk4_b1",
                    lessonNumber: 1,
                    title: "Bài 1: 爱情与婚姻的真谛 (Chân lý của tình yêu và hôn nhân)",
                    topic: "Tình yêu, Hôn nhân & Giá trị gia đình",
                    summary: "Bàn về quan niệm tình yêu, sự thấu hiểu giữa vợ chồng và liên từ 不仅...而且...",
                    grammarExplanation: "1. Liên từ 不仅...而且...: Không những... mà còn... Ví dụ: 他不仅聪明，而且非常勤奋.\n2. Phó từ 哪怕: Cho dù, dẫu cho.",
                    dialogueChinese: "你们结婚二十年了，为什么感情还这么好？\n浪漫的爱情只是开始，长久的婚姻需要双方的互相理解与包容。\n很多人说婚后生活很平淡，你们是怎么保持新鲜感的？\n生活中不仅要共同承担家务，更要经常交流内心的想法，尊重彼此的独立空间。",
                    dialoguePinyin: "Nǐmen jiéhūn èrshí nián le, wèishénme gǎnqíng hái zhème hǎo?\nLàngmàn de àiqíng zhǐshì kāishǐ, chángjiǔ de hūnyīn xūyào shuāngfāng de hùxiāng lǐjiě yǔ bāoróng.\nHěn duō rén shuō hūnhòu shēnghuó hěn píngdàn, nǐmen shì zěnme bǎochí xīnxiāngǎn de?\nShēnghuó zhōng bùjǐn yào gòngtóng chéngdān jiāwù, gèng yào jīngcháng jiāoliú nèixīn de xiǎngfǎ, zūnzhòng bǐcǐ de dúlì kōngjiān.",
                    dialogueVietnamese: "Hai người kết hôn 20 năm rồi, sao tình cảm vẫn mặn nồng thế?\nTình yêu lãng mạn chỉ là bắt đầu, hôn nhân lâu bền cần sự thấu hiểu và bao dung từ cả hai phía.\nNhiều người bảo cuộc sống sau hôn nhân rất bình đạm, hai bạn giữ sự tươi mới bằng cách nào?\nTrong cuộc sống không những phải cùng san sẻ việc nhà, mà quan trọng hơn là thường xuyên tâm sự và tôn trọng không gian riêng của nhau.",
                    vocabulary: [
                        SHZWordData(hanzi: "结婚", pinyin: "jiéhūn", sinoVietnamese: "Kết hôn", vietnameseMeaning: "Lập gia đình, cưới", exampleHanzi: "祝贺你们结婚！", examplePinyin: "Zhùhè nǐmen jiéhūn!", exampleTranslation: "Chúc mừng hai bạn kết hôn!", strokeCount: 20),
                        SHZWordData(hanzi: "互相", pinyin: "hùxiāng", sinoVietnamese: "Hỗ tương", vietnameseMeaning: "Lẫn nhau, qua lại", exampleHanzi: "互相帮助。", examplePinyin: "Hùxiāng bāngzhù.", exampleTranslation: "Giúp đỡ lẫn nhau.", strokeCount: 13),
                        SHZWordData(hanzi: "理解", pinyin: "lǐjiě", sinoVietnamese: "Lý giải", vietnameseMeaning: "Hiểu, thấu hiểu", exampleHanzi: "请理解我的难处。", examplePinyin: "Qǐng lǐjiě wǒ de nánchu.", exampleTranslation: "Xin hãy hiểu cho nỗi khó của tôi.", strokeCount: 17),
                        SHZWordData(hanzi: "尊重", pinyin: "zūnzhòng", sinoVietnamese: "Tôn trọng", vietnameseMeaning: "Tôn trọng, kính trọng", exampleHanzi: "尊重别人的意见。", examplePinyin: "Zūnzhòng biérén de yìjiàn.", exampleTranslation: "Tôn trọng ý kiến người khác.", strokeCount: 21)
                    ]
                ),
                SHZLessonData(
                    id: "hsk4_b2",
                    lessonNumber: 2,
                    title: "Bài 2: 成功的秘密在于坚持 (Bí quyết thành công là kiên trì)",
                    topic: "Sự nghiệp, Động lực & Thái độ sống",
                    summary: "Phân tích phẩm chất của người thành đạt, đối mặt thất bại và cấu trúc 只要...就...",
                    grammarExplanation: "1. Cấu trúc 只要...就...: Chỉ cần... thì sẽ... Ví dụ: 只要坚持努力，就一定能成功.\n2. Câu chữ 被 (Bị động): 'Tân ngữ + 被 + Chủ thể + Động từ'.",
                    dialogueChinese: "很多人在遇到困难时会选择放弃，您是怎么坚持下来的？\n失败其实是通往成功的必经之路。只要目标明确，哪怕走得慢一点，也不要停下脚步。\n对于刚步入社会的年轻人，您有什么建议？\n不要害怕犯错，要把每一次挫折都看作积累经验的宝贵财富。",
                    dialoguePinyin: "Hěn duō rén zài yùdào kùnnan shí huì xuǎnzé fàngqì, nín shì zěnme jiānchí xiàlai de?\nShībài qíshí shì tōngwǎng chénggōng de bìjīng zhī lù. Zhǐyào mùbiāo míngquè, nǎpà zǒu de màn yìdiǎn, yě bú yào tíng xià jiǎobù.\nDuìyú gāng bùrù shèhuì de niánqīngrén, nín yǒu shénme jiànyì?\nBú yào hàipà fàncuò, yào bǎ měi yí cì cuòzhé dōu kànzuò jīlěi jīngyàn de bǎoguì cáifù.",
                    dialogueVietnamese: "Nhiều người khi gặp khó khăn thường chọn bỏ cuộc, làm sao ngài có thể kiên trì được?\nThất bại thực ra là con đường tất yếu dẫn tới thành công. Chỉ cần mục tiêu rõ ràng, dẫu cho đi chậm một chút, cũng đừng dừng bước.\nĐối với các bạn trẻ mới bước vào đời, ngài có lời khuyên gì?\nĐừng sợ phạm sai lầm, hãy coi mỗi lần trắc trở là tài sản quý báu để tích lũy kinh nghiệm.",
                    vocabulary: [
                        SHZWordData(hanzi: "坚持", pinyin: "jiānchí", sinoVietnamese: "Kiên trì", vietnameseMeaning: "Kiên trì, giữ vững", exampleHanzi: "坚持到底就是胜利。", examplePinyin: "Jiānchí dàodǐ jiù shì shènglì.", exampleTranslation: "Kiên trì đến cùng là thắng lợi.", strokeCount: 18),
                        SHZWordData(hanzi: "成功", pinyin: "chénggōng", sinoVietnamese: "Thành công", vietnameseMeaning: "Thành công", exampleHanzi: "祝你早日成功！", examplePinyin: "Zhù nǐ zǎorì chénggōng!", exampleTranslation: "Chúc bạn sớm thành công!", strokeCount: 12),
                        SHZWordData(hanzi: "放弃", pinyin: "fàngqì", sinoVietnamese: "Phóng khí", vietnameseMeaning: "Từ bỏ, buông xuôi", exampleHanzi: "永不放弃。", examplePinyin: "Yǒng bù fàngqì.", exampleTranslation: "Không bao giờ từ bỏ.", strokeCount: 12),
                        SHZWordData(hanzi: "积累", pinyin: "jīlěi", sinoVietnamese: "Tích lũy", vietnameseMeaning: "Tích lũy, gom góp", exampleHanzi: "积累知识。", examplePinyin: "Jīlěi zhīshi.", exampleTranslation: "Tích lũy kiến thức.", strokeCount: 23)
                    ]
                ),
                SHZLessonData(
                    id: "hsk4_b3",
                    lessonNumber: 3,
                    title: "Bài 3: 保护绿色地球家园 (Bảo vệ mái nhà trái đất xanh)",
                    topic: "Môi trường, Sinh thái & Tiết kiệm tài nguyên",
                    summary: "Thảo luận về biến đổi khí hậu, phân loại rác thải và trách nhiệm công dân.",
                    grammarExplanation: "1. Câu bị động chữ 被: '塑料袋被禁止使用了' (Túi ni lông đã bị cấm sử dụng).\n2. Giới từ 随着: Đi cùng với, theo đà... Ví dụ: 随着经济的发展 (Cùng với sự phát triển kinh tế).",
                    dialogueChinese: "最近几年极端天气越来越频繁，我们每个人都应该反思。\n是的，全球变暖和环境污染已经严重威胁到了人类的生存。\n作为普通人，我们平时能为环保做些什么呢？\n出门尽量乘坐公共交通，减少使用一次性塑料制品，养成垃圾分类的好习惯。",
                    dialoguePinyin: "Zuìjìn jǐ nián jíduān tiānqì yuèláiyuè pínfán, wǒmen měi gè rén dōu yīnggāi fǎnsī.\nShì de, quánqiú biànnuǎn hé huánjìng wūrǎn yǐjīng yánzhòng wēixié dào le rénlèi de shēngcún.\nZuòwéi pǔtōngrén, wǒmen píngshí néng wèi huánbǎo zuò xiē shénme ne?\nChūmén jǐnliàng chéngzuò gōnggòng jiāotōng, jiǎnshǎo shǐyòng yícìxìng sùliào zhìpǐn, yǎngchéng lājī fēnlèi de hǎo xíguàn.",
                    dialogueVietnamese: "Mấy năm gần đây thời tiết cực đoan ngày càng thường xuyên, mỗi người chúng ta đều nên suy ngẫm.\nĐúng vậy, sự nóng lên toàn cầu và ô nhiễm môi trường đã đe dọa nghiêm trọng tới sự sống còn của nhân loại.\nLà người bình thường, hàng ngày chúng ta có thể làm gì vì môi trường?\nRa ngoài cố gắng đi phương tiện công cộng, giảm dùng đồ nhựa dùng một lần, hình thành thói quen phân loại rác.",
                    vocabulary: [
                        SHZWordData(hanzi: "保护", pinyin: "bǎohù", sinoVietnamese: "Bảo hộ", vietnameseMeaning: "Bảo vệ, gìn giữ", exampleHanzi: "保护大自然。", examplePinyin: "Bǎohù dàzìrán.", exampleTranslation: "Bảo vệ thiên nhiên.", strokeCount: 16),
                        SHZWordData(hanzi: "环境", pinyin: "huánjìng", sinoVietnamese: "Hoàn cảnh", vietnameseMeaning: "Môi trường", exampleHanzi: "保护生态环境。", examplePinyin: "Bǎohù shēngtài huánjìng.", exampleTranslation: "Bảo vệ môi trường sinh thái.", strokeCount: 20),
                        SHZWordData(hanzi: "严重", pinyin: "yánzhòng", sinoVietnamese: "Nghiêm trọng", vietnameseMeaning: "Nghiêm trọng, trầm trọng", exampleHanzi: "污染很严重。", examplePinyin: "Wūrǎn hěn yánzhòng.", exampleTranslation: "Ô nhiễm rất nghiêm trọng.", strokeCount: 18),
                        SHZWordData(hanzi: "习惯", pinyin: "xíguàn", sinoVietnamese: "Tập quán", vietnameseMeaning: "Thói quen, quen với", exampleHanzi: "养成良好的生活习惯。", examplePinyin: "Yǎngchéng liánghǎo de shēnghuó xíguàn.", exampleTranslation: "Tạo thói quen sinh hoạt tốt.", strokeCount: 15)
                    ]
                ),
                SHZLessonData(
                    id: "hsk4_b4",
                    lessonNumber: 4,
                    title: "Bài 4: 中国茶文化与待客之道 (Văn hóa trà và đạo tiếp khách)",
                    topic: "Văn hóa truyền thống, Ẩm thực & Phong tục",
                    summary: "Khám phá nghệ thuật thưởng trà, lễ nghĩa trên bàn ăn và liên từ 无论...都...",
                    grammarExplanation: "1. Liên từ 无论...都...: Bất luận... đều... Ví dụ: 无论走到哪里，我都想念家乡.\n2. Trợ từ 所: Đặt trước động từ để danh từ hóa.",
                    dialogueChinese: "中国人在招待客人时，为什么总喜欢泡上一壶热茶？\n俗话说'客来敬茶'，茶不仅能消渴解腻，更代表着主人对客人的敬意与热情。\n泡茶有什么讲究吗？\n无论水温、茶叶用量还是冲泡时间都有严格的要求，这正是茶艺修身养性的魅力所在。",
                    dialoguePinyin: "Zhōngguórén zài zhāodài kèrén shí, wèishénme zǒng xǐhuan pào shàng yì hú rè chá?\nSúhuà shuō 'kè lái jìng chá', chá bùjǐn néng xiāokě jiěnì, gèng dàibiǎo zhe zhǔrén duì kèrén de jìngyì yǔ rèqíng.\nPào chá yǒu shénme jiǎngjiu ma?\nWúlùn shuǐwēn, cháyè yòngliàng háishì chōngpào shíjiān dōu yǒu yángé de yāoqiú, zhè zhèng shì cháyì xiūshēn yǎngxìng de mèilì suǒzài.",
                    dialogueVietnamese: "Người Trung Quốc khi tiếp khách, tại sao luôn thích pha một ấm trà nóng?\nTục ngữ có câu 'khách đến mời trà', trà không chỉ làm dịu cơn khát giải ngấy, mà còn đại diện cho sự kính trọng và nhiệt tình của chủ nhà.\nPha trà có cầu kỳ gì không?\nBất kể nhiệt độ nước, lượng trà hay thời gian hãm đều có yêu cầu nghiêm ngặt, đó chính là nét hấp dẫn tu thân dưỡng tính của trà đạo.",
                    vocabulary: [
                        SHZWordData(hanzi: "热情", pinyin: "rèqíng", sinoVietnamese: "Nhiệt tình", vietnameseMeaning: "Nhiệt tình, hiếu khách", exampleHanzi: "热情招待客人。", examplePinyin: "Rèqíng zhāodài kèrén.", exampleTranslation: "Nhiệt tình đón tiếp khách.", strokeCount: 20),
                        SHZWordData(hanzi: "无论", pinyin: "wúlùn", sinoVietnamese: "Vô luận", vietnameseMeaning: "Bất kể, dù cho", exampleHanzi: "无论刮风下雨。", examplePinyin: "Wúlùn guāfēng xiàyǔ.", exampleTranslation: "Bất kể mưa to gió lớn.", strokeCount: 11),
                        SHZWordData(hanzi: "文化", pinyin: "wénhuà", sinoVietnamese: "Văn hóa", vietnameseMeaning: "Văn hóa", exampleHanzi: "传统茶文化。", examplePinyin: "Chuántǒng chá wénhuà.", exampleTranslation: "Văn hóa trà truyền thống.", strokeCount: 8),
                        SHZWordData(hanzi: "严格", pinyin: "yángé", sinoVietnamese: "Nghiêm cách", vietnameseMeaning: "Nghiêm ngặt, khắt khe", exampleHanzi: "要求很严格。", examplePinyin: "Yāoqiú hěn yángé.", exampleTranslation: "Yêu cầu rất nghiêm ngặt.", strokeCount: 16)
                    ]
                )
            ]
        ),
        
        // MARK: - HSK 5: 发展汉语 · 高级综合 (Bài 1 -> Bài 4)
        SHZCourseData(
            level: 5,
            courseName: "Khóa học HSK 5",
            textbook: "发展汉语 · 高级综合",
            totalLessons: "Bài 1 → Bài 4 · 72 tiết",
            vocabTarget: "Khoảng 4.000 từ vựng chuyên sâu",
            grammarPointsCount: 150,
            lessons: [
                SHZLessonData(
                    id: "hsk5_b1",
                    lessonNumber: 1,
                    title: "Bài 1: 跨国商务谈判与合作 (Đàm phán thương mại quốc tế)",
                    topic: "Kinh tế, Hợp đồng, Đầu tư & Chiến lược kinh doanh",
                    summary: "Thuật ngữ đàm phán hợp đồng, phân chia lợi nhuận, giảm thiểu rủi ro và cấu trúc 鉴于 / 从而.",
                    grammarExplanation: "1. Liên từ 鉴于: Xuất phát từ, xét thấy... Ví dụ: 鉴于目前的市场行情 (Xét thấy tình hình thị trường hiện tại).\n2. Phó từ 从而: Từ đó, do đó... biểu thị kết quả logic.",
                    dialogueChinese: "李总，关于这次合资项目的股权比例，贵方还有什么补充意见吗？\n鉴于我方在核心技术与供应链方面的独家优势，我们希望将股份比例提升至百分之五十一，从而确保运营决策的高效。\n这个提议我们可以理解，但在利润分配机制上，我们需要更具体的风险保障条款。\n完全同意，互利共赢始终是我们跨国合作的根本宗旨。",
                    dialoguePinyin: "Lǐ zǒng, guānyú zhè cì hézī xiàngmù de gǔquán bǐlì, guìfāng hái yǒu shénme bǔchōng yìjiàn ma?\nJiànyú wǒfāng zài héxīn jìshù yǔ gōngyìngliàn fāngmiàn de dújiā yōushì, wǒmen xīwàng jiāng gǔfèn bǐlì tíshēng zhì bǎifēnzhī wǔshíyī, cóng'ér quèbǎo yùnyíng juécè de gāoxiào.\nZhège tíyì wǒmen kěyǐ lǐjiě, dàn zài lìrùn fēnpèi jīzhì shang, wǒmen xūyào gèng jùtǐ de fēngxiǎn bǎozhàng tiáokuǎn.\nWánquán tóngyì, hùlì gòngyíng shǐzhōng shì wǒmen kuàguó hézuò de gēnběn zōngzhǐ.",
                    dialogueVietnamese: "Thưa Giám đốc Lý, về tỷ lệ cổ phần trong dự án liên doanh lần này, quý công ty còn ý kiến bổ sung gì không?\nXét thấy thế mạnh độc quyền của chúng tôi về công nghệ cốt lõi và chuỗi cung ứng, chúng tôi muốn nâng tỷ lệ cổ phần lên 51%, từ đó đảm bảo hiệu quả quyết sách vận hành.\nĐề xuất này chúng tôi có thể hiểu được, nhưng về cơ chế phân chia lợi nhuận, chúng tôi cần các điều khoản bảo đảm rủi ro cụ thể hơn.\nHoàn toàn nhất trí, cùng thắng đôi bên luôn là tôn chỉ căn bản trong hợp tác xuyên quốc gia của chúng tôi.",
                    vocabulary: [
                        SHZWordData(hanzi: "谈判", pinyin: "tánpàn", sinoVietnamese: "Đàm phán", vietnameseMeaning: "Đàm phán, thương lượng", exampleHanzi: "进行商务谈判。", examplePinyin: "Jìnxíng shāngwù tánpàn.", exampleTranslation: "Tiến hành đàm phán thương mại.", strokeCount: 22),
                        SHZWordData(hanzi: "投资", pinyin: "tóuzī", sinoVietnamese: "Đầu tư", vietnameseMeaning: "Đầu tư vốn", exampleHanzi: "吸引外商投资。", examplePinyin: "Xīyǐn wàishāng tóuzī.", exampleTranslation: "Thu hút vốn đầu tư nước ngoài.", strokeCount: 16),
                        SHZWordData(hanzi: "利润", pinyin: "lìrùn", sinoVietnamese: "Lợi nhuận", vietnameseMeaning: "Lợi nhuận, tiền lãi", exampleHanzi: "追求合理利润。", examplePinyin: "Zhuīqiú hélǐ lìrùn.", exampleTranslation: "Theo đuổi lợi nhuận hợp lý.", strokeCount: 17),
                        SHZWordData(hanzi: "合同", pinyin: "hétong", sinoVietnamese: "Hợp đồng", vietnameseMeaning: "Hợp đồng kinh tế", exampleHanzi: "正式签订合同。", examplePinyin: "Zhèngshì qiāndìng hétong.", exampleTranslation: "Chính thức ký kết hợp đồng.", strokeCount: 12)
                    ]
                ),
                SHZLessonData(
                    id: "hsk5_b2",
                    lessonNumber: 2,
                    title: "Bài 2: 人工智能与未来社会的变革 (Trí tuệ nhân tạo và tương lai)",
                    topic: "Khoa học công nghệ, Trí tuệ nhân tạo & Cách mạng 4.0",
                    summary: "Phân tích tác động của AI đối với thị trường lao động, đạo đức khoa học và tự động hóa.",
                    grammarExplanation: "1. Cấu trúc 不仅不...反而...: Không những không... trái lại còn...\n2. Giới từ 以...为基础: Lấy... làm cơ sở nền tảng.",
                    dialogueChinese: "随着大语言模型和具身智能的飞速突破，许多人开始担忧自己的岗位会被机器取代。\n这种焦虑可以理解，但从历史规律来看，科技创新不仅不会消灭就业，反而会催生出大量全新的高端需求。\n那么面对这一轮变革，我们应该具备怎样的核心竞争力？\n机器擅长处理既定逻辑与海量数据，而人类的批判性思维、跨学科综合判断力与情感共鸣能力，才是无法被算法替代的独特价值。",
                    dialoguePinyin: "Suízhe dà yǔyán móxíng hé jùshēn zhìnéng de fēisù tūpò, xǔduō rén kāishǐ dānyōu zìjǐ de gǎngwèi huì bèi jīqì qǔdài.\nZhè zhǒng jiāolǜ kěyǐ lǐjiě, dàn cóng lìshǐ guīlǜ lái kàn, kējì chuàngxīn bùjǐn bú huì xiāomiè jiùyè, fǎn'ér huì cuīshēng chū dàliàng quánxīn de gāoduān xūqiú.\nNàme miànduì zhè yì lún biàngé, wǒmen yīnggāi jùbèi zěnyàng de héxīn jìngzhēnglì?\nJīqì shàncháng chǔlǐ jìdìng luóji yǔ hǎiliàng shùjù, ér rénlèi de pīpànxìng sīwéi, kuàxuékē zōnghé pànduànlì yǔ qínggǎn gòngmíng nénglì, cái shì wúfǎ bèi suànfǎ tìdài de dútè jiàzhí.",
                    dialogueVietnamese: "Cùng với sự bứt phá thần tốc của các mô hình ngôn ngữ lớn và trí tuệ nhân tạo, nhiều người bắt đầu lo âu công việc của mình sẽ bị máy móc thay thế.\nNỗi âu lo này có thể hiểu được, nhưng nhìn từ quy luật lịch sử, đổi mới công nghệ không những không tiêu diệt việc làm, mà trái lại còn sản sinh ra hàng loạt nhu cầu cao cấp mới toanh.\nVậy đứng trước làn sóng đổi thay này, chúng ta cần trang bị năng lực cạnh tranh cốt lõi nào?\nMáy móc giỏi xử lý logic sẵn có và dữ liệu khổng lồ, còn tư duy phản biện, óc phán đoán liên ngành và năng lực đồng cảm cảm xúc của con người mới là giá trị độc bản không thuật toán nào thay thế nổi.",
                    vocabulary: [
                        SHZWordData(hanzi: "人工智能", pinyin: "réngōng zhìnéng", sinoVietnamese: "Nhân công trí năng", vietnameseMeaning: "Trí tuệ nhân tạo (AI)", exampleHanzi: "人工智能技术飞速发展。", examplePinyin: "Réngōng zhìnéng jìshù fēisù fāzhǎn.", exampleTranslation: "Công nghệ AI phát triển phi mã.", strokeCount: 26),
                        SHZWordData(hanzi: "突破", pinyin: "tūpò", sinoVietnamese: "Đột phá", vietnameseMeaning: "Đột phá, bứt phá", exampleHanzi: "取得重大突破。", examplePinyin: "Qǔdé zhòngdà tūpò.", exampleTranslation: "Đạt được bước đột phá quan trọng.", strokeCount: 16),
                        SHZWordData(hanzi: "创新", pinyin: "chuàngxīn", sinoVietnamese: "Sáng tân", vietnameseMeaning: "Đổi mới sáng tạo", exampleHanzi: "科技创新。", examplePinyin: "Kējì chuàngxīn.", exampleTranslation: "Đổi mới công nghệ.", strokeCount: 19),
                        SHZWordData(hanzi: "取代", pinyin: "qǔdài", sinoVietnamese: "Thủ đại", vietnameseMeaning: "Thay thế, đoạt chỗ", exampleHanzi: "无法被取代。", examplePinyin: "Wúfǎ bèi qǔdài.", exampleTranslation: "Không thể bị thay thế.", strokeCount: 13)
                    ]
                ),
                SHZLessonData(
                    id: "hsk5_b3",
                    lessonNumber: 3,
                    title: "Bài 3: 情绪管理与心理弹性 (Quản trị cảm xúc và tâm lý)",
                    topic: "Tâm lý học ứng dụng, Trí tuệ cảm xúc EQ & Áp lực",
                    summary: "Kiểm soát căng thẳng, nuôi dưỡng trạng thái tinh thần tích cực và liên từ 与其...不如...",
                    grammarExplanation: "1. Cấu trúc 与其...不如...: Thà rằng... còn hơn là... Ví dụ: 与其抱怨环境，不如改变自己.\n2. Cấu trúc 旨在: Nhằm mục đích, với tôn chỉ là...",
                    dialogueChinese: "现代职场节奏这么快，很多人常常感到精力透支、情绪崩溃。\n心理学研究表明，长期的慢性焦虑大多源于我们对'未知结果'的过度担忧与失控感。\n如果陷入这种负面情绪循环，最好的自我调节方法是什么？\n与其在无休止的内耗中焦虑不安，不如立刻着手做一件具体微小的事，通过微小的确定性重新找回对生活的掌控感。",
                    dialoguePinyin: "Xiàndài zhíchǎng jiézòu zhème kuài, hěn duō rén chángcháng gǎndào jīnglì tòuzhī, qíngxù bēngkuì.\nXīnlǐxué yánjiū biǎomíng, chángqī de mànxìng jiāolǜ dàduō yuányú wǒmen duì 'wèizhī jiéguǒ' de guòdù dānyōu yǔ shīkònggǎn.\nRúguǒ xiànrù zhè zhǒng fùmiàn qíngxù xúnhuán, zuì hǎo de zìwǒ tiáojié fāngfǎ shì shénme?\nYǔqí zài wúxiūzhǐ de nèihào zhōng jiāolǜ bù'ān, bùrú lìkè zhuóshǒu zuò yí jiàn jùtǐ wēixiǎo de shì, tōngguò wēixiǎo de quèdìngxìng chóngxīn zhǎohuí duì shēnghuó de zhǎngkònggǎn.",
                    dialogueVietnamese: "Nhịp sống công sở hiện đại nhanh như vậy, rất nhiều người thường xuyên cảm thấy cạn kiệt năng lượng, suy sụp tinh thần.\nNghiên cứu tâm lý học chỉ ra rằng, lo âu mãn tính kéo dài phần lớn bắt nguồn từ sự lo lắng thái quá và cảm giác mất kiểm soát đối với 'kết quả bất định'.\nNếu rơi vào vòng xoáy cảm xúc tiêu cực này, cách tự điều tiết tốt nhất là gì?\nThà rằng ngay lập tức bắt tay vào làm một việc nhỏ bé cụ thể, còn hơn là cứ bất an lo âu trong sự hao tổn nội tâm bất tận, thông qua sự chắc chắn nhỏ bé để lấy lại quyền làm chủ cuộc đời.",
                    vocabulary: [
                        SHZWordData(hanzi: "情绪", pinyin: "qíngxù", sinoVietnamese: "Tình tự", vietnameseMeaning: "Cảm xúc, tâm trạng", exampleHanzi: "稳定情绪。", examplePinyin: "Wěndìng qíngxù.", exampleTranslation: "Ổn định cảm xúc.", strokeCount: 22),
                        SHZWordData(hanzi: "焦虑", pinyin: "jiāolǜ", sinoVietnamese: "Tiêu lự", vietnameseMeaning: "Lo âu, bồn chồn", exampleHanzi: "缓解焦虑。", examplePinyin: "Huǎnjiě jiāolǜ.", exampleTranslation: "Xoa dịu sự lo âu.", strokeCount: 26),
                        SHZWordData(hanzi: "调节", pinyin: "tiáojié", sinoVietnamese: "Điều tiết", vietnameseMeaning: "Điều hòa, điều chỉnh", exampleHanzi: "自我调节心态。", examplePinyin: "Zìwǒ tiáojié xīntài.", exampleTranslation: "Tự điều chỉnh tâm thái.", strokeCount: 20),
                        SHZWordData(hanzi: "积极", pinyin: "jījí", sinoVietnamese: "Tích cực", vietnameseMeaning: "Tích cực, hăng hái", exampleHanzi: "保持积极乐观。", examplePinyin: "Bǎochí jījí lèguān.", exampleTranslation: "Giữ tinh thần tích cực lạc quan.", strokeCount: 16)
                    ]
                ),
                SHZLessonData(
                    id: "hsk5_b4",
                    lessonNumber: 4,
                    title: "Bài 4: 东方哲学与中庸之道 (Triết học phương Đông và Trung Dung)",
                    topic: "Tư tưởng Nho gia, Đạo gia & Văn hóa nhân sinh",
                    summary: "Tìm hiểu tư tưởng Khổng Tử, Lão Tử, phép ứng xử dĩ hòa vi quý và cấu trúc 所谓...",
                    grammarExplanation: "1. Từ ngữ 所谓: Cái gọi là... Ví dụ: 所谓中庸，并非无原则妥协 (Cái gọi là Trung Dung không phải thỏa hiệp vô nguyên tắc).\n2. Cấu trúc 亦...亦...: Vừa... lại vừa...",
                    dialogueChinese: "中国传统文化中常提到'中庸之道'，这究竟是一种怎样的处世哲学？\n所谓'中庸'，绝非许多人误解的毫无原则的妥协退让，而是在极端矛盾中寻求最恰当、最适度的动态平衡。\n这种哲学在当代复杂的人际交往中，能给我们带来什么启发？\n古人讲'过犹不及'。行事不偏不倚，既坚持内心的道德底线，又通权达变、包容异见，方能在风云变幻的社会中立于不败之地。",
                    dialoguePinyin: "Zhōngguó chuántǒng wénhuà zhōng cháng tídào 'zhōngyōng zhī dào', zhè jiūjìng shì yì zhǒng zěnyàng de chǔshì zhéxué?\nSuǒwèi 'zhōngyōng', juéfēi xǔduō rén wùjiě de háo wú yuánzé de tuǒxié tuìràng, ér shì zài jíduān máodùn zhōng xúnqiú zuì qiàdàng, zuì shìdù de dòngtài pínghéng.\nZhè zhǒng zhéxué zài dāngdài fùzá de rénjì jiāowǎng zhōng, néng gěi wǒmen dàilái shénme qǐfā?\nGǔrén jiǎng 'guòyóubùjí'. Xíngshì bùpiānbùyǐ, jì jiānchí nèixīn de dàodé dǐxiàn, yòu tōngquándàbiàn, bāoróng yìjiàn, fāng néng zài fēngyún biànhuàn de shèhuì zhōng lì yú búbài zhī dì.",
                    dialogueVietnamese: "Trong văn hóa truyền thống Trung Hoa thường nhắc đến 'đạo Trung Dung', rốt cuộc đây là một triết lý xử thế như thế nào?\nCái gọi là 'Trung Dung' tuyệt đối không phải sự thỏa hiệp nhượng bộ vô nguyên tắc như nhiều người lầm tưởng, mà là tìm kiếm điểm cân bằng động thỏa đáng và vừa vặn nhất giữa các mâu thuẫn đối cực.\nTriết lý này trong giao tiếp nhân sinh phức tạp thời nay có thể đem lại gợi ý gì cho chúng ta?\nCổ nhân nói 'quá do bất cập' (làm quá cũng như chưa tới). Hành sự không thiên lệch, vừa kiên định lằn ranh đạo đức trong tâm, lại vừa tùy cơ ứng biến, bao dung ý kiến trái chiều, mới có thể vững vàng bất bại giữa xã hội biến ảo khôn lường.",
                    vocabulary: [
                        SHZWordData(hanzi: "哲学", pinyin: "zhéxué", sinoVietnamese: "Triết học", vietnameseMeaning: "Triết học, đạo lý", exampleHanzi: "东方哲学思想。", examplePinyin: "Dōngfāng zhéxué sīxiǎng.", exampleTranslation: "Tư tưởng triết học phương Đông.", strokeCount: 20),
                        SHZWordData(hanzi: "平衡", pinyin: "pínghéng", sinoVietnamese: "Bình hành", vietnameseMeaning: "Cân bằng, thăng bằng", exampleHanzi: "保持心理平衡。", examplePinyin: "Bǎochí xīnlǐ pínghéng.", exampleTranslation: "Giữ cân bằng tâm lý.", strokeCount: 21),
                        SHZWordData(hanzi: "道德", pinyin: "dàodé", sinoVietnamese: "Đạo đức", vietnameseMeaning: "Đạo đức, phẩm hạnh", exampleHanzi: "遵守职业道德。", examplePinyin: "Zūnshǒu zhíyè dàodé.", exampleTranslation: "Tuân thủ đạo đức nghề nghiệp.", strokeCount: 27),
                        SHZWordData(hanzi: "原则", pinyin: "yuánzé", sinoVietnamese: "Nguyên tắc", vietnameseMeaning: "Nguyên tắc, chuẩn tắc", exampleHanzi: "坚持做人的原则。", examplePinyin: "Jiānchí zuòrén de yuánzé.", exampleTranslation: "Kiên định nguyên tắc làm người.", strokeCount: 13)
                    ]
                )
            ]
        )
    ]
    
    /// Toàn bộ danh sách từ vựng từ tất cả các khóa học
    public static var allWordsList: [SHZWordData] {
        var list: [SHZWordData] = []
        for course in allCourses {
            for lesson in course.lessons {
                list.append(contentsOf: lesson.vocabulary)
            }
        }
        return list
    }
}
