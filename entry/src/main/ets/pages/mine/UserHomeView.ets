import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem } from '../../models/PostItem';

@Entry
@Component
struct UserHomeView {
  // 1. 全局数据联动
  @StorageLink('globalPostList') globalPosts: PostItem[] = [];
  @StorageLink('currentUserId') myId: string = '';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('followingList') followingList: string[] = []; // 存用户 ID 或名字

  // 2. 状态变量
  @State targetUserId: string = '';
  @State targetUserName: string = '探险员';
  @State targetUserDesc: string = '寻域首席体验官 | 走遍中国每一角';
  @State userPosts: PostItem[] = [];

  aboutToAppear() {
    // 接收参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.userId) {
      this.targetUserId = params.userId as string;
    } else {
      // 如果没传 ID（理论上不会），默认看自己的
      this.targetUserId = this.myId;
    }

    // 初始化页面数据
    this.refreshUserInfo();
  }

  refreshUserInfo() {
    // 过滤出该用户的动态
    this.userPosts = this.globalPosts.filter(post => post.userId === this.targetUserId);

    // 如果是看别人，从第一条帖子获取对方名字（实际项目中应从用户数据库获取）
    if (this.userPosts.length > 0) {
      this.targetUserName = this.userPosts[0].userName;
    } else if (this.targetUserId === this.myId) {
      this.targetUserName = AppStorage.get('userName') || '我';
    }
  }

  // 统一拦截器
  checkAuthAndExecute(action: () => void) {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return;
    }
    action();
  }

  handleFollowAction() {
    this.checkAuthAndExecute(() => {
      if (this.targetUserId === this.myId) return;

      // 这里建议改为存储 ID，但我目前顺着你的代码逻辑用名字
      const targetName = this.targetUserName;
      let list = [...this.followingList];

      if (list.includes(targetName)) {
        list = list.filter(name => name !== targetName);
        promptAction.showToast({ message: '取消关注' });
      } else {
        list.push(targetName);
        promptAction.showToast({ message: '关注成功' });
      }

      this.followingList = list;
      AppStorage.SetOrCreate('followingList', this.followingList);
    });
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        // 背景图 - 对标小红书渐变色
        Rect().width('100%').height(220)
          .fill('#007DFF')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#007DFF', 0.0], ['#F1F3F5', 1.0]]
          })

        // 导航栏
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24).fontColor(['#FFFFFF'])
            .onClick(() => router.back())
          Blank()
          if (this.targetUserId !== this.myId) {
            SymbolGlyph($r('sys.symbol.share')).fontSize(22).fontColor(['#FFFFFF'])
          }
        }.width('100%').padding({ left: 15, right: 15, top: 50 }).zIndex(2)

        // 个人信息卡片
        Column() {
          Row() {
            Image($r('app.media.start'))
              .width(80).height(80).borderRadius(40)
              .border({ width: 4, color: '#FFFFFF' })
              .shadow({ radius: 10, color: '#20000000' })

            Column() {
              Text(this.targetUserName)
                .fontSize(22).fontWeight(FontWeight.Bold)
              Text(`ID: ${this.targetUserId || '未登录'}`)
                .fontSize(12).fontColor('#999999').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start).margin({ left: 15 })
          }.width('100%')

          Text(this.targetUserDesc)
            .fontSize(14).fontColor('#666666').margin({ top: 15 }).width('100%')

          // 关注/粉丝数据
          Row() {
            this.CountItem('128', '关注')
            this.CountItem('3.5k', '粉丝')
            this.CountItem(this.calculateTotalLikes(), '获赞')

            if (this.targetUserId !== this.myId) {
              Button('关注')
                .backgroundColor('#FF4D4F').height(30).width(80)
                .onClick(() => this.checkAuthAndExecute(() => {
                  promptAction.showToast({ message: '关注成功' })
                }))
            } else {
              Button('编辑资料')
                .backgroundColor('#E8E8E8').fontColor('#666').height(30).width(100)
            }
          }.margin({ top: 20 }).width('100%')
        }
        .width('92%').backgroundColor('#FFFFFF').borderRadius(20)
        .padding(20).margin({ top: 120 })
        .shadow({ radius: 15, color: '#15000000' })
      }

      // 动态 Tab 栏
      Row() {
        Column() {
          Text('动态').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#181818')
          Divider().width(20).strokeWidth(3).color('#007DFF').margin({ top: 5 })
        }.margin({ left: 25 })
        Text('收藏').fontSize(16).fontColor('#999999').margin({ left: 30 })
      }.margin({ top: 30 }).width('100%')

      // 帖子列表
      List({ space: 10 }) {
        if (this.userPosts.length === 0) {
          ListItem() {
            Column() {
              Image($r('sys.symbol.notice_fill')).width(100).opacity(0.3)
              Text('该探险员还没有发布任何动态').fontColor('#CCCCCC').fontSize(14).margin({ top: 10 })
            }.width('100%').margin({ top: 60 })
          }
        } else {
          ForEach(this.userPosts, (item: PostItem) => {
            ListItem() {
              this.PostGridItem(item)
            }
          }, (item: PostItem) => item.id)
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding(10)
      .margin({ top: 10 })
    }.width('100%').height('100%').backgroundColor('#F1F3F5')
  }

  // 获赞总数计算
  calculateTotalLikes(): string {
    let total = 0;
    this.userPosts.forEach(p => total += (p.likeCount || 0));
    return total > 1000 ? (total/1000).toFixed(1) + 'k' : total.toString();
  }

  @Builder CountItem(count: string, label: string) {
    Column() {
      Text(count).fontSize(16).fontWeight(FontWeight.Bold)
      Text(label).fontSize(11).fontColor('#999999').margin({ top: 2 })
    }.margin({ right: 25 }).alignItems(HorizontalAlign.Start)
  }

  // 对标小红书的列表项
  @Builder PostGridItem(item: PostItem) {
    Row() {
      if (item.images && item.images.length > 0) {
        Image(item.images[0])
          .width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)
      }

      Column() {
        Text(item.text).fontSize(15).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        Row() {
          Text(new Date(item.timestamp).toLocaleDateString()).fontSize(12).fontColor('#BBB')
          Blank()
          SymbolGlyph($r('sys.symbol.heart')).fontSize(14).fontColor(['#BBB'])
          Text(item.likeCount.toString()).fontSize(12).fontColor('#BBB').margin({ left: 5 })
        }.width('100%')
      }
      .layoutWeight(1)
      .height(80)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .width('100%')
    .onClick(() => {
      router.pushUrl({
        url: 'pages/circle/PostDetailView',
        params: { postData: item }
      })
    })
  }
}