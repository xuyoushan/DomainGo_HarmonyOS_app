import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';
import { postRepo } from '../../services/PostRepository';

@Component
export struct CircleView {
  @StorageLink('currentCity') currentCity: string = '定位中...';
  @StorageLink('currentProvince') currentProvince: string = '';
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @State currentIndex: number = 1
  @State isRefreshing: boolean = false
  @State showBigImage: boolean = false
  @State currentPreviewImg: ResourceStr = ''
  @State searchKey: string = ''
  @State timeRefreshTicker: number = 0;
  private timerId: number = -1;

  private controller: TabsController = new TabsController()

  formatLocation(data: PostItem): string {
    if (data.location && data.location.trim() !== '' &&
      data.location !== '选择位置' && data.location !== '定位中...') {
      return data.location;
    }
    if (this.currentProvince && this.currentProvince !== '' && this.currentProvince !== '未知省份') {
      return this.currentProvince;
    }
    return '未知地区 · 火星';
  }

  getRelativeTime(time: number, ticker: number): string {
    const now = Date.now();
    const diff = (now - time) / 1000;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return `${Math.floor(diff / 60)}分钟前`;
    if (diff < 8400) return `${Math.floor(diff / 3600)}小时前`;
    const date = new Date(time);
    return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
  }

  async aboutToAppear() {
    await postRepo.init(getContext(this));
    this.refreshData();

    this.timerId = setInterval(() => {
      this.timeRefreshTicker++;
    }, 58888);
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  async refreshData() {
    this.isRefreshing = true;
    try {
      await new Promise<void>(resolve => {setTimeout(() => {resolve();}, 1200);});
      const posts = await postRepo.fetchAllPosts();
      AppStorage.SetOrCreate('globalPostList', posts);
    } catch (e) {
      console.error("Fetch_Posts_Error: " + e);
    } finally {
      this.isRefreshing = false;
    }
  }

  addToHistory(post: PostItem) {
    let history = AppStorage.Get<PostItem[]>('browseHistory') || [];
    history = [post, ...history.filter(item => item.id !== post.id)];
    AppStorage.SetOrCreate('browseHistory', history.slice(0, 50));
  }

  async toggleLike(post: PostItem) {
    post.isLiked = !post.isLiked;
    post.likeCount += post.isLiked ? 1 : -1;
    AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
    await postRepo.updatePostStatus(post.id, post.isLiked, post.isCollected, post.likeCount);
  }

  async toggleCollect(post: PostItem) {
    post.isCollected = !post.isCollected;
    AppStorage.SetOrCreate('globalPostList', [...this.globalPosts]);
    await postRepo.updatePostStatus(post.id, post.isLiked, post.isCollected, post.likeCount);
    promptAction.showToast({
      message: post.isCollected ? '已添加到收藏' : '已取消收藏'
    });
  }

  build() {
    Stack() {
      Column() {
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

        // 分类页签
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

      if (this.showBigImage) {
        Stack() {
          Rect()
            .width('100%')
            .height('100%')
            .fill('#FF000000') // 纯黑背景
            .onClick(() => this.showBigImage = false)

          Image(this.currentPreviewImg)
            .width('100%')
            .objectFit(ImageFit.Contain)
            .onClick(() => this.showBigImage = false) // 点击图片本身也关闭
        }
        .width('100%')
        .height('100%')
        .zIndex(100) // 确保在最顶层
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
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
          (item: PostItem) => item.id + String(item.isLiked) + String(item.isCollected)
        )
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
    }
    .onRefreshing(() => {
      this.refreshData();
    })
  }

  @Builder SocialCard(data: PostItem) {
    Column() {
      Row() {
        Image(data.avatar)
          .width(45)
          .height(45)
          .borderRadius(22.5)
        Column() {
          Text(data.userName)
            .fontSize(16).fontWeight(FontWeight.Medium)
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            Text(`${this.getRelativeTime(data.timestamp, this.timeRefreshTicker)} · `)
              .fontSize(12).fontColor('#999999')
            Text(this.formatLocation(data))
              .fontSize(12).fontColor('#999999')
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 }).layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 15, bottom: 10 })

      if (data.images && data.images.length > 0) {
        Image(data.images[0])
          .width('92%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .margin({ bottom: 10 })
          .onClick(() => {
            this.currentPreviewImg = data.images[0]
            this.showBigImage = true
          })
      }

      Text(data.text)
        .fontSize(15)
        .fontColor('#333')
        .lineHeight(22)
        .width('100%')
        .padding({ left: 15, right: 15, bottom: 15 })
        .onClick(() => {
          this.addToHistory(data)
          router.pushUrl({
            url: 'pages/circle/PostDetailView',
            params: { postData: data }
          })
        })

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