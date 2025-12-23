import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { PROVINCE_CITY_DATA } from './CityData'; // 导入刚才创建的数据

// --- 接口定义 ---
interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }
interface BannerInfo { title: string; color: string; }

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @State weatherText: string = '阴';
  @State searchText: string = '';

  @State bannerList: BannerInfo[] = [
    { title: '武汉黄鹤楼 · 千古名胜', color: '#FF6B6B' },
    { title: '东湖绿道 · 最美骑行地', color: '#4ECDC4' },
    { title: '湖北省博物馆 · 越王勾践剑', color: '#45B7D1' }
  ];

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.initLocation();
  }

  // --- 城市选择核心逻辑：省市二级联动 ---
  showCityPicker() {
    let provinces = Object.keys(PROVINCE_CITY_DATA);

    // 1. 弹出省份选择器
    TextPickerDialog.show({
      range: provinces,
      selected: 0,
      onAccept: (pResult: TextPickerResult) => {
        let selectedProvince = pResult.value as string;
        let cities = PROVINCE_CITY_DATA[selectedProvince];

        // 2. 紧接着弹出该省下的地级市选择器
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
        }, 300) // 延迟一小会儿弹出，避免动画冲突
      }
    })
  }

  // --- 天气获取逻辑 (已经为你修正过 URL 拼接) ---
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
      } else {
        this.weatherInfo = `Err:${response.responseCode}`;
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
        this.currentCity = res;
        this.fetchRealWeather(res);
      }
    } else {
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
      // 1. 顶部搜索栏
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(18).fontColor(['#007DFF'])
          Text(this.currentCity)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(12).fontColor(['#999'])
        }
        .onClick(() => this.showCityPicker())
        .width('32%')

        Search({ value: this.searchText, placeholder: '搜索目的地' })
          .layoutWeight(1).height(36).backgroundColor('#F1F3F5')

        Row() {
          SymbolGlyph(this.getWeatherIcon(this.weatherText)).fontSize(18).fontColor(['#FFAD0A'])
          Text(this.weatherInfo).fontSize(11).margin({ left: 3 })
        }.width('18%').justifyContent(FlexAlign.End)
      }
      .width('100%').padding(12).backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 25 }) {
          // 2. 轮播图
          Swiper() {
            ForEach(this.bannerList, (item: BannerInfo) => {
              this.BannerItem(item.title, item.color)
            }, (item: BannerInfo) => item.title)
          }
          .width('100%').height(180).autoPlay(true).borderRadius(12)

          // 3. 功能矩阵
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            this.CategoryIcon('景点', $r('sys.symbol.map'), '#4ECDC4')
            this.CategoryIcon('美食', $r('sys.symbol.fork_knife'), '#FF6B6B')
            this.CategoryIcon('酒店', $r('sys.symbol.bed_double_fill'), '#45B7D1')
            this.CategoryIcon('交通', $r('sys.symbol.car_fill'), '#FFA07A')
            this.CategoryIcon('攻略', $r('sys.symbol.paperplane_fill'), '#A29BFE')
            this.CategoryIcon('周边', $r('sys.symbol.mountain_2_fill'), '#00B894')
            this.CategoryIcon('笔记', $r('sys.symbol.doc_text_fill'), '#FAB1A0')
            this.CategoryIcon('门票', $r('sys.symbol.ticket_fill'), '#74B9FF')
          }
          .width('100%')

          // 4. 精品路线
          Column() {
            this.SectionHeader('寻域精品路线')
            this.RouteCard('两江四岸灯光秀之旅', '长江大桥 - 江滩 - 轮渡', '5.2km')
            this.RouteCard('知音文化深度游', '古琴台 - 晴川阁 - 龟山', '4.8km')
          }

          Column().height(80)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F8F8F8')
  }

  // --- UI 构建器 ---
  @Builder BannerItem(title: string, color: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Rect().width('100%').height('100%').fill(color).borderRadius(12).opacity(0.2)
      Column() {
        Text('当地热门').fontSize(10).fontColor('#FFFFFF').backgroundColor('#007DFF').padding({left:6, right:6, top:2, bottom:2}).borderRadius(4)
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin({ top: 8 })
      }.margin(20).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder CategoryIcon(name: string, icon: Resource, color: string) {
    Column() {
      Stack() {
        Circle().width(45).height(45).fill(color).opacity(0.1)
        SymbolGlyph(icon).fontColor([color]).fontSize(22)
      }
      Text(name).fontSize(12).margin({ top: 8 }).fontColor('#666')
    }.width('25%').margin({ bottom: 20 })
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
        Circle({width:6, height:6}).fill('#007DFF')
        Rect().width(1).height(15).fill('#D8D8D8')
        Circle({width:6, height:6}).fill(Color.Transparent).stroke('#007DFF').strokeWidth(1)
      }.margin({right: 12})
      Column() {
        Text(title).fontSize(15).fontWeight(FontWeight.Bold)
        Text(desc).fontSize(12).fontColor('#666').margin({ top: 4 })
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text(distance).fontSize(13).fontColor('#007DFF')
    }
    .width('100%').padding(15).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 })
  }
}