export interface CultureStory {
  title: string;
  tag: string;      // 类别：如 非遗 / 民俗 / 艺术 / 典故
  content: string;  // 详细的故事介绍文案
  icon: Resource;   // 展示用的图标
}

// 特产风味条目结构
export interface SpecialtyItem {
  name: string;
  price: string;    // 参考价格区间
  desc: string;     // 产品描述
  buyTip: string;   // 购买建议或挑选技巧
  image: Resource;  // 特产实物图片
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
        icon: $r('sys.symbol.paintpalette_fill')
      },
      {
        title: "高龙",
        tag: "民俗活动",
        content: "武汉汉阳一带独有的舞龙形式，龙体竖立，舞者以肩扛、头顶、齿衔，姿态雄壮。每逢元宵，火流星飞舞，场面极度壮观。",
        icon: $r('sys.symbol.flag_fill')
      },
      {
        title: "伯牙子期传说",
        tag: "文化典故",
        content: "知音文化的源头。归元寺旁的古琴台，讲述了“高山流水觅知音”的千古绝唱，构成了这座城市重情重义的精神底色。",
        icon: $r('sys.symbol.music_note_list')
      }
    ],
    specialtyFoods: [
      {
        name: "蔡林记热干面礼盒",
        price: "￥29 - ￥58",
        desc: "选用优质碱面与秘制黑芝麻酱，经过多道工序复刻店头口感，是把“武汉过早”带回家的首选。",
        buyTip: "建议选择配有料包较全的礼盒，注意查看芝麻酱的保质期。",
        image: $r('app.media.food_rgm')
      },
      {
        name: "精武/周黑鸭",
        price: "￥35 - ￥120",
        desc: "武汉鸭脖以麻、辣、鲜、香、甜著称。皮黑肉嫩，骨髓入味，是极佳的休闲零食。",
        buyTip: "真空包装适合远途携带，锁鲜装口感更好但保质期短（通常5-7天）。",
        image: $r('app.media.food_yabo')
      },
      {
        name: "黄陂荆蜜",
        price: "￥45 - ￥80",
        desc: "中国四大名蜜之一，色泽琥珀，气味清香，含有丰富的维生素和矿物质。",
        buyTip: "认准地理标志保护产品认证，纯正荆蜜久置会有细密结晶。",
        image: $r('app.media.food_honey')
      }
    ]
  },
  // 你可以在这里继续添加其他城市，例如：
  // "北京市": { ... },
  // "天津市": { ... },
}