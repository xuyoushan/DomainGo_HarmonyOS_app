import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';
import { PostItem } from '../../../models/PostItem';
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../../../services/PreferenceManager';

interface MessageItem {
  id: string;
  type: string;
  fromUserName: string | undefined;
  fromAvatar: Resource;
  targetContent: string;
  timestamp: number;
  isRead: boolean;
}

@Entry
@Component
struct UserHomeView {
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @StorageLink('currentUserId') myId: string = '';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('followingList') followingList: string[] = [];
  @StorageLink('unreadMessages') unreadMessages: MessageItem[] = [];
  @StorageLink('userAvatar') myAvatar: string = '';

  @State targetUserId: string = '';
  @State targetUserName: string = '探险员';
  @State targetUserDesc: string = '寻域首席体验官 | 走遍中国每一角';
  @State userPosts: PostItem[] = [];
  @State favoritePosts: PostItem[] = [];
  @State selectedTabIndex: number = 0;
  @State baseFollowerCount: number = 1;

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.userId) {
      this.targetUserId = params.userId as string;
    } else {
      this.targetUserId = this.myId;
    }
    if (this.globalPosts.length === 0) {
      const context = getContext(this) as common.UIAbilityContext;
      const savedPosts = await PreferenceManager.get(context, 'globalPostList', '[]');
      try {
        const parsed = JSON.parse(savedPosts as string) as PostItem[];
        this.globalPosts = parsed;
        AppStorage.setOrCreate('globalPostList', parsed);
      } catch (e) {
        console.error('UserHome recovery error:', e);
      }
    }
    this.refreshUserInfo();
  }

  onPageShow() {
    this.refreshUserInfo();
  }

  async loadAllData() {
    const context = getContext(this) as common.UIAbilityContext;
    const historyJson = await PreferenceManager.get(context, 'browseHistory', '[]');

    this.refreshUserInfo();
  }

  private async syncFavoritesToDisk() {
    const context = getContext(this) as common.UIAbilityContext;
    AppStorage.setOrCreate('globalPostList', this.globalPosts);
    await PreferenceManager.put(context, 'globalPostList', JSON.stringify(this.globalPosts));
  }

  refreshUserInfo() {
    this.userPosts = this.globalPosts.filter(post => post.userId === this.targetUserId);
    this.favoritePosts = this.globalPosts.filter(post => post.isCollected === true);
    this.baseFollowerCount = 1;
    if (this.targetUserId === this.myId) {
      this.targetUserName = AppStorage.get('userName') || '探险家';
    } else if (this.userPosts.length > 0) {
      this.targetUserName = this.userPosts[0].userName;
    }
  }

  getSafeDisplayAvatar(): ResourceStr {
    if (this.targetUserId === this.myId) {
      if (
        this.myAvatar &&
          this.myAvatar !== '' &&
          this.myAvatar !== 'undefined' &&
          this.myAvatar !== 'app.media.start'
      ) {
        return this.myAvatar;
      }
      return $r('app.media.start');
    }
    if (this.userPosts.length > 0 && this.userPosts[0].avatar) {
      return this.userPosts[0].avatar;
    }
    return $r('app.media.start');
  }

  calculateTotalLikes(): string {
    let total = 0;
    this.userPosts.forEach(p => total += (p.likeCount || 0));
    return total > 1000 ? (total / 1000).toFixed(1) + 'k' : total.toString();
  }

  copyToClipboard(text: string) {
    if (!text) return;
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData, (err) => {
      if (err) {
        promptAction.showToast({ message: '复制失败' });
      } else {
        promptAction.showToast({ message: 'ID 已复制到剪贴板' });
      }
    });
  }

  checkAuthAndExecute(action: () => void) {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return;
    }
    action();
  }

  handleFollowAction() {
    this.checkAuthAndExecute(async () => {
      const targetId = this.targetUserId;
      let list = [...this.followingList];
      const index = list.indexOf(targetId);
      if (index === -1) {
        list.push(targetId);
        promptAction.showToast({ message: '结交成功' });
        const newMsg: MessageItem = {
          id: Date.now().toString(),
          type: 'follow',
          fromUserName: '系统',
          fromAvatar: $r('app.media.start'),
          targetContent: `你结交了 ${this.targetUserName}`,
          timestamp: Date.now(),
          isRead: false
        };
        this.unreadMessages = [newMsg, ...this.unreadMessages];
      } else {
        list.splice(index, 1);
        promptAction.showToast({ message: '已解除结交' });
      }
      this.followingList = list;
      AppStorage.setOrCreate('followingList', list);
      const context = getContext(this) as common.UIAbilityContext;
      await PreferenceManager.put(context, 'followingList', JSON.stringify(list));
    });
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Rect().width('100%').height(220)
          .fill('#FAF9F7')

        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(22).fontColor(['#3D3D3D'])
          }
          .width(36).height(36).backgroundColor('rgba(0,0,0,0.05)')
          .borderRadius(18)
          .onClick(() => router.back())

          Blank()
        }.width('100%').padding({ left: 20, right: 20, top: 45 }).zIndex(10)

        Column() {
          Row() {
            Image(this.getSafeDisplayAvatar())
              .width(80).height(80)
              .borderRadius(40)
              .border({ width: 2, color: '#C0A47E' })
              .objectFit(ImageFit.Cover)
              .shadow({ radius: 15, color: '#15000000', offsetY: 8 })

            Column() {
              Text(this.targetUserName)
                .fontSize(24).fontWeight(FontWeight.Bold).fontColor('#2C2C2C')

              Row() {
                Text(`域号: ${this.targetUserId.substring(0, 8) || '探险员'}`)
                  .fontSize(12).fontColor('#8C8476')
                SymbolGlyph($r('sys.symbol.doc_filled_on_doc'))
                  .fontSize(12).fontColor(['#B22222']).margin({ left: 6 })
              }
              .margin({ top: 6 })
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#F0EDE7')
              .borderRadius(6)
              .onClick(() => {
                if (this.targetUserId) this.copyToClipboard(this.targetUserId);
              })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 15 })
            .layoutWeight(1)
          }
          .width('100%')

          Text(this.targetUserDesc)
            .fontSize(14)
            .fontColor('#5C5446')
            .lineHeight(20)
            .margin({ top: 18 })
            .width('100%')

          Row() {
            this.CountItem(this.targetUserId === this.myId ? this.followingList.length.toString() : '0', '追随')
            this.CountItem((this.baseFollowerCount + (this.followingList.includes(this.targetUserId) ? 1 : 0)).toString(), '知音')
            this.CountItem(this.calculateTotalLikes(), '获誉')

            Blank()

            if (this.targetUserId !== this.myId) {
              Button(this.followingList.includes(this.targetUserId) ? '已结交' : '结交')
                .fontSize(14).fontWeight(FontWeight.Medium)
                .backgroundColor(this.followingList.includes(this.targetUserId) ? '#E0DDD5' : '#B22222')
                .fontColor(this.followingList.includes(this.targetUserId) ? '#666666' : '#FFFFFF')
                .height(34).width(90)
                .borderRadius(4)
                .onClick(() => this.handleFollowAction())
            }
          }
          .margin({ top: 25 })
          .width('100%')
        }
        .width('92%')
        .backgroundColor('#FCF9F5')
        .borderRadius(12)
        .padding(24)
        .margin({ top: 110 })
        .shadow({ radius: 25, color: '#12000000', offsetY: 10 })
      }

      Row() {
        this.TabBtn('动态', 0)
        this.TabBtn('收藏', 1)
      }
      .margin({ top: 30 })
      .padding({ left: 30 })
      .width('100%')

      List({ space: 14 }) {
        if ((this.selectedTabIndex === 0 ? this.userPosts.length : this.favoritePosts.length) === 0) {
          ListItem() {
            Column() {
              SymbolGlyph($r('sys.symbol.scribble'))
                .fontSize(70)
                .fontColor(['#D1CEC7'])
              Text(this.selectedTabIndex === 0 ? '还没有发布任何动态' : '暂无收藏内容')
                .fontColor('#BDB9B1')
                .fontSize(15)
                .margin({ top: 15 })
            }
            .width('100%')
            .margin({ top: 80 })
          }
        } else {
          ForEach(
            this.selectedTabIndex === 0 ? this.userPosts : this.favoritePosts,
            (item: PostItem) => {
              ListItem() {
                this.PostCardItem(item)
              }
            },
            (item: PostItem) => item.id + this.selectedTabIndex + this.globalPosts.length
          )
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16, top: 10 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF9F7')
  }

  @Builder TabBtn(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(18)
        .fontWeight(this.selectedTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selectedTabIndex === index ? '#1A1A1A' : '#999999')

      if (this.selectedTabIndex === index) {
        Rect().width(24).height(4).fill('#B22222').margin({ top: 6 }).borderRadius(2)
      }
    }
    .margin({ right: 35 })
    .onClick(() => this.selectedTabIndex = index)
  }

  @Builder CountItem(count: string, label: string) {
    Column() {
      Text(count).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
      Text(label).fontSize(12).fontColor('#999999').margin({ top: 4 })
    }
    .margin({ right: 30 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder PostCardItem(item: PostItem) {
    Row() {
      if (item.images && item.images.length > 0) {
        Image(item.images[0])
          .width(100).height(100)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
      }

      Column() {
        Text(item.text)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .lineHeight(22)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()

        Row() {
          Text(new Date(item.timestamp).toLocaleDateString())
            .fontSize(12)
            .fontColor('#BBBBBB')

          Blank()

          Row() {
            SymbolGlyph(item.isCollected ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
              .fontSize(16)
              .fontColor([item.isCollected ? '#B22222' : '#CCC'])
              .onClick((event: ClickEvent) => {
                item.isCollected = !item.isCollected;
                this.syncFavoritesToDisk();
                this.refreshUserInfo();
              })
              .hitTestBehavior(HitTestMode.Block)

            Text(item.likeCount.toString())
              .fontSize(13)
              .fontColor('#666666')
              .margin({ left: 4 })
          }
          .backgroundColor('#FFF2F0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height(100)
      .margin({ left: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .width('100%')
    .shadow({ radius: 15, color: '#08000000', offsetY: 5 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/circle/PostDetailView',
        params: { postData: item }
      })
    })
  }
}