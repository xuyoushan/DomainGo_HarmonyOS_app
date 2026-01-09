@Component
export struct EmptyComponent {
  @Prop title: string = '暂无数据';
  @Prop subTitle: string = '换个城市或分类试试吧';
  @Prop imageRes: Resource = $r('sys.symbol.exclamationmark_and_minus_plus_batteryblock_stack'); // 使用系统图标或你的插画

  build() {
    Column() {
      // 1. 图标/插画区
      SymbolGlyph(this.imageRes)
        .fontSize(80)
        .fontColor(['#DBDBDB'])

      // 2. 主标题
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
        .margin({ top: 20 })

      // 3. 副标题
      Text(this.subTitle)
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 })

      // 4. 这里的 Slot (可选) 可以放一个刷新按钮
    }
    .width('100%')
    .height('60%') // 占据页面大半部分
    .justifyContent(FlexAlign.Center)
  }
}