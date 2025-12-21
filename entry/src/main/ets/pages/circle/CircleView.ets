@Component
export struct CircleView {
  build() {
    Column() {
      Text('社区圈子').fontSize(24).fontWeight(FontWeight.Bold).margin(20)

      List({ space: 12 }) {
        ForEach([1, 2, 3], (item: number) => {
          ListItem() {
            Column() {
              Row() {
                Circle().width(40).height(40).fill('#ccc') // 头像占位
                Text('旅行达人 ' + item).margin({ left: 10 })
              }.width('100%')

              Text('今天在锦江区发现了一个超级出片的打卡点！#成都旅行')
                .margin({ top: 10 }).fontSize(14)

              Rect().width('100%').height(150).fill('#f0f0f0').margin({ top: 10 }).borderRadius(8) // 图片占位
            }
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
        }, (item: number) => item.toString())
      }
      .width('94%')
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F1F3F5')
  }
}