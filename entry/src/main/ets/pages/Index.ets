import { ExploreView } from './explore/ExploreView';
import { CircleView } from './circle/CircleView';
import { PostView } from './post/PostView';
import { GuideView } from './guide/GuideView';
import { MineView } from './mine/MineView';
import { BottomNavBar } from '../components/BottomNavBar';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        // 这里的顺序必须死磕 BottomNavBar 的 index 定义

        // Index 0 -> 对应“探索” (虽然文件夹在中间，但代码必须排第一)
        TabContent() { ExploreView() }

        // Index 1 -> 对应“圈子”
        TabContent() { CircleView() }

        // Index 2 -> 对应“发布” (中间加号按钮)
        TabContent() { PostView() }

        // Index 3 -> 对应“导览”
        TabContent() { GuideView() }

        // Index 4 -> 对应“我的”
        TabContent() { MineView() }
      }
      .scrollable(false)
      .barHeight(0)
      .layoutWeight(1)

      // 绑定双向变量
      BottomNavBar({ currentIndex: this.$currentIndex })
    }
    .width('100%')
    .height('100%')
  }
}