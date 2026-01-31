type ResourceStr = string;

export interface Venue {
  id: string;
  name: string;
  address: string;
  category: '文博馆' | '学术殿堂' | '科技馆' | '体育馆' | '其他'; // 调整分类
  description: string;
  image?: ResourceStr;
  officialUrl?: string; // 官网链接
  wechatName?: string;  // 小程序名称
  tips?: string;        // 预约贴士
  isHot?: boolean;      // 是否热门
  needBooking: boolean; // 是否需要预约
  isUniversity?: boolean; // 标记是否为高校
  isLibrary?: boolean; // 标记是否为图书馆
}

export const CITY_VENUES_MAP: Record<string, Venue[]> = {
  '北京市': [
    // 文博馆
    {
      id: 'bj_culture_1',
      name: '中国国家博物馆',
      category: '文博馆',
      address: '东城区东长安街16号',
      description: '国家一级文博机构，收藏海量珍贵文物，展现中华文明发展脉络。',
      needBooking: true,
      officialUrl: 'https://ticket.chnmuseum.cn/',
      wechatName: '国家博物馆服务号',
      image: 'app.media.bj_museum_national',
      tips: '建议提前7天0点放票时预约，节假日票源紧张',
      isHot: true
    },
    {
      id: 'bj_culture_2',
      name: '故宫博物院',
      category: '文博馆',
      address: '东城区景山前街4号',
      description: '明清两代皇宫，世界文化遗产，拥有海量宫廷文物和古建筑群。',
      needBooking: true,
      officialUrl: 'https://gugong.228.com.cn/',
      wechatName: '故宫博物院',
      image: 'app.media.bj_museum_forbidden',
      tips: '需通过微信小程序提前8天20点放票预约，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'bj_culture_3',
      name: '首都博物馆',
      category: '文博馆',
      address: '西城区复兴门外大街16号',
      description: '北京地区综合性文博馆，展示北京历史文化与城市发展。',
      needBooking: true,
      officialUrl: 'https://www.capitalmuseum.org.cn/',
      wechatName: '首都博物馆',
      tips: '提前1-3天预约即可，每日有少量现场预约名额',
      isHot: true
    },
    {
      id: 'bj_culture_4',
      name: '中国美术馆',
      category: '文博馆',
      address: '东城区五四大街一号',
      description: '中国唯一的国家级美术文博机构，收藏展示各类经典美术作品。',
      needBooking: true,
      officialUrl: 'https://www.namoc.org/',
      wechatName: '中国美术馆',
      tips: '提前7天预约，特展期间票源紧张，周一闭馆',
      isHot: true
    },
    {
      id: 'bj_culture_5',
      name: '北京画院美术馆',
      category: '文博馆',
      address: '朝阳区朝阳公园南路12号',
      description: '以近现代中国画收藏、研究、展示为核心的专业文博机构。',
      needBooking: true,
      officialUrl: 'https://www.bjam.org.cn/',
      wechatName: '北京画院美术馆',
      tips: '免费预约，提前1天即可，观展人数较少',
      isHot: false
    },
    {
      id: 'bj_culture_6',
      name: '中国人民抗日战争纪念馆',
      category: '文博馆',
      address: '丰台区卢沟桥宛平城内街101号',
      description: '全国唯一全面反映中国人民抗日战争历史的大型综合性专题纪念馆。',
      needBooking: true,
      officialUrl: 'https://www.krzzjn.org/',
      wechatName: '中国人民抗日战争纪念馆',
      tips: '免费预约，提前1-3天预约即可，周一闭馆（法定节假日除外）',
      isHot: false
    },
    {
      id: 'bj_culture_7',
      name: '李大钊纪念馆',
      category: '文博馆',
      address: '海淀区万安里1号',
      description: '纪念中国共产主义运动先驱李大钊同志的专题纪念馆，展现其革命生平与精神遗产。',
      needBooking: true,
      wechatName: '李大钊纪念馆',
      tips: '免费预约，支持现场扫码预约，参观需携带身份证',
      isHot: false
    },
    {
      id: 'bj_culture_8',
      name: '宋庆龄故居纪念馆',
      category: '文博馆',
      address: '西城区后海北沿46号',
      description: '宋庆龄先生生前居住的场所，馆藏大量珍贵文物与历史资料，兼具园林景观价值。',
      needBooking: true,
      officialUrl: 'https://www.sclg.org.cn/',
      tips: '需购票预约，提前1天即可，院落参观禁止吸烟',
      isHot: true
    },
    {
      id: 'bj_culture_9',
      name: '老舍纪念馆（老舍故居）',
      category: '文博馆',
      address: '东城区灯市口西街丰富胡同19号',
      description: '老舍先生1950-1966年居所（丹柿小院），创作《茶馆》《龙须沟》等名作。',
      needBooking: true,
      wechatName: '老舍纪念馆',
      tips: '免费预约，提前1天，周一闭馆，院内有丹柿树可打卡',
      isHot: false
    },
    {
      id: 'bj_culture_10',
      name: '鲁迅博物馆（鲁迅故居）',
      category: '文博馆',
      address: '西城区阜成门内大街宫门口二条19号',
      description: '鲁迅1924-1926年居所，全国重点文保单位，含生平陈列与故居原状。',
      needBooking: true,
      officialUrl: 'https://www.luxunmuseum.net.cn/',
      tips: '提前3天预约，周一闭馆，16:30停止入馆',
      isHot: true
    },
    {
      id: 'bj_culture_11',
      name: '梅兰芳纪念馆（梅兰芳故居）',
      category: '文博馆',
      address: '西城区护国寺街9号',
      description: '梅兰芳1951-1961年居所，四合院保存完好，展陈艺术生涯文物。',
      needBooking: true,
      wechatName: '梅兰芳纪念馆',
      tips: '提前1天预约，免费参观，每日有定时讲解',
      isHot: false
    },
    {
      id: 'bj_culture_12',
      name: '郭沫若纪念馆（郭沫若故居）',
      category: '文博馆',
      address: '西城区前海西街18号',
      description: '郭沫若1963-1978年居所，两进四合院，藏大量手稿与藏书。',
      needBooking: true,
      officialUrl: 'https://www.guomoruo.com/',
      tips: '提前2天预约，周一闭馆，院内银杏秋季很美',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'bj_academy_1',
      name: '清华大学',
      category: '学术殿堂',
      address: '海淀区清华园1号',
      description: '中国顶尖高等学府，校园内有二校门、荷塘月色等标志性景观，人文与自然交融。',
      needBooking: true,
      wechatName: '清华大学',
      tips: '提前7天通过小程序预约，校园参观分时段进入，需携带身份证',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'bj_academy_2',
      name: '北京大学',
      category: '学术殿堂',
      address: '海淀区颐和园路5号',
      description: '百年名校，校园内未名湖、博雅塔为标志性景观，文化底蕴深厚。',
      needBooking: true,
      wechatName: '北京大学',
      tips: '提前7天预约，参观时段分为上下午，需严格遵守校园规定',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'bj_academy_3',
      name: '国家图书馆',
      category: '学术殿堂',
      address: '海淀区中关村南大街33号',
      description: '中国国家总图书馆，建筑气势恢宏，馆藏文献资源丰富，兼具借阅与观光价值。',
      needBooking: true,
      officialUrl: 'https://www.nlc.cn/',
      wechatName: '国家图书馆',
      tips: '读者卡需实名办理，参观无需预约，进入阅览区需预约，周一闭馆',
      isHot: true,
      isLibrary: true
    },
    {
      id: 'bj_academy_4',
      name: '北京城市副中心图书馆',
      category: '学术殿堂',
      address: '通州区潞阳大街与宋梁路交叉口',
      description: '建筑设计形似“森林中的图书馆”，融合自然与人文，是北京新晋文化地标。',
      needBooking: true,
      wechatName: '北京城市副中心图书馆',
      tips: '提前3天预约，馆内“森林书墙”为热门打卡点，禁止使用闪光灯拍照',
      isHot: true,
      isLibrary: true
    },

    // 科技馆
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
    {
      id: 'bj_science_3',
      name: '北京自然博物馆',
      category: '科技馆',
      address: '东城区天桥南大街126号',
      description: '国家级自然科学博物馆，馆藏恐龙化石、古生物标本等珍贵展品。',
      needBooking: true,
      officialUrl: 'https://www.bmnh.org.cn/',
      wechatName: '北京自然博物馆',
      tips: '提前7天0点放票，免费预约，儿童需由成人陪同',
      isHot: true
    },
    {
      id: 'bj_science_4',
      name: '中国地质博物馆',
      category: '科技馆',
      address: '西城区复兴门外大街1号',
      description: '中国成立最早的地质博物馆，拥有丰富的矿物、岩石、古生物化石藏品。',
      needBooking: true,
      officialUrl: 'http://www.gmc.org.cn/',
      wechatName: '中国地质博物馆',
      tips: '提前3天预约，免费开放，地下一层宝石展区最受欢迎',
      isHot: false
    },

    // 体育馆
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
      wechatName: '五棵松体育中心'
    },
    {
      id: 'bj_sport_4',
      name: '北京工人体育场',
      category: '体育馆',
      address: '朝阳区工人体育场北路',
      description: '综合性体育场馆，日常观光无需预约，赛事/活动需单独购票。',
      needBooking: false
    },

    // 其他
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
      name: '798艺术区',
      category: '其他',
      address: '朝阳区酒仙桥路4号',
      description: '开放式艺术街区，汇集小型画廊、文创店铺，整体无需预约。',
      needBooking: false,
      tips: '全天开放，部分小众画廊需单独预约，建议工作日前往人少',
      isHot: true
    }
  ],
  '武汉市': [
    // 文博馆
    {
      id: 'wh_culture_1',
      name: '湖北省博物馆',
      category: '文博馆',
      address: '武昌区东湖路160号',
      description: '国家一级文博机构，馆藏曾侯乙编钟等珍贵文物，楚文化核心展示地。',
      needBooking: true,
      officialUrl: 'https://www.hbww.org/',
      wechatName: '湖北省博物馆',
      image: 'app.media.wh_museum_hubei',
      tips: '提前7天预约，编钟演奏会需单独购票，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'wh_culture_2',
      name: '武汉博物馆',
      category: '文博馆',
      address: '江汉区青年路373号',
      description: '综合性文博馆，展现武汉城市发展历史与地域文化特色。',
      needBooking: true,
      officialUrl: 'http://www.whmuseum.com.cn/',
      wechatName: '武汉博物馆',
      tips: '提前1-3天预约即可，免费开放，每日有志愿讲解服务',
      isHot: false
    },
    {
      id: 'wh_culture_3',
      name: '湖北美术馆',
      category: '文博馆',
      address: '武昌区东湖路三官殿1号',
      description: '省级专业文博机构，聚焦现当代美术创作与湖北本土艺术展示。',
      needBooking: true,
      officialUrl: 'http://www.hubeiartmuseum.org/',
      wechatName: '湖北美术馆',
      tips: '免费预约，提前1天预约，特展期间人流量较大，建议错峰前往',
      isHot: false
    },
    {
      id: 'wh_culture_4',
      name: '武汉美术馆(琴台馆)',
      category: '文博馆',
      address: '汉阳区知音大道77号',
      description: '武汉新晋艺术地标，建筑风格独特，主打国内外大型艺术特展。',
      needBooking: true,
      officialUrl: 'https://www.wuhanartmuseum.org/',
      wechatName: '武汉美术馆',
      tips: '提前3天预约，周末票源紧张，馆内禁止携带食品饮料',
      isHot: true
    },
    {
      id: 'wh_culture_5',
      name: '辛亥革命武昌起义纪念馆',
      category: '文博馆',
      address: '武昌区阅马场首义广场南侧',
      description: '依托武昌起义军政府旧址建立，再现辛亥革命波澜壮阔的历史进程，又称“红楼”。',
      needBooking: true,
      officialUrl: 'http://www.xhgmuseum.com/',
      wechatName: '辛亥革命武昌起义纪念馆',
      tips: '免费预约，提前1天预约，每日有定时公益讲解',
      isHot: true
    },
    {
      id: 'wh_culture_6',
      name: '毛泽东同志旧居纪念馆',
      category: '文博馆',
      address: '武昌区都府堤41号',
      description: '毛泽东同志在武汉从事革命活动时的居所，见证了重要历史时期的革命实践。',
      needBooking: true,
      wechatName: '武汉革命博物馆',
      tips: '免费预约，与中共五大会址纪念馆联票参观更便捷，周一闭馆',
      isHot: false
    },
    {
      id: 'wh_culture_7',
      name: '八路军武汉办事处旧址纪念馆',
      category: '文博馆',
      address: '江岸区长春街57号',
      description: '记录八路军武汉办事处抗战时期工作历史的专题纪念馆，展现抗日民族统一战线的实践。',
      needBooking: true,
      officialUrl: 'http://www.bljwhbsc.org.cn/',
      tips: '免费预约，支持现场预约，馆内文物禁止拍照',
      isHot: false
    },
    {
      id: 'wh_culture_8',
      name: '詹天佑故居博物馆',
      category: '文博馆',
      address: '江岸区洞庭街65号',
      description: '詹天佑晚年居所（1912-1919），唯一保留的生活旧址，展铁路工程文物。',
      needBooking: true,
      officialUrl: 'https://jtygjng.wuhanmuseum.net.cn/',
      tips: '提前1天预约，免费参观，周一闭馆，与江汉关博物馆联游更佳',
      isHot: false
    },
    {
      id: 'wh_culture_9',
      name: '宋庆龄汉口旧居纪念馆',
      category: '文博馆',
      address: '江岸区沿江大道162号',
      description: '1926-1927年宋庆龄在汉居所，俄式建筑，见证国民政府迁都武汉历史。',
      needBooking: true,
      wechatName: '宋庆龄汉口旧居纪念馆',
      tips: '免费预约，提前1天，周一闭馆，二楼复原卧室可参观',
      isHot: false
    },
    {
      id: 'wh_culture_10',
      name: '八七会议会址纪念馆',
      category: '文博馆',
      address: '江岸区鄱阳街139号',
      description: '1927年八七会议召开地，中共重要历史旧址，展革命文物与史料。',
      needBooking: true,
      wechatName: '八七会议会址纪念馆',
      tips: '免费预约，提前1天，周一闭馆，适合党史研学',
      isHot: false
    },
    {
      id: 'wh_culture_11',
      name: '武汉天地壹方美术馆',
      category: '文博馆',
      address: '江岸区中山大道1505号',
      description: '商场内的小型文博机构，主打潮流艺术展，街区式开放。',
      needBooking: false,
      tips: '商场营业时间内开放，部分特展需购票，可顺路参观',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'wh_academy_1',
      name: '武汉大学',
      category: '学术殿堂',
      address: '武昌区八一路299号',
      description: '百年名校，以樱花和中西合璧的历史建筑闻名，东湖之畔风景秀丽。',
      needBooking: true,
      wechatName: '武汉大学',
      tips: '常态化参观需提前预约，樱花季（3月中下旬）需专项预约，限流严格',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'wh_academy_2',
      name: '华中科技大学',
      category: '学术殿堂',
      address: '洪山区珞喻路1037号',
      description: '中国顶尖工科高校，校园植被茂密被誉为“森林大学”，标志性建筑为韵苑体育馆。',
      needBooking: true,
      wechatName: '华中科技大学',
      tips: '提前3天预约，校园内梧桐大道秋季（11月）景色绝美，适合拍照',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'wh_academy_3',
      name: '湖北省图书馆',
      category: '学术殿堂',
      address: '武昌区公正路25号',
      description: '外观如一本翻开的巨书，内部阶梯式阅览区震撼，是武汉标志性文化建筑。',
      needBooking: true,
      wechatName: '湖北省图书馆',
      tips: '需通过微信实名预约，自习位需早起抢占，周一闭馆',
      isHot: true,
      isLibrary: true
    },

    // 科技馆
    {
      id: 'wh_science_1',
      name: '湖北省科学技术馆',
      category: '科技馆',
      address: '洪山区高新大道779号',
      description: '省级综合性科技馆，互动展项丰富，适合亲子科普研学。',
      needBooking: true,
      officialUrl: 'https://www.hbstm.org.cn/',
      wechatName: '湖北省科学技术馆',
      tips: '提前7天0点放票，儿童需绑定监护人信息预约，周末建议9点前到馆',
      isHot: true
    },
    {
      id: 'wh_science_2',
      name: '武汉自然博物馆',
      category: '科技馆',
      address: '硚口区园博园东路8号',
      description: '华中地区规模最大的自然博物馆，馆藏大量动植物标本、古生物化石，沉浸式展陈体验。',
      needBooking: true,
      wechatName: '武汉自然博物馆',
      tips: '提前3天预约，与园博园联票更划算，恐龙化石展区最受儿童欢迎',
      isHot: true
    },
    {
      id: 'wh_science_3',
      name: '中国地质大学（武汉）逸夫博物馆',
      category: '科技馆',
      address: '洪山区鲁磨路388号',
      description: '全国科普教育基地，拥有丰富的恐龙化石、矿石标本和宝玉石珍藏，学术性与观赏性兼具。',
      needBooking: true,
      officialUrl: 'http://museum.cug.edu.cn/',
      wechatName: '中国地质大学逸夫博物馆',
      tips: '提前1天预约，学生凭学生证半价，馆内矿石展区灯光较暗建议注意安全',
      isHot: false
    },

    // 体育馆
    {
      id: 'wh_sport_1',
      name: '武汉体育中心体育馆',
      category: '体育馆',
      address: '蔡甸区车城北路58号',
      description: '大型综合性体育馆，承办国内外重大体育赛事与演艺活动。',
      needBooking: true,
      wechatName: '武汉体育中心',
      tips: '仅赛事/演出需购票预约，场馆外部参观无需预约，周边停车方便',
      isHot: false
    },
    {
      id: 'wh_sport_2',
      name: '洪山体育馆',
      category: '体育馆',
      address: '武昌区体育馆路特1号',
      description: '武汉老牌体育馆，以篮球赛事和群众体育活动为主。',
      needBooking: true,
      officialUrl: 'http://www.hongshan-stadium.com/',
      wechatName: '洪山体育馆',
      tips: '日常全民健身项目需现场预约，大型赛事需提前购票',
      isHot: false
    },

    // 其他
    {
      id: 'wh_other_1',
      name: '汉口江滩',
      category: '其他',
      address: '江岸区沿江大道',
      description: '开放式滨江景观带，集休闲、观光、运动于一体的城市公共空间。',
      needBooking: false,
      tips: '全天开放，夏季傍晚人流量大，江边风大建议带外套',
      isHot: true
    },
    {
      id: 'wh_other_2',
      name: '黎黄陂路街头博物馆',
      category: '其他',
      address: '江岸区黎黄陂路',
      description: '百年老街，汇集众多欧式建筑，沿街分布小型画廊与特色小店。',
      needBooking: false,
      tips: '全天开放，小店多为10:00后营业，适合拍照打卡',
      isHot: true
    }
  ],
  '天津市': [
    // 文博馆
    {
      id: 'tj_culture_1',
      name: '天津博物馆',
      category: '文博馆',
      address: '河西区平江道62号',
      description: '国家一级文博机构，馆藏文物丰富，以明清官窑瓷器、杨柳青年画为特色。',
      needBooking: true,
      officialUrl: 'https://www.tjbwg.com/',
      wechatName: '天津博物馆',
      tips: '提前3天预约，免费开放，每日10:00、14:00有公益讲解',
      isHot: true
    },
    {
      id: 'tj_culture_2',
      name: '天津美术馆',
      category: '文博馆',
      address: '河西区平江道60号',
      description: '省级专业文博机构，建筑风格现代，聚焦国内外现当代艺术展览。',
      needBooking: true,
      officialUrl: 'http://www.tjmsg.org/',
      wechatName: '天津美术馆',
      tips: '免费预约，提前1天即可，特展期间需单独购票',
      isHot: false
    },
    {
      id: 'tj_culture_3',
      name: '周恩来邓颖超纪念馆',
      category: '文博馆',
      address: '南开区水上公园西路9号',
      description: '纪念周恩来、邓颖超同志的专题文博馆，展现革命先辈的生平事迹。',
      needBooking: true,
      officialUrl: 'http://www.zldyjng.com/',
      wechatName: '周恩来邓颖超纪念馆',
      tips: '免费预约，提前2天预约，周一闭馆（法定节假日除外）',
      isHot: false
    },
    {
      id: 'tj_culture_4',
      name: '张学良故居纪念馆',
      category: '文博馆',
      address: '和平区赤峰道78号',
      description: '张学良将军在津故居，欧式洋楼风格，还原其在津生活场景，展陈大量历史文物。',
      needBooking: true,
      wechatName: '天津张学良故居',
      tips: '需购票预约，提前1天即可，馆内有沉浸式情景剧演出',
      isHot: true
    },
    {
      id: 'tj_culture_5',
      name: '梁启超故居饮冰室',
      category: '文博馆',
      address: '河北区民族路44号、46号',
      description: '梁启超晚年在津居所，分为故居和饮冰室书斋，展陈其著作手稿与生平史料。',
      needBooking: true,
      officialUrl: 'http://www.tj-lqz.com/',
      tips: '需购票预约，故居与饮冰室联票参观，周一闭馆',
      isHot: true
    },
    {
      id: 'tj_culture_6',
      name: '李叔同故居纪念馆',
      category: '文博馆',
      address: '河北区海河东路与滨海道交口',
      description: '李叔同（弘一法师）出生地，清代民居风格，展陈其书法、篆刻及生平事迹。',
      needBooking: true,
      wechatName: '李叔同故居纪念馆',
      tips: '免费预约，提前1天，每日10:00、14:00有公益讲解',
      isHot: false
    },
    {
      id: 'tj_culture_7',
      name: '曹锟故居',
      category: '文博馆',
      address: '和平区南海路2号',
      description: '民国时期直系军阀曹锟的故居，西式建筑特色鲜明，见证近代天津历史变迁。',
      needBooking: true,
      tips: '需现场购票预约，内部复原曹锟生活场景，禁止拍照',
      isHot: false
    },
    {
      id: 'tj_culture_8',
      name: '吉鸿昌故居纪念馆',
      category: '文博馆',
      address: '和平区花园路4号',
      description: '抗日民族英雄吉鸿昌在津居所，展陈其抗日事迹与革命遗物，弘扬爱国精神。',
      needBooking: true,
      wechatName: '天津吉鸿昌纪念馆',
      tips: '免费预约，支持现场扫码预约，周一闭馆，适合红色研学',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'tj_academy_1',
      name: '南开大学',
      category: '学术殿堂',
      address: '南开区卫津路94号',
      description: '百年名校，中国顶尖高等学府，校园内思源堂、马蹄湖为标志性景观。',
      needBooking: true,
      wechatName: '南开大学',
      tips: '提前3天预约，校园参观需遵守规定，秋季银杏大道景色优美',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'tj_academy_2',
      name: '天津大学',
      category: '学术殿堂',
      address: '南开区卫津路92号',
      description: '中国第一所现代大学，工科实力雄厚，校园内北洋纪念亭、敬业湖极具特色。',
      needBooking: true,
      wechatName: '天津大学',
      tips: '提前3天预约，参观需携带身份证，春季海棠花盛开时景观最佳',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'tj_academy_3',
      name: '天津滨海图书馆',
      category: '学术殿堂',
      address: '滨海新区中央大道3998号',
      description: '全球知名网红图书馆，“书山”设计震撼人心，是天津标志性文化建筑。',
      needBooking: true,
      wechatName: '天津滨海图书馆',
      tips: '提前7天预约，“书山”区域需单独预约拍照，禁止大声喧哗',
      isHot: true,
      isLibrary: true
    },
    {
      id: 'tj_academy_4',
      name: '天津市图书馆',
      category: '学术殿堂',
      address: '南开区复康路15号',
      description: '天津市级公共图书馆，馆藏丰富，建筑风格典雅，兼具借阅与自习功能。',
      needBooking: false,
      wechatName: '天津市图书馆',
      tips: '无需预约，自习位需现场抢占，周一上午闭馆（法定节假日除外）',
      isHot: false,
      isLibrary: true
    },

    // 科技馆
    {
      id: 'tj_science_1',
      name: '天津科技馆',
      category: '科技馆',
      address: '河西区隆昌路94号',
      description: '省级综合性科技馆，互动展项丰富，适合青少年科普教育。',
      needBooking: true,
      officialUrl: 'http://www.tjskjg.com/',
      wechatName: '天津科技馆',
      tips: '提前2天预约，部分互动展项有体验时间限制，建议错峰前往',
      isHot: true
    },
    {
      id: 'tj_science_2',
      name: '天津自然博物馆',
      category: '科技馆',
      address: '河西区友谊路31号',
      description: '华北地区规模较大的自然博物馆，馆藏恐龙化石、古生物标本等珍贵展品。',
      needBooking: true,
      officialUrl: 'http://www.tjnhm.com/',
      wechatName: '天津自然博物馆',
      tips: '提前3天预约，免费开放，儿童需由成人陪同参观',
      isHot: true
    },

    // 体育馆
    {
      id: 'tj_sport_1',
      name: '天津奥林匹克中心体育场(水滴)',
      category: '体育馆',
      address: '南开区宾水西道奥林匹克中心',
      description: '2008年奥运会足球分赛场，建筑形似水滴，兼具赛事和观光功能。',
      needBooking: true,
      wechatName: '天津奥林匹克中心',
      tips: '观光票可当天预约，赛事/演出需提前购票，周边交通便利',
      isHot: true
    },
    {
      id: 'tj_sport_2',
      name: '天津体育馆',
      category: '体育馆',
      address: '南开区宾水西道',
      description: '综合性体育馆，承办篮球、排球等赛事及大型文艺演出。',
      needBooking: true,
      officialUrl: 'http://www.tjtgy.com/',
      wechatName: '天津体育馆',
      tips: '仅赛事/演出需购票预约，日常全民健身项目需现场预约',
      isHot: false
    },

    // 其他
    {
      id: 'tj_other_1',
      name: '五大道文化旅游区',
      category: '其他',
      address: '和平区成都道以南，马场道以北',
      description: '开放式历史文化街区，汇集200余座欧式风格建筑，被誉为“万国建筑博览群”。',
      needBooking: false,
      tips: '全天开放，建议骑行游览，节假日人流量大，部分故居需单独购票',
      isHot: true
    },
    {
      id: 'tj_other_2',
      name: '意式风情区',
      category: '其他',
      address: '河北区进步道与民族路交口',
      description: '开放式意式风貌街区，保留大量欧式建筑，餐饮、文创店铺集中。',
      needBooking: false,
      tips: '全天开放，夜间灯光景观优美，适合拍照打卡',
      isHot: true
    }
  ],
  '上海市': [
    // 文博馆
    {
      id: 'sh_culture_1',
      name: '上海博物馆',
      category: '文博馆',
      address: '黄浦区人民大道201号',
      description: '国家一级博物馆，馆藏文物超100万件，以青铜器、陶瓷器、书画为特色，江南文化核心展示地。',
      needBooking: true,
      officialUrl: 'https://www.shanghaimuseum.net/',
      wechatName: '上海博物馆',
      image: 'app.media.sh_museum_shanghai',
      tips: '提前7天20:00放号，每日限流，特展需单独预约，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'sh_culture_2',
      name: '中华艺术宫（中国国家馆）',
      category: '文博馆',
      address: '浦东新区上南路205号',
      description: '以上海美术馆为基础扩建，馆藏近7万件近现代美术作品，保留2010年世博会中国国家馆主体建筑。',
      needBooking: true,
      officialUrl: 'https://www.namoc.org/',
      wechatName: '中华艺术宫',
      tips: '免费预约，提前1天即可，清明上河图动态版需单独预约参观时段，周一闭馆',
      isHot: true
    },
    {
      id: 'sh_culture_3',
      name: '上海科技馆',
      category: '文博馆',
      address: '浦东新区世纪大道2000号',
      description: '综合性科技馆，设11个常设展厅和4个特种影院，以互动体验为核心的科普教育基地。',
      needBooking: true,
      officialUrl: 'https://www.sstm.org.cn/',
      wechatName: '上海科技馆',
      tips: '提前7天预约，儿童需绑定监护人信息，周末建议9点前入馆避开人流高峰',
      isHot: true
    },
    {
      id: 'sh_culture_4',
      name: '中共一大纪念馆',
      category: '文博馆',
      address: '黄浦区黄陂南路374号',
      description: '依托中共一大会址建立，由中共一大会址、宣誓大厅、基本陈列展厅等组成，再现建党百年历史。',
      needBooking: true,
      officialUrl: 'https://www.zgyd1921.com/',
      wechatName: '中共一大纪念馆',
      tips: '免费预约，提前7天放票，每日有定时公益讲解，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'sh_culture_5',
      name: '上海鲁迅纪念馆',
      category: '文博馆',
      address: '虹口区甜爱路200号',
      description: '全国首家人物类纪念馆，馆藏鲁迅手稿、书信等文物2万余件，展现鲁迅在上海的最后十年。',
      needBooking: true,
      wechatName: '上海鲁迅纪念馆',
      tips: '免费预约，提前1天即可，与鲁迅公园、虹口足球场联游更佳，周一闭馆',
      isHot: false
    },
    {
      id: 'sh_culture_6',
      name: '上海自然博物馆（静安馆）',
      category: '文博馆',
      address: '静安区北京西路510号',
      description: '亚洲最大自然博物馆之一，馆藏标本29万件，以"自然·人·和谐"为主题的沉浸式展陈。',
      needBooking: true,
      officialUrl: 'https://www.snhm.org.cn/',
      wechatName: '上海自然博物馆',
      tips: '提前7天12:00放票，4D电影需单独购票，儿童互动区需家长陪同',
      isHot: true
    },
    {
      id: 'sh_culture_7',
      name: '豫园馆藏楼',
      category: '文博馆',
      address: '黄浦区豫园路100号',
      description: '依托豫园园林建立，馆藏明清家具、玉器、瓷器等，展现江南园林文化与海派收藏特色。',
      needBooking: true,
      wechatName: '豫园',
      tips: '含在豫园门票内，无需单独预约，节假日人流量大建议错峰，夜间游园需单独购票',
      isHot: true
    },
    {
      id: 'sh_culture_8',
      name: '上海宋庆龄故居纪念馆',
      category: '文博馆',
      address: '徐汇区淮海中路1843号',
      description: '宋庆龄1948-1981年居所，欧式花园洋房，馆藏文物万余件，展现其生平与革命历程。',
      needBooking: true,
      officialUrl: 'https://www.sclg.org.cn/',
      tips: '提前1天预约，免费参观，周一闭馆，园内禁止大声喧哗',
      isHot: false
    },
    {
      id: 'sh_culture_9',
      name: '上海邮政博物馆',
      category: '文博馆',
      address: '虹口区天潼路395号',
      description: '依托上海邮政总局大楼建立，展现中国邮政发展历程，百年欧式建筑为外滩历史文化地标。',
      needBooking: true,
      wechatName: '上海邮政博物馆',
      tips: '免费预约，仅周三、六开放，钟楼观景台需单独登记，禁止无人机拍摄',
      isHot: false
    },
    {
      id: 'sh_culture_10',
      name: '上海历史博物馆（上海革命历史博物馆）',
      category: '文博馆',
      address: '黄浦区南京西路325号',
      description: '馆藏上海历史文物11万件，展现上海从渔村到国际都市的发展历程，位于原跑马总会大楼。',
      needBooking: true,
      officialUrl: 'https://www.shanghaimuseum.net/lsbg/',
      tips: '免费预约，提前1天即可，顶楼观景台可俯瞰人民广场，周一闭馆',
      isHot: false
    },
    {
      id: 'sh_culture_11',
      name: '龙美术馆（西岸馆）',
      category: '文博馆',
      address: '徐汇区龙腾大道3398号',
      description: '民营艺术博物馆，由旧煤料码头改造，主打当代艺术展，工业风建筑为西岸艺术地标。',
      needBooking: false,
      officialUrl: 'https://www.longmuseum.org/',
      tips: '部分展览需购票，无需预约，周二闭馆，馆内拍照禁止使用闪光灯',
      isHot: false
    },
    {
      id: 'sh_culture_12',
      name: '西岸美术馆',
      category: '文博馆',
      address: '徐汇区龙腾大道2600号',
      description: '与蓬皮杜中心合作的艺术机构，主打现当代艺术展，建筑设计为西岸文化名片。',
      needBooking: false,
      officialUrl: 'https://www.westbundmuseum.org/',
      tips: '常设展免费，特展需购票，无需预约，周一闭馆，馆内咖啡厅景观极佳',
      isHot: false
    },
    {
      id: 'sh_culture_13',
      name: '上海电影博物馆',
      category: '文博馆',
      address: '徐汇区漕溪北路595号',
      description: '展现中国电影发展历程，馆藏老胶片、道具、海报等，设互动体验区可模拟电影拍摄。',
      needBooking: false,
      officialUrl: 'https://www.sfmuseum.org.cn/',
      tips: '需购票入场，无需预约，周二至周日开放，讲解服务需提前1天预约',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'sh_academy_1',
      name: '复旦大学',
      category: '学术殿堂',
      address: '杨浦区邯郸路220号',
      description: '百年名校，中国顶尖综合性大学，校园内相辉堂、光华楼为标志性建筑，人文气息浓厚。',
      needBooking: true,
      wechatName: '复旦大学',
      tips: '提前3天通过官网预约，限校外人员参观，邯郸校区主门入校，禁止商业拍摄',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'sh_academy_2',
      name: '上海交通大学（徐汇校区）',
      category: '学术殿堂',
      address: '徐汇区华山路1954号',
      description: '中国顶尖工科高校，徐汇校区为老校区，百年建筑林立，钱学森图书馆坐落于此。',
      needBooking: true,
      wechatName: '上海交通大学',
      tips: '提前3天预约，校外人员每日限流，钱学森图书馆需单独预约，周一闭馆',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'sh_academy_3',
      name: '同济大学（四平路校区）',
      category: '学术殿堂',
      address: '杨浦区四平路1239号',
      description: '以建筑、土木学科闻名，校园内文远楼为中国现代建筑典范，樱花大道春季景色绝美。',
      needBooking: true,
      wechatName: '同济大学',
      tips: '提前2天预约，樱花季（3月底）需专项预约，建筑系馆禁止校外人员进入',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'sh_academy_4',
      name: '华东师范大学（中山北路校区）',
      category: '学术殿堂',
      address: '普陀区中山北路3663号',
      description: '中国顶尖师范院校，丽娃河畔为校园标志性景观，人文社科底蕴深厚。',
      needBooking: true,
      wechatName: '华东师范大学',
      tips: '提前1天预约，校外人员限工作日参观，丽娃河区域禁止垂钓',
      isHot: false,
      isUniversity: true
    },
    {
      id: 'sh_academy_5',
      name: '上海图书馆（东馆）',
      category: '学术殿堂',
      address: '浦东新区迎春路300号',
      description: '中国最大图书馆之一，东馆为新馆，馆藏超5500万册，智能化借阅系统为特色。',
      needBooking: true,
      officialUrl: 'https://www.library.sh.cn/',
      wechatName: '上海图书馆',
      tips: '提前1天预约入馆，自习位需单独预约，少儿馆限12岁以下儿童进入，周一闭馆',
      isHot: true,
      isLibrary: true
    },
    {
      id: 'sh_academy_6',
      name: '上海科学技术情报研究所图书馆',
      category: '学术殿堂',
      address: '徐汇区淮海中路1634号',
      description: '专业科技类图书馆，馆藏科技文献超200万册，为科研人员提供专业情报服务。',
      needBooking: true,
      wechatName: '上海科技情报',
      tips: '仅对科研人员开放，需单位介绍信预约，普通游客禁止入内',
      isHot: false,
      isLibrary: true
    },

    // 科技馆
    {
      id: 'sh_science_1',
      name: '上海天文馆',
      category: '科技馆',
      address: '浦东新区临港大道380号',
      description: '全球建筑面积最大的天文馆，设三大展区和球幕影院，沉浸式宇宙探索体验。',
      needBooking: true,
      officialUrl: 'https://www.sstm.org.cn/twg/',
      wechatName: '上海天文馆',
      tips: '提前7天12:00放票，秒空需拼手速，球幕电影需单独购票，禁止携带自拍杆',
      isHot: true
    },
    {
      id: 'sh_science_2',
      name: '上海海洋水族馆',
      category: '科技馆',
      address: '浦东新区陆家嘴环路1388号',
      description: '亚洲最大水族馆之一，拥有155米海底隧道，展示来自五大洲四大洋的450余种水生生物。',
      needBooking: false,
      officialUrl: 'https://www.shanghaiaquarium.com/',
      tips: '需购票入场，无需预约，10:00-14:00人流量最大，建议早到或下午3点后参观',
      isHot: true
    },
    {
      id: 'sh_science_3',
      name: '上海航宇科普中心',
      category: '科技馆',
      address: '闵行区沪闵路7900号',
      description: '中国首个航空航天科普基地，馆藏真机、模型200余件，设模拟飞行体验区。',
      needBooking: true,
      wechatName: '上海航宇科普中心',
      tips: '免费预约，提前1天即可，模拟飞行体验需现场预约，周二闭馆',
      isHot: false
    },
    {
      id: 'sh_science_4',
      name: '中国航海博物馆',
      category: '科技馆',
      address: '浦东新区申港大道197号',
      description: '国家级航海博物馆，馆藏文物2万余件，设船舶、航海、港口等展区，互动体验丰富。',
      needBooking: true,
      officialUrl: 'https://www.shmsmuseum.cn/',
      tips: '提前1天预约，门票半价优惠日为每月第一个周二，儿童模拟航海体验需排队',
      isHot: false
    },

    // 体育馆
    {
      id: 'sh_sport_1',
      name: '上海体育场（八万人体育场）',
      category: '体育馆',
      address: '徐汇区天钥桥路666号',
      description: '上海标志性体育场馆，可容纳8万人，承办中超联赛、演唱会等大型活动。',
      needBooking: true,
      officialUrl: 'https://www.shanghaistadium.com/',
      wechatName: '上海体育场',
      tips: '仅赛事/演出需购票预约，场馆外部参观无需预约，周边地铁1/4号线直达',
      isHot: true
    },
    {
      id: 'sh_sport_2',
      name: '梅赛德斯-奔驰文化中心',
      category: '体育馆',
      address: '浦东新区世博大道1200号',
      description: '多功能文化体育场馆，可容纳1.8万人，主打演唱会、电竞比赛、体育赛事等。',
      needBooking: true,
      officialUrl: 'https://www.mercedes-benz-arena.com/',
      wechatName: '梅赛德斯奔驰文化中心',
      tips: '需购票入场，不同活动预约方式不同，场馆内禁止携带瓶装水',
      isHot: true
    },
    {
      id: 'sh_sport_3',
      name: '虹口足球场',
      category: '体育馆',
      address: '虹口区东江湾路444号',
      description: '中国首个专业足球场，可容纳3.5万人，为上海申花队主场，兼办演唱会等活动。',
      needBooking: true,
      wechatName: '虹口足球场',
      tips: '赛事门票需通过俱乐部预约，演唱会门票通过票务平台购买，周边停车紧张建议公共交通',
      isHot: false
    },
    {
      id: 'sh_sport_4',
      name: '源深体育中心',
      category: '体育馆',
      address: '浦东新区张杨路1458号',
      description: '综合性体育场馆，以篮球、羽毛球、游泳等群众体育项目为主，为上海男篮主场。',
      needBooking: true,
      officialUrl: 'https://www.yssportscenter.com/',
      tips: '日常健身项目需提前1天预约，场馆开放时间为6:00-22:00，节假日需错峰',
      isHot: false
    },

    // 其他
    {
      id: 'sh_other_1',
      name: '外滩',
      category: '其他',
      address: '黄浦区中山东一路',
      description: '上海标志性滨江景观带，汇集52幢风格各异的古典复兴大楼，被誉为"万国建筑博览群"。',
      needBooking: false,
      tips: '全天开放，夜景最佳观赏时间为19:00-22:00，节假日人流量极大建议错峰',
      isHot: true
    },
    {
      id: 'sh_other_2',
      name: '新天地',
      category: '其他',
      address: '黄浦区马当路245号',
      description: '以上海石库门建筑为基础改造的休闲街区，集餐饮、购物、文化于一体的海派地标。',
      needBooking: false,
      tips: '全天开放，10:00-22:00为营业高峰，中共一大会址新天地馆需单独预约',
      isHot: true
    },
    {
      id: 'sh_other_3',
      name: '陆家嘴中心绿地',
      category: '其他',
      address: '浦东新区陆家嘴东路160号',
      description: '陆家嘴金融区核心开放式绿地，可近距离观赏东方明珠、上海中心等摩天建筑群。',
      needBooking: false,
      tips: '全天开放，夏季17:00后凉爽，拍照建议使用广角镜头，禁止搭帐篷',
      isHot: true
    },
    {
      id: 'sh_other_4',
      name: '武康路历史文化街区',
      category: '其他',
      address: '徐汇区武康路',
      description: '百年历史马路，汇集巴金故居、武康大楼等历史建筑，沿街分布特色小店与咖啡馆。',
      needBooking: false,
      tips: '全天开放，小店多为10:00后营业，武康大楼拍照最佳位置在淮海中路交叉口',
      isHot: true
    },
    {
      id: 'sh_other_5',
      name: '思南公馆',
      category: '其他',
      address: '黄浦区思南路51号',
      description: '上海历史文化风貌区，51幢老洋房组成的休闲街区，集文化、餐饮、住宿于一体。',
      needBooking: false,
      tips: '全天开放，周末有露天音乐会，部分展馆需购票参观，禁止宠物入内',
      isHot: false
    },
    {
      id: 'sh_other_6',
      name: '豫园商城',
      category: '其他',
      address: '黄浦区豫园路100号',
      description: '依托豫园建立的特色商业街区，汇集上海老字号与特色小吃，江南园林与市井文化交融。',
      needBooking: false,
      tips: '全天开放，节假日人流量极大，九曲桥需排队通行，小笼包建议错峰品尝',
      isHot: true
    }
  ],
  '成都市': [
    // 文博馆
    {
      id: 'cd_culture_1',
      name: '四川博物院',
      category: '文博馆',
      address: '成都市青羊区浣花南路251号',
      description: '国家一级博物馆，西南地区综合性文博标杆，藏张大千画作、三星堆青铜器、民族文物等珍品。',
      needBooking: true,
      officialUrl: 'https://www.scmuseum.cn/',
      wechatName: '四川博物院',
      image: 'app.media.cd_museum_sichuan',
      tips: '提前7天预约，免费参观，特展单独购票，周一闭馆（法定节假日除外）',
      isHot: true
    },
    {
      id: 'cd_culture_2',
      name: '成都博物馆',
      category: '文博馆',
      address: '成都市青羊区小河街1号（天府广场西侧）',
      description: '西南规模最大的城市综合博物馆，常设“花重锦官城”成都通史展与皮影木偶专题展。',
      needBooking: true,
      officialUrl: 'https://www.cdmuseum.com/',
      wechatName: '成都博物馆',
      tips: '提前14天19:00放号，周五周六开放至20:30，儿童博物馆需亲子同行',
      isHot: true
    },
    {
      id: 'cd_culture_3',
      name: '成都武侯祠博物馆（汉昭烈庙）',
      category: '文博馆',
      address: '成都市武侯区武侯祠大街231号',
      description: '全国唯一君臣合祀祠庙，三国文化核心地标，馆藏蜀汉文物、唐碑宋刻，祠庙园林相映成趣。',
      needBooking: true,
      officialUrl: 'https://www.wuhouci.net.cn/',
      wechatName: '成都武侯祠',
      tips: '需购票预约，春节/三国文化节人流密集，联游锦里古街更省心',
      isHot: true
    },
    {
      id: 'cd_culture_4',
      name: '成都杜甫草堂博物馆',
      category: '文博馆',
      address: '成都市青羊区青华路37号',
      description: '纪念诗圣杜甫的胜地，唐代风格茅屋故居，馆藏历代杜诗版本、书画，园林清幽适合静心游览。',
      needBooking: true,
      officialUrl: 'https://www.dufu.org/',
      wechatName: '成都杜甫草堂博物馆',
      tips: '提前3天预约，秋季银杏季（11月）景色绝美，建议早到避峰',
      isHot: true
    },
    {
      id: 'cd_culture_5',
      name: '成都金沙遗址博物馆',
      category: '文博馆',
      address: '成都市青羊区金沙遗址路2号',
      description: '古蜀文明重要遗址，出土“太阳神鸟”金饰，常设遗迹馆与陈列馆，展现商周时期成都平原文化。',
      needBooking: true,
      officialUrl: 'https://www.jinshasitemuseum.com/',
      wechatName: '成都金沙遗址博物馆',
      tips: '提前7天预约，太阳神鸟主题文创值得选购，夜间灯光展需单独购票',
      isHot: true
    },
    {
      id: 'cd_culture_6',
      name: '永陵博物馆（王建墓）',
      category: '文博馆',
      address: '成都市金牛区永陵路10号',
      description: '五代十国前蜀皇帝王建的陵墓，墓室浮雕二十四伎乐为中国古代音乐史瑰宝，地面园林静谧。',
      needBooking: true,
      wechatName: '成都永陵博物馆',
      tips: '提前1天预约，免费参观，伎乐石刻讲解建议听专业导览',
      isHot: false
    },
    {
      id: 'cd_culture_7',
      name: '成都自然博物馆（成都理工大学博物馆）',
      category: '文博馆',
      address: '成都市成华区成华大道二段1号',
      description: '西南最大自然博物馆，馆藏恐龙化石、矿产标本6万余件，沉浸式古生物展陈极具冲击力。',
      needBooking: true,
      wechatName: '成都自然博物馆',
      tips: '提前3天预约，恐龙厅儿童需家长陪同，馆内禁止使用闪光灯',
      isHot: true
    },
    {
      id: 'cd_culture_8',
      name: '成都宋瓷博物馆（温江）',
      category: '文博馆',
      address: '成都市温江区南江路8号',
      description: '聚焦宋代陶瓷的专题博物馆，馆藏南宋官窑、龙泉窑精品，再现宋代文人瓷艺审美。',
      needBooking: false,
      tips: '购票即可入馆，周末人少，适合陶瓷爱好者深度参观',
      isHot: false
    },
    {
      id: 'cd_culture_9',
      name: '四川美术馆',
      category: '文博馆',
      address: '成都市青羊区人民西路20号',
      description: '省级专业美术机构，建筑风格现代，主打现当代美术展与四川本土艺术流派展示。',
      needBooking: true,
      officialUrl: 'https://www.sichuanartmuseum.net/',
      wechatName: '四川美术馆',
      tips: '免费预约，提前1天，特展期间建议工作日前往，馆内严禁饮食',
      isHot: false
    },
    {
      id: 'cd_culture_10',
      name: '建川博物馆聚落',
      category: '文博馆',
      address: '成都市大邑县安仁镇迎宾路二段550号',
      description: '国内规模最大的民间博物馆群，分抗战、民俗、红色年代等系列展馆，文物数量与品类丰富。',
      needBooking: true,
      officialUrl: 'https://www.jcmuseum.org/',
      tips: '需购票预约，展馆分散建议预留一整天，景区内有观光车',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'cd_academy_1',
      name: '四川大学（望江校区）',
      category: '学术殿堂',
      address: '成都市武侯区一环路南一段24号',
      description: '百年川大，西部顶尖综合高校，红楼、明德楼等老建筑典雅，华西校区医学底蕴深厚。',
      needBooking: false,
      wechatName: '四川大学',
      tips: '刷身份证直接入校，华西坝秋季银杏、望江校区荷花池是打卡点',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'cd_academy_2',
      name: '电子科技大学（清水河校区）',
      category: '学术殿堂',
      address: '成都市高新区（西区）西源大道2006号',
      description: '中国顶尖电子信息高校，“森林大学”，银杏大道（11月）是成都秋季网红打卡地。',
      needBooking: true,
      wechatName: '平安成电',
      tips: '通过公众号预约，银杏季需专项预约，校内禁止无人机航拍',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'cd_academy_3',
      name: '成都图书馆',
      category: '学术殿堂',
      address: '成都市青羊区文翁路98号',
      description: '成都市中心大型公共图书馆，古籍与地方文献丰富，阅览环境舒适，文化讲座常态化开展。',
      needBooking: true,
      officialUrl: 'https://www.cdlib.org.cn/',
      wechatName: '成都图书馆',
      tips: '实名预约入馆，自习位上午紧张，周一闭馆，可免费借阅图书',
      isHot: true,
      isLibrary: true
    },

    // 科技馆
    {
      id: 'cd_science_1',
      name: '四川科技馆',
      category: '科技馆',
      address: '成都市青羊区人民中路一段16号（天府广场北侧）',
      description: '西南大型综合性科技馆，航空航天、机器人、防灾避险等互动展区，适合全年龄段科普研学。',
      needBooking: true,
      officialUrl: 'https://www.scstm.org/',
      wechatName: '四川科技馆',
      tips: '提前3天17:00放票，火箭发射模拟秀10:30/14:30两场，儿童需监护人陪同',
      isHot: true
    },
    {
      id: 'cd_science_2',
      name: '成都科幻馆',
      category: '科技馆',
      address: '成都市郫都区德源街道静园东路',
      description: '世界科幻大会永久会址，未来感建筑，常设科幻展品、影视特效体验，是科幻迷的朝圣地。',
      needBooking: true,
      officialUrl: 'https://www.chengdusfcon.com/',
      wechatName: '成都科幻馆',
      tips: '提前7天预约，特展/沙龙活动需单独报名，馆内餐饮价格偏高建议自带',
      isHot: true
    },
    {
      id: 'cd_science_3',
      name: '电子科技博物馆',
      category: '科技馆',
      address: '成都市高新区（西区）西源大道2006号（电子科大清水河校区内）',
      description: '国内首个综合性电子科技博物馆，展示电子信息产业百年发展史，实物藏品丰富。',
      needBooking: true,
      wechatName: '电子科技博物馆',
      tips: '与电子科大入校预约同步，讲解需提前1天在公众号申请，免费参观',
      isHot: false
    },

    // 体育馆
    {
      id: 'cd_sport_1',
      name: '凤凰山体育公园（五粮液文化体育中心）',
      category: '体育馆',
      address: '成都市金牛区北星大道一段',
      description: '成都大运会篮球决赛场馆，含6万座专业足球场与1.8万座综合体育馆，承接顶级赛事与演唱会。',
      needBooking: true,
      officialUrl: 'https://www.fhsports.cn/',
      wechatName: '凤凰山体育公园',
      tips: '赛事/演出需购票预约，自驾停车建议停P2/P3区，地铁5号线直达',
      isHot: true
    },
    {
      id: 'cd_sport_2',
      name: '四川省体育馆',
      category: '体育馆',
      address: '成都市武侯区人民南路四段8号',
      description: '成都老牌体育地标，彩蝶式外观，长期承办CBA、羽毛球等赛事及中型演唱会，群众健身项目丰富。',
      needBooking: true,
      officialUrl: 'https://www.sichuansports.org/',
      wechatName: '四川省体育馆',
      tips: '日常健身需提前预约，大型活动期间周边交通管制，优先地铁',
      isHot: false
    },
    {
      id: 'cd_sport_3',
      name: '东安湖体育公园',
      category: '体育馆',
      address: '成都市龙泉驿区车城大道旁',
      description: '成都大运会主场馆，一场三馆格局，主体育场可容纳4万余人，赛后向市民开放健身与参观。',
      needBooking: true,
      wechatName: '东安湖体育公园',
      tips: '参观需预约，体育场馆需付费，湖边绿道适合骑行散步',
      isHot: false
    },

    // 其他
    {
      id: 'cd_other_1',
      name: '锦里古街',
      category: '其他',
      address: '成都市武侯区武侯祠大街231号（武侯祠东侧）',
      description: '川西民俗风情古街，仿古建筑，特色小吃、手工艺品、茶馆戏台，夜间灯笼亮起氛围感极佳。',
      needBooking: false,
      tips: '全天开放，夜间（19:00-21:00）最热闹，小吃价格略高于市区',
      isHot: true
    },
    {
      id: 'cd_other_2',
      name: '宽窄巷子历史文化街区',
      category: '其他',
      address: '成都市青羊区同仁路以东、长顺街以西',
      description: '由宽巷子、窄巷子、井巷子组成，清末民初川西民居，汇集老字号、茶馆、民宿，成都城市名片。',
      needBooking: false,
      tips: '全天开放，避开中午人流，井巷子文创市集适合淘伴手礼，禁止宠物入内',
      isHot: true
    },
    {
      id: 'cd_other_3',
      name: '春熙路 - 太古里商圈',
      category: '其他',
      address: '成都市锦江区春熙路步行街、中纱帽街8号',
      description: '成都核心商业地标，现代商场与清末民初街巷（太古里）交融，IFS爬墙熊猫是必打卡点。',
      needBooking: false,
      tips: '全天开放，周末与节假日人流密集，夜间灯光璀璨适合拍照',
      isHot: true
    },
    {
      id: 'cd_other_4',
      name: '望平街滨河街区',
      category: '其他',
      address: '成都市成华区望平街',
      description: '锦江岸边的文艺街区，咖啡馆、书店、文创小店林立，河景座位惬意，适合午后休闲。',
      needBooking: false,
      tips: '10:00后店铺陆续营业，夏季傍晚可乘游船夜游锦江',
      isHot: false
    }
  ],
  '重庆市': [
    // 文博馆
    {
      id: 'cq_culture_1',
      name: '重庆中国三峡博物馆（重庆博物馆）',
      category: '文博馆',
      address: '重庆市渝中区人民路236号（人民大礼堂旁）',
      description: '国家一级博物馆，集巴渝、三峡、抗战、移民文化于一体，馆藏三峡文物、汉代陶俑、西南民族文物珍品。',
      needBooking: true,
      officialUrl: 'https://www.3gmuseum.cn/',
      wechatName: '重庆中国三峡博物馆',
      image: 'app.media.cq_museum_threegorges',
      tips: '提前7天预约，周一闭馆（法定节假日除外），《重庆大轰炸》半景画定时播放',
      isHot: true
    },
    {
      id: 'cq_culture_2',
      name: '重庆红岩革命历史博物馆（红岩革命纪念馆）',
      category: '文博馆',
      address: '重庆市渝中区红岩村52号',
      description: '抗战与红色文化核心地标，含红岩村、曾家岩50号、渣滓洞、白公馆等多处旧址，馆藏革命文物与史料。',
      needBooking: true,
      officialUrl: 'https://hybwg.cq.gov.cn/',
      wechatName: '红岩博物馆',
      tips: '免费预约，提前3天，景区分散建议乘坐景区直通车，渣滓洞周一不开放旧址内部',
      isHot: true
    },
    {
      id: 'cq_culture_3',
      name: '重庆自然博物馆（北碚馆）',
      category: '文博馆',
      address: '重庆市北碚区金华路398号',
      description: '西南大型自然类博物馆，馆藏古生物化石、动植物标本11万余件，恐龙化石展区极具震撼力。',
      needBooking: false,
      officialUrl: 'https://www.cqnm.org/',
      wechatName: '重庆自然博物馆',
      tips: '免费入馆，无需预约，周一闭馆，儿童区有互动科普装置',
      isHot: false
    },
    {
      id: 'cq_culture_4',
      name: '重庆抗战遗址博物馆（黄山官邸）',
      category: '文博馆',
      address: '重庆市南岸区南山植物园路1号',
      description: '抗战时期国民政府重要办公地，保存完好的官邸建筑群，展示抗战陪都历史与军事文化。',
      needBooking: true,
      wechatName: '重庆抗战遗址博物馆',
      tips: '需购票预约，周一闭馆，山路较陡建议穿舒适鞋子，夏季注意防暑',
      isHot: false
    },
    {
      id: 'cq_culture_5',
      name: '重庆大韩民国临时政府旧址陈列馆',
      category: '文博馆',
      address: '重庆市渝中区七星岗莲花池38号',
      description: '二战时期大韩民国临时政府在华办公旧址，展现中韩联合抗日的历史篇章。',
      needBooking: true,
      officialUrl: 'https://www.koreangovmuseum.com/',
      tips: '免费预约，提前1天，周一闭馆，有韩语志愿讲解服务',
      isHot: false
    },
    {
      id: 'cq_culture_6',
      name: '中国民主党派历史陈列馆（特园）',
      category: '文博馆',
      address: '重庆市渝中区嘉陵桥东村35号',
      description: '依托特园旧址建立，展示中国民主党派诞生与发展历程，馆藏多党合作历史文物。',
      needBooking: true,
      wechatName: '民主党派历史陈列馆',
      tips: '免费预约，提前1天，周一闭馆，适合统战与近代史研学',
      isHot: false
    },
    {
      id: 'cq_culture_7',
      name: '重庆工业文化博览园（重庆工业博物馆）',
      category: '文博馆',
      address: '重庆市大渡口区义渡路999号',
      description: '由重钢旧址改造，展现重庆从洋务运动到现代工业的发展历程，工业风建筑与大型设备展品极具特色。',
      needBooking: false,
      tips: '免费开放，无需预约，周一闭馆，园区较大建议预留2小时参观',
      isHot: false
    },
    {
      id: 'cq_culture_8',
      name: '重庆美术馆',
      category: '文博馆',
      address: '重庆市渝中区临江路1号',
      description: '市级专业美术机构，建筑融合巴渝吊脚楼风格，主打当代美术展与重庆本土艺术流派展示。',
      needBooking: true,
      officialUrl: 'https://www.cqam.org/',
      wechatName: '重庆美术馆',
      tips: '免费预约，提前1天，周二闭馆，特展期间拍照禁止使用闪光灯',
      isHot: false
    },
    {
      id: 'cq_culture_9',
      name: '重庆史迪威博物馆',
      category: '文博馆',
      address: '重庆市渝中区嘉陵新路63号',
      description: '纪念二战时期美军中将史迪威，展现中美联合抗日的军事合作历史，馆藏史迪威相关文物与影像资料。',
      needBooking: true,
      tips: '免费预约，提前1天，周一闭馆，馆内空间不大，建议与曾家岩50号联游',
      isHot: false
    },

    // 学术殿堂
    {
      id: 'cq_academy_1',
      name: '重庆大学（A校区）',
      category: '学术殿堂',
      address: '重庆市沙坪坝区沙正街174号',
      description: '百年工科强校，老校区红砖建筑典雅，含重大近代建筑群，虎溪校区则是现代化园林式校园。',
      needBooking: true,
      wechatName: '平安重大',
      tips: '通过公众号提前3天预约，虎溪校区银杏季（11月）需专项预约，禁止商业拍摄',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'cq_academy_2',
      name: '四川美术学院（黄桷坪校区）',
      category: '学术殿堂',
      address: '重庆市九龙坡区黄桷坪正街108号',
      description: '西南艺术教育标杆，黄桷坪校区涂鸦街是网红打卡地，校园内罗中立美术馆收藏大量当代艺术作品。',
      needBooking: true,
      wechatName: '平安川美',
      tips: '提前7天预约，涂鸦街无需预约，美术馆内禁止饮食',
      isHot: true,
      isUniversity: true
    },
    {
      id: 'cq_academy_3',
      name: '重庆图书馆',
      category: '学术殿堂',
      address: '重庆市沙坪坝区凤天大道106号',
      description: '前身是国立罗斯福图书馆，馆藏民国文献、古籍、联合国资料三大特色，西南大型公共图书馆。',
      needBooking: true,
      officialUrl: 'https://www.cqlib.cn/',
      wechatName: '重庆图书馆',
      tips: '入馆免费，自习位需单独预约，周一14:00后开放，可免费借阅图书',
      isHot: true,
      isLibrary: true
    },

    // 科技馆
    {
      id: 'cq_science_1',
      name: '重庆科技馆',
      category: '科技馆',
      address: '重庆市江北区江北城文星门街7号',
      description: '现代化综合性科普场馆，设生活科技、防灾科技、宇航科技等6大主题展厅+儿童科学乐园，互动展项400余件。',
      needBooking: true,
      officialUrl: 'https://www.cqkjg.cn/',
      wechatName: '重庆科技馆',
      tips: '提前2天20:00放号，免费参观，4D电影需单独购票，周一闭馆',
      isHot: true
    },
    {
      id: 'cq_science_2',
      name: '重庆白鹤梁水下博物馆',
      category: '科技馆',
      address: '重庆市涪陵区滨江大道二段185号',
      description: '世界首座水下博物馆，保护唐代至清代的白鹤梁题刻，通过水下参观廊道观赏千年水文石刻。',
      needBooking: true,
      officialUrl: 'https://www.bhlmuseum.com/',
      tips: '需购票预约，提前1天，水下廊道参观有固定时段，禁止使用闪光灯',
      isHot: false
    },
    {
      id: 'cq_science_3',
      name: '重庆建川博物馆（兵工署第一工厂旧址）',
      category: '科技馆',
      address: '重庆市九龙坡区谢家湾付家沟1号',
      description: '防空洞改造的博物馆群，含兵工、抗战、民俗等展馆，展示重庆工业与军事历史，工业风浓厚。',
      needBooking: true,
      officialUrl: 'https://www.jcmuseum.org/',
      tips: '需购票预约，展馆分布在多个防空洞，建议穿平底鞋，夏季洞内凉爽',
      isHot: false
    },

    // 体育馆
    {
      id: 'cq_sport_1',
      name: '重庆奥林匹克体育中心（重庆奥体中心）',
      category: '体育馆',
      address: '重庆市九龙坡区袁家岗1号',
      description: '重庆最大综合性体育场馆，主体育场可容纳6万余人，承办中超、演唱会、大型体育赛事。',
      needBooking: true,
      wechatName: '重庆奥体中心',
      tips: '赛事/演出需购票预约，日常健身可现场预约，周边地铁2号线直达',
      isHot: true
    },
    {
      id: 'cq_sport_2',
      name: '大田湾体育场（重庆体育博物馆）',
      category: '体育馆',
      address: '重庆市渝中区大田湾全民健身中心',
      description: '新中国首座甲级体育场，配套重庆体育博物馆，展示重庆百年体育发展历程与贺龙元帅体育相关文物。',
      needBooking: true,
      wechatName: '重庆体育博物馆',
      tips: '博物馆免费预约，提前1天，周一闭馆，体育场可免费参观外观',
      isHot: false
    },

    // 其他
    {
      id: 'cq_other_1',
      name: '洪崖洞民俗风貌区',
      category: '其他',
      address: '重庆市渝中区嘉陵江滨江路88号',
      description: '依山而建的吊脚楼建筑群，巴渝传统风貌，夜景璀璨，餐饮、文创、民俗表演集中，是重庆地标。',
      needBooking: false,
      tips: '全天开放，夜景最佳观赏19:30-21:30，建议错峰步行，周边停车困难',
      isHot: true
    },
    {
      id: 'cq_other_2',
      name: '解放碑步行街',
      category: '其他',
      address: '重庆市渝中区民族路177号',
      description: '抗战胜利纪功碑，重庆核心商圈地标，高楼林立，商场、美食、潮流店铺密集，是体验重庆都市活力的好去处。',
      needBooking: false,
      tips: '全天开放，夜间人流大，八一好吃街就在附近，可品尝重庆小吃',
      isHot: true
    },
    {
      id: 'cq_other_3',
      name: '山城巷传统风貌区',
      category: '其他',
      address: '重庆市渝中区中兴路234号',
      description: '依山而建的老重庆街巷，保留着明清至民国的民居与步道，悬崖步道可俯瞰长江，文创小店与茶馆分布其间。',
      needBooking: false,
      tips: '全天开放，10:00后店铺陆续营业，爬坡较多建议穿舒适鞋子',
      isHot: false
    },
    {
      id: 'cq_other_4',
      name: '李子坝轻轨穿楼观景平台',
      category: '其他',
      address: '重庆市渝中区李子坝正街39号',
      description: '重庆网红地标，轨道交通2号线列车穿居民楼而过，观景平台是拍摄打卡的最佳位置。',
      needBooking: false,
      tips: '全天免费开放，轻轨每2-3分钟一班，最佳拍摄时间是上午10点前',
      isHot: true
    },
    {
      id: 'cq_other_5',
      name: '十八梯传统风貌区',
      category: '其他',
      address: '重庆市渝中区中兴路1号',
      description: '连接上下半城的百年老街，改造后保留巴渝风貌，吊脚楼、青石板路、传统店铺，展现老重庆市井生活。',
      needBooking: false,
      tips: '全天开放，夜间灯笼亮起氛围感强，可顺路参观山城巷',
      isHot: true
    }
  ]
};