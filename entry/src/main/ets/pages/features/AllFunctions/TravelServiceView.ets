import { router, promptAction } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { getCityTraffic, CityTrafficConfig, UniqueTraffic, MetroLine } from '../../../models/CityTrafficData';

interface AmapPoi { name: string; address: string; adname: string; }
interface AmapResponse { status: string; pois: AmapPoi[]; }

@Entry
@Component
struct TravelServiceView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @State selectedIndex: number = 2;
  @State destination: string = '';
  @State poiList: string[] = [];
  @State isShowPlatforms: boolean = false;
  @State currentMode: string = '';
  @State activePlatforms: string[] = [];
  @State cityConfig: CityTrafficConfig = getCityTraffic(this.currentCity);
  @State isShowTrafficDetail: boolean = false;
  @State selectedTrafficItem: UniqueTraffic | null = null;

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    let params = router.getParams() as Record<string, string>;
    if (params) {
      const type = params.defaultType as string;
      if (type === '休闲娱乐') this.selectedIndex = 0;
      else if (type === '酒店住宿') this.selectedIndex = 1;
      else if (type === '交通出行') this.selectedIndex = 2;
    }
  }

  async searchPoi(keyword: string) {
    if (!keyword) {
      this.poiList = [];
      return;
    }
    let httpRequest = http.createHttp();
    const amapKey = 'd4552bc3e20af2857f9cfd5ac95ded1d';
    try {
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(keyword)}&city=${encodeURIComponent(this.currentCity)}&offset=5&page=1&key=${amapKey}`;
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        if (res.status === '1' && res.pois) {
          this.poiList = res.pois.map(p => p.name);
        }
      }
    } catch (err) {
      console.error('POI_Search_Error');
    } finally {
      httpRequest.destroy();
    }
  }

  openPicker(mode: string) {
    this.currentMode = mode;
    const platformMap: Record<string, string[]> = {
      'taxi': ['高德', '百度', '神州', '滴滴'],
      'bike': ['美团', '哈啰', '微信', '支付宝'],
      'bus': ['微信', '支付宝', '车来了']
    };
    this.activePlatforms = platformMap[mode] || ['高德'];
    this.isShowPlatforms = true;
  }

  async handleJump(platform: string) {
    let uri = '';
    const dest = encodeURIComponent(this.destination);
    const city = this.currentCity.replace('市', '');

    if (this.currentMode === 'taxi') {
      if (!this.destination) {
        promptAction.showToast({ message: '请先搜索目的地' });
        return;
      }
      if (platform === '高德') uri = `amapuri://route/plan/?dname=${dest}&dev=0&t=0`;
      else if (platform === '百度') uri = `baidumap://map/direction?destination=${dest}&mode=driving&region=${city}`;
      else uri = `diditaxi://`;
    } else if (this.currentMode === 'bike' || this.currentMode === 'bus') {
      if (platform === '微信') uri = 'weixin://dl/scan';
      else if (platform === '支付宝') uri = 'alipays://platformapi/startapp?appId=10000007';
    }

    if (uri) {
      try {
        let want: Want = {
          action: 'ohos.want.action.viewData',
          entities: ['entity.system.browsable'],
          uri: uri
        };
        await this.context.startAbility(want);
        promptAction.showToast({ message: `正在前往 ${platform}...` });
      } catch (e) {
        promptAction.showToast({ message: `未检测到 ${platform} 客户端` });
      }
    }
    this.isShowPlatforms = false;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column().width('100%').height('100%').backgroundColor('#F8F9FB')

      Column() {
        this.HeaderBar()

        Tabs({ index: this.selectedIndex }) {
          TabContent() { this.LeisureModule() }.tabBar(this.TabBuilder('🎪 休闲', 0))
          TabContent() { this.HotelModule() }.tabBar(this.TabBuilder('🏨 酒店', 1))
          TabContent() { this.TrafficModule() }.tabBar(this.TabBuilder('🚗 交通', 2))
        }
        .barMode(BarMode.Fixed)
        .barHeight(56)
        .onChange(index => this.selectedIndex = index)
      }
      .width('100%')

      if (this.isShowPlatforms) this.PlatformPicker()

      if (this.isShowTrafficDetail && this.selectedTrafficItem) {
        this.DetailPanel(
          this.selectedTrafficItem.name,
          `${this.selectedTrafficItem.type}\n运营时间：${this.selectedTrafficItem.operationTime}\n票价：${this.selectedTrafficItem.price}\n\n${this.selectedTrafficItem.desc}`,
          this.selectedTrafficItem.color,
          () => this.isShowTrafficDetail = false
        )
      }
    }
  }

  @Builder TrafficModule() {
    Scroll() {
      if (!this.cityConfig) {
        Column({ space: 15 }) {
          LoadingProgress().width(60).height(60).color('#007DFF')
          Text(`正在检索 ${this.currentCity} 交通数据...`).fontSize(14).fontColor('#666')
        }.width('100%').height('80%').justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 24 }) {
          this.HeroSection()

          Column() {
            Search({ placeholder: '搜地点、查线路...', value: this.destination })
              .height(54)
              .backgroundColor(Color.White)
              .borderRadius(this.poiList.length > 0 ? { topLeft: 12, topRight: 12 } : 12)
              .onChange(v => {
                this.destination = v;
                this.searchPoi(v);
              })

            if (this.destination.length > 0 && this.poiList.length > 0) {
              List() {
                ForEach(this.poiList, (item: string) => {
                  ListItem() {
                    Text(item).fontSize(14).width('100%').padding(15)
                      .onClick(() => {
                        this.destination = item;
                        this.poiList = [];
                        this.openPicker('taxi');
                      })
                  }.border({ width: { bottom: 0.5 }, color: '#f5f5f5' })
                }, (item: string) => item)
              }
              .backgroundColor(Color.White)
              .width('100%')
              .borderRadius({ bottomLeft: 12, bottomRight: 12 })
              .shadow({ radius: 10, color: '#10000000' })
              .constraintSize({ maxHeight: 200 })
            }
          }.width('100%').zIndex(100)

          if (this.cityConfig.uniqueTraffic?.length > 0) {
            Column({ space: 12 }) {
              this.ModuleTitle(`${this.currentCity} · 特色出行`)
              List({ space: 16 }) {
                ForEach(this.cityConfig.uniqueTraffic, (item: UniqueTraffic) => {
                  ListItem() { this.UniqueTrafficCard(item) }
                }, (item: UniqueTraffic) => item.name)
              }.listDirection(Axis.Horizontal).height(130).edgeEffect(EdgeEffect.Spring).scrollBar(BarState.Off)
            }.alignItems(HorizontalAlign.Start)
          }

          if (this.cityConfig.metro) {
            Column({ space: 12 }) {
              Row() {
                this.ModuleTitle('轨道交通概览')
                Blank()
                Text(this.cityConfig.metro.basePrice || '价格查询中').fontSize(14).fontWeight(700).fontColor('#FF9500')
              }.width('100%')

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.cityConfig.metro.lines, (line: MetroLine) => {
                  Row() {
                    Circle({ width: 8, height: 8 }).fill(line.color)
                    Text(line.name).fontSize(13).margin({ left: 6 }).fontWeight(500)
                  }
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .margin({ right: 10, bottom: 12 })
                  .backgroundColor(Color.White)
                  .borderRadius(10)
                  .shadow({ radius: 4, color: '#05000000' })
                  .onClick(() => {
                    this.selectedTrafficItem = {
                      name: line.name,
                      type: '城市轨道交通',
                      price: this.cityConfig.metro.basePrice,
                      operationTime: '详见站点公告',
                      desc: line.desc,
                      color: line.color
                    };
                    this.isShowTrafficDetail = true;
                  })
                })
              }
              Text(`* ${this.cityConfig.metro.notice || '请以车站实时公告为准'}`).fontSize(11).fontColor('#999')
            }.alignItems(HorizontalAlign.Start)
          }

          Column({ space: 12 }) {
            this.ModuleTitle('第三方出行服务')
            Row({ space: 12 }) {
              this.ServiceEntry('一键打车', $r('sys.symbol.car_fill'), '#FF9500', 'taxi')
              this.ServiceEntry('共享单车', $r('sys.symbol.bicycle'), '#4CD964', 'bike')
              this.ServiceEntry('便捷公交', $r('sys.symbol.bus_fill'), '#007DFF', 'bus')
            }.width('100%')
          }.alignItems(HorizontalAlign.Start)

          Column().height(60)
        }.padding(20).onClick(() => { if (this.poiList.length > 0) this.poiList = [] })
      }
    }.scrollBar(BarState.Off)
  }

  @Builder
  UniqueTrafficCard(item: UniqueTraffic) {
    Stack({ alignContent: Alignment.BottomEnd }) {
      SymbolGlyph(this.getIconByTrafficType(item.type))
        .fontSize(80)
        .fontColor([Color.White])
        .opacity(0.12)
        .offset({ x: 10, y: 20 })
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text(item.name).fontSize(20).fontWeight(800).fontColor(Color.White)
            Text(item.type).fontSize(10).fontColor(Color.White).backgroundColor('#30FFFFFF').padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(6)
          }.alignItems(HorizontalAlign.Start)
          Blank()
          Text('运营中').fontSize(10).fontColor(Color.White).opacity(0.8)
        }
        .width('100%')
        Blank()
        Row() {
          Column({ space: 2 }) {
            Text('票价说明').fontSize(10).fontColor(Color.White).opacity(0.6)
            Text(item.price).fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.White)
          }.alignItems(HorizontalAlign.Start)
          Blank()
          Row() {
            Text('查看详情').fontSize(12).fontColor(Color.White).fontWeight(500)
            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor([Color.White]).margin({ left: 4 })
          }.padding({ left: 12, right: 8, top: 6, bottom: 6 }).backgroundColor('#20000000').borderRadius(12)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .height('100%')
      .padding(18)
    }.width(260).height(140).borderRadius(24).linearGradient({
      angle: 135,
      colors: [
        [item.color, 0.0],
        [this.getDarkerColor(item.color), 1.0]
      ]
    })
    .shadow({
      radius: 20,
      color: `${item.color}44`,
      offsetY: 8
    })
    .onClick(() => {
      this.selectedTrafficItem = item;
      this.isShowTrafficDetail = true;
    })
  }

  getIconByTrafficType(type: string): Resource {
    if (type.includes('轮渡') || type.includes('水上')) return $r('sys.symbol.ferry_fill');
    if (type.includes('电车') || type.includes('轨道')) return $r('sys.symbol.tram_fill');
    if (type.includes('索道') || type.includes('缆车')) return $r('sys.symbol.mountain_2_fill');
    return $r('sys.symbol.car_fill');
  }

  getDarkerColor(color: string): string {
    return color;
  }

  @Builder DetailPanel(title: string, content: string, color: string, onClose: () => void) {
    Stack() {
      Rect().fill('#90000000').width('100%').height('100%').onClick(onClose)
      Column({ space: 20 }) {
        Row() {
          Text(title).fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          SymbolGlyph($r('sys.symbol.xmark')).fontSize(20).fontColor(['#999']).onClick(onClose)
        }.width('100%')
        Scroll() { Text(content).fontSize(15).lineHeight(24).fontColor('#444') }.width('100%').constraintSize({ maxHeight: '40%' }).scrollBar(BarState.Off)
        Button('我知道了').width('100%').height(50).backgroundColor(color).onClick(onClose)
      }.width('85%').padding(24).backgroundColor(Color.White).borderRadius(28)
    }.zIndex(300)
  }

  @Builder HeaderBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
      Column() {
        Text('文旅出行助手').fontSize(18).fontWeight(FontWeight.Bold)
        Text(this.currentCity).fontSize(11).fontColor('#666').margin({ top: 2 })
      }.margin({ left: 16 }).alignItems(HorizontalAlign.Start)
      Blank()
      SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(16).fontColor(['#007DFF']).padding(8).backgroundColor('#E6F2FF').borderRadius(20)
    }.width('100%').padding(16).backgroundColor(Color.White)
  }

  @Builder TabBuilder(title: string, index: number) {
    Column() {
      Text(title).fontSize(14).fontColor(this.selectedIndex === index ? '#1A1A1A' : '#999').fontWeight(this.selectedIndex === index ? 700 : 400)
      if (this.selectedIndex === index) Rect().width(20).height(3).fill('#007DFF').radius(2).margin({ top: 4 })
    }
  }

  @Builder HeroSection() {
    Row() {
      Column({ space: 4 }) {
        Text('你好，寻域者').fontSize(24).fontWeight(FontWeight.Bold)
        Text('让每一次出发都充满新奇').fontSize(13).fontColor('#666')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Column() {
        SymbolGlyph($r('sys.symbol.leaf_fill')).fontSize(20).fontColor(['#4CD964'])
        Text('低碳行').fontSize(10).fontColor('#4CD964').margin({ top: 2 })
      }.padding(8).backgroundColor('#F0F9F4').borderRadius(12)
    }.width('100%')
  }

  @Builder ServiceEntry(label: string, icon: Resource, color: string, mode: string) {
    Column({ space: 8 }) {
      Stack() {
        Circle({ width: 50, height: 50 }).fill(color).opacity(0.1)
        SymbolGlyph(icon).fontSize(24).fontColor([color])
      }
      Text(label).fontSize(12).fontColor('#333')
    }.layoutWeight(1).padding(16).backgroundColor(Color.White).borderRadius(16).onClick(() => this.openPicker(mode))
  }

  @Builder PlatformPicker() {
    Stack({ alignContent: Alignment.Bottom }) {
      Rect().fill('#80000000').width('100%').height('100%').onClick(() => this.isShowPlatforms = false)
      Column() {
        Row().width(40).height(5).backgroundColor('#DDD').borderRadius(3).margin({ bottom: 20 })
        Text('选择服务平台').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 25 })
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
          ForEach(this.activePlatforms, (p: string) => {
            Column() {
              Stack() { Circle({ width: 56, height: 56 }).fill('#F5F7FA'); Text(p[0]).fontSize(20).fontWeight(700) }
              Text(p).fontSize(12).margin({ top: 10 })
            }.width('25%').onClick(() => this.handleJump(p))
          })
        }
        Button('取消').margin({ top: 30, bottom: 10 }).width('100%').height(50).backgroundColor('#F5F5F5').fontColor('#666').onClick(() => this.isShowPlatforms = false)
      }.padding(24).backgroundColor(Color.White).borderRadius({ topLeft: 24, topRight: 24 })
    }.zIndex(200)
  }

  @Builder ModuleTitle(title: string) { Text(title).fontSize(16).fontWeight(700).fontColor('#1A1A1A') }
  @Builder LeisureModule() { Column() { Text('休闲生活板块开发中').fontColor('#999') }.height('60%').justifyContent(FlexAlign.Center) }
  @Builder HotelModule() { Column() { Text('精选酒店模块开发中').fontColor('#999') }.height('60%').justifyContent(FlexAlign.Center) }
}