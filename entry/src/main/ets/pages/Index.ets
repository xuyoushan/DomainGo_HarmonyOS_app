import router from '@ohos.router';
import { ExploreView } from './explore/ExploreView';
import { CircleView } from './circle/CircleView';
import { GuideView } from './guide/GuideView';
import { MineView } from './mine/MineView';
import { BottomNavBar } from '../components/BottomNavBar';

@Entry
@Component
struct Index {
  // 当前选中的索引，仅对应 0(探索), 1(圈子), 3(导览), 4(我的)
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        // Index 0
        TabContent() { ExploreView() }

        // Index 1
        TabContent() { CircleView() }

        // Index 2: 对应中间的 + 号
        TabContent() {
          Column() { Text('发布功能') }.width('100%').height('100%').justifyContent(FlexAlign.Center)
        }

        // Index 3 (跳过 2)
        TabContent() { GuideView() }

        // Index 4
        TabContent() { MineView() }
      }
      .scrollable(false)
      .barHeight(0) // 隐藏原生TabBar
      .layoutWeight(1)
      // .width('100%')
      // .height('100%')

      // 引入自定义导航栏，通过 @Link 双向绑定索引
      BottomNavBar({ currentIndex: this.$currentIndex })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}