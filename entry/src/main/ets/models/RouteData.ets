export interface ScenicSpot {
  name: string;
  address: string;
  latitude: number;  // 纬度
  longitude: number; // 经度
}

export interface TravelRoute {
  routeName: string;
  spots: ScenicSpot[];
}

export const CITY_ROUTES: Record<string, TravelRoute[]> = {
  "北京市": [
    {
      routeName: "皇城文化线",
      spots: [
        { name: "天安门广场", address: "看升旗", latitude: 39.9055, longitude: 116.3976 },
        { name: "故宫博物院", address: "逛中轴线", latitude: 39.9163, longitude: 116.3972 },
        { name: "四季民福烤鸭店", address: "故宫店", latitude: 39.9142, longitude: 116.4025 },
        { name: "景山公园", address: "拍全景", latitude: 39.9231, longitude: 116.3969 },
        { name: "天坛公园", address: "祈年殿", latitude: 39.8821, longitude: 116.4066 }
      ]
    },
    {
      routeName: "环球沉浸线",
      spots: [
        { name: "哈利波特禁忌之旅", address: "环球影城", latitude: 39.8601, longitude: 116.6710 },
        { name: "变形金刚火种源", address: "环球影城", latitude: 39.8615, longitude: 116.6690 },
        { name: "三把扫帚餐厅", address: "用餐", latitude: 39.8595, longitude: 116.6720 },
        { name: "奇梦之光幻影秀", address: "闭园秀", latitude: 39.8580, longitude: 116.6700 }
      ]
    },
    {
      routeName: "京郊休闲线",
      spots: [
        { name: "古北水镇", address: "永顺染坊", latitude: 40.6521, longitude: 117.2715 },
        { name: "司马台长城", address: "登城", latitude: 40.6520, longitude: 117.2885 },
        { name: "798 艺术区", address: "看展", latitude: 39.9841, longitude: 116.4920 },
        { name: "三里屯太古里", address: "逛街", latitude: 39.9348, longitude: 116.4545 }
      ]
    }
  ],
  "天津市": [
    {
      routeName: "风情 Citywalk 线",
      spots: [
        { name: "五大道", address: "疙瘩楼", latitude: 39.1065, longitude: 117.1956 },
        { name: "意大利风情区", address: "复古建筑", latitude: 39.1351, longitude: 117.1972 },
        { name: "天津之眼", address: "摩天轮", latitude: 39.1555, longitude: 117.1818 },
        { name: "津湾广场", address: "夜景游船", latitude: 39.1305, longitude: 117.2085 }
      ]
    },
    {
      routeName: "亲子科普线",
      spots: [
        { name: "国家海洋博物馆", address: "远古海洋", latitude: 39.1278, longitude: 117.8090 },
        { name: "泰达航母主题公园", address: "登航母", latitude: 39.1545, longitude: 117.8020 },
        { name: "滨海新区图书馆", address: "网红墙", latitude: 39.0142, longitude: 117.6850 }
      ]
    },
    {
      routeName: "老城美食线",
      spots: [
        { name: "古文化街", address: "泥人张", latitude: 39.1432, longitude: 117.1885 },
        { name: "天后宫", address: "民俗", latitude: 39.1418, longitude: 117.1892 },
        { name: "南市食品街", address: "炸糕", latitude: 39.1331, longitude: 117.1798 }
      ]
    }
  ],
  "上海市": [
    {
      routeName: "魔都经典线",
      spots: [
        { name: "外滩", address: "万国建筑", latitude: 31.2403, longitude: 121.4905 },
        { name: "豫园", address: "九曲桥", latitude: 31.2275, longitude: 121.4925 },
        { name: "陆家嘴", address: "三件套", latitude: 31.2355, longitude: 121.5065 }
      ]
    },
    {
      routeName: "文艺漫步线",
      spots: [
        { name: "武康大楼", address: "拍照", latitude: 31.2045, longitude: 121.4358 },
        { name: "安福路", address: "话剧中心", latitude: 31.2162, longitude: 121.4402 },
        { name: "田子坊", address: "弄堂", latitude: 31.2065, longitude: 121.4678 }
      ]
    },
    {
      routeName: "苏河水岸线",
      spots: [
        { name: "四行仓库", address: "纪念馆", latitude: 31.2422, longitude: 121.4695 },
        { name: "苏州河步道", address: "漫步", latitude: 31.2445, longitude: 121.4650 },
        { name: "M50 艺术区", address: "画廊", latitude: 31.2485, longitude: 121.4485 }
      ]
    }
  ],
  "重庆市": [
    {
      routeName: "山城赛博线",
      spots: [
        { name: "洪崖洞", address: "千厮门大桥", latitude: 29.5645, longitude: 106.5835 },
        { name: "解放碑", address: "核心区", latitude: 29.5575, longitude: 106.5772 },
        { name: "李子坝", address: "轻轨穿楼", latitude: 29.5535, longitude: 106.5365 }
      ]
    },
    {
      routeName: "怀旧时光线",
      spots: [
        { name: "磁器口古镇", address: "陈麻花", latitude: 29.5815, longitude: 106.4495 },
        { name: "渣滓洞", address: "红岩魂", latitude: 29.5785, longitude: 106.4320 },
        { name: "鹅岭二厂", address: "从你的全世界路过", latitude: 29.5522, longitude: 106.5385 }
      ]
    },
    {
      routeName: "云端漫步线",
      spots: [
        { name: "南山一棵树", address: "夜景", latitude: 29.5552, longitude: 106.5915 },
        { name: "长江索道", address: "过江", latitude: 29.5582, longitude: 106.5845 },
        { name: "龙门浩老街", address: "江景", latitude: 29.5495, longitude: 106.5895 }
      ]
    }
  ],
  "武汉市": [
    {
      routeName: "江城烟火线",
      spots: [
        { name: "户部巷", address: "过早", latitude: 30.5485, longitude: 114.2985 },
        { name: "黄鹤楼", address: "登高", latitude: 30.5448, longitude: 114.3045 },
        { name: "长江大桥", address: "漫步", latitude: 30.5505, longitude: 114.2885 }
      ]
    },
    {
      routeName: "知音文化线",
      spots: [
        { name: "古琴台", address: "俞伯牙", latitude: 30.5512, longitude: 114.2695 },
        { name: "月湖公园", address: "风景", latitude: 30.5535, longitude: 114.2655 },
        { name: "汉口江滩", address: "芦苇荡", latitude: 30.6055, longitude: 114.3215 }
      ]
    },
    {
      routeName: "高校樱花线",
      spots: [
        { name: "武汉大学", address: "樱花大道", latitude: 30.5375, longitude: 114.3645 },
        { name: "湖北省博物馆", address: "越王勾践剑", latitude: 30.5615, longitude: 114.3635 },
        { name: "东湖绿道", address: "骑行", latitude: 30.5595, longitude: 114.3755 }
      ]
    }
  ],
  "成都市": [
    {
      routeName: "安逸生活线",
      spots: [
        { name: "宽窄巷子", address: "采耳", latitude: 30.6635, longitude: 104.0535 },
        { name: "锦里", address: "夜游", latitude: 30.6485, longitude: 104.0495 },
        { name: "武侯祠", address: "三国文化", latitude: 30.6465, longitude: 104.0485 }
      ]
    },
    {
      routeName: "萌动熊猫线",
      spots: [
        { name: "大熊猫基地", address: "花花", latitude: 30.7335, longitude: 104.1435 },
        { name: "春熙路", address: "爬墙熊猫", latitude: 30.6555, longitude: 104.0815 },
        { name: "太古里", address: "3D大屏", latitude: 30.6535, longitude: 104.0855 }
      ]
    },
    {
      routeName: "盖碗茶香线",
      spots: [
        { name: "人民公园", address: "鹤鸣茶社", latitude: 30.6565, longitude: 104.0595 },
        { name: "杜甫草堂", address: "诗歌", latitude: 30.6605, longitude: 104.0295 },
        { name: "琴台路", address: "川剧变脸", latitude: 30.6615, longitude: 104.0455 }
      ]
    }
  ]
}