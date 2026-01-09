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
  ]
};