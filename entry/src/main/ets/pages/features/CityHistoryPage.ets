import { router } from '@kit.ArkUI'
import { HistoryNode, CITY_EXPLORE_MAP } from '../../models/HistoryData'

@Entry
@Component
struct CityHistoryPage {
  private scroller: Scroller = new Scroller()
  @State currentCity: string = "北京"
  @State historyNodes: HistoryNode[] = []
  @State selectedIndex: number = 0
  private isManualScrolling: boolean = false // 防止点击跳转时左侧闪烁

  // 图片放大相关状态
  @State showFullImage: boolean = false
  @State activeImage: string = ""

  aboutToAppear() {
    // 1. 获取路由参数
    const params = router.getParams() as Record<string, string>
    console.info("【调试】收到的所有路由参数: " + JSON.stringify(params))

    // 2. 尝试从各种可能的 Key 中获取城市名 (多重补齐)
    let receivedCity = ""
    if (params) {
      receivedCity = params.cityName || params.city || params.currentCity || ""
    }

    // 3. 强制去掉“市”字或多余空格
    if (receivedCity) {
      this.currentCity = receivedCity.trim().replace("市", "")
    }

    // 4. 核心匹配逻辑
    let data = CITY_EXPLORE_MAP[this.currentCity]

    if (data && data.length > 0) {
      console.info("【调试】匹配成功，城市为: " + this.currentCity)
      this.historyNodes = JSON.parse(JSON.stringify(data))
    } else {
      console.warn("【调试】匹配失败，Key不存在: " + this.currentCity)
      this.currentCity = "北京"
      this.historyNodes = JSON.parse(JSON.stringify(CITY_EXPLORE_MAP["北京"]))
    }
  }

