import router from '@ohos.router';

@Entry
@Component
struct PostDetailView {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .onClick(() => router.back())
        Text('帖子正文').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 15 })
        Blank()
        SymbolGlyph($r('sys.symbol.share')).fontSize(24)
      }
      .width('100%').padding(15).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 作者信息
          Row() {
            Image($r('app.media.ic_mine_active')).width(45).height(45).borderRadius(22.5)
            Column() {
              Text('探险家_1').fontSize(16).fontWeight(FontWeight.Medium)
              Text('2小时前发布').fontSize(12).fontColor('#999999').margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start).margin({ left: 10 })
          }.width('100%').padding(15)

          // 正文
          Text('在寻域发现了一个超棒的角落！这里的足迹地图真的很精准，推荐大家来体验。 #寻域探索 #足迹')
            .fontSize(16).lineHeight(24).padding({ left: 15, right: 15, bottom: 15 })

          // 大图
          Image($r('app.media.map_china_tech'))
            .width('100%').objectFit(ImageFit.Contain).padding({ left: 15, right: 15 })

          Divider().strokeWidth(8).color('#F1F3F5').margin({ top: 20 })

          // 评论区占位
          Column() {
            Text('全部评论 (0)').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
            SymbolGlyph($r('sys.symbol.message_badge_plus')).fontSize(50).fontColor(['#EEEEEE'])
            Text('还没有人评论，快来抢沙发吧').fontSize(12).fontColor('#CCCCCC').margin({ top: 10 })
          }.width('100%').padding(30).alignItems(HorizontalAlign.Center)
        }
      }.layoutWeight(1)

      // 底部评论栏
      Row() {
        Row() {
          Text('说点什么...').fontSize(14).fontColor('#999999').margin({ left: 15 })
        }
        .layoutWeight(1).height(40).backgroundColor('#F1F3F5').borderRadius(20)

        SymbolGlyph($r('sys.symbol.heart')).fontSize(24).margin({ left: 20 })
        SymbolGlyph($r('sys.symbol.star')).fontSize(24).margin({ left: 20 })
      }.width('100%').padding(10).backgroundColor('#FFFFFF')
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}