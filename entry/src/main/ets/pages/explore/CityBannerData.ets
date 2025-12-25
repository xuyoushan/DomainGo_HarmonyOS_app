export interface CityBanner {
  title: string;
  image?: Resource; // 以后你要真放图片用
  color: string;    // 现在先用色块占位
}

// 每个城市一组
export const CITY_BANNER_DATA: Record<string, CityBanner[]> = {
  "武汉市": [
    { title: '黄鹤楼 · 千古名胜', color: '#FF6B6B' },
    { title: '热干面 · 武汉早餐灵魂', color: '#FFD93D' },
    { title: '长江大桥 · 万里长江第一桥', color: '#4ECDC4' }
  ],

  "青岛市": [
    { title: '青岛啤酒 · 世界知名', color: '#74B9FF' },
    { title: '碧海蓝天 · 海滨城市', color: '#00B894' },
    { title: '海鲜盛宴 · 鲜美直达', color: '#FAB1A0' }
  ],

  "北京市": [
    { title: '故宫 · 紫禁城', color: '#E17055' },
    { title: '长城 · 万里雄关', color: '#636E72' },
    { title: '天安门 · 国家象征', color: '#D63031' }
  ]
};
