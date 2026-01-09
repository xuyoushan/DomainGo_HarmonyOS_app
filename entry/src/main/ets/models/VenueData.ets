// 定义资源类型（适配你代码中的 $r 语法）
type Resource = string;

export interface Venue {
  id: string;
  name: string;
  category: '博物馆' | '美术馆' | '科技馆' | '体育馆' | '其他';
  address: string;
  description: string;
  needBooking: boolean; // 是否需要预约
  officialUrl?: string; // 官网链接
  wechatName?: string;  // 微信小程序/公众号名称
  image?: Resource;
  tips?: string;        // 状态提醒
  isHot?: boolean;      // 热门标注
}

export const CITY_VENUES_MAP: Record<string, Venue[]> = {
  '北京市': [
    // 博物馆（需预约）
    {
      id: 'bj_museum_1',
      name: '中国国家博物馆',
      category: '博物馆',
      address: '东城区东长安街16号',
      description: '国家一级博物馆，收藏了大量珍贵文物，展现中华文明发展脉络。',
      needBooking: true,
      officialUrl: 'https://ticket.chnmuseum.cn/',
      wechatName: '国家博物馆服务号',
      image: 'bj_museum_national',
      tips: '建议提前7天0点放票时预约，节假日票源紧张',
      isHot: true
    },
    {
      id: 'bj_museum_2',
      name: '故宫博物院',
      category: '博物馆',
      address: '东城区景山前街4号',
      description: '明清两代皇宫，世界文化遗产，拥有海量宫廷文物和古建筑群。',
      needBooking: true,
      officialUrl: 'https://gugong.228.com.cn/',
      wechatName: '故宫博物院',
      image: 'bj_museum_forbidden',
      tips: '需通过微信小程序提前8天20点放票预约，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'bj_museum_3',
      name: '首都博物馆',
      category: '博物馆',
      address: '西城区复兴门外大街16号',
      description: '北京地区综合性博物馆，展示北京历史文化与城市发展。',
      needBooking: true,
      officialUrl: 'https://www.capitalmuseum.org.cn/',
      wechatName: '首都博物馆',
      tips: '提前1-3天预约即可，每日有少量现场预约名额',
      isHot: true
    },
    {
      id: 'bj_museum_4',
      name: '中国人民革命军事博物馆',
      category: '博物馆',
      address: '海淀区复兴路9号',
      description: '国家级军事博物馆，展示中国军事发展历程和国防建设成就。',
      needBooking: true,
      officialUrl: 'https://www.jb.mil.cn/',
      wechatName: '中国人民革命军事博物馆',
      tips: '免费预约，可提前7天预约，现场也可扫码预约（人少）',
      isHot: false
    },
    // 美术馆（需预约）
    {
      id: 'bj_art_1',
      name: '中国美术馆',
      category: '美术馆',
      address: '东城区五四大街一号',
      description: '中国唯一的国家级美术博物馆，收藏展示各类经典美术作品。',
      needBooking: true,
      officialUrl: 'https://www.namoc.org/',
      wechatName: '中国美术馆',
      tips: '提前7天预约，特展期间票源紧张，周一闭馆',
      isHot: true
    },
    {
      id: 'bj_art_2',
      name: '北京画院美术馆',
      category: '美术馆',
      address: '朝阳区朝阳公园南路12号',
      description: '以近现代中国画收藏、研究、展示为核心的专业美术馆。',
      needBooking: true,
      officialUrl: 'https://www.bjam.org.cn/',
      wechatName: '北京画院美术馆',
      tips: '免费预约，提前1天即可，观展人数较少',
      isHot: false
    },
    {
      id: 'bj_art_3',
      name: '中央美术学院美术馆',
      category: '美术馆',
      address: '朝阳区花家地南街8号',
      description: '集展览、收藏、研究于一体的专业艺术机构，聚焦现当代美术创作。',
      needBooking: true,
      officialUrl: 'https://museum.cafa.edu.cn/',
      wechatName: '中央美术学院美术馆',
      tips: '部分特展需购票，常规展免费预约，提前1天预约即可',
      isHot: false
    },
    // 科技馆（需预约）
    {
      id: 'bj_science_1',
      name: '中国科技馆',
      category: '科技馆',
      address: '朝阳区北辰东路5号',
      description: '国家级综合性科技馆，通过互动体验普及科学技术知识。',
      needBooking: true,
      officialUrl: 'https://www.cdm.org.cn/',
      wechatName: '中国科技馆',
      tips: '需购票预约，节假日建议提前3天预约，儿童需单独预约',
      isHot: true
    },
    {
      id: 'bj_science_2',
      name: '北京天文馆',
      category: '科技馆',
      address: '西城区西直门外大街138号',
      description: '以天文科普为核心，拥有球幕影院和各类天文展项的专业场馆。',
      needBooking: true,
      officialUrl: 'https://www.bjp.org.cn/',
      wechatName: '北京天文馆',
      tips: '门票需提前1-3天预约，球幕电影票抢手建议尽早预约',
      isHot: true
    },
    // 体育馆（需预约/部分需预约）
    {
      id: 'bj_sport_1',
      name: '国家体育场(鸟巢)',
      category: '体育馆',
      address: '朝阳区国家体育场南路',
      description: '2008年奥运会主体育场，双奥开闭幕式举办地，兼具赛事和观光功能。',
      needBooking: true,
      wechatName: '巢票',
      image: 'bj_sport_birdnest',
      tips: '观光票可当天预约，赛事/演出需提前购票，节假日人流量大',
      isHot: true
    },
    {
      id: 'bj_sport_2',
      name: '国家游泳中心(水立方)',
      category: '体育馆',
      address: '朝阳区奥林匹克公园中心区',
      description: '2008年奥运会游泳场馆，现为集游泳、休闲、赛事于一体的综合场馆。',
      needBooking: true,
      wechatName: '水立方',
      tips: '参观票可当天预约，游泳需单独购票预约，分时段入场',
      isHot: true
    },
    {
      id: 'bj_sport_3',
      name: '五棵松体育中心',
      category: '体育馆',
      address: '海淀区复兴路69号',
      description: '多功能体育场馆，承办篮球、冰球等各类赛事和大型活动。',
      needBooking: true,
      officialUrl: 'https://www.wukesongarena.com/',
      wechatName: '五棵松体育中心',
      tips: '仅赛事/活动需购票预约，日常场馆外部参观无需预约',
      isHot: false
    },
    // 其他（无需预约）
    {
      id: 'bj_other_1',
      name: '奥林匹克森林公园',
      category: '其他',
      address: '朝阳区安立路',
      description: '开放式城市公园，包含各类休闲运动场地，无需预约即可进入。',
      needBooking: false,
      tips: '24小时开放（核心区域18:00闭园），节假日停车位紧张',
      isHot: true
    },
    {
      id: 'bj_other_2',
      name: '北京工人体育场',
      category: '其他',
      address: '朝阳区工人体育场北路',
      description: '综合性体育场馆，日常观光无需预约，赛事/活动需单独购票。',
      needBooking: false,
      tips: '场馆内部参观需跟随导览团，外部可自由参观',
      isHot: false
    },
    {
      id: 'bj_other_3',
      name: '798艺术区美术馆群',
      category: '其他',
      address: '朝阳区酒仙桥路4号',
      description: '艺术区内多家小型美术馆/画廊，开放式街区，单馆部分需预约，整体无需预约。',
      needBooking: false,
      tips: '全天开放，部分小众画廊需单独预约，建议工作日前往人少',
      isHot: true
    }
  ]
};