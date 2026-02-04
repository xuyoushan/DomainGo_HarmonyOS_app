import { router } from '@kit.ArkUI';
import { CultureStory, CityCultureSpecialty, CULTURE_SPECIALTY_MAP } from '../../../models/CultureSpecialtyData';

@Entry
@Component
struct CultureView {
  @State currentCity: string = (router.getParams() as Record<string, string>)?.['cityName'] || '武汉市';
  @State currentIndex: number = 0;
  @State isDetailOpen: boolean = false;
  @State bgScale: number = 1.05;
  @State data: CultureStory[] = [];
  @State isImmersive: boolean = false;

  aboutToAppear() {
    this.data = CULTURE_SPECIALTY_MAP[this.currentCity]?.cultureStories || [];
  }

  /* ======================= 顶部导航 ======================= */
  @Builder
  NavigationHeader() {
    if (!this.isImmersive) {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor([Color.White])
          .onClick(() => router.back())

        Text(`寻域 · ${this.currentCity}`)
          .fontSize(18)
          .fontWeight(FontWeight.Lighter)
          .fontColor(Color.White)
          .letterSpacing(4)
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 40 })
      .zIndex(100)
    }
  }

  /* ======================= 无数据提示 (Empty State) ======================= */
  @Builder
  EmptyState() {
    Stack() {
      // 艺术感背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#1C1C1E')

      Column({ space: 20 }) {
        SymbolGlyph($r('sys.symbol.wind'))
          .fontSize(60)
          .fontColor(['#444444'])

        Text("此城尚在云深处")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5E5E5')
          .letterSpacing(2)

        Text("万物静默，等待下一场人文的季风。")
          .fontSize(16)
          .fontColor('#888888')
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .padding({ left: 40, right: 40 })

        Button("返回探索")
          .margin({ top: 30 })
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: '#444444' })
          .onClick(() => router.back())
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  /* ======================= 故事卡片 ======================= */
  @Builder
  StoryCard(item: CultureStory, index: number) {
    Stack({ alignContent: Alignment.Top }) {
      Image(item.coverImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .scale({
          x: this.currentIndex === index ? this.bgScale : 1.08,
          y: this.currentIndex === index ? this.bgScale : 1.08
        })
        .animation({
          duration: 4000,
          curve: Curve.EaseInOut,
          iterations: -1,
          playMode: PlayMode.Alternate
        })

      if (!this.isImmersive) {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 20 }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            Column() {
              Text(item.tag)
                .fontSize(14)
                .fontColor(Color.White)
                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                .backgroundColor(item.accentColor)
                .borderRadius(6)
                .margin({ bottom: 24 })

              Text(item.title)
                .fontSize(55)
                .fontWeight(FontWeight.Bolder)
                .fontColor(Color.White)
                .lineHeight(80)
                .letterSpacing(10)

              Column() {
                Text(item.quote)
                  .fontSize(20)
                  .fontColor('#F5F5F5')
                  .fontWeight(FontWeight.Medium)
                  .fontStyle(FontStyle.Italic)
                  .lineHeight(36)
                  .letterSpacing(2)
              }
              .padding({ left: 24, right: 24, top: 16, bottom: 16 })
              .margin({ top: 40 })
              .borderRadius(16)
              .backgroundColor('rgba(255, 255, 255, 0.05)')
              .backdropBlur(25)
              .border({ width: 0.5, color: '#26FFFFFF' })

              Blank()

              Column() {
                SymbolGlyph($r('sys.symbol.chevron_up'))
                  .fontSize(36)
                  .fontColor([Color.White])

                Text('向上滑动 开启秘境')
                  .fontSize(14)
                  .fontColor(Color.White)
                  .letterSpacing(3)
                  .margin({ top: 10 })
              }
              .margin({ bottom: 60 })
              .hitTestBehavior(HitTestMode.Block)
              .onClick(() => {
                animateTo({ duration: 488, curve: Curve.FastOutSlowIn }, () => {
                  this.isDetailOpen = true
                })
              })
            }
            .height('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 30, right: 30, top: 120 })
          }
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
        .transition(TransitionEffect.OPACITY.animation({ duration: 488, curve: Curve.EaseInOut }))
      }
    }
    .width('100%')
    .height('100%')
    .priorityGesture(
      TapGesture()
        .onAction(() => {
          animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
            this.isImmersive = !this.isImmersive
          })
        })
    )
  }

  /* ======================= 主体 ======================= */
  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.NavigationHeader()

      if (this.data.length > 0) {
        Swiper() {
          ForEach(this.data, (item: CultureStory, index: number) => {
            this.StoryCard(item, index)
          }, (item: CultureStory) => item.title)
        }
        .vertical(true)
        .indicator(false)
        .loop(false)
        .duration(600)
        .curve(Curve.Friction)
        .hitTestBehavior(HitTestMode.Default)
        .enabled(!this.isDetailOpen)
        .onChange((index: number) => {
          this.currentIndex = index;
        })

        if (this.isDetailOpen) {
          Stack({ alignContent: Alignment.Bottom }) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('transparent')
              .onClick(() => {
                animateTo({ duration: 400 }, () => {
                  this.isDetailOpen = false
                })
              })

            this.DetailPanel()
          }
          .width('100%')
          .height('100%')
          .zIndex(200)
        }
      }else {
        this.EmptyState()
      }
    }
    .width('100%')
    .height('100%')
  }

  /* ======================= 详情面板 ======================= */
  @Builder
  DetailPanel() {
    Column() {

      Scroll() {
        Column({ space: 28 }) {

          Text(this.data[this.currentIndex].title)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.data[this.currentIndex].accentColor)
            // .fontColor(Color.Black)

          Divider()
            // .color(this.data[this.currentIndex].accentColor)
            .color(Color.Black)
            .strokeWidth(6)
            .width(72)

          Text(this.data[this.currentIndex].content)
            .fontSize(20)
            .fontColor(this.data[this.currentIndex].accentColor)
            .lineHeight(42)
            .letterSpacing(1.5)

        }
        .padding({ left: 36, right: 36, top: 24, bottom: 32 })
      }
    }
    .width('100%')
    .height('55%')
    .backgroundColor('#FAFAF8')
    .borderRadius({ topLeft: 40, topRight: 40 })
    .transition(
      TransitionEffect.move(TransitionEdge.BOTTOM)
        .combine(TransitionEffect.OPACITY)
    )
  }
}
