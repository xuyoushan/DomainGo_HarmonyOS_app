// 1. 更新数据结构，支持两种状态的资源
interface TabItemInfo {
  icon: Resource;       // 默认图标
  iconActive: Resource; // 选中状态图标
  label: string;
  index: number;
}

@Component
export struct BottomNavBar {
  @Link currentIndex: number;

  // 2. 严格匹配你的 media 目录文件名
  private tabItems: TabItemInfo[] = [
    {
      icon: $r('app.media.ic_explore'),
      iconActive: $r('app.media.ic_explore_active'),
      label: '探索',
      index: 0
    },
    {
      icon: $r('app.media.ic_circle'),
      iconActive: $r('app.media.ic_circle_active'),
      label: '圈子',
      index: 1
    },
    {
      icon: $r('app.media.ic_guide'),
      iconActive: $r('app.media.ic_guide_active'),
      label: '导览',
      index: 3
    },
    {
      icon: $r('app.media.ic_mine'),
      iconActive: $r('app.media.ic_mine_active'),
      label: '我的',
      index: 4
    }
  ];

  build() {
    Row() {
      // 0: 探索
      this.TabItem(this.tabItems[0])
      // 1: 圈子
      this.TabItem(this.tabItems[1])

      // 2: 中间发布按钮 (保持你满意的 43vp 逻辑与动画)
      Column() {
        Stack() {
          Circle()
            .width(43)
            .height(43)
            .fill('#007DFF')
            .shadow(this.currentIndex === 2 ?
              { radius: 15, color: '#80007DFF', offsetY: 4 } :
              { radius: 5, color: '#20000000', offsetY: 2 })

          SymbolGlyph($r('sys.symbol.plus'))
            .fontSize(22)
            .fontColor([Color.White])
            .rotate({ angle: this.currentIndex === 2 ? 45 : 0 })
            .animation({ duration: 300, curve: Curve.EaseOut })
        }
        .scale({
          x: this.currentIndex === 2 ? 1.15 : 1.0,
          y: this.currentIndex === 2 ? 1.15 : 1.0
        })
        .animation({ duration: 250, curve: Curve.Friction })
        .onClick(() => {
          this.currentIndex = 2;
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

  // 3. 修改 TabItem 渲染逻辑，从 SymbolGlyph 切换为 Image
  @Builder
  TabItem(item: TabItemInfo) {
    Column() {
      // 根据 currentIndex 状态切换对应的 SVG 图片
      Image(this.currentIndex === item.index ? item.iconActive : item.icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      // 注意：如果是直接更换不同设计的 SVG，通常不需要 fillColor 覆盖
      // 如果想保留全局蓝色基调，也可以取消下面这一行的注释
      // .fillColor(this.currentIndex === item.index ? '#007DFF' : '#666666')

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