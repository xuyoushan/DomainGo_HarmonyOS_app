export class CityBanner {
  title: string;
  image: Resource;
  constructor(title: string, image: Resource) {
    this.title = title;
    this.image = image;
  }
}

export const CITY_BANNER_CONFIG: Record<string, CityBanner[]> = {
  // 1. 直辖市 (特大型)
  '北京市': [
    new CityBanner('故宫 · 红墙深处', $r('app.media.bj_bj_1')),
    new CityBanner('天坛 · 祭天祈年', $r('app.media.bj_bj_2')),
    new CityBanner('长城 · 万里雄风', $r('app.media.bj_bj_3')),
    new CityBanner('颐和园 · 昆明湖色', $r('app.media.bj_bj_4')),
    new CityBanner('三里屯 · 时尚中心', $r('app.media.bj_bj_5'))
  ],
//   '上海市': [
//     new CityBanner('外滩 · 万国建筑', $r('app.media.sh_sh_1')),
//     new CityBanner('陆家嘴 · 摩天楼群', $r('app.media.sh_sh_2')),
//     new CityBanner('豫园 · 城隍记忆', $r('app.media.sh_sh_3')),
//     new CityBanner('南京路 · 十里洋场', $r('app.media.sh_sh_4')),
//     new CityBanner('迪士尼 · 奇妙梦幻', $r('app.media.sh_sh_5'))
//   ],
//   '天津市': [
//     new CityBanner('天津之眼 · 摩天之轮', $r('app.media.tj_tj_1')),
//     new CityBanner('意式风情区 · 欧陆景观', $r('app.media.tj_tj_2')),
//     new CityBanner('古文化街 · 津味民俗', $r('app.media.tj_tj_3'))
//   ],
//   '重庆市': [
//     new CityBanner('洪崖洞 · 吊脚夜色', $r('app.media.cq_cq_1')),
//     new CityBanner('李子坝 · 轻轨穿楼', $r('app.media.cq_cq_2')),
//     new CityBanner('解放碑 · 时光之门', $r('app.media.cq_cq_3')),
//     new CityBanner('武隆 · 地质奇观', $r('app.media.cq_cq_4')),
//     new CityBanner('磁器口 · 巴渝古镇', $r('app.media.cq_cq_5'))
//   ],
//
//   // 2. 华中地区 (鄂、湘、豫)
//   '武汉市': [
//     new CityBanner('黄鹤楼 · 荆楚名胜', $r('app.media.hb_wh_1')),
//     new CityBanner('长江大桥 · 跨江巨龙', $r('app.media.hb_wh_2')),
//     new CityBanner('东湖 · 樱海缤纷', $r('app.media.hb_wh_3')),
//     new CityBanner('省博 · 楚剑风华', $r('app.media.hb_wh_4'))
//   ],
//   '宜昌市': [
//     new CityBanner('三峡大坝 · 国之重器', $r('app.media.hb_yc_1')),
//     new CityBanner('清江画廊 · 山水如画', $r('app.media.hb_yc_2')),
//     new CityBanner('三峡人家 · 巴楚风情', $r('app.media.hb_yc_3'))
//   ],
//   '襄阳市': [
//     new CityBanner('古隆中 · 卧龙故地', $r('app.media.hb_xy_1')),
//     new CityBanner('唐城 · 盛唐气象', $r('app.media.hb_xy_2')),
//     new CityBanner('襄阳古城 · 铁打的城', $r('app.media.hb_xy_3'))
//   ],
//   '荆州市': [
//     new CityBanner('荆州古城 · 三国故都', $r('app.media.hb_jz_1')),
//     new CityBanner('关帝庙 · 忠义千秋', $r('app.media.hb_jz_2')),
//     new CityBanner('楚王车马阵 · 楚韵雄风', $r('app.media.hb_jz_3'))
//   ],
//   '长沙市': [
//     new CityBanner('橘子洲头 · 湘江砥柱', $r('app.media.hn_cs_1')),
//     new CityBanner('岳麓山 · 千年学府', $r('app.media.hn_cs_2')),
//     new CityBanner('文和友 · 市井烟火', $r('app.media.hn_cs_3'))
//   ],
//   '株洲市': [
//     new CityBanner('炎帝陵 · 华夏始祖', $r('app.media.hn_zz_1')),
//     new CityBanner('方特 · 欢乐无限', $r('app.media.hn_zz_2')),
//     new CityBanner('神农湖 · 生态之美', $r('app.media.hn_zz_3'))
//   ],
//   '张家界市': [
//     new CityBanner('天门山 · 天门洞开', $r('app.media.hn_zjj_1')),
//     new CityBanner('武陵源 · 奇峰三千', $r('app.media.hn_zjj_2')),
//     new CityBanner('玻璃桥 · 云端漫步', $r('app.media.hn_zjj_3')),
//     new CityBanner('百龙天梯 · 直上云端', $r('app.media.hn_zjj_4'))
//   ],
//   '岳阳市': [
//     new CityBanner('岳阳楼 · 千古名楼', $r('app.media.hn_yy_1')),
//     new CityBanner('洞庭湖 · 浩浩汤汤', $r('app.media.hn_yy_2')),
//     new CityBanner('君山岛 · 湘妃故里', $r('app.media.hn_yy_3'))
//   ],
//   '郑州市': [
//     new CityBanner('少林寺 · 禅宗祖庭', $r('app.media.hen_zz_1')),
//     new CityBanner('河南博物院 · 中原瑰宝', $r('app.media.hen_zz_2')),
//     new CityBanner('如意湖 · 郑东新貌', $r('app.media.hen_zz_3'))
//   ],
//   '洛阳市': [
//     new CityBanner('龙门石窟 · 石刻艺术', $r('app.media.hen_ly_1')),
//     new CityBanner('老君山 · 仙山圣境', $r('app.media.hen_ly_2')),
//     new CityBanner('白马寺 · 释源祖庭', $r('app.media.hen_ly_3'))
//   ],
//   '开封市': [
//     new CityBanner('清明上河园 · 宋韵风华', $r('app.media.hen_kf_1')),
//     new CityBanner('龙亭 · 皇城遗韵', $r('app.media.hen_kf_2')),
//     new CityBanner('大相国寺 · 佛门圣地', $r('app.media.hen_kf_3'))
//   ],
//
//   // 3. 华东地区 (苏、浙、鲁、皖、闽、赣)
//   '南京市': [
//     new CityBanner('中山陵 · 博爱之都', $r('app.media.js_nj_1')),
//     new CityBanner('夫子庙 · 秦淮风月', $r('app.media.js_nj_2')),
//     new CityBanner('鸡鸣寺 · 古刹樱花', $r('app.media.js_nj_3'))
//   ],
//   '苏州市': [
//     new CityBanner('拙政园 · 园林典范', $r('app.media.js_sz_1')),
//     new CityBanner('平江路 · 江南水乡', $r('app.media.js_sz_2')),
//     new CityBanner('金鸡湖 · 现代苏韵', $r('app.media.js_sz_3'))
//   ],
//   '无锡市': [
//     new CityBanner('鼋头渚 · 太湖佳绝', $r('app.media.js_wx_1')),
//     new CityBanner('灵山大佛 · 祥符禅寺', $r('app.media.js_wx_2')),
//     new CityBanner('拈花湾 · 禅意小镇', $r('app.media.js_wx_3'))
//   ],
//   '徐州市': [
//     new CityBanner('云龙湖 · 徐州明珠', $r('app.media.js_xz_1')),
//     new CityBanner('汉文化景区 · 汉风楚韵', $r('app.media.js_xz_2')),
//     new CityBanner('回龙窝 · 明清古巷', $r('app.media.js_xz_3'))
//   ],
//   '常州市': [
//     new CityBanner('中华恐龙园 · 亲子乐园', $r('app.media.js_cz_1')),
//     new CityBanner('天宁禅寺 · 东南第一', $r('app.media.js_cz_2')),
//     new CityBanner('淹城遗址 · 春秋古城', $r('app.media.js_cz_3'))
//   ],
//   '南通市': [
//     new CityBanner('狼山 · 江海名山', $r('app.media.js_nt_1')),
//     new CityBanner('濠河 · 环城翡翠', $r('app.media.js_nt_2')),
//     new CityBanner('水绘园 · 才子佳人', $r('app.media.js_nt_3'))
//   ],
//   '扬州市': [
//     new CityBanner('瘦西湖 · 园林之胜', $r('app.media.js_yz_1')),
//     new CityBanner('个园 · 竹影婆娑', $r('app.media.js_yz_2')),
//     new CityBanner('东关街 · 扬州记忆', $r('app.media.js_yz_3'))
//   ],
//   '杭州市': [
//     new CityBanner('西湖 · 人间天堂', $r('app.media.zj_hz_1')),
//     new CityBanner('灵隐寺 · 禅意悠远', $r('app.media.zj_hz_2')),
//     new CityBanner('雷峰塔 · 千年传说', $r('app.media.zj_hz_3')),
//     new CityBanner('良渚遗址 · 文明曙光', $r('app.media.zj_hz_4'))
//   ],
//   '宁波市': [
//     new CityBanner('天一阁 · 藏书之祖', $r('app.media.zj_nb_1')),
//     new CityBanner('老外滩 · 甬城风情', $r('app.media.zj_nb_2')),
//     new CityBanner('渔山岛 · 碧海蓝天', $r('app.media.zj_nb_3'))
//   ],
//   '温州市': [
//     new CityBanner('雁荡山 · 海上名山', $r('app.media.zj_wz_1')),
//     new CityBanner('江心屿 · 瓯江蓬莱', $r('app.media.zj_wz_2')),
//     new CityBanner('南塘街 · 温瑞水乡', $r('app.media.zj_wz_3'))
//   ],
//   '绍兴市': [
//     new CityBanner('鲁迅故里 · 三味书屋', $r('app.media.zj_sx_1')),
//     new CityBanner('沈园 · 钗头凤韵', $r('app.media.zj_sx_2')),
//     new CityBanner('兰亭 · 书圣墨香', $r('app.media.zj_sx_3'))
//   ],
//   '舟山市': [
//     new CityBanner('普陀山 · 海天佛国', $r('app.media.zj_zs_1')),
//     new CityBanner('朱家尖 · 沙雕之乡', $r('app.media.zj_zs_2')),
//     new CityBanner('花鸟岛 · 东方圣托', $r('app.media.zj_zs_3'))
//   ],
//   '济南市': [
//     new CityBanner('趵突泉 · 天下第一', $r('app.media.sd_jn_1')),
//     new CityBanner('大明湖 · 泉城明珠', $r('app.media.sd_jn_2')),
//     new CityBanner('黑虎泉 · 泉群之首', $r('app.media.sd_jn_3'))
//   ],
//   '青岛市': [
//     new CityBanner('栈桥 · 青岛地标', $r('app.media.sd_qd_1')),
//     new CityBanner('崂山 · 海上仙山', $r('app.media.sd_qd_2')),
//     new CityBanner('五四广场 · 城市名片', $r('app.media.sd_qd_3')),
//     new CityBanner('八大关 · 万国建筑', $r('app.media.sd_qd_4'))
//   ],
//   '烟台市': [
//     new CityBanner('蓬莱阁 · 八仙过海', $r('app.media.sd_yt_1')),
//     new CityBanner('长岛 · 海上仙山', $r('app.media.sd_yt_2')),
//     new CityBanner('月亮湾 · 爱情圣地', $r('app.media.sd_yt_3'))
//   ],
//   '泰安市': [
//     new CityBanner('泰山 · 五岳独尊', $r('app.media.sd_ta_1')),
//     new CityBanner('岱庙 · 泰山祖庭', $r('app.media.sd_ta_2')),
//     new CityBanner('天外村 · 登山起点', $r('app.media.sd_ta_3'))
//   ],
//   '合肥市': [
//     new CityBanner('三河古镇 · 皖中水乡', $r('app.media.ah_hf_1')),
//     new CityBanner('天鹅湖 · 合肥地标', $r('app.media.ah_hf_2')),
//     new CityBanner('包公园 · 清风正气', $r('app.media.ah_hf_3'))
//   ],
//   '芜湖市': [
//     new CityBanner('方特 · 欢乐世界', $r('app.media.ah_wh_1')),
//     new CityBanner('鸠兹古镇 · 徽派风情', $r('app.media.ah_wh_2')),
//     new CityBanner('赭山公园 · 江城绿肺', $r('app.media.ah_wh_3'))
//   ],
//   '黄山市': [
//     new CityBanner('黄山 · 奇松怪石', $r('app.media.ah_hs_1')),
//     new CityBanner('宏村 · 画里乡村', $r('app.media.ah_hs_2')),
//     new CityBanner('西递 · 徽派古村', $r('app.media.ah_hs_3'))
//   ],
//   '福州市': [
//     new CityBanner('三坊七巷 · 闽都文脉', $r('app.media.fj_fz_1')),
//     new CityBanner('鼓山 · 闽刹之冠', $r('app.media.fj_fz_2')),
//     new CityBanner('平潭岛 · 蓝眼泪海', $r('app.media.fj_fz_3'))
//   ],
//   '厦门市': [
//     new CityBanner('鼓浪屿 · 琴岛风情', $r('app.media.fj_xm_1')),
//     new CityBanner('南普陀寺 · 闽南佛地', $r('app.media.fj_xm_2')),
//     new CityBanner('环岛路 · 碧海金沙', $r('app.media.fj_xm_3')),
//     new CityBanner('厦大 · 最美校园', $r('app.media.fj_xm_4'))
//   ],
//   '泉州市': [
//     new CityBanner('开元寺 · 桑莲法界', $r('app.media.fj_qz_1')),
//     new CityBanner('洛阳桥 · 海内第一', $r('app.media.fj_qz_2')),
//     new CityBanner('西街 · 闽南古街', $r('app.media.fj_qz_3'))
//   ],
//   '南昌市': [
//     new CityBanner('滕王阁 · 落霞孤鹜', $r('app.media.jx_nc_1')),
//     new CityBanner('八一纪念馆 · 红色记忆', $r('app.media.jx_nc_2')),
//     new CityBanner('海昏侯墓 · 汉墓瑰宝', $r('app.media.jx_nc_3'))
//   ],
//   '九江市': [
//     new CityBanner('庐山 · 匡庐奇秀', $r('app.media.jx_jj_1')),
//     new CityBanner('鄱阳湖 · 候鸟天堂', $r('app.media.jx_jj_2')),
//     new CityBanner('浔阳楼 · 水浒遗韵', $r('app.media.jx_jj_3'))
//   ],
//   '景德镇市': [
//     new CityBanner('陶瓷博物馆 · 瓷都瑰宝', $r('app.media.jx_jdz_1')),
//     new CityBanner('御窑厂 · 皇家瓷厂', $r('app.media.jx_jdz_2')),
//     new CityBanner('瑶里古镇 · 瓷茶故里', $r('app.media.jx_jdz_3'))
//   ],
//
//   // 4. 华南地区 (粤、桂、琼)
//   '广州市': [
//     new CityBanner('广州塔 · 小蛮腰姿', $r('app.media.gd_gz_1')),
//     new CityBanner('白云山 · 羊城第一', $r('app.media.gd_gz_2')),
//     new CityBanner('陈家祠 · 岭南建筑', $r('app.media.gd_gz_3'))
//   ],
//   '深圳市': [
//     new CityBanner('平安中心 · 鹏城之巅', $r('app.media.gd_sz_1')),
//     new CityBanner('世界之窗 · 环球缩影', $r('app.media.gd_sz_2')),
//     new CityBanner('大梅沙 · 碧海银沙', $r('app.media.gd_sz_3'))
//   ],
//   '珠海市': [
//     new CityBanner('情侣路 · 浪漫海岸', $r('app.media.gd_zh_1')),
//     new CityBanner('海洋王国 · 亲子乐园', $r('app.media.gd_zh_2')),
//     new CityBanner('日月贝 · 珠海地标', $r('app.media.gd_zh_3'))
//   ],
//   '佛山市': [
//     new CityBanner('祖庙 · 岭南圣域', $r('app.media.gd_fs_1')),
//     new CityBanner('西樵山 · 理学名山', $r('app.media.gd_fs_2')),
//     new CityBanner('逢简水乡 · 岭南周庄', $r('app.media.gd_fs_3'))
//   ],
//   '东莞市': [
//     new CityBanner('松山湖 · 科技绿洲', $r('app.media.gd_dg_1')),
//     new CityBanner('可园 · 岭南园林', $r('app.media.gd_dg_2')),
//     new CityBanner('鸦片战争博物馆 · 虎门销烟', $r('app.media.gd_dg_3'))
//   ],
//   '惠州市': [
//     new CityBanner('惠州西湖 · 苎萝西子', $r('app.media.gd_hz_1')),
//     new CityBanner('巽寮湾 · 白金海岸', $r('app.media.gd_hz_2')),
//     new CityBanner('罗浮山 · 岭南第一', $r('app.media.gd_hz_3'))
//   ],
//   '汕头市': [
//     new CityBanner('南澳岛 · 粤东屏障', $r('app.media.gd_st_1')),
//     new CityBanner('小公园 · 骑楼风情', $r('app.media.gd_st_2')),
//     new CityBanner('礐石风景区 · 海国石林', $r('app.media.gd_st_3'))
//   ],
//   '南宁市': [
//     new CityBanner('青秀山 · 绿城翡翠', $r('app.media.gx_nn_1')),
//     new CityBanner('南湖公园 · 邕城明珠', $r('app.media.gx_nn_2')),
//     new CityBanner('扬美古镇 · 明清遗风', $r('app.media.gx_nn_3'))
//   ],
//   '柳州市': [
//     new CityBanner('柳侯公园 · 柳祠怀古', $r('app.media.gx_lz_1')),
//     new CityBanner('百里柳江 · 玉带绕城', $r('app.media.gx_lz_2')),
//     new CityBanner('立鱼峰 · 刘三姐乡', $r('app.media.gx_lz_3'))
//   ],
//   '桂林市': [
//     new CityBanner('漓江 · 百里画廊', $r('app.media.gx_gl_1')),
//     new CityBanner('象鼻山 · 訾洲烟雨', $r('app.media.gx_gl_2')),
//     new CityBanner('遇龙河 · 小漓江美', $r('app.media.gx_gl_3')),
//     new CityBanner('龙脊梯田 · 大地画卷', $r('app.media.gx_gl_4'))
//   ],
//   '北海市': [
//     new CityBanner('银滩 · 天下第一', $r('app.media.gx_bh_1')),
//     new CityBanner('涠洲岛 · 火山秘境', $r('app.media.gx_bh_2')),
//     new CityBanner('老街 · 百年骑楼', $r('app.media.gx_bh_3'))
//   ],
//   '海口市': [
//     new CityBanner('骑楼老街 · 南洋风情', $r('app.media.hn_hk_1')),
//     new CityBanner('雷琼火山 · 地质奇观', $r('app.media.hn_hk_2')),
//     new CityBanner('假日海滩 · 椰风海韵', $r('app.media.hn_hk_3'))
//   ],
//   '三亚市': [
//     new CityBanner('亚龙湾 · 天下第一', $r('app.media.hn_sy_1')),
//     new CityBanner('南山观音 · 海上圣像', $r('app.media.hn_sy_2')),
//     new CityBanner('蜈支洲岛 · 中国马尔代', $r('app.media.hn_sy_3')),
//     new CityBanner('天涯海角 · 浪漫地标', $r('app.media.hn_sy_4'))
//   ],
//   '三沙市': [
//     new CityBanner('西沙群岛 · 南海明珠', $r('app.media.hn_ss_1')),
//     new CityBanner('永兴岛 · 南海心脏', $r('app.media.hn_ss_2')),
//     new CityBanner('七连屿 · 七色海疆', $r('app.media.hn_ss_3'))
//   ],
//
//   // 5. 西南地区 (川、云、贵、藏)
//   '成都市': [
//     new CityBanner('熊猫基地 · 国宝家园', $r('app.media.sc_cd_1')),
//     new CityBanner('宽窄巷子 · 成都记忆', $r('app.media.sc_cd_2')),
//     new CityBanner('锦里 · 三国遗风', $r('app.media.sc_cd_3')),
//     new CityBanner('都江堰 · 千年水利', $r('app.media.sc_cd_4'))
//   ],
//   '绵阳市': [
//     new CityBanner('越王楼 · 唐代名楼', $r('app.media.sc_my_1')),
//     new CityBanner('七曲山 · 文昌祖庭', $r('app.media.sc_my_2')),
//     new CityBanner('李白故里 · 诗仙之乡', $r('app.media.sc_my_3'))
//   ],
//   '宜宾市': [
//     new CityBanner('蜀南竹海 · 翠甲天下', $r('app.media.sc_yb_1')),
//     new CityBanner('李庄古镇 · 抗战文脉', $r('app.media.sc_yb_2')),
//     new CityBanner('五粮液酒圣山 · 酒都飘香', $r('app.media.sc_yb_3'))
//   ],
//   '昆明市': [
//     new CityBanner('石林 · 天下第一', $r('app.media.yn_km_1')),
//     new CityBanner('滇池 · 高原明珠', $r('app.media.yn_km_2')),
//     new CityBanner('翠湖 · 春城碧玉', $r('app.media.yn_km_3'))
//   ],
//   '丽江市': [
//     new CityBanner('丽江古城 · 四方街韵', $r('app.media.yn_lj_1')),
//     new CityBanner('玉龙雪山 · 纳西圣山', $r('app.media.yn_lj_2')),
//     new CityBanner('束河古镇 · 茶马古道', $r('app.media.yn_lj_3'))
//   ],
//   '大理白族自治州': [
//     new CityBanner('洱海 · 高原明珠', $r('app.media.yn_dl_1')),
//     new CityBanner('大理古城 · 风花雪月', $r('app.media.yn_dl_2')),
//     new CityBanner('崇圣寺三塔 · 大理地标', $r('app.media.yn_dl_3'))
//   ],
//   '西双版纳傣族自治州': [
//     new CityBanner('星光夜市 · 傣泰风情', $r('app.media.yn_bn_1')),
//     new CityBanner('热带植物园 · 植物王国', $r('app.media.yn_bn_2')),
//     new CityBanner('野象谷 · 亚洲象乡', $r('app.media.yn_bn_3'))
//   ],
//   '贵阳市': [
//     new CityBanner('甲秀楼 · 贵阳地标', $r('app.media.gz_gy_1')),
//     new CityBanner('黔灵山 · 黔南第一', $r('app.media.gz_gy_2')),
//     new CityBanner('花果园 · 贵阳新貌', $r('app.media.gz_gy_3'))
//   ],
//   '遵义市': [
//     new CityBanner('遵义会议会址 · 红色圣地', $r('app.media.gz_zy_1')),
//     new CityBanner('赤水丹霞 · 丹霞之冠', $r('app.media.gz_zy_2')),
//     new CityBanner('海龙屯 · 土司城堡', $r('app.media.gz_zy_3'))
//   ],
//   '拉萨市': [
//     new CityBanner('布达拉宫 · 雪域圣殿', $r('app.media.xz_ls_1')),
//     new CityBanner('大昭寺 · 藏传圣地', $r('app.media.xz_ls_2')),
//     new CityBanner('纳木错 · 天湖圣境', $r('app.media.xz_ls_3'))
//   ],
//
//   // 6. 西北地区 (陕、甘、青、宁、新)
//   '西安市': [
//     new CityBanner('兵马俑 · 世界奇迹', $r('app.media.sx_xa_1')),
//     new CityBanner('大唐不夜城 · 盛唐夜景', $r('app.media.sx_xa_2')),
//     new CityBanner('城墙 · 古都屏障', $r('app.media.sx_xa_3')),
//     new CityBanner('大雁塔 · 玄奘译经', $r('app.media.sx_xa_4'))
//   ],
//   '宝鸡市': [
//     new CityBanner('法门寺 · 佛骨圣地', $r('app.media.sx_bj_1')),
//     new CityBanner('太白山 · 秦岭之巅', $r('app.media.sx_bj_2')),
//     new CityBanner('青铜器博物院 · 青铜之乡', $r('app.media.sx_bj_3'))
//   ],
//   '咸阳市': [
//     new CityBanner('乾陵 · 二帝合葬', $r('app.media.sx_xy_1')),
//     new CityBanner('昭陵 · 唐宗陵寝', $r('app.media.sx_xy_2')),
//     new CityBanner('袁家村 · 关中民俗', $r('app.media.sx_xy_3'))
//   ],
//   '兰州市': [
//     new CityBanner('中山铁桥 · 黄河第一', $r('app.media.gs_lz_1')),
//     new CityBanner('黄河母亲 · 金城地标', $r('app.media.gs_lz_2')),
//     new CityBanner('白塔山 · 金城屏障', $r('app.media.gs_lz_3'))
//   ],
//   '酒泉市': [
//     new CityBanner('莫高窟 · 丝路瑰宝', $r('app.media.gs_jq_1')),
//     new CityBanner('鸣沙山 · 沙岭晴鸣', $r('app.media.gs_jq_2')),
//     new CityBanner('雅丹地貌 · 魔鬼之城', $r('app.media.gs_jq_3'))
//   ],
//   '西宁市': [
//     new CityBanner('塔尔寺 · 藏传圣地', $r('app.media.qh_xn_1')),
//     new CityBanner('青海湖 · 高原圣湖', $r('app.media.qh_xn_2')),
//     new CityBanner('日月山 · 唐蕃古道', $r('app.media.qh_xn_3'))
//   ],
//   '银川市': [
//     new CityBanner('西夏陵 · 东方金字塔', $r('app.media.nx_yc_1')),
//     new CityBanner('镇北堡影城 · 大话西游', $r('app.media.nx_yc_2')),
//     new CityBanner('览山公园 · 贺兰晴雪', $r('app.media.nx_yc_3'))
//   ],
//   '乌鲁木齐市': [
//     new CityBanner('国际大巴扎 · 西域风情', $r('app.media.xj_wlmq_1')),
//     new CityBanner('天山天池 · 瑶池仙境', $r('app.media.xj_wlmq_2')),
//     new CityBanner('红山 · 乌市地标', $r('app.media.xj_wlmq_3'))
//   ],
//   '吐鲁番市': [
//     new CityBanner('火焰山 · 赤地千里', $r('app.media.xj_tlf_1')),
//     new CityBanner('坎儿井 · 地下运河', $r('app.media.xj_tlf_2')),
//     new CityBanner('葡萄沟 · 甜蜜之乡', $r('app.media.xj_tlf_3'))
//   ],
//
//   // 7. 北方及东北 (辽、吉、黑、晋、蒙)
//   '沈阳市': [
//     new CityBanner('沈阳故宫 · 关外紫禁城', $r('app.media.ln_sy_1')),
//     new CityBanner('张氏帅府 · 东北王居', $r('app.media.ln_sy_2')),
//     new CityBanner('中街 · 百年商街', $r('app.media.ln_sy_3'))
//   ],
//   '大连市': [
//     new CityBanner('星海广场 · 亚洲最大', $r('app.media.ln_dl_1')),
//     new CityBanner('棒棰岛 · 黄海明珠', $r('app.media.ln_dl_2')),
//     new CityBanner('海洋世界 · 亲子乐园', $r('app.media.ln_dl_3'))
//   ],
//   '长春市': [
//     new CityBanner('伪满皇宫 · 末代行宫', $r('app.media.jl_cc_1')),
//     new CityBanner('净月潭 · 森林氧吧', $r('app.media.jl_cc_2')),
//     new CityBanner('长影世纪城 · 电影主题', $r('app.media.jl_cc_3'))
//   ],
//   '吉林市': [
//     new CityBanner('雾凇岛 · 玉树琼花', $r('app.media.jl_jl_1')),
//     new CityBanner('松花湖 · 北国明珠', $r('app.media.jl_jl_2')),
//     new CityBanner('北山 · 吉林胜境', $r('app.media.jl_jl_3'))
//   ],
//   '哈尔滨市': [
//     new CityBanner('索菲亚教堂 · 俄式风情', $r('app.media.hlj_heb_1')),
//     new CityBanner('冰雪大世界 · 冰雕王国', $r('app.media.hlj_heb_2')),
//     new CityBanner('中央大街 · 欧式建筑', $r('app.media.hlj_heb_3')),
//     new CityBanner('亚布力 · 滑雪胜地', $r('app.media.hlj_heb_4'))
//   ],
//   '太原市': [
//     new CityBanner('晋祠 · 三晋之胜', $r('app.media.sx_ty_1')),
//     new CityBanner('双塔寺 · 晋阳地标', $r('app.media.sx_ty_2')),
//     new CityBanner('蒙山大佛 · 北齐石刻', $r('app.media.sx_ty_3'))
//   ],
//   '大同市': [
//     new CityBanner('云冈石窟 · 北魏石刻', $r('app.media.sx_dt_1')),
//     new CityBanner('悬空寺 · 空中楼阁', $r('app.media.sx_dt_2')),
//     new CityBanner('大同古城 · 北魏京华', $r('app.media.sx_dt_3'))
//   ],
//   '呼和浩特市': [
//     new CityBanner('大召寺 · 藏传圣地', $r('app.media.nmg_hhht_1')),
//     new CityBanner('塞上老街 · 明清风情', $r('app.media.nmg_hhht_2')),
//     new CityBanner('内蒙古博物院 · 草原瑰宝', $r('app.media.nmg_hhht_3'))
//   ],
//   '包头市': [
//     new CityBanner('五当召 · 草原布达拉', $r('app.media.nmg_bt_1')),
//     new CityBanner('赛汗塔拉 · 城中草原', $r('app.media.nmg_bt_2')),
//     new CityBanner('北方兵器城 · 军工博览', $r('app.media.nmg_bt_3'))
//   ],
//   '鄂尔多斯市': [
//     new CityBanner('响沙湾 · 大漠驼铃', $r('app.media.nmg_eeds_1')),
//     new CityBanner('成吉思汗陵 · 一代天骄', $r('app.media.nmg_eeds_2')),
//     new CityBanner('康巴什 · 草原新城', $r('app.media.nmg_eeds_3'))
//   ],
//
  // 默认兜底
  '默认': [new CityBanner('寻域 · 探索城市之魂', $r('app.media.start'))]
};

export function getBannerByCity(city: string): CityBanner[] {
  if (!city || city === '定位中...') {
    return CITY_BANNER_CONFIG['默认'];
  }

  if (CITY_BANNER_CONFIG[city]) {
    return CITY_BANNER_CONFIG[city];
  }
  const cleanName = city.replace(/市|省|自治区|特别行政区|地区|自治州|盟|旗/, '').trim();
  const keys = Object.keys(CITY_BANNER_CONFIG);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (key !== '默认' && (key.includes(cleanName) || cleanName.includes(key.replace(/市|省|自治区|特别行政区|地区|自治州|盟|旗/, '')))) {
      return CITY_BANNER_CONFIG[key];
    }
  }
  return CITY_BANNER_CONFIG['默认'];
}