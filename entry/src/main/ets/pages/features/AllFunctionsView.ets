// AllFunctionsView.ets
import { promptAction, router } from '@kit.ArkUI';

interface FunctionItem {
  name: string;
  icon: Resource;
  color: string;
}

@Entry
@Component
struct AllFunctionsView {
  private scroller: Scroller = new Scroller();
  @StorageLink('currentCity') currentCity: string = '武汉市';

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // --- 1. 背景渐变范围做大 ---
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#D6E4FF', 0.0],
            ['#F2F6FF', 0.3],
            ['#FFFFFF', 0.6],
            ['#FFFFFF', 1.0]
          ]
        })

      Column() {
        // --- 沉浸式标题栏 ---
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor(['#333'])
            .onClick(() => router.back())

          Text('服务大厅')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
            .fontColor('#1A1A1A')

          Blank()
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 20 })

        Scroll(this.scroller) {
          Column() {
            // --- 2. 居中的城市服务头部 ---
            Column() {
              Text(this.currentCity)
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F3C88')

              Text('这座城市，正在为你提供服务')
                .fontSize(13)
                .fontColor('#6B7A99')
                .margin({ top: 6 })
            }
            .padding({ left: 28, right: 28, bottom: 35, top: 20 })
            .width('100%')
            .justifyContent(FlexAlign.Center)

            // --- 3. 功能区布局 ---
            Column({ space: 28 }) {

              // ===== 文旅精选（原有）=====
              this.FunctionCard('文旅精选', '玩转城市 · 精选推荐', [
                { name: '门票预订', icon: $r('sys.symbol.ticket_fill'), color: '#2F80ED' },
                { name: '酒店住宿', icon: $r('sys.symbol.bed_double_fill'), color: '#45B7D1' },
                { name: '交通出行', icon: $r('sys.symbol.car_fill'), color: '#5AC8FA' },
                { name: '城市商圈', icon: $r('sys.symbol.cart_fill'), color: '#27AE60' }
              ])

              // ===== 政务助手（原有）=====
              this.FunctionCard('政务助手', '官方数据 · 权威查询', [
                { name: '行政隶属', icon: $r('sys.symbol.map_badge_cloud_slash_fill'), color: '#4568DC' },
                { name: '邮编查询', icon: $r('sys.symbol.envelope_fill'), color: '#B06AB3' },
                { name: '区号查询', icon: $r('sys.symbol.phone_fill'), color: '#56CCF2' },
                { name: '人口数据', icon: $r('sys.symbol.person_3_fill'), color: '#6FCF97' }
              ])

              // ===== 新增：行程与记录 =====
              this.FunctionCard('行程与记录', '出行规划与个人记录', [
                { name: '寻域锦囊', icon: $r('sys.symbol.briefcase_fill'), color: '#FF9500' },
                { name: '随手笔记', icon: $r('sys.symbol.square_and_pencil'), color: '#FAB1A0' },
                { name: '行程安排', icon: $r('sys.symbol.calendar_001_fill'), color: '#9B51E0' }
              ])

              // ===== 更多功能（原有，占位）=====
              this.FunctionCard('更多功能', '持续更新中', [
                { name: '敬请期待', icon: $r('sys.symbol.plus_circle_fill'), color: '#BDBDBD' }
              ])
            }
            .padding({ left: 16, right: 16, bottom: 40 })
          }
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
  }

  // --- FunctionCard 组件：完全未改 ---
  @Builder FunctionCard(title: string, subTitle: string, items: FunctionItem[]) {
    Column() {
      Row() {
        Rect()
          .width(4)
          .height(18)
          .fill('#007DFF')
          .borderRadius(2)
          .margin({ top: 2 })

        Column() {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text(subTitle)
            .fontSize(12)
            .fontColor('#7D8FB3')
            .margin({ top: 4 })
        }
        .margin({ left: 10 })
      }
      .margin({ bottom: 16, left: 4 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(items, (item: FunctionItem) => {
          Column() {
            Stack() {
              Circle()
                .width(56)
                .height(56)
                .fill(Color.White)
                .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 4 })

              SymbolGlyph(item.icon)
                .fontColor([item.color])
                .fontSize(28)
            }

            Text(item.name)
              .fontSize(12)
              .margin({ top: 10 })
              .fontColor('#4F4F4F')
              .fontWeight(FontWeight.Medium)
          }
          .width('25%')
          .margin({ bottom: 20 })
          .onClick(() => {
            if (item.name === '敬请期待') {
              promptAction.showToast({ message: '更多功能正在持续更新中...' });
              return;
            }

            // 1. 文旅类跳转
            const travelFunctions = ['门票预订', '酒店住宿', '交通出行'];
            if (travelFunctions.includes(item.name)) {
              router.pushUrl({
                url: 'pages/features/TravelServiceView',
                params: { defaultType: item.name }
              })
              return;
            }

            // 2. 政务类跳转
            const govFunctions = ['行政隶属', '邮编查询', '区号查询', '人口数据'];
            if (govFunctions.includes(item.name)) {
              router.pushUrl({
                url: 'pages/features/GovServiceDetailView',
                params: { defaultType: item.name }
              })
              return;
            }

            // 3. 通用功能跳转
            const pageMap: Record<string, string> = {
              '寻域锦囊': 'pages/features/CityToolkitView',
              '随手笔记': 'pages/features/NoteView',
              '行程安排': 'pages/features/ScheduleView',
            };

            const url = pageMap[item.name]; // 修正：使用当前点击项的名字
            if (url) {
              router.pushUrl({
                url: url,
                params: {
                  title: item.name,
                  cityName: this.currentCity,
                  color: item.color, // 修正：明确 initializer
                  icon: item.icon    // 修正：明确 initializer
                }
              });
            } else {
              promptAction.showToast({ message: `${item.name} 功能模块正在对接中...` });
            }
          })
        }, (item: FunctionItem) => item.name)
      }
      .padding({ top: 20, bottom: 4, left: 8, right: 8 })
      .backgroundColor('rgba(255,255,255,0.6)')
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
    }
  }
}
