import router from '@ohos.router';

@Entry
@Component
struct TraceDetailView {
  private scroller: Scroller = new Scroller()

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 1. 底层：沉浸式地图
      Image($r('app.media.map_china_tech'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 2. 顶层内容
      Column() {
        // 自定义导航栏：增加背景渐变确保返回键清晰
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
            .textShadow({ radius: 5, color: '#FF000000' }) // 增加文字阴影

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
            // A. 探索成就卡片 (已增强对比度)
            this.AchievementCard()

            // B. 时光足迹流 (已增强对比度)
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

  // A. 增强版成就卡片
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

      Text('你已经探索了成都市 40% 的区域，击败了 85% 的用户！')
        .fontSize(14)
        .fontColor('#FFFFFF') // 强化为纯白
        .lineHeight(22)
        .fontWeight(FontWeight.Medium)
    }
    .width('92%')
    .padding(25)
    .margin({ top: 320 }) // 留出顶部地图视野
    .backgroundColor('#F21A1A1A') // 接近实色的深色背景，确保文字可读
    .borderRadius(20)
    .border({ width: 1, color: '#40FFFFFF' }) // 强化边框感
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
        .fontColor('#CCFFFFFF') // 稍微调亮辅助文字
        .margin({ top: 4 })
    }
  }

  // B. 增强版时光足迹流
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
          // 时间轴线
          Column() {
            Circle({ width: 12, height: 12 }).fill('#007DFF')
            Rect({ width: 2, height: 120 }).fill('#40FFFFFF')
          }
          .margin({ right: 15 })

          // 增强版足迹卡片
          Column() {
            Text('2025年12月' + item + '日')
              .fontSize(14)
              .fontColor('#CCFFFFFF')

            Text(item === 1 ? '锦江区 · 寻域探索' : '武侯区 · 完成导览')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 8 })

            // 占位图区
            Rect()
              .width('100%')
              .height(100)
              .fill('#33FFFFFF')
              .borderRadius(12)
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .padding(18)
          .backgroundColor('#F21A1A1A') // 同样使用高浓度背景
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