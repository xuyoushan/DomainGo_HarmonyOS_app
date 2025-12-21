// 定义导航项的数据结构
interface TabItemInfo {
  icon: Resource;
  label: string;
  index: number;
}

@Component
export struct BottomNavBar {
  @Link currentIndex: number;

  // 这里的图标名称已修正为系统标准库图标
  private tabItems: TabItemInfo[] = [
    { icon: $r('sys.symbol.house'), label: '探索', index: 0 },
    { icon: $r('sys.symbol.message'), label: '圈子', index: 1 }, // 修正：改为 bubble_left
    { icon: $r('sys.symbol.map'), label: '导览', index: 3 },
    { icon: $r('sys.symbol.person'), label: '我的', index: 4 }
  ];

  build() {
    Row() {
      // 0: 探索
      this.TabItem(this.tabItems[0])
      // 1: 圈子
      this.TabItem(this.tabItems[1])

      // 2: 中间发布按钮 (加号)
      // BottomNavBar.ets 中间加号部分
      Column() {
        Stack() {
          Circle()
            .width(43) // 你的黄金比例 43vp
            .height(43)
            .fill('#007DFF')
            // 1. 动态阴影：选中时产生蓝色外发光，未选中时只有淡淡的阴影
            .shadow(this.currentIndex === 2 ?
              { radius: 15, color: '#80007DFF', offsetY: 4 } :
              { radius: 5, color: '#20000000', offsetY: 2 })

          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(22)
            .fontColor([Color.White])
            // 2. 图标旋转：选中时加号旋转 45 度变成“X”（可选，非常有动感）
            .rotate({ angle: this.currentIndex === 2 ? 45 : 0 })
            .animation({ duration: 300, curve: Curve.EaseOut })
        }
        // 3. 整体缩放：选中时按钮放大 1.15 倍，产生“浮起来”的视觉差
        .scale({
          x: this.currentIndex === 2 ? 1.15 : 1.0,
          y: this.currentIndex === 2 ? 1.15 : 1.0
        })
        // 4. 丝滑动画：让所有变化（缩放、阴影、旋转）都有过渡效果
        .animation({ duration: 250, curve: Curve.Friction })
        .onClick(() => {
          this.currentIndex = 2; //
        })
        .margin({ bottom: 15 })
      }
      .layoutWeight(1)

      // 3: 导览
      this.TabItem(this.tabItems[2])
      // 4: 我的
      this.TabItem(this.tabItems[3])
    }
    .width('100%')
    .height(65)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#EEEEEE' })
  }

  @Builder
  TabItem(item: TabItemInfo) {
    Column() {
      SymbolGlyph(item.icon)
        .fontSize(24)
        .fontColor(this.currentIndex === item.index ? ['#007DFF'] : ['#666666'])

      Text(item.label)
        .fontSize(12)
        .margin({ top: 4 })
        .fontColor(this.currentIndex === item.index ? '#007DFF' : '#666666')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = item.index;
    })
  }
}