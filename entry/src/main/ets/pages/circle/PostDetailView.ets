import router from '@ohos.router';
import { PostItem } from './CircleView'; // 导入接口定义

@Entry
@Component
struct PostDetailView {
  // 1. 动态获取传递过来的参数，若无则显示默认值
  @State postData: PostItem = (router.getParams() as Record<string, PostItem>)?.postData || {
    userName: '探险家_1',
    avatar: $r('app.media.ic_mine_active'),
    text: '加载中...',
    location: '',
    timestamp: Date.now(),
    images: [$r('app.media.map_china_tech')]
  };

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).onClick(() => router.back())
        Text('帖子正文').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 15 })
        Blank()
        SymbolGlyph($r('sys.symbol.share')).fontSize(24)
      }.width('100%').padding(15).backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 作者信息
          Row() {
            Image(this.postData.avatar).width(45).height(45).borderRadius(22.5)
            Column() {
              Text(this.postData.userName).fontSize(16).fontWeight(FontWeight.Medium)
              Text('发布于 ' + this.postData.location).fontSize(12).fontColor('#999999').margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start).margin({ left: 10 })
          }.width('100%').padding(15)

          // 正文 [核心修复：设置 alignItems 确保左对齐]
          Text(this.postData.text)
            .fontSize(16).lineHeight(26)
            .width('100%').textAlign(TextAlign.Start)
            .padding({ left: 15, right: 15, bottom: 15 })

          // 图片展示
          if (this.postData.images.length > 0) {
            Image(this.postData.images[0])
              .width('100%').objectFit(ImageFit.Contain).padding({ left: 15, right: 15 })
          }

          Divider().strokeWidth(8).color('#F1F3F5').margin({ top: 20 })

          // 评论区占位（保持居中）
          Column() {
            Text('全部评论 (0)').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
            SymbolGlyph($r('sys.symbol.message_badge_plus')).fontSize(50).fontColor(['#EEEEEE'])
            Text('还没有人评论，快来抢沙发吧').fontSize(12).fontColor('#CCCCCC').margin({ top: 10 })
          }.width('100%').padding(30).alignItems(HorizontalAlign.Center)
        }
        .alignItems(HorizontalAlign.Start) // 【关键】强制容器内所有元素左侧对齐
      }.layoutWeight(1)

      // 底部评论栏保持不变...
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}