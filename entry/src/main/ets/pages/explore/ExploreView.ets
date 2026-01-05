import { LocationManager, RealLocation } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { PROVINCE_CITY_DATA } from '../../models/CityData';
import { CITY_BANNER_CONFIG, CityBanner } from '../../models/CityBannerData';
import { promptAction, router } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute, ScenicSpot } from '../../models/RouteData';

// --- 关键：引入外部动态城市数据 ---
import { CITY_EXPLORE_MAP, DEFAULT_EXPLORE_DATA, CityExploreConfig } from '../../models/ExploreCityData';

interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }

// 定义话题接口
interface HotTopic { title: string; color: string; count: string; }

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @State weatherText: string = '阴';
  @State searchText: string = '';

  @State hotTopics: HotTopic[] = [
    { title: '武汉樱花地图', color: '#FFEAA7', count: '3.5w' },
    { title: '老汉口建筑寻踪', color: '#81ECEC', count: '1.2w' },
    { title: '地名网寻根之旅', color: '#FAB1A0', count: '8900' }
  ];

  private context = getContext(this) as common.UIAbilityContext;

  // ✅ 辅助方法：获取当前城市的实时配置
  getCityConfig(): CityExploreConfig {
    return CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
  }

  aboutToAppear() {
    // 🔥 进入页面就获取定位（后台完成）
    this.initLocation();
  }

  async initLocation() {
    try {
      const isAuth = await LocationManager.requestPermission(this.context)
      if (isAuth) {
        // 获取真实城市
        const city = await LocationManager.getRealCity(this.context)
        if (city) {
          this.currentCity = city
          AppStorage.setOrCreate('currentCity', city)
          console.info('[Explore] 定位城市:', city)
          // 刷新天气
          this.fetchRealWeather(city)
        }
      } else {
        console.warn('[Explore] 定位权限未授予，使用默认城市', this.currentCity)
        this.fetchRealWeather(this.currentCity)
      }
    } catch (err) {
      console.error('[Explore] 定位失败', err)
      this.fetchRealWeather(this.currentCity)
    }
  }



  // 城市选择器：保留原逻辑
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
              this.fetchRealWeather(selectedCity);
            }
          })
        }, 300)
      }
    })
  }

  // 天气获取：保留原逻辑
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

  // // 定位初始化：保留原逻辑
  // async initLocation() {
  //   let isAuth = await LocationManager.requestPermission(this.context);
  //   if (isAuth) {
  //     const res = await LocationManager.getRealCity();
  //     if (res) {
  //       AppStorage.setOrCreate('currentCity', res);
  //       this.currentCity = res;
  //       this.fetchRealWeather(res);
  //     }
  //   } else {
  //     this.fetchRealWeather(this.currentCity);
  //   }
  // }

  getWeatherIcon(text: string): Resource {
    if (text.includes('晴')) return $r('sys.symbol.sun_max_fill');
    if (text.includes('雨')) return $r('sys.symbol.light_rain');
    if (text.includes('阴') || text.includes('多云')) return $r('sys.symbol.cloud_fill');
    return $r('sys.symbol.cloud_sun_fill');
  }

  build() {
    Column() {
      // --- 顶部状态栏 ---
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
          // --- 轮播图 (已修改：移除 bannerList，直接读取配置) ---
          Swiper() {
            if (CITY_BANNER_CONFIG[this.currentCity]) {
              ForEach(CITY_BANNER_CONFIG[this.currentCity], (item: CityBanner) => {
                this.BannerImageItem(item.title, item.image)
              }, (item: CityBanner) => item.title)
            } else {
              // 兜底色块，保留功能
              this.BannerItem(`${this.currentCity} · 发现更多`, '#DCDDE1')
            }
          }
          .width('100%').height(180).autoPlay(true).borderRadius(12)

          // --- 寻域快报 (已修改：接入 getCityConfig().news) ---
          Row() {
            Text('寻域快报').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FF4500')
            Divider().vertical(true).height(14).margin({ left: 8, right: 8 }).color('#EEE')
            Swiper() {
              ForEach(this.getCityConfig().news, (news: string) => {
                Text(news).fontSize(12).fontColor('#333').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              }, (item: string) => item)
            }.vertical(true).autoPlay(true).indicator(false).layoutWeight(1).height(20)
          }
          .width('100%').padding(12).backgroundColor('#FFF5F5').borderRadius(8)

          // --- 热门搜索词 (已修改：接入 getCityConfig().keywords) ---
          Scroll() {
            Row() {
              ForEach(this.getCityConfig().keywords, (word: string) => {
                Text(word).fontSize(12).fontColor('#666').backgroundColor('#FFFFFF').padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(15).margin({ right: 8 }).border({ width: 1, color: '#F1F3F5' })
                  .onClick(() => this.searchText = word)
              }, (item: string) => item)
            }
          }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

          // --- 三排功能区 (保留原逻辑) ---
          Column() {
            Row() {
              this.CategoryIcon('城市印象', $r('sys.symbol.bookmark_fill'), '#007DFF')
              this.CategoryIcon('行政区划', $r('sys.symbol.map'), '#4ECDC4')
              this.CategoryIcon('地名故事', $r('sys.symbol.doc_text_fill'), '#A29BFE')
              this.CategoryIcon('城市名人', $r('sys.symbol.person_crop_circle_fill'), '#FF9500')
            }.width('100%')

            Row() {
              this.CategoryIcon('历史轴线', $r('sys.symbol.timer_circle_fill'), '#65bb5c')
              this.CategoryIcon('文化资源', $r('sys.symbol.flower'), '#FF2D55')
              this.CategoryIcon('特产风味', $r('sys.symbol.fork_knife'), '#FF6B6B')
              this.CategoryIcon('景点推荐', $r('sys.symbol.camera_fill'), '#45B7D1')
            }.width('100%').margin({ top: 15 })

            Row() {
              this.CategoryIcon('交通出行', $r('sys.symbol.car_fill'), '#5AC8FA')
              this.CategoryIcon('随手笔记', $r('sys.symbol.square_and_pencil'), '#FAB1A0')
              this.CategoryIcon('行程安排', $r('sys.symbol.calendar_001_fill'), '#9B51E0')
              this.CategoryIcon('全部', $r('sys.symbol.square_fill_grid_2x2'), '#8E8E93', true)
            }.width('100%').margin({ top: 15 })
          }.width('100%')

          // --- 正在讨论 (保留原逻辑) ---
          Column() {
            this.SectionHeader('正在讨论')
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.hotTopics, (topic: HotTopic) => {
                  this.TopicItem(topic.title, topic.count, topic.color)
                }, (item: HotTopic) => item.title)
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
          }

          // --- 动态路线推荐 (保留原逻辑) ---
          Column() {
            this.SectionHeader(`寻域 · ${this.currentCity}精品路线`)
            if (CITY_ROUTES[this.currentCity] && CITY_ROUTES[this.currentCity].length > 0) {
              ForEach(CITY_ROUTES[this.currentCity], (route: TravelRoute) => {
                this.NewRouteCard(route)
              }, (item: TravelRoute) => item.routeName)
            } else {
              Column() {
                SymbolGlyph($r('sys.symbol.map_badge_cloud_slash_fill')).fontSize(30).fontColor(['#DDD'])
                Text(`${this.currentCity} 路线正在火速规划中...`)
                  .fontSize(14).fontColor('#999').margin({ top: 10 })
              }.width('100%').padding(30).alignItems(HorizontalAlign.Center)
            }
          }
          Column().height(80)
        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F8F8F8')
  }

  // --- 所有原有 Builder 完整保留 ---
  @Builder BannerImageItem(title: string, img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img).width('100%').height('100%').borderRadius(12).objectFit(ImageFit.Cover)
      Text(title)
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .margin(15).textShadow({ radius: 8, color: '#90000000', offsetX: 2, offsetY: 2 })
    }
  }

  @Builder BannerItem(title: string, color: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Rect().width('100%').height('100%').fill(color).borderRadius(12).opacity(0.2)
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin(20)
    }
  }

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
      if (name === '城市印象') {
        router.pushUrl({ url: 'pages/features/DataDetailView', params: { title: name, cityName: this.currentCity, color: color, icon: icon } });
      } else if (isAll || name === '全部') {
        router.pushUrl({ url: 'pages/features/AllFunctionsView' });
      } else if (name === '随手笔记') {
        router.pushUrl({ url: 'pages/features/NoteView'})
      } else if (name === '历史轴线') {
        router.pushUrl({ url: 'pages/features/CityHistoryPage', params: { title: name, cityName: this.currentCity, color: color, icon: icon } });
      } else if (name === '城市名人') {
        router.pushUrl({ url: 'pages/features/CityCelebrityPage', params: { title: name, cityName: this.currentCity, color: color, icon: icon }});
      } else if (name === '行程安排') {
        router.pushUrl({ url: 'pages/features/ScheduleView'})
      } else {
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

  @Builder NewRouteCard(route: TravelRoute) {
    Row() {
      Column() {
        Circle({ width: 6, height: 6 }).fill('#007DFF')
        Rect().width(1).height(15).fill('#D8D8D8')
        Circle({ width: 6, height: 6 }).fill(Color.Transparent).stroke('#007DFF').strokeWidth(1)
      }.margin({ right: 12 })
      Column() {
        Text(route.routeName).fontSize(15).fontWeight(FontWeight.Bold)
        Text(`${route.spots.length}个打卡点 · 建议时间${route.spots.length > 3 ? '1天' : '半天'}`)
          .fontSize(12).fontColor('#666').margin({ top: 4 })
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)

      Button('同步行程').height(28).fontSize(11).backgroundColor('#007DFF')
        .onClick(() => {
          // ✅ API 21 正确写法：确保参数对象符合 router.RouterOptions
          const options: router.RouterOptions = {
            url: 'pages/features/TravelScheduleView',
            params: {
              'route': route,
              'cityName': this.currentCity
            }
          };
          router.pushUrl(options);
        })
    }
    .width('100%').padding(15).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 })
    .onClick(() => {
      const options: router.RouterOptions = {
        url: 'pages/features/TravelScheduleView',
        params: {
          'route': route,
          'cityName': this.currentCity
        }
      };
      router.pushUrl(options);
    })
  }

  jumpToGuide(route: TravelRoute) {
    router.pushUrl({
      url: 'pages/guide/GuideView',
      params: { route: route }
    }, (err) => {
      if (err) promptAction.showToast({ message: `跳转失败: ${err.message}` });
    })
  }
}