@Component
export struct GuideView {
  build() {
    Stack() {
      // 模拟地图背景
      Rect().width('100%').height('100%').fill('#E8F0F5')

      Column() {
        Search({ placeholder: '查找附近的讲解点...' }).width('90%').margin(20)
        Blank()
        // 底部线路卡片预览
        Row() {
          Text('推荐路线：锦江历史文化游').fontWeight(FontWeight.Bold)
          Button('开始导览').fontSize(12).padding(8)
        }
        .width('90%').padding(15).backgroundColor(Color.White)
        .borderRadius(15).margin({ bottom: 30 }).justifyContent(FlexAlign.SpaceBetween)
      }.width('100%').height('100%')
    }
  }
}