//
//  SHZCurriculumDatabase.swift
//  HanLearn
//
//  Created by Senior iOS Architect.
//  Lộ trình học HSK 3.0 chuẩn SHZ: Hội Thông Hán Ngữ (会通汉语) & Phát Triển Hán Ngữ (发展汉语)
//  72 tiết/khóa chuẩn quốc tế - HSK 1 đến HSK 6
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
        // MARK: - HSK 1: 会通汉语 · 应用汉语 1 (Bài 1 -> Bài 4)
        SHZCourseData(
            level: 1,
            courseName: "Khóa học HSK 1",
            textbook: "会通汉语 · 应用汉语 1",
            totalLessons: "Bài 1 → Bài 4 · 72 tiết",
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
                    grammarExplanation: "1. Động từ 有 biểu thị sở hữu: 'Chủ ngữ + 有 + Tân ngữ'. Dạng phủ định là 没有 (không dùng 不有).\n2. Lượng từ 口: Chuyên dùng để đếm nhân khẩu trong gia đình: '我家有五口人'.\n3. Trợ từ sở hữu 的: 'Danh từ 1 + 的 + Danh từ 2' (của). Ví dụ: 我的爸爸 (Bố của tôi). Khi quan hệ thân thuộc có thể lược bỏ 的.",
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
                        SHZWordData(hanzi: "喜欢", pinyin: "xǐhuan", sinoVietnamese: "Hỉ hoan", vietnameseMeaning: "Thích, yêu thích", exampleHanzi: "我喜欢中国菜。", examplePinyin: "Wǒ xǐhuan Zhōngguó cài.", exampleTranslation: "Tôi thích món ăn Trung Quốc.", strokeCount: 18),
                        SHZWordData(hanzi: "岁", pinyin: "suì", sinoVietnamese: "Tuế", vietnameseMeaning: "Tuổi", exampleHanzi: "我二十岁。", examplePinyin: "Wǒ èrshí suì.", exampleTranslation: "Tôi hai mươi tuổi.", strokeCount: 13),
                        SHZWordData(hanzi: "看书", pinyin: "kànshū", sinoVietnamese: "Khán thư", vietnameseMeaning: "Đọc sách", exampleHanzi: "他在房间看书。", examplePinyin: "Tā zài fángjiān kànshū.", exampleTranslation: "Anh ấy đang đọc sách trong phòng.", strokeCount: 19)
                    ]
                ),
                SHZLessonData(
                    id: "hsk1_b3",
                    lessonNumber: 3,
                    title: "Bài 3: 你每天几点起床？ (Mỗi ngày bạn mấy giờ thức dậy?)",
                    topic: "Thời gian, Lịch trình & Hoạt động hàng ngày",
                    summary: "Diễn đạt giờ giấc, thời gian trong ngày (sáng, trưa, tối), lịch sinh hoạt và các hoạt động ăn uống.",
                    grammarExplanation: "1. Cách nói giờ: 'Số + 点 + (Số) + 分'. Ví dụ: 7点30分 (7 giờ 30 phút).\n2. Trật tự từ chỉ thời gian: Từ lớn đến nhỏ (Năm -> Tháng -> Ngày -> Buổi -> Giờ). Trạng ngữ chỉ thời gian đứng trước vị ngữ hoặc đứng đầu câu.\n3. Cấu trúc 几点: Dùng để hỏi mấy giờ. Ví dụ: 你几点吃饭？",
                    dialogueChinese: "现在几点了？\n现在早上七点半。\n你每天几点起床？\n我每天六点半起床，七点吃早饭。\n你几点去上学？\n八点去学校。下午五点回家，晚上十点半睡觉。",
                    dialoguePinyin: "Xiànzài jǐ diǎn le?\nXiànzài zǎoshang qī diǎn bàn.\nNǐ měitiān jǐ diǎn qǐchuáng?\nWǒ měitiān liù diǎn bàn qǐchuáng, qī diǎn chī zǎofàn.\nNǐ jǐ diǎn qù shàngxué?\nBā diǎn qù xuéxiào. Xiàwǔ wǔ diǎn huí jiā, wǎnshang shí diǎn bàn shuìjiào.",
                    dialogueVietnamese: "Bây giờ là mấy giờ rồi?\nBây giờ là 7 giờ rưỡi sáng.\nMỗi ngày bạn thức dậy lúc mấy giờ?\nMỗi ngày tôi dậy lúc 6 rưỡi, 7 giờ ăn sáng.\nMấy giờ bạn đi học?\n8 giờ đi đến trường. 5 giờ chiều về nhà, 10 rưỡi tối đi ngủ.",
                    vocabulary: [
                        SHZWordData(hanzi: "现在", pinyin: "xiànzài", sinoVietnamese: "Hiện tại", vietnameseMeaning: "Bây giờ, hiện tại", exampleHanzi: "现在八点。", examplePinyin: "Xiànzài bā diǎn.", exampleTranslation: "Bây giờ là 8 giờ.", strokeCount: 14),
                        SHZWordData(hanzi: "点", pinyin: "diǎn", sinoVietnamese: "Điểm", vietnameseMeaning: "Giờ (trên đồng hồ)", exampleHanzi: "三点见。", examplePinyin: "Sān diǎn jiàn.", exampleTranslation: "3 giờ gặp nhé.", strokeCount: 9),
                        SHZWordData(hanzi: "起床", pinyin: "qǐchuáng", sinoVietnamese: "Khởi sàng", vietnameseMeaning: "Thức dậy, rời giường", exampleHanzi: "快起床吧！", examplePinyin: "Kuài qǐchuáng ba!", exampleTranslation: "Dậy mau thôi nào!", strokeCount: 17),
                        SHZWordData(hanzi: "早饭", pinyin: "zǎofàn", sinoVietnamese: "Tảo phạn", vietnameseMeaning: "Bữa sáng, điểm tâm", exampleHanzi: "你吃早饭了吗？", examplePinyin: "Nǐ chī zǎofàn le ma?", exampleTranslation: "Bạn ăn sáng chưa?", strokeCount: 15),
                        SHZWordData(hanzi: "睡觉", pinyin: "shuìjiào", sinoVietnamese: "Thụy giác", vietnameseMeaning: "Đi ngủ", exampleHanzi: "我想睡觉了。", examplePinyin: "Wǒ xiǎng shuìjiào le.", exampleTranslation: "Tôi muốn đi ngủ rồi.", strokeCount: 22),
                        SHZWordData(hanzi: "每天", pinyin: "měitiān", sinoVietnamese: "Mỗi thiên", vietnameseMeaning: "Mỗi ngày, hàng ngày", exampleHanzi: "我每天学汉语。", examplePinyin: "Wǒ měitiān xué Hànyǔ.", exampleTranslation: "Mỗi ngày tôi đều học tiếng Trung.", strokeCount: 11),
                        SHZWordData(hanzi: "上午", pinyin: "shàngwǔ", sinoVietnamese: "Thượng ngọ", vietnameseMeaning: "Buổi sáng (trước 12h)", exampleHanzi: "上午有课。", examplePinyin: "Shàngwǔ yǒu kè.", exampleTranslation: "Buổi sáng có tiết học.", strokeCount: 7),
                        SHZWordData(hanzi: "晚上", pinyin: "wǎnshang", sinoVietnamese: "Vãn thượng", vietnameseMeaning: "Buổi tối", exampleHanzi: "晚上好！", examplePinyin: "Wǎnshang hǎo!", exampleTranslation: "Chào buổi tối!", strokeCount: 14)
                    ]
                ),
                SHZLessonData(
                    id: "hsk1_b4",
                    lessonNumber: 4,
                    title: "Bài 4: 一共多少钱 (Tổng cộng hết bao nhiêu tiền?)",
                    topic: "Mua sắm, Giá cả, Màu sắc & Kích cỡ",
                    summary: "Giao tiếp hỏi giá tại chợ và siêu thị, mặc cả đơn giản, chọn màu sắc và kích cỡ quần áo.",
                    grammarExplanation: "1. Đơn vị tiền tệ: 块 (tệ - văn nói) / 元 (văn viết), 毛 (hào) / 角, 分 (xu).\n2. Cấu trúc hỏi giá: 'Cái này/Cái kia + 多少钱？'. Ví dụ: 这个多少钱？\n3. Phó từ 太...了 biểu thị cảm thán hoặc mức độ quá: 太贵了！(Đắt quá rồi!).\n4. Từ 一共 (Tổng cộng): Đứng trước số từ để tổng kết.",
                    dialogueChinese: "你好！请问这个苹果怎么卖？\n五块钱一斤，很甜的。\n太贵了，四块钱可以吗？\n好吧，你要几斤？\n我要三斤。这件衣服多少钱？\n八十块一件。\n一共多少钱？\n三斤苹果十二块，加衣服一共九十二块。",
                    dialoguePinyin: "Nǐ hǎo! Qǐngwèn zhège píngguǒ zěnme mài?\nWǔ kuài qián yì jīn, hěn tián de.\nTài guì le, sì kuài qián kěyǐ ma?\nHǎo ba, nǐ yào jǐ jīn?\nWǒ yào sān jīn. Zhè jiàn yīfu duōshao qián?\nBāshí kuài yí jiàn.\nYígòng duōshao qián?\nSān jīn píngguǒ shí'èr kuài, jiā yīfu yígòng jiǔshí'èr kuài.",
                    dialogueVietnamese: "Xin chào! Cho hỏi táo này bán thế nào?\n5 tệ một cân, ngọt lắm.\nĐắt quá, 4 tệ được không?\nĐược thôi, bạn muốn mấy cân?\nTôi lấy 3 cân. Bộ đồ này bao nhiêu tiền?\n80 tệ một bộ.\nTổng cộng hết bao nhiêu tiền?\n3 cân táo 12 tệ, cộng với quần áo tổng cộng là 92 tệ.",
                    vocabulary: [
                        SHZWordData(hanzi: "钱", pinyin: "qián", sinoVietnamese: "Tiền", vietnameseMeaning: "Tiền", exampleHanzi: "我没有钱。", examplePinyin: "Wǒ méiyǒu qián.", exampleTranslation: "Tôi không có tiền.", strokeCount: 10),
                        SHZWordData(hanzi: "多少", pinyin: "duōshao", sinoVietnamese: "Đa thiểu", vietnameseMeaning: "Bao nhiêu", exampleHanzi: "这件多少钱？", examplePinyin: "Zhè jiàn duōshao qián?", exampleTranslation: "Chiếc này bao nhiêu tiền?", strokeCount: 10),
                        SHZWordData(hanzi: "块", pinyin: "kuài", sinoVietnamese: "Khối", vietnameseMeaning: "Đồng, tệ (đơn vị tiền tệ)", exampleHanzi: "十块钱。", examplePinyin: "Shí kuài qián.", exampleTranslation: "10 đồng tệ.", strokeCount: 7),
                        SHZWordData(hanzi: "买", pinyin: "mǎi", sinoVietnamese: "Mãi", vietnameseMeaning: "Mua", exampleHanzi: "我想买书。", examplePinyin: "Wǒ xiǎng mǎi shū.", exampleTranslation: "Tôi muốn mua sách.", strokeCount: 6),
                        SHZWordData(hanzi: "苹果", pinyin: "píngguǒ", sinoVietnamese: "Bình quả", vietnameseMeaning: "Quả táo", exampleHanzi: "苹果很好吃。", examplePinyin: "Píngguǒ hěn hǎochī.", exampleTranslation: "Táo rất ngon.", strokeCount: 8),
                        SHZWordData(hanzi: "贵", pinyin: "guì", sinoVietnamese: "Quý", vietnameseMeaning: "Đắt, quý báu", exampleHanzi: "太贵了！", examplePinyin: "Tài guì le!", exampleTranslation: "Đắt quá!", strokeCount: 9),
                        SHZWordData(hanzi: "便宜", pinyin: "piányi", sinoVietnamese: "Tiện nghi", vietnameseMeaning: "Rẻ, giá cả phải chăng", exampleHanzi: "能便宜一点吗？", examplePinyin: "Néng piányi yìdiǎn ma?", exampleTranslation: "Có thể rẻ hơn một chút không?", strokeCount: 11),
                        SHZWordData(hanzi: "一共", pinyin: "yígòng", sinoVietnamese: "Nhất cộng", vietnameseMeaning: "Tổng cộng", exampleHanzi: "一共一百块。", examplePinyin: "Yígòng yìbǎi kuài.", exampleTranslation: "Tổng cộng 100 tệ.", strokeCount: 7),
                        SHZWordData(hanzi: "衣服", pinyin: "yīfu", sinoVietnamese: "Y phục", vietnameseMeaning: "Quần áo", exampleHanzi: "新衣服很漂亮。", examplePinyin: "Xīn yīfu hěn piàoliang.", exampleTranslation: "Quần áo mới rất đẹp.", strokeCount: 14)
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
                    title: "Bài 5: 你去那儿干什么？ (Bạn đến đó làm gì?)",
                    topic: "Sở thích & Hoạt động cuối tuần",
                    summary: "Diễn tả mục đích hành động, câu liên động, các môn thể thao và giải trí.",
                    grammarExplanation: "1. Câu liên động biểu thị mục đích: 'Chủ ngữ + 去 / 来 + Nơi chốn + Làm gì'. Ví dụ: 我去图书馆看书 (Tôi đi thư viện đọc sách).\n2. Cấu trúc 跟...一起: 'Chủ ngữ + 跟 + Người nào đó + 一起 + Động từ'. Ví dụ: 我跟他一起去.",
                    dialogueChinese: "周末你打算做什么？\n我想去体育馆踢足球。你去那儿干什么？\n我去图书馆借书。你跟谁一起去？\n我跟大卫一起去。踢完球我们去看电影，你想来吗？\n好啊，我也很想看那部新电影！",
                    dialoguePinyin: "Zhōumò nǐ dǎsuàn zuò shénme?\nWǒ xiǎng qù tǐyùguǎn tī zúqiú. Nǐ qù nàr gàn shénme?\nWǒ qù túshūguǎn jiè shū. Nǐ gēn shéi yìqǐ qù?\nWǒ gēn Dàwèi yìqǐ qù. Tī wán qiú wǒmen qù kàn diànyǐng, nǐ xiǎng lái ma?\nHǎo a, wǒ yě hěn xiǎng kàn nà bù xīn diànyǐng!",
                    dialogueVietnamese: "Cuối tuần bạn dự định làm gì?\nTôi muốn đến nhà thi đấu đá bóng. Bạn đến đó làm gì?\nTôi đến thư viện mượn sách. Bạn đi cùng ai thế?\nTôi đi cùng David. Đá bóng xong chúng tôi đi xem phim, bạn muốn đi cùng không?\nĐược chứ, tôi cũng rất muốn xem bộ phim mới đó!",
                    vocabulary: [
                        SHZWordData(hanzi: "打算", pinyin: "dǎsuàn", sinoVietnamese: "Đả toán", vietnameseMeaning: "Dự định, kế hoạch", exampleHanzi: "你有什么打算？", examplePinyin: "Nǐ yǒu shénme dǎsuàn?", exampleTranslation: "Bạn có dự định gì?", strokeCount: 12),
                        SHZWordData(hanzi: "踢足球", pinyin: "tī zúqiú", sinoVietnamese: "Thích túc cầu", vietnameseMeaning: "Đá bóng", exampleHanzi: "我们一起踢足球吧。", examplePinyin: "Wǒmen yìqǐ tī zúqiú ba.", exampleTranslation: "Chúng ta cùng nhau đá bóng nhé.", strokeCount: 29),
                        SHZWordData(hanzi: "电影", pinyin: "diànyǐng", sinoVietnamese: "Điện ảnh", vietnameseMeaning: "Phim, điện ảnh", exampleHanzi: "这部电影很好看。", examplePinyin: "Zhè bù diànyǐng hěn hǎokàn.", exampleTranslation: "Bộ phim này rất hay.", strokeCount: 14),
                        SHZWordData(hanzi: "运动", pinyin: "yùndòng", sinoVietnamese: "Vận động", vietnameseMeaning: "Thể thao, vận động", exampleHanzi: "每天运动身体好。", examplePinyin: "Měitiān yùndòng shēntǐ hǎo.", exampleTranslation: "Vận động mỗi ngày tốt cho sức khỏe.", strokeCount: 16)
                    ]
                ),
                SHZLessonData(
                    id: "hsk2_b8",
                    lessonNumber: 8,
                    title: "Bài 8: 今天比昨天冷多了 (Hôm nay lạnh hơn hôm qua nhiều)",
                    topic: "Thời tiết, Khí hậu & Câu so sánh",
                    summary: "Làm chủ cấu trúc câu so sánh chữ 比 và các từ vựng thời tiết 4 mùa.",
                    grammarExplanation: "1. Câu so sánh chữ 比: 'A + 比 + B + Tính từ + (Mức độ)'. Ví dụ: 今天比昨天冷 (Hôm nay lạnh hơn hôm qua).\n2. Biểu thị chênh lệch lớn: Thêm 多了 hoặc 得多 sau tính từ. Ví dụ: 今天比昨天冷多了.\n3. Trợ từ ngữ khí 了 biểu thị sự biến đổi: 下雨了 (Mưa rồi).",
                    dialogueChinese: "今天天气怎么样？\n今天比昨天冷多了，外面还在下雨。\n你要出门吗？\n我要去超市买点东西。\n外面冷，多穿点衣服，别感冒了！\n好的，谢谢你！",
                    dialoguePinyin: "Jīntiān tiānqì zěnmeyàng?\nJīntiān bǐ zuótiān lěng duō le, wàimiàn hái zài xiàyǔ.\nNǐ yào chūmén ma?\nWǒ yào qù chāoshì mǎi diǎn dōngxi.\nWàimiàn lěng, duō chuān diǎn yīfu, bié gǎnmào le!\nHǎo de, xièxie nǐ!",
                    dialogueVietnamese: "Hôm nay thời tiết thế nào?\nHôm nay lạnh hơn hôm qua nhiều, bên ngoài vẫn đang mưa.\nBạn có ra ngoài không?\nTôi phải đến siêu thị mua chút đồ.\nBên ngoài lạnh, mặc thêm quần áo vào, đừng để bị cảm lạnh nhé!\nĐược rồi, cảm ơn bạn nhé!",
                    vocabulary: [
                        SHZWordData(hanzi: "比", pinyin: "bǐ", sinoVietnamese: "Tỷ", vietnameseMeaning: "So với, hơn (so sánh)", exampleHanzi: "他比我大。", examplePinyin: "Tā bǐ wǒ dà.", exampleTranslation: "Anh ấy lớn hơn tôi.", strokeCount: 4),
                        SHZWordData(hanzi: "天气", pinyin: "tiānqì", sinoVietnamese: "Thiên khí", vietnameseMeaning: "Thời tiết", exampleHanzi: "今天天气真好！", examplePinyin: "Jīntiān tiānqì zhēn hǎo!", exampleTranslation: "Thời tiết hôm nay thật đẹp!", strokeCount: 10),
                        SHZWordData(hanzi: "冷", pinyin: "lěng", sinoVietnamese: "Lãnh", vietnameseMeaning: "Lạnh", exampleHanzi: "冬天很冷。", examplePinyin: "Dōngtiān hěn lěng.", exampleTranslation: "Mùa đông rất lạnh.", strokeCount: 7),
                        SHZWordData(hanzi: "下雨", pinyin: "xiàyǔ", sinoVietnamese: "Hạ vũ", vietnameseMeaning: "Mưa, trời mưa", exampleHanzi: "外面下雨了。", examplePinyin: "Wàimiàn xiàyǔ le.", exampleTranslation: "Bên ngoài trời mưa rồi.", strokeCount: 11)
                    ]
                )
            ]
        )
    ]
}
