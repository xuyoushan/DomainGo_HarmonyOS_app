import router from '@ohos.router';

@Entry
@Component
struct UserHomeView {
  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 背景图
        Rect().width('100%').height(200).fill('#007DFF').opacity(0.8)

        // 返回按钮
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24).fontColor(['#FFFFFF'])
            .onClick(() => router.back())
        }.width('100%').padding(15).zIndex(2)

        // 个人信息卡片
        Column() {
          Image($r('app.media.ic_mine_active'))
            .width(80).height(80).borderRadius(40)
            .border({ width: 4, color: '#FFFFFF' })

          Text('探险家_1').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 10 })
          Text('寻域首席体验官 | 走遍中国每一角').fontSize(13).fontColor('#666666').margin({ top: 5 })

          Row() {
            this.CountItem('128', '关注')
            this.CountItem('3.5k', '粉丝')
            this.CountItem('1.2w', '获赞')
          }.margin({ top: 20 })
        }
        .width('90%').backgroundColor('#FFFFFF').borderRadius(20)
        .padding(20).margin({ top: 140 })
        .shadow({ radius: 10, color: '#20000000' })
      }

      Text('动态').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 30, left: 20 }).alignSelf(ItemAlign.Start)
      Divider().width(30).strokeWidth(3).color('#007DFF').margin({ left: 20, top: 5 }).alignSelf(ItemAlign.Start)

      // 列表展示该用户的动态
      List() {
        ListItem() {
          Text('暂无更多动态').width('100%').textAlign(TextAlign.Center).margin(50).fontColor('#CCCCCC')
        }
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F1F3F5')
  }

  @Builder CountItem(count: string, label: string) {
    Column() {
      Text(count).fontSize(18).fontWeight(FontWeight.Bold)
      Text(label).fontSize(12).fontColor('#999999').margin({ top: 2 })
    }.layoutWeight(1)
  }
}