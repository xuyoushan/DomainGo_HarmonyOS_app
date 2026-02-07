import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';
import { postRepo } from '../../services/PostRepository';

// 定义通知消息接口
interface MessageNotification {
  id: string;
  type: string; // 'like' | 'collect' | 'follow' | 'comment'
  fromUserName: string;
  fromAvatar: ResourceStr;
  targetContent: string;
  timestamp: number;
}

@Component
export struct CircleView {
  @StorageLink('currentCity') currentCity: string = '定位中...';
  @StorageLink('currentProvince') currentProvince: string = '';
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @StorageLink('followingList') followingList: string[] = [];
  @StorageLink('unreadMessages') unreadMessages: MessageNotification[] = [];
  // 【新增】账号隔离关键变量
  @StorageLink('currentUserId') currentUserId: string = '';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;

  @State currentIndex: number = 1;
  @State isRefreshing: boolean = false;
  @State showBigImage: boolean = false;
  @State currentPreviewImg: ResourceStr = '';
  @State searchKey: string = '';
  @State timeRefreshTicker: number = 0;
  private timerId: number = -1;

  private controller: TabsController = new TabsController();

  // --- 【新增】小红书式交互拦截器 ---
  checkAuthAndExecute(action: () => void): void {
    if (!this.isLoggedIn || this.currentUserId === '') {
      promptAction.showToast({ message: '请先登录探索更多精彩' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return;
    }
    action();
  }

  sendNotification(post: PostItem | null, type: string, targetUserId: string = ''): void {
    const currentName: string = AppStorage.Get<string>('userName') || '某个探险家';
    const currentAvatar: Resource = $r('app.media.start');

    let receiverId: string = '';
    if (type === 'follow') {
      receiverId = targetUserId;
    } else if (post !== null) {
      receiverId = post.userId;
    }

    if (receiverId !== '' && receiverId !== this.currentUserId) {
      const newMsg: MessageNotification = {
        id: Date.now().toString(),
        type: type,
        fromUserName: currentName,
        fromAvatar: currentAvatar,
        targetContent: (post !== null) ? post.text : `关注了你`,
        timestamp: Date.now()
      };

      const updatedMessages: MessageNotification[] = [newMsg];
      this.unreadMessages = updatedMessages.concat(this.unreadMessages);
      AppStorage.SetOrCreate('unreadMessages', this.unreadMessages);
    }
  }

  formatLocation(data: PostItem): string {
    if (data.location && data.location !== '' && data.location !== '选择位置' && data.location !== '定位中...') {
      return data.location;
    }
    if (this.currentProvince && this.currentProvince !== '' && this.currentProvince !== '未知省份') {
      return this.currentProvince;
    }
    return '探险途中';
  }

  getRelativeTime(time: number, ticker: number): string {
    const now: number = Date.now();
    const diff: number = (now - time) / 1000;
    if (diff < 60) return '刚刚';
    if (diff < 3600) return `${Math.floor(diff / 60)}分钟前`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}小时前`;
    const date: Date = new Date(time);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  async deletePost(postId: string): Promise<void> {
    try {
      await postRepo.deletePost(postId);
      this.globalPosts = this.globalPosts.filter((p: PostItem) => p.id !== postId);
      promptAction.showToast({ message: '已成功删除动态' });
    } catch (e) {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  async aboutToAppear(): Promise<void> {
    await postRepo.init(getContext(this));
    this.refreshData();
    this.timerId = setInterval(() => {
      this.timeRefreshTicker++;
    }, 60000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  async refreshData(): Promise<void> {
    this.isRefreshing = true;
    try {
      const posts: PostItem[] = await postRepo.fetchAllPosts();
      this.globalPosts = posts;
    } catch (e) {
      console.error("Fetch_Posts_Error");
    } finally {
      this.isRefreshing = false;
    }
  }

  addToHistory(post: PostItem): void {
    let history: PostItem[] = AppStorage.Get<PostItem[]>('browseHistory') || [];
    const filtered = history.filter((item: PostItem) => item.id !== post.id);
    const updated: PostItem[] = [post];
    AppStorage.SetOrCreate('browseHistory', updated.concat(filtered).slice(0, 50));
  }

  // 优化后的点赞逻辑
  async toggleLike(post: PostItem) {
    this.checkAuthAndExecute(async () => {
      const index = this.globalPosts.findIndex(p => p.id === post.id);
      if (index === -1) return;

      let p = this.globalPosts[index];
      if (!p.likeUserIds) p.likeUserIds = [];

      const uIdx = p.likeUserIds.indexOf(this.currentUserId);
      if (uIdx === -1) {
        p.likeUserIds.push(this.currentUserId);
        this.sendNotification(p, 'like');
      } else {
        p.likeUserIds.splice(uIdx, 1);
      }

      // 更新状态
      p.likeCount = p.likeUserIds.length;
      p.isLiked = p.likeUserIds.includes(this.currentUserId);

      // 局部替换并触发全局同步
      this.globalPosts[index] = p;
      AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);

      // 静默更新数据库
      await postRepo.updatePostStatus(p.id, p.isLiked, p.isCollected, p.likeCount);
    });
  }

  // 优化后的收藏逻辑
  async toggleCollect(post: PostItem) {
    this.checkAuthAndExecute(async () => {
      const index = this.globalPosts.findIndex(p => p.id === post.id);
      if (index === -1) return;

      let p = this.globalPosts[index];
      if (!p.collectUserIds) p.collectUserIds = [];

      const uIdx = p.collectUserIds.indexOf(this.currentUserId);
      if (uIdx === -1) {
        p.collectUserIds.push(this.currentUserId);
        this.sendNotification(p, 'collect');
      } else {
        p.collectUserIds.splice(uIdx, 1);
      }

      p.isCollected = p.collectUserIds.includes(this.currentUserId);

      this.globalPosts[index] = p;
      AppStorage.setOrCreate('globalPostList', [...this.globalPosts]);

      await postRepo.updatePostStatus(p.id, p.isLiked, p.isCollected, p.likeCount);
    });
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Search({ placeholder: '搜索动态、用户...', value: this.searchKey })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#F1F3F5', radius: 20 })
            .onChange((v: string) => {
              this.searchKey = v;
            })

          Stack({ alignContent: Alignment.TopEnd }) {
            SymbolGlyph($r('sys.symbol.bell'))
              .fontSize(24)
              .onClick(() => {
                this.checkAuthAndExecute(() => {
                  router.pushUrl({ url: 'pages/circle/MessageCenterView' })
                })
              })
            if (this.unreadMessages.length > 0) {
              Circle({ width: 8, height: 8 }).fill('#FF4D4F')
                .offset({ x: 2, y: -2 })
            }
          }
          .margin({ left: 15 })
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 10, bottom: 5 })

        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('关注', 0))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('推荐', 1))
          TabContent() { this.SocialContentList() }.tabBar(this.TabBuilder('同城', 2))
        }
        .layoutWeight(1)
        .onChange((i: number) => {
          this.currentIndex = i;
        })
        .barMode(BarMode.Fixed)
      }
      .width('100%')
      .height('100%')

      if (this.showBigImage) {
        Stack() {
          Rect().width('100%').height('100%').fill('#FF000000')
            .onClick(() => {
              this.showBigImage = false;
            })
          Image(this.currentPreviewImg).width('100%').objectFit(ImageFit.Contain)
        }
        .width('100%').height('100%').zIndex(100)
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
        .fontColor(this.currentIndex === index ? '#181818' : '#999999')
        .fontSize(this.currentIndex === index ? 16 : 15)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
      if (this.currentIndex === index) {
        Rect().width(20).height(3).fill('#FF4D4F').margin({ top: 4 }).borderRadius(1.5)
      }
    }.padding({ left: 12, right: 12 })
  }

  @Builder
  SocialContentList() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ space: 10 }) {
        ForEach(
          this.globalPosts.filter((item: PostItem) => {
            const matchesSearch: boolean = item && (item.text.toLowerCase().includes(this.searchKey.toLowerCase()) ||
            item.userName.toLowerCase().includes(this.searchKey.toLowerCase()));
            if (!matchesSearch) return false;

            if (this.currentIndex === 0) {
              return this.followingList.includes(item.userName);
            } else if (this.currentIndex === 2) {
              return item.location.includes(this.currentCity);
            }
            return true;
          }),
          (item: PostItem) => {
            ListItem() {
              if (item && item.id) {
                this.SocialCard(item)
              }
            }
          },
          (item: PostItem) => item.id + String(item.likeUserIds?.length) + String(this.followingList.includes(item.userName))
        )
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
      .padding({ bottom: 20 })
    }
    .onRefreshing(() => {
      this.refreshData();
    })
  }

  @Builder SocialCard(data: PostItem) {
    Column() {
      Row() {
        Image($r('app.media.start'))
          .width(44)
          .height(44)
          .borderRadius(22)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            // 1. 未登录拦截
            if (!this.isLoggedIn) {
              promptAction.showToast({ message: '请先登录探索更多精彩' });
              router.pushUrl({ url: 'pages/mine/RegisterView' });
              return;
            }
            // 2. 已登录判断身份
            if (data.userId === this.currentUserId) {
              AppStorage.setOrCreate('mainTabIndex', 4);
            } else {
              router.pushUrl({
                url: 'pages/mine/UserHomeView',
                params: { userId: data.userId }
              });
            }
          })

        Column() {
          Text(data.userName)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#181818')
            .onClick(() => {
              if (!this.isLoggedIn) {
                router.pushUrl({ url: 'pages/mine/RegisterView' });
              } else if (data.userId === this.currentUserId) {
                router.pushUrl({ url: 'pages/Index', params: { tabIndex: 4 } });
              } else {
                router.pushUrl({ url: 'pages/mine/UserHomeView', params: { userId: data.userId } });
              }
            })

          Column() {
            Text(this.getRelativeTime(data.timestamp, this.timeRefreshTicker))
              .fontSize(11)
              .fontColor('#BBBBBB')

            Text(this.formatLocation(data))
              .fontSize(11)
              .fontColor('#BBBBBB')
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 12, bottom: 10 })

      // 帖子图片展示
      if (data.images && data.images.length > 0) {
        Image(data.images[0])
          .width('100%')
          .height(260)
          .objectFit(ImageFit.Cover)
          .margin({ bottom: 10 })
          .onClick(() => {
            this.currentPreviewImg = data.images[0]
            this.showBigImage = true
          })
      }

      // 帖子正文点击跳转详情
      Text(data.text)
        .fontSize(15)
        .fontColor('#333333')
        .lineHeight(22)
        .width('100%')
        .padding({ left: 15, right: 15, bottom: 15 })
        .onClick(() => {
          this.addToHistory(data)
          router.pushUrl({ url: 'pages/circle/PostDetailView', params: { postData: data } })
        })

      // 底部交互按钮区（点赞、收藏、评论）
      Row() {
        // 点赞
        Row() {
          this.InteractionIcon(
            (data.likeUserIds?.includes(this.currentUserId)) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
            data.likeCount.toString(),
            (data.likeUserIds?.includes(this.currentUserId)) ? '#FF4D4F' : '#666666'
          )
        }.onClick(() => { this.toggleLike(data) })

        // 收藏
        Row() {
          this.InteractionIcon(
            (data.collectUserIds?.includes(this.currentUserId)) ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
            (data.collectUserIds?.includes(this.currentUserId)) ? '已收藏' : '收藏',
            (data.collectUserIds?.includes(this.currentUserId)) ? '#FFAD14' : '#666666'
          )
        }.onClick(() => { this.toggleCollect(data) })

        // 评论跳转详情
        Row() {
          this.InteractionIcon(
            $r('sys.symbol.message'),
            (data.comments && data.comments.length > 0) ? data.comments.length.toString() : '评论'
          )
        }.onClick(() => {
          router.pushUrl({ url: 'pages/circle/PostDetailView', params: { postData: data } })
        })
      }
      .width('100%')
      .padding({ left: 15, right: 15, bottom: 15 })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 12, right: 12, top: 5, bottom: 5 })
    .shadow({ radius: 10, color: '#08000000', offsetY: 4 })
  }

  @Builder
  InteractionIcon(icon: Resource, text: string, color: string = '#666666') {
    Row() {
      SymbolGlyph(icon)
        .fontSize(20)
        .fontColor([color])
      Text(text)
        .fontSize(13)
        .fontColor(color)
        .margin({ left: 6 })
    }
    .margin({ right: 30 })
  }
}