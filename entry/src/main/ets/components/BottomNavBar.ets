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

      // 2. 中间发布按钮 (保留你的样式逻辑，仅修改点击动作)
      Column() {
        Stack() {
          Circle()
            .width(43)
            .height(43)
            .fill('#007DFF')
            .shadow({ radius: 5, color: '#20000000', offsetY: 2 })

          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(22)
            .fontColor([Color.White])
        }
        .onClick(() => {
          // 关键修改：直接跳转，不改 currentIndex，防止 UI 变乱
          try {
            router.pushUrl({ url: 'pages/circle/PostDynamicView' })
          } catch (err) {
            console.error(`跳转失败: ${err.code}`)
          }
        })
        .margin({ bottom: 15 })
      }
      .layoutWeight(1)

      // 3. 导览
      this.TabItem(3, '导览', $r('app.media.ic_guide'), $r('app.media.ic_guide_active'))

      // 4. 我的
      this.TabItem(4, '我的', $r('app.media.ic_mine'), $r('app.media.ic_mine_active'))
    }
    .width('100%')
    .height(70)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 10, color: '#10000000', offsetY: -2 })
  }

  @Builder
  TabItem(index: number, label: string, icon: Resource, iconActive: Resource) {
    Column() {
      Image(this.currentIndex === index ? iconActive : icon)
        .width(24)
        .height(24)
      Text(label)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}