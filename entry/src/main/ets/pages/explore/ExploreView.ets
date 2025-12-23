import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';

// --- 1. 严格的类型定义：确保 JSON 解析能跑通 ---
interface WeatherNow {
  temperature: string;
  text: string;
}
interface WeatherResult {
  now: WeatherNow;
}
interface WeatherResponse {
  results: WeatherResult[];
}
interface BannerInfo {
  title: string;
  color: string;
}

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '8°C';
  @State weatherText: string = '阴';
  @State searchText: string = '';
  @State selectIndex: number = 0; // 修复：重命名 tabIndex 避免系统冲突

  @State bannerList: BannerInfo[] = [
    { title: '武汉黄鹤楼 · 千古名胜', color: '#FF6B6B' },
    { title: '东湖绿道 · 最美骑行地', color: '#4ECDC4' },
    { title: '湖北省博物馆 · 越王勾践剑', color: '#45B7D1' }
  ];

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.initLocation();
  }

  // --- 2. 真实定位与天气请求 ---
  async initLocation() {
    let isAuth = await LocationManager.requestPermission(this.context);
    if (isAuth) {
      const res = await LocationManager.getRealCity();
      this.currentCity = res;
      this.fetchRealWeather(res);
    }
  }

  async fetchRealWeather(city: string) {
    let httpRequest = http.createHttp();
    try {
      // 真实天气 API
      let url = `https://api.seniverse.com/v3/weather/now.json?key=S-v_mP24n0z-VpL01&location=${encodeURIComponent(city)}&language=zh-Hans&unit=c`;
      let response = await httpRequest.request(url);

      if (response.responseCode === 200) {
        // 关键修复：显式转换解析后的类型
        let result = JSON.parse(response.result as string) as WeatherResponse;
        if (result.results && result.results.length > 0) {
          let nowData = result.results[0].now;
          // 这里是数据更新的核心，更新后 UI 会自动重绘
          this.weatherInfo = `${nowData.temperature}°C`;
          this.weatherText = nowData.text;
        }
      }
    } catch (err) {
      console.error('Weather update failed');
    } finally {
      httpRequest.destroy();
    }
  }

  // 修复：使用系统存在的图标资源名
  getWeatherIcon(text: string): Resource {
    if (text.includes('晴')) return $r('sys.symbol.sun_max_fill');
    if (text.includes('雨')) return $r('sys.symbol.light_rain');
    if (text.includes('阴') || text.includes('多云')) return $r('sys.symbol.cloud_fill');
    return $r('sys.symbol.cloud_sun_fill');
  }

  showCityPicker() {
    const cities = ['武汉市', '北京市', '上海市', '成都市', '广州市'];
    TextPickerDialog.show({
      range: cities,
      selected: cities.indexOf(this.currentCity),
      onAccept: (value: TextPickerResult) => {
        this.currentCity = value.value as string;
        this.fetchRealWeather(this.currentCity);
      }
    })
  }

  build() {
    Column() {
      // 1. 顶部搜索栏
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(18).fontColor(['#007DFF'])
          Text(this.currentCity).fontSize(15).fontWeight(FontWeight.Bold).margin({ left: 4 })
          SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(12).fontColor(['#999'])
        }
        .onClick(() => this.showCityPicker())
        .width('30%')

        Search({ value: this.searchText, placeholder: '搜索目的地/景点' })
          .layoutWeight(1).height(36).backgroundColor('#F1F3F5')

        Row() {
          // 根据动态获取到的 weatherText 显示对应图标
          SymbolGlyph(this.getWeatherIcon(this.weatherText)).fontSize(18).fontColor(['#FFAD0A'])
          Text(this.weatherInfo).fontSize(11).margin({ left: 3 })
        }.width('15%').justifyContent(FlexAlign.End)
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
            this.CategoryIcon('景点', $r('sys.symbol.map_badge_cloud_slash_fill'))
            this.CategoryIcon('美食', $r('sys.symbol.fork_knife'))
            this.CategoryIcon('酒店', $r('sys.symbol.bed_double_fill'))
            this.CategoryIcon('交通', $r('sys.symbol.car_fill'))
            this.CategoryIcon('攻略', $r('sys.symbol.paperplane_fill'))
            this.CategoryIcon('周边', $r('sys.symbol.mountain_2_fill'))
            this.CategoryIcon('笔记', $r('sys.symbol.doc_text_fill'))
            this.CategoryIcon('门票', $r('sys.symbol.ticket_fill'))
            this.CategoryIcon('打卡', $r('sys.symbol.mappin_and_rectangle'))
            this.CategoryIcon('更多', $r('sys.symbol.square_grid_2x2'))
          }
          .width('100%')

          // 4. 寻域精品路线
          Column() {
            this.SectionHeader('寻域精品路线')
            this.RouteCard('两江四岸灯光秀之旅', '长江大桥 - 江滩 - 轮渡', '5.2km')
            this.RouteCard('知音文化深度游', '古琴台 - 晴川阁 - 龟山', '4.8km')
          }

          // 修复：ListItem 只能在 List 中使用，这里改用 Column 占位
          Column().height(80)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F8F8F8')
  }

  @Builder BannerItem(title: string, color: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Rect().width('100%').height('100%').fill(color).borderRadius(12).opacity(0.2)
      Column() {
        Text('当地热门').fontSize(10).fontColor('#FFFFFF').backgroundColor('#007DFF').padding({left:6, right:6, top:2, bottom:2}).borderRadius(4)
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin({ top: 8 })
      }.margin(20).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder CategoryIcon(name: string, icon: Resource) {
    Column() {
      SymbolGlyph(icon).fontSize(24).fontColor(['#333'])
      Text(name).fontSize(12).margin({ top: 8 }).fontColor('#666')
    }.width('20%').margin({ bottom: 20 })
  }

  @Builder SectionHeader(title: string) {
    Row() {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold)
      Blank()
      Text('查看更多 >').fontSize(12).fontColor('#999')
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