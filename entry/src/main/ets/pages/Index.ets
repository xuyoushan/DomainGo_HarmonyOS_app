import router from '@ohos.router'
import { ExploreView } from './explore/ExploreView'
import { CircleView } from './circle/CircleView'
import { GuideView } from './guide/GuideView'
import { MineView } from './mine/MineView'
import { BottomNavBar } from '../components/BottomNavBar'
import window from '@ohos.window'

@Entry
@Component
struct Index {
  @StorageLink('mainIndex') currentIndex: number = 0
  @StorageLink('welcomeFinished') welcomeFinished: boolean = false
  @State showBottomBar: boolean = false
  @State navOffsetY: number = 40
  @State navOpacity: number = 0

  /**
   * 核心窗口状态控制：根据参数决定是开启沉浸式全屏，还是恢复常规系统导航栏
   */
  private async setSystemWindowMode(isImmersive: boolean) {
    try {
      const win = await window.getLastWindow(getContext(this));
      if (isImmersive) {
        // 开启全屏模式：视图扩展至状态栏，并隐藏所有系统工具栏
        await win.setWindowLayoutFullScreen(true);
        await win.setWindowSystemBarEnable([]);
      } else {
        // 恢复常规模式：视图避开状态栏，并显示系统导航栏与状态栏
        await win.setWindowLayoutFullScreen(false);
        await win.setWindowSystemBarEnable(['status', 'navigation']);
      }
    } catch (err) {
      console.error('Index Window Mode Error: ' + JSON.stringify(err));
    }
  }

  /**
   * 页面初始化：根据当前是否已完成引导，决定初始窗口状态和底部导航栏显隐
   */
  aboutToAppear() {
    if (this.welcomeFinished) {
      // 场景：已登录或已完成引导。直接恢复系统栏，并立即显示应用底部导航
      this.setSystemWindowMode(false);
      this.showBottomBar = true;
      this.navOffsetY = 0;
      this.navOpacity = 1;
    } else {
      // 场景：新用户或初次启动。强制进入沉浸式全屏，开始轮询引导结束状态
      this.setSystemWindowMode(true);
      this.waitForWelcomeFinish();
    }
  }

  /**
   * 引导状态监控：持续检查 welcomeFinished 状态，一旦完成则执行转场恢复逻辑
   */
  private waitForWelcomeFinish() {
    const timer = setInterval(() => {
      if (this.welcomeFinished) {
        clearInterval(timer)

        // 引导结束瞬间，立即恢复系统栏，确保主内容区交互正常
        this.setSystemWindowMode(false);

        setTimeout(() => {
          this.showBottomBar = true
          animateTo(
            {
              duration: 300,
              curve: Curve.EaseOut
            },
            () => {
              this.navOffsetY = 0
              this.navOpacity = 1
            }
          )
        }, 888)
      }
    }, 50)
  }

  build() {
    Column() {
      Tabs({ index: this.currentIndex, barPosition: BarPosition.End }) {
        TabContent() { ExploreView() }
        TabContent() { CircleView() }
        TabContent() {
          Column() {
            Text('发布功能')
          }
          .justifyContent(FlexAlign.Center)
          .height('100%')
        }
        TabContent() { GuideView() }
        TabContent() { MineView() }
      }
      .layoutWeight(1)
      .barHeight(0)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      if (this.showBottomBar) {
        BottomNavBar({ currentIndex: $currentIndex })
          .width('100%')
          .height(65)
          .translate({ y: this.navOffsetY })
          .opacity(this.navOpacity)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}