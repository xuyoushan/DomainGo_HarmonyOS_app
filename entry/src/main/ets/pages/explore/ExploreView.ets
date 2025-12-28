import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { PROVINCE_CITY_DATA } from './CityData';
import { CITY_BANNER_CONFIG, CityBanner } from './CityBannerData';
import { promptAction, router } from '@kit.ArkUI'; // 引入 router

// --- 接口定义 (完整保留) ---
interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }
interface BannerInfo { title: string; color: string; }
interface TravelRoute { title: string; desc: string; distance: string; }

// 定义话题接口
interface HotTopic { title: string; color: string; count: string; }

/**
 * ===============================
 * 城市 → 轮播图数据映射（完整保留）
 * ===============================
 */
const CITY_BANNER_DATA: Record<string, BannerInfo[]> = {
  "武汉市": [
    { title: '黄鹤楼 · 千古名胜', color: '#FF6B6B' },
    { title: '热干面 · 武汉早餐灵魂', color: '#FFD93D' },
    { title: '长江大桥 · 万里长江第一桥', color: '#4ECDC4' }
  ],
  "青岛市": [
    { title: '青岛啤酒 · 世界知名', color: '#74B9FF' },
    { title: '碧海蓝天 · 海滨城市', color: '#00B894' },
    { title: '海鲜盛宴 · 鲜美直达', color: '#FAB1A0' }
  ],
  "北京市": [
    { title: '故宫 · 紫禁城', color: '#E17055' },
    { title: '长城 · 万里雄关', color: '#636E72' },
    { title: '天安门 · 国家象征', color: '#D63031' }
  ]
};

