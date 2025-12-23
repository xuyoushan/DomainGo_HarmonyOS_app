import router from '@ohos.router';

@Component
export struct BottomNavBar {
  @Link currentIndex: number;

  build() {
    Row() {
      // 0. 探索
      this.TabItem(0, '探索', $r('app.media.ic_explore'), $r('app.media.ic_explore_active'))

      // 1. 圈子
      this.TabItem(1, '圈子', $r('app.media.ic_circle'), $r('app.media.ic_circle_active'))

      // 2. 中间发布按钮
      Column() {
        Stack() {
          Circle()
            .width(43) // 稍微加大一点，防止 SymbolGlyph 边际裁剪
            .height(43)
            .fill('#007DFF')
            .shadow({ radius: 10, color: '#30007DFF', offsetY: 4 })

          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(28)
            .fontColor([Color.White])
        }
        // 关键修复：防止图标被切边
        .clip(false)
        .onClick(() => {
          router.pushUrl({ url: 'pages/circle/PostDynamicView' })
        })
        .margin({ bottom: 20 }) // 向上悬浮效果
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 3. 导览
      this.TabItem(3, '导览', $r('app.media.ic_guide'), $r('app.media.ic_guide_active'))

      // 4. 我的
      this.TabItem(4, '我的', $r('app.media.ic_mine'), $r('app.media.ic_mine_active'))
    }
    .width('100%')
    .height(65)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#EEEEEE' })
  }

  @Builder
  TabItem(index: number, label: string, icon: Resource, iconActive: Resource) {
    Column() {
      Image(this.currentIndex === index ? iconActive : icon)
        .width(26)
        .height(26)
        // 关键修复：解决图标左侧被削去一块的问题
        .objectFit(ImageFit.Contain)
      Text(label)
        .fontSize(10)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}