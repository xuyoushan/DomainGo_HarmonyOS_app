export interface ToolkitTip {
  title: string;      // 锦囊模块标题（如：生存穿衣法则）
  icon: Resource;     // 图标
  color: string;      // 模块主题色
  mainInfo: string;   // 正经显示的实时信息/主词条
  subInfo: string;    // 正经的辅助补充/字面解释
  crazyNote: string;  // 【灵魂】不正经的备注、避坑、碎碎念
}

export const CITY_TOOLKIT_CONFIG: Record<string, ToolkitTip[]> = {
  '武汉市': [
    {
      title: '生存穿衣法则',
      icon: $r('sys.symbol.shirt'),
      color: '#007DFF',
      mainInfo: '当前状态：过早热气加持',
      subInfo: '建议：洋葱式叠穿。',
      crazyNote: '实战提醒：在该城市，体感温度取决于你刚吃的辣椒浓度。若风力超过4级，请在兜里放两块砖头防止被吹进长江，或在过早摊位前借热气取暖。'
    },
    {
      title: '方言语义解析',
      icon: $r('sys.symbol.mic_fill'),
      color: '#FF9500',
      mainInfo: '“冒得事”',
      subInfo: '字面意思：没关系 / 没事。',
      crazyNote: '深度提示：如果本地人对你说这句话时语速极快且头也不回，那是触发了“懒得理你”剧情，请不要追问，否则可能升级为“你要搞么斯”的对峙局面。'
    },
    {
      title: '陆地飞行协议',
      icon: $r('sys.symbol.bus_fill'),
      color: '#65bb5c',
      mainInfo: '公交521路（或任意线路）',
      subInfo: '载具等级：航天级地面模拟器。',
      crazyNote: '飞行守则：请紧握扶手，不要试图在行驶中喝水。武汉公交司机的梦想是开战斗机，如果他超了一辆跑车，请保持淡定，这只是基本操作。'
    },
    {
      title: '过早排队力学',
      icon: $r('sys.symbol.heart_fill'),
      color: '#FF2D55',
      mainInfo: '排队时长预计：15分钟',
      subInfo: '检测到热干面/豆皮信号。',
      crazyNote: '排队潜规则：如果前面有人一次性帮五个同事带早餐，请启动“武汉式抱怨”：嘴里发出“嘶”的一声并看表。此时老板可能会因为心虚多给你加两粒萝卜丁。'
    },
    {
      title: '特产成分分析',
      icon: $r('sys.symbol.square_fill_grid_2x2'),
      color: '#81ECEC',
      mainInfo: '热干面 (Hot Dry Noodles)',
      subInfo: '能量占比：碳水 100%。',
      crazyNote: '灵魂成分：面条 30%，芝麻酱 20%，剩下的 50% 是老板在 30 秒内完成拌、挑、甩动作时产生的残影，以及那一勺消失在碗底的萝卜丁。'
    },
    {
      title: '时空乱序监测',
      icon: $r('sys.symbol.sun_max_fill'),
      color: '#FFEAA7',
      mainInfo: '季节判定：由于算法紊乱，判定失败',
      subInfo: '当前可能处于：春夏秋冬随机切换模式。',
      crazyNote: '系统忠告：在武汉，早上穿羽绒服和中午穿短袖的人擦肩而过时，请互道一声“珍重”，因为你们都没错，错的是武汉的天气预报。'
    },
    {
      title: '地理定位盲盒',
      icon: $r('sys.symbol.location_right_fill'),
      color: '#A29BFE',
      mainInfo: '附近 500 米隐藏点',
      subInfo: '坐标：老巷深处。',
      crazyNote: '避坑指南：如果路边看到在树下下棋的老头且他正处于劣势，千万别指点，否则将触发“长达两小时的汉口/武昌野史强制听讲”且无法跳过。'
    }
  ]
  // 后续继续添加：
  // '北京市': [...],
  // '成都市': [...],
};

export const DEFAULT_TOOLKIT_DATA: ToolkitTip[] = [
  {
    title: '城市探索协议',
    icon: $r('sys.symbol.info_circle_fill'),
    color: '#999999',
    mainInfo: '信号扫描中...',
    subInfo: '该城市锦囊尚未同步。',
    crazyNote: '也许这个城市的人太正经了，我们还没找到他们的胡说八道协议。你可以先随便走走，别丢了就行。'
  }
];