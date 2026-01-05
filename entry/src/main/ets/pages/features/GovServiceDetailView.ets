import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { CITY_GOV_DATA, DistrictDetail } from '../../models/CityDataModel';

//高德 POI 接口数据结构
interface AmapPoi {
  adname: string;      // 行政区名称（如 江夏区）
  name: string;        // POI 名称（如 武昌理工）
  cityname: string;
}
interface AmapResponse {
  status: string;      // 请求状态，'1' 为成功
  pois: AmapPoi[];     // POI 列表
}

@Entry
@Component
struct GovServiceDetailView {

  private scroller: Scroller = new Scroller();     // 主滚动容器控制器
  private debounceTimer: number = -1;              // 搜索防抖定时器 ID

  @StorageLink('currentCity')
  currentCity: string = '武汉市';                  // 当前城市（跨页面共享）

  @State searchKey: string = '';                   // 搜索框关键词
  @State filteredList: DistrictDetail[] = [];      // 当前渲染的行政区结果
  @State isSearching: boolean = false;             // 网络请求加载态
  @State suggestList: AmapPoi[] = [];               // 地名联想结果
  @State showSuggest: boolean = false;             // 是否显示联想浮层
  @State highlightType: string = '';                // 当前高亮的信息类型

//生命周期：页面进入
  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    const target = params?.defaultType;             // 从上页传入的高亮目标


    let raw = CITY_GOV_DATA[this.currentCity] || [];
    const myDist = '江夏区';                         // 模拟定位区（未来可接系统定位）

    // 将定位区置顶（sort 稳定、不创建新数组）
    this.filteredList = raw.sort((a, b) =>
    a.name === myDist ? -1 : (b.name === myDist ? 1 : 0)
    );

    if (target) {
      setTimeout(() => {
        this.highlightType = target;                 // 设置默认高亮类型
        this.scroller.scrollTo({
          yOffset: 0,
          xOffset: 0,
          animation: { duration: 500, curve: Curve.EaseOut }
        });
      }, 100);                                       // 等待首帧布局完成
    } else {
      this.highlightType = '城市服务';               // 默认高亮
    }
  }

// 搜索输入监听（防抖）
  async handleSearch(key: string) {
    this.searchKey = key;                            // 实时同步输入值

    if (!key) {                                     // 输入被清空
      clearTimeout(this.debounceTimer);
      this.filteredList = CITY_GOV_DATA[this.currentCity] || [];
      this.showSuggest = false;
      this.suggestList = [];                         // 清空联想数据
      return;
    }

    clearTimeout(this.debounceTimer);                // 重置防抖计时器
    this.debounceTimer = setTimeout(() => {
      if (this.searchKey) {
        this.execSearch(this.searchKey);             // 延迟触发真实搜索
      }
    }, 300);
  }

// 高德 POI 搜索请求
  private async execSearch(key: string) {
    this.showSuggest = true;                         // 显示联想面板
    this.isSearching = true;                         // 进入加载态

    let httpRequest = http.createHttp();
    try {
      let url =
        `https://restapi.amap.com/v3/place/text` +
          `?keywords=${encodeURIComponent(key)}` +
          `&city=${encodeURIComponent(this.currentCity)}` +
          `&key=d4552bc3e20af2857f9cfd5ac95ded1d`;

      let res = await httpRequest.request(url);

      if (res.responseCode === 200) {
        let data = JSON.parse(res.result as string) as AmapResponse;

        if (data.status === '1' && data.pois?.length > 0) {
          this.suggestList = data.pois;               // 更新联想列表
          this.matchDistrict(data.pois[0].adname);   // 用首条结果反查行政区
        }
      }
    } catch (e) {
      console.error('NetErr:' + JSON.stringify(e));
    } finally {
      this.isSearching = false;                       // 关闭加载态
      httpRequest.destroy();                          // 释放请求实例
    }
  }

