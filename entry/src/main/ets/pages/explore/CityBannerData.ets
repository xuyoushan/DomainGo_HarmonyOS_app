// CityBannerData.ets

export class CityBanner {
  title: string;
  image: Resource;
  constructor(title: string, image: Resource) {
    this.title = title;
    this.image = image;
  }
}

export const CITY_BANNER_CONFIG: Record<string, CityBanner[]> = {
  '北京市': [
    new CityBanner('故宫 · 红墙深处', $r('app.media.bj_bj_1')),
    new CityBanner('天坛 · 祭天祈年', $r('app.media.bj_bj_2')),
    new CityBanner('长城 · 万里雄风', $r('app.media.bj_bj_3')),
    new CityBanner('颐和园 · 昆明湖色', $r('app.media.bj_bj_4')),
    new CityBanner('三里屯 · 时尚中心', $r('app.media.bj_bj_5'))
  ],
  '上海市': [
    new CityBanner('外滩 · 万国建筑', $r('app.media.sh_sh_1')),
    new CityBanner('陆家嘴 · 摩天楼群', $r('app.media.sh_sh_2')),
    new CityBanner('豫园 · 城隍记忆', $r('app.media.sh_sh_3')),
    new CityBanner('南京路 · 十里洋场', $r('app.media.sh_sh_4')),
    new CityBanner('迪士尼 · 奇妙梦幻', $r('app.media.sh_sh_5'))
  ],
  '天津市': [
    new CityBanner('天津之眼 · 摩天之轮', $r('app.media.tj_tj_1')),
    new CityBanner('意式风情区 · 欧陆景观', $r('app.media.tj_tj_2')),
    new CityBanner('古文化街 · 泥人张', $r('app.media.tj_tj_3'))
  ],
  '重庆市': [
    new CityBanner('洪崖洞 · 吊脚楼夜色', $r('app.media.cq_cq_1')),
    new CityBanner('李子坝 · 轻轨穿楼', $r('app.media.cq_cq_2')),
    new CityBanner('解放碑 · 时光之门', $r('app.media.cq_cq_3')),
    new CityBanner('武隆 · 地质公园', $r('app.media.cq_cq_4')),
    new CityBanner('磁器口 · 巴渝古镇', $r('app.media.cq_cq_5'))
  ],
  '武汉市': [
    new CityBanner('黄鹤楼 · 荆楚名胜', $r('app.media.hb_wh_1')),
    new CityBanner('长江大桥 · 跨江巨龙', $r('app.media.hb_wh_2')),
    new CityBanner('东湖 · 樱花园', $r('app.media.hb_wh_3')),
    new CityBanner('省博 · 越王勾践剑', $r('app.media.hb_wh_4'))
  ],
  '成都市': [new CityBanner('熊猫基地', $r('app.media.sc_cd_1')), new CityBanner('宽窄巷子', $r('app.media.sc_cd_2')), new CityBanner('锦里', $r('app.media.sc_cd_3')), new CityBanner('都江堰', $r('app.media.sc_cd_4'))],
  // 默认兜底
  '默认': [new CityBanner('寻域 · 探索城市之魂', $r('app.media.map_china_tech'))]
};

/**
 * 核心检索逻辑：精准匹配 -> 模糊提取 -> 默认兜底
 */
export function getBannerByCity(city: string): CityBanner[] {
  if (CITY_BANNER_CONFIG[city]) {
    return CITY_BANNER_CONFIG[city];
  }
  const cleanName = city.replace(/市|地区|自治州|盟/g, '');
  for (let key of Object.keys(CITY_BANNER_CONFIG)) {
    if (key.includes(cleanName)) return CITY_BANNER_CONFIG[key];
  }
  return CITY_BANNER_CONFIG['默认'];
}