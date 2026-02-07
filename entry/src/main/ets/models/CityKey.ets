export interface CityExploreConfig {
  keywords: string[];
}

export const CITY_EXPLORE_MAP: Record<string, CityExploreConfig> = {
  "北京市": { keywords: ["故宫", "南锣鼓巷", "中轴线", "颐和园", "胡同寻踪"] },
  "天津市": { keywords: ["天津之眼", "五大道", "意风区", "瓷房子", "海河游船"] },
  "上海市": { keywords: ["外滩", "武康路", "陆家嘴", "豫园", "安福路"] },
  "重庆市": { keywords: ["洪崖洞", "解放碑", "李子坝", "磁器口", "山城步道"] },
  "武汉市": { keywords: ["热干面", "黄鹤楼", "武汉樱花", "湖北省博", "江汉路"] },
  "成都市": { keywords: ["宽窄巷子", "大熊猫基地", "武侯祠", "锦里", "春熙路"] }
};

export const DEFAULT_EXPLORE_DATA: CityExploreConfig = {
  keywords: ["地名", "历史", "文化", "攻略", "打卡"]
};