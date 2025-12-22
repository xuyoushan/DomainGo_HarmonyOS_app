import { ExploreView } from './explore/ExploreView';
import { CircleView } from './circle/CircleView';
import { GuideView } from './guide/GuideView';
import { MineView } from './mine/MineView';
import { BottomNavBar } from '../components/BottomNavBar';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        // Index 0: 探索
        TabContent() { ExploreView() }

        // Index 1: 圈子
        TabContent() { CircleView() }

        // Index 2: 发布 (中间占位层)
        TabContent() {
          // 这里放一个空组件，并通过 onAppear 触发跳转逻辑
          Column()
            .onAppear(() => {
              // 当系统尝试渲染这个 Tab 时，立即执行跳转
              try {
                router.pushUrl({
                  url: 'pages/circle/PostDynamicView'
                })
              } catch (err) {
                console.error(`跳转失败: ${err.code}`)
              }
              // 跳转后，将索引改回之前的页面(比如首页或圈子)，防止用户返回时停留在这个空页面
              this.currentIndex = 1
            })
        }

        // Index 3: 导览 (索引保持不变)
        TabContent() { GuideView() }

        // Index 4: 我的 (索引保持不变)
        TabContent() { MineView() }
      }
      .scrollable(false)
      .barHeight(0)
      .layoutWeight(1)

      // 保持你原有的 BottomNavBar 不变
      BottomNavBar({ currentIndex: this.$currentIndex })
    }
    .width('100%')
    .height('100%')
  }
}