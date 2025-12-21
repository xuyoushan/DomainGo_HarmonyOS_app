@Component
export struct MineView {
  build() {
    Column() {
      // 个人信息头部
      Column() {
        Image($r('sys.media.ohos_app_icon')).width(80).height(80).margin({ top: 50 })
        Text('未登录用户').fontSize(18).margin({ top: 10 }).fontWeight(FontWeight.Bold)
      }
      .width('100%').height(250).backgroundColor('#007DFF')

      // 功能列表
      List() {
        ListItem() { this.MenuEntry('我的足迹') }
        ListItem() { this.MenuEntry('收藏百科') }
        ListItem() { this.MenuEntry('设置') }
      }.backgroundColor(Color.White).margin({ top: -20 }).borderRadius(20)
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }

  @Builder MenuEntry(title: string) {
    Row() {
      Text(title)
      Blank()
      Text('>').fontColor('#ccc')
    }.width('100%').padding(20)
  }
}