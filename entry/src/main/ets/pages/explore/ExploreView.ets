import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { PROVINCE_CITY_DATA } from '../../models/CityData';
import { CITY_BANNER_CONFIG, CityBanner } from '../../models/CityBannerData';
import { promptAction, router } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute } from '../../models/RouteData';
import { CITY_EXPLORE_MAP, DEFAULT_EXPLORE_DATA, CityExploreConfig } from '../../models/ExploreCityData';
import { display } from '@kit.ArkUI';

interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }
interface HotTopic { title: string; color: string; count: string; }
interface TopicTemplate { suffix: string; color: string; }
interface MyNewsResponse { code: number; city: string; news: string[]; }
interface ExploreGuideParams { skipGuide?: boolean }

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @State weatherText: string = '阴';
  @State searchText: string = '';
  @State scaleValue: number = 1.0; // 用于缩放动画
  @State bannerHeight: number = 200;
  @State hotTopics: HotTopic[] = [];
  @State newsList: string[] = ["正在连接文旅大数据中心..."]; // 初始文案
  @State isCitySwitching: boolean = false
  // ------------------ 新增：引导流转全量状态 (ExploreGuideWrapper 迁移) ------------------
  @State currentStage: 'welcome' | 'stepGuide' | 'teaching' | 'full' = 'welcome'
  @State guideStepIndex: number = 0
  @State displayedText: string = ''     // 当前逐字显示的文案
  @State isTyping: boolean = false      // 是否正在逐字播放
  private timerId: number = -1          // 补全定时器ID声明


  private context = getContext(this) as common.UIAbilityContext;

  private getGuideSteps(): string[] {
    return [
      `欢迎来到寻域之旅。\n在这座城市，每条街道、每幢建筑、每个人的笑声里，都藏着独特的故事。`,
      `这里有被时间遗忘的老巷，有被记忆铭刻的历史建筑。\n走进去，你会发现那些平凡角落里非凡的秘密。`,
      `在这里，你可以慢慢品味城市的味道。\n无论是街头小吃的香气，还是老茶馆里的谈笑声，都在讲述属于城市的温度。`,
      `每一座城市都有自己的节奏和脉络。\n历史、文化、生活在这里交织，每一步行走，都是一次新的发现。`,
      `准备好了吗？\n让我们从这里开始，慢慢触摸城市的故事。\n一场探索之旅即将在你的指尖展开。`,
      `点击“开始探索”，\n你将进入城市教学模式，了解每个功能、每条路线、每个故事的精华。`
    ];
  }

  private playStepText() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    const steps = this.getGuideSteps()

    this.displayedText = '';
    this.isTyping = true;
    const fullText = steps[this.guideStepIndex];
    let i = 0;

    this.timerId = setInterval(() => {
      if (i < fullText.length) {
        this.displayedText += fullText[i];
        i++;
      } else {
        clearInterval(this.timerId);
        this.timerId = -1;
        this.isTyping = false;
      }
    }, 50);
  }

  private nextStep(total: number) {
    if (this.isTyping) return;
    if (this.guideStepIndex < total - 1) {
      this.guideStepIndex++;
      this.playStepText();
    } else {
      this.currentStage = 'teaching';
    }
  }

  getCityConfig(): CityExploreConfig {
    return CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
  }

  aboutToAppear() {
    const params = router.getParams() as ExploreGuideParams

    if (params?.skipGuide === true) {
      this.currentStage = 'full'
      return
    }
    // 在生命周期中计算一次高度，而不是在 build 中实时计算
    try {
      const displayData: display.Display = display.getDefaultDisplaySync();
      const screenWidthVp = px2vp(displayData.width);
      this.bannerHeight = screenWidthVp * 9 / 16;
    } catch (e) {
      this.bannerHeight = 200; // 兜底高度
    }
  }

  onPageShow() {
    this.initLocation()
    this.fetchRealNews()
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }


  async initLocation() {
    try {
      const isAuth = await LocationManager.requestPermission(this.context)
      if (isAuth) {
        const city = await LocationManager.getRealCity(this.context)
        if (city && city !== '定位失败') {
          this.updateCityState(city);
        }
      } else {
        this.fetchRealWeather(this.currentCity)
      }
    } catch (err) {
      this.fetchRealWeather(this.currentCity)
    }
  }

  private async updateCityState(city: string) {
    if (city === this.currentCity) return

    this.isCitySwitching = true
    this.currentCity = city
    AppStorage.setOrCreate('currentCity', city)

    // 给人类一点“系统反应时间”
    await new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve()
      }, 500)
    })

    await Promise.all([
      this.fetchRealWeather(city),
      this.fetchRealNews(),
      this.fetchHotTopics()
    ])

    this.isCitySwitching = false
    console.info(`[Explore] 城市切换完成: ${city}`)
  }

  showCityPicker() {
    let provinces = Object.keys(PROVINCE_CITY_DATA);
    TextPickerDialog.show({
      range: provinces,
      onAccept: (pResult: TextPickerResult) => {
        let cities = PROVINCE_CITY_DATA[pResult.value as string];
        setTimeout(() => {
          TextPickerDialog.show({
            range: cities,
            onAccept: (cResult: TextPickerResult) => {
              this.updateCityState(cResult.value as string);
            }
          })
        }, 300)
      }
    })
  }

  async fetchRealWeather(city: string) {
    let httpRequest = http.createHttp();
    try {
      let queryCity = city.replace('市', '');
      let url = `https://api.seniverse.com/v3/weather/now.json?key=S7zKUHHMAcavQT0_R&location=${encodeURIComponent(queryCity)}&language=zh-Hans&unit=c`;
      let response = await httpRequest.request(url, { connectTimeout: 5000 });
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as WeatherResponse;
        if (result.results?.length > 0) {
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

  async fetchRealNews() {
    // --- 💡 方案开关 ---
    const USE_REAL_CRAWLER = true;  // 模式A：后端抓取（做PPT/录视频时开启）
    // const USE_REAL_CRAWLER = false; // 模式B：本地数据（现场演示/提交代码时开启）
    // ----------------

    if (!USE_REAL_CRAWLER) {
      // 【方案二：调用本地数据】—— 模拟一个加载过程，显得更真实
      this.newsList = ["正在连接文旅数据中心...", "正在同步城市快报..."];
      setTimeout(() => {
        this.showLocalNews();
        console.info("已加载本地精品文旅数据");
      }, 800); // 故意延迟 0.8s，做出“请求”的视觉效果
      return;
    }

    // 【方案一：后端抓取模式】—— 仅在开启模式A时执行
    let isFinished = false;
    setTimeout(() => {
      if (!isFinished) {
        this.showLocalNews();
        isFinished = true;
      }
    }, 3000);

    let httpRequest = http.createHttp();
    // 注意：这里记得换成你真实的电脑IP
    const url = `http://192.168.103.83:5000/get_news/${encodeURIComponent(this.currentCity)}`;
    try {
      let response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 4000,
        expectDataType: http.HttpDataType.OBJECT
      });

      const res = response.result as MyNewsResponse;
      const localData = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;

      if (!isFinished && res.code === 200 && res.news.length > 0) {
        const realPart = res.news.slice(0, 3);
        const localPart = localData.news.slice(0, 3);
        this.newsList = realPart.concat(localPart).sort(() => Math.random() - 0.5);
        isFinished = true;
      }
    } catch (err) {
      if (!isFinished) {
        this.showLocalNews();
        isFinished = true;
      }
    } finally {
      httpRequest.destroy();
    }
  }

  // 统一的本地数据调用方法
  showLocalNews() {
    const localData = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
    // 随机打乱一下，每次进来顺序不一样，显得是实时拉取的
    this.newsList = [...localData.news].sort(() => Math.random() - 0.5);
  }


  async fetchHotTopics() {
    // 同样使用兜底数据获取关键词
    const config = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
    const localKeywords = config.keywords;
    const city = this.currentCity.replace('市', '');

    // 刚才定义的强类型模板
    const topicTemplates: TopicTemplate[] = [
      { suffix: '深度游攻略', color: '#FFEAA7' },
      { suffix: '地名背后的故事', color: '#81ECEC' },
      { suffix: '宝藏打卡地分享', color: '#FAB1A0' },
      { suffix: '特色美食避雷', color: '#D6E4FF' },
      { suffix: '历史建筑漫步', color: '#E8F5E9' }
    ];

    // 映射成 HotTopic 数组
    this.hotTopics = localKeywords.slice(0, 5).map((key: string, index: number): HotTopic => {
      return {
        title: `${city}${key}${topicTemplates[index].suffix}`,
        color: topicTemplates[index].color,
        count: `${(Math.random() * 5 + 1).toFixed(1)}w`
      };
    });
  }

  getWeatherIcon(text: string): Resource {
    if (text.includes('晴')) return $r('sys.symbol.sun_max_fill');
    if (text.includes('雨')) return $r('sys.symbol.light_rain');
    if (text.includes('阴') || text.includes('多云')) return $r('sys.symbol.cloud_fill');
    return $r('sys.symbol.cloud_sun_fill');
  }

  build() {
    Stack() {
      // 1. 背景层
      if (this.currentStage === 'welcome' || this.currentStage === 'stepGuide') {
        this.BackgroundAtmosphere()
      }

      // 2. 内容层 (修正：width/height/alignItems 从参数移至链式调用)
      Column() {
        // 第一阶段：欢迎页
        if (this.currentStage === 'welcome') {
          Stack() {
            // 1. 背景大图（利用你现有的资源，不加模糊，保持清晰感）
            Image($r('app.media.start'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)

            // 2. 渐变遮罩，让底部文字浮现
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#20000000', 0.0], ['#80000000', 1.0]]
              })

            // 3. 文字与入口
            Column() {
              // 城市标语
              Text('寻 · 域')
                .fontSize(48)
                .fontWeight(FontWeight.Lighter)
                .fontColor(Color.White)
                .letterSpacing(15) // 增加字间距，更有艺术感
                .margin({ bottom: 10 })

              Text('—— 触摸每一座城市的温度 ——')
                .fontSize(14)
                .fontColor('#CCFFFFFF')
                .letterSpacing(2)
                .margin({ bottom: 80 })

              // 探索入口
              Button() {
                Row({ space: 8 }) {
                  Text('开启旅程').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium)
                  SymbolGlyph($r('sys.symbol.arrow_right')).fontSize(18).fontColor([Color.White])
                }
              }
              .width(200)
              .height(56)
              .backgroundColor('rgba(255,255,255,0.15)') // 极简半透明背景
              .backgroundBlurStyle(BlurStyle.Thin)      // 加上毛玻璃效果
              .borderRadius(28)
              .border({ width: 1, color: 'rgba(255,255,255,0.3)' }) // 细边框质感
              .onClick(() => {
                this.currentStage = 'stepGuide'
                this.guideStepIndex = 0
                this.playStepText()
              })
            }
            .width('100%')
            .padding({ bottom: 100 })
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.End) // 内容沉在底部，更有意境
          }
          .width('100%')
          .height('100%')
        }

        // 第二阶段：分步文案引导
        else if (this.currentStage === 'stepGuide') {
          Stack() {
            Column() {
              Text(this.displayedText).fontSize(20).fontColor(Color.White).lineHeight(28).textAlign(TextAlign.Center).margin({ left: 24, right: 24, bottom: 30 })
              if (!this.isTyping) {
                Button(this.guideStepIndex < this.getGuideSteps().length - 1 ? '下一步' : '开始探索')
                  .width(180).height(44).backgroundColor('#FF7F50').fontColor('#333').borderRadius(22)
                  .onClick(() => this.nextStep(this.getGuideSteps().length))
              }
            }
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height('100%')
            .onClick(() => this.nextStep(this.getGuideSteps().length))
          }
          .width('100%')
          .height('100%')
        }

        // 第三阶段：教学态
        else if (this.currentStage === 'teaching') {
          Column({ space: 20 }) {
            Text('先从城市印象开始了解这座城市').fontSize(16).fontColor('#666')
            this.HeroArchiveCard()
            Button('展开完整内容').onClick(() => this.currentStage = 'full')
          }
          .padding(16)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F8F8F8') // 进入教学态，切回明亮背景
        }

        // 第四阶段：完整 ExploreView 内容
        else if (this.currentStage === 'full') {
          this.MainExploreContent()
        }
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  @Builder MainExploreContent() {
    Column() {
      // 顶部状态栏
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(18).fontColor(['#007DFF'])
          Text(this.currentCity).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 4 }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(12).fontColor(['#999'])
        }.onClick(() => this.showCityPicker()).width('28%')

        Search({ value: this.searchText, placeholder: '搜索目的地' })
          .layoutWeight(1).height(36).backgroundColor('#F1F3F5')
          .onChange((v) => this.searchText = v)

        Row() {
          SymbolGlyph(this.getWeatherIcon(this.weatherText)).fontSize(18).fontColor(['#FFAD0A'])
          Text(this.weatherInfo).fontSize(11).margin({ left: 3 })
        }.width('18%').justifyContent(FlexAlign.End)
      }.width('100%').padding(12).backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 20 }) {
          // 轮播图 Banner
          Swiper() {
            if (CITY_BANNER_CONFIG[this.currentCity]) {
              ForEach(CITY_BANNER_CONFIG[this.currentCity], (item: CityBanner) => {
                this.BannerImageItem(item.title, item.image)
              }, (item: CityBanner) => `${this.currentCity}_${item.title}`)
            } else {
              this.BannerItem(`${this.currentCity} · 发现更多`, '#DCDDE1')
            }
          }.width('100%').height(this.bannerHeight).autoPlay(true).borderRadius(12)

          // 节奏断点 / 弱提示文案
          Text('城市不止一种读法。').fontSize(12).fontColor('#999').margin({ top: 10, bottom: 8 })

          // 寻域快报
          Row() {
            Text('寻域快报')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4500')
              .flexShrink(0)

            Divider()
              .vertical(true)
              .height(24)
              .margin({ left: 8, right: 8 })
              .color('#EEE')
              .flexShrink(0)

            // 右侧内容区域
            if (this.isCitySwitching) {
              // —— 忙碌态 —— //
              Text(`正在同步 ${this.currentCity.replace('市', '')} 城市快报…`)
                .fontSize(12)
                .fontColor('#999')
                .opacity(0.8)
                .layoutWeight(1)
                .maxLines(1)
            } else {
              // —— 正常轮播态 —— //
              Swiper() {
                ForEach(this.newsList, (news: string) => {
                  Column() {
                    Text(news)
                      .fontSize(12)
                      .fontColor('#333')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .lineHeight(16)
                      .width('100%')
                  }
                  .justifyContent(FlexAlign.Center)
                  .height('100%')
                }, (item: string) => item)
              }
              .vertical(true)
              .autoPlay(true)
              .interval(4000)
              .indicator(false)
              .layoutWeight(1)
              .height(40)
            }
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FFF5F5')
          .borderRadius(8)

          // 功能金刚区
          Column() {
            this.HeroArchiveCard()
            Row({ space: 12 }) {
              this.VerticalFeatureCard('地名寻踪', $r('sys.symbol.doc_text_fill'), '#A29BFE', '探索地名背后的故事')
              Column({ space: 12 }) {
                this.HorizontalFeatureCard('历史轴线', $r('sys.symbol.timer_circle_fill'), '#65bb5c', '穿越时空的城市脉络')
                this.SquareFeatureCard('文化资源', $r('sys.symbol.flower'), '#FF2D55')
              }
              .width('54%')
            }
            .width('100%')
            .margin({ top: 16 })

            Text('探索本地生活')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 25, bottom: 16, left: 4 })
              .alignSelf(ItemAlign.Start)

            Row() {
              this.GalleryCard('景点推荐', $r('sys.symbol.camera_fill'), '#45B7D1')
              this.GalleryCard('场馆预约', $r('sys.symbol.house_fill'), '#F2994A')
              this.GalleryCard('特产风味', $r('sys.symbol.fork_knife'), '#FF6B6B')
              this.GalleryCard('全部', $r('sys.symbol.square_fill_grid_2x2'), '#8E8E93')
            }
            .width('100%')
            .padding({ top: 20, bottom: 20 })
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: 8 }) // 柔和浮空投影
          }
          .padding({ left: 16, right: 16 })

          // 节奏断点 / 弱提示文案
          Text('慢慢探索，每一次出行都有惊喜。').fontSize(12).fontColor('#999').margin({ top: 10, bottom: 8 })

          // 正在讨论
          Column() {
            // 找到这行
            this.SectionHeader(`今天的${this.currentCity.replace('市','')}在讨论什么`)
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.hotTopics, (topic: HotTopic) => {
                  this.TopicItem(topic.title, topic.count, topic.color)
                }, (item: HotTopic) => item.title)
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
          }.opacity(this.isCitySwitching ? 0.5 : 1).enabled(!this.isCitySwitching) // 👈 防止切换中误触

          // 路线推荐
          Column() {
            this.SectionHeader(`编辑推荐 · 行走路线`)
            if (CITY_ROUTES[this.currentCity]?.length > 0) {
              ForEach(CITY_ROUTES[this.currentCity], (route: TravelRoute) => {
                this.NewRouteCard(route)
              }, (item: TravelRoute) => `${this.currentCity}_${item.routeName}`)
            } else {
              Column() {
                SymbolGlyph($r('sys.symbol.map_badge_cloud_slash_fill')).fontSize(30).fontColor(['#DDD'])
                Text(`${this.currentCity} 路线正在火速规划中...`).fontSize(14).fontColor('#999').margin({ top: 10 })
              }.width('100%').padding(30)
            }
          }

          // 页面底部弱结束语
          Column() {
            Text('每座城市，都值得被慢慢认识。').fontSize(12).fontColor('#AAA').margin({ top: 15 })
          }.width('100%').height(80)

        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F8F8F8')
  }

  @Builder BackgroundAtmosphere() {
    Stack() {
      Image($r('app.media.start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover) // ✅ 关键：确保横图在纵屏下自动中心裁剪
        .blur(25)                 // ✅ 稍微加大模糊，利用云层的金色形成光晕
        .opacity(0.5)              // 保持半透明
        .scale({ x: 1.2, y: 1.2 }) // ✅ 稍微加大初始比例，给 Ken Burns 效果留足裁剪空间
        .animation({ duration: 12000, iterations: -1, curve: Curve.Linear }) // 极慢速移动

      // ✅ 建议加一层极其微弱的暗色蒙层，防止夕阳太亮盖住白色文字
      Rect()
        .width('100%')
        .height('100%')
        .fill(Color.Black)
        .opacity(0.15)
    }.width('100%').height('100%')

  }

  @Builder BannerImageItem(title: string, img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img).width('100%').height('100%').borderRadius(12).objectFit(ImageFit.Cover)
      Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').margin(15)
        .textShadow({ radius: 8, color: '#90000000', offsetX: 2, offsetY: 2 })
    }
  }

  @Builder BannerItem(title: string, color: string) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Rect().width('100%').height('100%').fill(color).borderRadius(12).opacity(0.2)
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333').margin(20)
    }
  }

  @Builder TopicItem(title: string, count: string, color: string) {
    Column() {
      Text(`# ${title}`).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333')
      Text(`${count} 参与讨论`).fontSize(11).fontColor('#666').margin({ top: 6 })
    }.width(140).height(70).padding(12).backgroundColor(color).borderRadius(12).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
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
        Text(`${route.spots.length}个打卡点 · 建议时间${route.spots.length > 3 ? '1天' : '半天'}`).fontSize(12).fontColor('#666').margin({ top: 4 })
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Button('开始导览').height(28).fontSize(11).backgroundColor('#007DFF').onClick(() => this.jumpToGuide(route))
    }.width('100%').padding(15).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 }).onClick(() => this.jumpToGuide(route))
  }

  // 🖼️ 【画卷入口】城市印象
  @Builder HeroArchiveCard() {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 模拟一个城市缩略图背景（可配合你的城市数据）
      Image($r('app.media.city_impression_placeholder'))
        .width('100%').height(140).borderRadius(20).objectFit(ImageFit.Cover)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#00000000', 0.0], ['#CC000000', 1.0]]
        })

      Column() {
        Text('城市印象').fontSize(22).fontWeight(FontWeight.Bolder).fontColor(Color.White)
        Text(`${this.currentCity} · 城市档案总览`).fontSize(12).fontColor('rgba(255,255,255,0.8)').margin({ top: 4 })
      }.padding(20)
    }
    .width('100%')
    .onClick(() => {
      router.pushUrl({
        url: 'pages/features/DataDetailView',
        params: {
          title: '城市印象',
          cityName: this.currentCity,
          color: '#333333',
          icon: $r('sys.symbol.bookmark_fill')
        }
      })
    })
  }

  // 📚 【竖向档案】地名寻踪
  @Builder VerticalFeatureCard(title: string, icon: Resource, color: string, desc: string) {
    Column() {
      SymbolGlyph(icon).fontSize(32).fontColor([color]).margin({ bottom: 15 })
      Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
      Text(desc).fontSize(10).fontColor('#999').margin({ top: 8 }).textAlign(TextAlign.Center)
      Blank()
      // 装饰元素：像档案索引标签
      Rect().width(30).height(4).fill(color).borderRadius(2).opacity(0.3)
    }
    .height(180)
    .padding(20)
    .width('42%')
    .backgroundColor('#F8F9FF')
    .borderRadius({ topLeft: 30, bottomRight: 30, topRight: 10, bottomLeft: 10 }) // ✅ 极具辨识度的非对称圆角
    .onClick(() => router.pushUrl({ url: 'pages/features/GeoOrigin' }))
  }

  // ⏳ 【横向脉络】历史轴线
  @Builder HorizontalFeatureCard(title: string, icon: Resource, color: string, desc: string) {
    Row() {
      Column() {
        Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
        Text(desc).fontSize(10).fontColor('#999').margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      SymbolGlyph(icon).fontSize(26).fontColor([color])
    }
    .padding(18)
    .backgroundColor('#F5FFF9')
    .borderRadius(16)
    .onClick(() => router.pushUrl({ url: 'pages/features/CityHistoryPage' }))
  }

  // 🎨 【画廊卡片】景点/特产/文化
  @Builder GalleryCard(name: string, icon: Resource, color: string) {
    Column() {
      Stack() {
        // 背景微圆环
        Circle({ width: 44, height: 44 })
          .fill(color)
          .opacity(0.08)
        SymbolGlyph(icon)
          .fontSize(22)
          .fontColor([color])
      }
      Text(name)
        .fontSize(12).fontWeight(FontWeight.Medium).fontColor('#444').margin({ top: 8 })
    }
    // 💡 关键：使用 25% 宽度实现四分并排
    .width('25%')
    .height(90)
    .justifyContent(FlexAlign.Center)
    // 增加点击反馈逻辑
    .onClick(() => {
      const pageMap: Record<string, string> = {
        '全部': 'pages/features/AllFunctionsView',
        '场馆预约': 'pages/features/VenueBookingView'
      };
      if (pageMap[name]) {
        router.pushUrl({ url: pageMap[name], params: { title: name, cityName: this.currentCity } });
      } else {
        promptAction.showToast({ message: `${name} 功能开发中...` });
      }
    })
  }

  @Builder SquareFeatureCard(title: string, icon: Resource, color: string) {
    Row() {
      SymbolGlyph(icon).fontSize(20).fontColor([color])
      Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333').margin({ left: 10 })
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFF9F5')
    .borderRadius(16)
    .onClick(() => {
      // const pageMap: Record<string, string> = {
      // };
      promptAction.showToast({ message: `寻域 · ${this.currentCity}文化资源库建设中...` })
    })
  }

  jumpToGuide(route: TravelRoute) {
    router.pushUrl({ url: 'pages/guide/GuideView', params: { route: route } })
  }
}
