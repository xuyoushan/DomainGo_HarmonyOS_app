export interface CultureStory {
  title: string;
  tag: string;      // 类别：如 非遗 / 民俗 / 艺术 / 典故
  content: string;  // 详细的故事介绍文案
  coverImage: Resource;  // 沉浸式意境大图
  accentColor: string;   // 氛围主题色（十六进制）
  quote: string;         // 灵魂文案：用于首屏的视觉呼吸感
}

export interface SpecialtyItem {
  id: number;
  name: string;
  price: string;    // 参考价格区间
  desc: string;     // 产品描述
  buyTip: string;   // 购买建议或挑选技巧
  image: Resource;  // 特产实物图片
  highlight: string; // 卖点句
}
export interface CityCultureSpecialty {
  cultureStories: CultureStory[];
  specialtyFoods: SpecialtyItem[];
}
export const CULTURE_SPECIALTY_MAP: Record<string, CityCultureSpecialty> = {
  "武汉市": {
    cultureStories: [
      {
        title: "汉绣",
        tag: "国家级非遗",
        content: "汉绣以“铺、压、织、锁、扣、盘、套”等针法见长，色彩浓艳，构图满密。它起源于楚绣，不仅是技艺，更是荆楚大地色彩审美的集中体现。",
        coverImage: $r('app.media.hanxiu'),
        accentColor: "#E63946", // 朱砂红
        quote: "一针一线，绣出荆楚三千年的浓墨重彩。"
      },
      {
        title: "高龙",
        tag: "民俗活动",
        content: "武汉汉阳一带独有的舞龙形式，龙体竖立，舞者以肩扛、头顶、齿衔，姿态雄壮。每逢元宵，火流星飞舞，场面极度壮观。",
        coverImage: $r('app.media.gaolong'),
        accentColor: "#FFB703", // 金盏黄
        quote: "脊梁顶起乾坤，火光中舞动的是不屈的城市魂。"
      },
      {
        title: "伯牙子期",
        tag: "文化典故",
        content: "知音文化的源头。归元寺旁的古琴台，讲述了“高山流水觅知音”的千古绝唱，构成了这座城市重情重义的精神底色。",
        coverImage: $r('app.media.zhiyin'),
        accentColor: "#2A9D8F", // 黛蓝色
        quote: "山水有相逢，万籁俱寂处，总有一曲知音响。"
      },
      {
        title: "黄鹤诗情",
        tag: "人文坐标",
        content: "“昔人已乘黄鹤去”。黄鹤楼不仅是地理坐标，更是中国诗歌文化的巅峰交汇点，承载着江城千年的浪漫与登高远望的胸怀。",
        coverImage: $r('app.media.huanghelou'),
        accentColor: "#8D99AE",
        quote: "一楼立江岸，载得起半部唐诗，也装得下万里云烟。"
      },
      {
        title: "过早文化",
        tag: "市井民俗",
        content: "“过早”在武汉不仅是早餐，更是一种生活仪式。热干面、豆皮、面窝，在晨雾缭绕的街头，这种烟火气构成了武汉人性格中最坚韧、活泼的一面。",
        coverImage: $r('app.media.guozao'),
        accentColor: "#F8961E",
        quote: "一碗烟火气，足以慰平生"
      }
    ],
    specialtyFoods: [
      {
        id: 1,
        name: "蔡林记热干面礼盒",
        price: "￥29 - ￥58",
        highlight: "把一碗地道的武汉早晨，装进礼盒里",
        desc: "选用优质碱面与秘制黑芝麻酱，经过多道工序复刻店头口感，是把“武汉过早”带回家的首选。",
        buyTip: "建议选择配有料包较全的礼盒，注意查看芝麻酱的保质期。",
        image: $r('app.media.food_rgm')
      },
      {
        id: 2,
        name: "精武/周黑鸭",
        price: "￥35 - ￥120",
        highlight: "麻辣与甜辣双流派代表，一口吃懂武汉鸭脖江湖",
        desc: "武汉鸭脖以麻、辣、鲜、香、甜著称。皮黑肉嫩，骨髓入味，是极佳的休闲零食。",
        buyTip: "真空包装适合远途携带，锁鲜装口感更好但保质期短（通常5-7天）。",
        image: $r('app.media.food_yabo')
      },
      {
        id: 3,
        name: "黄陂荆蜜",
        price: "￥45 - ￥80",
        highlight: "荆楚山野里，时间酿出来的甜",
        desc: "中国四大名蜜之一，色泽琥珀，气味清香，含有丰富的维生素和矿物质。",
        buyTip: "认准地理标志保护产品认证，纯正荆蜜久置会有细密结晶。",
        image: $r('app.media.food_honey')
      },
      {
        id: 4,
        name: "武昌鱼",
        price: "￥58 - ￥158",
        desc: "因毛主席诗句名扬天下，肉质细嫩、脂肪适中，真空半成品方便携带和烹饪。",
        buyTip: "选有QS认证品牌，冷冻品需冷链保存。",
        image: $r('app.media.wuchangyu'),
        highlight: "一江春水鲜，一鱼武昌香"
      },
      {
        id: 5,
        name: "五芳斋汤圆/粽子",
        price: "￥32 - ￥88",
        desc: "武汉百年老字号，汤圆皮薄馅足，粽子米香浓郁，是传统节令美食。",
        buyTip: "汤圆建议选冷冻装，保质期约12个月；粽子真空装保质期约9个月，按需选甜咸。",
        image: $r('app.media.wufangzhai'),
        highlight: "软糯香甜，藏着老武汉的年味"
      }
    ]
  },
  "北京市": {
    cultureStories: [
      {
        title: "京剧",
        tag: "国家级非遗",
        content: "中国国粹，形成于清代乾隆年间，唱念做打俱全，扮相华美，是戏曲艺术的巅峰代表。",
        coverImage: $r('app.media.jingju'),
        accentColor: "#C92C2C",
        quote: "粉墨登场演悲欢，一唱一吟皆华夏。"
      },
      {
        title: "地坛庙会",
        tag: "民俗活动",
        content: "北京春节最具人气的传统庙会，集民俗表演、特色小吃、年货市集于一体，年味十足。",
        coverImage: $r('app.media.miaohui'),
        accentColor: "#E64A19",
        quote: "一街年味浓，一庙盛景藏尽人间烟火。"
      },
      {
        title: "故宫传说",
        tag: "文化典故",
        content: "旧称紫禁城，明清两代皇家宫殿，红墙黄瓦之间藏着数百年的宫廷故事与历史传奇。",
        coverImage: $r('app.media.gugong'),
        accentColor: "#D4AF37",
        quote: "宫墙深几许，一砖一瓦都是岁月史书。"
      },
      {
        title: "景泰蓝",
        tag: "国家级非遗",
        content: "铜胎掐丝珐琅工艺，始于元代盛于明景泰年间，色彩绚丽华贵，曾为皇家专属御用工艺。",
        coverImage: $r('app.media.jingtailan'),
        accentColor: "#3A7BD5",
        quote: "匠心凝彩釉，一器藏尽东方雅韵。"
      },
      {
        title: "四合院",
        tag: "民俗文化",
        content: "北方经典民居代表，中轴对称围合院落，承载着传统家族伦理与浓郁京味生活气息。",
        coverImage: $r('app.media.siheyuan'),
        accentColor: "#A67C52",
        quote: "一院藏四季，烟火温柔守流年。"
      }
    ],
    specialtyFoods: [
      {
        id: 1,
        name: "全聚德烤鸭",
        price: "￥198 - ￥598",
        desc: "北京烤鸭代表品牌，果木炭烤皮酥肉嫩，礼盒内含饼酱葱丝全套配件。",
        buyTip: "优先选现烤真空装，用烤箱复烤，口感最接近堂食。",
        image: $r('app.media.kaoya'),
        highlight: "一鸭三吃，香透京城岁月"
      },
      {
        id: 2,
        name: "六必居酱菜",
        price: "￥68 - ￥198",
        desc: "明代老字号酱菜，咸甜脆嫩开胃解腻，是老北京餐桌上经典佐餐小菜。",
        buyTip: "玻璃瓶密封更安心，开封后记得冷藏保存。",
        image: $r('app.media.jiangcai'),
        highlight: "一口酱菜，半朝京城滋味"
      },
      {
        id: 3,
        name: "稻香村糕点",
        price: "￥88 - ￥328",
        desc: "京式糕点代表，含驴打滚、豌豆黄、萨其马等，甜而不腻老少皆宜。",
        buyTip: "认准三禾商标，糕点保质期短，收到尽快品尝。",
        image: $r('app.media.gaodian'),
        highlight: "一块糕点，装下老北京风情"
      },
      {
        id: 4,
        name: "怀柔板栗",
        price: "￥25 - ￥88",
        desc: "产自中国板栗之乡，果肉细腻香甜软糯，既可当零食也能入菜调味。",
        buyTip: "选外壳光亮、无虫眼、手感沉的板栗，品质更好。",
        image: $r('app.media.banli'),
        highlight: "栗香满京华，软糯暖人心"
      },
      {
        id: 5,
        name: "王致和臭豆腐",
        price: "￥15 - ￥68",
        desc: "康熙年间老字号，闻着独特吃着鲜香，质地细腻，老北京特色调味品。",
        buyTip: "玻璃瓶无霉斑即可，开封密封冷藏尽快食用。",
        image: $r('app.media.choudoufu'),
        highlight: "闻之独特，食之难忘的京味"
      }
    ]
  },
  "天津市": {
    cultureStories: [
      {
        title: "杨柳青木版年画",
        tag: "国家级非遗",
        content: "杨柳青木版年画始于明代崇祯年间，以木版套印与手工彩绘结合，色彩艳丽，兼具艺术价值与民俗内涵，是天津最具代表性的民间艺术。",
        coverImage: $r('app.media.yangliuqing'),
        accentColor: "#E54E4E",
        quote: "木版印春秋，一笔一画都是人间好光景。"
      },
      {
        title: "天津皮影戏",
        tag: "民俗艺术",
        content: "灯光映影窗，巧手弄皮人，融津味腔调与民间故事，一影一幕演尽市井百态与人间悲欢。",
        coverImage: $r ('app.media.piyingxi'),
        accentColor: "#FF7B42",
        quote: "灯影摇岁月，一纸皮人唱尽津门情长。"
      },
      {
        title: "妈祖文化",
        tag: "文化典故",
        content: "北方最大妈祖庙，始建于元代，因天津漕运兴盛而建。每年农历三月二十三妈祖诞辰举办盛大的皇会。",
        coverImage: $r('app.media.mazu'),
        accentColor: "#4AA0D5",
        quote: "一庙守海河，岁岁平安佑津门。"
      },
      {
        title: "泥人张彩塑",
        tag: "国家级非遗",
        content: "清代道光年间创立，泥塑人物形神兼备细节逼真，将市井百态尽收于指尖。",
        coverImage: $r('app.media.caisu'),
        accentColor: "#A97D5D",
        quote: "一泥塑众生，百态人间掌中藏。"
      },
      {
        title: "估衣街传说",
        tag: "文化典故",
        content: "天津最早商业街，这里流传着“八大祥”商号的故事，见证百年商埠兴衰变迁，是津商文化的重要历史载体。",
        coverImage: $r('app.media.guyijie'),
        accentColor: "#6B6B6B",
        quote: "老街藏旧事，一街读懂津商百年情。"
      }
    ],
    specialtyFoods: [
      {
        id: 1,
        name: "狗不理包子",
        price: "￥88 - ￥298",
        desc: "天津“三绝”之首，始创于1858年，包子以“水馅半发面”工艺制作，皮薄馅大，褶花均匀（每个18褶），是天津标志性特产。",
        buyTip: "速冻款保质期约12个月，蒸制时无需解冻，水开后蒸8-10分钟；真空即食款需加热。",
        image: $r('app.media.goubuli'),
        highlight: "一口包子，十八道褶，津门百年味"
      },
      {
        id: 2,
        name: "十八街麻花",
        price: "￥58 - ￥198",
        desc: "桂发祥十八街麻花最具代表性，以优质面粉、花生油、冰糖、核桃仁等为原料，经多道工序炸制而成，麻花酥脆香甜，层次分明。",
        buyTip: "优选独立小包装（保质期约9个月），避免整根大麻花开封后受潮。",
        image: $r('app.media.mahua'),
        highlight: "根根酥脆，酥香千层，一口咬出天津味"
      },
      {
        id: 3,
        name: "耳朵眼炸糕",
        price: "￥68 - ￥188",
        desc: "因店铺位于耳朵眼胡同得名，炸糕以糯米面为皮，红豆沙为馅，经热油炸至金黄，外皮酥脆，内馅软糯香甜。",
        buyTip: "速冻生胚炸制时油温控制在160-180℃，炸至浮起即可。",
        image: $r('app.media.zhagao'),
        highlight: "外酥里糯，一口老天津"
      },
      {
        id: 4,
        name: "天津果仁张",
        price: "￥35 - ￥128",
        desc: "中华老字号，果仁张以花生仁、核桃仁、杏仁等为原料，经糖衣裹制、烘炒而成，口味有琥珀、五香、麻辣等，是天津经典的休闲零食。",
        buyTip: "开封后需密封保存，避免受潮变软；优先选无添加防腐剂的款式。",
        image: $r('app.media.guorenzhang'),
        highlight: "颗颗酥脆，津门经典零食"
      },
      {
        id: 5,
        name: "杨村糕干",
        price: "￥28 - ￥98",
        desc: "天津武清杨村特产，始于明初，糕干以优质大米粉、绵白糖为原料，经蒸制而成，质地细腻，口感清甜绵软，老少皆宜。",
        buyTip: "密封常温保存，可直接吃也可蒸软后食用。",
        image: $r('app.media.gaogan'),
        highlight: "绵软清甜，六百年津门老味道"
      }
    ]
  },
  // ==================== 上海市 ====================
  // "上海市": {
  //   cultureStories: [
  //     {
  //       title: "海派剪纸",
  //       tag: "国家级非遗",
  //       content: "海派剪纸融合南北剪纸特色，又吸纳西洋艺术元素，题材多变，线条细腻灵动，构图兼具写实与写意，是上海海派文化的典型艺术表达。",
  //       coverImage: $r('app.media.jianzhi'),
  //       accentColor: "#E6004F",
  //       quote: "一纸剪尽中西风华，藏着上海的灵动与浪漫。"
  //     },
  //     {
  //       title: "上海评弹",
  //       tag: "民俗艺术",
  //       content: "以苏州话演唱，融合说、噱、弹、唱、演，伴奏用琵琶和三弦，多讲述才子佳人、历史演义故事，老上海的茶馆、书场是评弹的主要展演地，尽显江南雅韵。",
  //       coverImage: $r('app.media.pingtan'),
  //       accentColor: "#9F3ED5",
  //       quote: "弦音轻起，便把江南的温柔唱进了上海时光。"
  //     },
  //     {
  //       title: "豫园传说",
  //       tag: "文化典故",
  //       content: "豫园始建于明代嘉靖年间，由潘允端为孝敬父亲所建，取“豫悦老亲”之意。园内有“玉玲珑”江南三大名石之一、九曲桥等经典景致。",
  //       coverImage: $r('app.media.yuyuan'),
  //       accentColor: "#007A9E",
  //       quote: "一园藏尽百年申城，曲桥流水皆是旧时光。"
  //     },
  //     {
  //       title: "顾绣",
  //       tag: "国家级非遗",
  //       content: "顾绣以绣仿画为特色，将绘画技法融入刺绣，针法多变，色彩清雅，题材多为山水、花鸟、人物，有“画绣”之称，是中国刺绣艺术的珍品。",
  //       coverImage: $r('app.media.guxiu'),
  //       accentColor: "#D9A8A8",
  //       quote: "丝线织就江南雅韵，一针一线皆是岁月匠心。"
  //     },
  //     {
  //       title: "石库门文化",
  //       tag: "民俗文化",
  //       content: "石库门是上海独有的民居建筑，以石质门框、黑漆大门为标志，弄堂纵横交错，既保留中式合院的格局，又融入西洋装饰元素，承载着老上海的市井生活与中西交融的城市记忆。",
  //       coverImage: $r('app.media.shikumen'),
  //       accentColor: "#5C4B4B",
  //       quote: "弄堂深处藏烟火，一门一屋都是上海的根。"
  //     }
  //   ],
  //   specialtyFoods: [
  //     {
  //       id: 1,
  //       name: "杏花楼月饼",
  //       price: "￥98 - ￥398",
  //       desc: "杏花楼广式月饼是上海经典代表，尤以豆沙、莲蓉、五仁口味见长，饼皮酥软，馅料饱满，甜度适中。",
  //       buyTip: "鲜肉月饼选现烤款口感最佳，广式月饼常温避光保存即可；认准官方商标，线下门店购买更靠谱。",
  //       image: $r('app.media.yuebing'),
  //       highlight: "一块月饼，尝遍海派中秋的温柔滋味"
  //     },
  //     {
  //       id: 2,
  //       name: "南翔小笼包",
  //       price: "￥78 - ￥268",
  //       desc: "上海嘉定南翔镇特产，小笼包以“皮薄、馅大、汁多、味鲜”著称，面皮薄如蝉翼，馅料选用新鲜猪腿肉，加入皮冻制成，蒸熟后汤汁充盈。",
  //       buyTip: "蒸制时冷水上锅，水开后蒸8分钟即可；选南翔馒头店官方出品，口感更正宗。",
  //       image: $r('app.media.nanxiang'),
  //       highlight: "皮薄汁鲜，一口咬开老上海风情"
  //     },
  //     {
  //       id: 3,
  //       name: "大白兔奶糖",
  //       price: "￥45 - ￥188",
  //       desc: "上海冠生园出品的经典糖果，始于1959年，奶糖以优质奶粉、麦芽糖为原料，口感奶香浓郁，软糯不粘牙，是上海最具童年记忆的伴手礼。",
  //       buyTip: "独立包装易保存，送礼认准正版商标；避免阳光直射，防止糖体粘连。",
  //       image: $r('app.media.dabaitu'),
  //       highlight: "一颗奶糖，甜了几代人的上海童年"
  //     },
  //     {
  //       id: 4,
  //       name: "功德林素月饼/素鸭",
  //       price: "￥68 - ￥228",
  //       desc: "上海百年素菜馆出品，素鸭以豆皮为原料，经卤制而成，口感咸香有嚼劲，素月饼选用坚果、菌菇等馅料，无荤腥，兼具江南风味与素食特色。",
  //       buyTip: "真空装开封后冷藏，吃前微波10秒；素月饼配清茶，口感更清雅。",
  //       image: $r('app.media.gongdelin'),
  //       highlight: "素食清雅，藏着沪上百年静心滋味"
  //     },
  //     {
  //       id: 5,
  //       name: "沈大成糕团",
  //       price: "￥58 - ￥198",
  //       desc: "涵盖双酿团、条头糕、金团等经典款，以优质糯米、豆沙、芝麻等为原料，口感软糯香甜，不粘牙，尽显上海本帮点心的软糯风味。",
  //       buyTip: "真空款冷藏保存即可，食用前回温10分钟；优先选新鲜短保款，风味更足。",
  //       image: $r('app.media.shendacheng'),
  //       highlight: "软糯香甜里，装着老上海的点心记忆"
  //     }
  //   ]
  // },
  //
  // // ==================== 重庆市 ====================
  // "重庆市": {
  //   cultureStories: [
  //     {
  //       title: "川江号子",
  //       tag: "国家级非遗",
  //       content: "船工行船时的歌谣，高亢粗犷，既能协调动作又抒发情感，是巴渝文化活化石。",
  //       coverImage: $r('app.media.chuanjiang'),
  //       accentColor: "#D81F26",
  //       quote: "号子震江涛，一呼一应见巴人风骨。"
  //     },
  //     {
  //       title: "铜梁龙舞",
  //       tag: "民俗活动",
  //       content: "传承千年民俗，龙舞刚劲有力，火龙铁水花场面震撼，被誉为中华第一龙。",
  //       coverImage: $r('app.media.tongliang'),
  //       accentColor: "#FF3C00",
  //       quote: "龙腾山河壮，火光里舞出重庆魂。"
  //     },
  //     {
  //       title: "白帝城传说",
  //       tag: "文化典故",
  //       content: "刘备托孤之地，因李白诗篇名扬天下，三国文化与诗词文化在此交融。",
  //       coverImage: $r('app.media.baidi'),
  //       accentColor: "#1E88E5",
  //       quote: "一城诗千首，忠义千秋照江流。"
  //     },
  //     {
  //       title: "荣昌陶艺",
  //       tag: "国家级非遗",
  //       content: "始于汉代，安陶透气性极佳，采用传统泥条盘筑，是西南陶艺杰出代表。",
  //       coverImage: $r('app.media.rongchang'),
  //       accentColor: "#8D6E63",
  //       quote: "土与火相融，一器温润巴渝岁月长。"
  //     },
  //     {
  //       title: "吊脚楼文化",
  //       tag: "民俗文化",
  //       content: "依山临江而建，木柱悬空设计，通风防潮，洪崖洞是其最典型代表。",
  //       coverImage: $r('app.media.diaojiao'),
  //       accentColor: "#455A64",
  //       quote: "楼悬山水间，一檐一柱尽山城。"
  //     }
  //   ],
  //   specialtyFoods: [
  //     {
  //       id: 1,
  //       name: "重庆火锅底料礼盒",
  //       price: "￥58 - ￥268",
  //       desc: "有牛油/清油两款，麻辣醇厚香味浓郁，可煮火锅烧菜煮面多用。",
  //       buyTip: "牛油更香更浓，清油清爽不腻，选无香精款。",
  //       image: $r('app.media.cqhuoguo'),
  //       highlight: "一袋底料，煮活重庆江湖"
  //     },
  //     {
  //       id: 2,
  //       name: "陈麻花礼盒（磁器口）",
  //       price: "￥35 - ￥158",
  //       desc: "磁器口名小吃，口感酥脆化渣，有原味麻辣椒盐等多种口味。",
  //       buyTip: "认准陈昌银品牌，独立小包装携带更方便。",
  //       image: $r('app.media.chenmahua'),
  //       highlight: "酥香满口，磁器口老味道"
  //     },
  //     {
  //       id: 3,
  //       name: "江津米花糖礼盒",
  //       price: "￥42 - ￥188",
  //       desc: "重庆百年特产，由糯米花生芝麻制作，香甜酥脆、入口不粘牙。",
  //       buyTip: "推荐玫瑰牌，密封保存防碎防潮更安心。",
  //       image: $r('app.media.mihuatang'),
  //       highlight: "一口酥脆，甜透山城时光"
  //     },
  //     {
  //       id: 4,
  //       name: "重庆怪味胡豆礼盒",
  //       price: "￥28 - ￥128",
  //       desc: "集麻辣甜咸鲜香酥于一体，是重庆标志性特色怪味零食。",
  //       buyTip: "可选蝶花牌、渝兄牌，开封后建议尽快吃完。",
  //       image: $r('app.media.guaiweihudou'),
  //       highlight: "七味合一，越吃越上头"
  //     },
  //     {
  //       id: 5,
  //       name: "城口老腊肉礼盒",
  //       price: "￥128 - ￥498",
  //       desc: "农家土猪柏枝烟熏而成，肉质紧实、咸香浓郁、腊味正宗地道。",
  //       buyTip: "认准地理标志，用温水泡去盐再烹饪更适口。",
  //       image: $r('app.media.larou'),
  //       highlight: "烟熏千年，巴渝腊味魂"
  //     }
  //   ]
  // },
  //
  // // ==================== 成都市 ====================
  // "成都市": {
  //   cultureStories: [
  //     {
  //       title: "川剧变脸",
  //       tag: "国家级非遗",
  //       content: "川剧独门绝技，瞬间变幻脸谱，视觉效果震撼，是巴蜀文化代表符号。",
  //       coverImage: $r('app.media.bianlian'),
  //       accentColor: "#E50000",
  //       quote: "瞬息换千面，绝技惊鸿震四方。"
  //     },
  //     {
  //       title: "成都糖画",
  //       tag: "民俗艺术",
  //       content: "以蔗糖为墨、石板为纸，龙飞凤舞花鸟生肖栩栩如生，好看又好吃。",
  //       coverImage: $r('app.media.tanghua'),
  //       accentColor: "#FF7D00",
  //       quote: "糖丝绕流年，一画一甜暖蓉城。"
  //     },
  //     {
  //       title: "武侯祠传说",
  //       tag: "文化典故",
  //       content: "全国唯一君臣合祀祠宇，纪念诸葛亮与刘备，三国文化核心地标。",
  //       coverImage: $r('app.media.wuhou'),
  //       accentColor: "#3D5A45",
  //       quote: "古柏守忠魂，一祠铭记三国心。"
  //     },
  //     {
  //       title: "蜀绣",
  //       tag: "国家级非遗",
  //       content: "中国四大名绣之一，针法严谨色彩明丽，熊猫芙蓉纹样极具川味。",
  //       coverImage: $r('app.media.shuxiu'),
  //       accentColor: "#F4A7C1",
  //       quote: "纤针绣锦绣，丝缕之间藏锦官。"
  //     },
  //     {
  //       title: "宽窄巷子文化",
  //       tag: "民俗文化",
  //       content: "清代满城历史遗存，川西民居风格，被誉为老成都底片新都市客厅。",
  //       coverImage: $r('app.media.kuanzhai'),
  //       accentColor: "#8D7B67",
  //       quote: "宽窄皆人生，一巷一韵是成都。"
  //     }
  //   ],
  //   specialtyFoods: [
  //     {
  //       id: 1,
  //       name: "郫县豆瓣礼盒",
  //       price: "￥38 - ￥168",
  //       desc: "被誉为川菜之魂，色泽红亮酱香浓郁，发酵足味道正，川菜必备调料。",
  //       buyTip: "选鹃城牌，发酵12个月以上的豆瓣风味更醇。",
  //       image: $r('app.media.douban'),
  //       highlight: "一勺豆瓣，香遍川菜江湖"
  //     },
  //     {
  //       id: 2,
  //       name: "张飞牛肉礼盒",
  //       price: "￥68 - ￥298",
  //       desc: "四川阆中特产，黄牛肉卤制而成，干香紧实、纹理清晰有嚼劲。",
  //       buyTip: "真空独立小包装，认准张飞正版商标更放心。",
  //       image: $r('app.media.niurou'),
  //       highlight: "忠义如张飞，牛肉香入骨"
  //     },
  //     {
  //       id: 3,
  //       name: "蜀绣熊猫糕点礼盒",
  //       price: "￥58 - ￥228",
  //       desc: "熊猫造型搭配蜀绣纹样，口感软糯香甜，是成都特色伴手礼。",
  //       buyTip: "独立小包装干净卫生，冷藏保鲜口感更佳。",
  //       image: $r('app.media.pandacake'),
  //       highlight: "萌趣熊猫，一口成都甜"
  //     },
  //     {
  //       id: 4,
  //       name: "蒲江米花糖礼盒",
  //       price: "￥42 - ￥158",
  //       desc: "经典蛋苕酥，由糯米鸡蛋红薯制作，香甜酥脆，老成都童年味道。",
  //       buyTip: "推荐蒲议牌，密封保存防碎防潮口感更好。",
  //       image: $r('app.media.mihuatang'),
  //       highlight: "酥脆香甜，成都儿时记忆"
  //     },
  //     {
  //       id: 5,
  //       name: "成都火锅底料（清油）礼盒",
  //       price: "￥55 - ￥258",
  //       desc: "菜籽油为基底，麻辣鲜香不腻口，吃着舒服对肠胃更友好。",
  //       buyTip: "可选名扬、大红袍，开封后记得冷藏保存。",
  //       image: $r('app.media.huoguo'),
  //       highlight: "清油麻辣，温润成都味"
  //     }
  //   ]
  // }
};