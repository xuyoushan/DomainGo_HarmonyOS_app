import router from '@ohos.router';

@Component
export struct CircleView {
  @State currentIndex: number = 1
  @State isRefreshing: boolean = false
  // --- 大图预览相关状态 ---
  @State showBigImage: boolean = false
  @State currentPreviewImg: Resource = $r('app.media.map_china_tech')

  private controller: TabsController = new TabsController()

  build() {
    // 使用 Stack 容器以便弹出全屏预览层
    Stack() {
      Column() {
        // 1. 顶部：搜索栏 + 消息中心
        this.TopSearchSection()

        // 2. 内容区：Tabs 切换
        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('关注', 0))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('发现', 1))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('同城', 2))
        }
        .vertical(false)
        .barHeight(50)
        .onChange((index: number) => { this.currentIndex = index })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')

      // 3. 全屏大图预览遮罩层
      if (this.showBigImage) {
        Column() {
          Image(this.currentPreviewImg)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#CC000000') // 半透明黑色背景
        .zIndex(999)
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
        .onClick(() => {
          this.showBigImage = false // 点击背景退出预览
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopSearchSection() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(18).fontColor(['#999999']).margin({ left: 12 })
        Text('搜索你感兴趣的领域...').fontSize(14).fontColor('#999999').margin({ left: 8 })
      }
      .layoutWeight(1).height(38).backgroundColor('#FFFFFF').borderRadius(19).margin({ right: 15 })

      Badge({ count: 3, style: { badgeSize: 16, badgeColor: '#FA2A2D' } }) {
        SymbolGlyph($r('sys.symbol.bell')).fontSize(26).fontColor(['#333333'])
      }
      .onClick(() => {
        router.pushUrl({ url: 'pages/circle/MessageCenterView' })
      })
    }
    .width('100%').padding({ left: 20, right: 20, top: 20, bottom: 5 })
  }

  @Builder
  TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .fontSize(this.currentIndex === index ? 18 : 16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
      Rect().width(20).height(3).fill('#007DFF').margin({ top: 4 })
        .opacity(this.currentIndex === index ? 1 : 0).borderRadius(1.5)
    }.width('100%').justifyContent(FlexAlign.Center)
  }

  @Builder
  SocialContentList() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ space: 15 }) {
        ForEach([1, 2, 3], (item: number) => {
          ListItem() { this.SocialCard(item) }
        })
      }
      .width('100%').padding({ left: 15, right: 15, bottom: 20 }).edgeEffect(EdgeEffect.Spring)
    }
    .onRefreshing(() => {
      setTimeout(() => { this.isRefreshing = false }, 2000)
    })
  }

  @Builder
  SocialCard(index: number) {
    Column() {
      // 1. 用户信息：点击头像或昵称进入对方主页
      Row() {
        Image($r('app.media.ic_mine_active'))
          .width(40).height(40).borderRadius(20)
          .onClick(() => { this.handleUserClick(index) })

        Column() {
          Text('探险家_' + index)
            .fontSize(16).fontWeight(FontWeight.Medium)
            .onClick(() => { this.handleUserClick(index) })
          Text('2小时前 · 成都').fontSize(12).fontColor('#999999').margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).margin({ left: 10 })

        Blank()
        Button('关注').fontSize(12).height(28).backgroundColor('#E6F2FF').fontColor('#007DFF')
      }
      .width('100%').padding(15)

      // 2. 动态图片：点击查看大图
      Image($r('app.media.map_china_tech'))
        .width('92%')
        .height(180)
        .borderRadius(12)
        .margin({ bottom: 10 })
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.currentPreviewImg = $r('app.media.map_china_tech')
          this.showBigImage = true
        })

      // 3. 内容文本：点击文字进入详情页
      Text('在寻域发现了一个超棒的角落！这里的足迹地图真的很精准，推荐大家来体验。 #寻域探索 #足迹')
        .fontSize(14).fontColor('#333333').lineHeight(20)
        .padding({ left: 15, right: 15, bottom: 15 })
        .onClick(() => { this.handlePostClick(index) })

      // 4. 底部交互
      Row() {
        this.InteractionIcon($r('sys.symbol.heart'), '128')
        this.InteractionIcon($r('sys.symbol.message'), '45')
        this.InteractionIcon($r('sys.symbol.map'), '查看地图')
      }
      .width('100%').padding({ left: 15, right: 15, bottom: 15 })
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor('#FFFFFF').borderRadius(16).width('100%')
    .shadow({ radius: 8, color: '#10000000', offsetY: 4 })
  }

  @Builder
  InteractionIcon(icon: Resource, text: string) {
    Row() {
      SymbolGlyph(icon).fontSize(18).fontColor(['#666666'])
      Text(text).fontSize(13).fontColor('#666666').margin({ left: 5 })
    }.margin({ right: 25 })
  }

  // --- 修改跳转逻辑 ---
  handleUserClick(id: number) {
    router.pushUrl({
      url: 'pages/mine/UserHomeView',
      params: { userId: id }
    })
  }

  handlePostClick(id: number) {
    router.pushUrl({
      url: 'pages/circle/PostDetailView',
      params: { postId: id }
    })
  }
}