import router from '@ohos.router';
import promptAction from '@ohos.promptAction'; // 必须导入
// 导入 PostItem 接口以便使用
import { PostItem } from '../../models/PostItem';
@Component
export struct MineView {
  scroller: Scroller = new Scroller()

  // 【功能4实现】：通过 StorageLink 绑定全局浏览历史，实现数字实时更新
  @StorageLink('browseHistory') history: PostItem[] = [];

  build() {
    Scroll(this.scroller) {
      Column() {
        // 1. 头部个人信息区（保持你的渐变和样式）
        Stack({ alignContent: Alignment.Bottom }) {
          Rect()
            .width('100%')
            .height(220)
            .fill('#007DFF')
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#007DFF', 0.0], ['#005BB7', 1.0]]
            })

          Column() {
            Image($r('app.media.ic_mine_active'))
              .width(85)
              .height(85)
              .borderRadius(42.5)
              .border({ width: 4, color: '#FFFFFF' })
              .backgroundColor('#FFFFFF')
              .objectFit(ImageFit.Contain)

            Text('DomainGo 用户')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 12 })

            Text('探索足迹：128公里 | 勋章：5枚')
              .fontSize(14)
              .fontColor('#E6FFFFFF')
              .margin({ top: 6, bottom: 30 })
          }
        }
        .width('100%')

        // 2. 基础功能列表（重绘：加入浏览历史数量显示）
        List() {
          ListItem() { this.MenuItem('我的足迹', $r('sys.symbol.map')) }

          ListItem() { this.MenuItem('我的收藏', $r('sys.symbol.star_fill')) }
          .onClick(() => { /* 跳转收藏页 */ })

          // 【功能4修改】：增加浏览历史点击和数量展示
          ListItem() {
            Row() {
              this.MenuItem('浏览历史', $r('sys.symbol.clock_fill'))
              // 显示当前历史记录的数量
              Text(this.history.length.toString())
                .fontSize(14)
                .fontColor('#999999')
                .margin({ right: 10 })
            }.width('100%')
          }
          .onClick(() => {
            // 这里可以跳转到专门的历史记录列表页
            promptAction.showToast({ message: '跳转至浏览历史' })
          })

          ListItem() { this.MenuItem('发布记录', $r('sys.symbol.square_and_pencil')) }
          ListItem() { this.MenuItem('系统设置', $r('sys.symbol.gearshape')) }
        }
        .width('92%')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .margin({ top: -25 })
        .padding({ left: 15, right: 15 })
        .divider({ strokeWidth: 1, color: '#F1F3F5', startMargin: 35 })
        .shadow({ radius: 15, color: '#15000000', offsetY: 8 })

        // 3. 我的勋章模块（完整保留）
        Column() {
          Row() {
            Text('我的勋章')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Blank()
            Text('全部勋章 >').fontSize(13).fontColor('#999999')
          }
          .width('92%')
          .margin({ top: 30, bottom: 15 })

          Scroll() {
            Row({ space: 20 }) {
              this.BadgeItem('探险家', $r('app.media.ic_explore'), true)
              this.BadgeItem('活地图', $r('app.media.ic_guide'), true)
              this.BadgeItem('社交王', $r('app.media.ic_circle'), false)
              this.BadgeItem('原住民', $r('app.media.ic_mine'), false)
            }
            .padding({ left: 15, right: 15 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }

        // 4. 足迹地图卡片（完整保留）
        Column() {
          Text('足迹地图')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('92%')
            .margin({ top: 30, bottom: 15 })

          Stack() {
            Image($r('app.media.map_china_tech'))
              .width('100%')
              .height(180)
              .borderRadius(20)
              .objectFit(ImageFit.Cover)

            Column()
              .width('100%')
              .height(180)
              .borderRadius(20)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [['#CC000000', 0.0], ['#00000000', 1.0]]
              })

            Row() {
              Column() {
                Text('我的寻域足迹')
                  .fontColor('#FFFFFF')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)

                Text('已点亮 12 个领域')
                  .fontColor('#E6FFFFFF')
                  .fontSize(14)
                  .margin({ top: 8 })

                Progress({ value: 40, total: 100, type: ProgressType.Capsule })
                  .width(120)
                  .height(6)
                  .color('#007DFF')
                  .margin({ top: 15 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 20 })

              Blank()

              SymbolGlyph($r('sys.symbol.mappin_and_rectangle'))
                .fontSize(45)
                .fontColor(['#40FFFFFF'])
                .margin({ right: 25 })
            }
            .width('100%')
          }
          .width('92%')
          .height(180)
          .shadow({ radius: 20, color: '#25000000', offsetY: 10 })
          .onClick(() => {
            try {
              router.pushUrl({ url: 'pages/mine/TraceDetailView' })
            } catch (err) {
              console.error(`pushUrl failed, code is ${err.code}, message is ${err.message}`);
            }
          })
        }

        Button('退出登录')
          .width('92%')
          .height(50)
          .margin({ top: 40, bottom: 40 })
          .backgroundColor('#FFF1F3')
          .fontColor('#FF4D4F')
          .borderRadius(12)

        Blank().height(80)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .scrollBar(BarState.Off)
  }

  @Builder
  MenuItem(title: string, icon: Resource) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(22)
        .fontColor(['#444444'])
      Text(title)
        .fontSize(16)
        .margin({ left: 12 })
        .layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor(['#BBBBBB'])
    }
    .width('100%')
    .height(58)
  }

  @Builder
  BadgeItem(name: string, icon: Resource, isUnlocked: boolean) {
    Column() {
      Stack() {
        Circle({ width: 60, height: 60 })
          .fill(isUnlocked ? '#E6F2FF' : '#F5F5F5')
        Image(icon)
          .width(32)
          .height(32)
          .grayscale(isUnlocked ? 0 : 1)
          .opacity(isUnlocked ? 1 : 0.4)
      }
      Text(name)
        .fontSize(12)
        .margin({ top: 8 })
        .fontColor(isUnlocked ? '#333333' : '#999999')
    }
  }
}