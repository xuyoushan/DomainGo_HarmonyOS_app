import { router } from '@kit.ArkUI';
import http from '@ohos.net.http'; // 必须引入 http 模块
import { CITY_GOV_DATA, DistrictDetail } from '../../models/CityDataModel';

// 定义高德接口返回类型
interface AmapPoi { adname: string; name: string; cityname: string; }
interface AmapResponse { status: string; pois: AmapPoi[]; }

@Entry
@Component
struct GovServiceDetailView {
  @StorageLink('currentCity') currentCity: string = '武汉市';

  @State searchKey: string = '';
  @State filteredList: DistrictDetail[] = [];
  @State isSearching: boolean = false; // 增加搜索状态提示

  // 来自 AllFunctions 的功能类型
  // 可能是：行政隶属 / 邮编查询 / 区号查询 / 人口数据
  @State highlightType: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    // 强制赋值，确保 highlightType 响应式生效
    this.highlightType = params?.defaultType || '城市服务';
    this.filteredList = CITY_GOV_DATA[this.currentCity] || [];
  }

  // ✅ 增强版搜索逻辑：本地全库匹配 + 高德 API 补位
  async handleSearch(key: string) {
    this.searchKey = key;
    if (!key) {
      this.filteredList = CITY_GOV_DATA[this.currentCity] || [];
      return;
    }

    // --- 第一步：全库扫描 (支持跨城市搜 邮编/区号/名) ---
    let globalResults: DistrictDetail[] = [];
    Object.keys(CITY_GOV_DATA).forEach(city => {
      const cityDistricts = CITY_GOV_DATA[city].filter(item =>
      item.name.includes(key) ||
      item.postCode.includes(key) || // 改为 includes 增加模糊匹配触发
      item.areaCode.includes(key)
      );
      globalResults.push(...cityDistricts);
    });

    if (globalResults.length > 0) {
      this.filteredList = globalResults;
    } else {
      // --- 第二步：调高德接口 (搜具体的街道/地标) ---
      await this.searchFromAmap(key);
    }
  }

  // 引用自你 PostDynamicView 的逻辑并优化
  async searchFromAmap(keyword: string) {
    let httpRequest = http.createHttp();
    const amapKey = 'd4552bc3e20af2857f9cfd5ac95ded1d';
    try {
      this.isSearching = true;
      // 去掉 city 限制，允许跨城搜地名
      let url = `https://restapi.amap.com/v3/place/text?keywords=${encodeURIComponent(keyword)}&key=${amapKey}`;
      let response = await httpRequest.request(url);

      if (response.responseCode === 200) {
        let res = JSON.parse(response.result as string) as AmapResponse;
        if (res.status === '1' && res.pois?.length > 0) {
          const poi = res.pois[0];
          // 在全库中匹配高德返回的“区名 (adname)”
          let found: DistrictDetail[] = [];
          Object.keys(CITY_GOV_DATA).forEach(city => {
            const match = CITY_GOV_DATA[city].find(d => d.name === poi.adname);
            if (match) found.push(match);
          });
          this.filteredList = found;
        } else {
          this.filteredList = [];
        }
      }
    } catch (err) {
      console.error('Amap_Search_Error: ' + JSON.stringify(err));
    } finally {
      this.isSearching = false;
      httpRequest.destroy();
    }
  }

  build() {
    Column() {
      // --- 顶部渐变 ---
      Stack({ alignContent: Alignment.Top }) {
        Column()
          .width('100%')
          .height(230) // 略微调高以容纳提示条
          .linearGradient({
            angle: 135,
            colors: [['#FF9A22', 0.0], ['#FFD233', 1.0]]
          })
          .borderRadius({ bottomLeft: 40, bottomRight: 40 })

        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#FFF'])
              .onClick(() => router.back())

            Text(`${this.currentCity} · 城市服务`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF')
              .margin({ left: 10 })

            Blank()
          }
          .width('100%')
          .padding({ top: 30, bottom: 20 })

          // 搜索框
          Search({
            value: this.searchKey,
            placeholder: '搜地名、邮编或区号'
          })
            .width('100%')
            .height(50)
            .backgroundColor('#FFF')
            .borderRadius(15)
            .onChange(v => this.handleSearch(v))

          // ✅ “当前关注”提示条
          Row() {
            SymbolGlyph($r('sys.symbol.checkmark_calendar')).fontSize(16).fontColor(['#FF9A22'])
            Text(` 当前关注：${this.highlightType}`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9A22')
            Blank()
            Text(this.isSearching ? '检索中...' : '已开启全库检索').fontSize(11).fontColor('#999')
          }
          .width('100%')
          .margin({ top: 15 })
          .padding(12)
          .backgroundColor('#E6FFFFFF')
          .borderRadius(12)
        }
        .padding({ left: 24, right: 24 })
      }

      // --- 结果区 ---
      Scroll() {
        Column({ space: 16 }) {
          if (this.isSearching) {
            LoadingProgress().width(50).color('#FF9A22').margin({ top: 50 })
          } else if (this.filteredList.length === 0) {
            this.EmptyState()
          } else {
            ForEach(this.filteredList, (item: DistrictDetail) => {
              this.ResultCard(item)
            })
          }
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 30 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDFDFD')
  }

  // --- 区级卡片 ---
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