// 【功能保留】城市路线数据
const CITY_ROUTES: Record<string, TravelRoute[]> = {
  "武汉市": [
    { title: '两江四岸灯光秀之旅', desc: '长江大桥 - 江滩 - 轮渡', distance: '5.2km' },
    { title: '知音文化深度游', desc: '古琴台 - 晴川阁 - 龟山', distance: '4.8km' },
    { title: '东湖绿道骑行线', desc: '梨园 - 磨山 - 凌波门', distance: '12.0km' }
  ],
  "北京市": [
    { title: '中轴线历史之旅', desc: '故宫 - 景山 - 钟鼓楼', distance: '6.5km' },
    { title: '皇家园林漫步', desc: '颐和园 - 圆明园', distance: '8.2km' }
  ]
};

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @State weatherText: string = '阴';
  @State searchText: string = '';

  // 【功能保留】原有的 Banner 逻辑兜底
  @State bannerList: BannerInfo[] = [
    { title: '武汉黄鹤楼 · 千古名胜', color: '#FF6B6B' },
    { title: '东湖绿道 · 最美骑行地', color: '#4ECDC4' },
    { title: '湖北省博物馆 · 越王勾践剑', color: '#45B7D1' }
  ];

  // 热门讨论数据（新增，用于充实页面）
  @State hotTopics: HotTopic[] = [
    { title: '武汉樱花地图', color: '#FFEAA7', count: '3.5w' },
    { title: '老汉口建筑寻踪', color: '#81ECEC', count: '1.2w' },
    { title: '地名网寻根之旅', color: '#FAB1A0', count: '8900' }
  ];

  private hotKeywords: string[] = ['热干面', '黄鹤楼', '武汉樱花', '省博', '江汉路'];
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.initLocation();
    this.updateBannerByCity(this.currentCity);
  }

  // --- 逻辑区：完整保留你的所有方法 ---
  updateBannerByCity(city: string) {
    if (CITY_BANNER_DATA[city]) {
      this.bannerList = CITY_BANNER_DATA[city];
    } else {
      this.bannerList = [
        { title: `${city} · 城市风光`, color: '#DCDDE1' },
        { title: '当地美食', color: '#B2BEC3' },
        { title: '热门打卡地', color: '#A4B0BE' }
      ];
    }
  }

  showCityPicker() {
    let provinces = Object.keys(PROVINCE_CITY_DATA);
    TextPickerDialog.show({
      range: provinces,
      selected: 0,
      onAccept: (pResult: TextPickerResult) => {
        let selectedProvince = pResult.value as string;
        let cities = PROVINCE_CITY_DATA[selectedProvince];
        setTimeout(() => {
          TextPickerDialog.show({
            range: cities,
            selected: 0,
            onAccept: (cResult: TextPickerResult) => {
              let selectedCity = cResult.value as string;
              this.currentCity = selectedCity;
              this.updateBannerByCity(selectedCity);
              this.fetchRealWeather(selectedCity);
            }
          })
        }, 300)
      }
    })
  }

  async fetchRealWeather(city: string) {
    let httpRequest = http.createHttp();
    let apiKey = 'S7zKUHHMAcavQT0_R';
    this.weatherInfo = '...';
    try {
      let queryCity = city.replace('市', '');
      let url = `https://api.seniverse.com/v3/weather/now.json?key=${apiKey}&location=${encodeURIComponent(queryCity)}&language=zh-Hans&unit=c&ts=${Date.now()}`;
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as WeatherResponse;
        if (result.results && result.results.length > 0) {
          let nowData = result.results[0].now;
          this.weatherInfo = `${nowData.temperature}°C`;
          this.weatherText = nowData.text;
        }
      }
    } catch (err) {
      this.weatherInfo = '网络异常';
    } finally {
      httpRequest.destroy();
    }
  }

  async initLocation() {
    let isAuth = await LocationManager.requestPermission(this.context);
    if (isAuth) {
      const res = await LocationManager.getRealCity();
      if (res) {
        // 【核心修复】同步更新全局存储
        AppStorage.setOrCreate('currentCity', res);
        this.currentCity = res;
        this.updateBannerByCity(res);
        this.fetchRealWeather(res);
      }
    } else {
      this.updateBannerByCity(this.currentCity);
      this.fetchRealWeather(this.currentCity);
    }
  }

  getWeatherIcon(text: string): Resource {
    if (text.includes('晴')) return $r('sys.symbol.sun_max_fill');
    if (text.includes('雨')) return $r('sys.symbol.light_rain');
    if (text.includes('阴') || text.includes('多云')) return $r('sys.symbol.cloud_fill');
    return $r('sys.symbol.cloud_sun_fill');
  }

  build() {
    Column() {
      // --- 1. 顶部状态栏 ---
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(18).fontColor(['#007DFF'])
          Text(this.currentCity).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 4 }).maxLines(1)
          SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(12).fontColor(['#999'])
        }.onClick(() => this.showCityPicker()).width('32%')

        Search({ value: this.searchText, placeholder: '搜索目的地' })
          .layoutWeight(1).height(36).backgroundColor('#F1F3F5')

        Row() {
          SymbolGlyph(this.getWeatherIcon(this.weatherText)).fontSize(18).fontColor(['#FFAD0A'])
          Text(this.weatherInfo).fontSize(11).margin({ left: 3 })
        }.width('18%').justifyContent(FlexAlign.End)
      }.width('100%').padding(12).backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 20 }) {
          // --- 2. 轮播图 ---
          Swiper() {
            if (CITY_BANNER_CONFIG[this.currentCity]) {
              ForEach(CITY_BANNER_CONFIG[this.currentCity], (item: CityBanner) => {
                this.BannerImageItem(item.title, item.image)
              }, (item: CityBanner) => item.title)
            } else {
              ForEach(this.bannerList, (item: BannerInfo) => {
                this.BannerItem(item.title, item.color)
              }, (item: BannerInfo) => item.title)
            }
          }
          .width('100%').height(180).autoPlay(true).borderRadius(12)

          // --- 3. 寻域快报 ---
          Row() {
            Text('寻域快报').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FF4500')
            Divider().vertical(true).height(14).margin({ left: 8, right: 8 }).color('#EEE')
            Swiper() {
              Text('地名网更新：武汉地名故事新增32条...').fontSize(12).fontColor('#333')
              Text('辛亥革命博物馆近期开放深度讲解预约...').fontSize(12).fontColor('#333')
              Text('发现武汉：里份文化探索路线正式上线...').fontSize(12).fontColor('#333')
            }.vertical(true).autoPlay(true).indicator(false).layoutWeight(1).height(20)
          }
          .width('100%').padding(12).backgroundColor('#FFF5F5').borderRadius(8)

          // 热门搜索词
          Scroll() {
            Row() {
              ForEach(this.hotKeywords, (word: string) => {
                Text(word).fontSize(12).fontColor('#666').backgroundColor('#FFFFFF').padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(15).margin({ right: 8 }).border({ width: 1, color: '#F1F3F5' })
                  .onClick(() => this.searchText = word)
              })
            }
          }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

          // --- 4. 三排功能区 ---
          Column() {
            Row() {
              this.CategoryIcon('城市印象', $r('sys.symbol.bookmark_fill'), '#007DFF')
              this.CategoryIcon('行政区划', $r('sys.symbol.map'), '#4ECDC4')
              this.CategoryIcon('地名故事', $r('sys.symbol.doc_text_fill'), '#A29BFE')
              this.CategoryIcon('城市名人', $r('sys.symbol.person_crop_circle_fill'), '#FF9500')
            }.width('100%')

            Row() {
              this.CategoryIcon('历史轴线', $r('sys.symbol.timer'), '#636E72')
              this.CategoryIcon('文化资源', $r('sys.symbol.flower'), '#FF2D55')
              this.CategoryIcon('特产风味', $r('sys.symbol.fork_knife'), '#FF6B6B')
              this.CategoryIcon('景点推荐', $r('sys.symbol.camera_fill'), '#45B7D1')
            }.width('100%').margin({ top: 15 })

            Row() {
              this.CategoryIcon('交通出行', $r('sys.symbol.car_fill'), '#5AC8FA')
              this.CategoryIcon('随手笔记', $r('sys.symbol.square_and_pencil'), '#FAB1A0')
              this.CategoryIcon('酒店住宿', $r('sys.symbol.bed_double_fill'), '#45B7D1')
              this.CategoryIcon('全部', $r('sys.symbol.square_fill_grid_2x2'), '#8E8E93', true)
            }.width('100%').margin({ top: 15 })
          }
          .width('100%')

          // --- 5. 正在讨论 ---
          Column() {
            this.SectionHeader('正在讨论')
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.hotTopics, (topic: HotTopic) => {
                  this.TopicItem(topic.title, topic.count, topic.color)
                })
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
          }

          // --- 6. 路线推荐 ---
          Column() {
            this.SectionHeader(`寻域 · ${this.currentCity}精品路线`)
            ForEach(CITY_ROUTES[this.currentCity] || CITY_ROUTES["武汉市"], (route: TravelRoute) => {
              this.RouteCard(route.title, route.desc, route.distance)
            })
          }
          Column().height(80)
        }
        .padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F8F8F8')
  }

  // --- UI 构建器 ---

  @Builder BannerImageItem(title: string, img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img).width('100%').height('100%').borderRadius(12).objectFit(ImageFit.Cover)
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin(15)
        .textShadow({ radius: 8, color: '#90000000', offsetX: 2, offsetY: 2 })
    }
  }

  @Builder BannerItem(title: string, color: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Rect().width('100%').height('100%').fill(color).borderRadius(12).opacity(0.2)
      Column() {
        Text('当地热门').fontSize(10).fontColor('#FFFFFF').backgroundColor('#007DFF')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin({ top: 8 })
      }.margin(20).alignItems(HorizontalAlign.Start)
    }
  }

  /**
   * 核心修改函数：修正跳转定位
   */
  @Builder CategoryIcon(name: string, icon: Resource, color: string, isAll: boolean = false) {
    Column() {
      Stack() {
        Circle().width(45).height(45).fill(color).opacity(0.1)
        SymbolGlyph(icon).fontColor([color]).fontSize(22)
      }
      Text(name).fontSize(12).margin({ top: 8 }).fontColor('#666')
    }
    .width('25%')
    .onClick(() => {
      // 1. 判断是否是“城市印象”或“全部”
      if (name === '城市印象') {
        router.pushUrl({
          url: 'pages/DataDetailView',
          params: {
            title: name,
            cityName: this.currentCity, // 【核心修改：使用动态定位值，不再写死北京市】
            color: color,
            icon: icon
          }
        });
      } else if (isAll || name === '全部') {
        // 如果点击的是全部，跳转到全部服务页面
        router.pushUrl({ url: 'pages/AllFunctionsView' });
      } else {
        // 其他功能暂时弹窗提示，不跳转
        promptAction.showToast({ message: `${name} 功能开发中...` });
      }
    })
  }

  @Builder TopicItem(title: string, count: string, color: string) {
    Column() {
      Text(`# ${title}`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
      Text(`${count} 参与讨论`).fontSize(11).fontColor('#666').margin({ top: 6 })
    }
    .width(140).height(70).padding(12).backgroundColor(color).borderRadius(12)
    .alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
  }

  @Builder SectionHeader(title: string) {
    Row() {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold)
      Blank()
      Text('更多 >').fontSize(12).fontColor('#999')
    }.width('100%').margin({ bottom: 15 })
  }

  @Builder RouteCard(title: string, desc: string, distance: string) {
    Row() {
      Column() {
        Circle({ width: 6, height: 6 }).fill('#007DFF')
        Rect().width(1).height(15).fill('#D8D8D8')
        Circle({ width: 6, height: 6 }).fill(Color.Transparent).stroke('#007DFF').strokeWidth(1)
      }.margin({ right: 12 })
      Column() {
        Text(title).fontSize(15).fontWeight(FontWeight.Bold)
        Text(desc).fontSize(12).fontColor('#666').margin({ top: 4 })
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text(distance).fontSize(13).fontColor('#007DFF')
    }
    .width('100%').padding(15).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 })
  }
}