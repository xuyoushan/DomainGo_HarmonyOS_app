import router from '@ohos.router'
import { ExploreView } from './explore/ExploreView'
import { CircleView } from './circle/CircleView'
import { GuideView } from './guide/GuideView'
import { MineView } from './mine/MineView'
import { BottomNavBar } from '../components/BottomNavBar'

@Entry
@Component
struct Index {
  @StorageLink('mainIndex') currentIndex: number = 0
  @StorageLink('welcomeFinished') welcomeFinished: boolean = false
  @State showBottomBar: boolean = false
  @State navOffsetY: number = 40
  @State navOpacity: number = 0
  aboutToAppear() {
    this.waitForWelcomeFinish()
  }
  private waitForWelcomeFinish() {
    const timer = setInterval(() => {
      if (this.welcomeFinished) {
        clearInterval(timer)
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
