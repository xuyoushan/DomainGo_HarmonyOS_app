export interface MetroLine {
  name: string;
  color: string;
  desc: string;
  icon: string;
}

export interface MetroInfo {
  lineCount: number;
  totalMileage: string;
  basePrice: string;
  notice: string;
  lines: MetroLine[];
}

export interface UniqueTraffic {
  name: string;
  type: string;
  price: string;
  operationTime: string;
  desc: string;
  color: string;
}

export interface CityLinks {
  metroMap: string;
  realTimeBus: string;
}

export interface CityTrafficConfig {
  city: string;
  metro: MetroInfo;
  uniqueTraffic: UniqueTraffic[];
  links: CityLinks;
}

// 北京市交通数据
export const BEIJING_TRAFFIC_DATA: CityTrafficConfig = {
  city: '北京市',
  metro: {
    lineCount: 27,
    totalMileage: '836km+',
    basePrice: '3元起',
    notice: '按里程计价，封顶约10元',
    lines: [
      { name: '1号线', color: '#FF4D4F', desc: '东西向骨干线路，贯穿长安街核心段', icon: 'subway' },
      { name: '2号线', color: '#0079FF', desc: '环线线路，覆盖北京站、北京西站等交通枢纽', icon: 'subway' },
      { name: '4号线', color: '#00B500', desc: '南北向骨干，连接安河桥北与天宫院，贯穿中关村', icon: 'subway' },
      { name: '5号线', color: '#C22E30', desc: '贯穿京城南北，连接天通苑与宋家庄', icon: 'subway' },
      { name: '6号线', color: '#7CB305', desc: '东西向大动脉，连接金安桥与潞城', icon: 'subway' },
      { name: '7号线', color: '#FF9D00', desc: '西起北京西站，东至环球度假区', icon: 'subway' },
      { name: '8号线', color: '#0018A8', desc: '南北中轴线线路，连接朱辛庄与瀛海', icon: 'subway' },
      { name: '9号线', color: '#836FFF', desc: '连接北京西站与国家图书馆，贯通丰台与海淀', icon: 'subway' },
      { name: '10号线', color: '#FF7500', desc: '北京第二条环线，覆盖CBD、中关村等核心区', icon: 'subway' },
      { name: '13号线', color: '#FFB800', desc: '连接西二旗与东直门，服务北部通勤', icon: 'subway' },
      { name: '14号线', color: '#00875A', desc: '东西向快线，连接善各庄与张郭庄', icon: 'subway' },
      { name: '15号线', color: '#8E2585', desc: '连接清华东路西口与俸伯，服务顺义区', icon: 'subway' },
      { name: '16号线', color: '#5E60CE', desc: '南北向快线，连接北安河与宛平城', icon: 'subway' },
      { name: '17号线', color: '#00B8D9', desc: '未来科学城至亦庄的大站快线', icon: 'subway' },
      { name: '19号线', color: '#FF56C9', desc: '牡丹园至新宫的南北快线，最高时速100km/h', icon: 'subway' },
      { name: '昌平线', color: '#E5A5A5', desc: '连接昌平西山口与西土城', icon: 'subway' },
      { name: '亦庄线', color: '#6CB2EB', desc: '宋家庄至亦庄火车站，服务亦庄开发区', icon: 'subway' },
      { name: '房山线', color: '#F6A800', desc: '郭公庄至阎村东，服务房山区', icon: 'subway' },
      { name: '大兴线', color: '#9F7AEA', desc: '公益西桥至天宫院，服务大兴区', icon: 'subway' },
      { name: '燕房线', color: '#A1887F', desc: '阎村东至燕山，北京首条全自动驾驶线路', icon: 'subway' },
      { name: 'S1线', color: '#FF8A65', desc: '石厂至苹果园，北京首条磁悬浮线路', icon: 'rail' },
      { name: '首都机场线', color: '#B2EBF2', desc: '东直门至首都机场T3，快速接驳机场', icon: 'airport' },
      { name: '大兴机场线', color: '#80CBC4', desc: '草桥至大兴机场，19分钟直达', icon: 'airport' },
      { name: '亦庄T1线', color: '#FFAB91', desc: '亦庄新城现代有轨电车，连接定海园与屈庄', icon: 'tram' },
      { name: '西郊线', color: '#4CAF50', desc: '巴沟至香山，有轨电车，赏西山红叶专线', icon: 'tram' },
      { name: '亦庄新城线', color: '#9C27B0', desc: '连接亦庄与中心城区的新建线路', icon: 'subway' },
      { name: '平谷线', color: '#FF6E40', desc: '东大桥至平谷，服务东部远郊区县', icon: 'subway' }
    ]
  },
  uniqueTraffic: [
    {
      name: '前门铛铛车',
      type: '复古有轨电车',
      price: '15元',
      operationTime: '09:00 - 17:00',
      desc: '复刻老北京有轨电车风貌，鸣响清脆铛铛声，穿梭灰砖古街，沉浸式感受京味烟火气',
      color: '#8D6E63'
    },
    {
      name: '北京观光巴士',
      type: '双层观光巴士',
      price: '100元/24小时',
      operationTime: '08:00 - 20:00',
      desc: '全景天窗设计，串联故宫、长城等核心景区，一站式解锁京城古今风貌与人文底蕴',
      color: '#FF6B6B'
    },
    {
      name: '西郊线有轨电车',
      type: '现代有轨电车',
      price: '3元',
      operationTime: '05:30 - 23:00',
      desc: '北京首条现代有轨电车，中式站台搭配沿途盛景，春日赏玉兰、秋日观红叶，步步皆风景',
      color: '#4CAF50'
    },
    {
      name: 'S1线磁悬浮',
      type: '中低速磁悬浮',
      price: '2元起',
      operationTime: '05:20 - 23:40',
      desc: '北京首条磁悬浮线路，无轮轨摩擦噪音极低，悬浮行驶体验独特，兼具环保与科技感',
      color: '#FF8A65'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=北京地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

// 上海市交通数据
export const SHANGHAI_TRAFFIC_DATA: CityTrafficConfig = {
  city: '上海市',
  metro: {
    lineCount: 20,
    totalMileage: '831km+',
    basePrice: '3元起',
    notice: '按里程计价，封顶约15元',
    lines: [
      { name: '1号线', color: '#D32026', desc: '南北向骨干，连接莘庄与富锦路，贯穿人民广场', icon: 'subway' },
      { name: '2号线', color: '#009944', desc: '东西向主动脉，连接浦东机场与徐泾东，覆盖陆家嘴', icon: 'subway' },
      { name: '3号线', color: '#FF7D00', desc: '环线北段，上海南站至江杨北路，高架线路为主', icon: 'rail' },
      { name: '4号线', color: '#3091F2', desc: '唯一环线，连接宜山路至宜山路，覆盖上海火车站', icon: 'subway' },
      { name: '5号线', color: '#99CC00', desc: '莘庄至奉贤新城，服务闵行与奉贤两区', icon: 'subway' },
      { name: '6号线', color: '#7D4498', desc: '港城路至东方体育中心，服务浦东金桥、张江片区', icon: 'subway' },
      { name: '7号线', color: '#FF6EC7', desc: '美兰湖至花木路，贯穿静安寺、世博园区', icon: 'subway' },
      { name: '8号线', color: '#00C1DE', desc: '沈杜公路至市光路，连接浦江镇与虹口足球场', icon: 'subway' },
      { name: '9号线', color: '#996633', desc: '松江南站至曹路，贯穿徐家汇、陆家嘴、世纪大道', icon: 'subway' },
      { name: '10号线', color: '#6A737C', desc: '基隆路至虹桥火车站，覆盖虹桥机场、豫园等核心区', icon: 'subway' },
      { name: '11号线', color: '#FFCC00', desc: '迪士尼至花桥，国内首条跨省地铁，连接上海与昆山', icon: 'subway' },
      { name: '12号线', color: '#8E4585', desc: '七莘路至金海路，贯穿南京西路、陕西南路', icon: 'subway' },
      { name: '13号线', color: '#66CC99', desc: '金运路至张江路，覆盖世博园、新天地、南京东路', icon: 'subway' },
      { name: '14号线', color: '#FFBA00', desc: '封浜至桂桥路，贯穿静安寺、陆家嘴等核心商圈', icon: 'subway' },
      { name: '15号线', color: '#00B0F0', desc: '顾村公园至紫竹高新区，服务普陀、徐汇、闵行', icon: 'subway' },
      { name: '16号线', color: '#206694', desc: '龙阳路至滴水湖，服务临港新片区', icon: 'subway' },
      { name: '17号线', color: '#00868B', desc: '虹桥火车站至东方绿舟，服务青浦片区', icon: 'subway' },
      { name: '18号线', color: '#B28DFF', desc: '航头至长江南路，贯穿杨浦、浦东核心区', icon: 'subway' },
      { name: '19号线', color: '#722ED1', desc: '宝山杨行至闵行梅陇，新建南北快线', icon: 'subway' },
      { name: '浦江线', color: '#8BC34A', desc: '沈杜公路至汇臻路，上海首条胶轮有轨电车', icon: 'tram' }
    ]
  },
  uniqueTraffic: [
    {
      name: '黄浦江轮渡',
      type: '水上交通',
      price: '2元起',
      operationTime: '05:00 - 23:00',
      desc: '上海本地人钟爱的过江方式，低成本解锁黄浦江全景，沉浸式感受魔都烟火与江风惬意',
      color: '#1E88E5'
    },
    {
      name: '上海磁浮列车',
      type: '高速磁悬浮',
      price: '50元起',
      operationTime: '06:45 - 21:40',
      desc: '全球唯一商业运营高速磁浮，最高时速430km/h，8分钟直达机场，解锁极速出行体验',
      color: '#FF5722'
    },
    {
      name: '松江有轨电车',
      type: '现代有轨电车',
      price: '2元起',
      operationTime: '06:00 - 22:00',
      desc: '外形酷似“蚕宝宝”，低能耗高颜值，串联松江大学城、泰晤士小镇等景点，网红打卡必选',
      color: '#4CAF50'
    },
    {
      name: '黄浦江游览船',
      type: '观光游船',
      price: '120元起',
      operationTime: '10:00 - 22:00',
      desc: '夜游必体验项目，沿途欣赏外滩灯光秀与陆家嘴摩天楼宇，尽览魔都璀璨夜景',
      color: '#0069C0'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=上海地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

// 天津市交通数据
export const TIANJIN_TRAFFIC_DATA: CityTrafficConfig = {
  city: '天津市',
  metro: {
    lineCount: 9,
    totalMileage: '286km+',
    basePrice: '2元起',
    notice: '按里程计价，封顶约9元',
    lines: [
      { name: '1号线', color: '#FF0000', desc: '东西向骨干，刘园至双桥河，贯穿营口道、小白楼', icon: 'subway' },
      { name: '2号线', color: '#009944', desc: '东西向线路，曹庄至滨海国际机场，覆盖天津站', icon: 'subway' },
      { name: '3号线', color: '#FF9900', desc: '南北向骨干，小淀至南站，贯穿天津站、营口道', icon: 'subway' },
      { name: '4号线', color: '#0066FF', desc: '东南角至新兴村，服务红桥、南开、河东片区', icon: 'subway' },
      { name: '5号线', color: '#990099', desc: '环线线路，北辰科技园北至李七庄南，覆盖文化中心', icon: 'subway' },
      { name: '6号线', color: '#00CCCC', desc: '南孙庄至梅林路，贯穿长虹公园、天津宾馆', icon: 'subway' },
      { name: '8号线', color: '#66CC33', desc: '绿水公园至咸水沽西，服务津南片区', icon: 'subway' },
      { name: '9号线', color: '#0099CC', desc: '天津站至东海路，连接中心城区与滨海新区', icon: 'rail' },
      { name: '10号线', color: '#FF6600', desc: '屿东城至于台，服务河东、河西、西青片区', icon: 'subway' }
    ]
  },
  uniqueTraffic: [
    {
      name: '天津海河游船',
      type: '水上观光',
      price: '80元起',
      operationTime: '09:30 - 20:30',
      desc: '串联海河两岸217栋建筑与14座桥梁，乘船解锁津门古今交融的流动画卷，日夜皆有风情',
      color: '#2196F3'
    },
    {
      name: '天津之眼摩天轮',
      type: '巨型摩天轮',
      price: '70元',
      operationTime: '09:30 - 21:30',
      desc: '世界唯一建在桥上的巨型摩天轮，120米高空俯瞰海河全景，天津城市地标性体验',
      color: '#FF9800'
    },
    {
      name: '复古铛铛车',
      type: '观光巴士',
      price: '30元',
      operationTime: '09:00 - 18:00',
      desc: '五大道专属观光交通，搭配随车讲解，穿梭异国风情洋楼，感受民国时期的津门韵味',
      color: '#795548'
    },
    {
      name: '津滨轻轨9号线',
      type: '市域快轨',
      price: '2元起',
      operationTime: '06:00 - 22:30',
      desc: '串联天津市区与滨海新区，时速快、站点密，兼具通勤与观光属性，解锁双城风光',
      color: '#0099CC'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=天津地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

// 重庆市交通数据
export const CHONGQING_TRAFFIC_DATA: CityTrafficConfig = {
  city: '重庆市',
  metro: {
    lineCount: 15,
    totalMileage: '501km+',
    basePrice: '2元起',
    notice: '按里程计价，封顶约10元',
    lines: [
      { name: '1号线', color: '#FF4D4F', desc: '朝天门至璧山，贯穿解放碑、沙坪坝核心区', icon: 'subway' },
      { name: '2号线', color: '#00A651', desc: '较场口至鱼洞，中国首条跨座式单轨，穿楼而过的网红线路', icon: 'monorail' },
      { name: '3号线', color: '#FF7D00', desc: '鱼洞至江北机场，重庆最繁忙线路，连接南坪、观音桥', icon: 'monorail' },
      { name: '4号线', color: '#0066CC', desc: '民安大道至黄岭，服务渝北龙兴片区', icon: 'subway' },
      { name: '5号线', color: '#993399', desc: '园博中心至跳磴，贯穿冉家坝、石桥铺核心区', icon: 'subway' },
      { name: '6号线', color: '#00CCCC', desc: '茶园至北碚，连接解放碑、江北嘴、光电园', icon: 'subway' },
      { name: '9号线', color: '#7CB305', desc: '新桥至花石沟，贯穿沙坪坝、观音桥、江北嘴', icon: 'subway' },
      { name: '10号线', color: '#009DE0', desc: '王家庄至兰花路，连接江北机场与重庆北站', icon: 'subway' },
      { name: '环线', color: '#FFC618', desc: '重庆西站至重庆西站，环线覆盖沙坪坝、南坪、弹子石', icon: 'subway' },
      { name: '国博线', color: '#00B5AD', desc: '礼嘉至沙河坝，服务国博中心、悦来片区', icon: 'subway' },
      { name: '江跳线', color: '#8E44AD', desc: '跳磴至圣泉寺，连接江津与主城', icon: 'subway' },
      { name: '9号线支线', color: '#27AE60', desc: '兴科大道至花石沟，服务渝北空港片区', icon: 'subway' },
      { name: '15号线', color: '#E67E22', desc: '曾家至两江影视城，连接西部科学城与龙兴', icon: 'subway' },
      { name: '18号线', color: '#16A085', desc: '富华路至跳磴南，服务渝中区、巴南区', icon: 'subway' },
      { name: '24号线', color: '#8E44AD', desc: '广阳湾至鹿角北，服务茶园片区', icon: 'subway' }
    ]
  },
  uniqueTraffic: [
    {
      name: '长江索道',
      type: '过江索道',
      price: '20元',
      operationTime: '07:30 - 22:30',
      desc: '重庆最具代表性的交通工具，横跨长江，俯瞰两岸山城夜景，解锁魔幻都市独特视角',
      color: '#E74C3C'
    },
    {
      name: '皇冠大扶梯',
      type: '户外大扶梯',
      price: '2元',
      operationTime: '06:45 - 21:45',
      desc: '亚洲第二长的一级提升坡道大扶梯，体验魔幻地形必备，承载几代重庆人的城市记忆',
      color: '#95A5A6'
    },
    {
      name: '两江小渡',
      type: '水上轮渡',
      price: '15元',
      operationTime: '07:00 - 18:00',
      desc: '保留老重庆过江风情，慢赏两江交汇盛景，感受江水潺潺与城市烟火的完美交融',
      color: '#3498DB'
    },
    {
      name: '黄桷坪长江大桥观光电梯',
      type: '户外观光电梯',
      price: '10元',
      operationTime: '09:00 - 18:00',
      desc: '全国首座大桥观光电梯，高空俯瞰长江与涂鸦艺术街，解锁山城立体观光新体验',
      color: '#F39C12'
    },
    {
      name: '缙云山索道',
      type: '登山索道',
      price: '30元',
      operationTime: '08:00 - 17:00',
      desc: '缙云山登山必经交通，被誉为“山间天梯”，沉浸式穿梭林海，俯瞰嘉陵江小三峡风光',
      color: '#27AE60'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=重庆地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

// 成都市交通数据
export const CHENGDU_TRAFFIC_DATA: CityTrafficConfig = {
  city: '成都市',
  metro: {
    lineCount: 16,
    totalMileage: '568km+',
    basePrice: '2元起',
    notice: '按里程计价，封顶约10元',
    lines: [
      { name: '1号线', color: '#FFCD00', desc: '南北向骨干，韦家碾至科学城，贯穿天府广场、金融城', icon: 'subway' },
      { name: '2号线', color: '#0066CC', desc: '东西向骨干，犀浦至龙泉驿，贯穿春熙路、天府广场', icon: 'subway' },
      { name: '3号线', color: '#FF7500', desc: '东北-西南向，成都医学院至双流西站，贯穿武侯祠、锦里', icon: 'subway' },
      { name: '4号线', color: '#009944', desc: '东西向，万盛至西河，贯穿宽窄巷子、杜甫草堂', icon: 'subway' },
      { name: '5号线', color: '#993399', desc: '南北向，华桂路至回龙，服务青羊、武侯、高新南区', icon: 'subway' },
      { name: '6号线', color: '#7CB305', desc: '西北-东南向，望丛祠至兰家沟，成都最长地铁线路', icon: 'subway' },
      { name: '7号线', color: '#FF4D4F', desc: '环线线路，火车北站至火车北站，覆盖成都站、成都东客站', icon: 'subway' },
      { name: '8号线', color: '#00CCCC', desc: '东北-西南向，十里店至莲花，贯穿东郊记忆、川大望江校区', icon: 'subway' },
      { name: '9号线', color: '#660099', desc: '环线快线，黄田坝至金融城东，成都首条全自动驾驶线路', icon: 'subway' },
      { name: '10号线', color: '#85C440', desc: '太平园至新平，直达双流国际机场，服务黄龙溪景区', icon: 'subway' },
      { name: '17号线', color: '#009DE0', desc: '金星至机投桥，快线连接温江与主城', icon: 'subway' },
      { name: '18号线', color: '#0066CC', desc: '火车南站至天府机场北，最快37分钟直达天府机场', icon: 'subway' },
      { name: '19号线', color: '#993399', desc: '九江北至天府站，连接双流机场与天府新区', icon: 'subway' },
      { name: '20号线', color: '#FF7500', desc: '应龙至白莲池，服务城南与城北片区', icon: 'subway' },
      { name: '27号线', color: '#009944', desc: '石佛至蜀鑫路，服务成华、金牛、青羊片区', icon: 'subway' },
      { name: '30号线', color: '#FFCD00', desc: '双流机场2航站楼至洪家桥，服务南部片区', icon: 'subway' }
    ]
  },
  uniqueTraffic: [
    {
      name: '成都有轨电车蓉2号线',
      type: '现代有轨电车',
      price: '2元起',
      operationTime: '06:30 - 22:30',
      desc: '成都首条有轨电车，穿梭田园与城镇之间，慢节奏解锁蓉城近郊的烟火与诗意',
      color: '#4CAF50'
    },
    {
      name: '天府云海低空航线',
      type: '低空观光',
      price: '380元起',
      operationTime: '09:00 - 17:00',
      desc: '解锁蓉城高空视角，俯瞰天府机场与三岔湖全景，沉浸式感受航空新城的壮阔与灵动',
      color: '#FF9800'
    },
    {
      name: '锦江夜游',
      type: '水上观光',
      price: '128元起',
      operationTime: '19:00 - 22:00',
      desc: '蓉城夜游首选，乘游船赏合江亭、九眼桥灯光盛景，感受锦江两岸的人文与浪漫',
      color: '#2196F3'
    },
    {
      name: '熊猫专线',
      type: '观光巴士',
      price: '5元',
      operationTime: '07:00 - 19:00',
      desc: '熊猫主题专属涂装，直达熊猫基地，沉浸式感受蓉城“熊猫文化”的可爱与治愈',
      color: '#4CAF50'
    },
    {
      name: '都江堰景区观光车',
      type: '景区交通',
      price: '30元',
      operationTime: '08:00 - 17:00',
      desc: '串联都江堰核心景点，省去徒步奔波，轻松领略千年水利工程的雄伟与智慧',
      color: '#9C27B0'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=成都地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

// 武汉市交通数据（保留原数据）
export const WUHAN_TRAFFIC_DATA: CityTrafficConfig = {
  city: '武汉市',
  metro: {
    lineCount: 12,
    totalMileage: '500km+',
    basePrice: '2元起',
    notice: '按里程计价，封顶约13元',
    lines: [
      { name: '1号线', color: '#004795', desc: '全高架线路，穿越老汉口核心区', icon: 'rail' },
      { name: '2号线', color: '#E9A0BB', desc: '首条穿越长江地铁，连接天河机场与武汉火车站', icon: 'subway' },
      { name: '3号线', color: '#C0935D', desc: '连接汉口与汉阳，串联体育中心与市民之家', icon: 'subway' },
      { name: '4号线', color: '#97D24A', desc: '串联三大火车站（武汉/武昌/汉阳），直达黄金口', icon: 'subway' },
      { name: '5号线', color: '#FF7D00', desc: '首条全自动无人驾驶线路，纵贯武昌滨江', icon: 'subway' },
      { name: '6号线', color: '#00B150', desc: '跨越汉江，连接金银湖与沌口开发区', icon: 'subway' },
      { name: '7号线', color: '#ED6D00', desc: '穿越长江公铁隧道，连接东西湖与南湖', icon: 'subway' },
      { name: '8号线', color: '#77C5D5', desc: '连接三江，贯穿二七商务区与徐东', icon: 'subway' },
      { name: '11号线', color: '#FFD400', desc: '通往光谷腹地，串联光谷火车站与左岭', icon: 'subway' },
      { name: '16号线', color: '#DA291C', desc: '最美南郊线，直通中国车谷', icon: 'subway' },
      { name: '19号线', color: '#009F8C', desc: '连接光谷与武汉站的高速轨道', icon: 'subway' },
      { name: '21号线', color: '#91278F', desc: '阳逻线，跨越黄陂区与江岸区', icon: 'subway' }
    ]
  },
  uniqueTraffic: [
    {
      name: '光谷空轨',
      type: '悬挂式轨道',
      price: '30元',
      operationTime: '08:00 - 20:00',
      desc: '国内首条商业运营空轨，全透明地板俯瞰光谷绿道，解锁空中观光新体验',
      color: '#00D1FF'
    },
    {
      name: '武汉轮渡',
      type: '水上交通',
      price: '1.5元起',
      operationTime: '06:30 - 20:00',
      desc: '低成本解锁长江盛景，吹着江风赏两岸风光，感受江城独有的江湖气息',
      color: '#007DFF'
    },
    {
      name: '有轨电车',
      type: 'L1/L2线',
      price: '2元',
      operationTime: '06:00 - 22:00',
      desc: '光谷特色交通名片，穿梭核心商圈与科创园区，串联城市风景与生活烟火',
      color: '#6FCF97'
    }
  ],
  links: {
    metroMap: 'amapuri://search?keyword=武汉地铁图',
    realTimeBus: 'weixin://dl/miniPrograms/车来了'
  }
};

export function getCityTraffic(cityName: string): CityTrafficConfig {
  // 1. 预处理：去掉用户输入或定位字符串末尾的"市"或"区"或"县"
  // 比如把 "北京市" 变成 "北京"，把 "北京" 还是 "北京"
  const pureName = cityName.replace(/[市区县]$/, '');

  // 2. 定义一个映射，让代码更健壮
  const TRAFFIC_MAP: Record<string, CityTrafficConfig> = {
    '北京': BEIJING_TRAFFIC_DATA,
    '上海': SHANGHAI_TRAFFIC_DATA,
    '天津': TIANJIN_TRAFFIC_DATA,
    '重庆': CHONGQING_TRAFFIC_DATA,
    '成都': CHENGDU_TRAFFIC_DATA,
    '武汉': WUHAN_TRAFFIC_DATA
  };

  // 3. 匹配数据
  const data = TRAFFIC_MAP[pureName];

  if (data) {
    return data;
  }

  // 4. 如果实在找不到（比如搜了西安），返回默认城市（武汉）
  console.error(`未找到 ${cityName} 的交通数据，已回退至默认城市`);
  return WUHAN_TRAFFIC_DATA;
}