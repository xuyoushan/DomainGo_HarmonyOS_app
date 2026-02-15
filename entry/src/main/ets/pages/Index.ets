import { ExploreView } from './explore/ExploreView'
import { CircleView } from './circle/CircleView'
import { GuideView } from './guide/GuideView'
import { MineView } from './mine/MineView'
import { BottomNavBar } from '../components/BottomNavBar'
import window from '@ohos.window'
import { common } from '@kit.AbilityKit';
import { PreferenceManager } from '../services/PreferenceManager';

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

  async aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext;
    const isLog = await PreferenceManager.get(context, 'isLoggedIn', false) as boolean;
    const followDataVal = await PreferenceManager.get(context, 'followingList', '[]');
    try {
      AppStorage.setOrCreate('followingList', JSON.parse(followDataVal.toString()));
    } catch (e) {
      AppStorage.setOrCreate('followingList', []);
    }
    if (isLog) {
      const savedId = await PreferenceManager.get(context, 'currentUserId', '') as string;
      const savedName = await PreferenceManager.get(context, 'userName', '') as string;
      const savedAvatar = await PreferenceManager.get(context, 'userAvatar', '') as string;

      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('currentUserId', savedId);
      AppStorage.setOrCreate('userName', savedName);

      if (savedAvatar === '' || savedAvatar === 'app.media.start' || savedAvatar === 'undefined') {
        AppStorage.setOrCreate('userAvatar', 'app.media.start');
      } else {
        AppStorage.setOrCreate('userAvatar', savedAvatar);
      }
    } else {
      AppStorage.setOrCreate('isLoggedIn', false);
      AppStorage.setOrCreate('currentUserId', '');
      AppStorage.setOrCreate('userName', '点击注册/登录');
      AppStorage.setOrCreate('userAvatar', 'app.media.start');
    }

    if (this.welcomeFinished) {
      this.setSystemWindowMode(false);
      this.showBottomBar = true;
      this.navOffsetY = 0;
      this.navOpacity = 1;
    } else {
      this.setSystemWindowMode(true);
      this.waitForWelcomeFinish();
    }
  }

  private waitForWelcomeFinish() {
    const timer = setInterval(() => {
      if (this.welcomeFinished) {
        clearInterval(timer)

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