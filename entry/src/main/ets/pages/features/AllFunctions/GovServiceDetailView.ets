import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { CITY_GOV_DATA, DistrictDetail } from '../../../models/CityDataModel';

interface AmapPoi {
  adname: string;
  name: string;
  cityname: string;
}
interface AmapResponse {
  status: string;
  pois: AmapPoi[];
}

@Entry
@Component
struct GovServiceDetailView {

  private scroller: Scroller = new Scroller();
  private debounceTimer: number = -1;

  @StorageLink('currentCity')
  currentCity: string = '武汉市';

  @State searchKey: string = '';
  @State filteredList: DistrictDetail[] = [];
  @State isSearching: boolean = false;
  @State suggestList: AmapPoi[] = [];
  @State showSuggest: boolean = false;
  @State highlightType: string = '';


  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    const target = params?.defaultType;


    let raw = CITY_GOV_DATA[this.currentCity] || [];
    const myDist = '江夏区';

    this.filteredList = raw.sort((a, b) =>
    a.name === myDist ? -1 : (b.name === myDist ? 1 : 0)
    );

    if (target) {
      setTimeout(() => {
        this.highlightType = target;
        this.scroller.scrollTo({
          yOffset: 0,
          xOffset: 0,
          animation: { duration: 500, curve: Curve.EaseOut }
        });
      }, 100);
    } else {
      this.highlightType = '城市服务';
    }
  }

  async handleSearch(key: string) {
    this.searchKey = key;

    if (!key) {
      clearTimeout(this.debounceTimer);
      this.filteredList = CITY_GOV_DATA[this.currentCity] || [];
      this.showSuggest = false;
      this.suggestList = [];
      return;
    }

    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      if (this.searchKey) {
        this.execSearch(this.searchKey);
      }
    }, 300);
  }

  private async execSearch(key: string) {
    this.showSuggest = true;
    this.isSearching = true;

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
          this.suggestList = data.pois;
          this.matchDistrict(data.pois[0].adname);
        }
      }
    } catch (e) {
      console.error('NetErr:' + JSON.stringify(e));
    } finally {
      this.isSearching = false;
      httpRequest.destroy();
    }
  }

  private matchDistrict(adname: string) {
    let matched: DistrictDetail[] = [];

    Object.keys(CITY_GOV_DATA).forEach(city => {
      let d = CITY_GOV_DATA[city].find(i => i.name === adname);
      if (d) matched.push(d);
    });

    if (matched.length > 0) {
      this.filteredList = matched;
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
              .onClick(() => router.back());

            Text(`${this.currentCity} · 城市服务`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF')
              .margin({ left: 10 });
          }
          .width('100%')
          .padding({ top: 30, bottom: 20 });

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
                .onChange(v => this.handleSearch(v));

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
                        clearTimeout(this.debounceTimer);
                        this.searchKey = poi.name;
                        this.showSuggest = false;
                        this.matchDistrict(poi.adname);
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
          this.showSuggest = false;
        });
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDFDFD');
  }

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

  @Builder
  InfoBox(label: string, value: string, matchType: string, rawValue: string) {
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
    .backgroundColor((this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? '#FFF7E8' : '#F8F9FB')
    .scale({
      x: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.05 : 1.0,
      y: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.05 : 1.0
    })
    .shadow({
      radius: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 15 : 0,
      color: '#40FF9A22',
      offsetY: 6
    })
    .border({
      width: (this.highlightType === matchType || (this.searchKey && rawValue.includes(this.searchKey))) ? 1.5 : 0,
      color: '#FF9A22'
    })
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
