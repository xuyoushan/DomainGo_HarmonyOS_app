import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem, CommentItem } from '../../models/PostItem';
import { postRepo } from '../../services/PostRepository';
import { PreferenceManager } from '../../services/PreferenceManager';
import { common } from '@kit.AbilityKit';

interface MessageNotification {
  id: string;
  type: string;
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
  @StorageLink('currentUserId') currentUserId: string = '';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('needsRefreshPosts') @Watch('onRefreshSignal') refreshSignal: number = 0;

  @State currentIndex: number = 1;
  @State isRefreshing: boolean = false;
  @State showBigImage: boolean = false;
  @State currentPreviewImg: ResourceStr = '';
  @State searchKey: string = '';
  @State timeRefreshTicker: number = 0;
  private timerId: number = -1;

  private controller: TabsController = new TabsController();

  onRefreshSignal() {
    this.refreshData();
  }

  checkAuthAndExecute(action: () => void): void {
    if (!this.isLoggedIn || this.currentUserId === '') {
      promptAction.showToast({ message: '请先登录探索更多精彩' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return;
    }
    action();
  }

  async sendNotification(post: PostItem | null, type: string, targetUserId: string = ''){
    const currentName: string = AppStorage.Get<string>('userName') || '某个探险家';
    const currentAvatar: string = AppStorage.Get<string>('userAvatar') || 'app.media.start';

    let receiverId: string = '';
    if (type === 'follow') {
      receiverId = targetUserId;
    } else if (post !== null) {
      receiverId = post.userId;
    }

    if (receiverId !== '' && receiverId !== this.currentUserId) {
      try {
        await postRepo.sendNotification(
          receiverId,
          this.currentUserId,
          currentName,
          currentAvatar,
          type,
          (post !== null) ? post.text : `已与你结交`
        );
        console.info('通知已成功存入数据库');
      } catch (err) {
        console.error('发送通知失败', JSON.stringify(err));
      }
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

  getSafeAvatar(data: PostItem): ResourceStr {
    if (data.userId === this.currentUserId) {
      const liveAvatar = AppStorage.get<string>('userAvatar');
      if (liveAvatar && liveAvatar !== 'undefined' && liveAvatar !== '' && liveAvatar !== 'app.media.start') {
        return liveAvatar;
      }
    }
    const avatar = data.avatar;
    if (avatar === null || avatar === undefined || avatar === '' || avatar === 'undefined' || avatar === 'null') {
      return $r('app.media.start');
    }
    if (typeof avatar === 'string') {
      if (avatar.includes('app.media') || avatar.startsWith('resource://')) {
        return $r('app.media.start');
      }
      if (avatar.startsWith('http') || avatar.startsWith('file://') || avatar.startsWith('/data/storage')) {
        return avatar;
      }
      if (avatar.length < 5) return $r('app.media.start');
    }
    return (typeof avatar === 'object') ? avatar : $r('app.media.start');
  }

  async refreshData(): Promise<void> {
    this.isRefreshing = true;
    try {
      if (this.isLoggedIn && this.currentUserId) {
        const latestUser = await postRepo.getUserById(this.currentUserId);
        if (latestUser) {
          AppStorage.setOrCreate('userName', latestUser.username);
          AppStorage.setOrCreate('userAvatar', latestUser.avatar);
        }
      }
      const posts: PostItem[] = await postRepo.fetchAllPosts();
      const newList = posts.map(p => {
        p.isLiked = (p.likeUserIds || []).includes(this.currentUserId);
        p.isCollected = (p.collectUserIds || []).includes(this.currentUserId);
        if (p.avatar === 'app.media.start' || p.avatar === '' || !p.avatar) {
          p.avatar = $r('app.media.start');
        }
        return p;
      });

      this.globalPosts = newList;
      AppStorage.setOrCreate('globalPostList', [...newList]);

    } catch (e) {
      console.error("Refresh_Data_Error");
    } finally {
      this.isRefreshing = false;
    }
  }

  async addToHistory(post: PostItem) {
    let history: PostItem[] = AppStorage.get<PostItem[]>('browseHistory') || [];
    const filtered = history.filter((item: PostItem) => item.id !== post.id);
    const updated = [post].concat(filtered).slice(0, 50);
    AppStorage.setOrCreate('browseHistory', updated);
    const context = getContext(this) as common.UIAbilityContext;
    await PreferenceManager.put(context, 'browseHistory', JSON.stringify(updated));
  }

  async toggleLike(post: PostItem) {
    this.checkAuthAndExecute(async () => {
      const index = this.globalPosts.findIndex(p => p.id === post.id);
      if (index === -1) return;
      const origin = this.globalPosts[index];

      let updatedPost: PostItem = {
        id: origin.id,
        userId: origin.userId,
        userName: origin.userName,
        avatar: origin.avatar,
        text: origin.text,
        images: origin.images,
        timestamp: origin.timestamp,
        location: origin.location,
        isLiked: origin.isLiked,
        likeCount: origin.likeCount,
        likeUserIds: origin.likeUserIds ? [...origin.likeUserIds] : [],
        isCollected: origin.isCollected,
        collectUserIds: origin.collectUserIds ? [...origin.collectUserIds] : [],
        comments: origin.comments
      };

      const ids = updatedPost.likeUserIds!;
      const userIdx = ids.indexOf(this.currentUserId);

      if (!updatedPost.isLiked) {
        if (userIdx === -1) {
          ids.push(this.currentUserId);
        }
        updatedPost.isLiked = true;
        updatedPost.likeCount++;
        this.sendNotification(updatedPost, 'like');
      } else {
        if (userIdx !== -1) {
          ids.splice(userIdx, 1);
        }
        updatedPost.isLiked = false;
        updatedPost.likeCount = Math.max(0, updatedPost.likeCount - 1);
      }

      updatedPost.likeUserIds = ids;

      this.globalPosts = this.globalPosts.map(p => p.id === updatedPost.id ? updatedPost : p);

      AppStorage.setOrCreate('globalPostList', this.globalPosts);
      postRepo.updatePostStatus(
        updatedPost.id,
        updatedPost.isLiked,
        updatedPost.isCollected || false,
        updatedPost.likeCount,
        updatedPost.likeUserIds,
        updatedPost.collectUserIds || []
      );
    });
  }

  async toggleCollect(post: PostItem) {
    this.checkAuthAndExecute(async () => {
      const index = this.globalPosts.findIndex(p => p.id === post.id);
      if (index === -1) return;
      const origin = this.globalPosts[index];

      let updatedPost: PostItem = {
        id: origin.id,
        userId: origin.userId,
        userName: origin.userName,
        avatar: origin.avatar,
        text: origin.text,
        images: origin.images,
        timestamp: origin.timestamp,
        location: origin.location,
        isLiked: origin.isLiked,
        likeCount: origin.likeCount,
        likeUserIds: origin.likeUserIds ? [...origin.likeUserIds] : [],
        comments: origin.comments,
        isCollected: origin.isCollected,
        collectUserIds: origin.collectUserIds ? [...origin.collectUserIds] : []
      };

      const collectIds = updatedPost.collectUserIds!;
      const userIdx = collectIds.indexOf(this.currentUserId);

      if (!updatedPost.isCollected) {
        if (userIdx === -1) {
          collectIds.push(this.currentUserId);
        }
        updatedPost.isCollected = true;
        promptAction.showToast({ message: '已加入收藏列表' });
        this.sendNotification(updatedPost, 'collect');
      } else {
        if (userIdx !== -1) {
          collectIds.splice(userIdx, 1);
        }
        updatedPost.isCollected = false;
        promptAction.showToast({ message: '已取消收藏' });
      }

      updatedPost.collectUserIds = collectIds;

      this.globalPosts = this.globalPosts.map(p => p.id === updatedPost.id ? updatedPost : p);
      AppStorage.setOrCreate('globalPostList', this.globalPosts);

      await postRepo.updatePostStatus(
        updatedPost.id,
        updatedPost.isLiked,
        updatedPost.isCollected,
        updatedPost.likeCount,
        updatedPost.likeUserIds || [],
        updatedPost.collectUserIds || []
      );
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
                  router.pushUrl({ url: 'pages/features/circle/MessageCenterView' })
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

  @Builder SocialContentList() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ space: 10 }) {
        if (this.globalPosts.length === 0) {
          ListItem() {
            this.WelcomeFixedCard()
          }
        }
        ForEach(
          this.globalPosts.filter((p: PostItem) => {
            const k = this.searchKey.toLowerCase().trim();
            const matchesSearch = !k || p.text.toLowerCase().includes(k) || p.userName.toLowerCase().includes(k);
            if (!matchesSearch) return false;
            if (this.currentIndex === 0) {
              return this.followingList.includes(p.userId);
            }
            else if (this.currentIndex === 2) {
              return p.location && p.location.includes(this.currentCity || '');
            }
            return true;
          }),
          (item: PostItem) => {
            ListItem() {
              this.SocialCard(item)
            }
          },
          (item: PostItem) => item.id
        )
        if (this.currentIndex === 0 && this.globalPosts.filter(p => this.followingList.includes(p.userId)).length === 0) {
          ListItem() {
            Text('你关注的人还没有发布动态哦')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontColor('#CCCCCC')
              .fontSize(14)
              .margin({ top: 60 })
          }
        }
      }
      .width('100%').height('100%')
      .edgeEffect(EdgeEffect.Spring).padding({ bottom: 20 })
    }
    .onRefreshing(() => this.refreshData())
  }

  @Builder WelcomeFixedCard() {
    Column() {
      Row() {
        Image($r('app.media.start')).width(40).height(40).borderRadius(20)
        Column() {
          Text('寻域官方').fontSize(15).fontWeight(FontWeight.Bold)
          Text('刚刚').fontSize(12).fontColor('#999999')
        }.margin({ left: 10 }).alignItems(HorizontalAlign.Start)
      }.padding(15).width('100%')

      Column() {
        Text('————欢迎来到寻域————\nDomainGo')
          .width('100%').textAlign(TextAlign.Center).fontSize(16).fontWeight(FontWeight.Medium).margin({ bottom: 15 })
        Image($r('app.media.start')).width('100%').height(200).borderRadius(8).objectFit(ImageFit.Cover)
      }
      .padding({ left: 15, right: 15, bottom: 15 })
      .onClick(() => {
        const data: PostItem = {
          id: 'fixed_welcome_post',
          userId: 'admin',
          userName: '寻域官方',
          avatar: $r('app.media.start'),
          text: '————欢迎来到寻域————\nDomainGo',
          timestamp: Date.now(),
          images: ['app.media.start'],
          location: '寻域总部',
          likeCount: 999,
          isLiked: false,
          isCollected: false,
          comments: []
        };
        router.pushUrl({ url: 'pages/circle/PostDetailView', params: { postData: data } })
      })
    }
    .backgroundColor('#FFFFFF').borderRadius(16).margin({ left: 12, right: 12, top: 5, bottom: 5 })
  }

  @Builder SocialCard(data: PostItem) {
    Column() {
      Row() {
        Image(this.getSafeAvatar(data))
          .width(44)
          .height(44)
          .borderRadius(22)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.start')) // 加载期间或失败时的占位图
          .key(data.id + (data.userId === this.currentUserId ? this.timeRefreshTicker : ''))
          .onClick(() => {
            if (!this.isLoggedIn) {
              promptAction.showToast({ message: '请先登录探索更多精彩' });
              router.pushUrl({ url: 'pages/mine/RegisterView' });
              return;
            }
            if (data.id === 'fixed_welcome_post') return;
            if (data.userId === this.currentUserId) {
              AppStorage.setOrCreate('mainIndex', 4);
            } else {
              router.pushUrl({ url: 'pages/features/mine/UserHomeView', params: { userId: data.userId } });
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
                AppStorage.setOrCreate('mainIndex', 4);
              } else {
                router.pushUrl({ url: 'pages/features/mine/UserHomeView', params: { userId: data.userId } });
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

      Row() {
        Row() {
          this.InteractionIcon(
            data.isLiked ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'),
            data.likeCount.toString(),
            data.isLiked ? '#FF4D4F' : '#666666'
          )
        }.onClick(() => { this.toggleLike(data) })

        Row() {
          this.InteractionIcon(
            data.isCollected ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
            data.isCollected ? '已收藏' : '收藏',
            data.isCollected ? '#FFAD14' : '#666666'
          )
        }.onClick(() => { this.toggleCollect(data) })

        Row() {
          this.InteractionIcon(
            $r('sys.symbol.message'),
            (data.comments && data.comments.length > 0) ? data.comments.length.toString() : '评论'
          )
        }.onClick(() => {
          this.addToHistory(data);
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
