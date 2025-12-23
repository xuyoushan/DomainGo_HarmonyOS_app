// Index.ets
import router from '@ohos.router';
import { ExploreView } from './explore/ExploreView';
import { CircleView } from './circle/CircleView';
import { GuideView } from './guide/GuideView';
import { MineView } from './mine/MineView';
import { BottomNavBar } from '../components/BottomNavBar';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    // 使用 Column 确保导航栏始终在屏幕最底部，不被内容遮挡
    Column() {
      Tabs({ index: this.currentIndex, barPosition: BarPosition.End }) {
        TabContent() { ExploreView() }
        TabContent() { CircleView() }
        // 发布按钮对应的中间占位
        TabContent() {
          Column() { Text('发布功能') }.justifyContent(FlexAlign.Center).height('100%')
        }
        TabContent() { GuideView() }
        TabContent() { MineView() }
      }
      .layoutWeight(1) // 自动占据剩余所有空间
      .barHeight(0)    // 隐藏原生页签
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })

      // 自定义底部导航栏
      // 注意：这里用 $ 符号同步 currentIndex
      BottomNavBar({ currentIndex: $currentIndex })
        .height(60) // 显式声明高度，解决图标遮挡
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 0, right: 0 })
    .backgroundColor('#F1F3F5')
  }
}