// models/HistoryData.ets

export interface HistoryNode {
  id: number
  era: string
  year: string
  siteName: string
  description: string
  image: string
  isExpanded: boolean
  screenX?: number     // 相对屏幕/画布的X坐标
  screenY?: number     // 相对屏幕/画布的Y坐标
  // sleep: 静态, breath: 自动缩放, active: 选中高亮+扩散波纹
  status?: 'sleep' | 'breath' | 'active'
}

export const CITY_EXPLORE_MAP: Record<string, HistoryNode[]> = {
  "北京": [
    { id: 0, era: "西周蓟都", year: "前1045年", siteName: "蓟城纪念柱", description: "【时代背景】周武王封召公于燕，于此建立蓟城，开启了北京三千年的建城史。\n【景点】蓟城纪念柱：位于广安门外，石碑铭刻着建城的坐标，是古都灵魂的起点。", image: "bj_0", isExpanded: false },
    { id: 1, era: "战国燕都", year: "前226年", siteName: "黄金台遗址", description: "【时代背景】燕昭王筑坛置金招揽天下贤士，使燕国一度强盛。北京自古便是求贤若渴之地。\n【景点】黄金台：见证了燕国图强崛起的野心与对人才的尊重。", image: "bj_1", isExpanded: false },
    { id: 2, era: "辽南京", year: "938年", siteName: "天宁寺塔", description: "【时代背景】辽将北京升为南京幽都府，城市充满了游牧与农耕文明碰撞的张力。\n【景点】天宁寺塔：北京现存最古老的地上建筑，其雄浑造型展现了辽代独特的审美。", image: "bj_2", isExpanded: false },
    { id: 3, era: "金中都", year: "1153年", siteName: "卢沟桥", description: "【时代背景】金朝正式迁都北京，标志着北京第一次成为一代王朝的统治中心。\n【景点】卢沟桥：金代石桥艺术奇迹，“卢沟晓月”自此传颂千载。", image: "bj_3", isExpanded: false },
    { id: 4, era: "元大都", year: "1271年", siteName: "妙应寺白塔", description: "【时代背景】元确立了今日北京城的中轴线布局，大都成为了连接欧亚的超级都市。\n【景点】白塔寺：由尼泊尔工匠监造，是元代国际化视野的历史物证。", image: "bj_4", isExpanded: false },
    { id: 5, era: "明永乐", year: "1420年", siteName: "故宫", description: "【时代背景】明成祖迁都，确立了皇权至上的格局。红墙琉璃瓦构筑起严密的礼制体系。\n【景点】故宫：世界最大木结构宫殿群，承载着大明王朝的辉煌与威严。", image: "bj_5", isExpanded: false },
    { id: 6, era: "清鼎盛", year: "1750年", siteName: "颐和园", description: "【时代背景】清代康乾盛世，皇家园林达到鼎盛，将自然山水与政治行政完美结合。\n【景点】颐和园：古典园林艺术集大成之作，展现了皇家气派。", image: "bj_6", isExpanded: false },
    { id: 7, era: "全面抗战", year: "1937年", siteName: "宛平城", description: "【时代背景】七七事变爆发，开启全民族抗战。北京沦陷，但民族灵魂从未屈服。\n【景点】宛平城：墙上的累累弹痕是民族伤痛的印记，也是反思战争的活教材。", image: "bj_7", isExpanded: false },
    { id: 8, era: "开国盛典", year: "1949年", siteName: "天安门广场", description: "【时代背景】1949年10月1日，北京焕发生机，从帝王之都转变为人民的首都。\n【景点】天安门广场：见证了共和国每一次跃动的脉搏。", image: "bj_8", isExpanded: false },
    { id: 9, era: "未来双轴", year: "2025年", siteName: "副中心绿心", description: "【时代背景】北京开启“疏解与提升”新阶段，城市副中心引领绿色智慧新高度。\n【景点】城市绿心：智慧图书馆与剧院错落森林间，展现未来北京的生态理想。", image: "bj_9", isExpanded: false }
  ],
  "天津": [
    { id: 10, era: "大运河源", year: "610年", siteName: "三岔河口", description: "【时代背景】隋炀帝开凿大运河，天津作为南北运河交汇点，自此拉开繁荣序幕。\n【景点】三岔河口：天津的母亲河之源，漕运文化的发端地。", image: "tj_0", isExpanded: false },
    { id: 11, era: "元代直沽", year: "1214年", siteName: "天后宫", description: "【时代背景】元代定都大都，漕运成为国家命脉，直沽作为海运终点与漕粮转运枢纽，地位空前提升。\\n【景点】天后宫：天津市区现存最古老的建筑群，也是中国北方妈祖文化（漕运、海神信仰）的中心。", image: "tj_1", isExpanded: false },
    { id: 12, era: "天津卫建", year: "1404年", siteName: "古文化街", description: "【时代背景】明成祖朱棣赐名，意为“天子经过的渡口”，正式设卫筑城。\n【景点】古文化街：保留了明清卫城商业繁荣的缩影，展现地道津味文化。", image: "tj_2", isExpanded: false },
    { id: 13, era: "近代口岸", year: "1860年", siteName: "五大道", description: "【时代背景】第二次鸦片战争后天津开埠，各国租界设立，成为近代中外文化碰撞前沿。\n【景点】五大道：欧式洋楼林立，被誉为“万国建筑博览馆”。", image: "tj_3", isExpanded: false },
    { id: 14, era: "洋务先锋", year: "1880年", siteName: "北洋大学旧址", description: "【时代背景】洋务运动兴起，天津成为北方工业与教育现代化的先行者。\n【景点】北洋大学：中国第一所现代大学，开启了实业救国的学术先河。", image: "tj_4", isExpanded: false },
    { id: 15, era: "觉醒抗争", year: "1937年", siteName: "觉悟社旧址", description: "【时代背景】战火纷飞中，天津青年学生寻求救国之道，成为北方革命火种的摇篮。\n【景点】觉悟社旧址：记录了周恩来等革命志士早年的奋斗足迹。", image: "tj_5", isExpanded: false },
    { id: 16, era: "现代工业", year: "1958年", siteName: "天津港", description: "【时代背景】新中国建设时期，天津从传统运河城市跨向全球大航海时代。\n【景点】天津港：北方最大的人工深水港，中国制造走向世界的出海口。", image: "tj_6", isExpanded: false },
    { id: 17, era: "海河记忆", year: "2025年", siteName: "天津之眼", description: "【时代背景】2025年的天津，智慧城市与海河生态交相辉映，焕发老工业城市新活力。\n【景点】天津之眼：跨河而建的巨型摩天轮，俯瞰海河两岸流光溢彩的现代风景。", image: "tj_7", isExpanded: false }
  ],
  "上海": [
    { id: 20, era: "唐代华亭", year: "751年", siteName: "广富林遗址", description: "【时代背景】唐朝设立华亭县，标志着上海地区正式拥有独立建制。\n【景点】广富林：水下博物馆展现了数千年前良渚文化到唐宋的文明演进。", image: "sh_0", isExpanded: false },
    { id: 11, era: "宋代通商", year: "1013年", siteName: "隆平寺塔基", description: "【时代背景】北宋时期青龙镇作为海上丝绸之路重要港口，经济文化繁荣，北宋书画家米芾曾担任镇监。\n【景点】隆平寺塔：兼具航标功能，引导商船入港，是唐宋时期海上贸易的重要实证。", image: "sh_1", isExpanded: false },
    { id: 21, era: "元设上海", year: "1292年", siteName: "豫园老城厢", description: "【时代背景】上海县正式设立，江南商业与航运枢纽地位初步确立。\n【景点】豫园：明清私家园林精华，浓缩了老上海的市井烟火与商业繁华。", image: "sh_2", isExpanded: false },
    { id: 22, era: "开埠时刻", year: "1843年", siteName: "外滩", description: "【时代背景】上海被迫开埠，迅速融入全球贸易，从县城蜕变为国际商埠。\n【景点】外滩：万国建筑群见证了近代上海作为“东方伦敦”的财富权力交替。", image: "sh_3", isExpanded: false },
    { id: 23, era: "弄堂文化", year: "1920s", siteName: "石库门", description: "【时代背景】民国时期上海人口激增，中西合璧的石库门建筑成为海派文化的温床。\n【景点】石库门建筑群：独特的上海民居，弄堂深处藏着无数名人往事。", image: "sh_4", isExpanded: false },
    { id: 24, era: "铁血守沪", year: "1937年", siteName: "四行仓库", description: "【时代背景】淞沪会战，上海沦为焦土，中国守军在城市腹地展开殊死抵抗。\n【景点】四行仓库：八百壮士血战四昼夜，那一堵满是弹孔的墙壁是民族脊梁的见证。", image: "sh_5", isExpanded: false },
    { id: 25, era: "浦东奇迹", year: "1990年", siteName: "东方明珠", description: "【时代背景】浦东开发开放，上海再次站上全球金融巅峰，实现跨越式跨江发展。\n【景点】东方明珠：从烂泥渡中拔地而起的摩天地标，象征着上海的现代高度。", image: "sh_6", isExpanded: false },
    { id: 26, era: "科创高地", year: "2025年", siteName: "张江科学城", description: "【时代背景】2025上海主攻硬核科技。张江科学城成为全球科研的核心枢纽。\n【景点】鹦鹉螺：世界级同步辐射光源，代表上海引领未来科学突破的信心。", image: "sh_7", isExpanded: false }
  ],
  "重庆": [
    { id: 30, era: "巴国都城", year: "前5世纪", siteName: "朝天门", description: "【时代背景】巴国迁都江州，两江交汇处的码头文化自此生根，成为山城地理坐标点。\n【景点】朝天门：守望两江交汇，见证了三千年码头城市的兴衰流转。", image: "cq_0", isExpanded: false },
    { id: 31, era: "秦巴重镇", year: "前314年", siteName: "老鼓楼遗址", description: "【时代背景】秦将张仪筑城，确立了重庆作为西南军事与政治重镇的基础。\n【景点】老鼓楼：重庆城市权力的最早物证，地层下埋藏着千年城防记忆。", image: "cq_1", isExpanded: false },
    { id: 32, era: "隋代命名", year: "581年", siteName: "渝中半岛", description: "【时代背景】公元581年隋文帝借用嘉陵江旧名“渝”，改楚州为渝州，重庆始简称\"渝\"。\\n【景点】渝中半岛：长江、嘉陵江交汇的半岛尖端，是重庆三千年建城史的绝对核心。重庆从此拥有了跨越千年的名字符号。", image: "cq_2", isExpanded: false },
    { id: 32, era: "铁血防御", year: "1242年", siteName: "钓鱼城", description: "【时代背景】南宋抗蒙，钓鱼城坚守36年，因蒙哥汗在此战死而改变了世界历史。\n【景点】钓鱼城：被誉为“上帝折鞭处”，是改变全球战争轨迹的历史堡垒。", image: "cq_3", isExpanded: false },
    { id: 33, era: "会战湖广", year: "1750s", siteName: "湖广会馆", description: "【时代背景】清代大规模移民入川，各地会馆林立，造就了重庆包容多元的城市性格。\n【景点】湖广会馆：精美的明清建筑群，记录了山城移民文化的繁荣景象。", image: "cq_4", isExpanded: false },
    { id: 34, era: "抗战陪都", year: "1937-1946年", siteName: "大轰炸遗址", description: "【时代背景】重庆成为二战同盟国远东指挥中心。虽遭日机狂轰滥炸，城市始终屹立不倒。\n【景点】大轰炸惨案遗址：废墟中的坚守，铭刻了英雄之城不屈的城市脊梁。", image: "cq_5", isExpanded: false },
    { id: 35, era: "直辖新篇", year: "1997年", siteName: "解放碑", description: "【时代背景】1997年重庆设立直辖市，开启了内陆开发与城市腾飞的新航程。\n【景点】解放碑：原名“抗战胜利纪功碑”，如今是山城最繁华的现代心脏。", image: "cq_6", isExpanded: false },
    { id: 36, era: "赛博山城", year: "2025年", siteName: "云端之眼", description: "【时代背景】2025重庆以立体交通与魔幻夜景走红。智慧城市与山水格局深度融合。\n【景点】云端之眼：海拔高度300多米，俯瞰赛博朋克现实版的山城奇迹。", image: "cq_7", isExpanded: false }
  ],
  "武汉": [
    { id: 40, era: "商代盘龙", year: "前1500年", siteName: "盘龙城遗址", description: "【时代背景】商代文明在长江中游的重要城市，证明了武汉早在三千多年前即为都邑。\n【景点】盘龙城：长江中游最早的城址之一，揭秘了荆楚大地悠久的文明脉络。", image: "wh_0", isExpanded: false },
    { id: 41, era: "三国筑城", year: "223年", siteName: "黄鹤楼", description: "【时代背景】东吴孙权为瞭望军情在夏口修筑城池。从此，黄鹤楼成为荆楚文脉图腾。\n【景点】黄鹤楼：历经屡次毁建，始终屹立蛇山之巅，俯瞰江汉平原千载风云。", image: "wh_1", isExpanded: false },
    { id: 42, era: "隋唐漕运", year: "581年", siteName: "江夏古城", description: "【时代背景】隋朝开皇九年(589年),隋灭南陈,改为江夏县,为鄂州治所。县治与州治均设于郢州城。\n【景点】江夏里：得益于长江与汉江交汇，武汉逐渐成为九省通衢的核心。", image: "wh_2", isExpanded: false },
    { id: 42, era: "汉口开埠", year: "1861年", siteName: "汉口租界群", description: "【时代背景】第二次鸦片战争后汉口开埠。因水路便捷，被誉为“东方芝加哥”。\n【景点】江汉路：近代西洋建筑群记录了汉口作为九省通衢的商业巅峰岁月。", image: "wh_3", isExpanded: false },
    { id: 43, era: "辛亥首义", year: "1911年", siteName: "武昌起义红楼", description: "【时代背景】武昌起义爆发，推翻两千年帝制。武汉成为共和政权的诞生地。\n【景点】辛亥革命纪念馆：那一抹红墙见证了中国走向民主共和的开端。", image: "wh_4", isExpanded: false },
    { id: 44, era: "抗战重心", year: "1938年", siteName: "武汉会战纪念碑", description: "【时代背景】全面抗战初期，武汉成为军事指挥重心。百万官兵在此血战，拖垮日军攻势。\n【景点】武汉会战纪念地：展现了保卫大武汉、持久抗战的英雄气魄。", image: "wh_5", isExpanded: false },
    { id: 45, era: "飞架南北", year: "1957年", siteName: "长江大桥", description: "【时代背景】新中国第一个五年计划重点工程，首次实现长江天堑变通途。\n【景点】武汉长江大桥：共和国的工业骄傲，连接了武昌、汉阳与汉口的脉络。", image: "wh_6", isExpanded: false },
    { id: 46, era: "英雄之城", year: "2025年", siteName: "光谷实验室", description: "【时代背景】2025武汉主攻光电子芯片与未来通讯。英雄之城正蝶变为全球科创之都。\n【景点】量子大街：光谷核心，展现未来科技跳动下不断进取的武汉精神。", image: "wh_7", isExpanded: false }
  ],
  "成都": [
    { id: 50, era: "金沙文明", year: "前1200年", siteName: "金沙遗址", description: "【时代背景】古蜀王国祭祀中心。太阳神鸟折射出古人对光明的崇拜与神权社会盛景。\n【景点】金沙遗址：探秘被尘封三千年的黄金面具与古蜀王室的祭祀奥秘。", image: "cd_0", isExpanded: false },
    { id: 51, era: "秦修水利", year: "前256年", siteName: "都江堰", description: "【时代背景】李冰父子化水害为水利。从此成都平原沃野千里，开启天府之国元年。\n【景点】都江堰：全世界现存最古老、且仍在发挥作用的生态水利枢纽工程。", image: "cd_1", isExpanded: false },
    { id: 52, era: "蜀汉建都", year: "221年", siteName: "武侯祠", description: "【时代背景】刘备与诸葛亮于此三分天下。君臣之礼与忠肝义胆成为成都文化内核。\n【景点】武侯祠：国内唯一的君臣合祀祠庙，承载了千年的三国英雄梦。", image: "cd_2", isExpanded: false },
    { id: 53, era: "诗圣入蜀", year: "759年", siteName: "杜甫草堂", description: "【时代背景】杜甫避乱入川。在成都的四年间，他的诗歌不仅描写民生，更赋予城市文气。\n【景点】草堂：战火硝烟中留存的文学绿洲，展现了天府之国包容文人的温润。", image: "cd_3", isExpanded: false },
    { id: 54, era: "宋代交子", year: "1023年", siteName: "成都老街", description: "【时代背景】北宋益州商品经济高度繁荣，铁钱笨重流通不便。官方设立“交子务”统一发行。【景点】成都老街：世界首张纸币在此诞生，开创了人类金融史新篇章。", image: "cd_4", isExpanded: false },
    { id: 55, era: "满城烟火", year: "1980s", siteName: "宽窄巷子", description: "【时代背景】清代满城遗址在当代焕发新生。在时尚与传统的交汇中，沉淀出成都式闲适。\n【景点】宽窄巷子：成都慢生活的活标本，展示了这座城市骨子里的安逸与自信。", image: "cd_5", isExpanded: false },
    { id: 54, era: "川军抗敌", year: "1937年", siteName: "川军抗战碑", description: "【时代背景】全面抗战爆发，成都作为大后方，350万将士慷慨出川，为国捐躯。\n【景点】川军纪念碑：一名士兵背负斗笠、紧握长枪，定格了四川子弟浴血报国的英魂。", image: "cd_6", isExpanded: false },
    { id: 56, era: "雪山之都", year: "2025年", siteName: "龙泉山公园", description: "【时代背景】2025年成都迈向全域公园城市。推窗见绿、抬头见雪山成为生活常态。\n【景点】森林公园：全球最大的城市森林公园，展现了人与自然和谐共生的天府样板。", image: "cd_7", isExpanded: false }
  ]
};