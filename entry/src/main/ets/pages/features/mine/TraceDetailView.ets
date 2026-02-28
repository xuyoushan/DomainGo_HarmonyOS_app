import router from '@ohos.router';

@Entry
@Component
struct TraceDetailView {
  private scroller: Scroller = new Scroller()

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.map_china_tech'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor(['#FFFFFF'])
            .onClick(() => {
              router.back()
            })

          Text('足迹详情')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ left: 15 })
            .textShadow({ radius: 5, color: '#FF000000' })

          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 50, bottom: 20 })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#CC000000', 0.0], ['#00000000', 1.0]]
        })

        Scroll(this.scroller) {
          Column() {
            this.AchievementCard()

            this.TimeLineSection()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AchievementCard() {
    Column() {
      Text('探索数据总览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 20 })
        .textShadow({ radius: 2, color: '#000000' })

      Row() {
        this.StatItem('128 km', '累计足迹')
        this.StatItem('12', '点亮领域')
        this.StatItem('5', '获得勋章')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      Divider().color('#33FFFFFF').margin({ top: 20, bottom: 20 })

      Text('你已经探索了北京市 40% 的区域，击败了 85% 的用户！')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .lineHeight(22)
        .fontWeight(FontWeight.Medium)
    }
    .width('92%')
    .padding(25)
    .margin({ top: 320 })
    .backgroundColor('#F21A1A1A')
    .borderRadius(20)
    .border({ width: 1, color: '#40FFFFFF' })
  }

  @Builder
  StatItem(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
      Text(label)
        .fontSize(13)
        .fontColor('#CCFFFFFF')
        .margin({ top: 4 })
    }
  }

  @Builder
  TimeLineSection() {
    Column() {
      Text('时光足迹流')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('92%')
        .margin({ top: 30, bottom: 20 })
        .textShadow({ radius: 2, color: '#000000' })

      ForEach([1, 2, 3], (item: number) => {
        Row() {
          Column() {
            Circle({ width: 12, height: 12 }).fill('#007DFF')
            Rect({ width: 2, height: 120 }).fill('#40FFFFFF')
          }
          .margin({ right: 15 })

          Column() {
            Text('2025年12月' + item + '日')
              .fontSize(14)
              .fontColor('#CCFFFFFF')

            Text(item === 1 ? '锦江区 · 寻域探索' : '朝阳区 · 完成导览')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 8 })

            Rect()
              .width('100%')
              .height(100)
              .fill('#33FFFFFF')
              .borderRadius(12)
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .padding(18)
          .backgroundColor('#F21A1A1A')
          .borderRadius(18)
          .margin({ bottom: 20 })
          .border({ width: 1, color: '#20FFFFFF' })
          .alignItems(HorizontalAlign.Start)
        }
        .width('92%')
      })
    }
    .margin({ bottom: 50 })
  }
}