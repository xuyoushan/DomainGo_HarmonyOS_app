import { LocationManager } from '../../services/LocationManager';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { WeatherWidget } from '../../components/Explore/Weather';
import { PROVINCE_CITY_DATA } from '../../models/CityData';
import { CityBanner, getBannerByCity } from '../../models/CityBannerData';
import { promptAction, router, display } from '@kit.ArkUI';
import { CITY_ROUTES, TravelRoute } from '../../models/RouteData';
import { CITY_EXPLORE_MAP, DEFAULT_EXPLORE_DATA, CityExploreConfig } from '../../models/CityKey';
import { WelcomeGuide } from '../../components/Explore/WelcomeGuide';
import { AIChatSheet } from '../../components/Explore/ExploreAIModel'

interface HotTopic { title: string; color: string; count: string; }
interface TopicTemplate { suffix: string; color: string; }
interface MyNewsResponse { code: number; city: string; news: string[]; }

@Component
export struct ExploreView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('currentWeather') weatherInfo: string = '...';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('show_guide_manual') show_guide_manual: boolean = false;
  @StorageLink('welcomeFinished') welcomeFinished: boolean = false;
  @StorageLink('hasCompletedGuide') hasCompletedGuide: boolean = false;
  @State scaleValue: number = 1.0;
  @State bannerHeight: number = 200;
  @State hotTopics: HotTopic[] = [];
  @State newsList: string[] = ["正在连接文旅大数据中心..."];
  @State isCitySwitching: boolean = false
  @State currentStage: 'welcome' | 'stepGuide' | 'full' = 'welcome'
  @State isReady: boolean = true;
  @State aiScale: number = 1.0;
  @State aiOpacity: number = 0.9;
  @State displayedText: string = ''
  @State isTyping: boolean = false
  @State guideStepIndex: number = 0
  @State isChatOpen: boolean = false;

  private context = getContext(this) as common.UIAbilityContext;

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
  }
  onPageShow() {
    this.initLocation();
    this.fetchRealNews();
    animateTo({ duration: 1500, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.aiScale = 1.03;
      this.aiOpacity = 0.7;
    })
  }

  async initLocation() {
    try {
      const isAuth = await LocationManager.requestPermission(this.context)
      if (isAuth) {
        const city = await LocationManager.getRealCity(this.context)
        if (city && city !== '定位失败') {
          this.updateCityState(city);
        }
      }
    } catch (err) {
      console.error("定位服务异常");
    }
  }

  private async updateCityState(city: string) {
    if (city === this.currentCity) return

    this.isCitySwitching = true
    this.currentCity = city
    AppStorage.setOrCreate('currentCity', city)

    await new Promise<void>((resolve) => {setTimeout(() => {resolve()}, 500)})

    await Promise.all([this.fetchRealNews(), this.fetchHotTopics()])

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

  async fetchRealNews() {
    const USE_REAL_CRAWLER = true;
    if (!USE_REAL_CRAWLER) {
      this.newsList = ["正在连接文旅数据中心...", "正在同步城市快报..."];
      return;
    }
    let isFinished = false;
    setTimeout(() => { if (!isFinished) { isFinished = true; } }, 5000);

    let httpRequest = http.createHttp();
    const url = `https://domaingo-script-xspvlwqrjf.cn-hangzhou.fcapp.run?city=${encodeURIComponent(this.currentCity)}`;


    try {
      let response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        expectDataType: http.HttpDataType.OBJECT
      });
      const res = response.result as MyNewsResponse;

      if (res.code === 200 && res.news && res.news.length > 0) {
        this.newsList = res.news;
        isFinished = true;
        console.info(`[Explore] 已同步 ${this.currentCity} 的全真新闻`);
      } else {
        this.newsList = [`暂未发现 ${this.currentCity} 的今日快报`];
      }
    } catch (err) {
      this.newsList = ["文旅部动态更新中..."];
    } finally {
      httpRequest.destroy();
    }
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

  build() {
    Stack() {
      if (!this.isReady || this.currentStage === 'full') {
        Column() {
          this.MainExploreContent()
        }
        .width('100%')
        .height('100%')
      }

      if (this.isReady && this.currentStage !== 'full') {
        WelcomeGuide({
          currentStage: $currentStage,
          displayedText: $displayedText,
          isTyping: $isTyping,
          guideStepIndex: $guideStepIndex,
          scaleValue: $scaleValue,
          isReady: $isReady
        })
          .zIndex(999)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .transition(TransitionEffect.OPACITY.animation({ duration: 888, curve: Curve.EaseInOut }))
      }
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.isChatOpen, this.AIChatPanelBuilder(), {
      height: SheetSize.LARGE,
      title: { title: `寻域 AI · ${this.currentCity}` },
      backgroundColor: '#F5F7FA'
    })
  }

  @Builder AIChatPanelBuilder() {
    AIChatSheet({
      currentCity: this.currentCity,
      isChatOpen: $isChatOpen
    })
  }

  @Builder MainExploreContent() {
    Column() {
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.location_north_up_right_and_circle_dotted_fill'))
            .fontSize(20)
            .fontColor(['#6C5CE7'])
          Text(this.currentCity.replace('自治州', ''))
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .minFontSize(11)
            .maxFontSize(15)
        }
        .width('25%')
        .onClick(() => this.showCityPicker())

        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.AI'))
              .fontSize(20)
              .fontColor([Color.White])
              .symbolEffect(new SymbolEffect(), true)
              .scale({ x: this.aiScale, y: this.aiScale })

            Text('你好，寻域探险家！')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.9)')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 6 })
              .maxLines(1)
              .opacity(this.aiOpacity)
              .textOverflow({ overflow: TextOverflow.None })
          }
          .height(38)
          .width(160)
          .borderRadius(20)
          .padding({ left: 14, right: 14 })
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#6C5CE7', 0.0], ['#00CEC9', 0.5], ['#0984E3', 1.0]]
          })
          .shadow({ radius: 12, color: 'rgba(108, 92, 231, 0.3)', offsetY: 4 })
          .scale({ x: this.aiScale, y: this.aiScale })
          .onClick(async () => {
            if (this.currentCity === '定位中...' || this.currentCity === '定位失败' || this.isCitySwitching) {
              promptAction.showToast({ message: '正在感应城市气息，请稍后...' });
              return;
            }
            this.isChatOpen = true;
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .padding({ right: 10 })

        WeatherWidget()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('rgba(255,255,255,0.95)')
      .backgroundBlurStyle(BlurStyle.Thin)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

      Scroll() {
        Column({ space: 20 }) {
          Swiper() {
            ForEach(getBannerByCity(this.currentCity), (item: CityBanner) => {
              this.BannerImageItem(item.title, item.image)
            }, (item: CityBanner) => `${this.currentCity}_${item.title}`)
          }
          .width('100%')
          .height(this.bannerHeight)
          .autoPlay(this.currentCity !== '定位中...')
          .borderRadius(12)
          .key(this.currentCity)

          Text('城市不止一种读法。').fontSize(12).fontColor('#999').margin({ top: 10, bottom: 8 })

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

            if (this.isCitySwitching) {
              Text(`正在同步 ${this.currentCity.replace('市', '')} 城市快报…`)
                .fontSize(12)
                .fontColor('#999')
                .opacity(0.8)
                .layoutWeight(1)
                .maxLines(1)
            } else {
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

          Column() {
            this.HeroArchiveCard()
            Row({ space: 12 }) {
              this.VerticalFeatureCard('地名寻踪', $r('sys.symbol.doc_text_fill'), '#A29BFE', '探索地名故事\n了解城市起源\n触摸城市底蕴')
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
            .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: 8 })
          }
          .padding({ left: 16, right: 16 })
          Text('慢慢探索，每一次出行都有惊喜。').fontSize(12).fontColor('#999').margin({ top: 10, bottom: 8 })

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
          Column() {
            Text('每座城市，都值得被慢慢认识。').fontSize(12).fontColor('#AAA').margin({ top: 15 })
          }.width('100%').height(80)

        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#FAFAFA')
  }


  @Builder BannerImageItem(title: string, img: Resource) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(img).width('100%').height('100%').borderRadius(12).objectFit(ImageFit.Cover).alt($r('app.media.start'))
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

  @Builder HeroArchiveCard() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.city_impression_placeholder'))
        .width('100%').height(140).borderRadius(20).objectFit(ImageFit.Cover)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#00000000', 0.0], ['#CC000000', 1.0]]
        })

      Column() {
        Text('城市印象').fontSize(22).fontWeight(FontWeight.Bolder).fontColor(Color.White)
        Text(`${this.currentCity} · 字里行间`).fontSize(12).fontColor('rgba(255,255,255,0.8)').margin({ top: 4 })
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
        '特产风味': 'pages/features/explore/SpecialtyView',
        '景点推荐': 'pages/features/explore/ScenicRecommendView',
        '文化资源': 'pages/features/explore/CultureView'
      };
      router.pushUrl({ url: pageMap[name], params: { cityName: this.currentCity } });
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
    .onClick(() => {router.pushUrl({ url: 'pages/features/explore/CultureView', params: { cityName: this.currentCity } });
    })
  }

  jumpToGuide(route: TravelRoute) {
    router.pushUrl({ url: 'pages/guide/GuideView', params: { route: route } })
  }
}