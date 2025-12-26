import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';

@Component
export struct CircleView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];

  @State currentIndex: number = 1
  @State isRefreshing: boolean = false
  @State showBigImage: boolean = false
  @State currentPreviewImg: ResourceStr = $r('app.media.map_china_tech')
  @State searchKey: string = ''

  // 【功能保留】时间强制刷新哨兵
  @State timeRefreshTicker: number = 0;
  private timerId: number = -1;

  private controller: TabsController = new TabsController()

  // 【功能保留】更精准的时间转换逻辑
  getRelativeTime(time: number, ticker: number): string {
    const now = Date.now();
    const diff = (now - time) / 1000;
    if (diff < 60) {
      return '刚刚';
    } else if (diff < 3600) {
      return `${Math.floor(diff / 60)}分钟前`;
    } else if (diff < 86400) {
      return `${Math.floor(diff / 3600)}小时前`;
    }
    const date = new Date(time);
    return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
  }

  // 【功能保留】生命周期管理心跳定时器
  aboutToAppear() {
    this.timerId = setInterval(() => {
      this.timeRefreshTicker++;
    }, 60000);
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  // 【功能保留】浏览历史记录逻辑
  addToHistory(post: PostItem) {
    let history = AppStorage.Get<PostItem[]>('browseHistory') || [];
    history = [post, ...history.filter(item => item.id !== post.id)];
    AppStorage.SetOrCreate('browseHistory', history.slice(0, 50));
  }

  // 【功能保留】点赞切换
  toggleLike(post: PostItem) {
    post.isLiked = !post.isLiked;
    post.likeCount += post.isLiked ? 1 : -1;
    AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
  }

  // 【功能保留】收藏切换
  toggleCollect(post: PostItem) {
    post.isCollected = !post.isCollected;
    AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
    promptAction.showToast({
      message: post.isCollected ? '已添加到收藏' : '已取消收藏'
    });
  }

  build() {
    Stack() {
      Column() {
        // 【功能保留】顶部搜索区域
        Row() {
          Search({ placeholder: '搜索动态...', value: this.searchKey })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F1F3F5')
            .onChange(v => this.searchKey = v)

          SymbolGlyph($r('sys.symbol.bell'))
            .fontSize(24)
            .margin({ left: 15 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/circle/MessageCenterView' })
            })
        }
        .width('100%')
        .padding(15)

        // 【功能保留】分类页签
        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('关注', 0))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('推荐', 1))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('同城', 2))
        }
        .layoutWeight(1)
        .onChange(i => this.currentIndex = i)
      }
      .width('100%')
      .height('100%')

      // 【功能保留】大图预览层
      if (this.showBigImage) {
        Stack() {
          Rect()
            .width('100%')
            .height('100%')
            .fill('#CC000000')
            .onClick(() => this.showBigImage = false)

          Image(this.currentPreviewImg)
            .width('100%')
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height('100%')
        .zIndex(10)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .fontSize(this.currentIndex === index ? 16 : 14)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
      if (this.currentIndex === index) {
        Rect().width(20).height(2).fill('#007DFF').margin({ top: 4 })
      }
    }
  }

  @Builder
  SocialContentList() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(
          this.globalPosts.filter(item =>
          item && (item.text.includes(this.searchKey) || item.userName.includes(this.searchKey))
          ),
          (item: PostItem) => {
            ListItem() {
              if (item && item.id) {
                this.SocialCard(item)
              }
            }
          },
          (item: PostItem) => item.id + String(item.isLiked) + String(item.isCollected) + this.timeRefreshTicker.toString()
        )
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
    }
    .onRefreshing(() => {
      setTimeout(() => this.isRefreshing = false, 1500)
    })
  }

  @Builder
  SocialCard(data: PostItem) {
    Column() {
      // 1. 头像与用户信息 (保留 timeRefreshTicker 联动)
      Row() {
        Image(data.avatar)
          .width(45)
          .height(45)
          .borderRadius(22.5)

        Column() {
          Text(data.userName).fontSize(16).fontWeight(FontWeight.Medium)
          Text(`${this.getRelativeTime(data.timestamp, this.timeRefreshTicker)} · ${data.location || this.currentCity}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 15, bottom: 10 })

      // 【核心修复：图片展示逻辑】
      // 不再使用 ForEach 循环所有图片，而是只显示 data.images[0]
      if (data.images && data.images.length > 0) {
        Image(data.images[0])
          .width('92%')
          .height(200) // 设定统一的封面高度
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .margin({ bottom: 10 })
          .onClick(() => {
            // 点击封面图查看大图
            this.currentPreviewImg = data.images[0]
            this.showBigImage = true
          })
      }

      // 3. 动态文本与跳转 (保留历史记录逻辑)
      Text(data.text)
        .fontSize(15)
        .fontColor('#333')
        .lineHeight(22)
        .width('100%')
        .padding({ left: 15, right: 15, bottom: 15 })
        .onClick(() => {
          this.addToHistory(data) // 历史记录功能
          router.pushUrl({
            url: 'pages/circle/PostDetailView',
            params: { postData: data }
          })
        })

      // 4. 底部交互区 (点赞、收藏、评论 100% 完整保留)
      Row() {
        Row() {
          this.InteractionIcon(
            data.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
            data.likeCount.toString(),
            data.isLiked ? '#FF4D4F' : '#666666'
          )
        }.onClick(() => this.toggleLike(data))

        Row() {
          this.InteractionIcon(
            data.isCollected ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
            data.isCollected ? '已收藏' : '收藏',
            data.isCollected ? '#FFAD14' : '#666666'
          )
        }.onClick(() => this.toggleCollect(data))

        Row() {
          this.InteractionIcon(
            $r('sys.symbol.message'),
            (data.comments && data.comments.length > 0) ? data.comments.length.toString() : '评论')
        }.onClick(() => {
          router.pushUrl({
            url: 'pages/circle/PostDetailView',
            params: { postData: data }
          })
        })
      }
      .width('100%')
      .padding({ left: 15, right: 15, bottom: 15 })
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 10, right: 10, top: 5, bottom: 5 })
  }

  @Builder
  InteractionIcon(icon: Resource, text: string, color: string = '#666666') {
    Row() {
      SymbolGlyph(icon)
        .fontSize(18)
        .fontColor([color])

      Text(text)
        .fontSize(13)
        .fontColor(color)
        .margin({ left: 5 })
    }
    .margin({ right: 25 })
  }
}