import { router } from '@kit.ArkUI';
import { CITY_TOOLKIT_CONFIG, DEFAULT_TOOLKIT_DATA, ToolkitTip } from '../../../models/CityToolkitData';

@Entry
@Component
struct CityToolkitView {
  @StorageLink('currentCity') currentCity: string = '武汉市';
  @State activeIndex: number = 0;

  build() {
    Stack() {
      // 1. 动态底色（随卡片主题色切换，增加沉浸感）
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getCurrentColor())
        .animation({ duration: 500 })

      // 背景装饰文字
      Text(this.currentCity)
        .fontSize(150)
        .fontWeight(FontWeight.Bolder)
        .fontColor('rgba(255,255,255,0.05)')
        .position({ x: -20, y: 100 })

      Column() {
        // --- 顶部状态 ---
        this.Header()

        // 2. 核心：横向堆叠轮播（让数据“显得”无穷无尽）
        Swiper() {
          ForEach(CITY_TOOLKIT_CONFIG[this.currentCity] || DEFAULT_TOOLKIT_DATA, (item: ToolkitTip) => {
            this.InteractiveCard(item)
          })
        }
        .width('100%')
        .height('70%')
        .loop(true)
        .indicator(false)
        .displayMode(SwiperDisplayMode.STRETCH)
        .effectMode(EdgeEffect.Spring)
        .itemSpace(20)
        .prevMargin(30)
        .nextMargin(30)
        .onChange((index) => this.activeIndex = index)

        // 3. 底部页码指示（增加书卷感）
        Text(`${this.activeIndex + 1} / ${(CITY_TOOLKIT_CONFIG[this.currentCity] || DEFAULT_TOOLKIT_DATA).length}`)
          .fontColor('rgba(255,255,255,0.6)')
          .fontSize(14)
          .margin({ top: 30 })
          .fontFamily('Monospace')
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  // 明确指定返回类型为 string
  getCurrentColor(): string {
    // 1. 获取对应城市的数据数组，并明确其类型为 ToolkitTip[]
    const data: ToolkitTip[] = CITY_TOOLKIT_CONFIG[this.currentCity] || DEFAULT_TOOLKIT_DATA;

    // 2. 检查索引是否存在，防止越界或 undefined
    if (data && data.length > this.activeIndex) {
      const item: ToolkitTip = data[this.activeIndex];
      return item.color;
    }

    // 3. 兜底返回一个默认颜色
    return '#333333';
  }

  @Builder Header() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(24).fontColor(['#FFF'])
        .onClick(() => router.back())
      Blank()
      Text('UNBOXING CITY').fontSize(12).fontColor('rgba(255,255,255,0.5)').letterSpacing(2)
    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 60 })
    .position({ y: 0 })
  }

  @Builder InteractiveCard(item: ToolkitTip) {
    Column() {
      // 卡片顶部：像档案夹一样的标签
      Row() {
        Text(item.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFF')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(4)
      }.width('100%').margin({ bottom: 40 })

      // 大图标
      SymbolGlyph(item.icon).fontSize(80).fontColor(['#FFF']).margin({ bottom: 30 })
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)' })

      // 主词条
      Text(item.mainInfo)
        .fontSize(28)
        .fontWeight(FontWeight.Bolder)
        .fontColor('#FFF')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 10 })

      Text(item.subInfo)
        .fontSize(16)
        .fontColor('rgba(255,255,255,0.7)')
        .margin({ bottom: 40 })

      // 💡 这里的“展开”逻辑：平时只显示一点点，诱导用户
      Column() {
        Text('「 灵魂备注 」')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.4)')
          .margin({ bottom: 10 })

        Scroll() {
          Text(item.crazyNote)
            .fontSize(16)
            .fontColor('#FFF')
            .lineHeight(26)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)
      .backgroundColor('rgba(0,0,0,0.15)')
      .borderRadius(15)
    }
    .width('100%')
    .height('100%')
    .padding(30)
    .backgroundColor('rgba(255,255,255,0.1)')
    .backgroundBlurStyle(BlurStyle.Thin) // 磨砂玻璃
    .borderRadius(30)
    .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
  }
}