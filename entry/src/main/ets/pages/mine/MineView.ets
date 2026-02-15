import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem } from '../../models/PostItem';
import { PreferenceManager } from '../../services/PreferenceManager';
import { common } from '@kit.AbilityKit';

@Component
export struct MineView {
  scroller: Scroller = new Scroller()
  @StorageLink('userName') userName: string = '点击注册/登录';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('browseHistory') history: PostItem[] = [];
  @StorageLink('userAvatar') userAvatar: string = '';
  @StorageLink('currentUserId') userId: string = '';

  // 统一的登录拦截方法
  checkLoginAndExecute(action: () => void) {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录探索更多精彩' });
      router.pushUrl({ url: 'pages/mine/RegisterView' });
      return;
    }
    action();
  }

  build() {
    Column() {
      if (!this.isLoggedIn) {
        // --- 未登录状态 ---
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(400)
            .height(400)
            .fill('#1A007DFF')
            .offset({ x: -150, y: -200 })
          Column() {
            this.UserHeaderCard()
            Text('登录后即可查看勋章、动态及足迹')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 20 })
          }
          .padding(16)
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F7F8FA')
      } else {
        Scroll(this.scroller) {
          Column() {
            Stack({ alignContent: Alignment.Top }) {
              Circle()
                .width(400)
                .height(400)
                .fill('#1A007DFF')
                .offset({ x: -150, y: -200 })

              Column() {
                this.UserHeaderCard()
                this.DataOverviewRow()
              }
              .padding({ top: 60, left: 16, right: 16 })
            }
            .width('100%')
            .height(300)

            Column() {
              this.QuickActions()

              List() {
                ListItem() {
                  this.EnhancedMenuItem('我的足迹', $r('sys.symbol.map'), '#4F94FF')
                }.onClick(() => {
                  this.checkLoginAndExecute(() => {
                    router.pushUrl({ url: 'pages/features/mine/TraceDetailView' })
                      .catch(() => promptAction.showToast({ message: '足迹页面路径未注册' }))
                  })
                })

                ListItem() {
                  this.EnhancedMenuItem('我的动态', $r('sys.symbol.star_fill'), '#FFB119')
                }.onClick(() => {
                  this.checkLoginAndExecute(() => {
                    router.pushUrl({
                      url: 'pages/features/mine/UserHomeView',
                      params: { userId: this.userId, initialTab: 1 }
                    })
                  })
                })

                ListItem() {
                  this.EnhancedMenuItem('浏览历史', $r('sys.symbol.clock_fill'), '#4CD964')
                }.onClick(() => {
                  this.checkLoginAndExecute(() => {
                    router.pushUrl({ url: 'pages/features/mine/HistoryView' })
                      .catch(() => promptAction.showToast({ message: '历史记录页面未注册' }))
                  })
                })

                ListItem() {
                  this.EnhancedMenuItem('系统设置', $r('sys.symbol.gearshape'), '#8E8E93')
                }
                .onClick(() => {
                  router.pushUrl({ url: 'pages/features/mine/settings' })
                    .catch(() => promptAction.showToast({ message: '路径未注册' }))
                })
              }
              .padding({ left: 10, right: 10 })
              .backgroundColor(Color.White)
              .borderRadius(20)
              .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 45 })
            }
            .width('92%')
            .margin({ top: -40 })

            if (this.history.length > 0) {
              this.SectionTitle('最近浏览', '查看全部 >')
            }

            this.SectionTitle('我的勋章', '全部勋章 >')
            this.BadgeWall()

            Blank().height(50)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .backgroundColor('#F7F8FA')
        .transition(TransitionEffect.asymmetric(
          TransitionEffect.OPACITY.animation({ duration: 800, curve: Curve.EaseInOut })
            .combine(TransitionEffect.translate({ y: 20 }))
            .combine(TransitionEffect.scale({ x: 0.98, y: 0.98 })),
          TransitionEffect.OPACITY.animation({ duration: 300 })
        ))
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder UserHeaderCard() {
    Row() {
      Image((this.userAvatar === 'app.media.start' || !this.userAvatar || this.userAvatar === 'undefined' || this.userAvatar === '')
        ? $r('app.media.start')
        : this.userAvatar)
        .width(72)
        .height(72)
        .borderRadius(36)
        .border({ width: 3, color: Color.White })
        .shadow({ radius: 10, color: '#20000000' })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(this.isLoggedIn ? this.userName : '登录解锁更多精彩')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(this.isLoggedIn ? `寻域 ID: ${this.userId}` : 'Hi，欢迎来到寻域')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
      .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor(['#BBBBBB'])
    }
    .width('100%')
    .padding(24)
    .backgroundColor('rgba(255,255,255,0.8)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(24)
    .onClick(() => {
      if (!this.isLoggedIn) {
        router.pushUrl({ url: 'pages/mine/RegisterView' })
      } else {
        router.pushUrl({ url: 'pages/features/mine/UserHomeView', params: { userId: this.userId } })
      }
    })
  }

  @Builder
  DataOverviewRow() {
    Row() {
      this.DataItem('1280', '足迹(km²)')
      this.DataItem('2', '获得勋章')
      this.DataItem('12', '点亮领域')
    }
    .width('100%')
    .margin({ top: 16 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  DataItem(value: string, label: string) {
    Column() {
      Text(value).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
      Text(label).fontSize(12).fontColor('#999999').margin({ top: 4 })
    }
  }

  @Builder
  EnhancedMenuItem(title: string, icon: Resource, iconColor: string, badge?: string) {
    Row() {
      Stack() {
        Circle().width(32).height(32).fill(iconColor).opacity(0.1)
        SymbolGlyph(icon).fontSize(18).fontColor([iconColor])
      }
      Text(title).fontSize(16).margin({ left: 12 }).layoutWeight(1).fontColor('#333333')
      // 只有显式传入 badge 且有内容时才显示
      if (badge && badge !== '0') {
        Text(badge).fontSize(14).fontColor('#999999').margin({ right: 8 })
      }
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(14).fontColor(['#D1D1D1'])
    }
    .width('100%')
    .height(64)
  }

  @Builder
  SectionTitle(title: string, subTitle: string) {
    Row() {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A1A')
      Blank()
      Text(subTitle).fontSize(13).fontColor('#999999')
    }
    .width('92%')
    .margin({ top: 30, bottom: 16 })
    .onClick(() => {
      if (title === '最近浏览') {
        router.pushUrl({ url: 'pages/features/mine/HistoryView' })
      } else if (title === '我的勋章') {
        router.pushUrl({ url: 'pages/features/mine/BadgeView' })
          .catch(() => promptAction.showToast({ message: '勋章页面未注册' }))
      }
    })
  }

  @Builder
  BadgeWall() {
    Scroll() {
      Row({ space: 12 }) {
        this.BadgeItem('探险家', $r('app.media.ic_explore'), true)
        this.BadgeItem('活地图', $r('app.media.ic_guide'), true)
        this.BadgeItem('社交王', $r('app.media.ic_circle'), false)
        this.BadgeItem('原住民', $r('app.media.ic_mine'), false)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .onClick(() => {
      router.pushUrl({ url: 'pages/features/mine/BadgeView' })
    })
  }

  @Builder
  BadgeItem(name: string, icon: Resource, isUnlocked: boolean) {
    Column() {
      Image(icon)
        .width(48).height(48)
        .grayscale(isUnlocked ? 0 : 1)
        .opacity(isUnlocked ? 1 : 0.4)
      Text(name)
        .fontSize(11)
        .margin({ top: 8 })
        .fontColor(isUnlocked ? '#333333' : '#BBBBBB')
    }
    .width(80).height(90)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#0A000000' })
  }

  @Builder
  QuickActions() {
  }

  async handleLogout() {
    const context = getContext(this) as common.UIAbilityContext;
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('userName', '点击注册/登录');
    AppStorage.setOrCreate('currentUserId', '');
    AppStorage.setOrCreate('userAvatar', 'app.media.start');
    await PreferenceManager.put(context, 'isLoggedIn', false);
    await PreferenceManager.put(context, 'currentUserId', '');
    await PreferenceManager.put(context, 'userName', '');
    await PreferenceManager.put(context, 'userAvatar', 'app.media.start');

    promptAction.showToast({ message: '已安全退出' });
  }
}