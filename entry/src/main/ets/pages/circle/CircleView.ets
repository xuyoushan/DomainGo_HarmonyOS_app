import router from '@ohos.router';

// 1. 统一接口定义，消灭 Object Literal 报错
export interface PostItem {
  userName: string;
  avatar: Resource;
  text: string;
  location: string;
  timestamp: number;
  images: Resource[];
}

@Component
export struct CircleView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @State currentIndex: number = 1
  @State isRefreshing: boolean = false
  @State showBigImage: boolean = false
  @State currentPreviewImg: Resource = $r('app.media.map_china_tech')

  private controller: TabsController = new TabsController()

  // 时间转换工具
  getRelativeTime(time: number): string {
    const diff = (Date.now() - time) / 1000;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return `${Math.floor(diff / 60)}分钟前`;
    return new Date(time).toLocaleDateString();
  }

  build() {
    Stack() {
      Column() {
        // 顶部搜索和消息中心
        this.TopSearchSection()

        // 内容分栏
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

      // 全屏预览图层
      if (this.showBigImage) {
        Column() {
          Image(this.currentPreviewImg).width('100%').height('100%').objectFit(ImageFit.Contain)
        }
        .width('100%').height('100%').backgroundColor('#CC000000')
        .zIndex(999).onClick(() => { this.showBigImage = false })
      }
    }
  }

  // --- 修复功能：顶部搜索栏与消息铃铛 ---
  @Builder
  TopSearchSection() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(18).fontColor(['#999999']).margin({ left: 12 })
        Text('搜索你感兴趣的领域...').fontSize(14).fontColor('#999999').margin({ left: 8 })
      }
      .layoutWeight(1).height(38).backgroundColor('#FFFFFF').borderRadius(19).margin({ right: 15 })

      // 点击铃铛跳转消息中心
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
        // 渲染真实发布的数据
        ForEach(this.globalPosts, (item: PostItem) => {
          ListItem() { this.SocialCard(item) }
        })

        // 默认模拟数据
        ForEach([1, 2], (index: number) => {
          ListItem() {
            this.SocialCard({
              userName: '探险家_' + index,
              avatar: $r('app.media.ic_mine_active'),
              text: '欢迎来到寻域！点击右上角发布分享你的第一个足迹吧。',
              location: '武汉市',
              timestamp: Date.now() - 3600000,
              images: [$r('app.media.map_china_tech')]
            })
          }
        })
      }
      .width('100%').padding({ left: 15, right: 15, bottom: 20 }).edgeEffect(EdgeEffect.Spring)
    }
    .onRefreshing(() => {
      setTimeout(() => { this.isRefreshing = false }, 1000)
    })
  }

  @Builder
  SocialCard(data: PostItem) {
    Column() {
      // 1. 用户信息：修复点击进入主页
      Row() {
        Image(data.avatar)
          .width(40).height(40).borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/UserHomeView', params: { name: data.userName } })
          })

        Column() {
          Text(data.userName)
            .fontSize(16).fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/UserHomeView', params: { name: data.userName } })
            })
          Text(`${this.getRelativeTime(data.timestamp)} · ${data.location || this.currentCity}`)
            .fontSize(12).fontColor('#999999').margin({ top: 2 })
        }.alignItems(HorizontalAlign.Start).margin({ left: 10 })
      }.width('100%').padding(15)

      // 2. 动态大图：点击查看大图
      if (data.images && data.images.length > 0) {
        Image(data.images[0])
          .width('92%').height(180).borderRadius(12).margin({ bottom: 10 })
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            this.currentPreviewImg = data.images[0]
            this.showBigImage = true
          })
      }

      // 3. 正文文字：【修复左对齐】并跳转详情页
      Text(data.text)
        .fontSize(14).fontColor('#333333').lineHeight(20)
        .width('100%').textAlign(TextAlign.Start)
        .padding({ left: 15, right: 15, bottom: 15 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/circle/PostDetailView', params: { postData: data } })
        })

      // 4. 底部交互按钮
      Row() {
        this.InteractionIcon($r('sys.symbol.heart'), '赞')
        this.InteractionIcon($r('sys.symbol.message'), '评论')
        this.InteractionIcon($r('sys.symbol.map'), '地图')
      }
      .width('100%').padding({ left: 15, right: 15, bottom: 15 })
    }
    .backgroundColor('#FFFFFF').borderRadius(16).width('100%')
  }

  @Builder
  InteractionIcon(icon: Resource, text: string) {
    Row() {
      SymbolGlyph(icon).fontSize(18).fontColor(['#666666'])
      Text(text).fontSize(13).fontColor('#666666').margin({ left: 5 })
    }.margin({ right: 25 })
  }
}