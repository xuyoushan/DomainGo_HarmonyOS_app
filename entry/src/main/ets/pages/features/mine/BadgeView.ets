import router from '@ohos.router';

interface BadgeInfo {
  name: string;
  icon: Resource;
  description: string;
  requirement: string;
  isUnlocked: boolean;
}

@Entry
@Component
struct BadgePage {
  @State badges: BadgeInfo[] = [
    { name: '探险家', icon: $r('app.media.ic_explore'), description: '初步探索寻域世界', requirement: '累计发布 1 篇足迹帖子', isUnlocked: true },
    { name: '活地图', icon: $r('app.media.ic_guide'), description: '对周边环境了如指掌', requirement: '累计记录 50 个地理位置', isUnlocked: true },
    { name: '社交王', icon: $r('app.media.ic_circle'), description: '社区活跃分子', requirement: '获得 100 次点赞', isUnlocked: false },
    { name: '原住民', icon: $r('app.media.ic_mine'), description: '长期守护这片领域', requirement: '连续登录 30 天', isUnlocked: false },
    { name: '摄影师', icon: $r('sys.symbol.camera_fill'), description: '发现身边的美', requirement: '发布帖子包含 50 张图片', isUnlocked: false },
    { name: '收藏家', icon: $r('sys.symbol.star_fill'), description: '博采众长', requirement: '收藏 20 篇深度好文', isUnlocked: false }
  ]

  build() {
    Column() {
      // 沉浸式头部
      Stack({ alignContent: Alignment.TopStart }) {
        Rect()
          .width('100%')
          .height(200)
          .fill('#1A1A1A')
          .linearGradient({
            angle: 160,
            colors: [['#2C2C2C', 0.0], ['#000000', 1.0]]
          })

        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#FFFFFF'])
              .onClick(() => router.back())
            Text('荣誉勋章')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ left: 15 })
          }
          .margin({ top: 50, left: 20 })

          Row() {
            Column() {
              Text('成就等级')
                .fontSize(14)
                .fontColor('#99FFFFFF')
              Text('领域先锋 LV.3') // 这里的先锋是一个段位概念
                .fontSize(26)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#FFD700')
                .margin({ top: 5 })
            }.alignItems(HorizontalAlign.Start)

            Blank()

            // 进度环示意
            Stack() {
              Progress({ value: 2, total: 6, type: ProgressType.Ring })
                .width(60).height(60).color('#FFD700').style({ strokeWidth: 5 })
              Text('2/6').fontSize(12).fontColor('#FFFFFF')
            }
          }
          .width('90%')
          .margin({ top: 30, left: 20 })
        }
      }
      .width('100%')

      // 勋章列表
      Grid() {
        ForEach(this.badges, (item: BadgeInfo) => {
          GridItem() {
            this.BadgeItemCard(item)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(15)
      .rowsGap(15)
      .padding(15)
      .margin({ top: -30 }) // 向上提一点，压在黑色背景上
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  BadgeItemCard(item: BadgeInfo) {
    Column() {
      Image(item.icon)
        .width(60)
        .height(60)
        .grayscale(item.isUnlocked ? 0 : 1)
        .opacity(item.isUnlocked ? 1 : 0.3)
        .margin({ bottom: 12 })

      Text(item.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.isUnlocked ? '#1A1A1A' : '#999999')

      Text(item.isUnlocked ? '点击查看' : '尚未获得')
        .fontSize(12)
        .fontColor(item.isUnlocked ? '#007DFF' : '#BBBBBB')
        .margin({ top: 5 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 10, color: '#0A000000', offsetY: 5 })
  }
}