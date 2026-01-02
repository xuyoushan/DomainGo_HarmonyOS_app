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
              // 文旅精选
              this.FunctionCard('文旅精选', '玩转城市 · 精选推荐', [
                { name: '门票预订', icon: $r('sys.symbol.ticket_fill'), color: '#2F80ED' },
                { name: '语音导览', icon: $r('sys.symbol.mic_fill'), color: '#9B51E0' },
                { name: '博物馆预约', icon: $r('sys.symbol.house_fill'), color: '#F2994A' },
                { name: '城市商圈', icon: $r('sys.symbol.cart_fill'), color: '#27AE60' }
              ])

              // 政务助手
              this.FunctionCard('政务助手', '官方数据 · 权威查询', [
                { name: '行政隶属', icon: $r('sys.symbol.map_badge_cloud_slash_fill'), color: '#4568DC' },
                { name: '邮编查询', icon: $r('sys.symbol.envelope_fill'), color: '#B06AB3' },
                { name: '区号查询', icon: $r('sys.symbol.phone_fill'), color: '#56CCF2' },
                { name: '人口数据', icon: $r('sys.symbol.person_3_fill'), color: '#6FCF97' }
              ])

              // 更多功能
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

  // --- 4. 修改后的卡片组件：支持主副标题 + 蓝色竖线 ---
  @Builder FunctionCard(title: string, subTitle: string, items: FunctionItem[]) {
    Column() {
      // 标题组：包含蓝色竖线和主副标题
      Row() {
        // --- 重新加回来的蓝色竖线 ---
        Rect()
          .width(4)
          .height(18) // 高度对齐大标题字号
          .fill('#007DFF')
          .borderRadius(2)
          .margin({ top: 2 }) // 微调使其与第一行文字视觉对齐

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
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 }) // 与竖线的间距
      }
      .width('100%')
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
            } else {
              router.pushUrl({
                url: 'pages/features/GovServiceDetailView',
                params: { defaultType: item.name }
              })
            }
          })
        }, (item: FunctionItem) => item.name)
      }
      .width('100%')
      .padding({ top: 20, bottom: 4, left: 8, right: 8 })
      .backgroundColor('rgba(255,255,255,0.6)')
      .borderRadius(20)
      .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
    }
    .width('100%')
  }
}