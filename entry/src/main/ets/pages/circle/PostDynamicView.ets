import router from '@ohos.router';

@Entry
@Component
struct PostDynamicView {
  @State postText: string = ''

  build() {
    Column() {
      // 1. 顶部操作栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => router.back())
        Blank()
        Button('发布')
          .width(70)
          .height(32)
          .fontSize(14)
          .backgroundColor(this.postText.length > 0 ? '#007DFF' : '#E6E6E6')
          .fontColor(this.postText.length > 0 ? '#FFFFFF' : '#999999')
          .enabled(this.postText.length > 0)
      }
      .width('100%')
      .padding(20)

      // 2. 文字输入区
      TextArea({ placeholder: '分享你点亮的领域和探索足迹...', text: this.postText })
        .width('92%')
        .height(150)
        .backgroundColor(Color.Transparent)
        .placeholderColor('#CCCCCC')
        .onChange((value: string) => {
          this.postText = value
        })

      // 3. 图片上传占位
      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(30)
            .fontColor(['#999999'])
          Text('添加图片').fontSize(12).fontColor('#999999').margin({ top: 5 })
        }
        .width(100)
        .height(100)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
      .width('92%')
      .margin({ top: 20 })

      // 4. 地理位置选择器
      Row() {
        SymbolGlyph($r('sys.symbol.location_north_up_right_fill'))
          .fontSize(18)
          .fontColor(['#007DFF'])
        Text('所在位置')
          .fontSize(16)
          .margin({ left: 10 })
        Blank()
        Text('成都·锦江区 >')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('92%')
      .padding({ top: 30, bottom: 15 })
      .border({ width: { bottom: 1 }, color: '#F1F3F5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}