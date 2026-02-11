import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PostItem } from '../../models/PostItem';

@Component
export struct MineView {
  scroller: Scroller = new Scroller()
  @StorageLink('userName') userName: string = '点击注册/登录';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('browseHistory') history: PostItem[] = [];
  @StorageLink('userAvatar') userAvatar: string = '';
  @StorageLink('currentUserId') userId: string = '';

  build() {
    Scroll(this.scroller) {
      Column() {
        // --- 头部：流光背景与用户信息 ---
        Stack({ alignContent: Alignment.Top }) {
          // 背景装饰
          Circle()
            .width(400)
            .height(400)
            .fill('#1A007DFF')
            .offset({ x: -150, y: -200 })

          Column() {
            // 用户主卡片
            this.UserHeaderCard()

            // 数据概览（原本的足迹/勋章数据）
            this.DataOverviewRow()
          }
          .padding({ top: 60, left: 16, right: 16 })
        }
        .width('100%')
        .height(300)

        // --- 功能操作区：卡片式列表 ---
        Column() {
          this.QuickActions()

          List() {
            ListItem() { this.EnhancedMenuItem('我的足迹', $r('sys.symbol.map'), '#4F94FF') }
            ListItem() { this.EnhancedMenuItem('我的收藏', $r('sys.symbol.star_fill'), '#FFB119') }
            ListItem() {
              this.EnhancedMenuItem('浏览历史', $r('sys.symbol.clock_fill'), '#4CD964', this.history.length.toString())
            }.onClick(() => promptAction.showToast({ message: '跳转至浏览历史' }))

            ListItem() { this.EnhancedMenuItem('系统设置', $r('sys.symbol.gearshape'), '#8E8E93') }
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

        // --- 勋章墙：横向滑动卡片 ---
        this.SectionTitle('我的勋章', '全部勋章 >')
        this.BadgeWall()

        // --- 退出登录 ---
        if (this.isLoggedIn) {
          Button('退出登录', { type: ButtonType.Capsule })
            .width('92%')
            .height(50)
            .margin({ top: 40, bottom: 40 })
            .backgroundColor('#FFF1F3')
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
            .onClick(() => this.handleLogout())
        }

        Blank().height(50)
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F7F8FA')
  }

  // --- 模块化 UI 组件 ---

  @Builder
  UserHeaderCard() {
    Row() {
      Image(this.isLoggedIn && this.userAvatar ? this.userAvatar : $r('app.media.start'))
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

        Text(this.isLoggedIn ?`寻域 ID: ${this.userId}`: 'Hi，欢迎来到寻域')
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
      if (!this.isLoggedIn) router.pushUrl({ url: 'pages/mine/RegisterView' })
    })
  }

  @Builder
  DataOverviewRow() {
    Row() {
      this.DataItem('128', '足迹(km²)')
      this.DataItem('5', '获得勋章')
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
      if (badge) {
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
  }

  @Builder
  BadgeWall() {
    Scroll() {
      Row({ space: 12 }) {
        this.BadgeItem('探险家', $r('app.media.ic_explore'), true)
        this.BadgeItem('社交王', $r('app.media.ic_circle'), true)
        this.BadgeItem('活地图', $r('app.media.ic_guide'), false)
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
    // 这里可以放类似“发布内容”、“勋章任务”的快捷入口
  }

  handleLogout() {
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('userName', '点击注册/登录');
    AppStorage.setOrCreate('currentUserId', '');
    promptAction.showToast({ message: '已安全退出' });
  }
}