  build() {
    Stack() {
      // --- 1. 底层背景 ---
      Image($r('app.media.paper_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        /* --- 顶部导航栏 --- */
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(25)
            .fontColor(['#333'])
            .onClick(() => router.back())

          Text(`${this.currentCity} · 历史脉络`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 15 })
            .fontFamily('HarmonyOS Sans')

          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })

        Row() {
          /* --- 2. 左侧时间轴 --- */
          Stack({ alignContent: Alignment.Top }) {
            // 底层贯穿全屏的垂直背景淡色轴线
            Rect()
              .width(2)
              .height('100%')
              .fill('#D2C4B0')
              .position({ x: '50%', y: 0 })

            List({ space: 0 }) {
              ForEach(this.historyNodes, (item: HistoryNode, index: number) => {
                ListItem() {
                  Column() {
                    // ⭐ 使用 Stack 包裹轴线和圆圈，确保轴线在圆圈下方且位置正确
                    Stack({ alignContent: Alignment.Top }) {
                      // 每一段的动态轴线：连接“上一个节点”到“本节点”
                      if (index > 0) {
                        Rect()
                          .width(this.selectedIndex === index ? 4 : 2)
                          .height(130) // 这里的长度需要匹配 ListItem 的总高度(padding top+bottom)
                          .fill(this.selectedIndex === index ? '#007DFF' : '#D2C4B0')
                          .position({ x: this.selectedIndex === index ? 8 : 9, y: -110 }) // 向上延伸至上一个圆圈
                          .animation({ duration: 300 })
                      }

                      // 圆圈组合 (外白内蓝)
                      Stack() {
                        Circle({ width: 16, height: 16 })
                          .fill(Color.White)
                          .stroke(this.selectedIndex === index ? '#007DFF' : '#B8A181')
                          .strokeWidth(2)
                          .shadow({
                            radius: this.selectedIndex === index ? 10 : 0,
                            color: this.selectedIndex === index ? '#40007DFF' : Color.Transparent
                          })

                        Circle({ width: 8, height: 8 })
                          .fill(this.selectedIndex === index ? '#007DFF' : Color.Transparent)
                          .animation({ duration: 300 })
                      }
                      .width(20)
                      .height(20)
                      .zIndex(2) // 确保圆圈在轴线之上
                    }
                    .width(20)
                    .height(20)

                    Text(item.year)
                      .fontSize(11)
                      .fontColor('#000')
                      .margin({ top: 6 })

                    Text(item.era)
                      .fontSize(13)
                      .fontWeight(this.selectedIndex === index ? FontWeight.Bolder : FontWeight.Normal)
                      .fontColor(this.selectedIndex === index ? '#007DFF' : '#444')
                      .margin({ top: 2 })
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .padding({ top: 55, bottom: 55 }) // 增加上下间距，使轴感更强
                  .onClick(() => {
                    this.isManualScrolling = true
                    animateTo({ duration: 500, curve: Curve.FastOutSlowIn }, () => {
                      this.selectedIndex = index
                      this.scroller.scrollToIndex(index, true)
                    })
                    setTimeout(() => { this.isManualScrolling = false }, 550)
                  })
                }
              }, (item: HistoryNode) => item.id.toString())
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
          }
          .width('28%')
          .height('100%')

          /* --- 3. 右侧历史内容 (完整保留原有逻辑) --- */
          List({ scroller: this.scroller, space: 25 }) {
            ForEach(this.historyNodes, (item: HistoryNode, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Image($r(`app.media.${item.image}`))
                      .width(110)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                      .autoResize(true)
                  }
                  .width(110)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.activeImage = item.image
                    this.showFullImage = true
                  })

                  Column() {
                    Text(item.siteName)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#222')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(item.description)
                      .fontSize(14)
                      .fontColor('#555')
                      .lineHeight(22)
                      .margin({ top: 8 })
                      .maxLines(item.isExpanded ? 100 : 3)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row() {
                      Text(item.isExpanded ? "收起详情" : "查看全文")
                        .fontSize(12)
                        .fontColor('#007DFF')
                      SymbolGlyph(item.isExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
                        .fontSize(13)
                        .fontColor(['#007DFF'])
                        .margin({ left: 4 })
                    }
                    .margin({ top: 10 })
                  }
                  .layoutWeight(1)
                  .padding({ left: 12, right: 10, top: 5, bottom: 5 })
                  .alignItems(HorizontalAlign.Start)
                  .onClick(() => {
                    animateTo({ duration: 300, curve: Curve.Smooth }, () => {
                      item.isExpanded = !item.isExpanded
                      this.historyNodes = [...this.historyNodes]
                    })
                  })
                }
                .width('100%')
                .backgroundColor(this.selectedIndex === index ? 'rgba(255, 255, 255, 0.85)' : 'rgba(255, 255, 255, 0.65)')
                .backdropBlur(15)
                .borderRadius(12)
                .padding(10)
                .scale({
                  x: this.selectedIndex === index ? 1.05 : 1,
                  y: this.selectedIndex === index ? 1.05 : 1
                })
                .shadow({
                  radius: this.selectedIndex === index ? 25 : 15,
                  color: this.selectedIndex === index ? '#40007DFF' : '#15000000',
                  offsetY: 8
                })
                .animation({ duration: 350, curve: Curve.FastOutSlowIn })
              }
              .padding({ right: 20, bottom: 5 })
            }, (item: HistoryNode) => item.id.toString() + item.isExpanded.toString())
          }
          .layoutWeight(1)
          .height('100%')
          .onScrollIndex((start: number) => {
            if (!this.isManualScrolling) {
              this.selectedIndex = start
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      /* --- 4. 全屏图片查看器 --- */
      if (this.showFullImage) {
        ZoomImageView({
          imgRes: this.activeImage,
          isShow: $showFullImage
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

//独立的全屏缩放查看组件
@Component
struct ZoomImageView {
  @Prop imgRes: string
  @Link isShow: boolean

  @State scaleValue: number = 1
  @State pinchValue: number = 1
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State lastOffsetX: number = 0
  @State lastOffsetY: number = 0

  build() {
    Stack() {
      Rect()
        .width('100%')
        .height('100%')
        .fill('rgba(0,0,0,0.95)')
        .onClick(() => this.closeView())

      Image($r(`app.media.${this.imgRes}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.scaleValue, y: this.scaleValue })
        .offset({ x: this.offsetX, y: this.offsetY })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.scaleValue = this.pinchValue * event.scale
              })
              .onActionEnd(() => {
                if (this.scaleValue < 1) {
                  animateTo({ duration: 200 }, () => this.scaleValue = 1)
                }
                this.pinchValue = this.scaleValue
              }),
            PanGesture()
              .onActionUpdate((event: GestureEvent) => {
                if (this.scaleValue > 1) {
                  this.offsetX = this.lastOffsetX + event.offsetX
                  this.offsetY = this.lastOffsetY + event.offsetY
                }
              })
              .onActionEnd(() => {
                this.lastOffsetX = this.offsetX
                this.lastOffsetY = this.offsetY
              }),
            TapGesture({ count: 2 })
              .onAction(() => {
                animateTo({ duration: 300 }, () => {
                  if (this.scaleValue > 1) {
                    this.reset()
                  } else {
                    this.scaleValue = 2.5
                    this.pinchValue = 2.5
                  }
                })
              })
          )
        )

      Column() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(28)
          .fontColor([Color.White])
      }
      .padding(20)
      .position({ x: '85%', y: '2%' })
      .onClick(() => this.closeView())
    }
    .width('100%')
    .height('100%')
    .zIndex(100)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.combine(TransitionEffect.scale({ x: 0.9, y: 0.9 })),
      TransitionEffect.OPACITY
    ))
  }

  private reset() {
    this.scaleValue = 1
    this.pinchValue = 1
    this.offsetX = 0
    this.offsetY = 0
    this.lastOffsetX = 0
    this.lastOffsetY = 0
  }

  private closeView() {
    animateTo({ duration: 200 }, () => {
      this.isShow = false
    })
  }
}