@Component
export struct PostView {
  build() {
    Column({ space: 20 }) {
      Text('分享你的见闻').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 50 })

      TextArea({ placeholder: '记录这一刻的味道或风景...' })
        .height(200).width('90%').backgroundColor(Color.White)

      Button('发布')
        .width('80%').height(50).backgroundColor('#007DFF')
    }
    .width('100%').height('100%')
  }
}