import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { PROVINCE_CITY_DATA } from '../../models/CityData';
import { CITY_BANNER_CONFIG, CityBanner } from '../../models/CityBannerData';
import { promptAction, router, display, window } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute } from '../../models/RouteData';
import { CITY_EXPLORE_MAP, DEFAULT_EXPLORE_DATA, CityExploreConfig } from '../../models/ExploreCityData';
import { PreferenceManager } from '../../services/PreferenceManager';

interface WeatherNow { temperature: string; text: string; }
interface WeatherResult { now: WeatherNow; }
interface WeatherResponse { results: WeatherResult[]; }
interface HotTopic { title: string; color: string; count: string; }
interface TopicTemplate { suffix: string; color: string; }
interface MyNewsResponse { code: number; city: string; news: string[]; }

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @State weatherText: string = '阴';
  @State searchText: string = '';
  @State scaleValue: number = 1.0;
  @State bannerHeight: number = 200;
  @State hotTopics: HotTopic[] = [];
  @State newsList: string[] = ["正在连接文旅大数据中心..."];
  @State isCitySwitching: boolean = false
  @State currentStage: 'welcome' | 'stepGuide' | 'full' = 'welcome'
  @State guideStepIndex: number = 0
  @State displayedText: string = ''
  @State isTyping: boolean = false
  @State guideOpacity: number = 1.0;
  @StorageLink('hasCompletedGuide') hasCompletedGuide: boolean = false;
  @State isReady: boolean = true;
  @StorageLink('show_guide_manual') show_guide_manual: boolean = false;
  @State isDataLoaded: boolean = false;
  @State isShowGuideModal: boolean = false;
  @StorageLink('welcomeFinished') welcomeFinished: boolean = false;

  private timerId: number = -1

  private context = getContext(this) as common.UIAbilityContext;

  private getGuideSteps(): string[] {
    return [
      `欢迎来到寻域之旅。\n在这座城市，每条街道、每幢建筑、每个人的笑声里，都藏着独特的故事。`,
      `这里有被时间遗忘的老巷，有被记忆铭刻的历史建筑。\n走进去，你会发现那些平凡角落里非凡的秘密。`,
      `在这里，你可以慢慢品味城市的味道。\n无论是街头小吃的香气，\n还是老茶馆里的谈笑声，\n都在讲述属于城市的温度。`,
      `每一座城市都有自己的节奏和脉络。\n历史、文化、生活在这里交织，每一步行走，都是一次新的发现。`,
      `准备好了吗？\n让我们从这里开始，慢慢触摸城市的故事。\n一场探索之旅即将在你的指尖展开。`,
      `点击“开始探索”\n去寻域\n去了解每个功能、每条路线、每个故事的精华。`];
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
    }
  }

  private async enterMainPage() {
    await PreferenceManager.put(this.context, 'hasCompletedGuide', true);
    await PreferenceManager.put(this.context, 'show_guide_manual', false);
    AppStorage.setOrCreate('show_guide_manual', false);
    AppStorage.setOrCreate('welcomeFinished', true);

    const win = await window.getLastWindow(this.context);
    animateTo({
      duration: 888,
      curve: Curve.EaseInOut,
      onFinish: () => {
        this.currentStage = 'full';
      }
    }, () => {
      this.isReady = false;
      win.setWindowSystemBarEnable(['status', 'navigation']);
      win.setWindowLayoutFullScreen(false);
    })
  }

  getCityConfig(): CityExploreConfig {
    return CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
  }

  aboutToAppear() {
    if (this.welcomeFinished) {
      this.currentStage = 'full';
      this.isReady = false;
    } else {
      this.currentStage = 'welcome';
      this.isReady = true;
    }
    try {
      const displayData: display.Display = display.getDefaultDisplaySync();
      this.bannerHeight = px2vp(displayData.width) * 9 / 16;
    } catch (e) {
      this.bannerHeight = 200;
    }
    window.getLastWindow(this.context, (err: BusinessError, data: window.Window) => {
      const errCode: number = err.code;
      if (errCode) {
        console.error('Failed to get window: ' + JSON.stringify(err));
        return;
      }
      let win: window.Window = data;
      win.setWindowLayoutFullScreen(true);
      win.setWindowSystemBarEnable([]);
    });
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

  showLocalNews() {
    const localData = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
    this.newsList = [...localData.news].sort(() => Math.random() - 0.5);
  }

  async fetchHotTopics() {
    const config = CITY_EXPLORE_MAP[this.currentCity] || DEFAULT_EXPLORE_DATA;
    const localKeywords = config.keywords;
    const city = this.currentCity.replace('市', '');

    const topicTemplates: TopicTemplate[] = [
      { suffix: '深度游攻略', color: '#FFEAA7' },
      { suffix: '地名背后的故事', color: '#81ECEC' },
      { suffix: '宝藏打卡地分享', color: '#FAB1A0' },
      { suffix: '特色美食避雷', color: '#D6E4FF' },
      { suffix: '历史建筑漫步', color: '#E8F5E9' }
    ];

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
      if (!this.isReady || this.currentStage === 'full') {
        Column() {
          this.MainExploreContent()
        }
        .width('100%').height('100%')
      }

      if (this.isReady && this.currentStage !== 'full') {
        Stack() {
          this.BackgroundAtmosphere()
          Column() {
            if (this.currentStage === 'welcome') {
              this.WelcomeGuideUI()
            } else if (this.currentStage === 'stepGuide') {
              this.StepGuideUI()
            }
          }
          .width('100%').height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .zIndex(999)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 1.1, y: 1.1 })))
      }
    }
    .width('100%')
    .height('100%')
  }

  // 引导逻辑
  @Builder GuideContent() {
    Stack() {
      Rect().width('100%').height('100%').fill(Color.Black)
      if (this.currentStage === 'welcome' || this.currentStage === 'stepGuide') {
        this.BackgroundAtmosphere()
      }
      Column() {
        if (this.currentStage === 'welcome') {
          this.WelcomeGuideUI()
        } else if (this.currentStage === 'stepGuide') {
          this.StepGuideUI()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder WelcomeGuideUI() {
    Stack() {
      Image($r('app.media.start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#20000000', 0.0], ['#80000000', 1.0]]
        })
      Column() {
        Text('寻 · 域')
          .fontSize(48)
          .fontWeight(FontWeight.Lighter)
          .fontColor(Color.White)
          .letterSpacing(15)
          .margin({ bottom: 10 })

        Text('—— 触摸每一座城市的温度 ——')
          .fontSize(14)
          .fontColor('#CCFFFFFF')
          .letterSpacing(2)
          .margin({ bottom: 80 })

        Button() {
          Row({ space: 8 }) {
            Text('开启旅程').fontColor(Color.White).fontSize(16).fontWeight(FontWeight.Medium)
            SymbolGlyph($r('sys.symbol.arrow_right')).fontSize(18).fontColor([Color.White])
          }
        }
        .width(200)
        .height(56)
        .backgroundColor('rgba(255,255,255,0.15)')
        .backgroundBlurStyle(BlurStyle.Thin)
        .borderRadius(28)
        .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
        .onClick(async () => {
          const isFinished = await PreferenceManager.get(this.context, 'hasCompletedGuide', false) as boolean;
          const isManualOpen = await PreferenceManager.get(this.context, 'show_guide_manual', false) as boolean;
          console.info(`[ButtonCheck] 磁盘状态 - 已完成: ${isFinished}, 手动开关: ${isManualOpen}`);
          if (isFinished && !isManualOpen) {
            this.enterMainPage();
          } else {
            animateTo({ duration: 300 }, () => {
              this.currentStage = 'stepGuide';
            })
            this.guideStepIndex = 0;
            this.playStepText();
          }
        })
      }
      .width('100%')
      .padding({ bottom: 100 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
  }

  @Builder StepGuideUI() {
    Stack() {
      Column() {
        Text(this.displayedText).fontSize(20)
          .fontWeight(FontWeight.Lighter).fontColor(Color.White)
          .lineHeight(32).textAlign(TextAlign.Center)
          .margin({ left: 24, right: 24, bottom: 30 }).textShadow({ radius: 4, color: '#80000000', offsetY: 2 })
        if (!this.isTyping) {
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text(this.guideStepIndex < this.getGuideSteps().length - 1 ? '下一步' : '开始探索')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .letterSpacing(2)
          }
          .width(200).height(56)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#FF7F50', 0.0], ['#FF6B6B', 1.0]]
          })
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.5)' })
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White).fontSize(16)
          .backgroundBlurStyle(BlurStyle.Thin)
          .border({ width: 1, color: 'rgba(255, 255, 255, 0.5)' })
          .borderRadius(25)
          .shadow({
            radius: 15,
            color: 'rgba(255, 107, 107, 0.4)', // 按钮同色系的呼吸投影
            offsetY: 8
          })
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              animateTo({ duration: 100 }, () => { this.scaleValue = 0.95 })
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              animateTo({ duration: 100 }, () => { this.scaleValue = 1.0 })
            }
          })
          .onClick(() => {
            if (this.guideStepIndex < this.getGuideSteps().length - 1) {
              this.nextStep(this.getGuideSteps().length);
            } else {
              this.enterMainPage();
            }
          })
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

  @Builder MainExploreContent() {
    Column() {
      // 顶部状态栏
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill')).fontSize(18).fontColor(['#007DFF'])
          Text(this.currentCity).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 4 }).maxLines(2).minFontSize(9).maxFontSize(14).textOverflow({ overflow: TextOverflow.Ellipsis }).constraintSize({ maxWidth: 80 }).textAlign(TextAlign.Start)
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
            this.SectionHeader(`今天的${this.currentCity.replace('市','')}在讨论什么`)
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.hotTopics, (topic: HotTopic) => {
                  this.TopicItem(topic.title, topic.count, topic.color)
                }, (item: HotTopic) => item.title)
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
          }.opacity(this.isCitySwitching ? 0.5 : 1).enabled(!this.isCitySwitching)
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
        .opacity(0.6)              // 保持半透明
        .scale({ x: 1.2, y: 1.2 }) // ✅ 稍微加大初始比例，给 Ken Burns 效果留足裁剪空间
        .animation({ duration: 12000, iterations: -1, curve: Curve.Linear })
      Rect()
        .width('100%')
        .height('100%')
        .fill(Color.Black)
        .opacity(0.15)
    }.width('100%').height('100%')
    .hitTestBehavior(HitTestMode.None)
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
        url: 'pages/features/explore/DataDetailView',
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
      Rect().width(30).height(4).fill(color).borderRadius(2).opacity(0.3)
    }
    .height(180)
    .padding(20)
    .width('42%')
    .backgroundColor('#F8F9FF')
    .borderRadius({ topLeft: 30, bottomRight: 30, topRight: 10, bottomLeft: 10 })
    .onClick(() => router.pushUrl({ url: 'pages/features/explore/GeoOrigin' }))
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
    .onClick(() => router.pushUrl({ url: 'pages/features/explore/CityHistoryPage' }))
  }

  // 🎨 【画廊卡片】景点/特产/文化
  @Builder GalleryCard(name: string, icon: Resource, color: string) {
    Column() {
      Stack() {
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
    .width('25%')
    .height(90)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      const pageMap: Record<string, string> = {
        '全部': 'pages/features/explore/AllFunctionsView',
        '场馆预约': 'pages/features/explore/VenueBookingView',
        '特产风味': 'pages/features/explore/SpecialtyView'
      };
      if (pageMap[name]) {router.pushUrl({ url: pageMap[name], params: { cityName: this.currentCity } });
      } else if (name === '文化资源') {
        router.pushUrl({ url: 'pages/features/explore/CultureView', params: { cityName: this.currentCity } });
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
    .onClick(() => {router.pushUrl({ url: 'pages/features/explores/CultureView', params: { cityName: this.currentCity } });
    })
  }

  jumpToGuide(route: TravelRoute) {
    router.pushUrl({ url: 'pages/guide/GuideView', params: { route: route } })
  }
}