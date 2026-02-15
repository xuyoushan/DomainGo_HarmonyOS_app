import router from '@ohos.router';

interface BadgeInfo {
  name: string;
  icon: Resource;
  description: string;
  requirement: string;
  isUnlocked: boolean;
}

@CustomDialog
struct BadgeDetailDialog {
  controller: CustomDialogController
  item: BadgeInfo | null = null

  build() {
    Column() {
      Image(this.item?.icon)
        .width(80)
        .height(80)
        .grayscale(this.item?.isUnlocked ? 0 : 1)
        .opacity(this.item?.isUnlocked ? 1 : 0.4)
        .margin({ bottom: 20 })

      Text(this.item?.name)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Text(this.item?.description)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 10, bottom: 20 })
        .textAlign(TextAlign.Center)

      Column() {
        Text('获得要求')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ bottom: 5 })
        Text(this.item?.requirement)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#F7F8FA')
      .borderRadius(12)

      Button(this.item?.isUnlocked ? '已达成' : '去完成')
        .width('100%')
        .height(45)
        .margin({ top: 25 })
        .backgroundColor(this.item?.isUnlocked ? '#FFD700' : '#007DFF')
        .fontColor(this.item?.isUnlocked ? '#1A1A1A' : '#FFFFFF')
        .onClick(() => {
          this.controller.close()
        })
    }
    .padding(25)
    .backgroundColor(Color.White)
    .borderRadius(24)
  }
}

@Entry
@Component
struct BadgePage {
  @State selectedBadge: BadgeInfo | null = null
  @State badges: BadgeInfo[] = [
    { name: '探险家', icon: $r('app.media.ic_explore'), description: '初步探索寻域世界，迈出勇敢的第一步', requirement: '累计发布 1 篇足迹帖子', isUnlocked: true },
    { name: '活地图', icon: $r('app.media.ic_guide'), description: '对周边环境了如指掌，你就是行走的指南针', requirement: '累计记录 50 个地理位置', isUnlocked: true },
    { name: '社交王', icon: $r('app.media.ic_circle'), description: '社区活跃分子，大家都很喜欢你的分享', requirement: '获得 100 次点赞', isUnlocked: false },
    { name: '原住民', icon: $r('app.media.ic_mine'), description: '长期守护这片领域，这里的每一寸土地都认识你', requirement: '连续登录 30 天', isUnlocked: false },
    { name: '摄影师', icon: $r('sys.symbol.camera_fill'), description: '发现身边的美，用镜头捕捉瞬间', requirement: '发布帖子包含 50 张图片', isUnlocked: false },
    { name: '收藏家', icon: $r('sys.symbol.star_fill'), description: '博采众长，拥有独到的审美眼光', requirement: '收藏 20 篇深度好文', isUnlocked: false }
  ]

  dialogController: CustomDialogController = new CustomDialogController({
    builder: BadgeDetailDialog({ item: this.selectedBadge }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  build() {
    Column() {
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
              Text('领域先锋 LV.3')
                .fontSize(26)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#FFD700')
                .margin({ top: 5 })
            }.alignItems(HorizontalAlign.Start)

            Blank()

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

      Grid() {
        ForEach(this.badges, (item: BadgeInfo) => {
          GridItem() {
            this.BadgeItemCard(item)
          }
          .onClick(() => {
            this.selectedBadge = item
            this.dialogController = new CustomDialogController({
              builder: BadgeDetailDialog({ item: item }),
              autoCancel: true,
              alignment: DialogAlignment.Center,
              customStyle: true
            })
            this.dialogController.open()
          })
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(15)
      .rowsGap(15)
      .padding(15)
      .margin({ top: -30 })
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