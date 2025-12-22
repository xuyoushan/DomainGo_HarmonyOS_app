import router from '@ohos.router';
@Component
export struct CircleView {
  @State currentIndex: number = 1 // 默认选中“发现”
  private controller: TabsController = new TabsController()

  build() {
    Column() {
      // --- 1. 顶部：搜索栏 + 标签切换 ---
      this.TopSearchSection()

      // --- 2. 内容区：Tabs 切换 ---
      Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          this.SocialContentList('关注内容区域')
        }.tabBar(this.TabBuilder('关注', 0))

        TabContent() {
          this.SocialContentList('发现精彩领域')
        }.tabBar(this.TabBuilder('发现', 1))

        TabContent() {
          this.SocialContentList('同城热门')
        }.tabBar(this.TabBuilder('同城', 2))
      }
      .vertical(false)
      .barHeight(50)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // 顶部搜索组件
  @Builder
  TopSearchSection() {
    Row() {
      // 搜索框容器
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(18)
          .fontColor(['#999999'])
          .margin({ left: 12 })

        Text('搜索你感兴趣的领域...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .height(38)
      .backgroundColor('#FFFFFF')
      .borderRadius(19)
      .margin({ right: 15 })

      // 发布按钮：点击跳转到发布页
      SymbolGlyph($r('sys.symbol.plus_circle_fill'))
        .fontSize(28)
        .fontColor(['#007DFF'])
        .onClick(() => {
          try {
            router.pushUrl({
              url: 'pages/circle/PostDynamicView'
            })
          } catch (err) {
            console.error(`fail to route: ${err.code}`);
          }
        })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 5
    })
  }

  // 2. 自定义 TabBar 样式
  @Builder
  TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .fontSize(this.currentIndex === index ? 18 : 16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)

      // 选中指示线
      Rect()
        .width(20)
        .height(3)
        .fill('#007DFF')
        .margin({ top: 4 })
        .opacity(this.currentIndex === index ? 1 : 0)
        .borderRadius(1.5)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 3. 动态列表容器
  @Builder
  SocialContentList(placeholder: string) {
    List({ space: 15 }) {
      ListItem() {
        Text(placeholder)
          .fontSize(12)
          .fontColor('#CCCCCC')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 10, bottom: -5 })
      }

      // 模拟 3 条动态数据
      ForEach([1, 2, 3], (item: number) => {
        ListItem() {
          this.SocialCard(item)
        }
      })
    }
    .width('100%')
    .padding({ left: 15, right: 15, bottom: 20 })
    .edgeEffect(EdgeEffect.Spring)
  }

  // 4. 核心社交卡片
  @Builder
  SocialCard(index: number) {
    Column() {
      // 用户信息栏
      Row() {
        Image($r('app.media.ic_mine_active'))
          .width(40)
          .height(40)
          .borderRadius(20)
        Column() {
          Text('探险家_' + index)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text('2小时前 · 成都')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })

        Blank()

        Button('关注')
          .fontSize(12)
          .height(28)
          .backgroundColor('#E6F2FF')
          .fontColor('#007DFF')
      }
      .width('100%')
      .padding(15)

      // 动态图片预览
      Rect()
        .width('92%')
        .height(180)
        .fill('#F5F5F5')
        .borderRadius(12)
        .margin({ bottom: 10 })

      // 内容文本
      Text('在寻域发现了一个超棒的角落！这里的足迹地图真的很精准，推荐大家来体验。 #寻域探索 #足迹')
        .fontSize(14)
        .fontColor('#333333')
        .lineHeight(20)
        .padding({ left: 15, right: 15, bottom: 15 })

      // 底部交互按钮
      Row() {
        this.InteractionIcon($r('sys.symbol.heart'), '128')
        this.InteractionIcon($r('sys.symbol.message'), '45')
        this.InteractionIcon($r('sys.symbol.map'), '查看地图')
      }
      .width('100%')
      .padding({ left: 15, right: 15, bottom: 15 })
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .width('100%')
    .shadow({ radius: 8, color: '#10000000', offsetY: 4 })
  }

  // 5. 交互图标小组件
  @Builder
  InteractionIcon(icon: Resource, text: string) {
    Row() {
      SymbolGlyph(icon)
        .fontSize(18)
        .fontColor(['#666666'])
      Text(text)
        .fontSize(13)
        .fontColor('#666666')
        .margin({ left: 5 })
    }
    .margin({ right: 25 })
  }
}