//行政区反查（adname → 本地数据）
  private matchDistrict(adname: string) {
    let matched: DistrictDetail[] = [];

    Object.keys(CITY_GOV_DATA).forEach(city => {
      let d = CITY_GOV_DATA[city].find(i => i.name === adname);
      if (d) matched.push(d);                         // 允许跨市命中
    });

    if (matched.length > 0) {
      this.filteredList = matched;                    // 驱动结果区刷新
    }
  }

  /* =========================页面 UI 构建========================= */
  build() {
    Column() {

      /* ---------- 顶部渐变 + 搜索区 ---------- */
      Stack({ alignContent: Alignment.Top }) {
        Column()
          .width('100%')
          .height(230)
          .borderRadius({ bottomLeft: 40, bottomRight: 40 })
          .linearGradient({
            angle: 135,
            colors: [['#FF9A22', 0.0], ['#FFD233', 1.0]]
          });

        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#FFF'])
              .onClick(() => router.back());           // 返回上一页

            Text(`${this.currentCity} · 城市服务`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF')
              .margin({ left: 10 });
          }
          .width('100%')
          .padding({ top: 30, bottom: 20 });

          /* ---------- 搜索框 + 状态提示 ---------- */
          Stack({ alignContent: Alignment.Top }) {
            Column() {
              Search({
                value: this.searchKey,
                placeholder: '搜地名、邮编或区号'
              })
                .width('100%')
                .height(50)
                .backgroundColor('#FFF')
                .borderRadius(15)
                .onChange(v => this.handleSearch(v));  // 搜索输入监听

              Row() {
                SymbolGlyph($r('sys.symbol.checkmark_calendar'))
                  .fontSize(16)
                  .fontColor(['#FF9A22']);

                Text(
                  this.searchKey
                    ? ` 搜索命中：${this.searchKey}`
                    : ` 当前关注：${this.highlightType}`
                )
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF9A22');

                Blank();

                Text(this.isSearching ? '检索中...' : '已开启全库检索')
                  .fontSize(11)
                  .fontColor('#999');
              }
              .width('100%')
              .margin({ top: 15 })
              .padding(12)
              .backgroundColor('#E6FFFFFF')
              .borderRadius(12);
            }

            /* ---------- 地名联想浮层 ---------- */
            if (this.showSuggest && this.suggestList.length > 0) {
              Column() {
                List() {
                  ForEach(this.suggestList, (poi: AmapPoi) => {
                    ListItem() {
                      Row() {
                        SymbolGlyph($r('sys.symbol.mappin_and_rectangle'))
                          .fontSize(14)
                          .fontColor(['#999']);

                        Column() {
                          Text(poi.name).fontSize(14).fontColor('#333');
                          Text(poi.adname)
                            .fontSize(11)
                            .fontColor('#999')
                            .margin({ top: 2 });
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 10 });

                        Blank();

                        SymbolGlyph($r('sys.symbol.chevron_right'))
                          .fontSize(12)
                          .fontColor(['#EEE']);
                      }
                      .width('100%')
                      .padding(12)
                      .onClick(() => {
                        clearTimeout(this.debounceTimer); // 阻断未触发的搜索
                        this.searchKey = poi.name;        // 回填搜索框
                        this.showSuggest = false;         // 立即关闭浮层
                        this.matchDistrict(poi.adname);  // 手动刷新结果
                      });
                    };
                  });
                }
                .width('100%')
                .edgeEffect(EdgeEffect.Spring);
              }
              .constraintSize({ maxHeight: 220 })
              .backgroundColor('#FFF')
              .borderRadius(15)
              .margin({ top: 55 })
              .shadow({ radius: 20, color: '#20000000' })
              .zIndex(100);
            }
          }
        }
        .padding({ left: 24, right: 24 });
      }

      /* ---------- 结果列表区 ---------- */
      Scroll(this.scroller) {
        Column({ space: 16 }) {
          if (this.isSearching) {
            LoadingProgress().width(50).color('#FF9A22').margin({ top: 50 });
          } else if (this.filteredList.length === 0) {
            this.EmptyState();
          } else {
            ForEach(this.filteredList, (item: DistrictDetail) =>
            this.ResultCard(item)
            );
          }
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 30 })
        .onClick(() => {
          this.showSuggest = false;                     // 点击空白关闭联想
        });
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDFDFD');
  }

  /* =========================以下 Builder：UI 组件块========================= */
  // 结果卡片
  @Builder
  ResultCard(item: DistrictDetail) {
    Column() {
      Row() {
        Image($r('sys.symbol.satellite_map_fill'))
          .width(20)
          .height(20)
          .margin({ right: 8 })
          .fillColor('#FF9A22')

        Text(item.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        // ✅ 跨城特别标注
        if (!item.belong.includes(this.currentCity)) {
          Text(item.belong.split('市')[0] + '市')
            .fontSize(10)
            .fontColor('#FFF')
            .backgroundColor('#FF6B6B')
            .margin({ left: 8 })
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        }

        Blank()

        Text('城市信息')
          .fontSize(12)
          .fontColor('#FF9A22')
          .backgroundColor('#FFF4E5')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 20 })

      Flex({ wrap: FlexWrap.Wrap }) {
        // 传入原始值用于搜索命中判断
        this.InfoBox('行政隶属', item.belong, '行政隶属', item.belong)
        this.InfoBox('邮政编码', item.postCode, '邮编查询', item.postCode)
        this.InfoBox('区号查询', item.areaCode, '区号查询', item.areaCode)
        this.InfoBox('人口数据', item.population, '人口数据', item.population)
      }
    }
    .padding(20)
    .backgroundColor('#FFF')
    .borderRadius(24)
    .shadow({ radius: 20, color: '#15000000', offsetY: 10 })
    .margin({ bottom: 10 })
  }

  // --- 信息单元（核心改动：增加放大和阴影逻辑） ---
  @Builder
  InfoBox(label: string, value: string, matchType: string, rawValue: string) {
    // 逻辑：如果(功能点击进入) 或者 (搜索词命中了该项内容) 则激活效果
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor((this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? '#FF9A22' : '#999')

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .margin({ top: 4 })
    }
    .width('47%')
    .margin('1.5%')
    .padding(12)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    // 激活态背景色
    .backgroundColor((this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? '#FFF7E8' : '#F8F9FB')
    // 1. 放大 1.05 倍
    .scale({
      x: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.05 : 1.0,
      y: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.05 : 1.0
    })
    // 2. 周围阴影效果
    .shadow({
      radius: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 15 : 0,
      color: '#40FF9A22',
      offsetY: 6
    })
    // 3. 边框高亮
    .border({
      width: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.5 : 0,
      color: '#FF9A22'
    })
    // 4. 动画过渡
    .animation({ duration: 300, curve: Curve.EaseOut })
  }

  @Builder
  EmptyState() {
    Column() {
      Image($r('sys.symbol.location_north_up_right_and_circle_dotted_fill'))
        .width(80)
        .height(80)
        .fillColor(['#EEE'])

      Text('没有找到相关地名信息\n可以尝试输入街道或区名')
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 16 })
    }
    .width('100%')
    .margin({ top: 60 })
  }
}
