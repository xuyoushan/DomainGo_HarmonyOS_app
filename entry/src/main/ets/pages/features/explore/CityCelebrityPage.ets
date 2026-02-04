import { router } from '@kit.ArkUI'
import { Celebrity, CITY_CELEBRITY_MAP } from '../../../models/CelebrityData'

@Entry
@Component
struct CityPeoplePage {
  @State currentCity: string = "北京"
  @State people: Celebrity[] = []
  @State swiperIndex: number = 0
  @State scrollOffset: number = 0

  private swiperController: SwiperController = new SwiperController()

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    if (params && (params.cityName || params.city)) {
      this.currentCity = (params.cityName || params.city).trim().replace("市", "")
    }
    this.people = CITY_CELEBRITY_MAP[this.currentCity] || []
  }

  private getWorksArray(works: string): string[] {
    if (!works) return []
    return works.split(/[《》·/]+/).filter(item => item.trim().length > 0)
  }

  private getIdentityArray(identity: string): string[] {
    if (!identity) return []
    return identity.split('·').map(i => i.trim())
  }

  private getSplitParts(text: string): string[] {
    const keywords: string[] = ['代表', '重要', '首次', '著名', '奠定', '影响', '开创'];
    return text.split(new RegExp(`(${keywords.join('|')})`, 'g'));
  }

  private isKeyword(word: string): boolean {
    const keywords: string[] = ['代表', '重要', '首次', '著名', '奠定', '影响', '开创'];
    return keywords.includes(word);
  }

  pageTransition() {
    // 进入页面：从右侧滑入并淡入
    PageTransitionEnter({ duration: 888, curve: Curve.FastOutSlowIn })
      .slide(SlideEffect.Right)
      .opacity(0)

    // 退出页面：向左侧滑出并淡出
    PageTransitionExit({ duration: 888, curve: Curve.FastOutSlowIn })
      .slide(SlideEffect.Left)
      .opacity(0)
  }

  @Builder
  buildDescription(text: string) {
    Text() {
      ForEach(this.getSplitParts(text), (word: string, index: number) => {
        if (this.isKeyword(word)) {
          Span(word)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A') // 关键词加粗加黑
        } else {
          Span(word)
            .fontSize(16)
            .fontColor('#555555')
        }
      }, (item: string, index: number) => index.toString() + item)
    }
    .lineHeight(30)
    .letterSpacing(1.1)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Swiper(this.swiperController) {
        ForEach(this.people, (item: Celebrity) => {
          Scroll() {
            Column() {

              /* --- 1. 顶部海报区 --- */
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r(`app.media.${item.image}`))
                  .width('100%')
                  .height('550')
                  .objectFit(ImageFit.Cover)
                  .translate({ y: this.scrollOffset * 0.3 })

                // 名字区：解决白色文字在黑白照中看不清的问题
                Column() {
                  // 增加一个极淡的毛玻璃衬底
                  Column() {
                    Text(item.name)
                      .fontSize(48)
                      .fontWeight(FontWeight.Bolder)
                      .fontColor('#1A1A1A') // 名字改用深黑

                    Text(item.years)
                      .fontSize(18)
                      .fontColor('#666666')
                      .margin({ top: 8 })
                  }
                  .padding({ left: 15, right: 25, top: 15, bottom: 15 })
                  .backgroundColor('rgba(255,255,255,0.85)') // 强力背景保护，无视图片颜色
                  .borderRadius({ topRight: 40 }) // 仅右上大圆角，增加设计感
                }
                .padding({ bottom: 30 }) // 压在最底部
              }
              .width('100%')
              .height(550)

              /* --- 2. 内容详情区 --- */
              Column() {
                Text("核心身份")
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ bottom: 15 })
                  .fontWeight(FontWeight.Medium)
                  .letterSpacing(2)

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.getIdentityArray(item.identity), (tag: string) => {
                    Text(tag)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#B22222')
                      .backgroundColor('#FDF2F2')
                      .padding({ left: 15, right: 15, top: 8, bottom: 8 })
                      .borderRadius(2)
                      .margin({ right: 12, bottom: 12 })
                      .border({ width: 0.5, color: 'rgba(178, 34, 34, 0.3)' })
                  }, (tag: string) => tag)
                }
                .margin({ bottom: 30 })

                // 简介部分
                Stack({ alignContent: Alignment.TopStart }) {
                  Text(item.name.charAt(0))
                    .fontSize(120)
                    .fontColor('#0A000000')
                    .fontWeight(FontWeight.Bolder)
                    .offset({ x: -20, y: -40 })

                  this.buildDescription(item.description)
                }
                .margin({ bottom: 45 })

                Text("代表成就 / 作品")
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .margin({ bottom: 20 })

                Column() {
                  ForEach(this.getWorksArray(item.works), (work: string) => {
                    Row() {
                      Rect().width(6).height(6).fill('#1A1A1A').margin({ right: 12 })
                      Text(work)
                        .fontSize(16)
                        .fontColor('#444444')
                    }
                    .margin({ bottom: 15 })
                    .width('100%')
                  }, (work: string) => work)
                }
                .margin({ bottom: 100 })
              }
              .width('100%')
              .backgroundColor('#FAFAF8')
              .padding(30)
              .offset({ y: -30 })
            }
          }
          .scrollBar(BarState.Off)
          .onScroll((x: number, y: number) => {
            this.scrollOffset = Math.min(y, 150)
          })
          .width('100%')
          .height('100%')
        }, (item: Celebrity) => item.id.toString())
      }
      .indicator(false)
      .loop(true)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor(['#000000'])
          .onClick(() => {
            router.back({ url: 'pages/Index' })
          })

        Text(`${this.currentCity}城市人物志`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .margin({ left: 12 })
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Button('城市印象')
          .fontSize(16)
          .opacity(0.85)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#B22222')
          .height(42) // 加高按钮
          .padding({ left: 20, right: 20 })
          .borderRadius(22.5) // 圆角同步
          .offset({ y: -1.5 }) // 视觉上移，增加动感
          .borderRadius(24)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#D32F2F', 0.0], ['#B22222', 0.5], ['#8B0000', 1.0]]
          })
          .border({ width: 0.5, color: 'rgba(255,255,255,0.3)' })
          .shadow({
            radius: 15,
            color: 'rgba(178, 34, 34, 0.4)',
            offsetY: 6
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10 })
      .backgroundColor('rgba(250,250,248,0.8)') // 顶部导航加一层毛玻璃
      .backdropBlur(10)
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAF8')
  }
  onBackPress() {
    router.back({
      url: 'pages/Index'
    })
    return true;
  }
}