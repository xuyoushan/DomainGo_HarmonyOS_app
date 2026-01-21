import { router, promptAction } from '@kit.ArkUI';
import http from '@ohos.net.http';

interface AmapPoi {
  name: string;
  address: string;
  adname: string;
}
interface AmapResponse {
  status: string;
  pois: AmapPoi[];
}

@Entry
@Component
struct TravelServiceView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @State selectedIndex: number = 2; // 默认切到交通，方便你调试
  @State destination: string = '';
  @State hotelKeyword: string = '';

  // 交通模块状态
  @State searchResults: AmapPoi[] = [];
  @State isShowPlatforms: boolean = false;
  @State currentMode: string = '';
  @State activePlatforms: string[] = []; // 动态存放当前模式下的平台列表

  aboutToAppear() {
    let params = router.getParams() as Record<string, string>;
    if (params) {
      if (params.defaultType === '门票预订') this.selectedIndex = 0;
      if (params.defaultType === '酒店住宿') this.selectedIndex = 1;
      if (params.defaultType === '交通出行') this.selectedIndex = 2;
    }
  }

  // --- 1. 高德搜索逻辑 ---
  async searchPoi(keyword: string) {
    if (!keyword) {
      this.searchResults = [];
      return;
    }
    let httpRequest = http.createHttp();
    const amapKey = 'd4552bc3e20af2857f9cfd5ac95ded1d';
    try {
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(keyword)}&city=${encodeURIComponent(this.currentCity)}&offset=10&page=1&key=${amapKey}`;
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        if (res.status === '1' && res.pois) {
          this.searchResults = res.pois;
        }
      }
    } catch (err) {
      console.error('POI_Search_Error: ' + JSON.stringify(err));
    } finally {
      httpRequest.destroy();
    }
  }

  // --- 2. 完善后的平台选择唤起逻辑 ---
  openPicker(mode: string) {
    this.currentMode = mode;
    // 根据业务逻辑分配平台
    if (mode === 'taxi') {
      this.activePlatforms = ['高德', '百度', '腾讯', '滴滴'];
    } else if (mode === 'rent') {
      this.activePlatforms = ['携程租车', '哈啰租车', '神州租车'];
    } else if (mode === 'bike') {
      this.activePlatforms = ['美团', '哈啰', '微信', '支付宝'];
    } else if (mode === 'bus') {
      this.activePlatforms = ['微信', '支付宝'];
    }
    this.isShowPlatforms = true;
  }

  // --- 3. 核心跳转函数 ---
  doJump(platform: string) {
    let uri = '';
    const city = this.currentCity.replace('市', '');
    const dest = this.destination;

    if (this.currentMode === 'taxi' || this.currentMode === 'bus') {
      if (!dest) {
        promptAction.showToast({ message: '请先输入或选择目的地' });
        return;
      }
      if (platform === '高德') uri = `amapuri://route/plan/?dname=${encodeURIComponent(city + dest)}&dev=0&t=0`;
      // ... 其他 scheme 逻辑
    } else if (this.currentMode === 'bike') {
      if (platform === '微信') uri = 'weixin://dl/scan';
      // ... 其他 scheme 逻辑
    }

    this.isShowPlatforms = false;
    promptAction.showToast({ message: `正在唤起 ${platform}...` });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 背景层：点击此处关闭搜索预测和平台弹窗
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F4F6F8')
        .onClick(() => {
          this.searchResults = [];
          this.isShowPlatforms = false;
        })

      Column() {
        // 自定义标题栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
          Text('文旅助手').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 12 })
          Blank()
          Text(this.currentCity).fontSize(14).fontColor('#666')
        }
        .width('100%').padding(16).backgroundColor(Color.White)

        Tabs({ index: this.selectedIndex }) {
          TabContent() { this.TicketModule() }.tabBar('🎫 门票')
          TabContent() { this.HotelModule() }.tabBar('🏨 酒店')
          TabContent() { this.TrafficModule() }.tabBar('🚗 交通')
        }
        .barMode(BarMode.Fixed)
        .onChange(index => this.selectedIndex = index)
      }
      .width('100%').height('100%')

      // 4. 搜索预测浮层 (通过 Stack 层级浮在最上)
      if (this.searchResults.length > 0) {
        this.SuggestionOverlay()
      }

      // 5. 平台选择底面板
      if (this.isShowPlatforms) {
        this.PlatformPicker()
      }
    }
  }

  // --- 交通模块 UI ---
  @Builder TrafficModule() {
    Scroll() {
      Column({ space: 24 }) {
        Column({ space: 8 }) {
          Text('你要去哪儿？').fontSize(32).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
          Text(`在${this.currentCity}享受智慧出行`).fontSize(14).fontColor('#999')
        }.alignItems(HorizontalAlign.Start).width('100%')

        // 搜索框
        Search({ placeholder: '输入目的地，一键多平台比价...', value: this.destination })
          .height(56)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .border({ width: 1, color: '#F0F0F0' })
          .onChange(v => {
            this.destination = v;
            this.searchPoi(v);
          })

        // 功能矩阵（非对称左对齐布局）
        this.SectionTitle('打车/导航 (自动填充)')
        this.TrafficGrid(['高德', '百度', '腾讯', '滴滴'], 'taxi', '#FF9500')

        this.SectionTitle('租车自驾 (自由探索)')
        this.TrafficGrid(['携程租车', '哈啰租车', '神州租车'], 'rent', '#4CD964')

        this.SectionTitle('低碳出行 (直接扫码)')
        this.TrafficGrid(['美团', '哈啰', '微信', '支付宝'], 'bike', '#007DFF')

      }.padding(20).alignItems(HorizontalAlign.Start)
    }.scrollBar(BarState.Off)
  }

  @Builder SuggestionOverlay() {
    Column() {
      ForEach(this.searchResults, (poi: AmapPoi) => {
        Row() {
          SymbolGlyph($r('sys.symbol.map')).fontSize(18).fontColor(['#CCC'])
          Column() {
            Text(poi.name).fontSize(15).fontWeight(FontWeight.Medium)
            Text(poi.address).fontSize(11).fontColor('#999').maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
          }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
        }
        .width('100%').padding(16).border({ width: { bottom: 0.5 }, color: '#F5F5F5' })
        .onClick(() => {
          this.destination = poi.name;
          this.searchResults = [];
          this.openPicker('taxi');
        })
      })
    }
    .width('92%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 30, color: '#20000000' })
    .position({ x: '4%', y: 180 }) // 定位在搜索框下方
    .zIndex(100)
  }

  @Builder SectionTitle(title: string) {
    Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
  }

  @Builder TrafficGrid(platforms: string[], mode: string, color: string) {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(platforms, (name: string) => {
        Column() {
          Circle({ width: 48, height: 48 }).fill(color + '15')
            .overlay(this.IconText(name[0], color), { align: Alignment.Center })
          Text(name).fontSize(12).margin({ top: 8 }).fontColor('#444')
        }
        .width('22%').margin({ bottom: 16, right: '3%' })
        .onClick(() => this.openPicker(mode))
      })
    }
  }

  @Builder PlatformPicker() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 遮罩层
      Rect().fill('#80000000').width('100%').height('100%').onClick(() => this.isShowPlatforms = false)

      // 弹窗抽屉
      Column() {
        Text('选择出发平台').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 24 })
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
          ForEach(this.activePlatforms, (p: string) => {
            Column() {
              Circle({ width: 56, height: 56 }).fill('#F5F7FA')
                .overlay(this.IconText(p[0], '#1A1A1A'), { align: Alignment.Center })
              Text(p).fontSize(12).margin({ top: 10 })
            }.onClick(() => this.doJump(p))
          })
        }
        Button('取消').margin({ top: 32 }).width('100%').backgroundColor('#F5F5F5').fontColor('#666')
          .onClick(() => this.isShowPlatforms = false)
      }
      .padding(24).backgroundColor(Color.White).borderRadius({ topLeft: 24, topRight: 24 })
    }.width('100%').height('100%').zIndex(200)
  }

  @Builder IconText(char: string, color: string) {
    Text(char).fontColor(color).fontWeight(FontWeight.Bold).fontSize(18)
  }

  // 门票与酒店保持原逻辑
  @Builder TicketModule() { /* ... */ }
  @Builder HotelModule() { /* ... */ }
}